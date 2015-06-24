//
// ManipulationService.h
// CeliTax
//
// Created by Leon Chen on 2015-05-05.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CatagoriesDAO, RecordsDAO, ReceiptsDAO, Record, TaxYearsDAO, Receipt;

@protocol ManipulationService <NSObject>

typedef void (^AddCatagorySuccessBlock)();
typedef void (^AddCatagoryFailureBlock)(NSString *reason);

typedef void (^ModifyCatagorySuccessBlock)();
typedef void (^ModifyCatagoryFailureBlock)(NSString *reason);

typedef void (^DeleteCatagorySuccessBlock)();
typedef void (^DeleteCatagoryFailureBlock)(NSString *reason);

typedef void (^AddRecordSuccessBlock)(NSString *newestRecordID);
typedef void (^AddRecordFailureBlock)(NSString *reason);

typedef void (^DeleteRecordSuccessBlock)();
typedef void (^DeleteRecordFailureBlock)(NSString *reason);

typedef void (^ModifyRecordSuccessBlock)();
typedef void (^ModifyRecordFailureBlock)(NSString *reason);

typedef void (^AddReceiptSuccessBlock)(NSString *newestReceiptID);
typedef void (^AddReceiptFailureBlock)(NSString *reason);

typedef void (^DeleteReceiptSuccessBlock)();
typedef void (^DeleteReceiptFailureBlock)(NSString *reason);

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;
@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

- (void) addCatagoryForName: (NSString *) catagoryName
                   forColor: (UIColor *) catagoryColor
                    success: (AddCatagorySuccessBlock) success
                    failure: (AddCatagoryFailureBlock) failure;

// change an existing catagory by catagoryID, to new name and/or new color.
// if nil is provided for catagoryName or catagoryColor, no change will be made
- (void) modifyCatagoryForCatagoryID: (NSString *) catagoryID
                             newName: (NSString *) catagoryName
                            newColor: (UIColor *) catagoryColor
                             success: (ModifyCatagorySuccessBlock) success
                             failure: (ModifyCatagoryFailureBlock) failure;

- (void) deleteCatagoryForCatagoryID: (NSString *) catagoryID
                             success: (DeleteCatagorySuccessBlock) success
                             failure: (DeleteCatagoryFailureBlock) failure;

- (void) transferCatagoryFromCatagoryID: (NSString *) fromCatagoryID
                           toCatagoryID: (NSString *) toCatagoryID
                                success: (ModifyCatagorySuccessBlock) success
                                failure: (ModifyCatagoryFailureBlock) failure;





- (void) addRecordForCatagoryID: (NSString *) catagoryID
                   forReceiptID: (NSString *) receiptID
                    forQuantity: (NSInteger) quantity
                      forAmount: (float) amount
                        success: (AddRecordSuccessBlock) success
                        failure: (AddRecordFailureBlock) failure;

- (void) deleteRecord: (NSString *) recordID
          WithSuccess: (DeleteRecordSuccessBlock) success
           andFailure: (DeleteRecordFailureBlock) failure;

- (void) modifyRecord: (Record *) record
          WithSuccess: (ModifyRecordSuccessBlock) success
           andFailure: (ModifyRecordFailureBlock) failure;






- (void) addReceiptForFilenames: (NSArray *) filenames
                     andTaxYear: (NSInteger) taxYear
                        success: (AddReceiptSuccessBlock) success
                        failure: (AddReceiptFailureBlock) failure;

- (BOOL) modifyReceipt:(Receipt *)receipt;

- (void) deleteReceiptAndAllItsRecords: (NSString *) receiptID
                               success: (DeleteReceiptSuccessBlock) success
                               failure: (DeleteReceiptFailureBlock) failure;






- (BOOL) addTaxYear: (NSInteger) taxYear;

- (BOOL) removeTaxYear: (NSInteger) taxYear;

@end