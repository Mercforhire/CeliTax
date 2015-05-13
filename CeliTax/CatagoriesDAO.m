//
//  CatagoriesDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesDAO.h"
#import "UserData.h"
#import "ItemCatagory.h"
#import "CatagoryRecord.h"
#import "Utils.h"
#import "Receipt.h"

@interface CatagoriesDAO ()

@property (nonatomic, strong) UserData *userData;

@end

@implementation CatagoriesDAO

-(NSString *)generateUserDataFileNameForUser:(NSString *)userKey
{
    if ( !userKey )
    {
        return nil;
    }
    
    NSString *storagePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePath = [storagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/USER_DATA-%@.dat", userKey]];
    
    return filePath;
}

-(UserData *)loadUserDataForUser:(NSString *)userKey
{
    if ( !userKey )
    {
        return nil;
    }
    
    UserData *readData = [Utils unarchiveFile:[self generateUserDataFileNameForUser:userKey]];
    
    return readData;
}

-(BOOL)saveUserDataForUser:(NSString *)userKey andUserData:(UserData *)dataToSave
{
    if ( !userKey || !dataToSave )
    {
        return NO;
    }
    
    if ( [Utils archiveFile:dataToSave toFile:[self generateUserDataFileNameForUser:userKey]] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSArray *)loadCatagoriesForUser:(NSString *)userKey
{
    if ( !userKey )
    {
        return nil;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        return userData.itemCatagories;
    }
    
    return nil;
}

-(ItemCatagory *)loadCatagoryForUser:(NSString *)userKey withCatagoryID:(NSInteger)catagoryID
{
    if ( !userKey  )
    {
        return nil;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)catagoryID];
        NSArray *catagory = [userData.itemCatagories filteredArrayUsingPredicate: findCatagories];
        
        return [catagory firstObject];
    }
    
    return nil;
}

-(BOOL)addCatagoryForUser:(NSString *)userKey forName:(NSString *)name andColor:(UIColor *)color
{
    if ( !userKey || !name || !color )
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        ItemCatagory *catagoryToAdd = [ItemCatagory new];
        
        catagoryToAdd.identifer = userData.itemCatagories.count;
        catagoryToAdd.name = name;
        catagoryToAdd.color = color;
        
        [userData.itemCatagories addObject:catagoryToAdd];
    }
    else
    {
        userData = [UserData new];
        
        ItemCatagory *catagoryToAdd = [ItemCatagory new];
        
        catagoryToAdd.identifer = 0;
        catagoryToAdd.name = name;
        catagoryToAdd.color = color;
        
        [userData.itemCatagories addObject:catagoryToAdd];
    }
    
    return [self saveUserDataForUser:userKey andUserData:userData];
    
    return NO;
}

-(BOOL)addCatagoryForUser:(NSString *)userKey withCatagory:(ItemCatagory *)catagory
{
    if ( !userKey || !catagory )
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (!userData)
    {
        userData = [UserData new];
    }
    
    [userData.itemCatagories addObject:catagory];
    
    return [self saveUserDataForUser:userKey andUserData:userData];
    
    return NO;
}

-(BOOL)modifyCatagoryForUser:(NSString *)userKey forCatagory:(NSInteger)catagoryID forName:(NSString *)name andColor:(UIColor *)color
{
    if ( !userKey  )
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)catagoryID];
        NSArray *catagory = [userData.itemCatagories filteredArrayUsingPredicate: findCatagories];
        
        if (catagory && catagory.count)
        {
            ItemCatagory *catagoryToModify = [catagory firstObject];
            
            catagoryToModify.name = name;
            catagoryToModify.color = color;
            
            return [self saveUserDataForUser:userKey andUserData:userData];
        }
        else
        {
            return NO;
        }
    }
    
    return NO;
}

-(BOOL)deleteCatagoryForUser:(NSString *)userKey forCatagory:(NSInteger)catagoryID
{
    if (!userKey)
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        //delete the existing catagory with same ID as catagory's ID
        NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)catagoryID];
        NSArray *catagoryToDelete = [userData.itemCatagories filteredArrayUsingPredicate: findCatagories];
        
        [userData.itemCatagories removeObjectsInArray:catagoryToDelete];
        
        //delete any catagory records belonging to the catagoryID
        NSPredicate *findCatagoryRecords = [NSPredicate predicateWithFormat: @"itemCatagoryID == %ld", (long)catagoryID];
        NSArray *catagoryRecordsToDelete = [userData.catagoryRecords filteredArrayUsingPredicate: findCatagoryRecords];
        
        [userData.catagoryRecords removeObjectsInArray:catagoryRecordsToDelete];
        
        return [self saveUserDataForUser:userKey andUserData:userData];
    }
    
    return NO;
}

-(NSArray *)loadCatagoryRecordsForUser:(NSString *)userKey
{
    if (!userKey)
    {
        return nil;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData && userData.catagoryRecords && userData.catagoryRecords.count)
    {
        return userData.catagoryRecords;
    }
    
    return nil;
}

-(NSArray *)loadCatagoryRecordsForUser:(NSString *)userKey forCatagory:(NSInteger)catagoryID
{
    if (!userKey)
    {
        return nil;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSPredicate *findCatagoryRecords = [NSPredicate predicateWithFormat: @"itemCatagoryID == %ld", (long)catagoryID];
        NSArray *catagoryRecords = [userData.catagoryRecords filteredArrayUsingPredicate: findCatagoryRecords];
        
        return catagoryRecords;
    }
    else
    {
        return nil;
    }
}

