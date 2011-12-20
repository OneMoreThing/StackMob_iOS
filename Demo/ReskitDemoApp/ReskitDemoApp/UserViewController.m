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
#import "StackMob/STMResponseError.h"

@interface  UserViewController()
- (void) showErrorMessage:(NSString *)errorMessage;
@end

@implementation UserViewController
@synthesize tableView;
@synthesize refreshButton;
@synthesize users;
@synthesize selectedUser;

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
        [self refreshUserList:nil];
        users = [NSMutableArray array];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setRefreshButton:nil];
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
		UINavigationController *navigationController = segue.destinationViewController;
		UserDetailsViewController *vc = [[navigationController viewControllers] objectAtIndex:0];
        vc.title = @"Add User";
		vc.delegate = self;
	}
    else if ([segue.identifier isEqualToString:@"EditUser"])
    {
        UserDetailsViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.user = self.selectedUser;
        vc.title = @"Edit User";
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedUser = [users objectAtIndex:indexPath.row];
    return indexPath;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tv 
                             dequeueReusableCellWithIdentifier:@"UserCell"];
    UserModel *model = [users objectAtIndex:indexPath.row];
	cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.userName;
	return cell;
}

#pragma mark - EditUserViewControllerDelegate

- (void) userDetailsViewControllerDidCancelAdd:(UserDetailsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) userDetailsViewControllerDidCancelEdit:(UserDetailsViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) userDetailsViewControllerDidSave:(UserDetailsViewController *)controller
{
    UserModel *user = controller.user;
    user.name = controller.nameTextField.text;
    user.email = controller.emailTextField.text;
    user.password = controller.passwordTextField.text;
    
    [[StackMob stackmob] put:@"user" withObject:user andCallback:^(BOOL success, id result) {
        if(!success)
        {
            NSString *errorMessage = [(STMResponseError *)result error];
            [self showErrorMessage:errorMessage];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        if(success)
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void) userDetailsViewControllerDidAdd:(UserDetailsViewController *)controller
{
    UserModel *user = [[UserModel alloc] init];
    user.name = controller.nameTextField.text;
    user.email = controller.emailTextField.text;
    user.password = controller.passwordTextField.text;
    user.userName = controller.userNameTextField.text;
    
    [[StackMob stackmob] post:@"user" withObject:user andCallback:^(BOOL success, id result) {
        if(success)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [users addObject:[result lastObject]];
                NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:users.count-1 inSection:0]];
                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        else
        {
            NSString *errorMessage = [(STMResponseError *)result error];
            [self showErrorMessage:errorMessage];
        }
    }];
}

- (IBAction)refreshUserList:(id)sender {
    
    refreshButton.enabled = NO;
    [[StackMob stackmob] get:@"user" withCallback:^(BOOL success, id result) {
        
        if(success)
        {
            users = result;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            NSString *errorMessage = [(STMResponseError *)result error];
            [self showErrorMessage:errorMessage];
        }
        
        refreshButton.enabled = YES;
    }];
    
}

- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void) showErrorMessage:(NSString *)errorMessage
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:errorMessage 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles: nil];
    [alert show];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        UserModel *user = [users objectAtIndex:indexPath.row];
        
        [[StackMob stackmob] destroy:@"user" withObject:user andCallback:^(BOOL success, id result) {
            
            if(success)
            {
                [users removeObject:user];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                NSString *errorMessage = [(STMResponseError *)result error];
                [self showErrorMessage:errorMessage];
            }
        }];
    }
}

@end
