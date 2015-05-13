//
//  UserManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface UserManager : NSObject

@property (nonatomic, strong) User *user;

-(void)loginUserFor:(NSString *)loginName
             andKey:(NSString *)key
       andFirstname:(NSString *)firstname
        andLastname:(NSString *)lastname
      andPostalCode:(NSString *)postalCode
         andCountry:(NSString *)country;

-(void)logOutUser;

@end
