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

@interface HelpScreenViewController () <UITextViewDelegate>
{
    BOOL justStartedEditing;
}

@property (weak, nonatomic) IBOutlet UITextView *commentField;
@property (weak, nonatomic) IBOutlet HollowGreenButton *sendButton;
@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (strong, nonatomic) MBProgressHUD *waitView;

@end

@implementation HelpScreenViewController

-(void)setupUI
{
    [self.sendButton setLookAndFeel:self.lookAndFeel];
    [self.sendButton setEnabled:NO];
    
    [self.lookAndFeel applyGrayBorderTo:self.commentField];
    
    self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.keyboardToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    [doneToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];
    
    self.keyboardToolbar.items = [NSArray arrayWithObjects:
                                  [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                  doneToolbarButton, nil];
    [self.keyboardToolbar sizeToFit];
    
    self.commentField.inputAccessoryView = self.keyboardToolbar;
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
        self.waitView.labelText = @"Please wait";
        self.waitView.detailsLabelText = @"Sending comment...";
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
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Thank you"
                                                          message:@"Comment has been sent"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok",nil];
        
        [message show];
        
        [self.sendButton setEnabled:YES];
        
        [self.waitView hide: YES];
        
    } failure:^(NSString *reason) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                          message:@"Please try sending again"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok",nil];
        
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
