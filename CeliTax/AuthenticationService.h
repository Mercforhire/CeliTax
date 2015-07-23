//
//  AuthenticationService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AuthorizeResult,RegisterResult,UserDataDAO,ConfigurationManager,NetworkCommunicator;

@protocol AuthenticationService <NSObject>

typedef void (^AuthenticateUserSuccessBlock) (AuthorizeResult *authorizeResult);
typedef void (^AuthenticateUserFailureBlock) (AuthorizeResult *authorizeResult);

typedef void (^RegisterNewUserSuccessBlock) (RegisterResult *registerResult);
typedef void (^RegisterNewUserFailureBlock) (RegisterResult *registerResult);

typedef void (^SendCommentSuccessBlock) ();
typedef void (^SendCommentFailureBlock) (NSString *reason);

@property (nonatomic, strong) UserDataDAO               *userDataDAO;
@property (nonatomic, strong) ConfigurationManager      *configManager;
@property (nonatomic, strong) NetworkCommunicator       *networkCommunicator;

- (void) authenticateUser: (NSString *) userName
             withPassword: (NSString *) password
                  success: (AuthenticateUserSuccessBlock) success
                  failure: (AuthenticateUserFailureBlock) failure;

- (void) registerNewUser: (NSString *) userName
            withPassword: (NSString *) password
           withFirstname: (NSString *) firstname
            withLastname: (NSString *) lastname
                withCity: (NSString *) city
             withCountry: (NSString *) country
              withPostal: (NSString *) postal
                 success: (RegisterNewUserSuccessBlock) success
                 failure: (RegisterNewUserSuccessBlock) failure;

- (void) sendComment: (NSString *)comment
             success: (SendCommentSuccessBlock) success
             failure: (SendCommentFailureBlock) failure;

@end
