//
//  UserManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationService.h"

@class User, UserDataDAO, ConfigurationManager;

@interface UserManager : NSObject

@property (nonatomic, strong) User *user;

@property (nonatomic, weak) id <AuthenticationService>  authenticationService;
@property (nonatomic, strong) ConfigurationManager      *configManager;
@property (nonatomic, strong) UserDataDAO               *userDataDAO;

-(BOOL)attemptToLoginSavedUser;

-(void)loginUserFor:(NSString *)loginName
             andKey:(NSString *)key
       andFirstname:(NSString *)firstname
        andLastname:(NSString *)lastname
            andCity:(NSString *)city
      andPostalCode:(NSString *)postalCode
         andCountry:(NSString *)country;

-(void)changeUserDetails:(NSString *)firstname
             andLastname:(NSString *)lastname
                 andCity:(NSString *)city
           andPostalCode:(NSString *)postalCode;

-(BOOL)doesUserHaveCustomProfileImage;

-(void)deleteUsersAvatar;

-(void)setNewAvatarImage: (UIImage *)image;

-(void)logOutUser;

@end
