//
//  PullRequestsViewController.h
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepositoryControllerDelegate.h"

@interface PullRequestsViewController : UIViewController <RepositoryControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelFirstSelection;

@property (strong, nonatomic) IBOutlet UITableView *tableViewPullRequests;

@end
