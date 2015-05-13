//
//  CameraManager.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CameraManager.h"

@interface CameraManager () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *imagePicker;
}

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) ViewControllerFactory *factory;

@end

@implementation CameraManager

- (instancetype)initWithViewController:(UIViewController *)viewController andDelegate:(id)delegate withViewFactory:(ViewControllerFactory *)factory
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.factory = factory;
    }
    return self;
}

-(void)readyCamera
{
    if (!imagePicker)
    {
        [self performSelector:@selector(loadcamera) withObject:nil afterDelay:0.3];
    }
}

- (void)loadcamera
{
    imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
}


-(void)presentCamera
{
    // If our device has a camera, go to the camera view. Otherwise, go to picking from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        if (imagePicker == nil)
        {
            [self loadcamera];
        }
        
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        imagePicker.cameraFlashMode =UIImagePickerControllerCameraFlashModeOff;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = NO;
        
        // important - it needs to be transparent so the camera preview shows through!
//        self.overlayViewController.view.opaque = NO;
//        self.overlayViewController.view.backgroundColor = [UIColor clearColor];
//        
//        [imagePicker.view addSubview:self.overlayViewController.view];
        
        [self.viewController presentViewController:imagePicker animated:YES completion:^{
            //code
        }];
    }
    else
    {
        if (imagePicker == nil)
        {
            [self loadcamera];
        }
        
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [self.viewController presentViewController:imagePicker animated:YES completion:^{
            //code
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSAssert(self.delegate, @"Self.delegate must not be unset");
        [self.delegate receivedImageFromCamera:image];
    }];
}


@end
