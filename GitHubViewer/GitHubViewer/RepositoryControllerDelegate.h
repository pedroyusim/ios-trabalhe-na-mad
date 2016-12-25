//
//  RepositoryControllerDelegate.h
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Repository;
@protocol RepositoryControllerDelegate <NSObject>

@required
-(void)selectRepository:(NSManagedObject *)repo;

-(void)allDataCleaned;

@end
