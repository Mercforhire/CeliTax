//
// CameraOverlayViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-18.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CameraViewController.h"
#import "WhiteBorderView.h"
#import "Utils.h"
#import "User.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "ConfigurationManager.h"
#import "LLSimpleCamera.h"
#import "UIImage+ResizeMagick.h"
#import "ViewControllerFactory.h"
#import "ReceiptCheckingViewController.h"
#import "FlashButtonView.h"
#import "Receipt.h"
#import "SolidGreenButton.h"
#import "TutorialManager.h"
#import "TutorialStep.h"


@interface CameraViewController () <TutorialManagerDelegate>
{
    NSString *newlyAddedReceiptID;
}

@property (strong, nonatomic) LLSimpleCamera *camera;
@property (weak, nonatomic) IBOutlet UIImageView *previousImageView;
@property (weak, nonatomic) IBOutlet UIView *greenBar;

@property (weak, nonatomic) IBOutlet SolidGreenButton *cancelButton;
@property (weak, nonatomic) IBOutlet SolidGreenButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet FlashButtonView *flashButtonView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *topRightCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomLeftCornerView;
@property (weak, nonatomic) IBOutlet WhiteBorderView *bottomRightCornerView;
@property (weak, nonatomic) IBOutlet UIView *maskViewUnderButtonCornerViews;
@property (weak, nonatomic) IBOutlet UIView *maskViewAboveTopCornerViews;
@property (weak, nonatomic) IBOutlet UIView *dragBarContainer;
@property (weak, nonatomic) IBOutlet UIView *dragBarView;

@property (weak, nonatomic) IBOutlet UIView *dragBarContainer2;
@property (weak, nonatomic) IBOutlet UIView *dragBarView2;

@property (strong, nonatomic) UIView *shutterView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceFromTopToGreenBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMaskHeight;
@property (nonatomic) float distanceFromTopToGreenBarDefaultConstant;
@property (nonatomic) float bottomMaskHeightDefaultConstant;

@property (nonatomic) float distanceFromTopToGreenBarStartingConstant;
@property (nonatomic) float bottomMaskHeightStartingConstant;

// these ratios means (coordinate value) / (total available length)
@property float topCropEdgeRatio;
@property float bottomCropEdgeRatio;
@property float leftCropEdgeRatio;
@property float rightCropEdgeRatio;

@property float buttomCornersOriginalYCoordinate;

@property NSMutableArray *takenImageFilenames;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;

@end

@implementation CameraViewController

#pragma mark - View Setup Functions

