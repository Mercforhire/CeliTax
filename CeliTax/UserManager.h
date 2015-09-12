//
//  UserManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationService.h"

@class User, UserDataDAO, ConfigurationManager, BackgroundWorker;

@interface UserManager : NSObject

@property (nonatomic, strong) User *user;

@property (nonatomic, weak) id <AuthenticationService>  authenticationService;
@property (nonatomic, weak) ConfigurationManager        *configManager;
@property (nonatomic, weak) UserDataDAO                 *userDataDAO;
@property (nonatomic, weak) BackgroundWorker            *backgroundWorker;

-(BOOL)attemptToLoginSavedUser;

-(void)loginUserFor:(NSString *)loginName
             andKey:(NSString *)key
       andFirstname:(NSString *)firstname
        andLastname:(NSString *)lastname
         andCountry:(NSString *)country;

-(void)changeUserDetails:(NSString *)firstname
             andLastname:(NSString *)lastname
              andCountry:(NSString *)country;

-(void)changeEmail:(NSString *)emailToChangeTo;

-(BOOL)doesUserHaveCustomProfileImage;

-(void)deleteUsersAvatar;

-(void)setNewAvatarImage: (UIImage *)image;

-(void)deleteAllLocalUserData;

-(void)logOutUser;

@end
