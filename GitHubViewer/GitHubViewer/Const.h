//
//  Const.h
//  GitHubViewer
//
//  Created by Pedro Yusim on 23/12/16.
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
#define KEY_REPOSITORY_NAME @"name"
#define KEY_REPOSITORY_DESCRIPTION @"repositoryDescription"
#define KEY_REPOSITORY_FORKS_COUNT @"forksCount"
#define KEY_REPOSITORY_STARS_COUNT @"stargazersCount"
#define KEY_REPOSITORY_OWNER @"owner"

//Owner
#define KEY_OWNER_LOGIN @"login"
#define KEY_OWNER_AVATAR_URL @"avatarUrl"

#endif /* Const_h */
