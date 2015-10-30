//
// AddCatagoryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AddCatagoryViewController.h"
#import "Catagory.h"
#import "UserManager.h"
#import "User.h"
#import "DataService.h"
#import "SelectionsPickerViewController.h"
#import "ColorPickerViewController.h"
#import "AllColorsPickerViewController.h"
#import "ViewControllerFactory.h"
#import "WYPopoverController.h"
#import "CatagoryTableViewCell.h"
#import "ModifyCatagoryTableViewCell.h"
#import "ModifyCatagoryViewController.h"
#import "UIView+Helper.h"
#import "TutorialManager.h"
#import "TutorialStep.h"
#import "ConfigurationManager.h"
#import "SolidGreenButton.h"

@interface AddCatagoryViewController () <SelectionsPickerPopUpDelegate, ColorPickerViewPopUpDelegate, UIPopoverControllerDelegate, AllColorsPickerViewPopUpDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, PopUpViewControllerProtocol, TutorialManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UITextField *catagoryNameField;
@property (nonatomic, strong) UIButton *nameFieldOverlayButton;
@property (nonatomic, strong) SolidGreenButton *saveButton;
@property (nonatomic, strong) UIBarButtonItem *rightMenuItem;
@property (weak, nonatomic) IBOutlet UIButton *addCatagoryButton;
@property (weak, nonatomic) IBOutlet UITableView *catagoriesTable;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *leftMenuItem;

@property (nonatomic, strong) NSMutableArray *sampleCatagoryNames;
@property (nonatomic, strong) NSMutableArray *catagories;
@property (nonatomic, strong) NSMutableArray *catagoryNames;

@property (nonatomic, strong) WYPopoverController *namesPickerPopover;
@property (nonatomic, strong) SelectionsPickerViewController *namesPickerViewController;

@property (nonatomic, strong) WYPopoverController *colorPickerPopover;
@property (nonatomic, strong) ColorPickerViewController *colorPickerViewController;

@property (nonatomic, strong) WYPopoverController *allColorsPickerPopover;
@property (nonatomic, strong) AllColorsPickerViewController *allColorsPickerViewController;

@property (nonatomic, strong) WYPopoverController *catagoryPickerPopover;
@property (nonatomic, strong) SelectionsPickerViewController *catagoryPickerViewController;

@property (nonatomic, strong) WYPopoverController *modifyCatagoryPickerPopover;
@property (nonatomic, strong) ModifyCatagoryViewController *modifyCatagoryViewController;

// set to true when user is actively adding a new catagory
@property (nonatomic) BOOL addingCatagoryMode;

@property (nonatomic, strong) Catagory *currentlySelectedCatagory;

@property (nonatomic, strong) Catagory *catagoryToTransferTo;

@property (nonatomic, strong) UIColor *colorBeingAddedOrEdited;

@property (nonatomic, strong) NSString *nameOfCategoryBeingAddedOrEdited;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;

@end

#define kCatagoryTableViewCellHeight                    45
#define kCatagoryTableViewCellIdentifier                @"CatagoryTableViewCell"

#define kModifyCatagoryTableViewCellHeight              62
#define kModifyCatagoryTableViewCellIdentifier          @"ModifyCatagoryTableViewCell"

