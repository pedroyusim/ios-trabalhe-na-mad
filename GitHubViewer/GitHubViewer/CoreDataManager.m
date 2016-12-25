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

#pragma mark - Repository Methods

- (NSManagedObject *)insertRepository:(Repository *)repository withPage:(int)page {
    NSEntityDescription *ownerEntity = [NSEntityDescription entityForName:@"Owner" inManagedObjectContext:self.managedContext];
    
    NSManagedObject *ownerObject = [[NSManagedObject alloc] initWithEntity:ownerEntity insertIntoManagedObjectContext:self.managedContext];
    
    [ownerObject setValue:repository.owner.login forKey:KEY_OWNER_LOGIN];
    [ownerObject setValue:repository.owner.avatarUrl forKey:KEY_OWNER_AVATAR_URL];
    
    NSEntityDescription *repoEntity = [NSEntityDescription entityForName:@"Repository" inManagedObjectContext:self.managedContext];
    
    NSManagedObject *repoObject = [[NSManagedObject alloc] initWithEntity:repoEntity insertIntoManagedObjectContext:self.managedContext];
    
    [repoObject setValue:repository.name forKey:KEY_REPOSITORY_NAME];
    [repoObject setValue:repository.repositoryDescription forKey:KEY_REPOSITORY_DESCRIPTION];
    [repoObject setValue:repository.forksCount forKey:KEY_REPOSITORY_FORKS_COUNT];
    [repoObject setValue:repository.stargazersCount forKey:KEY_REPOSITORY_STARS_COUNT];
    [repoObject setValue:[NSNumber numberWithInteger:page] forKey:KEY_REPOSITORY_PAGE];
    
    [repoObject setValue:ownerObject forKey:KEY_REPOSITORY_OWNER];
    
    [self.appDel saveContext];
        
    return repoObject;
}

- (NSArray *)fetchAllStoreRepositoriesWithError:(NSError *)error {
    NSFetchRequest *fetchAllRepos = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    
    NSArray *allRepos = [self.managedContext executeFetchRequest:fetchAllRepos error:&error];
    
    return allRepos;
}

- (NSArray *)fetchRepositoriesForPage:(int) page withError:(NSError *)error {
    NSFetchRequest *fetchRepos = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    
    //Buscando apenas os repositorios da primeira pagina.
    [fetchRepos setPredicate:[NSPredicate predicateWithFormat:@"page == %d", page]];
    
    NSArray *repos = [self.managedContext executeFetchRequest:fetchRepos error:&error];
    
    NSLog(@"reposSIZE: %lu", (unsigned long)[repos count]);
    
    return repos;
    
}

- (void)cleanAllCoreDataWithError:(NSError *)error {
    NSFetchRequest *fetchOwners = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
    NSBatchDeleteRequest *batchDeleteOwners = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchOwners];
    
    [self.appDel.persistentContainer.persistentStoreCoordinator executeRequest:batchDeleteOwners withContext:self.managedContext error:&error];
    
    if(error == nil) {
        NSFetchRequest *fetchRepos = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
        NSBatchDeleteRequest *batchDeleteRepos = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRepos];
        
        [self.appDel.persistentContainer.persistentStoreCoordinator executeRequest:batchDeleteRepos withContext:self.managedContext error:&error];
        
        if(error == nil) {
            NSFetchRequest *fetchUsers = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            NSBatchDeleteRequest *batchDeleteUsers = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchUsers];
            
            [self.appDel.persistentContainer.persistentStoreCoordinator executeRequest:batchDeleteUsers withContext:self.managedContext error:&error];
            
            if(error == nil) {
                NSFetchRequest *fetchPullRequests = [NSFetchRequest fetchRequestWithEntityName:@"PullRequest"];
                NSBatchDeleteRequest *batchDeletePullRequests = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchPullRequests];
                
                [self.appDel.persistentContainer.persistentStoreCoordinator executeRequest:batchDeletePullRequests withContext:self.managedContext error:&error];
            }
        }
    }
}

#pragma mark - PullRequest Methods

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
