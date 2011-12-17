//
//  FirstViewController.h
//  ReskitDemoApp
//
//  Created by Ryan Connelly on 11/3/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDetailsViewController.h"

@interface UserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UserDetailsViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *users;

@end