@implementation AddCatagoryViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Manage Categories", nil)];
    [self.catagoryNameField setPlaceholder:NSLocalizedString(@"Enter Catagory Name",nil)];
    
    self.sampleCatagoryNames = [NSMutableArray new];

    // sample names
    [self.sampleCatagoryNames addObject: NSLocalizedString(@"Bread", nil)];
    [self.sampleCatagoryNames addObject: NSLocalizedString(@"Rice", nil)];
    [self.sampleCatagoryNames addObject: NSLocalizedString(@"Cake", nil)];
    [self.sampleCatagoryNames addObject: NSLocalizedString(@"Meat", nil)];
    [self.sampleCatagoryNames addObject: NSLocalizedString(@"Pizza", nil)];
    [self.sampleCatagoryNames addObject: NSLocalizedString(@"Custom", nil)];

    self.colorPickerViewController = [self.viewControllerFactory createColorPickerViewController];

    self.namesPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: self.sampleCatagoryNames];
    self.namesPickerViewController.highlightedSelectionIndex = self.sampleCatagoryNames.count - 1;
    self.allColorsPickerViewController = [self.viewControllerFactory createAllColorsPickerViewController];

    self.nameFieldOverlayButton = [[UIButton alloc] initWithFrame: self.catagoryNameField.frame];
    [self.view addSubview: self.nameFieldOverlayButton];

    // initialize the Save menu button button
    self.saveButton = [[SolidGreenButton alloc] initWithFrame: CGRectMake(0, 0, 50, 25)];
    [self.saveButton setTitle: NSLocalizedString(@"Save", nil) forState: UIControlStateNormal];
    (self.saveButton.titleLabel).font = [UIFont latoBoldFontOfSize: 14];
    (self.saveButton).titleEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    [self.saveButton addTarget: self action: @selector(saveCatagoryPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self.saveButton setLookAndFeel:self.lookAndFeel];

    self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.saveButton];
    self.navigationItem.rightBarButtonItem = self.rightMenuItem;
    [self.rightMenuItem setEnabled:NO];

    [self.lookAndFeel applyGrayBorderTo: self.catagoryNameField];
    [self.lookAndFeel addLeftInsetToTextField: self.catagoryNameField];

    UINib *catagoryTableViewCell = [UINib nibWithNibName: @"CatagoryTableViewCell" bundle: nil];
    UINib *modifyCatagoryTableViewCell = [UINib nibWithNibName: @"ModifyCatagoryTableViewCell" bundle: nil];

    [self.catagoriesTable registerNib: catagoryTableViewCell forCellReuseIdentifier: kCatagoryTableViewCellIdentifier];
    [self.catagoriesTable registerNib: modifyCatagoryTableViewCell forCellReuseIdentifier: kModifyCatagoryTableViewCellIdentifier];

    (self.colorView).backgroundColor = [UIColor whiteColor];
    [self.lookAndFeel applySlightlyDarkerBorderTo: self.colorView];

    // initialize the Cancel menu button button
    self.cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
    [self.cancelButton setImage:[UIImage imageNamed:@"xIcon.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget: self action: @selector(cancelEditing) forControlEvents: UIControlEventTouchUpInside];
    [self.lookAndFeel applyTransperantWhiteTextButtonStyleTo:self.cancelButton];
    
    self.leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancelButton];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    (self.colorPickerViewController).delegate = self;
    (self.namesPickerViewController).delegate = self;
    (self.allColorsPickerViewController).delegate = self;

    UITapGestureRecognizer *colorBoxPressedTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(colorBoxPressed)];
    [self.colorView addGestureRecognizer: colorBoxPressedTap];

    self.catagoryNameField.delegate = self;
    [self.catagoryNameField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];

    [self.nameFieldOverlayButton addTarget: self action: @selector(textBoxPressed) forControlEvents: UIControlEventTouchUpInside];

    // run its setter
    self.addingCatagoryMode = NO;

    self.catagoriesTable.dataSource = self;
    self.catagoriesTable.delegate = self;

    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime])
    {
        self.catagories = [NSMutableArray new];
        
        Catagory *sampleCategory1 = [Catagory new];
        sampleCategory1.name = @"Rice";
        sampleCategory1.color = [UIColor yellowColor];
        
        [self.catagories addObject:sampleCategory1];
        
        Catagory *sampleCategory2 = [Catagory new];
        sampleCategory2.name = @"Bread";
        sampleCategory2.color = [UIColor orangeColor];
        
        [self.catagories addObject:sampleCategory2];
        
        Catagory *sampleCategory3 = [Catagory new];
        sampleCategory3.name = @"Meat";
        sampleCategory3.color = [UIColor redColor];
        
        [self.catagories addObject:sampleCategory3];
        
        Catagory *sampleCategory4 = [Catagory new];
        sampleCategory4.name = @"Flour";
        sampleCategory4.color = [UIColor lightGrayColor];
        
        [self.catagories addObject:sampleCategory4];
        
        Catagory *sampleCategory5 = [Catagory new];
        sampleCategory5.name = @"Cake";
        sampleCategory5.color = [UIColor purpleColor];
        
        [self.catagories addObject:sampleCategory5];
        
        for (Catagory *catagory in self.catagories)
        {
            [self.catagoryNames addObject:catagory.name];
        }
        
        [self.catagoriesTable reloadData];
        
        [self setupTutorials];
        
        // decide which set of tutorials to show based on self.tutorialManager.currentStep
        if (self.tutorialManager.currentStep == 7)
        {
            [self displayTutorialStep:TutorialStep7];
        }
    }
    else
    {
        // load catagories
        [self refreshCatagories];
    }
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime])
    {
        [self setupTutorials];
        
        // decide which set of tutorials to show based on self.tutorialManager.currentStep
        if (self.tutorialManager.currentStep == 7)
        {
            [self displayTutorialStep:TutorialStep7];
        }
    }
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

