//
// Receipt.h
// CeliTax
//
// Created by Leon Chen on 2015-05-06.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RecordsDAO;

@interface Receipt : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *identifer;

@property NSMutableArray *fileNames;

@property (nonatomic, strong) NSDate *dateCreated;

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID usingRecordsDAO: (RecordsDAO *) recordsDAO;

@end