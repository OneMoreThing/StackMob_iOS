//
//  FirstViewController.m
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 11/3/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "UserViewController.h"
#import "UserDetailsViewController.h"
#import "UserModel.h"
#import "StackMob/StackMob.h"

@implementation UserViewController
@synthesize users;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!users)
    {
        users = [NSMutableArray array];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddUser"])
	{
		UINavigationController *navigationController = 
        segue.destinationViewController;
		UserDetailsViewController 
        *vc = 
        [[navigationController viewControllers] 
         objectAtIndex:0];
		vc.delegate = self;
	}
}

#pragma mark - UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"UserCell"];
	cell.textLabel.text = [users objectAtIndex:indexPath.row];
	return cell;
}

#pragma mark - EditUserViewControllerDelegate

- (void) userDetailsViewControllerDidCancel:(UserDetailsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) userDetailsViewControllerDidSave:(UserDetailsViewController *)controller
{
        UserModel *user = [[UserModel alloc] init];
        user.name = controller.nameTextField.text;
        user.email = controller.emailTextField.text;
        user.password = controller.passwordTextField.text;
        user.username = controller.userNameTextField.text;
    
        [[StackMob stackmob] post:@"user" withObject:user andCallback:^(BOOL success, id result) {
            if(success)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    [users addObject:result];
                }];
            }
            else
            {
                NSString *errorMessage = [result error];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                message:errorMessage 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Ok" 
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }];
}

@end
