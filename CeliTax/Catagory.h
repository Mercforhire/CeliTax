//
//  ItemCatagory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kUnitItemKey            @"UnitItem"
#define kUnitMLKey              @"UnitML"
#define kUnitLKey               @"UnitL"
#define kUnitGKey               @"UnitG"
#define kUnitKGKey              @"UnitKG"

@interface Catagory : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString    *localID;

@property (nonatomic, copy) NSString    *name;
@property (nonatomic, strong) UIColor   *color;

@property (nonatomic, strong) NSMutableDictionary *nationalAverageCosts;

@property (nonatomic, assign) NSInteger dataAction;

- (NSDictionary *) toJson;

-(void)copyDataFromCatagory:(Catagory *)thisOne;

-(void)addOrUpdateNationalAverageCostForUnitType:(NSInteger)unitType amount:(float)amount;

-(void)deleteNationalAverageCostForUnitType:(NSInteger)unitType;

@end