- (void) refreshCatagories
{
    self.currentlySelectedCatagory = nil;

    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = [[NSMutableArray alloc] initWithArray: catagories copyItems: YES];
    
    [self.catagoriesTable reloadData];
    
    self.catagoryNames = [[NSMutableArray alloc] init];
    
    for (Catagory *catagory in self.catagories)
    {
        [self.catagoryNames addObject:catagory.name];
    }
    
    //set up the catagoryPickerViewController
    self.catagoryPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: self.catagoryNames];
    self.catagoryPickerViewController.highlightedSelectionIndex = -1;
    (self.catagoryPickerViewController).delegate = self;
}

- (void) setCurrentlySelectedCatagory: (Catagory *) currentlySelectedCatagory
{
    if (_currentlySelectedCatagory != currentlySelectedCatagory)
    {
        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self.catagoriesTable reloadData];
        
        if (!_currentlySelectedCatagory)
        {
            self.colorBeingAddedOrEdited = nil;
            
            self.nameOfCategoryBeingAddedOrEdited = nil;
        }
    }
}

-(void)setColorBeingAddedOrEdited:(UIColor *)colorBeingAddedOrEdited
{
    _colorBeingAddedOrEdited = colorBeingAddedOrEdited;
    
    if (_colorBeingAddedOrEdited)
    {
        self.colorView.backgroundColor = _colorBeingAddedOrEdited;
    }
    else
    {
        self.colorView.backgroundColor = [UIColor whiteColor];
    }
}

