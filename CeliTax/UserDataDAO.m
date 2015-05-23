//
//  UserDataDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UserDataDAO.h"
#import "Utils.h"
#import "UserData.h"

@interface UserDataDAO ()

@property (nonatomic, strong) UserData *userData;

@end

@implementation UserDataDAO

-(void)setUserKey:(NSString *)userKey
{
    _userKey = userKey;
    
    [self loadUserData];
}

-(NSMutableArray *)getCatagories
{
    return self.userData.catagories;
}

-(NSMutableArray *)getRecords
{
    return self.userData.records;
}

-(NSMutableArray *)getReceipts
{
    return self.userData.receipts;
}

-(NSString *)generateUserDataFileName
{
    if ( !self.userKey )
    {
        return nil;
    }
    
    NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePath = [storagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/USER_DATA-%@.dat", self.userKey]];
    
    return filePath;
}

-(BOOL)loadUserData
{
    if ( !self.userKey )
    {
        return NO;
    }
    
    if (self.userData)
    {
        return YES;
    }
    else
    {
        self.userData = [Utils unarchiveFile:[self generateUserDataFileName]];
        
        if (self.userData)
        {
            return YES;
        }
        else
        {
            self.userData = [UserData new];
            
            return [self saveUserData];
        }
    }
    
    return NO;
}

-(BOOL)saveUserData
{
    if ( !self.userKey || !self.userData )
    {
        return NO;
    }
    
    if ( [Utils archiveFile:self.userData toFile:[self generateUserDataFileName]] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
