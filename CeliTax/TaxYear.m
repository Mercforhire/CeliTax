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

- (instancetype) initWithCoder: (NSCoder *) coder
{
    if (self = [self init])
    {
        self.taxYear = [coder decodeIntegerForKey: kKeyTaxYear];
        
        self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];
    }
    
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

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    json[kKeyTaxYear] = @(self.taxYear);
    
    json[kKeyDataAction] = @(self.dataAction);
    
    return json;
}

@end
