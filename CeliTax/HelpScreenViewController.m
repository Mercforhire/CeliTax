//
//  HelpScreenViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HelpScreenViewController.h"
#import "AuthenticationService.h"
#import "MBProgressHUD.h"
#import "AlertDialogsProvider.h"
#import "UIView+Helper.h"
#import "HollowGreenButton.h"
#import "TutorialManager.h"
#import "SolidGreenButton.h"

#define KTelephoneNumber        @"905-583-5353"

@interface HelpScreenViewController () <UITextViewDelegate>
{
    BOOL justStartedEditing;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendUsMessageLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *viewTutorialButton;
@property (weak, nonatomic) IBOutlet UITextView *commentField;
@property (weak, nonatomic) IBOutlet UITextView *contactInfoTextView;
@property (weak, nonatomic) IBOutlet HollowGreenButton *sendButton;
@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation HelpScreenViewController

-(void)setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Help", nil)];
    [self.contactLabel setText:NSLocalizedString(@"Contact", nil)];
    [self.sendUsMessageLabel setText:NSLocalizedString(@"Send us a message", nil)];
    
    [self.sendButton setLookAndFeel:self.lookAndFeel];
    [self.sendButton setEnabled:NO];
    [self.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    [self.lookAndFeel applyGrayBorderTo:self.commentField];
    
    [self.viewTutorialButton setLookAndFeel:self.lookAndFeel];
    [self.viewTutorialButton setTitle:NSLocalizedString(@"View Tutorial", nil) forState:UIControlStateNormal];
    
    self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.keyboardToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil) style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    [doneToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    self.keyboardToolbar.items = [NSArray arrayWithObjects:
                                  [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                  doneToolbarButton, nil];
    [self.keyboardToolbar sizeToFit];
    
    self.commentField.inputAccessoryView = self.keyboardToolbar;
    [self.commentField setText:NSLocalizedString(@"Type message", nil)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
    
    [self.commentField setDelegate:self];
    
    justStartedEditing = YES;
}

-(void)doneClicked
{
    [self.commentField resignFirstResponder];
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

- (IBAction)viewTutorialPressed:(UIButton *)sender
{
    [self.tutorialManager setTutorialsAsNotShown];
    
    //go to Main View
    [super selectedMenuIndex:RootViewControllerHome];
}

- (void) createAndShowWaitView
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Sending comment...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }
    
    [self.waitView show: YES];
}

- (IBAction)sendPressed:(UIButton *)sender
{
    [self createAndShowWaitView];
    
    [self.lookAndFeel applyDisabledButtonStyleTo:self.sendButton];
    [self.sendButton setEnabled:NO];
    
    [self.authenticationService sendComment:self.commentField.text
                                    success:^
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank you", nil)
                                                          message:NSLocalizedString(@"Comment has been sent", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
        
        [self.sendButton setEnabled:YES];
        
        [self.waitView hide: YES];
        
    } failure:^(NSString *reason) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"Please try sending again", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
        
        [self.sendButton setEnabled:YES];
        
        [self.waitView hide: YES];
    }];
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view scrollToY: 0 - kbSize.height];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (justStartedEditing)
    {
        textView.text = @"";
        
        justStartedEditing = NO;
        
        [self textViewDidChange:textView];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length)
    {
        [self.sendButton setEnabled:YES];
    }
    else
    {
        [self.sendButton setEnabled:NO];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    
    return YES;
}

@end
