//
//  PullRequestsViewController.m
//  GitHubViewer
//
//  Created by Lorna Kemp on 24/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import "PullRequestsViewController.h"
#import "Const.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GitHubAPIRepository.h"
#import "CoreDataManager.h"
#import "PullRequestCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PullRequestsViewController ()

@property NSArray *arrayPullRequestsToShow;

@end

@implementation PullRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.arrayPullRequestsToShow == nil) {
        self.arrayPullRequestsToShow = [NSArray array];
    }
    
    [self.tableViewPullRequests setTableFooterView:[[UIView alloc] init]];
    
    [self.tableViewPullRequests setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.arrayPullRequestsToShow != nil && [self.arrayPullRequestsToShow count] > 0) {
        [self.labelFirstSelection setHidden:YES];
        [self.tableViewPullRequests setHidden:NO];
    } else {
        if([MBProgressHUD HUDForView:self.view] == nil) {
            [self.labelFirstSelection setHidden:NO];
        }
        
        [self.tableViewPullRequests setHidden:YES];
    }
    
    [self.tableViewPullRequests reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.arrayPullRequestsToShow != nil && [self.arrayPullRequestsToShow count] > 0) {
        return [self.arrayPullRequestsToShow count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.arrayPullRequestsToShow != nil && [self.arrayPullRequestsToShow count] > 0) {
        PullRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pullRequestCell"];
        
        NSManagedObject *pullReq = [self.arrayPullRequestsToShow objectAtIndex:indexPath.row];
        
        cell.labelPullRequestTitle.text = [pullReq valueForKey:KEY_PULL_REQUEST_TITLE];
        cell.labelPullRequestDescription.text = [pullReq valueForKey:KEY_PULL_REQUEST_BODY];
        
        cell.labelOwnerUsername.text = [[pullReq valueForKey:KEY_PULL_REQUEST_USER] valueForKey:KEY_USER_LOGIN];
        //Objeto retornado por API não tem este valor, portanto, setamos para string vazia.
        cell.labelOwnerFullName.text = @"";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

        NSDate *createdDate = [dateFormatter dateFromString:[pullReq valueForKey:KEY_PULL_REQUEST_CREATED_AT]];
        
        NSDateFormatter *commomDateFormatter = [[NSDateFormatter alloc] init];
        [commomDateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];

        cell.labelPullRequestCreationTime.text = [commomDateFormatter stringFromDate:createdDate];
        
        [cell.imageViewOwnerAvatar sd_setImageWithURL:[NSURL URLWithString:[[pullReq valueForKey:KEY_PULL_REQUEST_USER] valueForKey:KEY_USER_AVATAR_URL]] placeholderImage:[UIImage imageNamed:@"owner-placeholder"]];
        
        return cell;
    }
    
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSManagedObject *pullReq = [self.arrayPullRequestsToShow objectAtIndex:indexPath.row];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[pullReq valueForKey:KEY_PULL_REQUEST_HTML_URL]]];
}

#pragma mark - RepositoryDelegate Methods

-(void)selectRepository:(NSManagedObject *)repo {
    [self.labelFirstSelection setHidden:YES];
    
    [self.navigationItem setTitle:[repo valueForKey:KEY_REPOSITORY_NAME]];
    
    NSMutableOrderedSet *pullRequests = [[CoreDataManager sharedManager] getPullRequestsFromRepository:repo];
    
    if([pullRequests count] == 0) {
        self.arrayPullRequestsToShow = [NSArray array];
        [self.tableViewPullRequests reloadData];
        
        [self callGetPullRequests:repo];
    } else {
        //Neste caso exibimos as informacoes gravadas no CoreData
        [self.tableViewPullRequests setHidden:NO];
        [self.labelFirstSelection setHidden:YES];
        
        self.arrayPullRequestsToShow = [NSArray arrayWithArray:[pullRequests array]];
        [self.tableViewPullRequests reloadData];
    }
}

- (void)allDataCleaned {
    //Neste momento MasterView limpou todos os dados.
    
    self.arrayPullRequestsToShow = [NSArray array];
    
    [self.labelFirstSelection setText:@"Por favor, selecione um repositório."];
    
    [self.labelFirstSelection setHidden:NO];
    [self.tableViewPullRequests setHidden:YES];
    
    [self.tableViewPullRequests reloadData];
}

#pragma mark - Helper Methods

- (void)callGetPullRequests:(NSManagedObject *)repository {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [repository valueForKey:KEY_REPOSITORY_NAME], @"repository",
                            [[repository valueForKey:KEY_REPOSITORY_OWNER] valueForKey:KEY_OWNER_LOGIN], @"owner",
                            nil];
    
    [[GitHubAPIRepository sharedRepository] callGetPullRequests:params success:^(NSArray *respObj) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if(respObj != nil) {
            if([respObj count] > 0) {
                [self.tableViewPullRequests setHidden:NO];
                [self.labelFirstSelection setHidden:YES];
                
                [self addPullRequestsArray:respObj toRepository:repository];
            } else {
                [self.tableViewPullRequests setHidden:YES];
                [self.labelFirstSelection setHidden:NO];
                self.labelFirstSelection.text = @"Este repositório não contém nenhum Pull Request aberto.";
            }
        } else {
            [self.tableViewPullRequests setHidden:YES];
            [self.labelFirstSelection setHidden:NO];
            
            self.labelFirstSelection.text = @"Ocorreu algum erro ao carregar a lista de Pull Requests. Por favor, tente novamente.";
        }
        
    } error:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.tableViewPullRequests setHidden:YES];
        [self.labelFirstSelection setHidden:NO];
        
        self.labelFirstSelection.text = @"Ocorreu algum erro ao carregar a lista de Pull Requests. Por favor, tente novamente.";
    }];
    
}

- (void)addPullRequestsArray:(NSArray *)pullRequests toRepository:(NSManagedObject *)repository{
    NSError *operationError = nil;
    
    NSArray *managedObjectsArray = [[CoreDataManager sharedManager] insertPullRequestsFromArray:pullRequests toRepository:repository withError:operationError];
    
    if(operationError == nil) {
        self.arrayPullRequestsToShow = managedObjectsArray;
        
        [self.tableViewPullRequests reloadData];
    }
}

@end
