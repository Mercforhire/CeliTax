//
//  RecordsDAO.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-22.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataDAO.h"
#import "CatagoriesDAO.h"

@class Record, Receipt;

@interface RecordsDAO : NSObject

@property (strong, nonatomic) UserDataDAO *userDataDAO;
@property (strong, nonatomic) CatagoriesDAO *catagoriesDAO;

/**
 @return NSArray of Records, nil if user not found
 */
-(NSArray *)loadRecords;

/**
 @param catagoryID NSString ID of catagory's records to load
 
 @return NSArray of Records, nil if user not found or catagory not found
 */
-(NSArray *)loadRecordsforCatagory:(NSString *)catagoryID;

/**
 @param receiptID NSString ID of receipt's records to load
 
 @return NSArray of Records, nil if user not found or catagory not found
 */
-(NSArray *)loadRecordsforReceipt:(NSString *)receiptID;

/**
 @param recordID NSString ID of record to load
 
 @return Record, nil if not found
 */
-(Record *)loadRecord:(NSString *)recordID;

/**
 @return NSString ID of the new record added, nil if error occurred
 */
-(NSString *)addRecordForCatagory: (Catagory *) catagory
                 andReceipt: (Receipt *) receipt
                forQuantity: (NSInteger) quantity
                  forAmount: (float) amount;


/**
 @return NSString ID of the new record added, nil if error occurred
 */
-(NSString *)addRecordForCatagoryID: (NSString *) catagoryID
                 andReceiptID: (NSString *) receiptID
                  forQuantity: (NSInteger) quantity
                    forAmount: (float) amount;

/**
 @return YES if success, NO if user not found or records is nil
 */
-(BOOL)addRecords:(NSArray *)records;

/**
 @return YES if success, NO if record is not found in existing database
 */
-(BOOL)modifyRecord:(Record *)record;

/**
 @return YES if success, NO if user not found or catagory not found
 */
-(BOOL)deleteRecordsForRecordIDs:(NSArray *)recordIDs;

@end
