//
//  RepositoriesViewController.m
//  GitHubViewer
//
//  Created by Pedro Yusim on 23/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import "RepositoriesViewController.h"
#import <CoreData/CoreData.h>
#import "RepositoryCell.h"
#import "Repository.h"
#import "Const.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GitHubAPIRepository.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RepositoriesViewController ()

@property NSMutableArray *arrayRepositoriesToShow;

@property int currentPage;

@property BOOL shouldKeepReloadingPages;

@end

@implementation RepositoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Inicializando variaveis
    self.arrayRepositoriesToShow = [NSMutableArray array];
    self.currentPage = 1;
    self.shouldKeepReloadingPages = YES;
    
    [self callSwiftRepos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.arrayRepositoriesToShow != nil && [self.arrayRepositoriesToShow count] > 0) {
        return [self.arrayRepositoriesToShow count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.arrayRepositoriesToShow != nil && [self.arrayRepositoriesToShow count] > 0) {
        RepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repoCell"];
        
        NSManagedObject *currentRepo = [self.arrayRepositoriesToShow objectAtIndex:indexPath.row];
        
        cell.labelRepoName.text = [currentRepo valueForKey:KEY_REPOSITORY_NAME];
        cell.labelRepoDescription.text = [currentRepo valueForKey:KEY_REPOSITORY_DESCRIPTION];
        cell.labelForkCount.text = [NSString stringWithFormat:@"%@",[currentRepo valueForKey:KEY_REPOSITORY_FORKS_COUNT]];
        cell.labelStarsCount.text = [NSString stringWithFormat:@"%@",[currentRepo valueForKey:KEY_REPOSITORY_STARS_COUNT]];
        
        cell.labelOwnerUsername.text = [[currentRepo valueForKey:KEY_REPOSITORY_OWNER] valueForKey:KEY_OWNER_LOGIN];
        
        [cell.imageViewOwnerAvatar sd_setImageWithURL:[NSURL URLWithString:[[currentRepo valueForKey:KEY_REPOSITORY_OWNER] valueForKey:KEY_OWNER_AVATAR_URL]] placeholderImage:[UIImage imageNamed:@"owner-placeholder"]];
        
        //Não há onde pegar esta informação, portanto, não exibo.
        cell.labelOwnerFullName.text = @"";
        
        if(indexPath.row == [self.arrayRepositoriesToShow count] - 1 && self.shouldKeepReloadingPages) {
            self.currentPage++;
            [self callSwiftRepos];
        }
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helper Methods

- (void)callSwiftRepos {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.currentPage], @"page", nil];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[GitHubAPIRepository sharedRepository] callSearchSwiftRepos:params success:^(NSArray *respObj) {
        NSLog(@"SUCCESS!!");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(respObj != nil && [respObj count] > 0) {
            [self addReposToArrayAndCoreData:respObj];
            
            [self.arrayRepositoriesToShow addObjectsFromArray:respObj];
            
            [self.tableViewRepos reloadData];
        } else {
            self.shouldKeepReloadingPages = NO;
        }
        
    } error:^(NSError *error) {
        NSLog(@"ERROR!!!");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.shouldKeepReloadingPages = NO;
    }];
    
}

-(void)addReposToArrayAndCoreData:(NSArray *)arrayRepos {
    //Adicionando a variavel
//    [self.arrayRepositoriesToShow addObjectsFromArray:arrayRepos];
    
    //Adicionando a CoreData
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *managedContext = appDel.persistentContainer.viewContext;
    
    for (Repository *repo in arrayRepos) {
        NSEntityDescription *ownerEntity = [NSEntityDescription entityForName:@"Owner" inManagedObjectContext:managedContext];
        
        NSManagedObject *ownerObject = [[NSManagedObject alloc] initWithEntity:ownerEntity insertIntoManagedObjectContext:managedContext];
        
        [ownerObject setValue:repo.owner.login forKey:KEY_OWNER_LOGIN];
        [ownerObject setValue:repo.owner.avatarUrl forKey:KEY_OWNER_AVATAR_URL];
        
        NSEntityDescription *repoEntity = [NSEntityDescription entityForName:@"Repository" inManagedObjectContext:managedContext];
        
        NSManagedObject *repoObject = [[NSManagedObject alloc] initWithEntity:repoEntity insertIntoManagedObjectContext:managedContext];
        
        [repoObject setValue:repo.name forKey:KEY_REPOSITORY_NAME];
        [repoObject setValue:repo.repositoryDescription forKey:KEY_REPOSITORY_DESCRIPTION];
        [repoObject setValue:repo.forksCount forKey:KEY_REPOSITORY_FORKS_COUNT];
        [repoObject setValue:repo.stargazersCount forKey:KEY_REPOSITORY_STARS_COUNT];
        
        [repoObject setValue:ownerObject forKey:KEY_REPOSITORY_OWNER];
        
        [appDel saveContext];
        
        [self.arrayRepositoriesToShow addObject:repoObject];
    }
    
}

@end
