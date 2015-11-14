//
//  MyProfileViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-07-24.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ProfileSettingsViewController.h"
#import "HollowGreenButton.h"
#import "TOCropViewController.h"
#import "UIImage+ResizeMagick.h"

#import "CeliTax-Swift.h"

#define kActionSheetTitle           @"Profile Photo"
#define kDestructiveTitle           @"Delete"
#define kOther1Title                @"Take A Photo"
#define kOther2Title                @"Pick from Library"
#define kCancelTitle                @"Cancel"

@interface ProfileSettingsViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TOCropViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *editProfileImageButton;
@property (strong, nonatomic) UIActionSheet *photoActions;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;
@property (weak, nonatomic) IBOutlet UILabel *taxCountryLabel;
@property (weak, nonatomic) IBOutlet UIButton *canadaButton;
@property (weak, nonatomic) IBOutlet UIButton *usaButton;

@property (weak, nonatomic) IBOutlet HollowGreenButton *saveButton;

@property (nonatomic) BOOL dirty;

@property (strong, nonatomic) NSString *country;

@end

@implementation ProfileSettingsViewController

-(void)setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Profile", nil)];
    
    [self.firstNameLabel setText:NSLocalizedString(@"First Name:", nil)];
    [self.lastNameLabel setText:NSLocalizedString(@"Last Name:", nil)];
    [self.taxCountryLabel setText:NSLocalizedString(@"Tax Country", nil)];
    
    [self.lookAndFeel applyGrayBorderTo:self.firstnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.firstnameField];
    [self.lookAndFeel applyGrayBorderTo:self.lastnameField];
    [self.lookAndFeel addLeftInsetToTextField: self.lastnameField];
    
    [self.saveButton setLookAndFeel:self.lookAndFeel];
    [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileImageView.layer.borderWidth = 1.0f;
    [self.profileImageView setClipsToBounds: YES];
    
    UITapGestureRecognizer *profileImageViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(editProfilePressed:)];
    
    [self.profileImageView addGestureRecognizer: profileImageViewTap];
    
    [self.editProfileImageButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
}

-(void)loadUserData
{
    (self.profileImageView).image = self.userManager.user.avatarImage;
    
    (self.firstnameField).text = self.userManager.user.firstname;
    (self.lastnameField).text = self.userManager.user.lastname;
    
    self.country = self.userManager.user.country;
    
    if ([self.country isEqualToString:@"Canada"])
    {
        [self canadaPressed:self.canadaButton];
    }
    else
    {
        [self usaPressed:self.usaButton];
    }
    
    self.dirty = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
 
    [self loadUserData];
    
    (self.firstnameField).delegate = self;
    [self.firstnameField addTarget: self
                           action: @selector(textFieldDidChange:)
                 forControlEvents: UIControlEventEditingChanged];
    
    (self.lastnameField).delegate = self;
    [self.lastnameField addTarget: self
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

- (IBAction)editProfilePressed:(id)sender
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
}

- (IBAction)savePressed:(HollowGreenButton *)sender
{
    if (self.dirty)
    {
        [self.userManager changeUserDetails:self.firstnameField.text lastname:self.lastnameField.text country:self.country];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    if (![self.country isEqualToString:self.userManager.user.country])
    {
        self.dirty = YES;
        
        return;
    }
    
    self.dirty = NO;
}

- (IBAction) canadaPressed: (UIButton *) sender
{
    self.country = @"Canada";
    
    [self checkIfFieldsAreChanged];
}

- (IBAction) usaPressed: (UIButton *) sender
{
    self.country = @"USA";
    
    [self checkIfFieldsAreChanged];
}

- (void) setCountry: (NSString *) country
{
    _country = country;
    
    if ([_country isEqualToString: @"Canada"])
    {
        (self.canadaButton).alpha = 1;
        (self.usaButton).alpha = 0.2;
    }
    else
    {
        (self.canadaButton).alpha = 0.2;
        (self.usaButton).alpha = 1;
    }
}

-(void)setDirty:(BOOL)dirty
{
    _dirty = dirty;
    
    if (_dirty)
    {
        [self.saveButton setEnabled:YES];
    }
    else
    {
        [self.saveButton setEnabled:NO];
    }
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = aNotification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view scrollToY: 0 - kbSize.height / 2];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
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
        (self.profileImageView).image = self.userManager.user.avatarImage;
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
            
            (self.imagePicker).sourceType = UIImagePickerControllerSourceTypeCamera;
            (self.imagePicker).delegate = self;
            
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
            self.imagePicker.allowsEditing = NO;
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
            
            (self.imagePicker).sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            (self.imagePicker).delegate = self;
            
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
        
        (self.imagePicker).sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        (self.imagePicker).delegate = self;
        
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
    textfield.text = (textfield.text).capitalizedString;
    
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