- (void) setAddingCatagoryMode: (BOOL) addingCatagoryMode
{
    _addingCatagoryMode = addingCatagoryMode;

    if (_addingCatagoryMode)
    {
        [self.addCatagoryButton setHidden: YES];
        [self.colorView setHidden: NO];
        [self.saveButton setHidden: NO];

        self.currentlySelectedCatagory = nil;

        [self.catagoriesTable setUserInteractionEnabled: NO];
        [self.catagoriesTable reloadData];
        
        // show the Cancel button instead of Back Button
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = self.leftMenuItem;
    }
    else
    {
        [self.addCatagoryButton setHidden: NO];
        [self.colorView setHidden: YES];
        [self.saveButton setHidden: YES];

        [self.catagoriesTable setUserInteractionEnabled: YES];
        [self.catagoriesTable reloadData];

        // restore the back button
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) cancelEditing
{
    self.addingCatagoryMode = NO;
    
    self.catagoryNameField.text = @"";
    self.nameOfCategoryBeingAddedOrEdited = nil;
    [self.catagoryNameField resignFirstResponder];
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    self.addingCatagoryMode = YES;
    
    [self colorBoxPressed];
}

- (void) colorBoxPressed
{
    [self showColorPickerViewController];
}

- (void) textBoxPressed
{
    if (!self.addingCatagoryMode)
    {
        self.addingCatagoryMode = YES;
    }

    [self showNamesPickerViewController];
}

- (void) saveCatagoryPressed: (UIButton *) sender
{
    NSString *trimmedString = [self.catagoryNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *capitalizedString = trimmedString.capitalizedString;
    
    if ([self.catagoryNames containsObject:capitalizedString])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"A existing category already has the same name. Please use a different category name", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
        
        return;
    }
    
    if ([self.manipulationService addCatagoryForName: capitalizedString
                                            forColor: self.colorView.backgroundColor save:YES])
    {
        self.addingCatagoryMode = NO;
        self.catagoryNameField.text = @"";
        self.nameOfCategoryBeingAddedOrEdited = nil;
        [self refreshCatagories];
    }
}

-(void)setupWYPopoverControllerTheme:(WYPopoverController *)wyPopoverController
{
    wyPopoverController.theme = [WYPopoverTheme theme];
    
    WYPopoverTheme *popUpTheme = wyPopoverController.theme;
    popUpTheme.fillTopColor = [UIColor whiteColor];
    popUpTheme.fillBottomColor = [UIColor whiteColor];
    popUpTheme.outerShadowColor = [UIColor grayColor];
    popUpTheme.outerShadowBlurRadius = 1;
    popUpTheme.outerShadowOffset = CGSizeMake(0, 2);
    wyPopoverController.theme = popUpTheme;
}

- (void) showColorPickerViewController
{
    self.colorPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.colorPickerViewController];
    (self.colorPickerPopover).popoverContentSize = self.colorPickerViewController.viewSize;
    
    [self setupWYPopoverControllerTheme:self.colorPickerPopover];
    
    CGRect popoverRect = self.colorView.frame;
    
    popoverRect.origin.y += 10;

    [self.colorPickerPopover presentPopoverFromRect: popoverRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

- (void) showNamesPickerViewController
{
    self.namesPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.namesPickerViewController];

    [self setupWYPopoverControllerTheme:self.namesPickerPopover];
    
    CGRect popoverRect = self.catagoryNameField.frame;
    
    popoverRect.origin.y += 10;

    [self.namesPickerPopover presentPopoverFromRect: popoverRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

- (void) showAllColorsPickerViewController
{
    self.allColorsPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.allColorsPickerViewController];
    (self.allColorsPickerPopover).popoverContentSize = self.allColorsPickerViewController.viewSize;

    [self setupWYPopoverControllerTheme:self.allColorsPickerPopover];
    
    CGRect popoverRect = self.colorView.frame;
    
    popoverRect.origin.y += 10;

    [self.allColorsPickerPopover presentPopoverFromRect: popoverRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

-(void)editPressed:(UIButton *)button
{
    //set up the modifyCatagoryViewController
    self.modifyCatagoryViewController = [self.viewControllerFactory createModifyCatagoryViewControllerWith:self.currentlySelectedCatagory];
    self.modifyCatagoryViewController.delegate = self;
    
    self.modifyCatagoryPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.modifyCatagoryViewController];
    (self.modifyCatagoryPickerPopover).popoverContentSize = self.modifyCatagoryViewController.viewSize;
    
    [self setupWYPopoverControllerTheme:self.modifyCatagoryPickerPopover];
    
    CGRect rectOfCellInTableView = [self.catagoriesTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: button.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.catagoriesTable convertRect: rectOfCellInTableView toView: (self.catagoriesTable).superview];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + button.frame.origin.x + button.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  button.frame.origin.y + button.frame.size.height / 2,
                                 1,
                                 1);
    
    [self.modifyCatagoryPickerPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

-(void)transferPressed:(UIButton *)button
{
    CGRect rectOfCellInTableView = [self.catagoriesTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: button.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.catagoriesTable convertRect: rectOfCellInTableView toView: (self.catagoriesTable).superview];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + button.frame.origin.x + button.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  button.frame.origin.y + button.frame.size.height / 2,
                                 1,
                                 1);
    
    self.catagoryPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.catagoryPickerViewController];
    
    [self setupWYPopoverControllerTheme:self.catagoryPickerPopover];
    
    [self.catagoryPickerPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

-(void)deletePressed:(UIButton *)button
{
    //show a UIAlertView Confirmation
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete", nil)
                                                      message: [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the category %@?", nil), self.currentlySelectedCatagory.name]
                                                     delegate: self
                                            cancelButtonTitle: NSLocalizedString(@"No", nil)
                                            otherButtonTitles: NSLocalizedString(@"Delete", nil), nil];
    
    [message show];
}

-(void)enableOrDisableSaveButton
{
    if (self.nameOfCategoryBeingAddedOrEdited.length && self.colorBeingAddedOrEdited)
    {
        [self.rightMenuItem setEnabled:YES];
    }
    else
    {
        [self.rightMenuItem setEnabled:NO];
    }
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    [self.view scrollToView:self.catagoryNameField];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

#pragma mark - PopUpViewControllerProtocol

-(void)requestPopUpToDismiss
{
    [self.namesPickerPopover dismissPopoverAnimated:YES];
    [self.colorPickerPopover dismissPopoverAnimated:YES];
    [self.allColorsPickerPopover dismissPopoverAnimated:YES];
    [self.catagoryPickerPopover dismissPopoverAnimated:YES];
    [self.modifyCatagoryPickerPopover dismissPopoverAnimated:YES];
    
    [self refreshCatagories];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    
    NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (trimmedString.length)
    {
        self.nameOfCategoryBeingAddedOrEdited = trimmedString;
    }
    else
    {
        self.nameOfCategoryBeingAddedOrEdited = nil;
    }
    
    [self enableOrDisableSaveButton];

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    NSString *trimmedString = [textfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (trimmedString.length)
    {
        self.nameOfCategoryBeingAddedOrEdited = trimmedString;
    }
    else
    {
        self.nameOfCategoryBeingAddedOrEdited = nil;
    }
}

#pragma mark - NamesPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.namesPickerPopover dismissPopoverAnimated:YES];
    [self.colorPickerPopover dismissPopoverAnimated:YES];
    [self.allColorsPickerPopover dismissPopoverAnimated:YES];
    [self.catagoryPickerPopover dismissPopoverAnimated:YES];
    [self.modifyCatagoryPickerPopover dismissPopoverAnimated:YES];
    
    if (popUpController == self.namesPickerViewController)
    {
        if (index == self.sampleCatagoryNames.count - 1)
        {
            [self.catagoryNameField becomeFirstResponder];
        }
        else
        {
            self.catagoryNameField.text = self.sampleCatagoryNames [index];
            
            [self.catagoryNameField resignFirstResponder];
            
            [self textFieldShouldReturn:self.catagoryNameField];
        }
    }
    
    else if (popUpController == self.catagoryPickerViewController)
    {
        self.catagoryToTransferTo = self.catagories[index];
        
        if (self.currentlySelectedCatagory == self.catagoryToTransferTo)
        {
            //nothing to be done
        }
        else
        {
            //show a UIAlertView Confirmation
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Transfer", nil)
                                                              message: [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to transfer all items in %@ to %@?", nil), self.currentlySelectedCatagory.name, self.catagoryToTransferTo.name]
                                                             delegate: self
                                                    cancelButtonTitle: NSLocalizedString(@"No", nil)
                                                    otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
            
            [message show];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: NSLocalizedString(@"Yes", nil)])
    {
        if ([self.manipulationService transferCatagoryFromCatagoryID:self.currentlySelectedCatagory.localID toCatagoryID:self.catagoryToTransferTo.localID save:YES])
        {
            self.catagoryToTransferTo = nil;
            
            [self refreshCatagories];
        }
    }
    
    else if ([title isEqualToString: NSLocalizedString(@"Delete", nil)])
    {
        if ([self.manipulationService deleteCatagoryForCatagoryID:self.currentlySelectedCatagory.localID save:YES])
        {
            [self refreshCatagories];
        }
    }
}

#pragma mark - ColorPickerViewController
#pragma mark - AllColorsPickerViewPopUpDelegate

-(void)pickedColor:(UIColor *)color
{
    self.colorBeingAddedOrEdited = color;
    [self.lookAndFeel applySlightlyDarkerBorderTo: self.colorView];
    
    [self enableOrDisableSaveButton];
}

- (void) selectedColor: (UIColor *) color
{
    self.colorBeingAddedOrEdited = color;
    [self.lookAndFeel applySlightlyDarkerBorderTo: self.colorView];
    
    if (!self.catagoryNameField.text.length)
    {
        [self textBoxPressed];
    }
    
    [self.colorPickerPopover dismissPopoverAnimated: YES];
    
    [self enableOrDisableSaveButton];
}

- (void) customColorPressed
{
    [self.colorPickerPopover dismissPopoverAnimated: NO];

    [self showAllColorsPickerViewController];
}

- (void) doneButtonPressed
{
    [self.allColorsPickerPopover dismissPopoverAnimated: YES];
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.catagories.count * 2;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a CatagoryTableViewCell
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellId = kCatagoryTableViewCellIdentifier;
        CatagoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[CatagoryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        cell.clipsToBounds = YES;

        Catagory *thisCatagory = (self.catagories)[indexPath.row / 2];

        cell.catagoryColor = thisCatagory.color;
        (cell.colorBox).backgroundColor = thisCatagory.color;

        (cell.catagoryName).text = thisCatagory.name;
        
        if (self.addingCatagoryMode)
        {
            [cell makeCellAppearInactive];
        }
        else
        {
            if (self.currentlySelectedCatagory)
            {
                if (thisCatagory == self.currentlySelectedCatagory)
                {
                    [cell makeCellAppearActive];
                }
                else
                {
                    [cell makeCellAppearInactive];
                }
            }
            else
            {
                [cell makeCellAppearActive];
            }
        }
        
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorBox];

        return cell;
    }
    // display a ModifyCatagoryTableViewCell
    else
    {
        static NSString *cellId2 = kModifyCatagoryTableViewCellIdentifier;
        ModifyCatagoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId2];

        if (cell == nil)
        {
            cell = [[ModifyCatagoryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId2];
        }

        cell.clipsToBounds = YES;

        [cell.editButton setLookAndFeel:self.lookAndFeel];
        [cell.transferButton setLookAndFeel:self.lookAndFeel];
        [cell.deleteButton setLookAndFeel:self.lookAndFeel];

        if (self.catagories.count > 1)
        {
            [cell.transferButton setEnabled: YES];
        }
        else
        {
            [cell.transferButton setEnabled: NO];
        }
        
        cell.editButton.tag = (indexPath.row - 1) / 2;
        cell.transferButton.tag = (indexPath.row - 1) / 2;
        cell.deleteButton.tag = (indexPath.row - 1) / 2;
        
        [cell.editButton addTarget: self
                            action: @selector(editPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
        
        [cell.transferButton addTarget: self
                                action: @selector(transferPressed:)
                      forControlEvents: UIControlEventTouchUpInside];
        
        [cell.deleteButton addTarget: self
                              action: @selector(deletePressed:)
                    forControlEvents: UIControlEventTouchUpInside];

        return cell;
    }

    return nil;
}

#pragma mark - UITableview Delegate
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row % 2 == 0)
    {
        return kCatagoryTableViewCellHeight;
    }
    else
    {
        Catagory *thisCatagory = (self.catagories)[(indexPath.row - 1) / 2];

        // only show the row if currentlySelectedCatagory == thisCatagory

        if (thisCatagory == self.currentlySelectedCatagory)
        {
            return kModifyCatagoryTableViewCellHeight;
        }
    }

    return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row % 2 == 0)
    {
        Catagory *thisCatagory = (self.catagories)[indexPath.row / 2];

        DLog(@"Category %@ clicked", thisCatagory.name);

        if (self.currentlySelectedCatagory == thisCatagory)
        {
            // deselect
            self.currentlySelectedCatagory = nil;
        }
        else
        {
            if (!self.currentlySelectedCatagory)
            {
                self.currentlySelectedCatagory = thisCatagory;
                
                [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            }
            else
            {
                // deselect
                self.currentlySelectedCatagory = nil;
            }
        }
    }
}

#pragma mark - Tutorial

typedef NS_ENUM(NSUInteger, TutorialSteps)
{
    TutorialStep7
};

-(void)setupTutorials
{
    (self.tutorialManager).delegate = self;
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep7 = [TutorialStep new];
    
    tutorialStep7.text = NSLocalizedString(@"Select from pre-made GF \"categories\" or create your own!", nil);
    tutorialStep7.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep7.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep7];
}

-(void)displayTutorialStep:(NSInteger)step
{
    if (self.tutorials.count && step < self.tutorials.count)
    {
        TutorialStep *tutorialStep = (self.tutorials)[step];
        
        [self.tutorialManager displayTutorialInViewController:self andTutorial:tutorialStep];
    }
}

- (void) tutorialLeftSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 7:
        {
            //Go back to Step 1 in Main view
            self.tutorialManager.currentStep = 1;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 7:
        {
            //Go to Step 8 in Main view
            self.tutorialManager.currentStep = 8;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
            break;
            
        default:
            break;
    }
}


@end