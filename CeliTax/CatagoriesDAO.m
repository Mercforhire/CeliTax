//
//  CatagoriesDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesDAO.h"
#import "Utils.h"

#import "CeliTax-Swift.h"

@interface CatagoriesDAO ()

@end

@implementation CatagoriesDAO

-(NSArray *)loadCatagories
{
    NSPredicate *loadCatagories = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionStatusDataActionDelete];
    NSArray *catagories = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: loadCatagories];
    
    return catagories;
}

-(ItemCategory *)loadCatagory:(NSString *)catagoryID
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@ AND dataAction != %ld", catagoryID, DataActionStatusDataActionDelete];
    NSArray *category = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    return category.firstObject;
}

-(BOOL)addCatagoryForName:(NSString *)name andColor:(UIColor *)color save:(BOOL)save
{
    if ( !name || !color )
    {
        return NO;
    }
    
    ItemCategory *catagoryToAdd = [ItemCategory new];
    
    catagoryToAdd.localID = [Utils generateUniqueID];
    catagoryToAdd.name = name;
    catagoryToAdd.color = color;
    catagoryToAdd.dataAction = DataActionStatusDataActionInsert;
    
    [[self.userDataDAO getCatagories] addObject:catagoryToAdd];
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

-(BOOL)modifyCatagory:(NSString *)catagoryID forName:(NSString *)name andColor:(UIColor *)color save:(BOOL)save
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *category = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (category && category.count)
    {
        ItemCategory *catagoryToModify = category.firstObject;
        
        catagoryToModify.name = name;
        catagoryToModify.color = color;
        
        if (catagoryToModify.dataAction != DataActionStatusDataActionInsert)
        {
            catagoryToModify.dataAction = DataActionStatusDataActionUpdate;
        }
        
        if (save)
        {
            return [self.userDataDAO saveUserData];
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

-(BOOL)deleteCatagory:(NSString *)catagoryID save:(BOOL)save
{
    //delete the existing ItemCategory with same ID as catagory's ID
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *catagoriesToDelete = [[self loadCatagories] filteredArrayUsingPredicate: findCatagories];
    
    for (ItemCategory *catagoryToDelete in catagoriesToDelete)
    {
        catagoryToDelete.dataAction = DataActionStatusDataActionDelete;
    }
    
    //delete any ItemCategory records belonging to the catagoryID
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *RecordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    for (Record *recordToDelete in RecordsToDelete)
    {
        recordToDelete.dataAction = DataActionStatusDataActionDelete;
    }
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

-(void)addCatagory:(ItemCategory *)category
{
    [[self.userDataDAO getCatagories] addObject:category];
}

-(BOOL)mergeWith:(NSArray *)catagories save:(BOOL)save
{
    NSMutableArray *localCatagories = [NSMutableArray arrayWithArray:[self loadCatagories]];
    
    for (ItemCategory *category in catagories)
    {
        //find any existing ItemCategory with same id as this new one
        NSPredicate *findCatagory = [NSPredicate predicateWithFormat: @"localID == %@", category.localID];
        NSArray *existingCatagory = [localCatagories filteredArrayUsingPredicate: findCatagory];
        
        if (existingCatagory.count)
        {
            ItemCategory *existing = existingCatagory.firstObject;
            
            [existing copyDataFromCategory:category];
            
            [localCatagories removeObject:existing];
        }
        else
        {
            [self addCatagory:category];
        }
    }
    
    //For any local ItemCategory that the server doesn't have and isn't marked DataActionInsert,
    //we need to set these to DataActionInsert again so that can be uploaded to the server next time
    for (ItemCategory *category in localCatagories)
    {
        if (category.dataAction != DataActionStatusDataActionInsert)
        {
            category.dataAction = DataActionStatusDataActionInsert;
        }
    }
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

-(BOOL)addOrUpdateNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType amount:(float)amount save: (BOOL)save
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *category = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (category && category.count)
    {
        ItemCategory *catagoryToModify = category.firstObject;
        
        // Do modifying here
        [catagoryToModify addOrUpdateNationalAverageCostForUnitType:unitType amount:amount];
        
        if (catagoryToModify.dataAction != DataActionStatusDataActionInsert)
        {
            catagoryToModify.dataAction = DataActionStatusDataActionUpdate;
        }
        
        if (save)
        {
            return [self.userDataDAO saveUserData];
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

-(BOOL)deleteNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType save: (BOOL)save
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *category = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (category && category.count)
    {
        ItemCategory *catagoryToModify = category.firstObject;
        
        // Do modifying here
        [catagoryToModify deleteNationalAverageCostForUnitType:unitType];
        
        if (catagoryToModify.dataAction != DataActionStatusDataActionInsert)
        {
            catagoryToModify.dataAction = DataActionStatusDataActionUpdate;
        }
        
        if (save)
        {
            return [self.userDataDAO saveUserData];
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

@end
