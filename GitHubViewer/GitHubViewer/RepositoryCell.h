//
//  RepositoryCell.h
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoryCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelRepoName;
@property (strong, nonatomic) IBOutlet UILabel *labelRepoDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelForkCount;
@property (strong, nonatomic) IBOutlet UILabel *labelStarsCount;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewOwnerAvatar;
@property (strong, nonatomic) IBOutlet UILabel *labelOwnerUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelOwnerFullName;

@end
