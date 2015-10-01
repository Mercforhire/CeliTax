//
//  UserManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationService.h"

@protocol AuthenticationService;

@class User, UserDataDAO, ConfigurationManager, BackgroundWorker,SubscriptionManager;

@interface UserManager : NSObject

@property (nonatomic, strong) User *user;

//This variable determines if the app should be restricted or not.
@property (nonatomic) BOOL subscriptionActive;

//This variable determines whether to show the disclaimer message upon login
@property (nonatomic) BOOL doNotShowDisclaimer;

@property (nonatomic, weak) id <AuthenticationService>  authenticationService;
@property (nonatomic, weak) ConfigurationManager        *configManager;
@property (nonatomic, weak) UserDataDAO                 *userDataDAO;
@property (nonatomic, weak) BackgroundWorker            *backgroundWorker;
@property (nonatomic, weak) SubscriptionManager         *subscriptionManager;

typedef void (^UpdateUserSubscriptionExpiryDateSuccessBlock) ();
typedef void (^UpdateUserSubscriptionExpiryDateFailureBlock) (NSString *reason);

-(BOOL)attemptToLoginSavedUser;

-(void)loginUserFor:(NSString *)loginName
             andKey:(NSString *)key
       andFirstname:(NSString *)firstname
        andLastname:(NSString *)lastname
         andCountry:(NSString *)country;

-(void)updateUserSubscriptionExpiryDate: (UpdateUserSubscriptionExpiryDateSuccessBlock) success
                                failure: (UpdateUserSubscriptionExpiryDateFailureBlock) failure;

-(void)changeUserDetails:(NSString *)firstname
             andLastname:(NSString *)lastname
              andCountry:(NSString *)country;

-(void)changeEmail:(NSString *)emailToChangeTo;

-(BOOL)doesUserHaveCustomProfileImage;

-(void)deleteUsersAvatar;

-(void)setNewAvatarImage: (UIImage *)image;

-(void)deleteAllLocalUserData;

-(void)logOutUser;

-(void)setExpiryDate: (NSString *)expiryDateString;

-(void)doNotShowDisclaimerAgain;

@end
