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

-(Catagory *)loadCatagory:(NSString *)catagoryID
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %@", catagoryID];
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
    
    catagoryToAdd.identifer = [[NSUUID UUID] UUIDString];
    catagoryToAdd.name = name;
    catagoryToAdd.color = color;
    catagoryToAdd.nationalAverageCost = cost;
    
    [[self.userDataDAO getCatagories] addObject:catagoryToAdd];
    
    return [self.userDataDAO saveUserData];
}

//-(BOOL)addCatagory:(Catagory *)catagory
//{
//    if ( !catagory )
//    {
//        return NO;
//    }
//    
//    [[self.userDataDAO getCatagories] addObject:catagory];
//    
//    return [self.userDataDAO saveUserData];
//}

-(BOOL)modifyCatagory:(NSString *)catagoryID forName:(NSString *)name andColor:(UIColor *)color
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %@", catagoryID];
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

-(BOOL)deleteCatagory:(NSString *)catagoryID
{
    //delete the existing catagory with same ID as catagory's ID
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %@", catagoryID];
    NSArray *catagoryToDelete = [[self.userDataDAO getCatagories] filteredArrayUsingPredicate: findCatagories];
    
    [[self.userDataDAO getCatagories] removeObjectsInArray:catagoryToDelete];
    
    //delete any catagory records belonging to the catagoryID
    NSPredicate *findRecords = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *RecordsToDelete = [[self.userDataDAO getRecords] filteredArrayUsingPredicate: findRecords];
    
    [[self.userDataDAO getRecords] removeObjectsInArray:RecordsToDelete];
    
    return [self.userDataDAO saveUserData];
}

@end
