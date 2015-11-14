//
//  UserManager.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-13.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation


@objc
class UserManager : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kDoNotShowDisclaimerAgainKey : String = "DoNotShowDisclaimerAgain"
    
    var user : User?
    
    //This variable determines if the app should be restricted or not.
    var subscriptionActive : Bool = false
    
    //This variable determines whether to show the disclaimer message upon login
    var doNotShowDisclaimer : Bool = false
    
    let defaultAvatarImage : UIImage! = UIImage.init(named: "userIcon.png")
    
    weak var authenticationService : AuthenticationService?
    weak var configManager : ConfigurationManager?
    weak var userDataDAO : UserDataDAO?
    weak var backgroundWorker : BackgroundWorker?
    weak var subscriptionManager : SubscriptionManager?
    
    typealias UpdateUserSubscriptionExpiryDateSuccessBlock = () -> Void
    typealias UpdateUserSubscriptionExpiryDateFailureBlock = (reason : String) -> Void
 
    override init()
    {
        super.init()
        
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(kDoNotShowDisclaimerAgainKey) != nil)
        {
            self.doNotShowDisclaimer = true
        }
    }
    
    //check to see if self.subscriptionExpirationDate is today or after today. If yes, mark subscriptionActive to be TRUE
    func checkAccountSubscriptionActivity()
    {
        let expirationDate : NSDate! = Utils.dateFromDateString(self.user!.subscriptionExpirationDate)
        
        let timeInt : NSTimeInterval = expirationDate.timeIntervalSinceDate(NSDate.init())
        
        let days : Int = Int(timeInt / 60 / 60 / 24)
        
        if (days >= 0)
        {
            self.subscriptionActive = true
            
            dLog("Subscription active")
        }
        else
        {
            dLog("Subscription expired")
        }
    }
    
    func attemptToLoginSavedUser() -> Bool
    {
        self.user = Utils.loadSavedUser()
        
        if (self.user != nil)
        {
            let avatar : UIImage? = Utils.readProfileImageForUser(self.user!.userKey)
            
            if (avatar != nil)
            {
                self.user!.avatarImage = avatar
            }
            else
            {
                self.user!.avatarImage = defaultAvatarImage
            }
            
            //IMPORTANT: set the userKey to userDataDAO
            self.userDataDAO!.userKey = self.user!.userKey
            
            self.backgroundWorker!.activeWorker()
            
            self.configManager!.loadSettingsFromPersistence()
            
            // check for user subscription
            if (self.user!.subscriptionExpirationDate.characters.count > 0)
            {
                self.checkAccountSubscriptionActivity()
            }
            
            return true
        }
    
        return false
    }
    
    func loginUserFor(loginName : String!, key : String!, firstname : String!, lastname : String!, country : String!)
    {
        let newUser : User = User()
        
        newUser.loginName = loginName
        newUser.userKey = key
        newUser.firstname = firstname
        newUser.lastname = lastname
        newUser.country = country
        
        //IMPORTANT: set the userKey to userDataDAO
        self.userDataDAO!.userKey = newUser.userKey
        
        //set this as default image
        newUser.avatarImage = defaultAvatarImage
        
        self.user = newUser
        
        if (!Utils.saveUser(self.user))
        {
            dLog("ERROR: Did not save User")
        }
        
        self.backgroundWorker!.activeWorker()
        self.configManager!.loadSettingsFromPersistence()
    
        self.authenticationService!.retrieveProfileImage({ (profileImage) in

            self.user!.avatarImage = profileImage;
            
            }, failure: { (reason) in
                //ignore failure
        })
    }
    
    func updateUserSubscriptionExpiryDate(success : UpdateUserSubscriptionExpiryDateSuccessBlock?, failure : UpdateUserSubscriptionExpiryDateFailureBlock?)
    {
        self.authenticationService!.getSubscriptionExpiryDate({ (expiryDateString) in
            
            self.setExpiryDate(expiryDateString)
            
            self.checkAccountSubscriptionActivity()
            
            if (success != nil)
            {
                success!()
            }
            
            }, failure: { (reason) in
                
                // ignore failure, can only happen when internet is down.
                // there should always be an expiry date for any account
                
                if (failure != nil)
                {
                    failure! ( reason: reason )
                }
        })
    }
    
    func changeUserDetails(firstname : String!, lastname : String!, country : String!)
    {
        self.user!.firstname = firstname
        self.user!.lastname = lastname
        self.user!.country = country
        
        if (!Utils.saveUser(self.user))
        {
            dLog("ERROR: Did not save User")
        }
        
        
        self.authenticationService!.updateAccountInfo(firstname, lastname:lastname, country:country, success: {
            //nothing left to do
            }, failure: { (reason) in
                
                self.backgroundWorker!.addTaskToQueue(QueueTaskType.UploadProfileData)
                
        })
    }
    
    func changeEmail(emailToChangeTo : String!)
    {
        self.user!.loginName = emailToChangeTo
        
        if (!Utils.saveUser(self.user))
        {
            dLog("ERROR: Did not save User")
        }
    }
    
    func doesUserHaveCustomProfileImage() -> Bool
    {
        return (self.user!.avatarImage != self.defaultAvatarImage)
    }
    
    func deleteUsersAvatar()
    {
        Utils.deleteProfileImageForUser(self.user!.userKey)
        
        self.user!.avatarImage = self.defaultAvatarImage
        
        self.backgroundWorker!.addTaskToQueue(QueueTaskType.UpdateProfileImage)
    }
    
    func setNewAvatarImage(image : UIImage)
    {
        Utils.setProfileImageForUser(self.user!.userKey, image:image)
        
        self.user!.avatarImage = Utils.readProfileImageForUser(self.user!.userKey)
        
        self.backgroundWorker!.addTaskToQueue(QueueTaskType.UpdateProfileImage)
    }
    
    func deleteAllLocalUserData()
    {
        // Delete user profile image
        Utils.deleteProfileImageForUser(self.user!.userKey)
        
        // Delete user receipt images
        Utils.deleteAllPhotosforUser(self.user!.userKey)
        
        // Delete user local data
        self.userDataDAO!.deleteUserData()
    }
    
    func logOutUser()
    {
        self.user = nil
        
        self.userDataDAO!.userKey = nil;
        
        self.subscriptionActive = false
        
        if (!Utils.deleteSavedUser())
        {
            dLog("ERROR: Did not delete saved User")
        }
        
        self.backgroundWorker!.deactiveWorker()
    }
    
    func setExpiryDate(expiryDateString : String!)
    {
        self.user!.subscriptionExpirationDate = expiryDateString
        
        Utils.saveUser(self.user)
    }
    
    func doNotShowDisclaimerAgain()
    {
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(true, forKey:kDoNotShowDisclaimerAgainKey)
        
        defaults.synchronize()
        
        self.doNotShowDisclaimer = true
    }
}