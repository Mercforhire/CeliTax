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

@interface AddCatagoryViewController () <SelectionsPickerPopUpDelegate, ColorPickerViewPopUpDelegate, UIPopoverControllerDelegate, AllColorsPickerViewPopUpDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UITextField *catagoryNameField;
@property (nonatomic, strong) UIButton *nameFieldOverlayButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIBarButtonItem *rightMenuItem;
@property (weak, nonatomic) IBOutlet UIButton *addCatagoryButton;
@property (weak, nonatomic) IBOutlet UITableView *catagoriesTable;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *leftMenuItem;

@property (nonatomic, strong) NSMutableArray *sampleCatagoryNames;
@property (nonatomic, strong) NSMutableArray *catagories;
@property (nonatomic, strong) NSMutableArray *catagoryNames;

@property (nonatomic, strong) WYPopoverController *pickerPopover;

@property (nonatomic, strong) SelectionsPickerViewController *namesPickerViewController;
@property (nonatomic, strong) ColorPickerViewController *colorPickerViewController;
@property (nonatomic, strong) AllColorsPickerViewController *allColorsPickerViewController;
@property (nonatomic, strong) SelectionsPickerViewController *catagoryPickerViewController;
@property (nonatomic, strong) ModifyCatagoryViewController *modifyCatagoryViewController;

// set to true when user is actively adding a new catagory
@property (nonatomic) BOOL addingCatagoryMode;

@property (nonatomic, strong) Catagory *currentlySelectedCatagory;

@property (nonatomic, strong) Catagory *catagoryToTransferTo;


@end

#define kCatagoryTableViewCellHeight                    45
#define kCatagoryTableViewCellIdentifier                @"CatagoryTableViewCell"

#define kModifyCatagoryTableViewCellHeight              62
#define kModifyCatagoryTableViewCellIdentifier          @"ModifyCatagoryTableViewCell"

@implementation AddCatagoryViewController

- (void) setupUI
{
    self.sampleCatagoryNames = [NSMutableArray new];

    // sample names
    [self.sampleCatagoryNames addObject: @"Bread"];
    [self.sampleCatagoryNames addObject: @"Rice"];
    [self.sampleCatagoryNames addObject: @"Cake"];
    [self.sampleCatagoryNames addObject: @"Meat"];
    [self.sampleCatagoryNames addObject: @"Pizza"];
    [self.sampleCatagoryNames addObject: @"Custom"];

    self.colorPickerViewController = [self.viewControllerFactory createColorPickerViewController];

    self.namesPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: self.sampleCatagoryNames];
    self.namesPickerViewController.highlightedSelectionIndex = self.sampleCatagoryNames.count - 1;
    self.allColorsPickerViewController = [self.viewControllerFactory createAllColorsPickerViewController];

    self.nameFieldOverlayButton = [[UIButton alloc] initWithFrame: self.catagoryNameField.frame];
    [self.view addSubview: self.nameFieldOverlayButton];

    // initialize the Save menu button button
    self.saveButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50, 25)];
    [self.saveButton setTitle: @"Save" forState: UIControlStateNormal];
    [self.saveButton.titleLabel setFont: [UIFont latoFontOfSize: 14]];
    [self.saveButton setTitleEdgeInsets: UIEdgeInsetsMake(5, 10, 5, 10)];
    [self.saveButton addTarget: self action: @selector(saveCatagoryPressed:) forControlEvents: UIControlEventTouchUpInside];
    [self.lookAndFeel applySolidGreenButtonStyleTo: self.saveButton];

    self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.saveButton];
    self.navigationItem.rightBarButtonItem = self.rightMenuItem;

    [self.lookAndFeel applyGrayBorderTo: self.catagoryNameField];
    [self.lookAndFeel addLeftInsetToTextField: self.catagoryNameField];

    UINib *catagoryTableViewCell = [UINib nibWithNibName: @"CatagoryTableViewCell" bundle: nil];
    UINib *modifyCatagoryTableViewCell = [UINib nibWithNibName: @"ModifyCatagoryTableViewCell" bundle: nil];

    [self.catagoriesTable registerNib: catagoryTableViewCell forCellReuseIdentifier: kCatagoryTableViewCellIdentifier];
    [self.catagoriesTable registerNib: modifyCatagoryTableViewCell forCellReuseIdentifier: kModifyCatagoryTableViewCellIdentifier];

    [self.colorView setBackgroundColor: [UIColor whiteColor]];
    [self.lookAndFeel applyGrayBorderTo: self.colorView];

    // initialize the Cancel menu button button
    self.cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
    [self.cancelButton setTitle: @"X" forState: UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont: [UIFont latoBoldFontOfSize: 14]];
    [self.cancelButton addTarget: self action: @selector(cancelEditing) forControlEvents: UIControlEventTouchUpInside];

    self.leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancelButton];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    [self.colorPickerViewController setDelegate: self];
    [self.namesPickerViewController setDelegate: self];
    [self.allColorsPickerViewController setDelegate: self];

    // conditionally check for any version >= iOS 8 using 'isOperatingSystemAtLeastVersion'
    if ([NSProcessInfo instancesRespondToSelector: @selector(isOperatingSystemAtLeastVersion:)])
    {
        // this is purely to fix the crashing problem
        UIPopoverPresentationController *garbageController = self.popoverPresentationController;
        [garbageController setSourceRect: self.namesPickerViewController.view.frame];
        [garbageController setSourceView: self.namesPickerViewController.view];
    }

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

    // load catagories
    [self refreshCatagories];
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

