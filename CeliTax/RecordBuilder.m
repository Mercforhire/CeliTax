//
//  RecordBuilder.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "RecordBuilder.h"

#define kKeyIdentifer            @"identifier"
#define kKeyCatagoryID           @"catagoryid"
#define kKeyReceiptID            @"receiptid"
#define kKeyAmount               @"amount"
#define kKeyQuantity             @"quantity"
#define kKeyUnitType             @"unit_type"

@implementation RecordBuilder

- (Record *) buildRecordFrom: (NSDictionary *) json
{
    if (![json isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    Record *record = [[Record alloc] init];
    
    record.localID = json[kKeyIdentifer];
    record.catagoryID = json[kKeyCatagoryID];
    record.receiptID = json[kKeyReceiptID];
    record.amount = [json[kKeyAmount] doubleValue];
    record.quantity = [json[kKeyQuantity] integerValue];
    record.unitType = [json[kKeyUnitType] integerValue];
    
    return record;
}

@end
