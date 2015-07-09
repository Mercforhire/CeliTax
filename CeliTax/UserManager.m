//
//  UserManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserManager.h"
#import "User.h"

@implementation UserManager

-(void)loginUserFor:(NSString *)loginName
             andKey:(NSString *)key
       andFirstname:(NSString *)firstname
        andLastname:(NSString *)lastname
            andCity:(NSString *)city
      andPostalCode:(NSString *)postalCode
         andCountry:(NSString *)country
{
    User *newUser = [[User alloc] init];
    newUser.loginName = loginName;
    newUser.userKey = key;
    newUser.firstname = firstname;
    newUser.lastname = lastname;
    newUser.city = city;
    newUser.postalCode = postalCode;
    newUser.country = country;
    
    self.user = newUser;
    
    //save user
}

-(void)logOutUser
{
    self.user = nil;
}

@end
