//
//  BuilderFactory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BuilderFactory.h"
#import "CatagoryBuilder.h"
#import "Catagory.h"
#import "RecordBuilder.h"
#import "Record.h"
#import "Receipt.h"
#import "ReceiptBuilder.h"
#import "TaxYear.h"
#import "TaxYearBuilder.h"

@interface BuilderFactory ()

@property (nonatomic, strong) CatagoryBuilder *catagoryBuilder;
@property (nonatomic, strong) RecordBuilder *recordBuilder;
@property (nonatomic, strong) ReceiptBuilder *receiptBuilder;
@property (nonatomic, strong) TaxYearBuilder *taxYearBuilder;

@end

@implementation BuilderFactory

- (CatagoryBuilder *) createCatagoryBuilder
{
    if (self.catagoryBuilder)
    {
        return self.catagoryBuilder;
    }
    
    self.catagoryBuilder = [[CatagoryBuilder alloc] init];
    
    return self.catagoryBuilder;
}

- (RecordBuilder *) createRecordBuilder
{
    if (self.recordBuilder)
    {
        return self.recordBuilder;
    }
    
    self.recordBuilder = [[RecordBuilder alloc] init];
    
    return self.recordBuilder;
}

- (ReceiptBuilder *) createReceiptBuilder
{
    if (self.receiptBuilder)
    {
        return self.receiptBuilder;
    }
    
    self.receiptBuilder = [[ReceiptBuilder alloc] init];
    
    return self.receiptBuilder;
}

- (TaxYearBuilder *) createTaxYearBuilder
{
    if (self.taxYearBuilder)
    {
        return self.taxYearBuilder;
    }
    
    self.taxYearBuilder = [[TaxYearBuilder alloc] init];
    
    return self.taxYearBuilder;
}


@end
