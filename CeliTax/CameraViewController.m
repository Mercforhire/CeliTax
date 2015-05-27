//
//  CameraOverlayViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-18.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraSessionView.h"
#import "WhiteBorderView.h"
#import "Utils.h"
#import "User.h"
#import "UserManager.h"
#import "MBProgressHUD.h"

@interface CameraViewController () <CACameraSessionDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraViewFinderView;
@property (weak, nonatomic) IBOutlet UIImageView *previousImageView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topRightCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomRightCornerView;

//these ratios means (coordinate value) / (total available length)
@property float topCropEdgeRatio;
@property float bottomCropEdgeRatio;
@property float leftCropEdgeRatio;
@property float rightCropEdgeRatio;

@property float buttomCornersOriginalYCoordinate;

@property (nonatomic, strong) CameraSessionView *cameraView;

@property (nonatomic) BOOL weAreNotDoneYet; //user not done capturing the whole receipt yet

@property NSMutableArray *takenImageFilenames;
@property NSMutableArray *takenImages;

@property NSInteger nextReceiptID;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setHidden:YES];
    self.navigationItem.hidesBackButton = YES;
    
    // Do any additional setup after loading the view from its nib.
    self.takenImageFilenames = [NSMutableArray new];
    self.takenImages = [NSMutableArray new];
    
    [self.previousImageView setHidden:YES];
    [self.previousImageView setAlpha:0.5f];
    
    [self.topLeftCornerView setRightBorder:NO];
    [self.topLeftCornerView setBottomBorder:NO];
    [self.topLeftCornerView setBorderThickness:2];
    
    [self.topRightCornerView setLeftBorder:NO];
    [self.topRightCornerView setBottomBorder:NO];
    [self.topRightCornerView setBorderThickness:2];
    
    [self.bottomLeftCornerView setTopBorder:NO];
    [self.bottomLeftCornerView setRightBorder:NO];
    [self.bottomLeftCornerView setBorderThickness:2];
    self.buttomCornersOriginalYCoordinate = self.bottomLeftCornerView.frame.origin.y;
    
    [self.bottomRightCornerView setTopBorder:NO];
    [self.bottomRightCornerView setLeftBorder:NO];
    [self.bottomRightCornerView setBorderThickness:2];
    
    //Instantiate the camera view & assign its frame
    _cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    
    //Set the camera view's delegate and add it as a subview
    _cameraView.delegate = self;
    [_cameraView hideDismissButton];
    [_cameraView hideCameraToogleButton];
    [_cameraView setTopBarColor:[UIColor clearColor]];
    
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    [self.view sendSubviewToBack:self.cameraViewFinderView];
    [self.cameraViewFinderView addSubview:_cameraView];
    
    self.topCropEdgeRatio = self.topLeftCornerView.frame.origin.y / self.view.frame.size.height;
    self.leftCropEdgeRatio = self.topLeftCornerView.frame.origin.x / self.view.frame.size.width;
    self.rightCropEdgeRatio = (self.topRightCornerView.frame.origin.x + self.topRightCornerView.frame.size.width) / self.view.frame.size.width;
    [self refreshBottomCropEdgeRatio];
}

-(void)refreshBottomCropEdgeRatio
{
    self.bottomCropEdgeRatio = (self.bottomLeftCornerView.frame.origin.y + self.bottomLeftCornerView.frame.size.height) / self.view.frame.size.height;
    
    //DLog(@"Bottom Y coordinate: %f", self.bottomRightCornerPoint.y);
}

-(void)saveNewReceipt
{
    [self.manipulationService addReceiptForFilenames:self.takenImageFilenames success:^{
        
        DLog(@"addReceiptForUserKey success");
        
    } failure:^(NSString *reason) {
        //should not happen
        DLog(@"saveNewReceipt ERROR");
    }];
}

