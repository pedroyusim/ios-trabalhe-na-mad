//
//  CoreDataManager.h
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Repository;

@interface CoreDataManager : NSObject

+ (id)sharedManager;

//Repository Methods

- (NSManagedObject *)insertRepository:(Repository *)repository withPage:(int)page;

- (NSArray *)fetchAllStoreRepositoriesWithError:(NSError *)error;

- (NSArray *)fetchRepositoriesForPage:(int) page withError:(NSError *)error;

- (void)cleanAllCoreDataWithError:(NSError *)error;

//PullRequest Methods

- (NSArray *)insertPullRequestsFromArray:(NSArray *)pullRequests toRepository:(NSManagedObject *)repository withError:(NSError *)error;

- (NSMutableOrderedSet *)getPullRequestsFromRepository:(NSManagedObject *)repository;

@end
