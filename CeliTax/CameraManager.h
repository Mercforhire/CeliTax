//
//  CameraManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewControllerFactory.h"

@protocol CameraControllerDelegate <NSObject>

@required

-(void)receivedImageFromCamera:(UIImage *)newImage;

@end

@interface CameraManager : NSObject

@property (nonatomic, weak) id<CameraControllerDelegate> delegate;

-(void)readyCamera;

-(void)presentCamera;

- (instancetype)initWithViewController:(UIViewController *)viewController andDelegate:(id)delegate withViewFactory:(ViewControllerFactory *)factory;

@end
