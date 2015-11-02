//
//  TaxYearsDAO.m
//  CeliTax
//
//  Created by Leon Chen on 2015-06-17.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TaxYearsDAO.h"
#import "CeliTax-Swift.h"

@implementation TaxYearsDAO

-(NSArray *)loadAllTaxYears
{
    NSPredicate *loadTaxYears = [NSPredicate predicateWithFormat: @"dataAction != %ld", DataActionStatusDataActionDelete];
    NSArray *taxYearsObjects = [[self.userDataDAO getTaxYears] filteredArrayUsingPredicate: loadTaxYears];
    
    NSMutableArray *taxYearNumbers = [NSMutableArray new];
    
    for (TaxYear *taxYear in taxYearsObjects)
    {
        [taxYearNumbers addObject:@(taxYear.taxYear)];
    }
    
    return taxYearNumbers;
}

-(BOOL)addTaxYear:(NSInteger)taxYear save:(BOOL)save
{
    if (taxYear > 2000)
    {
        TaxYear *taxTear = [TaxYear new];
        taxTear.taxYear = taxYear;
        taxTear.dataAction = DataActionStatusDataActionInsert;
        
        [[self.userDataDAO getTaxYears] addObject:taxTear];
        
        if (save)
        {
            return [self.userDataDAO saveUserData];
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)mergeWith:(NSArray *)taxyears save:(BOOL)save
{
    NSMutableArray *localTaxyears = [NSMutableArray arrayWithArray:[self.userDataDAO getTaxYears]];
    
    for (TaxYear *taxyear in taxyears)
    {
        //find any existing Taxyear with same year as this new one
        NSPredicate *findTaxyear = [NSPredicate predicateWithFormat: @"taxYear == %ld", taxyear.taxYear];
        NSArray *existingYear = [localTaxyears filteredArrayUsingPredicate: findTaxyear];
        
        if (!existingYear.count)
        {
            [[self.userDataDAO getTaxYears] addObject:taxyear];
        }
        else
        {
            TaxYear *existing = existingYear.firstObject;
            
            [localTaxyears removeObject:existing];
        }
    }
    
    //For any local TaxYear that the server doesn't have and isn't marked DataActionInsert,
    //we need to set these to DataActionInsert again so that can be uploaded to the server next time
    for (TaxYear *taxYear in localTaxyears)
    {
        if (taxYear.dataAction != DataActionStatusDataActionInsert)
        {
            taxYear.dataAction = DataActionStatusDataActionInsert;
        }
    }
    
    if (save)
    {
        return [self.userDataDAO saveUserData];
    }
    else
    {
        return YES;
    }
}

@end
