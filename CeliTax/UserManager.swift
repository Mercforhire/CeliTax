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
    private let kLastLoggedInUserEmail : String = "LastLoggedInUserEmail"
    
    var user : User?
    
    //This variable determines whether to show the disclaimer message upon login
    var doNotShowDisclaimer : Bool = false
    
    let defaultAvatarImage : UIImage! = UIImage.init(named: "userIcon.png")
    
    weak var authenticationService : AuthenticationService?
    weak var configManager : ConfigurationManager?
    weak var userDataDAO : UserDataDAO?
    weak var backgroundWorker : BackgroundWorker?
    
    private let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
 
    override init()
    {
        super.init()
        
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(kDoNotShowDisclaimerAgainKey) != nil)
        {
            self.doNotShowDisclaimer = true
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
            
            self.rememberLastLoggedInUser(self.user!.loginName)
            
            self.backgroundWorker!.activeWorker()
            
            self.configManager!.loadSettingsFromPersistence()
            
            return true
        }
    
        return false
    }
    
    func rememberLastLoggedInUser(loginName : String)
    {
        self.defaults.setObject(loginName, forKey: kLastLoggedInUserEmail)
        self.defaults.synchronize()
    }
    
    func getLastLoggedInUser() -> NSString?
    {
        return self.defaults.objectForKey(kLastLoggedInUserEmail) as? NSString
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
        
        self.rememberLastLoggedInUser(loginName)
        
        self.backgroundWorker!.activeWorker()
        self.configManager!.loadSettingsFromPersistence()
    
        self.authenticationService!.retrieveProfileImage({ (profileImage) in

            self.user!.avatarImage = profileImage
            
            }, failure: { (reason) in
                //ignore failure
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
        
        self.userDataDAO!.userKey = nil
        
        if (!Utils.deleteSavedUser())
        {
            dLog("ERROR: Did not delete saved User")
        }
        
        self.backgroundWorker!.deactiveWorker()
    }
    
    func doNotShowDisclaimerAgain()
    {
        let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setObject(true, forKey:kDoNotShowDisclaimerAgainKey)
        
        defaults.synchronize()
        
        self.doNotShowDisclaimer = true
    }
}