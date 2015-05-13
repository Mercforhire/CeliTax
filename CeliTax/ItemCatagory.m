//
//  ItemCatagory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ItemCatagory.h"

#define kKeyIdentiferKey        @"Identifer"
#define kKeyNameKey             @"Name"
#define kKeyColorKey            @"Color"
#define kNationalAverageCostKey @"NationalAverageCost"

@implementation ItemCatagory

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.identifer             forKey:kKeyIdentiferKey];
    
    [coder encodeObject:self.name                   forKey:kKeyNameKey];
    [coder encodeObject:self.color                  forKey:kKeyColorKey];
    
    [coder encodeInteger:self.nationalAverageCost    forKey:kNationalAverageCostKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    self.identifer = [coder decodeIntegerForKey:kKeyIdentiferKey];
    
    self.name = [coder decodeObjectForKey:kKeyNameKey];
    self.color = [coder decodeObjectForKey:kKeyColorKey];
    
    self.nationalAverageCost = [coder decodeIntegerForKey:kNationalAverageCostKey];
    
    return self;
}

@end
