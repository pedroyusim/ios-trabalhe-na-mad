//
//  Repository.h
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Owner.h"

@interface Repository : NSObject

@property NSNumber *id;

@property NSString *name;

@property NSString *repositoryDescription;

@property NSNumber *stargazersCount;

@property NSNumber *forksCount;

@property Owner *owner;

@end
