//
//  FeedbackViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "FeedbackViewController.h"
#import "AlertDialogsProvider.h"

@interface FeedbackViewController ()

@property (weak, nonatomic) IBOutlet UITextView *commentsField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation FeedbackViewController

-(id)init
{
    if (self = [super initWithNibName:@"FeedbackViewController" bundle:nil])
    {
        
        //initialize the slider bar menu button
        UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        menuButton.tintColor = [UIColor colorWithRed:7.0/255 green:61.0/255 blue:48.0/255 alpha:1.0f];
        [menuButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.rightBarButtonItem = menuItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //make pressing on the background cancels any text editing
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    // Create done button for the keyboard
    UIToolbar *_keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56)];
    [_keyboardToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardDoneClicked)];
    [barItems addObject:doneBtn];
    [_keyboardToolbar setItems:barItems animated:YES];
    
    _commentsField.inputAccessoryView = _keyboardToolbar;
}

//slide out the slider bar
- (void)revealSidebar
{

}

-(void)keyboardDoneClicked
{
    [self backgroundTapped];
}

- (void)backgroundTapped
{
    [self.view endEditing:YES];
}

- (IBAction)sendButtonPressed:(UIButton *)sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}


@end
