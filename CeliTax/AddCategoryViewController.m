//
// AddCategoryViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "AddCategoryViewController.h"
#import "UserManager.h"
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
#import "ConfigurationManager.h"
#import "SolidGreenButton.h"

#import "CeliTax-Swift.h"

@interface AddCategoryViewController () <SelectionsPickerPopUpDelegate, ColorPickerViewPopUpDelegate, UIPopoverControllerDelegate, AllColorsPickerViewPopUpDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, PopUpViewControllerProtocol, TutorialManagerDelegate>

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

@property (nonatomic, strong) NSMutableArray *sampleCategoryNames;
@property (nonatomic, strong) NSMutableArray *catagories;
@property (nonatomic, strong) NSMutableArray *categoryNames;

@property (nonatomic, strong) WYPopoverController *namesPickerPopover;
@property (nonatomic, strong) SelectionsPickerViewController *namesPickerViewController;

@property (nonatomic, strong) WYPopoverController *colorPickerPopover;
@property (nonatomic, strong) ColorPickerViewController *colorPickerViewController;

@property (nonatomic, strong) WYPopoverController *allColorsPickerPopover;
@property (nonatomic, strong) AllColorsPickerViewController *allColorsPickerViewController;

@property (nonatomic, strong) WYPopoverController *categoryPickerPopover;
@property (nonatomic, strong) SelectionsPickerViewController *categoryPickerViewController;

@property (nonatomic, strong) WYPopoverController *modifyCategoryPickerPopover;
@property (nonatomic, strong) ModifyCatagoryViewController *modifyCategoryViewController;

// set to true when user is actively adding a new ItemCategory
@property (nonatomic) BOOL addingCategoryMode;

@property (nonatomic, strong) ItemCategory *currentlySelectedCategory;

@property (nonatomic, strong) ItemCategory *categoryToTransferTo;

@property (nonatomic, strong) UIColor *colorBeingAddedOrEdited;

@property (nonatomic, strong) NSString *nameOfCategoryBeingAddedOrEdited;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;

@end

#define kCategoryTableViewCellHeight                    45
#define kCategoryTableViewCellIdentifier                @"CategoryTableViewCell"

#define kModifyCategoryTableViewCellHeight              62
#define kModifyCategoryTableViewCellIdentifier          @"ModifyCategoryTableViewCell"

