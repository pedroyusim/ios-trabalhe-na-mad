//
//  CoreDataManager.h
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

+ (id)sharedManager;

- (NSArray *)insertPullRequestsFromArray:(NSArray *)pullRequests toRepository:(NSManagedObject *)repository withError:(NSError *)error;

- (NSMutableOrderedSet *)getPullRequestsFromRepository:(NSManagedObject *)repository;

@end
