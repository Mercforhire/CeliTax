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
/*
 Tell its delegate that an image has been captured
 */
@protocol CameraControllerDelegate <NSObject>

@required

- (void) hasJustCreatedNewReceipt;

@end

@interface CameraViewController : BaseViewController

@property (nonatomic, weak) id <ManipulationService> manipulationService;

@property (nonatomic, weak) id <CameraControllerDelegate> delegate;

@end