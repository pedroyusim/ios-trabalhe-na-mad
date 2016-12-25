//
//  RepositoriesViewController.h
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepositoryControllerDelegate.h"

@interface RepositoriesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRepos;

@property (nonatomic, assign) id<RepositoryControllerDelegate> delegate;

- (IBAction)barButtonRefreshClicked:(id)sender;

@end