- (void) refreshCatagories
{
    self.currentlySelectedCatagory = nil;

    [self.dataService fetchCatagoriesSuccess: ^(NSArray *catagories) {
        self.catagories =  [[NSMutableArray alloc] initWithArray: catagories copyItems: YES];

        [self.catagoriesTable reloadData];
        
        self.catagoryNames = [[NSMutableArray alloc] init];
        
        for (Catagory *catagory in self.catagories)
        {
            [self.catagoryNames addObject:catagory.name];
        }
        
        //set up the catagoryPickerViewController
        self.catagoryPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: self.catagoryNames];
        self.catagoryPickerViewController.highlightedSelectionIndex = -1;
        [self.catagoryPickerViewController setDelegate: self];
        
    } failure: ^(NSString *reason) {
        // should not happen
    }];
}

- (void) setCurrentlySelectedCatagory: (Catagory *) currentlySelectedCatagory
{
    if (_currentlySelectedCatagory != currentlySelectedCatagory)
    {
        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self.catagoriesTable reloadData];
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
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    self.addingCatagoryMode = YES;
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

- (void) colorSelected: (UIColor *) newColor
{
    [self.colorView setBackgroundColor: newColor];
}

- (void) saveCatagoryPressed: (UIButton *) sender
{
    [self.manipulationService addCatagoryForName: self.catagoryNameField.text
                                        forColor: self.colorView.backgroundColor
                                         success: ^{
        self.addingCatagoryMode = NO;
        self.catagoryNameField.text = @"";
        [self refreshCatagories];
    } failure: ^(NSString *reason) {
        DLog(@"self.manipulationService addCatagoryForUserKey failed!");
    }];
}

- (void) showColorPickerViewController
{
    self.pickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.colorPickerViewController];
    [self.pickerPopover setPopoverContentSize: self.colorPickerViewController.viewSize];
    [self.pickerPopover setTheme: [WYPopoverTheme theme]];

    WYPopoverTheme *popUpTheme = self.pickerPopover.theme;
    popUpTheme.fillTopColor = [UIColor whiteColor];
    popUpTheme.fillBottomColor = [UIColor whiteColor];
    popUpTheme.outerShadowColor = [UIColor grayColor];
    popUpTheme.outerShadowBlurRadius = 1;
    popUpTheme.outerShadowOffset = CGSizeMake(0, 2);
    [self.pickerPopover setTheme: popUpTheme];

    [self.pickerPopover presentPopoverFromRect: self.colorView.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (void) showNamesPickerViewController
{
    self.pickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.namesPickerViewController];

    WYPopoverTheme *popUpTheme = self.pickerPopover.theme;
    popUpTheme.fillTopColor = [UIColor whiteColor];
    popUpTheme.fillBottomColor = [UIColor whiteColor];
    popUpTheme.outerShadowColor = [UIColor grayColor];
    popUpTheme.outerShadowBlurRadius = 1;
    popUpTheme.outerShadowOffset = CGSizeMake(0, 2);
    [self.pickerPopover setTheme: popUpTheme];

    [self.pickerPopover presentPopoverFromRect: self.catagoryNameField.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (void) showAllColorsPickerViewController
{
    self.pickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.allColorsPickerViewController];
    [self.pickerPopover setPopoverContentSize: self.allColorsPickerViewController.viewSize];

    WYPopoverTheme *popUpTheme = self.pickerPopover.theme;
    popUpTheme.fillTopColor = [UIColor whiteColor];
    popUpTheme.fillBottomColor = [UIColor whiteColor];
    popUpTheme.outerShadowColor = [UIColor grayColor];
    popUpTheme.outerShadowBlurRadius = 1;
    popUpTheme.outerShadowOffset = CGSizeMake(0, 2);

    [self.pickerPopover setTheme: popUpTheme];

    [self.pickerPopover presentPopoverFromRect: self.colorView.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

-(void)editPressed:(UIButton *)button
{
    //set up the modifyCatagoryViewController
    self.modifyCatagoryViewController = [self.viewControllerFactory createModifyCatagoryViewControllerWith:self.currentlySelectedCatagory];
    
    self.pickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.modifyCatagoryViewController];
    
    WYPopoverTheme *popUpTheme = self.pickerPopover.theme;
    popUpTheme.fillTopColor = [UIColor whiteColor];
    popUpTheme.fillBottomColor = [UIColor whiteColor];
    popUpTheme.outerShadowColor = [UIColor grayColor];
    popUpTheme.outerShadowBlurRadius = 1;
    popUpTheme.outerShadowOffset = CGSizeMake(0, 2);
    
    [self.pickerPopover setTheme: popUpTheme];
    
    CGRect rectOfCellInTableView = [self.catagoriesTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: button.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.catagoriesTable convertRect: rectOfCellInTableView toView: [self.catagoriesTable superview]];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + button.frame.origin.x + button.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  button.frame.origin.y + button.frame.size.height / 2,
                                 1,
                                 1);
    
    [self.pickerPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

-(void)transferPressed:(UIButton *)button
{
    CGRect rectOfCellInTableView = [self.catagoriesTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: button.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.catagoriesTable convertRect: rectOfCellInTableView toView: [self.catagoriesTable superview]];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + button.frame.origin.x + button.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  button.frame.origin.y + button.frame.size.height / 2,
                                 1,
                                 1);
    
    self.pickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.catagoryPickerViewController];
    
    WYPopoverTheme *popUpTheme = self.pickerPopover.theme;
    popUpTheme.fillTopColor = [UIColor whiteColor];
    popUpTheme.fillBottomColor = [UIColor whiteColor];
    popUpTheme.outerShadowColor = [UIColor grayColor];
    popUpTheme.outerShadowBlurRadius = 1;
    popUpTheme.outerShadowOffset = CGSizeMake(0, 2);
    
    [self.pickerPopover setTheme: popUpTheme];
    
    [self.pickerPopover presentPopoverFromRect: tinyRect inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

-(void)deletePressed:(UIButton *)button
{
    //show a UIAlertView Confirmation
    UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Delete"
                                                      message: [NSString stringWithFormat:@"Are you sure you want to delete the catagory %@?", self.currentlySelectedCatagory.name]
                                                     delegate: self
                                            cancelButtonTitle: @"No"
                                            otherButtonTitles: @"Delete", nil];
    
    [message show];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textfield
{
    if (self.catagoryNameField.text.length)
    {
        [self.saveButton setEnabled: YES];
    }
    else
    {
        [self.saveButton setEnabled: NO];
    }
}

#pragma mark - NamesPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.pickerPopover dismissPopoverAnimated: YES];
    
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
            
            [self textFieldDidChange: self.catagoryNameField];
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
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Transfer"
                                                              message: [NSString stringWithFormat:@"Are you sure you want to transfer all items in %@ to %@?", self.currentlySelectedCatagory.name, self.catagoryToTransferTo.name]
                                                             delegate: self
                                                    cancelButtonTitle: @"No"
                                                    otherButtonTitles: @"Yes", nil];
            
            [message show];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: @"Yes"])
    {
        [self.manipulationService transferCatagoryFromCatagoryID:self.currentlySelectedCatagory.identifer
                                                    toCatagoryID:self.catagoryToTransferTo.identifer
                                                         success:^
        {
            self.catagoryToTransferTo = nil;
            
            [self.manipulationService deleteCatagoryForCatagoryID:self.currentlySelectedCatagory.identifer
                                                          success:^
            {
                [self refreshCatagories];
                
            } failure:^(NSString *reason) {
                DLog(@"self.manipulationService deleteCatagoryForCatagoryID failed");
            }];
                                                        
        } failure:^(NSString *reason) {
            DLog(@"self.manipulationService transferCatagoryFromCatagoryID failed");
        }];
    }
    
    else if ([title isEqualToString: @"Delete"])
    {
        [self.manipulationService deleteCatagoryForCatagoryID:self.currentlySelectedCatagory.identifer
                                                      success:^
        {
            
            [self refreshCatagories];
            
        } failure:^(NSString *reason) {
            DLog(@"self.manipulationService deleteCatagoryForCatagoryID failed");
        }];
    }
}

