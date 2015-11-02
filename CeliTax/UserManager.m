//
//  UserManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-04-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserManager.h"
#import "Utils.h"
#import "UserDataDAO.h"
#import "ConfigurationManager.h"
#import "BackgroundWorker.h"
#import "SubscriptionManager.h"

#import "CeliTax-Swift.h"

#define kDoNotShowDisclaimerAgainKey               @"DoNotShowDisclaimerAgain"

@interface UserManager ()

@end

@implementation UserManager
{
    UIImage *defaultAvatarImage;
}

- (instancetype) init
{
    if (self = [super init])
    {
        defaultAvatarImage = [UIImage imageNamed: @"userIcon.png"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:kDoNotShowDisclaimerAgainKey])
        {
            _doNotShowDisclaimer = YES;
        }
    }
    
    return self;
}

//check to see if self.subscriptionExpirationDate is today or after today. If yes, mark subscriptionActive to be TRUE
-(void)checkAccountSubscriptionActivity
{
    if (!self.user.subscriptionExpirationDate)
    {
        return;
    }
    
    NSDate *expirationDate = [Utils dateFromDateString:self.user.subscriptionExpirationDate];
    
    NSTimeInterval timeInt = [expirationDate timeIntervalSinceDate:[NSDate date]];
    
    NSInteger days = timeInt / 60 / 60 / 24;
    
    if (days >= 0)
    {
        self.subscriptionActive = YES;
        
        DLog(@"Subscription active");
    }
    else
    {
        DLog(@"Subscription expired");
    }
}

-(BOOL)attemptToLoginSavedUser
{
    self.user = [Utils loadSavedUser];
    
    if (self.user)
    {
        UIImage *avatar = [Utils readProfileImageForUser:self.user.userKey];
        
        if (avatar)
        {
            self.user.avatarImage = avatar;
        }
        else
        {
            self.user.avatarImage = defaultAvatarImage;
        }
        
        //IMPORTANT: set the userKey to userDataDAO
        self.userDataDAO.userKey = self.user.userKey;
        
        [self.backgroundWorker activeWorker];
        
        [self.configManager loadSettingsFromPersistence];

        // check for user subscription
        if (self.user.subscriptionExpirationDate)
        {
            [self checkAccountSubscriptionActivity];
        }
    }
    
    return (self.user != nil);
}

-(void)loginUserFor:(NSString *)loginName
             andKey:(NSString *)key
       andFirstname:(NSString *)firstname
        andLastname:(NSString *)lastname
         andCountry:(NSString *)country
{
    User *newUser = [[User alloc] init];
    
    newUser.loginName = loginName;
    newUser.userKey = key;
    newUser.firstname = firstname;
    newUser.lastname = lastname;
    newUser.country = country;
    
    //IMPORTANT: set the userKey to userDataDAO
    self.userDataDAO.userKey = newUser.userKey;
    
    //set this as default image
    newUser.avatarImage = defaultAvatarImage;
    
    self.user = newUser;
    
    if (![Utils saveUser:self.user])
    {
        DLog(@"ERROR: Did not save User");
    }
    
    [self.backgroundWorker activeWorker];
    
    [self.configManager loadSettingsFromPersistence];
    
    [self.authenticationService retrieveProfileImage:^(UIImage *profileImage) {
        
        self.user.avatarImage = profileImage;
        
    } failure:^(NSString *reason) {
        //ignore failure
    }];
}

-(void)updateUserSubscriptionExpiryDate: (UpdateUserSubscriptionExpiryDateSuccessBlock) success
                                failure: (UpdateUserSubscriptionExpiryDateFailureBlock) failure;
{
    [self.authenticationService getSubscriptionExpiryDate:^(NSString *expiryDateString) {
        
        [self setExpiryDate:expiryDateString];
        
        [self checkAccountSubscriptionActivity];
        
        if (success)
        {
            success ();
        }
        
    } failure:^(NSString *reason) {
        
        // ignore failure, can only happen when internet is down.
        // there should always be an expiry date for any account
        
        if (failure)
        {
            failure ( reason );
        }
        
    }];
}

-(void)changeUserDetails:(NSString *)firstname
             andLastname:(NSString *)lastname
              andCountry:(NSString *)country
{
    self.user.firstname = firstname;
    self.user.lastname = lastname;
    self.user.country = country;
    
    if (![Utils saveUser:self.user])
    {
        DLog(@"ERROR: Did not save User");
    }
    
    
    [self.authenticationService updateAccountInfo:firstname
                                     withLastname:lastname
                                      withCountry:country
                                          success:^{
                                              
        //nothing left to do
                                              
    } failure:^(NSString *reason) {
        
        [self.backgroundWorker addTaskToQueue:QueueTaskUploadProfileData];
        
    }];
}

-(void)changeEmail:(NSString *)emailToChangeTo
{
    self.user.loginName = emailToChangeTo;
    
    if (![Utils saveUser:self.user])
    {
        DLog(@"ERROR: Did not save User");
    }
}

-(BOOL)doesUserHaveCustomProfileImage
{
    return (self.user.avatarImage != defaultAvatarImage);
}

-(void)deleteUsersAvatar
{
    [Utils deleteProfileImageForUser:self.user.userKey];
    
    self.user.avatarImage = defaultAvatarImage;
    
    [self.backgroundWorker addTaskToQueue:QueueTaskUpdateProfileImage];
}

-(void)setNewAvatarImage: (UIImage *)image
{
    [Utils setProfileImageForUser:self.user.userKey image:image];
    
    self.user.avatarImage = [Utils readProfileImageForUser:self.user.userKey];
    
    [self.backgroundWorker addTaskToQueue:QueueTaskUpdateProfileImage];
}

-(void)deleteAllLocalUserData
{
    // Delete user profile image
    [Utils deleteProfileImageForUser:self.user.userKey];
    
    // Delete user receipt images
    [Utils deleteAllPhotosforUser:self.user.userKey];
    
    // Delete user local data
    [self.userDataDAO deleteUserData];
}

-(void)logOutUser
{
    self.user = nil;
    
    self.userDataDAO.userKey = nil;
    
    self.subscriptionActive = NO;
    
    if (![Utils deleteSavedUser])
    {
        DLog(@"ERROR: Did not delete saved User");
    }
    
    [self.backgroundWorker deactiveWorker];
}

-(void)setExpiryDate: (NSString *)expiryDateString
{
    self.user.subscriptionExpirationDate = expiryDateString;
    
    [Utils saveUser:self.user];
}

-(void)doNotShowDisclaimerAgain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@YES forKey:kDoNotShowDisclaimerAgainKey];
    
    [defaults synchronize];
    
    self.doNotShowDisclaimer = YES;
}

@end
