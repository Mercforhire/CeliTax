//
// User.m
// CeliTax
//
// Created by Leon Chen on 2015-04-30.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "User.h"

#define kKeyLoginName                   @"loginName"
#define kKeyUserKey                     @"userKey"
#define kKeyFirstname                   @"firstname"
#define kKeyLastname                    @"lastname"
#define kKeyCountry                     @"country"
#define kSubscriptionExpirationDate     @"subscriptionExpirationDate"

@implementation User

- (id) initWithCoder: (NSCoder *) aDecoder
{
    if (self = [super init])
    {
        self.loginName = [aDecoder decodeObjectForKey: kKeyLoginName];
        self.userKey = [aDecoder decodeObjectForKey: kKeyUserKey];
        self.firstname = [aDecoder decodeObjectForKey: kKeyFirstname];
        self.lastname = [aDecoder decodeObjectForKey: kKeyLastname];
        self.country = [aDecoder decodeObjectForKey: kKeyCountry];
        self.subscriptionExpirationDate = [aDecoder decodeObjectForKey: kSubscriptionExpirationDate];
    }

    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeObject: self.loginName forKey: kKeyLoginName];
    [aCoder encodeObject: self.userKey forKey: kKeyUserKey];
    [aCoder encodeObject: self.firstname forKey: kKeyFirstname];
    [aCoder encodeObject: self.lastname forKey: kKeyLastname];
    [aCoder encodeObject: self.country forKey: kKeyCountry];
    [aCoder encodeObject: self.subscriptionExpirationDate forKey: kSubscriptionExpirationDate];
}

@end