@implementation AddCategoryViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Manage Categories", nil)];
    [self.catagoryNameField setPlaceholder:NSLocalizedString(@"Enter Category Name",nil)];
    
    self.sampleCategoryNames = [NSMutableArray new];

    // sample names
    [self.sampleCategoryNames addObject: NSLocalizedString(@"Bread", nil)];
    [self.sampleCategoryNames addObject: NSLocalizedString(@"Rice", nil)];
    [self.sampleCategoryNames addObject: NSLocalizedString(@"Cake", nil)];
    [self.sampleCategoryNames addObject: NSLocalizedString(@"Meat", nil)];
    [self.sampleCategoryNames addObject: NSLocalizedString(@"Pizza", nil)];
    [self.sampleCategoryNames addObject: NSLocalizedString(@"Custom", nil)];

    self.colorPickerViewController = [self.viewControllerFactory createColorPickerViewController];

    self.namesPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: self.sampleCategoryNames];
    self.namesPickerViewController.highlightedSelectionIndex = self.sampleCategoryNames.count - 1;
    self.allColorsPickerViewController = [self.viewControllerFactory createAllColorsPickerViewController];

    self.nameFieldOverlayButton = [[UIButton alloc] initWithFrame: self.catagoryNameField.frame];
    [self.view addSubview: self.nameFieldOverlayButton];

    // initialize the Save menu button button
    self.saveButton = [[SolidGreenButton alloc] initWithFrame: CGRectMake(0, 0, 50, 25)];
    [self.saveButton setTitle: NSLocalizedString(@"Save", nil) forState: UIControlStateNormal];
    (self.saveButton.titleLabel).font = [UIFont latoBoldFontOfSize: 14];
    (self.saveButton).titleEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    [self.saveButton addTarget: self action: @selector(saveCategoryPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self.saveButton setLookAndFeel:self.lookAndFeel];

    self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.saveButton];
    self.navigationItem.rightBarButtonItem = self.rightMenuItem;
    [self.rightMenuItem setEnabled:NO];

    [self.lookAndFeel applyGrayBorderTo: self.catagoryNameField];
    [self.lookAndFeel addLeftInsetToTextField: self.catagoryNameField];

    UINib *categoryTableViewCell = [UINib nibWithNibName: @"CatagoryTableViewCell" bundle: nil];
    UINib *modifyCategoryTableViewCell = [UINib nibWithNibName: @"ModifyCatagoryTableViewCell" bundle: nil];

    [self.catagoriesTable registerNib: categoryTableViewCell forCellReuseIdentifier: kCategoryTableViewCellIdentifier];
    [self.catagoriesTable registerNib: modifyCategoryTableViewCell forCellReuseIdentifier: kModifyCategoryTableViewCellIdentifier];

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
    self.addingCategoryMode = NO;

    self.catagoriesTable.dataSource = self;
    self.catagoriesTable.delegate = self;

    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime])
    {
        self.catagories = [NSMutableArray new];
        
        ItemCategory *sampleCategory1 = [ItemCategory new];
        sampleCategory1.name = @"Rice";
        sampleCategory1.color = [UIColor yellowColor];
        
        [self.catagories addObject:sampleCategory1];
        
        ItemCategory *sampleCategory2 = [ItemCategory new];
        sampleCategory2.name = @"Bread";
        sampleCategory2.color = [UIColor orangeColor];
        
        [self.catagories addObject:sampleCategory2];
        
        ItemCategory *sampleCategory3 = [ItemCategory new];
        sampleCategory3.name = @"Meat";
        sampleCategory3.color = [UIColor redColor];
        
        [self.catagories addObject:sampleCategory3];
        
        ItemCategory *sampleCategory4 = [ItemCategory new];
        sampleCategory4.name = @"Flour";
        sampleCategory4.color = [UIColor lightGrayColor];
        
        [self.catagories addObject:sampleCategory4];
        
        ItemCategory *sampleCategory5 = [ItemCategory new];
        sampleCategory5.name = @"Cake";
        sampleCategory5.color = [UIColor purpleColor];
        
        [self.catagories addObject:sampleCategory5];
        
        for (ItemCategory *category in self.catagories)
        {
            [self.categoryNames addObject:category.name];
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
    self.currentlySelectedCategory = nil;

    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = [[NSMutableArray alloc] initWithArray: catagories copyItems: YES];
    
    [self.catagoriesTable reloadData];
    
    self.categoryNames = [[NSMutableArray alloc] init];
    
    for (ItemCategory *category in self.catagories)
    {
        [self.categoryNames addObject:category.name];
    }
    
    //set up the categoryPickerViewController
    self.categoryPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: self.categoryNames];
    self.categoryPickerViewController.highlightedSelectionIndex = -1;
    (self.categoryPickerViewController).delegate = self;
}

