//
//  PullRequestCell.h
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullRequestCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelPullRequestTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelPullRequestDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelOwnerUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelOwnerFullName;
@property (strong, nonatomic) IBOutlet UILabel *labelPullRequestCreationTime;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewOwnerAvatar;

@end
