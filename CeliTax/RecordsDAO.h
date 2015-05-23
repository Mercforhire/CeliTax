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

@interface RecordsDAO : NSObject

@property (strong, nonatomic) UserDataDAO *userDataDAO;
@property (strong, nonatomic) CatagoriesDAO *catagoriesDAO;

/**
 @return NSArray of Records, nil if user not found
 */
-(NSArray *)loadRecords;

/**
 @param catagoryID NSInteger ID of catagory's records to load
 
 @return NSArray of Records, nil if user not found or catagory not found
 */
-(NSArray *)loadRecordsforCatagory:(NSInteger)catagoryID;

/**
 @param receiptID NSInteger ID of receipt's records to load
 
 @return NSArray of Records, nil if user not found or catagory not found
 */
-(NSArray *)loadRecordsforReceipt:(NSInteger)receiptID;

/**
 @return YES if success
 */
-(BOOL)addRecordForCatagoryID: (NSInteger) catagoryID
                 forReceiptID: (NSInteger) receiptID
                  forQuantity: (NSInteger) quantity
                    forAmount: (NSInteger) amount;

/**
 @return YES if success, NO if user not found or records is nil
 */
-(BOOL)addRecords:(NSArray *)records;

/**
 @param catagoryID NSInteger ID of catagory's records to delete
 
 @return YES if success, NO if user not found or catagory not found
 */
-(BOOL)deleteCatagoryAndRecordsForRecordIDs:(NSArray *)recordIDs;

@end
