//
//  GitHubAPIRepository.h
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Const.h"
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <DCKeyValueObjectMapping/DCObjectMapping.h>
#import <DCKeyValueObjectMapping/DCParserConfiguration.h>
#import "Repository.h"

@interface GitHubAPIRepository : NSObject

+ (id)sharedRepository;

- (void)callSearchSwiftRepos:(NSDictionary *)params success:(void (^)(NSArray *respObj))success error:(void (^)(NSError *error)) failure;

@end
