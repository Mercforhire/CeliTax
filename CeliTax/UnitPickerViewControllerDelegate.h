//
//  UnitPickerViewControllerDelegate.h
//  CeliTax
//
//  Created by Leon Chen on 2015-09-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CeliTax-Swift.h"

@protocol UnitPickerViewControllerDelegate <NSObject>

- (void) selectedUnit:(UnitTypes)unitType;

@end
