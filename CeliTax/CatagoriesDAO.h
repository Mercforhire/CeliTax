//
//  CatagoriesDAO.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataDAO.h"
#import "Catagory.h"

@interface CatagoriesDAO : NSObject

@property (weak, nonatomic) UserDataDAO *userDataDAO;

/**
 @return NSArray of Catagory, nil if user not found
 */
-(NSArray *)loadCatagories;

/**
 @return Catagory, nil if user not found or catagory not found
 */
-(Catagory *)loadCatagory:(NSString *)catagoryID;

/**
 @param name NSString name
 @param color UIColor color
 @param save BOOL save to disk at end of operation
 
 @return YES if success
 */
-(BOOL)addCatagoryForName:(NSString *)name andColor:(UIColor *)color save:(BOOL)save;

/**
 @param catagoryID NSString catagory to modify ID
 @param name NSString name
 @param color UIColor color
 @param save BOOL save to disk at end of operation
 
 @return YES if success
 */
-(BOOL)modifyCatagory:(NSString *)catagoryID forName:(NSString *)name andColor:(UIColor *)color save:(BOOL)save;

/**
 @param catagoryID NSString ID of catagory to delete
 @param save BOOL save to disk at end of operation
 
 @return YES if success
 */
-(BOOL)deleteCatagory:(NSString *)catagoryID save:(BOOL)save;


/**
 @param catagories NSArray of Catagory objects to merge with
        any Catagory with existing Catagory in local Database of same id will be updated with new data
        any Catagory that doesn't exist locally will be added as new ones
 @param save BOOL save to disk at end of operation
 
 @return YES if success
 */
-(BOOL)mergeWith:(NSArray *)catagories save:(BOOL)save;

/**
 @return YES if success
 */
-(BOOL)addOrUpdateNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType amount:(float)amount save: (BOOL)save;

/**
 @return YES if success
 */
-(BOOL)deleteNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType save: (BOOL)save;

@end
