//
//  ReceiptBuilder.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-20.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptBuilder.h"

#define kKeyIdentifer       @"identifier"
#define kKeyFileNames       @"filenames"
#define kKeyDateCreated     @"date_created"
#define kKeyTaxYear         @"tax_year"

@implementation ReceiptBuilder

- (Receipt *) buildReceiptFrom: (NSDictionary *) json
{
    if (![json isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    Receipt *receipt = [[Receipt alloc] init];
    
    receipt.localID = json[kKeyIdentifer];
    receipt.taxYear = [json[kKeyTaxYear] integerValue];
    
    //Filenames
    NSString *filenamesString = json[kKeyFileNames];
    
    NSArray *filenames = [filenamesString componentsSeparatedByString:@","];
    
    receipt.fileNames = [[NSMutableArray alloc] initWithArray: filenames copyItems: NO];
    
    //Data Created
    NSString *dateString = json[kKeyDateCreated];
    
    if (dateString.length)
    {
        NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
        gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSDate *dateCreated = [gmtDateFormatter dateFromString: dateString];
        
        receipt.dateCreated = dateCreated;
    }
    
    return receipt;
}

@end
