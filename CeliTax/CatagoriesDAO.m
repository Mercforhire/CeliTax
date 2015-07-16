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

-(BOOL)addCatagoryForName:(NSString *)name andColor:(UIColor *)color andNationalAverageCost:(float)cost
{
    if ( !name || !color )
    {
        return NO;
    }
    
    Catagory *catagoryToAdd = [Catagory new];
    
    catagoryToAdd.localID = [Utils generateUniqueID];
    catagoryToAdd.name = name;
    catagoryToAdd.color = color;
    catagoryToAdd.nationalAverageCost = cost;
    catagoryToAdd.dataAction = DataActionInsert;
    
    [[self.userDataDAO getCatagories] addObject:catagoryToAdd];
    
    return [self.userDataDAO saveUserData];
}

-(BOOL)modifyCatagory:(NSString *)catagoryID forName:(NSString *)name andColor:(UIColor *)color
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
        
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return NO;
    }
}

-(BOOL)deleteCatagory:(NSString *)catagoryID
{
    //delete the existing catagory with same ID as catagory's ID
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *catagoriesToDelete = [[self loadCatagories] filteredArrayUsingPredicate: findCatagories];
    
    for (Catagory *catagoryToDelete in catagoriesToDelete)
    {
        if (!catagoryToDelete.serverID)
        {
            //catagoryToDelete is not on server, delete it right away
            [[self.userDataDAO getCatagories] removeObject:catagoryToDelete];
        }
        else
        {
            //catagoryToDelete is on server, have to set its DataAction to delete
            catagoryToDelete.dataAction = DataActionDelete;
        }
    }
    
    //delete any catagory records belonging to the catagoryID
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *RecordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    for (Record *recordToDelete in RecordsToDelete)
    {
        if (!recordToDelete.serverID)
        {
            //recordToDelete is not on server, delete it right away
            [[self.userDataDAO getRecords] removeObject:recordToDelete];
        }
        else
        {
            //recordToDelete is on server, have to set its DataAction to delete
            recordToDelete.dataAction = DataActionDelete;
        }
    }
    
    return [self.userDataDAO saveUserData];
}

@end
