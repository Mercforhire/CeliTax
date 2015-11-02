//
//  AuthenticationServiceImpl.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-29.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AuthenticationServiceImpl.h"
#import "UserDataDAO.h"
#import "ConfigurationManager.h"
#import "NetworkCommunicator.h"
#import "Utils.h"
#import "CeliTax-Swift.h"

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
        
        if ( [response[@"error"] boolValue] == NO )
        {
            returnedResult.success = YES;
            returnedResult.message = @"Login Success";
            returnedResult.userName = response[@"email"];
            returnedResult.userAPIKey = response[@"api_key"];
            returnedResult.firstname = response[@"first_name"];
            returnedResult.lastname = response[@"last_name"];
            returnedResult.country = response[@"country"];
            
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
            returnedResult.message = response[@"message"];
            
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
        returnedResult.message = NETWORK_ERROR_NO_CONNECTIVITY;
        
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
             withCountry: (NSString *) country
                 success: (RegisterNewUserSuccessBlock) success
                 failure: (RegisterNewUserSuccessBlock) failure
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       userName,@"email",
                                       password,@"password",
                                       firstname,@"first_name",
                                       lastname,@"last_name",
                                       country,@"country"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"register"] ] ;
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        RegisterResult *registerResult = [RegisterResult new];
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [response[@"error"] boolValue] == NO )
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
            registerResult.message = response[@"message"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( registerResult );
            });
        }
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        RegisterResult *registerResult = [RegisterResult new];
        
        registerResult.success = NO;
        registerResult.message = NETWORK_ERROR_NO_CONNECTIVITY;
        
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
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       comment,@"feedback_text"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"submit_feedback"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
            {
                success ( );
            }
        });
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) updateAccountInfo: (NSString *) firstname
              withLastname: (NSString *) lastname
               withCountry: (NSString *) country
                   success: (UpdateAccountInfoSuccessBlock) success
                   failure: (UpdateAccountInfoFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       firstname,@"firstname",
                                       lastname,@"lastname",
                                       country,@"country"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"update_account"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
            {
                success ( );
            }
        });
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) updateProfileImage: (UIImage *) profileImage
                    success: (UpdateAccountInfoSuccessBlock) success
                    failure: (UpdateAccountInfoFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:nil path: [WEB_API_FILE stringByAppendingPathComponent:@"update_profile_photo"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.9f);
    
    //used for server temp storage file name. Not important
    NSString *fileNameWithExtension = [NSString stringWithFormat:@"%@.jpg",@"ProfileImage"];
    
    [networkOperation addData:imageData forKey:@"photos" mimeType:@"image/jpeg" fileName:fileNameWithExtension];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                success ( );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) deleteProfileImage: (UpdateAccountInfoSuccessBlock) success
                    failure: (UpdateAccountInfoFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:nil path: [WEB_API_FILE stringByAppendingPathComponent:@"delete_profile_photo"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                success ( );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
            
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) downloadProfileImageFrom: (NSString *)url
                          success: (RetrieveProfileImageSuccessBlock) success
                          failure: (RetrieveProfileImageFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSString *profileImagePath = [Utils getProfileImagePathForUser:self.userDataDAO.userKey];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator downloadFileFrom:url toFile:profileImagePath];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        UIImage *profileImage = [Utils readProfileImageForUser:self.userDataDAO.userKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success)
            {
                success ( profileImage );
            }
            
        });
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
}

- (void) retrieveProfileImage: (RetrieveProfileImageSuccessBlock) success
                      failure: (RetrieveProfileImageFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator getRequestToServer:[WEB_API_FILE stringByAppendingPathComponent:@"get_profile_image"]];
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: nil];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [response[@"error"] boolValue] == NO )
        {
            NSString *imageURL = response[@"url"];
            
            //go download the image
            [self downloadProfileImageFrom:imageURL success:success failure:failure];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure)
                {
                    failure ( response[@"message"] );
                }
            });
        }
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
        
        [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) updateEmailTo: (NSString *)emailToChangeTo
               success: (UpdateAccountInfoSuccessBlock) success
               failure: (UpdateAccountInfoFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       emailToChangeTo,@"new_email"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"change_email"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [response[@"error"] boolValue] == NO )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                success (  );
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ( response[@"message"] );
            });
        }
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) updatePassword: (NSString *)oldPassword
     passwordToChangeTo: (NSString *)passwordToChangeTo
                success: (UpdateAccountInfoSuccessBlock) success
                failure: (UpdateAccountInfoFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       oldPassword,@"old_password",
                                       passwordToChangeTo,@"new_password"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"change_password"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [response[@"error"] boolValue] == NO )
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
                    failure ( USER_PASSWORD_WRONG );
                }
            });
        }
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) killAccount: (NSString *)password
             success: (UpdateAccountInfoSuccessBlock) success
             failure: (UpdateAccountInfoFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       password,@"password"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"kill_account"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( [response[@"error"] boolValue] == NO )
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
                    failure ( response[@"message"] );
                }
            });
        }
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) getSubscriptionExpiryDate: (GetSubscriptionExpiryDateSuccessBlock) success
                           failure: (GetSubscriptionExpiryDateFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator getRequestToServer:[WEB_API_FILE stringByAppendingPathComponent:@"get_expiration_date"]];
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        if ( response[@"error"] && [response[@"error"] boolValue] == NO)
        {
            NSString *expirationDateString = response[@"expiration_date"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success)
                {
                    success ( expirationDateString );
                }
                
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (failure)
                {
                    failure ( NO_EXPIRATION_DATE_EXIST );
                }
                
            });
        }
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

- (void) addNumberOfMonthToUserSubscription: (NSInteger) numberOfMonth
                                    success: (SubscriptionUpdateSuccessBlock) success
                                    failure: (SubscriptionUpdateFailureBlock) failure
{
    if (!self.userDataDAO.userKey)
    {
        NSAssert(NO, @"self.userDataDAO.userKey not set");
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @(numberOfMonth),@"number_of_month"
                                       ,nil];
    
    MKNetworkOperation *networkOperation = [self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"add_new_expiration_date"] ] ;
    
    [networkOperation addHeader:@"Authorization" withValue:self.userDataDAO.userKey];
    
    MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *response = [completedOperation responseJSON];
        
        NSString *expirationDateString = response[@"expiration_date"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success ( expirationDateString );
        });
        
    };
    
    MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)
            {
                failure ( NETWORK_ERROR_NO_CONNECTIVITY );
            }
        });
    };
    
    [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
    
    [self.networkCommunicator enqueueOperation:networkOperation];
}

@end
