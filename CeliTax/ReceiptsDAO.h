//
// ReceiptsDAO.h
// CeliTax
//
// Created by Leon Chen on 2015-05-22.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Receipt.h"
#import "UserDataDAO.h"

@interface ReceiptsDAO : NSObject

@property (strong, nonatomic) UserDataDAO *userDataDAO;

/*
   @param filenames NSArray of NSString filenames for this receipt

   @return YES if success, NO if user not found or filenames is nil or empty
 */
- (BOOL) addReceiptWithFilenames: (NSArray *) filenames;

/*
   @param filenames NSArray of NSString filenames for this receipt

   @return YES if success, NO if user not found or receiptToAdd is nil
 */
- (BOOL) addReceipt: (Receipt *) receiptToAdd;

/*
   @return NSArray of Receipts, nil if user not found or has no receipts
 */
- (NSArray *) loadReceipts;

/*
   @return NSArray of newest n-th Receipts, nil if user not found or has no receipts
 */
- (NSArray *) loadNewestNthReceipts: (NSInteger) nTh inYear: (NSInteger) year;

/*
   @return NSArray of Receipts from fromDate to toDate
 */
- (NSArray *) loadReceiptsFrom: (NSDate *) fromDate toDate: (NSDate *) toDate;

/*
   @param receiptID NSString receiptID

   @return Receipt object, nil if user not found or receipt not found
 */
- (Receipt *) loadReceipt: (NSString *) receiptID;

/*
   @param receiptID NSString receiptID

   @return YES if success, NO if receipt not found
 */
- (BOOL) deleteReceipt: (NSString *) receiptID;

@end