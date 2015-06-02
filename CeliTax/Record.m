//
//  CatagoryRecord.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Record.h"

#define kKeyIdentiferKey            @"Identifer"
#define kKeyDateCreatedKey          @"DateCreated"
#define kKeyCatagoryIDKey           @"CatagoryID"
#define kKeyCatagoryNameKey         @"CatagoryName"
#define kKeyReceiptIDKey            @"ReceiptID"
#define kKeyAmountKey               @"Amount"
#define kKeyQuantityKey             @"Quantity"

@implementation Record

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.identifer forKey:kKeyIdentiferKey];
	[coder encodeObject:self.dateCreated forKey:kKeyDateCreatedKey];
	[coder encodeObject:self.catagoryID forKey:kKeyCatagoryIDKey];
	[coder encodeObject:self.catagoryName forKey:kKeyCatagoryNameKey];
	[coder encodeObject:self.receiptID forKey:kKeyReceiptIDKey];
	[coder encodeFloat:self.amount forKey:kKeyAmountKey];
	[coder encodeInteger:self.quantity forKey:kKeyQuantityKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];

	self.identifer = [coder decodeObjectForKey:kKeyIdentiferKey];
	self.dateCreated = [coder decodeObjectForKey:kKeyDateCreatedKey];
	self.catagoryID = [coder decodeObjectForKey:kKeyCatagoryIDKey];
	self.catagoryName = [coder decodeObjectForKey:kKeyCatagoryNameKey];
	self.receiptID = [coder decodeObjectForKey:kKeyReceiptIDKey];
	self.amount = [coder decodeFloatForKey:kKeyAmountKey];
	self.quantity = [coder decodeIntegerForKey:kKeyQuantityKey];

	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Record *copy = [[[self class] alloc] init];
    
    if (copy) {
        copy.identifer = [self.identifer copy];
        copy.dateCreated = [self.dateCreated copy];
        copy.catagoryID = [self.catagoryID copy];
        copy.catagoryName = [self.catagoryName copy];
        copy.receiptID = [self.receiptID copy];
        copy.amount = self.amount;
        copy.quantity = self.quantity;
    }
    
    return copy;
}

@end
