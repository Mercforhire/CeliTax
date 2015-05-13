//
//  AuthenticationService.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AuthorizeResult;
@class RegisterResult;

@protocol AuthenticationService <NSObject>

typedef void (^AuthenticateUserSuccessBlock) (AuthorizeResult *authorizeResult);
typedef void (^AuthenticateUserFailureBlock) (AuthorizeResult *authorizeResult);

typedef void (^RegisterNewUserSuccessBlock) (RegisterResult *registerResult);
typedef void (^RegisterNewUserFailureBlock) (RegisterResult *registerResult);

- (NSOperation *) authenticateUser: (NSString *) userName
                      withPassword: (NSString *) password
                           success: (AuthenticateUserSuccessBlock) success
                           failure: (AuthenticateUserFailureBlock) failure;

- (NSOperation *) registerNewUser: (NSString *) userName
                     withPassword: (NSString *) password
                    withFirstname: (NSString *) firstname
                     withLastname: (NSString *) lastname
                      withCountry: (NSString *) country
                       withPostal: (NSString *) postal
                          success: (RegisterNewUserSuccessBlock) success
                          failure: (RegisterNewUserSuccessBlock) failure;

@end
