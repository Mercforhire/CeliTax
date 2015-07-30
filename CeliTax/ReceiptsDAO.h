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

   @return ID of newest receipt added, nil if failed
 */
- (NSString *) addReceiptWithFilenames: (NSArray *) filenames inTaxYear:(NSInteger)taxYear save:(BOOL) save;


- (BOOL) addReceipt: (Receipt *) receiptToAdd save:(BOOL) save;

/*
 @return NSArray of Receipts, nil if user not found or has no receipts
 */
- (NSArray *) loadAllReceipts;

/*
   @return NSArray of Receipts, nil if user not found or has no receipts
 */
- (NSArray *) loadReceiptsFromTaxYear:(NSInteger)taxYear;

/*
   @return NSArray of newest n-th Receipts, nil if user not found or has no receipts
 */
- (NSArray *) loadNewestNthReceipts: (NSInteger) nTh inTaxYear: (NSInteger) taxYear;

/*
   @return NSArray of Receipts from fromDate to toDate
 */
- (NSArray *) loadReceiptsFrom: (NSDate *) fromDate toDate: (NSDate *) toDate inTaxYear:(NSInteger)taxYear;

/*
   @param receiptID NSString receiptID

   @return Receipt object, nil if user not found or receipt not found
 */
- (Receipt *) loadReceipt: (NSString *) receiptID;

/**
 @return YES if success, NO if record is not found in existing database
 */
- (BOOL)modifyReceipt: (Receipt *)receipt save:(BOOL) save;;

/*
   @param receiptID NSString receiptID

   @return YES if success, NO if receipt not found
 */
- (BOOL) deleteReceipt: (NSString *) receiptID save:(BOOL) save;

-(BOOL)mergeWith:(NSArray *)receipts save:(BOOL)save;

@end