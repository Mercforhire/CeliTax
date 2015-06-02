//
// User.m
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "User.h"

#define kKeyLoginName           @"loginName"
#define kKeyUserKey             @"userKey"
#define kKeyFirstname           @"firstname"
#define kKeyLastname            @"lastname"
#define kKeyCity                @"city"
#define kKeyPostalCode          @"postalCode"
#define kKeyCountry             @"country"
#define kKeyAvatarImage         @"avatarImage"

@implementation User

- (id) initWithCoder: (NSCoder *) aDecoder
{
    if (self = [super init])
    {
        self.loginName = [aDecoder decodeObjectForKey: kKeyLoginName];
        self.userKey = [aDecoder decodeObjectForKey: kKeyUserKey];
        self.firstname = [aDecoder decodeObjectForKey: kKeyFirstname];
        self.lastname = [aDecoder decodeObjectForKey: kKeyLastname];
        self.city = [aDecoder decodeObjectForKey: kKeyCity];
        self.postalCode = [aDecoder decodeObjectForKey: kKeyPostalCode];
        self.country = [aDecoder decodeObjectForKey: kKeyCountry];
        self.avatarImage = [UIImage imageWithData: [aDecoder decodeObjectForKey: kKeyAvatarImage]];
    }

    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeObject: self.loginName forKey: kKeyLoginName];
    [aCoder encodeObject: self.userKey forKey: kKeyUserKey];
    [aCoder encodeObject: self.firstname forKey: kKeyFirstname];
    [aCoder encodeObject: self.lastname forKey: kKeyLastname];
    [aCoder encodeObject: self.city forKey: kKeyCity];
    [aCoder encodeObject: self.postalCode forKey: kKeyPostalCode];
    [aCoder encodeObject: self.country forKey: kKeyCountry];
    [aCoder encodeObject: UIImagePNGRepresentation(self.avatarImage) forKey: kKeyAvatarImage];
}

@end