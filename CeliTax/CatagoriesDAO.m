//
//  CatagoriesDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesDAO.h"
#import "Catagory.h"

@interface CatagoriesDAO ()

@end

@implementation CatagoriesDAO

-(NSArray *)loadCatagories
{
    return [self.userDataDAO getCatagories];
}

-(Catagory *)loadCatagory:(NSInteger)catagoryID
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)catagoryID];
    NSArray *catagory = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    return [catagory firstObject];
}

-(BOOL)addCatagoryForName:(NSString *)name andColor:(UIColor *)color
{
    if ( !name || !color )
    {
        return NO;
    }
    
    Catagory *catagoryToAdd = [Catagory new];
    
    catagoryToAdd.identifer = [self.userDataDAO getCatagories].count;
    catagoryToAdd.name = name;
    catagoryToAdd.color = color;
    
    [[self.userDataDAO getCatagories] addObject:catagoryToAdd];
    
    return [self.userDataDAO saveUserData];
}

-(BOOL)addCatagory:(Catagory *)catagory
{
    if ( !catagory )
    {
        return NO;
    }
    
    [[self.userDataDAO getCatagories] addObject:catagory];
    
    return [self.userDataDAO saveUserData];
}

-(BOOL)modifyCatagory:(NSInteger)catagoryID forName:(NSString *)name andColor:(UIColor *)color
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)catagoryID];
    NSArray *catagory = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    if (catagory && catagory.count)
    {
        Catagory *catagoryToModify = [catagory firstObject];
        
        catagoryToModify.name = name;
        catagoryToModify.color = color;
        
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return NO;
    }
}

-(BOOL)deleteCatagory:(NSInteger)catagoryID
{
    //delete the existing catagory with same ID as catagory's ID
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %ld", (long)catagoryID];
    NSArray *catagoryToDelete = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    [[self.userDataDAO getCatagories] removeObjectsInArray:catagoryToDelete];
    
    //delete any catagory records belonging to the catagoryID
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %ld", (long)catagoryID];
    NSArray *RecordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    [[self.userDataDAO getRecords] removeObjectsInArray:RecordsToDelete];
    
    return [self.userDataDAO saveUserData];
}

@end
