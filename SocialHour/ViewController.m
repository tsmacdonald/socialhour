//
//  ViewController.m
//  SocialHour
//
//  Created by Tim Macdonald on 5/8/13.
//  Copyright (c) 2013 Tim Macdonald. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountType.h>


@interface ViewController ()


@end

@implementation ViewController

@synthesize twitterProfile;

NSString *username = @"CS394";

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onTweetButtonPressed:(id)sender
{
    NSLog(@"Hello world!");
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Whoa, this app is the greatest thing ever! Look at me telling all my friends about it!"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        //completion is a callback for after it's closed
    }
    else
    {
        NSLog(@"No tweeting available!");
    }

}

- (IBAction)onFacebookButtonPressed:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
            SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [vc setInitialText:@"Hello, happy Facebookers!"];

        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        NSString *message = @"It seems that we cannot talk to Facebook at the moment or you have not yet added your Facebook account to this device. Go to the Settings application to add your Facebook account to this device.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (IBAction)onTwitterDataRequested:(id)sender {
    [self getTwitterData];
}

- (void) getTwitterData
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                SLRequest *twitterDataRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:username forKey:@"screen_name"]];
                [twitterDataRequest setAccount:twitterAccount];
                [twitterDataRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([urlResponse statusCode] == 429) { //Rate limit
                            NSLog(@"Rate limit reached");
                            return;
                        }

                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        if (responseData) {
                            NSError *responseError = nil;
                            NSArray *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&responseError];
                            
                            NSLog(@"%@", twitterData);
                            NSDictionary *twitterDict = (NSDictionary *)twitterData;
                            NSString *screenName = [twitterDict objectForKey:@"screen_name"];
                            NSString *name = [twitterDict objectForKey:@"name"];
                            int followers = [[twitterDict objectForKey:@"followers_count"] integerValue];
                            int following = [[twitterDict objectForKey:@"friends_count"] integerValue];
                            int tweets = [[twitterDict objectForKey:@"statuses_count"] integerValue];
                            
                            twitterProfile.text = [NSString stringWithFormat:@"%@ (%@) has %d followers and is following %d people. (S)he has %d tweets.", name, screenName, followers, following, tweets];

                            
                        }
                    });
                }];
            }
        }
        else
        {
            NSLog(@"Access denied.");
        }
    }];
}
@end
