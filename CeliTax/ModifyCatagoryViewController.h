//
//  ModifyCatagoryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "ManipulationService.h"
#import "PopUpViewControllerProtocol.h"
#import "CeliTax-Swift.h"

@interface ModifyCatagoryViewController : BaseViewController

@property CGSize viewSize;

@property (nonatomic, weak) id <ManipulationService> manipulationService;

@property (nonatomic, copy) ItemCategory *catagoryToModify;

@property (nonatomic, weak) id <PopUpViewControllerProtocol> delegate;

@end
