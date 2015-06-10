//
//  AuthenticationServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AuthenticationServiceImpl.h"
#import "AuthorizeResult.h"
#import "RegisterResult.h"
#import "UserDataDAO.h"

#define testUserName    @"leonchn84@gmail.com"
#define testPassword    @"123456"
#define testFirstname   @"Leon"
#define testLastname    @"Chen"
#define testCity        @"Toronto"
#define testPostal      @"M1T2Z4"
#define testCountry     @"Canada"
#define testKey         @"testKey"

@interface AuthenticationServiceImpl ()

//demo purposes
@property (nonatomic, strong) NSMutableDictionary *userAccounts;

@end

@implementation AuthenticationServiceImpl

- (id) init
{
    self = [super init];
    
    self.userAccounts = [NSMutableDictionary new];
    
    //add demo account
    [self.userAccounts setObject:testPassword forKey:testUserName];
    
    return self;
}

- (void) authenticateUser: (NSString *) userName
                      withPassword: (NSString *) password
                           success: (AuthenticateUserSuccessBlock) success
                           failure: (AuthenticateUserFailureBlock) failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //simulate 1 seconds wait
        [NSThread sleepForTimeInterval:1.0f];
        
        AuthorizeResult *returnedResult = [AuthorizeResult new];
        
        if ([self.userAccounts objectForKey:userName] &&
            [[self.userAccounts objectForKey:userName] isEqualToString:password])
        {
            returnedResult.success = YES;
            returnedResult.message = @"login success";
            returnedResult.userName = userName;
            returnedResult.userAPIKey = testKey;
            returnedResult.firstname = testFirstname;
            returnedResult.lastname = testLastname;
            returnedResult.city = testCity;
            returnedResult.postalCode = testPostal;
            returnedResult.country = testCountry;
            
            //IMPORTANT: set the userKey to userDataDAO
            self.userDataDAO.userKey = testKey;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success ( returnedResult );
            });
        }
        else
        {
            returnedResult.success = NO;
            returnedResult.message = @"wrong credientials";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( returnedResult );
            });
        }
    });
    
    return;
}

- (void) registerNewUser: (NSString *) userName
                     withPassword: (NSString *) password
                    withFirstname: (NSString *) firstname
                     withLastname: (NSString *) lastname
                         withCity: (NSString *) city
                      withCountry: (NSString *) country
                       withPostal: (NSString *) postal
                          success: (RegisterNewUserSuccessBlock) success
                          failure: (RegisterNewUserSuccessBlock) failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //simulate 1 seconds wait
        [NSThread sleepForTimeInterval:1.0f];
        
        RegisterResult *registerResult = [RegisterResult new];
        
        if (userName.length && password.length)
        {
            [self.userAccounts setObject:password forKey:userName];
            
            registerResult.success = YES;
            registerResult.message = @"register success";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success ( registerResult );
            });
        }
        else
        {
            registerResult.success = NO;
            registerResult.message = @"missing credientials";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( registerResult );
            });
        }
    });
    
    return;
}

@end
