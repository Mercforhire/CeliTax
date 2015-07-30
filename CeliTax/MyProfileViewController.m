//
//  MyProfileViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-24.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MyProfileViewController.h"
#import "HollowGreenButton.h"
#import "UIView+Helper.h"
#import "UserManager.h"
#import "User.h"
#import "UIView+Helper.h"
#import "TOCropViewController.h"
#import "Utils.h"
#import "UIImage+ResizeMagick.h"

#define kActionSheetTitle           @"Profile Photo"
#define kDestructiveTitle           @"Delete"
#define kOther1Title                @"Take A Photo"
#define kOther2Title                @"Pick from Library"
#define kCancelTitle                @"Cancel"

@interface MyProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TOCropViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *editProfileImageButton;
@property (strong, nonatomic) UIActionSheet *photoActions;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *postalField;

@property (weak, nonatomic) IBOutlet HollowGreenButton *saveButton;

@property (nonatomic) BOOL dirty;

@end

@implementation MyProfileViewController

-(void)setupUI
{
    [self.lookAndFeel applyGrayBorderTo:self.firstnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.firstnameField];
    [self.lookAndFeel applyGrayBorderTo:self.lastnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.lastnameField];
    [self.lookAndFeel applyGrayBorderTo:self.cityField];
    [self.lookAndFeel addLeftInsetToTextField: self.cityField];
    [self.lookAndFeel applyGrayBorderTo:self.postalField];
    [self.lookAndFeel addLeftInsetToTextField: self.postalField];
    
    [self.saveButton setLookAndFeel:self.lookAndFeel];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileImageView.layer.borderWidth = 1.0f;
    [self.profileImageView setClipsToBounds: YES];
}

-(void)loadUserData
{
    [self.profileImageView setImage: self.userManager.user.avatarImage];
    
    [self.firstnameField setText:self.userManager.user.firstname];
    [self.lastnameField setText:self.userManager.user.lastname];
    [self.cityField setText:self.userManager.user.city];
    [self.postalField setText:self.userManager.user.postalCode];
    
    self.dirty = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
 
    [self loadUserData];
    
    [self.firstnameField setDelegate:self];
    [self.firstnameField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];
    
    [self.lastnameField setDelegate:self];
    [self.lastnameField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];
    
    [self.cityField setDelegate:self];
    [self.cityField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];
    
    [self.postalField setDelegate:self];
    [self.postalField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    [self readyCamera];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (void) readyCamera
{
    if (!self.imagePicker)
    {
        [self performSelector: @selector(loadcamera) withObject: nil afterDelay: 0.3];
    }
}

- (void) loadcamera
{
    self.imagePicker = [[UIImagePickerController alloc] init];
}

- (IBAction)editProfilePressed:(UIButton *)sender
{
    //If user has profile image, display ActionSheet with Delete button
    if ([self.userManager doesUserHaveCustomProfileImage])
    {
        self.photoActions = [[UIActionSheet alloc]
                             initWithTitle:kActionSheetTitle
                             delegate:self
                             cancelButtonTitle:kCancelTitle
                             destructiveButtonTitle:kDestructiveTitle
                             otherButtonTitles:kOther1Title, kOther2Title, nil];
    }
    else
    {
        self.photoActions = [[UIActionSheet alloc]
                             initWithTitle:kActionSheetTitle
                             delegate:self
                             cancelButtonTitle:kCancelTitle
                             destructiveButtonTitle:nil
                             otherButtonTitles:kOther1Title, kOther2Title, nil];
    }
    
    
    [self.photoActions showInView:self.view];
    
//    UIImagePickerController *photoPickerController = [[UIImagePickerController alloc] init];
//    photoPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    photoPickerController.allowsEditing = NO;
//    photoPickerController.delegate = self;
//    [self presentViewController:photoPickerController animated:YES completion:nil];
}

- (IBAction)savePressed:(HollowGreenButton *)sender
{
    if (self.dirty)
    {
        [self.userManager changeUserDetails:self.firstnameField.text andLastname:self.lastnameField.text andCity:self.cityField.text andPostalCode:self.postalField.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view scrollToY: 0 - kbSize.height / 2];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

-(void)checkIfFieldsAreChanged
{
    if (![self.firstnameField.text isEqualToString:self.userManager.user.firstname])
    {
        self.dirty = YES;
        
        return;
    }
    
    if (![self.lastnameField.text isEqualToString:self.userManager.user.lastname])
    {
        self.dirty = YES;
        
        return;
    }
    
    if (![self.cityField.text isEqualToString:self.userManager.user.city])
    {
        self.dirty = YES;
        
        return;
    }
    
    if (![self.postalField.text isEqualToString:self.userManager.user.postalCode])
    {
        self.dirty = YES;
        
        return;
    }
    
    self.dirty = NO;
}

#pragma mark - Cropper Delegate 

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    CGRect viewFrame = self.profileImageView.frame;
    viewFrame.origin.y += 64;
    
    [cropViewController dismissAnimatedFromParentViewController:self withCroppedImage:image toFrame:viewFrame completion:^{
        
        [self.userManager setNewAvatarImage:image];
        
        self.profileImageView.image = self.userManager.user.avatarImage;
        
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if  ([buttonTitle isEqualToString:kDestructiveTitle])
    {
        [self.userManager deleteUsersAvatar];
        
        //Reload the image
        [self.profileImageView setImage: self.userManager.user.avatarImage];
    }
    else if ([buttonTitle isEqualToString:kOther1Title])
    {
        //Open up Camera
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            if (self.imagePicker == nil)
            {
                [self loadcamera];
            }
            
            [self.imagePicker setSourceType: UIImagePickerControllerSourceTypeCamera];
            [self.imagePicker setDelegate: self];
            
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
            self.imagePicker.allowsEditing = YES;
            self.imagePicker.showsCameraControls = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self presentViewController: self.imagePicker animated: YES completion:^{
                    
                }];
            });
        }
        else
        {
            //Open up Photo Picker
            if (self.imagePicker == nil)
            {
                self.imagePicker = [[UIImagePickerController alloc] init];
            }
            
            [self.imagePicker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
            [self.imagePicker setDelegate: self];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self presentViewController: self.imagePicker animated: YES completion:^{
                    
                }];
            });
        }
    }
    else if ([buttonTitle isEqualToString:kOther2Title])
    {
        //Open up Photo Picker
        if (self.imagePicker == nil)
        {
            self.imagePicker = [[UIImagePickerController alloc] init];
        }
        
        [self.imagePicker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        [self.imagePicker setDelegate: self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self presentViewController: self.imagePicker animated: YES completion:^{
                
            }];
        });
    }
    
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    //Resize the image here first
    UIImage *resizedImage = [image resizedImageByMagick: @"500"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:resizedImage];
        
        cropController.delegate = self;
        
        [self presentViewController:cropController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (textfield.text.length)
    {
        [self.saveButton setEnabled: YES];
        
        [self checkIfFieldsAreChanged];
    }
    else
    {
        [self.saveButton setEnabled: NO];
    }
}

@end
