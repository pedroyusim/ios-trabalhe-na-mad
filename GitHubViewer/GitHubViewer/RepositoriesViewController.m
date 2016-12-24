//
//  RepositoriesViewController.m
//  GitHubViewer
//
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

@property int lastCachedPage;

@property BOOL shouldKeepReloadingPages;

@property AppDelegate *appDel;

@property NSManagedObjectContext *managedContext;

@end

@implementation RepositoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO:REMOVER LOG
    NSLog(@"GITHUBVIEWER viewDidLoad");
    
    //Inicializando variaveis
    self.arrayRepositoriesToShow = [NSMutableArray array];
    self.currentPage = 1;
    self.lastCachedPage = 0;
    self.shouldKeepReloadingPages = YES;
    
    //Instanciando NSManagedObjectContext
    self.appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.managedContext = self.appDel.persistentContainer.viewContext;
    
    [self tryToLoadCachedRepositories];
    
    [self callSwiftRepos:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //TODO:REMOVER LOG
    NSLog(@"GITHUBVIEWER numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO:REMOVER LOG
    NSLog(@"GITHUBVIEWER numberOfRowsInSection -> %lu", (unsigned long)[self.arrayRepositoriesToShow count]);
    if(self.arrayRepositoriesToShow != nil && [self.arrayRepositoriesToShow count] > 0) {
        return [self.arrayRepositoriesToShow count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO:REMOVER LOG
    NSLog(@"GITHUBVIEWER cellForRowAtIndexPath");
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
            if(self.currentPage < self.lastCachedPage) {
                //Neste caso, devemos carregar do CoreData a nova pagina.
                self.currentPage++;
                
                [self loadNextPage];
            } else {
                self.currentPage++;
                [self callSwiftRepos:YES];
            }
        }
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
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

- (void)callSwiftRepos:(BOOL)isNewPageCall {
    //Verificamos se já temos a página gravada no CoreData. Se nao tivermos, buscamos no webservice.
    if(self.currentPage > self.lastCachedPage || isNewPageCall) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.currentPage], @"page", nil];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[GitHubAPIRepository sharedRepository] callSearchSwiftRepos:params success:^(NSArray *respObj) {
            NSLog(@"SUCCESS!!");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(respObj != nil && [respObj count] > 0) {
                [self addReposToArrayAndCoreData:respObj];
                
                [self.tableViewRepos reloadData];
            } else {
                self.shouldKeepReloadingPages = NO;
            }
            
        } error:^(NSError *error) {
            NSLog(@"ERROR!!!");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.shouldKeepReloadingPages = NO;
        }];
    } else {
        //Neste caso nao carregamos webservice, pois ja tinhamos tudo o que precisavamos exibir.
        NSLog(@"Pagina toda em cache");
    }
    
}

-(void)addReposToArrayAndCoreData:(NSArray *)arrayRepos {
    //Adicionando a CoreData
    for (Repository *repo in arrayRepos) {
        NSEntityDescription *ownerEntity = [NSEntityDescription entityForName:@"Owner" inManagedObjectContext:self.managedContext];
        
        NSManagedObject *ownerObject = [[NSManagedObject alloc] initWithEntity:ownerEntity insertIntoManagedObjectContext:self.managedContext];
        
        [ownerObject setValue:repo.owner.login forKey:KEY_OWNER_LOGIN];
        [ownerObject setValue:repo.owner.avatarUrl forKey:KEY_OWNER_AVATAR_URL];
        
        NSEntityDescription *repoEntity = [NSEntityDescription entityForName:@"Repository" inManagedObjectContext:self.managedContext];
        
        NSManagedObject *repoObject = [[NSManagedObject alloc] initWithEntity:repoEntity insertIntoManagedObjectContext:self.managedContext];
        
        [repoObject setValue:repo.name forKey:KEY_REPOSITORY_NAME];
        [repoObject setValue:repo.repositoryDescription forKey:KEY_REPOSITORY_DESCRIPTION];
        [repoObject setValue:repo.forksCount forKey:KEY_REPOSITORY_FORKS_COUNT];
        [repoObject setValue:repo.stargazersCount forKey:KEY_REPOSITORY_STARS_COUNT];
        [repoObject setValue:[NSNumber numberWithInteger:self.currentPage] forKey:KEY_REPOSITORY_PAGE];
        
        [repoObject setValue:ownerObject forKey:KEY_REPOSITORY_OWNER];
        
        [self.appDel saveContext];
        
        [self.arrayRepositoriesToShow addObject:repoObject];
    }
    
    //Incrementamos contador de ultima pagina inserida no CoreData
    self.lastCachedPage++;
    
}

- (void)tryToLoadCachedRepositories {
    
    NSFetchRequest *fetchRepos = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    
    //Buscando apenas os repositorios da primeira pagina.
    [fetchRepos setPredicate:[NSPredicate predicateWithFormat:@"page == %d", 1]];
    
    NSError *error = nil;
    
    NSArray *repositories = [self.managedContext executeFetchRequest:fetchRepos error:&error];
    
    if(error == nil) {
        if(repositories != nil && [repositories count] > 0) {
            NSLog(@"Conseguimos carregar dados");
            self.arrayRepositoriesToShow = [NSMutableArray arrayWithArray:repositories];
            
            //Precisamos saber até que página já exibimos e assim atualizar lastCachedPage
            NSNumber *ultimaPagina = [[repositories lastObject] valueForKey:KEY_REPOSITORY_PAGE];
            
            self.lastCachedPage = [ultimaPagina intValue] + 1;
            
            [self.tableViewRepos reloadData];
        }
    } else {
        NSLog(@"Erro ao buscar repositorios");
    }
    
}

- (void)loadNextPage {
    
    NSFetchRequest *fetchRepos = [NSFetchRequest fetchRequestWithEntityName:@"Repository"];
    
    //Buscando apenas os repositorios da primeira pagina.
    [fetchRepos setPredicate:[NSPredicate predicateWithFormat:@"page == %d", self.currentPage]];
    
    NSError *error = nil;
    
    NSArray *repositories = [self.managedContext executeFetchRequest:fetchRepos error:&error];
    
    if(error == nil) {
        if(repositories != nil && [repositories count] > 0) {
            NSLog(@"Conseguimos carregar dados");
            [self.arrayRepositoriesToShow addObjectsFromArray:repositories];
            
            [self.tableViewRepos reloadData];
        }
    } else {
        NSLog(@"Erro ao buscar repositorios");
    }
    
}

@end
