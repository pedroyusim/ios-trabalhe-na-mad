//
//  CoreDataManager.m
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import "CoreDataManager.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Repository.h"
#import "PullRequest.h"
#import "Const.h"

@interface CoreDataManager()

@property AppDelegate *appDel;

@property NSManagedObjectContext *managedContext;

@end

@implementation CoreDataManager

+ (id)sharedManager {
    static CoreDataManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        //Inicializacao de variaveis do repositorio caso necessario.
        self.appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        self.managedContext = self.appDel.persistentContainer.viewContext;
    }
    return self;
}

- (NSArray *)insertPullRequestsFromArray:(NSArray *)pullRequests toRepository:(NSManagedObject *)repository withError:(NSError *)error {
    NSMutableArray *respArray = [NSMutableArray array];
    
    for (PullRequest *pullReq in pullRequests) {
        NSManagedObject *objectUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedContext];
    
        [objectUser setValue:pullReq.user.login forKey:KEY_USER_LOGIN];
        [objectUser setValue:pullReq.user.avatarUrl forKey:KEY_USER_AVATAR_URL];
        
        NSManagedObject *objectPullReq = [NSEntityDescription insertNewObjectForEntityForName:@"PullRequest" inManagedObjectContext:self.managedContext];

        [objectPullReq setValue:pullReq.title forKey:KEY_PULL_REQUEST_TITLE];
        [objectPullReq setValue:pullReq.body forKey:KEY_PULL_REQUEST_BODY];
        [objectPullReq setValue:pullReq.htmlUrl forKey:KEY_PULL_REQUEST_HTML_URL];
        [objectPullReq setValue:pullReq.createdAt forKey:KEY_PULL_REQUEST_CREATED_AT];
        
        [objectPullReq setValue:objectUser forKey:KEY_PULL_REQUEST_USER];
        
        NSMutableOrderedSet *repoPullReqs = [repository mutableOrderedSetValueForKey:KEY_REPOSITORY_PULL_REQUESTS];
        
        //TODO:Remover NSLOG
        NSLog(@"NSMUTABLESET SIZE: %lu", (unsigned long)[repoPullReqs count]);
        
        [repoPullReqs addObject:objectPullReq];
        
        [self.managedContext save:&error];
        
        [respArray addObject:objectPullReq];
    }
    
    return respArray;
}

- (NSMutableOrderedSet *)getPullRequestsFromRepository:(NSManagedObject *)repository {
    return [repository mutableOrderedSetValueForKey:KEY_REPOSITORY_PULL_REQUESTS];
}

@end
