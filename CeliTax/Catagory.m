//
//  ItemCatagory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Catagory.h"

#define kKeyIdentiferKey        @"Identifer"
#define kKeyNameKey             @"Name"
#define kKeyColorKey            @"Color"
#define kNationalAverageCostKey @"NationalAverageCost"

@implementation Catagory

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.identifer forKey:kKeyIdentiferKey];

	[coder encodeObject:self.name forKey:kKeyNameKey];
	[coder encodeObject:self.color forKey:kKeyColorKey];

	[coder encodeInteger:self.nationalAverageCost forKey:kNationalAverageCostKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];

	self.identifer = [coder decodeObjectForKey:kKeyIdentiferKey];

	self.name = [coder decodeObjectForKey:kKeyNameKey];
	self.color = [coder decodeObjectForKey:kKeyColorKey];

	self.nationalAverageCost = [coder decodeIntegerForKey:kNationalAverageCostKey];

	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	Catagory *copy = [[[self class] alloc] init];

	if (copy) {
		copy.identifer = [self.identifer copy];
		copy.name = [self.name copy];
		copy.color = [self.color copy];
		copy.nationalAverageCost = self.nationalAverageCost;
	}

	return copy;
}

@end
