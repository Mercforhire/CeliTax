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

@property (nonatomic, copy) NSString *localID;

@property NSMutableArray *fileNames;

@property (nonatomic, strong) NSDate *dateCreated;

@property (nonatomic) NSInteger taxYear;

@property (nonatomic, assign) NSInteger dataAction;

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID
                     usingRecordsDAO: (RecordsDAO *) recordsDAO;

- (NSArray *) fetchRecordsOfCatagory: (NSString *) catagoryID
                          ofUnitType: (NSInteger)unitType
                     usingRecordsDAO: (RecordsDAO *) recordsDAO;

- (NSDictionary *) toJson;

-(void)copyDataFromReceipt:(Receipt *)thisOne;

@end