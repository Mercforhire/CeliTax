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
#define kKeyCatagoryIDKey       @"CatagoryID"
#define kKeyCatagoryNameKey     @"CatagoryName"
#define kKeyReceiptIDKey            @"ReceiptID"
#define kKeyAmountKey               @"Amount"
#define kKeyQuantityKey             @"Quantity"

@implementation Record

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.identifer             forKey:kKeyIdentiferKey];
    [coder encodeObject:self.dateCreated            forKey:kKeyDateCreatedKey];
    [coder encodeInteger:self.catagoryID            forKey:kKeyCatagoryIDKey];
    [coder encodeObject:self.catagoryName           forKey:kKeyCatagoryNameKey];
    [coder encodeInteger:self.receiptID             forKey:kKeyReceiptIDKey];
    [coder encodeFloat:self.amount                  forKey:kKeyAmountKey];
    [coder encodeInteger:self.quantity              forKey:kKeyQuantityKey];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    self.identifer = [coder decodeIntegerForKey:kKeyIdentiferKey];
    self.dateCreated = [coder decodeObjectForKey:kKeyDateCreatedKey];
    self.catagoryID = [coder decodeIntegerForKey:kKeyCatagoryIDKey];
    self.catagoryName = [coder decodeObjectForKey:kKeyCatagoryNameKey];
    self.receiptID = [coder decodeIntegerForKey:kKeyReceiptIDKey];
    self.amount = [coder decodeFloatForKey:kKeyAmountKey];
    self.quantity = [coder decodeIntegerForKey:kKeyQuantityKey];
    
    return self;
}

@end
