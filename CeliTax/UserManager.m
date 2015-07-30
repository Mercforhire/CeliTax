//
//  UserManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserManager.h"
#import "User.h"
#import "Utils.h"

@implementation UserManager
{
    UIImage *defaultAvatarImage;
}

- (instancetype) init
{
    if (self = [super init])
    {
        defaultAvatarImage = [UIImage imageNamed: @"userIcon.png"];
    }
    
    return self;
}

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
    
    //set this as default image
    newUser.avatarImage = defaultAvatarImage;
    
    self.user = newUser;
    
    //TODO: Save user to UserDefaults
    //...
    
    [self.authenticationService retrieveProfileImage:^(UIImage *profileImage) {
        
        self.user.avatarImage = profileImage;
        
    } failure:^(NSString *reason) {
        //ignore failure
    }];
    
}

-(void)changeUserDetails:(NSString *)firstname
             andLastname:(NSString *)lastname
                 andCity:(NSString *)city
           andPostalCode:(NSString *)postalCode
{
    self.user.firstname = firstname;
    self.user.lastname = lastname;
    self.user.city = city;
    self.user.postalCode = postalCode;
    
    //TODO: Save user to UserDefaults
    //...
    
    [self.authenticationService updateAccountInfo:firstname
                                     withLastname:lastname
                                         withCity:city
                                       withPostal:postalCode
                                          success:^{
                                              
        //nothing left to do
                                              
    } failure:^(NSString *reason) {
        //TODO: Remember it failed and try again later
    }];
}

-(BOOL)doesUserHaveCustomProfileImage
{
    return (self.user.avatarImage != defaultAvatarImage);
}

-(void)deleteUsersAvatar
{
    [Utils deleteProfileImageForUser:self.user.userKey];
    
    self.user.avatarImage = defaultAvatarImage;
    
    //TODO: Save user to UserDefaults
    //...
    
    //TODO: Update the server when possible
    //...
}

-(void)setNewAvatarImage: (UIImage *)image
{
    [Utils setProfileImageForUser:self.user.userKey image:image];
    
    self.user.avatarImage = [Utils readProfileImageForUser:self.user.userKey];
    
    //TODO: Save user to UserDefaults
    //...
    
    //TODO: Update the server when possible
    //...
}

-(void)logOutUser
{
    self.user = nil;
    
    //TODO: delete user login from UserDefaults
    //...
}

@end
