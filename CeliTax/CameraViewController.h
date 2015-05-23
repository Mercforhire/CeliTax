//
//  CameraOverlayViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-18.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ManipulationService.h"

@interface CameraViewController : BaseViewController

@property (nonatomic, weak) id <ManipulationService> manipulationService;

@end
