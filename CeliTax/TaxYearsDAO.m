//
//  TaxYearsDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TaxYearsDAO.h"
#import "TaxYear.h"

@implementation TaxYearsDAO

-(NSArray *)loadAllTaxYears
{
    NSPredicate *loadTaxYears = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionDelete];
    NSArray *taxYearsObjects = [[self.userDataDAO getTaxYears] filteredArrayUsingPredicate: loadTaxYears];
    
    NSMutableArray *taxYearNumbers = [NSMutableArray new];
    
    for (TaxYear *taxYear in taxYearsObjects)
    {
        [taxYearNumbers addObject:[NSNumber numberWithInteger:taxYear.taxYear]];
    }
    
    return taxYearNumbers;
}

-(BOOL)addTaxYear:(NSInteger)taxYear
{
    if (taxYear > 2000)
    {
        TaxYear *taxTear = [TaxYear new];
        taxTear.taxYear = taxYear;
        taxTear.dataAction = DataActionInsert;
        
        [[self.userDataDAO getTaxYears] addObject:taxTear];
        
        return [self.userDataDAO saveUserData];
    }
    
    return NO;
}

@end
