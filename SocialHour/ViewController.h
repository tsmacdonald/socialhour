//
//  ViewController.h
//  SocialHour
//
//  Created by Tim Macdonald on 5/8/13.
//  Copyright (c) 2013 Tim Macdonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *twitterProfile;

- (IBAction)onTweetButtonPressed:(id)sender;
- (IBAction)onFacebookButtonPressed:(id)sender;
- (IBAction)onTwitterDataRequested:(id)sender;

@end
