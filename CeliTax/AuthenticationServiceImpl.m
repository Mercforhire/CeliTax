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
#import "ConfigurationManager.h"
#import "NetworkCommunicator.h"

@interface AuthenticationServiceImpl ()

@end

@implementation AuthenticationServiceImpl

- (void) authenticateUser: (NSString *) userName
             withPassword: (NSString *) password
                  success: (AuthenticateUserSuccessBlock) success
                  failure: (AuthenticateUserFailureBlock) failure
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       userName,@"email",
                                       password,@"password"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"login"] ] ;
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        AuthorizeResult *returnedResult = [AuthorizeResult new];
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [[response objectForKey:@"error"] boolValue] == NO )
        {
            returnedResult.success = YES;
            returnedResult.message = @"Login Success";
            returnedResult.userName = [response objectForKey:@"email"];
            returnedResult.userAPIKey = [response objectForKey:@"api_key"];
            returnedResult.firstname = [response objectForKey:@"first_name"];
            returnedResult.lastname = [response objectForKey:@"last_name"];
            returnedResult.city = [response objectForKey:@"city"];
            returnedResult.postalCode = [response objectForKey:@"postal_code"];
            returnedResult.country = [response objectForKey:@"country"];
            
            //IMPORTANT: set the userKey to userDataDAO
            self.userDataDAO.userKey = returnedResult.userAPIKey;
            
            //TODO: default to on, will change this later
            [self.configManager setTutorialON:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                {
                    success ( returnedResult );
                }
            });
        }
        else
        {
            returnedResult.success = NO;
            returnedResult.message = [response objectForKey:@"message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure)
                {
                    failure ( returnedResult );
                }
            });
        }
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        AuthorizeResult *returnedResult = [AuthorizeResult new];
        
        returnedResult.success = NO;
        returnedResult.message = @"network error";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( returnedResult );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
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
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       userName,@"email",
                                       password,@"password",
                                       firstname,@"first_name",
                                       lastname,@"last_name",
                                       city,@"city",
                                       postal,@"postal_code",
                                       country,@"country"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"register"] ] ;
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        RegisterResult *registerResult = [RegisterResult new];
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [[response objectForKey:@"error"] boolValue] == NO )
        {
            registerResult.success = YES;
            registerResult.message = @"You are successfully registered.";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success ( registerResult );
            });
        }
        else
        {
            registerResult.success = NO;
            registerResult.message = [response objectForKey:@"message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( registerResult );
            });
        }
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        RegisterResult *registerResult = [RegisterResult new];
        
        registerResult.success = NO;
        registerResult.message = @"Network Error";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( registerResult );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) sendComment: (NSString *)comment
             success: (SendCommentSuccessBlock) success
             failure: (SendCommentFailureBlock) failure
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       comment,@"feedback_text"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"submit_feedback"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [[response objectForKey:@"error"] boolValue] == NO )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                {
                    success ( );
                }
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure)
                {
                    failure ( [response objectForKey:@"message"] );
                }
            });
        }
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( @"Network Error" );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

@end
