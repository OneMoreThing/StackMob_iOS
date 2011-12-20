//
//  UserDetailsViewController.m
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "UserModel.h"

@implementation UserDetailsViewController
@synthesize user;
@synthesize roleTextField;
@synthesize nameTextField;
@synthesize userNameTextField;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize password2TextField;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if(self.user)
    {
        self.emailTextField.text = self.user.email;
        self.nameTextField.text = self.user.name;
        self.passwordTextField.text = @"****";
        self.password2TextField.text = @"****";
        self.userNameTextField.text = self.user.userName;
    }
    
    self.userNameTextField.enabled = self.user == nil;
    self.passwordTextField.enabled = self.user == nil;
    self.password2TextField.enabled = self.user == nil;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

- (IBAction)cancel:(id)sender
{
    if(self.user)
    {
        [delegate userDetailsViewControllerDidCancelEdit:self];
    } else {
        [delegate userDetailsViewControllerDidCancelAdd:self];
    }
}

- (IBAction)save:(id)sender {
    if(self.user)
    {
        [delegate userDetailsViewControllerDidSave:self];
    } else {
        [delegate userDetailsViewControllerDidAdd:self];
    }
}
@end