-(NSArray *)loadCatagoryRecordsForUser:(NSString *)userKey forReceipt:(NSInteger)receiptID
{
    if (!userKey)
    {
        return nil;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSPredicate *findCatagoryRecords = [NSPredicate predicateWithFormat: @"receiptID == %ld", (long)receiptID];
        NSArray *catagoryRecords = [userData.catagoryRecords filteredArrayUsingPredicate: findCatagoryRecords];
        
        return catagoryRecords;
    }
    else
    {
        return nil;
    }
}

-(BOOL)addCatagoryRecordForUser: (NSString *) userKey
                  forCatagoryID: (NSInteger) catagoryID
                   forReceiptID: (NSInteger) receiptID
                    forQuantity: (NSInteger) quantity
                      forAmount: (NSInteger) amount
{
    if (!userKey)
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    ItemCatagory *catagory = [self loadCatagoryForUser:userKey withCatagoryID:catagoryID];
    
    if (userData && catagory)
    {
        CatagoryRecord *newRecord = [CatagoryRecord new];
        
        newRecord.identifer = userData.catagoryRecords.count;
        newRecord.dateCreated = [NSDate date];
        newRecord.itemCatagoryID = catagoryID;
        newRecord.itemCatagoryName = catagory.name;
        newRecord.receiptID = receiptID;
        newRecord.quantity = quantity;
        newRecord.amount = amount;
        
        //set it back to userData and save it
        [userData.catagoryRecords addObject:newRecord];
        
        return [Utils archiveFile:userData toFile:[self generateUserDataFileNameForUser:userKey]];
    }
    //else we should not be adding a record to a userData that doesn't have any set catagories
    
    return NO;
}

-(BOOL)addCatagoryRecordsForUser:(NSString *)userKey andRecords:(NSArray *)records;
{
    if (!userKey || !records)
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSMutableArray *recordsCopy = userData.catagoryRecords;
        
        //delete all records with same identifiers as records in 'records'
        NSMutableArray *identifiers = [NSMutableArray new];
        for (CatagoryRecord *record in records)
        {
            [identifiers addObject:[NSNumber numberWithInteger:record.identifer]];
        }
        
        NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"identifer in %@", identifiers];
        NSArray *recordsToDelete = [userData.catagoryRecords filteredArrayUsingPredicate: findRecords];
        
        [recordsCopy removeObjectsInArray:recordsToDelete];
        
        //add the new records
        [recordsCopy addObjectsFromArray:records];
        
        //set it back to userData and save it
        userData.catagoryRecords = recordsCopy;
        
        return [Utils archiveFile:userData toFile:[self generateUserDataFileNameForUser:userKey]];
    }
    else
    {
        userData = [UserData new];
        
        [userData.catagoryRecords addObjectsFromArray:records];
        
        return [Utils archiveFile:userData toFile:[self generateUserDataFileNameForUser:userKey]];
    }
    
    return NO;
}

-(BOOL)deleteCatagoryAndRecordsForUser:(NSString *)userKey forCatagoryRecordIDs:(NSArray *)catagoryRecordIDs
{
    if (!userKey || !catagoryRecordIDs)
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"identifer in %@", catagoryRecordIDs];
        NSArray *recordsToDelete = [userData.catagoryRecords filteredArrayUsingPredicate: findRecords];
        
        [userData.catagoryRecords removeObjectsInArray:recordsToDelete];
        
        return [Utils archiveFile:userData toFile:[self generateUserDataFileNameForUser:userKey]];
    }
    
    return NO;
}

-(BOOL)addReceiptForUser:(NSString *)userKey withFilenames:(NSArray *)filenames
{
    if (!userKey || !filenames)
    {
        return NO;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        Receipt *newReceipt = [Receipt new];
        newReceipt.identifer = userData.receipts.count;
        newReceipt.fileNames = [filenames mutableCopy];
        newReceipt.dateCreated = [NSDate date];
        
        [userData.receipts addObject:newReceipt];
        
        return [Utils archiveFile:userData toFile:[self generateUserDataFileNameForUser:userKey]];
    }
    else
    {
        userData = [UserData new];
        
        Receipt *newReceipt = [Receipt new];
        newReceipt.identifer = 0;
        newReceipt.fileNames = [filenames mutableCopy];
        newReceipt.dateCreated = [NSDate date];
        
        [userData.receipts addObject:newReceipt];
        
        return [Utils archiveFile:userData toFile:[self generateUserDataFileNameForUser:userKey]];
    }
    
    return NO;
}

-(NSArray *)loadReceiptsForUser:(NSString *)userKey
{
    if (!userKey)
    {
        return nil;
    }
    
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        return userData.receipts;
    }
    
    return nil;
}

-(Receipt *)loadReceiptForUser:(NSString *)userKey forReceiptID:(NSInteger)receiptID
{
    UserData *userData = [self loadUserDataForUser:userKey];
    
    if (userData)
    {
        NSPredicate *findReceipt = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)receiptID];
        NSArray *receipt = [userData.receipts filteredArrayUsingPredicate: findReceipt];
        
        return [receipt firstObject];
    }
    
    return nil;
}

@end
