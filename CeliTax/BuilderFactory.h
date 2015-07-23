//
//  BuilderFactory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoryBuilder, RecordBuilder, ReceiptBuilder, TaxYearBuilder;

@interface BuilderFactory : NSObject

- (CatagoryBuilder *) createCatagoryBuilder;

- (RecordBuilder *) createRecordBuilder;

- (ReceiptBuilder *) createReceiptBuilder;

- (TaxYearBuilder *) createTaxYearBuilder;

@end