-(void)setupUI
{
    [self.navigationBarTitleImageContainer setHidden:YES];
    
    // Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setHidden: YES];
    self.navigationItem.hidesBackButton = YES;
    
    [self.previousImageView setHidden: YES];
    
    [self.dragBarContainer setBackgroundColor:[UIColor clearColor]];
    [self.dragBarContainer2 setBackgroundColor:[UIColor clearColor]];
    
    self.dragBarView.layer.cornerRadius = 4.0f;
    self.dragBarView2.layer.cornerRadius = 4.0f;
    
    [self.topLeftCornerView setRightBorder: NO];
    [self.topLeftCornerView setBottomBorder: NO];
    [self.topLeftCornerView setBorderThickness: 2];
    [self.topLeftCornerView setMargin:7.5f];
    [self.topLeftCornerView setBackgroundColor: [UIColor clearColor]];
    
    [self.topRightCornerView setLeftBorder: NO];
    [self.topRightCornerView setBottomBorder: NO];
    [self.topRightCornerView setBorderThickness: 2];
    [self.topRightCornerView setMargin:7.5f];
    [self.topRightCornerView setBackgroundColor: [UIColor clearColor]];
    
    [self.bottomLeftCornerView setTopBorder: NO];
    [self.bottomLeftCornerView setRightBorder: NO];
    [self.bottomLeftCornerView setBorderThickness: 2];
    [self.bottomLeftCornerView setMargin:7.5f];
    [self.bottomLeftCornerView setBackgroundColor: [UIColor clearColor]];
    self.buttomCornersOriginalYCoordinate = self.bottomLeftCornerView.frame.origin.y;
    
    [self.bottomRightCornerView setTopBorder: NO];
    [self.bottomRightCornerView setLeftBorder: NO];
    [self.bottomRightCornerView setBorderThickness: 2];
    [self.bottomRightCornerView setMargin:7.5f];
    [self.bottomRightCornerView setBackgroundColor: [UIColor clearColor]];

    [self refreshCropEdgeRatio];
    
    [self.cancelButton setLookAndFeel:self.lookAndFeel];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.continueButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.continueButton setLookAndFeel:self.lookAndFeel];
    
    // snap button to capture image
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget: self action: @selector(snapButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    // button to toggle flash
    [self.flashButtonView.flashButton addTarget: self action: @selector(flashButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    // Instantiate the camera view & assign its frame
    self.camera = [[LLSimpleCamera alloc] initWithQuality: AVCaptureSessionPresetHigh
                                                 position: CameraPositionBack
                                             videoEnabled: NO];
    // attach to the view
    [self.camera attachToViewController: self withFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    
    [self.camera setOnDeviceChange: ^(LLSimpleCamera *camera, AVCaptureDevice *device)
    {
        // device changed, check if flash is available
        if ([camera isFlashAvailable])
        {
            weakSelf.flashButtonView.hidden = NO;
            
            if (camera.flash == CameraFlashOff)
            {
                weakSelf.flashButtonView.on = NO;
            }
            else
            {
                weakSelf.flashButtonView.on = YES;
            }
        }
        else
        {
            weakSelf.flashButtonView.hidden = YES;
        }
    }];
    
    [self.camera setOnError: ^(LLSimpleCamera *camera, NSError *error)
    {
        NSLog(@"Camera error: %@", error);
        
        if ([error.domain isEqualToString: LLSimpleCameraErrorDomain])
        {
            if (error.code == LLSimpleCameraErrorCodeCameraPermission ||
                error.code == LLSimpleCameraErrorCodeMicrophonePermission)
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                  message:NSLocalizedString(@"We need permission for the camera.\nPlease enable it in your settings.", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
                
                [message show];
            }
        }
    }];
    
    self.shutterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.shutterView setOpaque:NO];
    [self.shutterView setBackgroundColor:[UIColor whiteColor]];
    [self.shutterView setUserInteractionEnabled:NO];
    [self.shutterView setHidden:YES];
    
    [self.view addSubview:self.shutterView];
}

-(void)initAndSetupCamera
{
    [self.view sendSubviewToBack: self.camera.view];
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    [self initAndSetupCamera];
    
    self.takenImageFilenames = [NSMutableArray new];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.navigationBarTitleImageContainer setHidden:YES];
    
    // Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setHidden: YES];
    self.navigationItem.hidesBackButton = YES;
    
    // start the camera
    [self.camera start];
    
    self.distanceFromTopToGreenBarDefaultConstant = self.distanceFromTopToGreenBar.constant;
    
    self.bottomMaskHeightDefaultConstant = self.bottomMaskHeight.constant;
    
    //Load the last image from the existing Receipt
    if (self.existingReceiptID)
    {
        Receipt *receipt = [self.dataService fetchReceiptForReceiptID:self.existingReceiptID];
        
        if (receipt.fileNames.count)
        {
            UIImage *image = [Utils readImageWithFileName: receipt.fileNames.lastObject forUser: self.userManager.user.userKey];
            
            if (image)
            {
                [self addImageToPreviousImageView:image];
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime])
    {
        [self setupTutorials];
        
        if (self.tutorialManager.currentStep == 9)
        {
            [self displayTutorialStep:TutorialStep9];
        }
    }
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];

    // stop the camera
    [self.camera stop];
    
    [self.navigationBarTitleImageContainer setHidden:NO];
}

#pragma mark - View Controller Functions

- (void) refreshCropEdgeRatio
{
    self.topCropEdgeRatio = self.topLeftCornerView.frame.origin.y / self.view.frame.size.height;
    self.leftCropEdgeRatio = self.topLeftCornerView.frame.origin.x / self.view.frame.size.width;
    self.rightCropEdgeRatio = (self.topRightCornerView.frame.origin.x + self.topRightCornerView.frame.size.width) / self.view.frame.size.width;
    self.bottomCropEdgeRatio = (self.bottomLeftCornerView.frame.origin.y + self.bottomLeftCornerView.frame.size.height) / self.view.frame.size.height;
}

-(void)addImageToPreviousImageView:(UIImage *)image
{
    float ratio = image.size.height / image.size.width;
    
    self.imageViewHeight.constant = self.previousImageView.frame.size.width * ratio;
    
    //reset Constrains
    self.bottomMaskHeight.constant = self.bottomMaskHeightDefaultConstant;
    self.distanceFromTopToGreenBar.constant = self.distanceFromTopToGreenBarDefaultConstant;
    
    [self.previousImageView setImage: image];
    [self.previousImageView setHidden: NO];
    [self.greenBar setHidden: NO];
    [self.dragBarContainer2 setHidden:NO];
    [self.maskViewAboveTopCornerViews setHidden:YES];
    
    [self.bottomLeftCornerView setBottomBorder: YES];
    [self.bottomRightCornerView setBottomBorder: YES];
    
    [self.bottomLeftCornerView setFrame: CGRectMake(self.bottomLeftCornerView.frame.origin.x,
                                                    self.buttomCornersOriginalYCoordinate,
                                                    self.bottomLeftCornerView.frame.size.width,
                                                    self.bottomLeftCornerView.frame.size.height)];
    
    [self.bottomRightCornerView setFrame: CGRectMake(self.bottomRightCornerView.frame.origin.x,
                                                     self.buttomCornersOriginalYCoordinate,
                                                     self.bottomRightCornerView.frame.size.width,
                                                     self.bottomRightCornerView.frame.size.height)];
}

-(void)captureCamera
{
    [self.view setUserInteractionEnabled:NO];
    
    // capture
    [self.camera capture: ^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if (!error)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^() {
                
                // crop first
                CGRect cropRectangle = CGRectMake(image.size.width * self.leftCropEdgeRatio,
                                                  image.size.height * self.topCropEdgeRatio,
                                                  image.size.width * self.rightCropEdgeRatio - image.size.width * self.leftCropEdgeRatio,
                                                  image.size.height * self.bottomCropEdgeRatio - image.size.height * self.topCropEdgeRatio);
                
                UIImage *croppedImage = [Utils getCroppedImageUsingRect: cropRectangle forImage: image];
                
                UIImage *resizedImage = [croppedImage resizedImageByMagick: @"400"];
                
                NSString *fileName = [NSString stringWithFormat: @"Receipt-%@-%ld", [Utils generateUniqueID], (long)self.takenImageFilenames.count];
                
                NSString *savedFilePath = [Utils saveImage: resizedImage withFilename: fileName forUser: self.userManager.user.userKey];
                
                DLog(@"Image saved to %@", savedFilePath);
                
                [self.takenImageFilenames addObject: fileName];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [self addImageToPreviousImageView:resizedImage];
                    
                    [self.continueButton setEnabled:YES];
                    
                    [self.view setUserInteractionEnabled:YES];
                    
                    [self.view setNeedsUpdateConstraints];
                    
                    [self.camera start];
                    
                });
                
            });
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                              message:NSLocalizedString(@"An error has occured with the camere device, please try taking a picture again", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
            
            [message show];
            
            [self.view setUserInteractionEnabled:YES];
        }
    } exactSeenImage: YES];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Button press events

