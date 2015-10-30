//
//  TaxYearBuilder.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TaxYearBuilder.h"

@implementation TaxYearBuilder

- (TaxYear *) buildTaxYearFrom: (NSNumber *) taxYearNumber
{
    if (![taxYearNumber isKindOfClass: [NSNumber class]])
    {
        return nil;
    }
    
    TaxYear *taxYear = [[TaxYear alloc] init];
    
    taxYear.taxYear = taxYearNumber.integerValue;
    
    return taxYear;
}

@end