#pragma mark - ColorPickerViewController

#pragma mark - AllColorsPickerViewPopUpDelegate

- (void) selectedColor: (UIColor *) color
{
    self.colorView.backgroundColor = color;
}

- (void) customColorPressed
{
    [self.pickerPopover dismissPopoverAnimated: NO];

    [self showAllColorsPickerViewController];
}

- (void) doneButtonPressed
{
    [self.pickerPopover dismissPopoverAnimated: NO];
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

        Catagory *thisCatagory = [self.catagories objectAtIndex: indexPath.row / 2];

        cell.catagoryColor = thisCatagory.color;
        [cell.colorBox setBackgroundColor: thisCatagory.color];
        [self.lookAndFeel applyGrayBorderTo: cell.colorBox];

        [cell.catagoryName setText: thisCatagory.name];
        
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

        [self.lookAndFeel applySolidGreenButtonStyleTo: cell.editButton];
        [self.lookAndFeel applySolidGreenButtonStyleTo: cell.transferButton];
        [self.lookAndFeel applySolidGreenButtonStyleTo: cell.deleteButton];

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
        Catagory *thisCatagory = [self.catagories objectAtIndex: (indexPath.row - 1) / 2];

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
        Catagory *thisCatagory = [self.catagories objectAtIndex: indexPath.row / 2];

        DLog(@"Catagory %@ clicked", thisCatagory.name);

        if (self.currentlySelectedCatagory == thisCatagory)
        {
            // deselect
            self.currentlySelectedCatagory = nil;
        }
        else
        {
            self.currentlySelectedCatagory = thisCatagory;
        }
    }
}

@end