- (void) flashButtonPressed: (UIButton *) button
{
    if (self.camera.flash == CameraFlashOff)
    {
        BOOL done = [self.camera updateFlashMode: CameraFlashOn];
        
        if (done)
        {
            self.flashButtonView.on = YES;
        }
    }
    else
    {
        BOOL done = [self.camera updateFlashMode: CameraFlashOff];
        
        if (done)
        {
            self.flashButtonView.on = NO;
        }
    }
}

- (void) snapButtonPressed: (UIButton *) button
{
    [self.shutterView setHidden:NO];
    [self.shutterView setAlpha:0.0f];
    
    //fade in
    [UIView animateWithDuration:0.1f animations:^{
        
        [self.shutterView setAlpha:0.8f];
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:0.1f animations:^{
            
            [self.shutterView setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            [self.shutterView setHidden:YES];
            
        }];
        
    }];
    
    [self performSelector:@selector(captureCamera) withObject:nil afterDelay:0];
}

- (IBAction) cancelPressed: (UIButton *) sender
{
    [self.camera updateFlashMode: CameraFlashOff];
    
    [self.camera stop];
    
    for (NSString *filename in self.takenImageFilenames)
    {
        [Utils deleteImageWithFileName:filename forUser:self.userManager.user.userKey];
    }
    
    [self.navigationController.navigationBar setHidden: NO];
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)continuePressed:(UIButton *)sender
{
    [self.camera updateFlashMode: CameraFlashOff];
    
    [self.camera stop];
    
    [self.navigationController.navigationBar setHidden: NO];
    
    //saving a new receipt
    if (!self.existingReceiptID)
    {
       NSString *newestReceiptID = [self.manipulationService addReceiptForFilenames: self.takenImageFilenames
                                                                          andTaxYear: [self.configurationManager getCurrentTaxYear].integerValue
                                                                                save:YES];
        
        if (newestReceiptID)
        {
            newlyAddedReceiptID = newestReceiptID;
            
            ReceiptCheckingViewController *receiptCheckingViewController = [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID:newlyAddedReceiptID cameFromReceiptBreakDownViewController:NO];
            
            // push the new viewController
            [self.navigationController pushViewController: receiptCheckingViewController animated: YES];
            
            // remove self viewController
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray: self.navigationController.viewControllers];
            
            [viewControllers removeObject: self];
            
            // Assign the updated stack with animation
            [self.navigationController setViewControllers: viewControllers animated: NO];
        }
    }
    
    //adding the photos taken to an existing receipt
    else
    {
        Receipt *receipt = [self.dataService fetchReceiptForReceiptID:self.existingReceiptID];
        
        [receipt.fileNames addObjectsFromArray:self.takenImageFilenames];
        
        [self.manipulationService modifyReceipt:receipt save:YES];
        
        [self.navigationController popViewControllerAnimated: YES];
    }
}


