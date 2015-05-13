//
//  CatagoriesDAO.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ItemCatagory;
@class CatagoryRecord;
@class Receipt;

@interface CatagoriesDAO : NSObject

/**
 @param userKey NSString User API Key
 
 @return NSArray of ItemCatagory, nil if user not found
 */
-(NSArray *)loadCatagoriesForUser:(NSString *)userKey;

/**
 @param userKey NSString User API Key
 
 @return ItemCatagory, nil if user not found or catagory not found
 */
-(ItemCatagory *)loadCatagoryForUser:(NSString *)userKey withCatagoryID:(NSInteger)catagoryID;

/**
 @param userKey NSString User API Key
 @param name NSString name
 @param color UIColor color
 
 @return YES if success, NO if user not found or name or color is nil
 */
-(BOOL)addCatagoryForUser:(NSString *)userKey forName:(NSString *)name andColor:(UIColor *)color;

/**
 @param userKey NSString User API Key
 @param catagory ItemCatagory catagory to add
 
 @return YES if success, NO if user not found or catagory is nil
 */
-(BOOL)addCatagoryForUser:(NSString *)userKey withCatagory:(ItemCatagory *)catagory;

/**
 @param userKey NSString User API Key
 @param catagoryID NSInteger catagory to modify ID
 @param name NSString name
 @param color UIColor color
 
 @return YES if success, NO if user not found or catagory is nil
 */
-(BOOL)modifyCatagoryForUser:(NSString *)userKey forCatagory:(NSInteger)catagoryID forName:(NSString *)name andColor:(UIColor *)color;

/**
 @param userKey NSString User API Key
 @param catagoryID NSInteger ID of catagory to delete
 
 @return YES if success, NO if user not found or catagory is not found
 */
-(BOOL)deleteCatagoryForUser:(NSString *)userKey forCatagory:(NSInteger)catagoryID;







/**
 @param userKey NSString User API Key
 
 @return NSArray of CatagoryRecords, nil if user not found
 */
-(NSArray *)loadCatagoryRecordsForUser:(NSString *)userKey;

/**
 @param userKey NSString User API Key
 @param catagoryID NSInteger ID of catagory's records to load
 
 @return NSArray of CatagoryRecords, nil if user not found or catagory not found
 */
-(NSArray *)loadCatagoryRecordsForUser:(NSString *)userKey forCatagory:(NSInteger)catagoryID;

/**
 @param userKey NSString User API Key
 @param receiptID NSInteger ID of receipt's records to load
 
 @return NSArray of CatagoryRecords, nil if user not found or catagory not found
 */
-(NSArray *)loadCatagoryRecordsForUser:(NSString *)userKey forReceipt:(NSInteger)receiptID;

/**
 @return YES if success, NO if user not found or records is nil
 */
-(BOOL)addCatagoryRecordForUser: (NSString *) userKey
                  forCatagoryID: (NSInteger) catagoryID
                   forReceiptID: (NSInteger) receiptID
                    forQuantity: (NSInteger) quantity
                      forAmount: (NSInteger) amount;

/**
 @param userKey NSString User API Key
 @param records NSArray of CatagoryRecord to save
 
 @return YES if success, NO if user not found or records is nil
 */
-(BOOL)addCatagoryRecordsForUser:(NSString *)userKey andRecords:(NSArray *)records;

/**
 @param userKey NSString User API Key
 @param catagoryID NSInteger ID of catagory's records to delete
 
 @return YES if success, NO if user not found or catagory not found
 */
-(BOOL)deleteCatagoryAndRecordsForUser:(NSString *)userKey forCatagoryRecordIDs:(NSArray *)catagoryRecordIDs;







/**
 @param userKey NSString User API Key
 @param filenames NSArray of NSString filenames for this receipt
 
 @return YES if success, NO if user not found or filenames is nil or empty
 */
-(BOOL)addReceiptForUser:(NSString *)userKey withFilenames:(NSArray *)filenames;

/**
 @param userKey NSString User API Key
 
 @return NSArray of Receipts, nil if user not found or has no receipts
 */
-(NSArray *)loadReceiptsForUser:(NSString *)userKey;

/**
 @param userKey NSString User API Key
 @param receiptID NSInteger receiptID
 
 @return Receipt object, nil if user not found or receipt not found
 */
-(Receipt *)loadReceiptForUser:(NSString *)userKey forReceiptID:(NSInteger)receiptID;

@end
