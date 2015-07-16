//
// Receipt.m
// CeliTax
//
// Created by Leon Chen on 2015-05-06.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "Receipt.h"
#import "RecordsDAO.h"

#define kKeyServerID        @"ServerID"
#define kKeyIdentifer       @"Identifer"
#define kKeyFileNames       @"FileNames"
#define kKeyDateCreated     @"DateCreated"
#define kKeyTaxYear         @"TaxYear"
#define kKeyDataAction      @"DataAction"

@implementation Receipt

- (void) encodeWithCoder: (NSCoder *) coder
{
    [coder encodeInteger: self.serverID forKey: kKeyServerID];
    [coder encodeObject: self.localID forKey: kKeyIdentifer];
    [coder encodeObject: self.fileNames forKey: kKeyFileNames];
    [coder encodeObject: self.dateCreated forKey: kKeyDateCreated];
    [coder encodeInteger: self.taxYear forKey: kKeyTaxYear];
    [coder encodeInteger:self.dataAction forKey:kKeyDataAction];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];

    self.serverID = [coder decodeIntegerForKey: kKeyServerID];
    
    self.localID = [coder decodeObjectForKey: kKeyIdentifer];

    NSArray *fileNames = [coder decodeObjectForKey: kKeyFileNames];
    self.fileNames = [[NSMutableArray alloc] initWithArray: fileNames copyItems: NO];

    self.dateCreated = [coder decodeObjectForKey: kKeyDateCreated];
    
    self.taxYear = [coder decodeIntegerForKey: kKeyTaxYear];
    
    self.dataAction = [coder decodeIntegerForKey:kKeyDataAction];

    return self;
}

- (id) copyWithZone: (NSZone *) zone
{
    Receipt *copy = [[[self class] alloc] init];

    if (copy)
    {
        copy.serverID = self.serverID;
        copy.localID = [self.localID copy];
        copy.dateCreated = [self.dateCreated copy];
        copy.fileNames = [self.fileNames copy];
        copy.taxYear = self.taxYear;
        copy.dataAction = self.dataAction;
    }

    return copy;
}

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID usingRecordsDAO: (RecordsDAO *) recordsDAO
{
    NSArray *allRecordsForReceipt = [recordsDAO loadRecordsforReceipt: self.localID];

    NSPredicate *findRecordsWithGivenCatagoryID = [NSPredicate predicateWithFormat: @"catagoryID == %@", catagoryID];
    NSArray *recordsWithGivenCatagoryID = [allRecordsForReceipt filteredArrayUsingPredicate: findRecordsWithGivenCatagoryID];

    return recordsWithGivenCatagoryID;
}

- (NSDictionary *) toJson
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setObject:[NSNumber numberWithInteger:self.serverID] forKey:kKeyServerID];
    
    [json setObject:self.localID forKey:kKeyIdentifer];
    
    NSMutableArray *filenamesJSONs = [NSMutableArray new];
    for (NSString *filename in self.fileNames)
    {
        [filenamesJSONs addObject:filename];
    }
    [json setObject:filenamesJSONs forKey:kKeyFileNames];
    
    //convert self.dateCreated to string
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:self.dateCreated];
    [json setObject:dateString forKey:kKeyDateCreated];
    
    [json setObject:[NSNumber numberWithInteger:self.taxYear] forKey:kKeyTaxYear];
    
    [json setObject:[NSNumber numberWithInteger:self.dataAction] forKey:kKeyDataAction];
    
    return json;
}

@end