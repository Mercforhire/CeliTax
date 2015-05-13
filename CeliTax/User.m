//
//  User.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithCoder: (NSCoder *) aDecoder
{
    if (self = [super init])
    {
        self.loginName = [aDecoder decodeObjectForKey: @"loginName"];
        self.userKey = [aDecoder decodeObjectForKey: @"userKey"];
        self.firstname = [aDecoder decodeObjectForKey: @"firstname"];
        self.lastname = [aDecoder decodeObjectForKey: @"lastname"];
        self.postalCode = [aDecoder decodeObjectForKey: @"postalCode"];
        self.country = [aDecoder decodeObjectForKey: @"country"];
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeObject: self.loginName forKey: @"loginName"];
    [aCoder encodeObject: self.userKey forKey: @"userKey"];
    [aCoder encodeObject: self.firstname forKey: @"firstname"];
    [aCoder encodeObject: self.lastname forKey: @"lastname"];
    [aCoder encodeObject: self.postalCode forKey: @"postalCode"];
    [aCoder encodeObject: self.country forKey: @"country"];
}

@end
