//
//  AuthenticationService.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class AuthenticationService : NSObject
{
    let USER_ALREADY_EXIST : String = "USER_ALREADY_EXIST"
    let USER_DOESNT_EXIST : String = "USER_DOESNT_EXIST"
    let USER_PASSWORD_WRONG : String = "USER_PASSWORD_WRONG"
    let PROFILE_IMAGE_FILE_DOESNT_EXIST : String = "PROFILE_IMAGE_FILE_DOESNT_EXIST"
    let USER_CHANGE_EMAIL_ALREADY_EXIST : String = "USER_CHANGE_EMAIL_ALREADY_EXIST"
    let NO_EXPIRATION_DATE_EXIST : String = "NO_EXPIRATION_DATE_EXIST"
    
    typealias AuthenticateUserSuccessBlock  = (AuthorizeResult) -> Void
    typealias AuthenticateUserFailureBlock = (AuthorizeResult) -> Void
    
    typealias RegisterNewUserSuccessBlock = (RegisterResult) -> Void
    typealias RegisterNewUserFailureBlock = (RegisterResult) -> Void
    
    typealias SendCommentSuccessBlock = () -> Void
    typealias SendCommentFailureBlock = (NSString) -> Void
    
    typealias UpdateAccountInfoSuccessBlock = () -> Void
    typealias UpdateAccountInfoFailureBlock = (NSString) -> Void
    
    typealias RetrieveProfileImageSuccessBlock = (UIImage) -> Void
    typealias RetrieveProfileImageFailureBlock = (NSString) -> Void
    
    typealias SubscriptionUpdateSuccessBlock = (NSString) -> Void
    typealias SubscriptionUpdateFailureBlock = (NSString) -> Void
    
    typealias GetSubscriptionExpiryDateSuccessBlock = (NSString) -> Void
    typealias GetSubscriptionExpiryDateFailureBlock = (NSString) -> Void
    
    weak var userDataDAO : UserDataDAO!
    weak var networkCommunicator : NetworkCommunicator!
    
    init(userDataDAO : UserDataDAO, networkCommunicator : NetworkCommunicator)
    {
        self.userDataDAO = userDataDAO
        self.networkCommunicator = networkCommunicator
    }
    
    func authenticateUser(userName : String, password : String, success : AuthenticateUserSuccessBlock?, failure : AuthenticateUserFailureBlock?)
    {
        var postParams : NSDictionary = NSDictionary.init(objects: [userName, password], forKeys: ["email","password"]) 
        
//        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: WEB_)
//        self.networkCommunicator postDataToServer:postParams path: [WEB_API_FILE stringByAppendingPathComponent:@"login"] ] ;
        
//        MKNKResponseBlock successBlock = ^(MKNetworkOperation *completedOperation) {
//            
//            AuthorizeResult *returnedResult = [AuthorizeResult new];
//            
//            NSDictionary *response = [completedOperation responseJSON];
//            
//            if ( [response[@"error"] boolValue] == NO )
//            {
//                returnedResult.success = YES;
//                returnedResult.message = @"Login Success";
//                returnedResult.userName = response[@"email"];
//                returnedResult.userAPIKey = response[@"api_key"];
//                returnedResult.firstname = response[@"first_name"];
//                returnedResult.lastname = response[@"last_name"];
//                returnedResult.country = response[@"country"];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (success)
//                    {
//                        success ( returnedResult );
//                    }
//                    });
//            }
//            else
//            {
//                returnedResult.success = NO;
//                returnedResult.message = response[@"message"];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (failure)
//                    {
//                        failure ( returnedResult );
//                    }
//                    });
//            }
//        };
//        
//        MKNKResponseErrorBlock failureBlock = ^(MKNetworkOperation *completedOperation, NSError *error) {
//            AuthorizeResult *returnedResult = [AuthorizeResult new];
//            
//            returnedResult.success = NO;
//            returnedResult.message = NETWORK_ERROR_NO_CONNECTIVITY;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (failure)
//                {
//                    failure ( returnedResult );
//                }
//                });
//        };
//        
//        [networkOperation addCompletionHandler: successBlock errorHandler: failureBlock];
//        
//        [self.networkCommunicator enqueueOperation:networkOperation];
    }
    
    func registerNewUser(userName : String, password : String, firstname : String, country : String, success : RegisterNewUserSuccessBlock?, failure : RegisterNewUserFailureBlock?)
    {
        
    }
    
    func sendComment(comment : NSString, success : SendCommentSuccessBlock?, failure : SendCommentFailureBlock?)
    {
        
    }
    
    func updateAccountInfo(firstname : NSString, lastname : String, country : String, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        
    }
    
    func updateProfileImage(profileImage : UIImage, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        
    }
    
    func deleteProfileImage (success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        
    }
    
    func retrieveProfileImage(success : RetrieveProfileImageSuccessBlock?, failure : RetrieveProfileImageFailureBlock?)
    {
        
    }
    
    func updateEmailTo(emailToChangeTo : NSString, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        
    }
    
    func updatePassword(oldPassword : NSString, passwordToChangeTo : NSString, success : UpdateAccountInfoSuccessBlock, failure : UpdateAccountInfoFailureBlock)
    {
        
    }
    
    func killAccount(password : NSString, success : UpdateAccountInfoSuccessBlock, failure : UpdateAccountInfoFailureBlock)
    {
        
    }
    
    func getSubscriptionExpiryDate(success : GetSubscriptionExpiryDateSuccessBlock, failure : GetSubscriptionExpiryDateFailureBlock)
    {
        
    }
    
    func addNumberOfMonthToUserSubscription (numberOfMonth : Int, success : SubscriptionUpdateSuccessBlock, failure : SubscriptionUpdateFailureBlock)
    {
        
    }
}