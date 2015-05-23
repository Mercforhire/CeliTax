//
//  DeleteCatagoryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ManipulationService.h"
#import "BaseViewController.h"
#import "Catagory.h"
#import "PopUpViewControllerProtocol.h"

@interface DeleteCatagoryViewController : BaseViewController

@property CGSize viewSize;

@property (nonatomic, weak) id <ManipulationService> manipulationService;

@property (nonatomic, copy) Catagory *catagoryToDelete;

@property (nonatomic, weak) id <PopUpViewControllerProtocol> delegate;

@end
