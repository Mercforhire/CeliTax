//
//  TaxYear.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-15.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "TaxYear.h"

#define kKeyTaxYear         @"TaxYear"
#define kKeyDataAction      @"DataAction"

@implementation TaxYear

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInteger: self.taxYear forKey: kKeyTaxYear];
    [coder encodeInteger:self.dataAction forKey:kKeyDataAction];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];
    
    self.taxYear = [coder decodeIntegerForKey: kKeyTaxYear];
    
    self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];
    
    return self;
}

- (id) copyWithZone: (NSZone *) zone
{
    TaxYear *copy = [[[self class] alloc] init];
    
    if (copy)
    {
        copy.taxYear = self.taxYear;
        copy.dataAction = self.dataAction;
    }
    
    return copy;
}

@end
