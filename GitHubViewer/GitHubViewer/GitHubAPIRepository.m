//
//  GitHubAPIRepository.m
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import "GitHubAPIRepository.h"

@implementation GitHubAPIRepository

+ (id)sharedRepository {
    static GitHubAPIRepository *sharedRepository = nil;
    @synchronized(self) {
        if (sharedRepository == nil)
        sharedRepository = [[self alloc] init];
    }
    return sharedRepository;
}

- (id)init {
    if (self = [super init]) {
        //Inicializacao de variaveis do repositorio caso necessario.
        
    }
    return self;
}

- (void)callSearchSwiftRepos:(NSDictionary *)params success:(void (^)(NSArray *respObj))success error:(void (^)(NSError *error)) failure {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",API_URL,@"search/repositories?q=language:Swift&sort=stars&page=", [params objectForKey:@"page"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error && responseObject == nil) {
            failure(nil);
        } else {
            @try {
                NSArray *repos = [responseObject objectForKey:@"items"];
                
                if(repos != nil) {
                    DCParserConfiguration *config = [DCParserConfiguration configuration];
                    
                    DCObjectMapping *descriptionMapping = [DCObjectMapping mapKeyPath:@"description" toAttribute:@"repositoryDescription" onClass:[Repository class]];
                    
                    [config addObjectMapping:descriptionMapping];
                    
                    DCKeyValueObjectMapping *repoMapper = [DCKeyValueObjectMapping mapperForClass:[Repository class] andConfiguration:config];
                    
                    NSMutableArray *respArray = [NSMutableArray array];
                    
                    for (NSDictionary *dict in repos) {
                        Repository *repo = [repoMapper parseDictionary:dict];
                        
                        [respArray addObject:repo];
                    }
                    
                    success(respArray);
                } else {
                    //Neste caso atingimos o limite que podemos acessar ou acabaram os repositórios.
                    success(nil);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Ocorreu um erro ou chegamos na ultima pagina: %@", [exception reason]);
                success(nil);
            }
        }
    }];
    [dataTask resume];
    
}

- (void)callGetPullRequests:(NSDictionary *)params success:(void (^)(NSArray *respObj))success error:(void (^)(NSError *error)) failure {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/%@%@",API_URL,@"repos/", [params objectForKey:@"owner"], [params objectForKey:@"repository"],@"/pulls"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            failure(nil);
        } else {
            @try {
                NSArray *repos = (NSArray *)responseObject;
                
                if(repos != nil) {
                    DCParserConfiguration *config = [DCParserConfiguration configuration];
                    
                    DCKeyValueObjectMapping *pullReqMapper = [DCKeyValueObjectMapping mapperForClass:[PullRequest class] andConfiguration:config];
                    
                    NSMutableArray *respArray = [NSMutableArray array];
                    
                    for (NSDictionary *dict in repos) {
                        PullRequest *repo = [pullReqMapper parseDictionary:dict];
                        
                        [respArray addObject:repo];
                    }
                    
                    success(respArray);
                }
            }
            @catch (NSException *exception) {
                success(nil);
            }
            
        }
    }];
    [dataTask resume];
    
}

@end