- (IBAction) dragBarPan: (UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView: self.view];
    
    switch ([recognizer state])
    {
        case UIGestureRecognizerStateBegan:
            //DLog(@"Dragging started with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            self.bottomMaskHeightStartingConstant = self.bottomMaskHeight.constant;
            [self.dragBarView setBackgroundColor:self.lookAndFeel.appGreenColor];
            break;
            
        case UIGestureRecognizerStateChanged:
            //DLog(@"Dragging with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            
            //don't let self.bottomMaskHeight.constant drop below self.bottomMaskHeightDefaultConstant
            //nor let it grow larger than (self.view.frame.size.height - self.distanceFromTopToGreenBar.constant -self.topLeftCornerView.frame.size.height - self.dragBarContainer.frame.size.height)
            if ( self.bottomMaskHeightDefaultConstant <= (self.bottomMaskHeightStartingConstant - translation.y) &&
                (self.bottomMaskHeightStartingConstant - translation.y) < (self.view.frame.size.height - self.distanceFromTopToGreenBar.constant - self.topLeftCornerView.frame.size.height - self.dragBarContainer.frame.size.height/2) )
            {
                self.bottomMaskHeight.constant = self.bottomMaskHeightStartingConstant - translation.y;
                [self.view setNeedsUpdateConstraints];
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            //DLog(@"Dragging completed with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            [self refreshCropEdgeRatio];
            [self.dragBarView setBackgroundColor:[UIColor whiteColor]];
            break;
            
        default:
            break;
    }
}

