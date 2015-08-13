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
    
    record.localID = [json objectForKey: kKeyIdentifer];
    record.catagoryID = [json objectForKey: kKeyCatagoryID];
    record.receiptID = [json objectForKey: kKeyReceiptID];
    record.amount = [[json objectForKey: kKeyAmount] doubleValue];
    record.quantity = [[json objectForKey: kKeyQuantity] integerValue];
    record.unitType = [[json objectForKey: kKeyUnitType] integerValue];
    
    return record;
}

@end
