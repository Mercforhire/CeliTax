//
//  CatagoriesDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesDAO.h"
#import "Catagory.h"
#import "Record.h"
#import "Utils.h"

@interface CatagoriesDAO ()

@end

@implementation CatagoriesDAO

-(NSArray *)loadCatagories
{
    NSPredicate *loadCatagories = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionDelete];
    NSArray *catagories = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: loadCatagories];
    
    return catagories;
}

-(Catagory *)loadCatagory:(NSString *)catagoryID
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@ AND dataAction != %ld", catagoryID, DataActionDelete];
    NSArray *catagory = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    return [catagory firstObject];
}

-(BOOL)addCatagoryForName:(NSString *)name andColor:(UIColor *)color save:(BOOL)save
{
    if ( !name || !color )
    {
        return NO;
    }
    
    Catagory *catagoryToAdd = [Catagory new];
    
    catagoryToAdd.localID = [Utils generateUniqueID];
    catagoryToAdd.name = name;
    catagoryToAdd.color = color;
    catagoryToAdd.dataAction = DataActionInsert;
    
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
    NSArray *catagory = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (catagory && catagory.count)
    {
        Catagory *catagoryToModify = [catagory firstObject];
        
        catagoryToModify.name = name;
        catagoryToModify.color = color;
        
        if (catagoryToModify.dataAction != DataActionInsert)
        {
            catagoryToModify.dataAction = DataActionUpdate;
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
    //delete the existing catagory with same ID as catagory's ID
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *catagoriesToDelete = [[self loadCatagories] filteredArrayUsingPredicate: findCatagories];
    
    for (Catagory *catagoryToDelete in catagoriesToDelete)
    {
        catagoryToDelete.dataAction = DataActionDelete;
    }
    
    //delete any catagory records belonging to the catagoryID
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *RecordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    for (Record *recordToDelete in RecordsToDelete)
    {
        recordToDelete.dataAction = DataActionDelete;
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

-(void)addCatagory:(Catagory *)catagory
{
    [[self.userDataDAO getCatagories] addObject:catagory];
}

-(BOOL)mergeWith:(NSArray *)catagories save:(BOOL)save
{
    NSMutableArray *localCatagories = [NSMutableArray arrayWithArray:[self loadCatagories]];
    
    for (Catagory *catagory in catagories)
    {
        //find any existing Catagory with same id as this new one
        NSPredicate *findCatagory = [NSPredicate predicateWithFormat: @"localID == %@", catagory.localID];
        NSArray *existingCatagory = [localCatagories filteredArrayUsingPredicate: findCatagory];
        
        if (existingCatagory.count)
        {
            Catagory *existing = [existingCatagory firstObject];
            
            [existing copyDataFromCatagory:catagory];
            
            [localCatagories removeObject:existing];
        }
        else
        {
            [self addCatagory:catagory];
        }
    }
    
    //For any local Catagory that the server doesn't have and isn't marked DataActionInsert,
    //we need to set these to DataActionInsert again so that can be uploaded to the server next time
    for (Catagory *catagory in localCatagories)
    {
        if (catagory.dataAction != DataActionInsert)
        {
            catagory.dataAction = DataActionInsert;
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
    NSArray *catagory = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (catagory && catagory.count)
    {
        Catagory *catagoryToModify = [catagory firstObject];
        
        // Do modifying here
        [catagoryToModify addOrUpdateNationalAverageCostForUnitType:unitType amount:amount];
        
        if (catagoryToModify.dataAction != DataActionInsert)
        {
            catagoryToModify.dataAction = DataActionUpdate;
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
    NSArray *catagory = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (catagory && catagory.count)
    {
        Catagory *catagoryToModify = [catagory firstObject];
        
        // Do modifying here
        [catagoryToModify deleteNationalAverageCostForUnitType:unitType];
        
        if (catagoryToModify.dataAction != DataActionInsert)
        {
            catagoryToModify.dataAction = DataActionUpdate;
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
