//
// Receipt.m
// CeliTax
//
// Created by Leon Chen on 2015-05-06.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Receipt.h"
#import "RecordsDAO.h"

#define kKeyIdentifer       @"Identifer"
#define kKeyFileNames       @"FileNames"
#define kKeyDateCreated     @"DateCreated"
#define kKeyTaxYear         @"TaxYear"

@implementation Receipt

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeObject: self.identifer forKey: kKeyIdentifer];
    [coder encodeObject: self.fileNames forKey: kKeyFileNames];
    [coder encodeObject: self.dateCreated forKey: kKeyDateCreated];
    [coder encodeInteger: self.taxYear forKey: kKeyTaxYear];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];

    self.identifer = [coder decodeObjectForKey: kKeyIdentifer];

    NSArray *fileNames = [coder decodeObjectForKey: kKeyFileNames];
    self.fileNames = [[NSMutableArray alloc] initWithArray: fileNames copyItems: NO];

    self.dateCreated = [coder decodeObjectForKey: kKeyDateCreated];
    
    self.taxYear = [coder decodeIntegerForKey: kKeyTaxYear];

    return self;
}

- (id) copyWithZone: (NSZone *) zone
{
    Receipt *copy = [[[self class] alloc] init];

    if (copy)
    {
        copy.identifer = [self.identifer copy];
        copy.dateCreated = [self.dateCreated copy];
        copy.fileNames = [self.fileNames copy];
        copy.taxYear = self.taxYear;
    }

    return copy;
}

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID usingRecordsDAO: (RecordsDAO *) recordsDAO
{
    NSArray *allRecordsForReceipt = [recordsDAO loadRecordsforReceipt: self.identifer];

    NSPredicate *findRecordsWithGivenCatagoryID = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *recordsWithGivenCatagoryID = [allRecordsForReceipt filteredArrayUsingPredicate: findRecordsWithGivenCatagoryID];

    return recordsWithGivenCatagoryID;
}

@end