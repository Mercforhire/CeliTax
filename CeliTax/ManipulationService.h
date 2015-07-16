//
// ManipulationService.h
// CeliTax
//
// Created by Leon Chen on 2015-05-05.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CatagoriesDAO, RecordsDAO, ReceiptsDAO, Record, TaxYearsDAO, Receipt, TaxYear;

@protocol ManipulationService <NSObject>

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;
@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

- (BOOL) addCatagoryForName: (NSString *) catagoryName
                   forColor: (UIColor *) catagoryColor;

// change an existing catagory by catagoryID, to new name and/or new color.
// if nil is provided for catagoryName or catagoryColor, no change will be made
- (BOOL) modifyCatagoryForCatagoryID: (NSString *) catagoryID
                             newName: (NSString *) catagoryName
                            newColor: (UIColor *) catagoryColor;

- (BOOL) deleteCatagoryForCatagoryID: (NSString *) catagoryID;

- (BOOL) transferCatagoryFromCatagoryID: (NSString *) fromCatagoryID
                           toCatagoryID: (NSString *) toCatagoryID;





- (NSString *) addRecordForCatagoryID: (NSString *) catagoryID
                         forReceiptID: (NSString *) receiptID
                          forQuantity: (NSInteger) quantity
                            forAmount: (float) amount;

- (BOOL) deleteRecord: (NSString *) recordID;

- (BOOL) modifyRecord: (Record *) record;






- (NSString *) addReceiptForFilenames: (NSArray *) filenames
                           andTaxYear: (NSInteger) taxYear;

- (BOOL) modifyReceipt: (Receipt *)receipt;

- (BOOL) deleteReceiptAndAllItsRecords: (NSString *) receiptID;






- (BOOL) addTaxYear: (NSInteger) taxYear;

@end