//
//  User.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-30.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class User : NSObject, NSCoding //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    var loginName : String = ""
    var userKey : String = ""
    var firstname : String = ""
    var lastname : String = ""
    var country : String = ""
    var avatarImage : UIImage?
    var subscriptionExpirationDate : String = ""
    
    private let kKeyLoginName : String = "loginName"
    private let kKeyUserKey : String = "userKey"
    private let kKeyFirstname : String = "firstname"
    private let kKeyLastname : String = "lastname"
    private let kKeyCountry : String = "country"
    private let kSubscriptionExpirationDate : String = "subscriptionExpirationDate"
    
    required override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        self.loginName = decoder.decodeObjectForKey(kKeyLoginName) as! String
        self.userKey = decoder.decodeObjectForKey(kKeyUserKey) as! String
        self.firstname = decoder.decodeObjectForKey(kKeyFirstname) as! String
        self.lastname = decoder.decodeObjectForKey(kKeyLastname) as! String
        self.country = decoder.decodeObjectForKey(kKeyCountry) as! String
        self.subscriptionExpirationDate = decoder.decodeObjectForKey(kSubscriptionExpirationDate) as! String
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.loginName, forKey: kKeyLoginName)
        coder.encodeObject(self.userKey, forKey: kKeyUserKey)
        coder.encodeObject(self.firstname, forKey: kKeyFirstname)
        coder.encodeObject(self.lastname, forKey: kKeyLastname)
        coder.encodeObject(self.country, forKey: kKeyCountry)
        coder.encodeObject(self.subscriptionExpirationDate, forKey: kSubscriptionExpirationDate)
    }
}