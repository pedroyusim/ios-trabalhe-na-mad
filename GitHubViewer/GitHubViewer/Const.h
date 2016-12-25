//
//  Const.h
//  GitHubViewer
//
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

/**
 
 Arquivo para definição de constantes globais
 
 **/

#ifndef Const_h
#define Const_h

//Variaveis para API
#define API_URL @"https://api.github.com/"

/* Variaveis para Coredata */
//Repository
#define KEY_REPOSITORY_ID @"id"
#define KEY_REPOSITORY_NAME @"name"
#define KEY_REPOSITORY_DESCRIPTION @"repositoryDescription"
#define KEY_REPOSITORY_FORKS_COUNT @"forksCount"
#define KEY_REPOSITORY_STARS_COUNT @"stargazersCount"
#define KEY_REPOSITORY_OWNER @"owner"
#define KEY_REPOSITORY_PAGE @"page"
#define KEY_REPOSITORY_PULL_REQUESTS @"pullRequests"

//Owner
#define KEY_OWNER_LOGIN @"login"
#define KEY_OWNER_AVATAR_URL @"avatarUrl"

//Pull Request
#define KEY_PULL_REQUEST_TITLE @"title"
#define KEY_PULL_REQUEST_HTML_URL @"htmlUrl"
#define KEY_PULL_REQUEST_BODY @"body"
#define KEY_PULL_REQUEST_CREATED_AT @"createdAt"
#define KEY_PULL_REQUEST_USER @"user"

//User
#define KEY_USER_LOGIN @"login"
#define KEY_USER_AVATAR_URL @"avatarUrl"


#endif /* Const_h */
