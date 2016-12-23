//
//  RepositoriesViewController.h
//  GitHubViewer
//
//  Created by Lorna Kemp on 23/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoriesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRepos;

@end
