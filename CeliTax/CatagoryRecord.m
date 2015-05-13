//
//  CatagoryRecord.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoryRecord.h"

#define kKeyIdentiferKey            @"Identifer"
#define kKeyDateCreatedKey          @"DateCreated"
#define kKeyItemCatagoryIDKey       @"ItemCatagoryID"
#define kKeyItemCatagoryNameKey     @"ItemCatagoryName"
#define kKeyReceiptIDKey            @"ReceiptID"
#define kKeyAmountKey               @"Amount"
#define kKeyQuantityKey             @"Quantity"

@implementation CatagoryRecord

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.identifer             forKey:kKeyIdentiferKey];
    [coder encodeObject:self.dateCreated            forKey:kKeyDateCreatedKey];
    [coder encodeInteger:self.itemCatagoryID        forKey:kKeyItemCatagoryIDKey];
    [coder encodeObject:self.itemCatagoryName       forKey:kKeyItemCatagoryNameKey];
    [coder encodeInteger:self.receiptID             forKey:kKeyReceiptIDKey];
    [coder encodeFloat:self.amount                  forKey:kKeyAmountKey];
    [coder encodeInteger:self.quantity              forKey:kKeyQuantityKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    self.identifer = [coder decodeIntegerForKey:kKeyIdentiferKey];
    self.dateCreated = [coder decodeObjectForKey:kKeyDateCreatedKey];
    self.itemCatagoryID = [coder decodeIntegerForKey:kKeyItemCatagoryIDKey];
    self.itemCatagoryName = [coder decodeObjectForKey:kKeyItemCatagoryNameKey];
    self.receiptID = [coder decodeIntegerForKey:kKeyReceiptIDKey];
    self.amount = [coder decodeFloatForKey:kKeyAmountKey];
    self.quantity = [coder decodeIntegerForKey:kKeyQuantityKey];
    
    return self;
}

@end