-(void)exitCamera
{
    [self.cameraView removeFromSuperview];
    
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPressed:(UIButton *)sender
{
    if (self.takenImages.count)
    {
        [self saveNewReceipt];
    }
    
    [self exitCamera];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    
    if (recognizer.view.frame.origin.y + translation.y >= self.topLeftCornerView.frame.origin.y + self.topLeftCornerView.frame.size.height - 20
        &&
        recognizer.view.frame.origin.y + translation.y <= self.cameraViewFinderView.frame.size.height - recognizer.view.frame.size.height)
    {
        self.bottomLeftCornerView.center = CGPointMake(self.bottomLeftCornerView.center.x,
                                             self.bottomLeftCornerView.center.y + translation.y);
        self.bottomRightCornerView.center = CGPointMake(self.bottomRightCornerView.center.x,
                                                       self.bottomRightCornerView.center.y + translation.y);
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    
    //when touch is finished
    if (UIGestureRecognizerStateEnded == [recognizer state])
    {
        //if buttomReceiptView is dragged near the button, change remove its bottom border
        if (recognizer.view.frame.origin.y >= self.cameraViewFinderView.frame.size.height - recognizer.view.frame.size.height - 20)
        {
            [self.bottomLeftCornerView setBottomBorder:NO];
            [self.bottomRightCornerView setBottomBorder:NO];
            
            if (!self.weAreNotDoneYet)
            {
                self.weAreNotDoneYet = YES;
            }
        }
        else
        {
            [self.bottomLeftCornerView setBottomBorder:YES];
            [self.bottomRightCornerView setBottomBorder:YES];
            
            if (self.weAreNotDoneYet)
            {
                self.weAreNotDoneYet = NO;
            }
        }
    }
    
    [self refreshBottomCropEdgeRatio];
}

#pragma mark - CameraManager

-(void)didCaptureImage:(UIImage *)image
{
    NSLog(@"CAPTURED IMAGE");
    
    //crop first
    CGRect cropRectangle = CGRectMake(image.size.width * self.leftCropEdgeRatio,
                                      image.size.height * self.topCropEdgeRatio,
                                      image.size.width * self.rightCropEdgeRatio - image.size.width * self.leftCropEdgeRatio,
                                      image.size.height * self.bottomCropEdgeRatio - image.size.height * self.topCropEdgeRatio);
    
    UIImage *croppedImage = [Utils getCroppedImageUsingRect:cropRectangle forImage:image];
    
    NSString *fileName = [NSString stringWithFormat:@"Receipt-%ld",(long)self.takenImages.count];
    
    NSString *savedFilePath = [Utils saveImage:croppedImage withFilename:fileName forUser:self.userManager.user.userKey];
    
    DLog(@"Image saved to %@", savedFilePath);
    
    [self.takenImageFilenames addObject:fileName];
    [self.takenImages addObject:croppedImage];
    
    if (self.weAreNotDoneYet)
    {
        [self.previousImageView setImage:croppedImage];
        [self.previousImageView setHidden:NO];
        
        [self.bottomLeftCornerView setBottomBorder:YES];
        [self.bottomRightCornerView setBottomBorder:YES];
        
        [self.bottomLeftCornerView setFrame:CGRectMake(self.bottomLeftCornerView.frame.origin.x,
                                                       self.buttomCornersOriginalYCoordinate,
                                                       self.bottomLeftCornerView.frame.size.width,
                                                        self.bottomLeftCornerView.frame.size.height)];
        
        [self.bottomRightCornerView setFrame:CGRectMake(self.bottomRightCornerView.frame.origin.x,
                                                        self.buttomCornersOriginalYCoordinate,
                                                        self.bottomRightCornerView.frame.size.width,
                                                        self.bottomRightCornerView.frame.size.height)];
        self.weAreNotDoneYet = NO;
    }
    else
    {
        //we are done with camera
        if (self.takenImages.count)
        {
            [self saveNewReceipt];
        }
        
        [self exitCamera];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}


@end
