//
//  MainViewTableDataModel.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-30.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainViewTableDataModel.h"

@implementation MainViewTableDataModel

- (id) init
{
    self = [super init];
    
    self.availableTaxYears = [[NSMutableArray alloc] init];
    
    return self;
}

@end
