//
// CatagoryRecord.m
// CeliTax
//
// Created by Leon Chen on 2015-05-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Record.h"

#define kKeyServerID             @"ServerID"
#define kKeyIdentifer            @"Identifer"
#define kKeyDateCreated          @"DateCreated"
#define kKeyCatagoryID           @"CatagoryID"
#define kKeyReceiptID            @"ReceiptID"
#define kKeyAmount               @"Amount"
#define kKeyQuantity             @"Quantity"
#define kKeyDataAction           @"DataAction"

@implementation Record

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInteger: self.serverID forKey: kKeyServerID];
    [coder encodeObject: self.localID forKey: kKeyIdentifer];
    [coder encodeObject: self.dateCreated forKey: kKeyDateCreated];
    [coder encodeObject: self.catagoryID forKey: kKeyCatagoryID];;
    [coder encodeObject: self.receiptID forKey: kKeyReceiptID];
    [coder encodeFloat: self.amount forKey: kKeyAmount];
    [coder encodeInteger: self.quantity forKey: kKeyQuantity];
    [coder encodeInteger:self.dataAction forKey:kKeyDataAction];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];

    self.serverID = [coder decodeIntegerForKey: kKeyServerID];
    self.localID = [coder decodeObjectForKey: kKeyIdentifer];
    self.dateCreated = [coder decodeObjectForKey: kKeyDateCreated];
    self.catagoryID = [coder decodeObjectForKey: kKeyCatagoryID];
    self.receiptID = [coder decodeObjectForKey: kKeyReceiptID];
    self.amount = [coder decodeFloatForKey: kKeyAmount];
    self.quantity = [coder decodeIntegerForKey: kKeyQuantity];
    self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];

    return self;
}

- (id) copyWithZone: (NSZone *) zone
{
    Record *copy = [[[self class] alloc] init];

    if (copy)
    {
        copy.serverID = self.serverID;
        copy.localID = [self.localID copy];
        copy.dateCreated = [self.dateCreated copy];
        copy.catagoryID = [self.catagoryID copy];
        copy.receiptID = [self.receiptID copy];
        copy.amount = self.amount;
        copy.quantity = self.quantity;
        copy.dataAction = self.dataAction;
    }

    return copy;
}

- (float) calculateTotal
{
    return self.quantity * self.amount;
}

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setObject:[NSNumber numberWithInteger:self.serverID] forKey:kKeyServerID];
    
    [json setObject:self.localID forKey:kKeyIdentifer];
    
    //convert self.dateCreated to string
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:self.dateCreated];
    [json setObject:dateString forKey:kKeyDateCreated];
    
    [json setObject:self.catagoryID forKey:kKeyCatagoryID];
    
    [json setObject:self.receiptID forKey:kKeyReceiptID];
    
    [json setObject:[NSNumber numberWithFloat:self.amount] forKey:kKeyAmount];
    
    [json setObject:[NSNumber numberWithInteger:self.quantity] forKey:kKeyQuantity];
    
    [json setObject:[NSNumber numberWithInteger:self.dataAction] forKey:kKeyDataAction];
    
    return json;
}

@end