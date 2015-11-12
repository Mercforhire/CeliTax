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
    static let USER_ALREADY_EXIST : String = "USER_ALREADY_EXIST"
    static let USER_DOESNT_EXIST : String = "USER_DOESNT_EXIST"
    static let USER_PASSWORD_WRONG : String = "USER_PASSWORD_WRONG"
    static let PROFILE_IMAGE_FILE_DOESNT_EXIST : String = "PROFILE_IMAGE_FILE_DOESNT_EXIST"
    static let USER_CHANGE_EMAIL_ALREADY_EXIST : String = "USER_CHANGE_EMAIL_ALREADY_EXIST"
    static let NO_EXPIRATION_DATE_EXIST : String = "NO_EXPIRATION_DATE_EXIST"
    
    typealias AuthenticateUserSuccessBlock  = (result : AuthorizeResult) -> Void
    typealias AuthenticateUserFailureBlock = (result : AuthorizeResult) -> Void
    
    typealias RegisterNewUserSuccessBlock = (result : RegisterResult) -> Void
    typealias RegisterNewUserFailureBlock = (result : RegisterResult) -> Void
    
    typealias ForgotPasswordSuccessBlock = () -> Void
    typealias ForgotPasswordFailureBlock = (reason : String) -> Void
    
    typealias SendCommentSuccessBlock = () -> Void
    typealias SendCommentFailureBlock = (reason : String) -> Void
    
    typealias UpdateAccountInfoSuccessBlock = () -> Void
    typealias UpdateAccountInfoFailureBlock = (reason : String) -> Void
    
    typealias RetrieveProfileImageSuccessBlock = (image : UIImage) -> Void
    typealias RetrieveProfileImageFailureBlock = (reason : String) -> Void
    
    typealias SubscriptionUpdateSuccessBlock = (expirationDateString : String) -> Void
    typealias SubscriptionUpdateFailureBlock = (reason : String) -> Void
    
    typealias GetSubscriptionExpiryDateSuccessBlock = (expirationDateString : NSString) -> Void
    typealias GetSubscriptionExpiryDateFailureBlock = (reason : String) -> Void
    
    private weak var userDataDAO : UserDataDAO!
    private weak var networkCommunicator : NetworkCommunicator!
    
    override init()
    {
        super.init()
    }
    
    init(userDataDAO : UserDataDAO!, networkCommunicator : NetworkCommunicator!)
    {
        self.userDataDAO = userDataDAO
        self.networkCommunicator = networkCommunicator
    }
    
    func authenticateUser(userName : String!, password : String!, success : AuthenticateUserSuccessBlock?, failure : AuthenticateUserFailureBlock?)
    {
        let postParams: [String:String] = [
            "email" : userName,
            "password" : password
        ]
        
        let urlPath : String = NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/login")
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams as [NSObject : AnyObject], path: urlPath)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let returnedResult : AuthorizeResult = AuthorizeResult()
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                returnedResult.success = true
                returnedResult.message = "Login Success"
                returnedResult.userName = response["email"] as! String
                returnedResult.userAPIKey = response["api_key"] as! String
                returnedResult.firstname = response["first_name"] as! String
                returnedResult.lastname = response["last_name"] as! String
                returnedResult.country = response["country"] as! String
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success != nil)
                    {
                        success! ( result: returnedResult )
                    }
                })
            }
            else
            {
                returnedResult.success = false
                returnedResult.message = response["message"] as! String
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure! ( result: returnedResult )
                    }
                })
            }
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            let returnedResult : AuthorizeResult = AuthorizeResult()
            
            returnedResult.success = false
            returnedResult.message = NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( result: returnedResult )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func registerNewUser(userName : String!, password : String!, firstname : String!, lastname : String!, country : String!, success : RegisterNewUserSuccessBlock?, failure : RegisterNewUserFailureBlock?)
    {
        let postParams: [String:String] = [
            "email" : userName,
            "password" : password,
            "first_name" : firstname,
            "last_name" : lastname,
            "country" : country
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams,path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/register"))
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let registerResult : RegisterResult = RegisterResult()
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                registerResult.success = true
                registerResult.message = "You are successfully registered."
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success != nil)
                    {
                        success! ( result: registerResult )
                    }
                    
                })
            }
            else
            {
                registerResult.success = false
                registerResult.message = response["message"] as! String
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure! ( result: registerResult )
                    }
                    
                })
            }
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            let registerResult : RegisterResult = RegisterResult()
            
            registerResult.success = false
            registerResult.message = NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( result: registerResult );
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func forgotPassword(userName : String!, success : ForgotPasswordSuccessBlock?, failure : ForgotPasswordFailureBlock?)
    {
        let postParams: [String:String] = [
            "email" : userName
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams,path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/forgetpassword"))
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success != nil)
                    {
                        success! ( )
                    }
                    
                })
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure! ( reason: AuthenticationService.USER_DOESNT_EXIST )
                    }
                    
                })
            }
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            let registerResult : RegisterResult = RegisterResult()
            
            registerResult.success = false
            registerResult.message = NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY );
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func sendComment(comment : String!, success : SendCommentSuccessBlock?, failure : SendCommentFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let postParams: [String:String] = [
            "feedback_text" : comment
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/submit_feedback"))
        
        networkOperation.addHeader("Authorization", withValue: self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success != nil)
                {
                    success! ()
                }
                
            })
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func updateAccountInfo(firstname : String!, lastname : String!, country : String!, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set");
        }
        
        let postParams: [String:String] = [
            "firstname" : firstname,
            "lastname" : lastname,
            "country" : country
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/update_account"))
        
        networkOperation.addHeader("Authorization", withValue: self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock  = { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success != nil)
                {
                    success! ( )
                }
            })
            
        }
        
        let failureBlock : MKNKResponseErrorBlock  = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func updateProfileImage(profileImage : UIImage!, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(nil, path: NetworkCommunicator.WEB_API_FILE .stringByAppendingString("/update_profile_photo"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let imageData : NSData = UIImageJPEGRepresentation(profileImage, 0.9)!
        
        //used for server temp storage file name. Not important
        let fileNameWithExtension : String = String(format: "%@.jpg", "ProfileImage")
        
        networkOperation.addData(imageData, forKey: "photos", mimeType: "image/jpeg", fileName: fileNameWithExtension)
        
        let bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            
        }
        
        let successBlock : MKNKResponseBlock  = { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success != nil)
                {
                    success! ( )
                }
                
                })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
                })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func deleteProfileImage (success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(nil, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/delete_profile_photo"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                
        }
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success != nil)
                {
                    success! ( )
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure! ( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    private func downloadProfileImageFrom(url : String!, success : RetrieveProfileImageSuccessBlock?, failure : RetrieveProfileImageFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let profileImagePath : String = Utils.getProfileImagePathForUser(self.userDataDAO.userKey)
        
        let networkOperation: MKNetworkOperation = self.networkCommunicator.downloadFileFrom(url, filePath: profileImagePath)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let profileImage : UIImage! = Utils.readProfileImageForUser(self.userDataDAO.userKey)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success != nil)
                {
                    success!( image: profileImage )
                }
                
            })
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
    }
    
    func retrieveProfileImage(success : RetrieveProfileImageSuccessBlock?, failure : RetrieveProfileImageFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.getRequestToServer(NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/get_profile_image"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let bgTask : UIBackgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            
        })
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                let imageURL : String = response["url"] as! String
                
                //go download the image
                self.downloadProfileImageFrom(imageURL, success:success, failure:failure)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure!( reason: response["message"] as! String )
                    }
                })
            }
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
            
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func updateEmailTo(emailToChangeTo : String!, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let postParams: [String:String] = [
            "new_email" : emailToChangeTo
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/change_email"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success != nil)
                    {
                        success!( )
                    }
                    
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure!( reason: response["message"] as! String )
                    }
                    
                })
            }
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func updatePassword(oldPassword : String!, passwordToChangeTo : String!, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let postParams: [String:String] = [
            "old_password" : oldPassword,
            "new_password" : passwordToChangeTo
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/change_password"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock  = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success != nil)
                    {
                        success!( )
                    }
                    
                })
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (failure != nil)
                    {
                        failure!( reason: AuthenticationService.USER_PASSWORD_WRONG )
                    }
                })
            }
            
        }
        
        let failureBlock : MKNKResponseErrorBlock  = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func killAccount(password : String!, success : UpdateAccountInfoSuccessBlock?, failure : UpdateAccountInfoFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set");
        }
        
        let postParams: [String:String] = [
            "password" : password
        ]

        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/kill_account"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (success != nil)
                    {
                        success!( )
                    }
                })
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure!( reason : (response["message"] as! String) )
                    }
                })
            }
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation,error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!(reason:  NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func getSubscriptionExpiryDate(success : GetSubscriptionExpiryDateSuccessBlock?, failure : GetSubscriptionExpiryDateFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.getRequestToServer(NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/get_expiration_date"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            if ( response["error"]!.boolValue == false )
            {
                let expirationDateString : String = response["expiration_date"] as! String
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if ( success != nil )
                    {
                        success!( expirationDateString: expirationDateString )
                    }
                    
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if (failure != nil)
                    {
                        failure!( reason: AuthenticationService.NO_EXPIRATION_DATE_EXIST )
                    }
                    
                })
            }
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
                
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
    
    func addNumberOfMonthToUserSubscription (numberOfMonth : Int, success : SubscriptionUpdateSuccessBlock?, failure : SubscriptionUpdateFailureBlock?)
    {
        if (self.userDataDAO.userKey == nil)
        {
            assert(false, "self.userDataDAO.userKey not set")
        }
        
        let postParams: [String : AnyObject] = [
            "number_of_month" : numberOfMonth
        ]
        
        let networkOperation : MKNetworkOperation = self.networkCommunicator.postDataToServer(postParams, path: NetworkCommunicator.WEB_API_FILE.stringByAppendingString("/add_new_expiration_date"))
        
        networkOperation.addHeader("Authorization", withValue:self.userDataDAO.userKey)
        
        let successBlock : MKNKResponseBlock = { (completedOperation) in
            
            let response : NSDictionary = completedOperation.responseJSON() as! NSDictionary
            
            let expirationDateString : String = response["expiration_date"] as! String
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (success != nil)
                {
                    success!( expirationDateString: expirationDateString )
                }
                
            })
            
        }
        
        let failureBlock : MKNKResponseErrorBlock = { (completedOperation, error) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (failure != nil)
                {
                    failure!( reason: NetworkCommunicator.NETWORK_ERROR_NO_CONNECTIVITY )
                }
            })
        }
        
        networkOperation.addCompletionHandler(successBlock, errorHandler: failureBlock)
        
        self.networkCommunicator.enqueueOperation(networkOperation)
    }
}
