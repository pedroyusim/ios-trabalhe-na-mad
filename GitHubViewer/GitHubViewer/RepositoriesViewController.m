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
#import "PullRequestsViewController.h"
#import "CoreDataManager.h"

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
            NSLog(@"CurrentPage: %d --- LastCachedPage: %d", self.currentPage, self.lastCachedPage);
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
    
    //Chamar Controller de PullRequests
    NSManagedObject *selectedRepo = [self.arrayRepositoriesToShow objectAtIndex:indexPath.row];
    if(self.delegate) {
        PullRequestsViewController *pullReqsController = (PullRequestsViewController *)self.delegate;
        
        [self.splitViewController showDetailViewController:pullReqsController.navigationController sender:nil];
        
        [self.delegate selectRepository:selectedRepo];
    }
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
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(respObj != nil && [respObj count] > 0) {
                [self addReposToArrayAndCoreData:respObj];
                
                [self.tableViewRepos reloadData];
            } else {
                self.shouldKeepReloadingPages = NO;
            }
            
        } error:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.shouldKeepReloadingPages = NO;
        }];
    } else {
        //Neste caso nao carregamos webservice, pois ja tinhamos tudo o que precisavamos exibir.
        
    }
    
}

-(void)addReposToArrayAndCoreData:(NSArray *)arrayRepos {
    //Adicionando a CoreData
    for (Repository *repo in arrayRepos) {
        NSManagedObject *repoObject = [[CoreDataManager sharedManager] insertRepository:repo withPage:self.currentPage];
        
        [self.arrayRepositoriesToShow addObject:repoObject];
    }
    
    //Incrementamos contador de ultima pagina inserida no CoreData
    self.lastCachedPage++;
    
}

- (void)tryToLoadCachedRepositories {
    NSError *error = nil;
    
    NSError *allReposError = nil;
    
    NSArray *repositories = [[CoreDataManager sharedManager] fetchRepositoriesForPage:1 withError:error];
    
    NSArray *allStoredRepos = [[CoreDataManager sharedManager] fetchAllStoreRepositoriesWithError:allReposError];
    
    if(error == nil && allReposError == nil) {
        if(repositories != nil && [repositories count] > 0) {
            self.arrayRepositoriesToShow = [NSMutableArray arrayWithArray:repositories];
            
            //Precisamos saber até que página já exibimos e assim atualizar lastCachedPage
            NSNumber *ultimaPagina = [[allStoredRepos lastObject] valueForKey:KEY_REPOSITORY_PAGE];
            
            self.lastCachedPage = [ultimaPagina intValue];
            
            [self.tableViewRepos reloadData];
        }
    } else {
        //Erro ao buscar repositorios
    }
    
}

- (void)loadNextPage {
    NSError *error = nil;
    
    NSArray *repositories = [[CoreDataManager sharedManager] fetchRepositoriesForPage:self.currentPage withError:error];
    
    if(error == nil) {
        if(repositories != nil && [repositories count] > 0) {
            //Conseguimos carregar dados
            [self.arrayRepositoriesToShow addObjectsFromArray:repositories];
            
            [self.tableViewRepos reloadData];
        }
    } else {
        //Erro ao buscar repositorios
    }
    
}

- (void)cleanRepositoriesData {
    
    NSError *errorCleanAllCoreData = nil;
    
    [[CoreDataManager sharedManager] cleanAllCoreDataWithError:errorCleanAllCoreData];
    
    if(errorCleanAllCoreData == nil) {
        //Limpamos todos os dados
        
        self.arrayRepositoriesToShow = [NSMutableArray array];
        
        [self.tableViewRepos reloadData];
    }
}

#pragma mark - Action Methods

- (IBAction)barButtonRefreshClicked:(id)sender {
    self.lastCachedPage = 0;
    
    [self cleanRepositoriesData];
    
    [self.delegate allDataCleaned];
    
    self.currentPage = 1;
    
    [self callSwiftRepos:YES];
    
}

@end