- (void) setCurrentlySelectedCategory: (ItemCategory *) currentlySelectedCategory
{
    if (_currentlySelectedCategory != currentlySelectedCategory)
    {
        _currentlySelectedCategory = currentlySelectedCategory;

        [self.catagoriesTable reloadData];
        
        if (!_currentlySelectedCategory)
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

- (void) setAddingCategoryMode: (BOOL) addingCategoryMode
{
    _addingCategoryMode = addingCategoryMode;

    if (_addingCategoryMode)
    {
        [self.addCatagoryButton setHidden: YES];
        [self.colorView setHidden: NO];
        [self.saveButton setHidden: NO];

        self.currentlySelectedCategory = nil;

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
    self.addingCategoryMode = NO;
    
    self.catagoryNameField.text = @"";
    self.nameOfCategoryBeingAddedOrEdited = nil;
    [self.catagoryNameField resignFirstResponder];
}

- (IBAction) addCategoryPressed: (UIButton *) sender
{
    self.addingCategoryMode = YES;
    
    [self colorBoxPressed];
}

- (void) colorBoxPressed
{
    [self showColorPickerViewController];
}

- (void) textBoxPressed
{
    if (!self.addingCategoryMode)
    {
        self.addingCategoryMode = YES;
    }

    [self showNamesPickerViewController];
}

- (void) saveCategoryPressed: (UIButton *) sender
{
    NSString *trimmedString = [self.catagoryNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *capitalizedString = trimmedString.capitalizedString;
    
    if ([self.categoryNames containsObject:capitalizedString])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                          message:NSLocalizedString(@"A existing category already has the same name. Please use a different category name", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
        
        [message show];
        
        return;
    }
    
    if ([self.manipulationService addCatagoryForName: capitalizedString forColor: self.colorView.backgroundColor save:YES])
    {
        self.addingCategoryMode = NO;
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
    //set up the modifyCategoryViewController
    self.modifyCategoryViewController = [self.viewControllerFactory createModifyCatagoryViewControllerWith:self.currentlySelectedCategory];
    self.modifyCategoryViewController.delegate = self;
    
    self.modifyCategoryPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.modifyCategoryViewController];
    (self.modifyCategoryPickerPopover).popoverContentSize = self.modifyCategoryViewController.viewSize;
    
    [self setupWYPopoverControllerTheme:self.modifyCategoryPickerPopover];
    
    CGRect rectOfCellInTableView = [self.catagoriesTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: button.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.catagoriesTable convertRect: rectOfCellInTableView toView: (self.catagoriesTable).superview];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + button.frame.origin.x + button.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  button.frame.origin.y + button.frame.size.height / 2,
                                 1,
                                 1);
    
    [self.modifyCategoryPickerPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

-(void)transferPressed:(UIButton *)button
{
    CGRect rectOfCellInTableView = [self.catagoriesTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: button.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.catagoriesTable convertRect: rectOfCellInTableView toView: (self.catagoriesTable).superview];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + button.frame.origin.x + button.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  button.frame.origin.y + button.frame.size.height / 2,
                                 1,
                                 1);
    
    self.categoryPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.categoryPickerViewController];
    
    [self setupWYPopoverControllerTheme:self.categoryPickerPopover];
    
    [self.categoryPickerPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated: YES];
}

-(void)deletePressed:(UIButton *)button
{
    //show a UIAlertView Confirmation
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete", nil)
                                                      message: [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the category %@?", nil), self.currentlySelectedCategory.name]
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
    [self.categoryPickerPopover dismissPopoverAnimated:YES];
    [self.modifyCategoryPickerPopover dismissPopoverAnimated:YES];
    
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
    [self.categoryPickerPopover dismissPopoverAnimated:YES];
    [self.modifyCategoryPickerPopover dismissPopoverAnimated:YES];
    
    if (popUpController == self.namesPickerViewController)
    {
        if (index == self.sampleCategoryNames.count - 1)
        {
            [self.catagoryNameField becomeFirstResponder];
        }
        else
        {
            self.catagoryNameField.text = self.sampleCategoryNames [index];
            
            [self.catagoryNameField resignFirstResponder];
            
            [self textFieldShouldReturn:self.catagoryNameField];
        }
    }
    
    else if (popUpController == self.categoryPickerViewController)
    {
        self.categoryToTransferTo = self.catagories[index];
        
        if (self.currentlySelectedCategory == self.categoryToTransferTo)
        {
            //nothing to be done
        }
        else
        {
            //show a UIAlertView Confirmation
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Transfer", nil)
                                                              message: [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to transfer all items in %@ to %@?", nil), self.currentlySelectedCategory.name, self.categoryToTransferTo.name]
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
        if ([self.manipulationService transferCatagoryFromCatagoryID:self.currentlySelectedCategory.localID toCatagoryID:self.categoryToTransferTo.localID save:YES])
        {
            self.categoryToTransferTo = nil;
            
            [self refreshCatagories];
        }
    }
    
    else if ([title isEqualToString: NSLocalizedString(@"Delete", nil)])
    {
        if ([self.manipulationService deleteCatagoryForCatagoryID:self.currentlySelectedCategory.localID save:YES])
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
    // display a CategoryTableViewCell
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellId = kCategoryTableViewCellIdentifier;
        CatagoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[CatagoryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        cell.clipsToBounds = YES;

        ItemCategory *thisCategory = self.catagories[indexPath.row / 2];

        cell.catagoryColor = thisCategory.color;
        (cell.colorBox).backgroundColor = thisCategory.color;

        (cell.catagoryName).text = thisCategory.name;
        
        if (self.addingCategoryMode)
        {
            [cell makeCellAppearInactive];
        }
        else
        {
            if (self.currentlySelectedCategory)
            {
                if (thisCategory == self.currentlySelectedCategory)
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
    // display a ModifyCategoryTableViewCell
    else
    {
        static NSString *cellId2 = kModifyCategoryTableViewCellIdentifier;
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
        return kCategoryTableViewCellHeight;
    }
    else
    {
        ItemCategory *thisCategory = (self.catagories)[(indexPath.row - 1) / 2];

        // only show the row if currentlySelectedCategory == thisCategory

        if (thisCategory == self.currentlySelectedCategory)
        {
            return kModifyCategoryTableViewCellHeight;
        }
    }

    return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row % 2 == 0)
    {
        ItemCategory *thisCategory = (self.catagories)[indexPath.row / 2];

        DLog(@"Category %@ clicked", thisCategory.name);

        if (self.currentlySelectedCategory == thisCategory)
        {
            // deselect
            self.currentlySelectedCategory = nil;
        }
        else
        {
            if (!self.currentlySelectedCategory)
            {
                self.currentlySelectedCategory = thisCategory;
                
                [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            }
            else
            {
                // deselect
                self.currentlySelectedCategory = nil;
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