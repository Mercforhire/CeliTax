//
//  UnitPickerViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-08-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "UnitPickerViewControllerDelegate.h"
#import "CeliTax-Swift.h"

@interface MetricUnitPickerViewController : BaseViewController

@property (nonatomic, weak) id <UnitPickerViewControllerDelegate> delegate;

@property (nonatomic, assign) UnitTypes defaultSelectedUnit;

@property CGSize viewSize;

@end
