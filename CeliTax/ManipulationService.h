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

@property (nonatomic, weak) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, weak) RecordsDAO *recordsDAO;
@property (nonatomic, weak) ReceiptsDAO *receiptsDAO;
@property (nonatomic, weak) TaxYearsDAO *taxYearsDAO;

- (BOOL) addCatagoryForName: (NSString *) catagoryName
                   forColor: (UIColor *) catagoryColor
                       save: (BOOL)save;

// change an existing catagory by catagoryID, to new name and/or new color.
// if nil is provided for catagoryName or catagoryColor, no change will be made
- (BOOL) modifyCatagoryForCatagoryID: (NSString *) catagoryID
                             newName: (NSString *) catagoryName
                            newColor: (UIColor *) catagoryColor
                                save: (BOOL)save;

- (BOOL) deleteCatagoryForCatagoryID: (NSString *) catagoryID save: (BOOL)save;

- (BOOL) transferCatagoryFromCatagoryID: (NSString *) fromCatagoryID
                           toCatagoryID: (NSString *) toCatagoryID
                                   save: (BOOL)save;

- (BOOL)addOrUpdateNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType amount:(float)amount save: (BOOL)save;

- (BOOL)deleteNationalAverageCostForCatagoryID: (NSString *) catagoryID andUnitType:(NSInteger)unitType save: (BOOL)save;




-(NSString *)addRecordForCatagoryID: (NSString *) catagoryID
                       andReceiptID: (NSString *) receiptID
                        forQuantity: (NSInteger) quantity
                             orUnit: (NSInteger) unitType
                          forAmount: (float) amount
                               save: (BOOL)save;

- (BOOL) deleteRecord: (NSString *) recordID save: (BOOL)save;

- (BOOL) modifyRecord: (Record *) record save: (BOOL)save;






- (NSString *) addReceiptForFilenames: (NSArray *) filenames
                           andTaxYear: (NSInteger) taxYear
                                 save: (BOOL)save;

- (BOOL) modifyReceipt: (Receipt *)receipt save: (BOOL)save;

- (BOOL) deleteReceiptAndAllItsRecords: (NSString *) receiptID save: (BOOL)save;






- (BOOL) addTaxYear: (NSInteger) taxYear save: (BOOL)save;

@end