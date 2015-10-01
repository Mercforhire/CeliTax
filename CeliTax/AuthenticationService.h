//
//  AuthenticationService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AuthorizeResult,RegisterResult,UserDataDAO,NetworkCommunicator;

@protocol AuthenticationService <NSObject>

#define USER_ALREADY_EXIST                      @"USER_ALREADY_EXIST"
#define USER_DOESNT_EXIST                       @"USER_DOESNT_EXIST"
#define USER_PASSWORD_WRONG                     @"USER_PASSWORD_WRONG"
#define PROFILE_IMAGE_FILE_DOESNT_EXIST         @"PROFILE_IMAGE_FILE_DOESNT_EXIST"
#define USER_CHANGE_EMAIL_ALREADY_EXIST         @"USER_CHANGE_EMAIL_ALREADY_EXIST"
#define NO_EXPIRATION_DATE_EXIST                @"NO_EXPIRATION_DATE_EXIST"

typedef void (^AuthenticateUserSuccessBlock) (AuthorizeResult *authorizeResult);
typedef void (^AuthenticateUserFailureBlock) (AuthorizeResult *authorizeResult);

typedef void (^RegisterNewUserSuccessBlock) (RegisterResult *registerResult);
typedef void (^RegisterNewUserFailureBlock) (RegisterResult *registerResult);

typedef void (^SendCommentSuccessBlock) ();
typedef void (^SendCommentFailureBlock) (NSString *reason);

typedef void (^UpdateAccountInfoSuccessBlock) ();
typedef void (^UpdateAccountInfoFailureBlock) (NSString *reason);

typedef void (^RetrieveProfileImageSuccessBlock) (UIImage *profileImage);
typedef void (^RetrieveProfileImageFailureBlock) (NSString *reason);

typedef void (^SubscriptionUpdateSuccessBlock) (NSString *expiryDateString);
typedef void (^SubscriptionUpdateFailureBlock) (NSString *reason);

typedef void (^GetSubscriptionExpiryDateSuccessBlock) (NSString *expiryDateString);
typedef void (^GetSubscriptionExpiryDateFailureBlock) (NSString *reason);

@property (nonatomic, weak) UserDataDAO               *userDataDAO;
@property (nonatomic, weak) NetworkCommunicator       *networkCommunicator;

- (void) authenticateUser: (NSString *) userName
             withPassword: (NSString *) password
                  success: (AuthenticateUserSuccessBlock) success
                  failure: (AuthenticateUserFailureBlock) failure;

- (void) registerNewUser: (NSString *) userName
            withPassword: (NSString *) password
           withFirstname: (NSString *) firstname
            withLastname: (NSString *) lastname
             withCountry: (NSString *) country
                 success: (RegisterNewUserSuccessBlock) success
                 failure: (RegisterNewUserSuccessBlock) failure;

- (void) sendComment: (NSString *)comment
             success: (SendCommentSuccessBlock) success
             failure: (SendCommentFailureBlock) failure;

- (void) updateAccountInfo: (NSString *) firstname
              withLastname: (NSString *) lastname
               withCountry: (NSString *) country
                   success: (UpdateAccountInfoSuccessBlock) success
                   failure: (UpdateAccountInfoFailureBlock) failure;

- (void) updateProfileImage: (UIImage *) profileImage
                    success: (UpdateAccountInfoSuccessBlock) success
                    failure: (UpdateAccountInfoFailureBlock) failure;

- (void) deleteProfileImage: (UpdateAccountInfoSuccessBlock) success
                    failure: (UpdateAccountInfoFailureBlock) failure;

- (void) retrieveProfileImage: (RetrieveProfileImageSuccessBlock) success
                      failure: (RetrieveProfileImageFailureBlock) failure;

- (void) updateEmailTo: (NSString *)emailToChangeTo
               success: (UpdateAccountInfoSuccessBlock) success
               failure: (UpdateAccountInfoFailureBlock) failure;

- (void) updatePassword: (NSString *)oldPassword
     passwordToChangeTo: (NSString *)passwordToChangeTo
                success: (UpdateAccountInfoSuccessBlock) success
                failure: (UpdateAccountInfoFailureBlock) failure;

- (void) killAccount: (NSString *)password
             success: (UpdateAccountInfoSuccessBlock) success
             failure: (UpdateAccountInfoFailureBlock) failure;

- (void) getSubscriptionExpiryDate: (GetSubscriptionExpiryDateSuccessBlock) success
                           failure: (GetSubscriptionExpiryDateFailureBlock) failure;

- (void) addNumberOfMonthToUserSubscription: (NSInteger) numberOfMonth
                                    success: (SubscriptionUpdateSuccessBlock) success
                                    failure: (SubscriptionUpdateFailureBlock) failure;

@end
