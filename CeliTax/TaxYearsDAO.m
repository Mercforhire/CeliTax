//
//  TaxYearsDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TaxYearsDAO.h"

@implementation TaxYearsDAO

-(NSArray *)loadAllTaxYears
{
    return [self.userDataDAO getTaxYears];
}

-(BOOL)addTaxYear:(NSInteger)taxYear
{
    if (taxYear > 2000)
    {
        NSNumber *newTaxYear = [NSNumber numberWithInteger:taxYear];
        
        [[self.userDataDAO getTaxYears] addObject:newTaxYear];
        
        return [self.userDataDAO saveUserData];
    }
    
    return NO;
}

-(BOOL)removeTaxYear:(NSInteger)taxYear
{
    if (taxYear > 2000)
    {
        NSNumber *taxYearToDelete = [NSNumber numberWithInteger:taxYear];
        
        [[self.userDataDAO getTaxYears] removeObject:taxYearToDelete];
        
        return [self.userDataDAO saveUserData];
    }
    
    return NO;
}

@end
