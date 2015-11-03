//
//  MyAccountViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "ManipulationService.h"

@class DataService;

@interface CategoryRow : NSObject

@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSString *unitTypeString;

@property (nonatomic) NSInteger totalQtyOrWeight;
@property (nonatomic) float totalAmount;
@property (nonatomic) float nationalAverageCost;

@end

@interface MyAccountViewController : BaseSideBarViewController

@property (nonatomic, weak) DataService *dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

@end