- (IBAction)imageViewPan: (UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView: self.view];
    
    switch ([recognizer state])
    {
        case UIGestureRecognizerStateBegan:
            //DLog(@"Dragging started with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            self.distanceFromTopToGreenBarStartingConstant = self.distanceFromTopToGreenBar.constant;
            [self.dragBarView2 setBackgroundColor:self.lookAndFeel.appGreenColor];
            break;
            
        case UIGestureRecognizerStateChanged:
            //DLog(@"Dragging with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            
            if ( self.distanceFromTopToGreenBarDefaultConstant <= (self.distanceFromTopToGreenBarStartingConstant + translation.y) &&
                (self.distanceFromTopToGreenBarStartingConstant + translation.y) < (self.view.frame.size.height - self.bottomMaskHeight.constant - self.distanceFromTopToGreenBarDefaultConstant) &&
                (self.distanceFromTopToGreenBarStartingConstant + translation.y) < (self.imageViewHeight.constant - self.distanceFromTopToGreenBarDefaultConstant) )
            {
                self.distanceFromTopToGreenBar.constant = self.distanceFromTopToGreenBarStartingConstant + translation.y;
                [self.view setNeedsUpdateConstraints];
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            //DLog(@"Dragging completed with translation of X: %.1f, YL %.1f", translation.x, translation.y);
            [self refreshCropEdgeRatio];
            [self.dragBarView2 setBackgroundColor:[UIColor whiteColor]];
            break;
            
        default:
            break;
    }
}

#pragma mark - Tutorial

typedef enum : NSUInteger
{
    TutorialStep9,
    TutorialStep10
} TutorialSteps;

-(void)setupTutorials
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep9 = [TutorialStep new];
    
    tutorialStep9.text = NSLocalizedString(@"Use the crop feature to custom fit the photo to the size of your receipt.", nil);
    tutorialStep9.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep9.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep9.pointsUp = NO;
    tutorialStep9.highlightedItemRect = self.dragBarContainer.frame;
    
    [self.tutorials addObject:tutorialStep9];
    
    TutorialStep *tutorialStep10 = [TutorialStep new];
    
    tutorialStep10.text = NSLocalizedString(@"Receipt too long? Take multiple photos to capture the entire receipt. After a photo is taken, it can be used as a guide for your next photo by simply pulling down the green bar.", nil);
    tutorialStep10.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep10.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep10.pointsUp = YES;
    tutorialStep10.highlightedItemRect = self.dragBarContainer2.frame;
    
    [self.tutorials addObject:tutorialStep10];
}

-(void)displayTutorialStep:(NSInteger)step
{
    if (self.tutorials.count && step < self.tutorials.count)
    {
        TutorialStep *tutorialStep = [self.tutorials objectAtIndex:step];
        
        [self.tutorialManager displayTutorialInViewController:self andTutorial:tutorialStep];
    }
}

- (void) tutorialLeftSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 9:
        {
            //Go back to Step 8 in Main view
            self.tutorialManager.currentStep = 8;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self.navigationController.navigationBar setHidden: NO];
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
            break;
            
        case 10:
            //Go back to Step 9
            self.tutorialManager.currentStep = 9;
            [self displayTutorialStep:TutorialStep9];
            break;
            
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 9:
        {
            //Go to Step 10
            self.tutorialManager.currentStep = 10;
            
            if (!self.takenImageFilenames.count)
            {
                //Add some sample image
                UIImage *testImage2 = [UIImage imageNamed: @"ReceiptPic-2.jpg"];
                
                [self.takenImageFilenames addObject: @"demo.jpg"];
                
                [self addImageToPreviousImageView:testImage2];
                
                [self.continueButton setEnabled:YES];
                
                [self.view setNeedsUpdateConstraints];
            }
            
            [self displayTutorialStep:TutorialStep10];
        }
            break;
            
        case 10:
        {
            //Go to Step 11 in Receipt Checking view without actually saving a receipt
            self.tutorialManager.currentStep = 11;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            
            [self.camera updateFlashMode: CameraFlashOff];
            
            ReceiptCheckingViewController *receiptCheckingViewController = [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID:nil cameFromReceiptBreakDownViewController:NO];
            
            [self.tutorialManager dismissTutorial:^{
                [self.navigationController.navigationBar setHidden: NO];
                
                // push the new viewController
                [self.navigationController pushViewController: receiptCheckingViewController animated: YES];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end