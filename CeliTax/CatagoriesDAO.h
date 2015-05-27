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

@property (strong, nonatomic) UserDataDAO *userDataDAO;

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
 
 @return YES if success, NO if user not found or name or color is nil
 */
-(BOOL)addCatagoryForName:(NSString *)name andColor:(UIColor *)color andNationalAverageCost:(float)cost;

/**
 @param catagory ItemCatagory catagory to add
 
 @return YES if success, NO if user not found or catagory is nil
 */
//-(BOOL)addCatagory:(Catagory *)catagory;

/**
 @param catagoryID NSString catagory to modify ID
 @param name NSString name
 @param color UIColor color
 
 @return YES if success, NO if user not found or catagory is nil
 */
-(BOOL)modifyCatagory:(NSString *)catagoryID forName:(NSString *)name andColor:(UIColor *)color;

/**
 @param catagoryID NSString ID of catagory to delete
 
 @return YES if success, NO if user not found or catagory is not found
 */
-(BOOL)deleteCatagory:(NSString *)catagoryID;

@end
