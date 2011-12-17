//
//  UserDetailsViewController.h
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserDetailsViewController;
@protocol UserDetailsViewControllerDelegate <NSObject>

- (void) userDetailsViewControllerDidSave:(UserDetailsViewController *)controller;
- (void) userDetailsViewControllerDidCancel:(UserDetailsViewController *)controller;

@end

@interface UserDetailsViewController : UITableViewController
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *roleTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet id <UserDetailsViewControllerDelegate> delegate;

@end
