//
//  CatagoryRecord.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    UnitItem,
    UnitML,
    UnitL,
    UnitG,
    Unit100G,
    UnitKG,
    UnitCount
} UnitTypes;

#define kUnitItemKey            @"UnitItem"
#define kUnitMLKey              @"UnitML"
#define kUnitLKey               @"UnitL"
#define kUnitGKey               @"UnitG"
#define kUnit100GKey            @"Unit100G"
#define kUnitKGKey              @"UnitKG"

@interface Record : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString    *localID;

@property (nonatomic, copy) NSString    *catagoryID; // must match an ItemCatagory's localID

@property (nonatomic, copy) NSString    *receiptID; // must match an Receipt's localID

@property float                         amount;

@property NSInteger                     quantity;

@property NSInteger                     unitType; // one of the UnitTypes enum

@property (nonatomic, assign) NSInteger dataAction;

-(float)calculateTotal;

- (NSDictionary *) toJson;

-(void)copyDataFromRecord:(Record *)thisOne;

+ (NSInteger)unitTypeStringToUnitTypeInt:(NSString *)unitTypeString;

+ (NSString *)unitTypeIntToUnitTypeString:(NSInteger)unitTypeInt;

@end
