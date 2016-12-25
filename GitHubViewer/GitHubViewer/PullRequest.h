//
//  PullRequest.h
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface PullRequest : NSObject

@property NSString *title;
@property NSString *body;
@property NSString *htmlUrl;
@property NSString *createdAt;

@property User *user;

@end
