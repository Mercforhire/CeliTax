//
// ReceiptCheckingViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-06.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptCheckingViewController.h"
#import "HorizonalScrollBarView.h"
#import "AddCatagoryViewController.h"
#import "Catagory.h"
#import "User.h"
#import "UserManager.h"
#import "Record.h"
#import "ImageCounterIconView.h"
#import "AddCatagoryViewController.h"
#import "ViewControllerFactory.h"
#import "Utils.h"
#import "Receipt.h"
#import "UIView+Helper.h"
#import "ReceiptBreakDownViewController.h"
#import "ReceiptItemCell.h"
#import "ReceiptScrollView.h"
#import "ReceiptEditModeTableViewCell.h"
#import "CameraViewController.h"
#import "TutorialManager.h"
#import "TutorialStep.h"
#import "ConfigurationManager.h"
#import "SolidGreenButton.h"
#import "MBProgressHUD.h"
#import "SyncManager.h"
#import "MetricUnitPickerViewController.h"
#import "ImperialUnitPickerViewController.h"
#import "WYPopoverController.h"
#import "TutorialManager.h"
#import "TutorialStep.h"

NSString *ReceiptItemCellIdentifier = @"ReceiptItemCellIdentifier";
NSString *ReceiptEditModeTableViewCellIdentifier = @"ReceiptEditModeTableViewCellIdentifier";

typedef enum : NSUInteger
{
    TextFieldTypeQuantity,
    TextFieldTypePricePerItem,
    TextFieldTypeTotalCost,
} TextFieldTypes;

@interface ReceiptCheckingViewController ()
<ImageCounterIconViewProtocol, HorizonalScrollBarViewProtocol, UITextFieldDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UnitPickerViewControllerDelegate, WYPopoverControllerDelegate, TutorialManagerDelegate>

@property (weak, nonatomic) IBOutlet HorizonalScrollBarView *catagoriesBar;
@property (weak, nonatomic) IBOutlet ImageCounterIconView *recordsCounter;
@property (weak, nonatomic) IBOutlet UIButton *previousItemButton;
@property (weak, nonatomic) IBOutlet UIButton *nextItemButton;
@property (weak, nonatomic) IBOutlet UIButton *addOrEditItemButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteItemButton;
@property (weak, nonatomic) IBOutlet UILabel *currentItemStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *itemControlsContainer;
@property (weak, nonatomic) IBOutlet ReceiptScrollView *receiptScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *receiptItemCollectionView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *completeButton;
@property (nonatomic, strong) UIBarButtonItem *leftMenuItem;
@property (nonatomic, strong) UIBarButtonItem *rightMenuItem;
@property (nonatomic, strong) UIToolbar *numberToolbar;
@property (weak, nonatomic) IBOutlet SolidGreenButton *editReceiptsButton;
@property (weak, nonatomic) IBOutlet UITableView *editReceiptTable;
@property (strong, nonatomic) MBProgressHUD *waitView;
@property (nonatomic, strong) WYPopoverController *unitPickerPopoverController;
@property (nonatomic, strong) MetricUnitPickerViewController *metricUnitPickerViewController;
@property (nonatomic, strong) ImperialUnitPickerViewController *imperialUnitPickerViewController;
@property (strong, nonatomic) UIButton *addPhotoButton;

@property (strong, nonatomic) NSMutableArray *receiptImages;
@property (strong, nonatomic) NSArray *catagories;
@property (nonatomic, copy) Receipt *receipt;
@property (strong, nonatomic) NSMutableDictionary *records; // all Records for this receipt
@property (nonatomic, strong) Catagory *currentlySelectedCatagory;
@property (strong, nonatomic) NSMutableArray *recordsOfCurrentlySelectedCatagory; // Records belonging to currentlySelectedCatagory
@property (nonatomic, strong) Record *currentlySelectedRecord;
@property (nonatomic) NSInteger currentlySelectedRecordIndex;  // index of the currentlySelectedRecord's position in recordsOfCurrentlySelectedCatagory

@property (nonatomic) BOOL editReceiptMode; //True, if user activated the Categories Bar
@property (nonatomic) BOOL itemControlsContainerActivated;

/*
 These values store the temp values user entered in the Quantity and Price/Item fields
 for a soon to be added item
 */
@property (nonatomic) NSInteger categoryIndexLongPressed;
@property (nonatomic, strong) NSString *categoryNameLongPressed;

@property (nonatomic) NSInteger tempUnitType;
@property (nonatomic) NSInteger tempQuantity;
@property (nonatomic) float tempPricePerItemOrTotalCost;

#define kTempUnitTypeKey                            @"TempUnitType"
#define kTempQuantityTypeKey                        @"TempQuantityType"
#define kTempPricePerItemOrTotalCostTypeKey         @"TempPricePerItemOrTotalCostType"

/*
 When user adds an item to a category, then when adding an additional item, 
 when one of the 2 input fields are filled, if user decides to review the 
 previously allocated item using the < > functions, when user comes back, 
 the entered data in the fields the user was trying to initially add should 
 be saved here. Same when they move to a different category. This data should 
 be saved here.
 */
@property (strong, nonatomic) NSMutableDictionary *savedDataForUnsavedNewRecordInEachCatagory;

@property (strong, nonatomic) NSMutableDictionary *savedDataForUnsavedExistingRecords;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;
@property (nonatomic) NSUInteger currentTutorialStep;

@property (nonatomic) BOOL shouldDisplaySecondSetOfTutorials;

@end

@implementation ReceiptCheckingViewController

- (void) setupUI
{
    self.catagoriesBar.lookAndFeel = self.lookAndFeel;

    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil) style: UIBarButtonItemStyleDone target: self action: @selector(doneOnKeyboardPressed)];
    [doneToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];

    self.numberToolbar.items = [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                doneToolbarButton,
                                nil];

    [self.numberToolbar sizeToFit];

    self.receiptScrollView.lookAndFeel = self.lookAndFeel;
    [self.receiptScrollView setBackgroundColor: [UIColor blackColor]];
    [self.receiptScrollView setInsets:UIEdgeInsetsMake(64, 0, 0, 0)];

    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionLayout setItemSize: CGSizeMake(self.view.frame.size.width, 53)];
    [collectionLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
    [self.receiptItemCollectionView setCollectionViewLayout: collectionLayout];
    [self.receiptItemCollectionView setBackgroundColor: [UIColor clearColor]];
    
    UITapGestureRecognizer *receiptScrollViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(stopEditing)];
    
    [self.receiptScrollView addGestureRecognizer: receiptScrollViewTap];

    UINib *receiptItemCell = [UINib nibWithNibName: @"ReceiptItemCell" bundle: nil];
    [self.receiptItemCollectionView registerNib: receiptItemCell forCellWithReuseIdentifier: ReceiptItemCellIdentifier];

    UINib *receiptEditModeTableViewCell = [UINib nibWithNibName: @"ReceiptEditModeTableViewCell" bundle: nil];
    [self.editReceiptTable registerNib: receiptEditModeTableViewCell forCellReuseIdentifier: ReceiptEditModeTableViewCellIdentifier];

    [self.editReceiptsButton setLookAndFeel:self.lookAndFeel];
    
    [self.addOrEditItemButton setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    [self.deleteItemButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];

    // if we are straight from the camera, we show the X, and Complete button while hiding the Back button
    if (!self.cameFromReceiptBreakDownViewController)
    {
        // initialize the left side Cancel menu button
        self.cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 20, 20)];
        [self.cancelButton setImage:[UIImage imageNamed:@"xIcon.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget: self action: @selector(cancelPressed) forControlEvents: UIControlEventTouchUpInside];

        self.leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancelButton];
        self.navigationItem.leftBarButtonItem = self.leftMenuItem;

        // initialize the right side Complete menu button button
        self.completeButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 90, 25)];
        [self.completeButton setTitle: @"Finish" forState: UIControlStateNormal];
        [self.completeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        self.completeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.completeButton.titleLabel setFont: [UIFont latoBoldFontOfSize: 14]];
        [self.completeButton addTarget: self action: @selector(completePressed) forControlEvents: UIControlEventTouchUpInside];

        self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.completeButton];
        self.navigationItem.rightBarButtonItem = self.rightMenuItem;
    }
    
    // initialize the right side Add Photo menu button
    self.addPhotoButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40, 30)];
    [self.addPhotoButton setImage:[UIImage imageNamed:@"camera_add_icon.png"] forState:UIControlStateNormal];
    [self.addPhotoButton addTarget: self action: @selector(addImagePressed:) forControlEvents: UIControlEventTouchUpInside];

    self.automaticallyAdjustsScrollViewInsets = YES;
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    self.catagoriesBar.delegate = self;

    [self.recordsCounter setDelegate: self];

    self.receiptItemCollectionView.delegate = self;
    self.receiptItemCollectionView.dataSource = self;

    self.editReceiptTable.delegate = self;
    self.editReceiptTable.dataSource = self;
    
    self.savedDataForUnsavedNewRecordInEachCatagory = [NSMutableDictionary new];
    self.savedDataForUnsavedExistingRecords = [NSMutableDictionary new];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self hideAddRecordControls];
    
    self.records = [NSMutableDictionary new];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];

    // load the receipt images for this receipt
    Receipt *receipt = [self.dataService fetchReceiptForReceiptID: self.receiptID];
    
    self.receipt = receipt;

    // load all the catagories
    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = catagories;
    
    [self refreshButtonBar];

    // load catagory records for this receipt
    NSArray *records = [self.dataService fetchRecordsForReceiptID: self.receiptID];
    
    [self populateRecordsDictionaryUsing: records];
    
    [self refreshRecordsCounter];
    
    NSMutableArray *filenamesToDownload = [NSMutableArray new];
    
    // load images from this receipt
    
    self.receiptImages = [NSMutableArray new];
    
    for (int i = 0; i < self.receipt.fileNames.count; i++)
    {
        UIImage *image = [Utils readImageWithFileName: self.receipt.fileNames[i] forUser: self.userManager.user.userKey];
        
        if (image)
        {
            [self.receiptImages addObject: image];
        }
        else
        {
            //need to download the image
            [filenamesToDownload addObject: self.receipt.fileNames[i]];
        }
    }
    
    if (filenamesToDownload.count)
    {
        //start download progress
        [self createAndShowWaitViewForDownload];
        
        [self.syncManager startDownloadPhotos:filenamesToDownload success:^{
            
            [self loadReceiptImages];
            
            [self.editReceiptTable reloadData];
            
            [self hideWaitingView];
            
        } failure:^(NSArray *filesnamesFailedToDownload) {
            
            [self hideWaitingView];
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                              message:NSLocalizedString(@"Failed to download the receipt image(s) for this receipt. Please try again later.", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Dismiss", nil),nil];
            
            [message show];
            
        }];
    }
    else
    {
        [self.receiptScrollView setImages: self.receiptImages];
        [self.editReceiptTable reloadData];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNumber *savedUnitSystem = [self.configurationManager getUnitSystem];
    
    if (!savedUnitSystem || savedUnitSystem.integerValue == UnitSystemMetric)
    {
        self.metricUnitPickerViewController = [self.viewControllerFactory createUnitPickerViewControllerWithDefaultUnit:UnitItem];
        self.unitPickerPopoverController = [[WYPopoverController alloc] initWithContentViewController: self.metricUnitPickerViewController];
        [self.unitPickerPopoverController setPopoverContentSize: self.metricUnitPickerViewController.viewSize];
        [self.unitPickerPopoverController setDelegate:self];
        [self.metricUnitPickerViewController setDelegate: self];
    }
    else
    {
        self.imperialUnitPickerViewController = [self.viewControllerFactory createImperialUnitPickerViewControllerWithDefaultUnit:UnitItem];
        self.unitPickerPopoverController = [[WYPopoverController alloc] initWithContentViewController: self.imperialUnitPickerViewController];
        [self.unitPickerPopoverController setPopoverContentSize: self.imperialUnitPickerViewController.viewSize];
        [self.unitPickerPopoverController setDelegate:self];
        [self.imperialUnitPickerViewController setDelegate: self];
    }
    
    if (![self.tutorialManager hasTutorialBeenShown])
    {
        if ([self.tutorialManager automaticallyShowTutorialNextTime])
        {
            if (!self.shouldDisplaySecondSetOfTutorials)
            {
                [self setupTutorials];
            }
            else
            {
                [self setupTutorialsForSecondSet];
            }
            
            [self displayTutorialStep:0];
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

#pragma mark - View Controller functions

-(void)loadReceiptImages
{
    self.receiptImages = [NSMutableArray new];
    
    for (int i = 0; i < self.receipt.fileNames.count; i++)
    {
        UIImage *image = [Utils readImageWithFileName: self.receipt.fileNames[i] forUser: self.userManager.user.userKey];
        
        if (image)
        {
            [self.receiptImages addObject: image];
        }
    }
    
    [self.receiptScrollView setImages: self.receiptImages];
}

- (NSInteger) calculateNumberOfRecords
{
    NSInteger counter = 0;

    for (NSMutableArray *recordsOfThisCatagory in self.records.allValues)
    {
        counter = counter + recordsOfThisCatagory.count;
    }

    return counter;
}

- (void) refreshRecordsCounter
{
    [self.recordsCounter setCounter: [self calculateNumberOfRecords]];

    if ([self calculateNumberOfRecords] == 0)
    {
        [self.recordsCounter setAlpha: 0.5];
        [self.recordsCounter setUserInteractionEnabled: NO];
    }
    else
    {
        [self.recordsCounter setAlpha: 1];
        [self.recordsCounter setUserInteractionEnabled: YES];
    }
}

- (void) populateRecordsDictionaryUsing: (NSArray *) records
{
    for (Record *record in records)
    {
        NSMutableArray *recordsOfThisCatagory = [self.records objectForKeyedSubscript:record.catagoryID];
        
        if (!recordsOfThisCatagory)
        {
            recordsOfThisCatagory = [NSMutableArray new];
        }

        [recordsOfThisCatagory addObject: record];

        [self.records setObject: recordsOfThisCatagory forKey: record.catagoryID];
    }
}

- (void) refreshButtonBar
{
    NSMutableArray *catagoryNames = [NSMutableArray new];
    NSMutableArray *catagoryColors = [NSMutableArray new];

    for (Catagory *catagory in self.catagories)
    {
        [catagoryNames addObject: catagory.name];
        [catagoryColors addObject: catagory.color];
    }

    [self.catagoriesBar setButtonNames: catagoryNames andColors: catagoryColors];
}

- (void) deleteCurrentReceiptAndQuit
{
    // delete the receipt
    if ([self.manipulationService deleteReceiptAndAllItsRecords: self.receiptID save:YES])
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}

-(void)selectedNoRecord
{
    self.currentlySelectedRecord = 0;
}

- (void) loadFirstRecordFromCurrentlySelectedCatagory
{
    self.recordsOfCurrentlySelectedCatagory = [self.records objectForKey: self.currentlySelectedCatagory.localID];

    if (self.recordsOfCurrentlySelectedCatagory.count)
    {
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory firstObject];
    }
    else
    {
        self.currentlySelectedRecord = nil;
    }
}

- (void) saveCurrentlySelectedRecord
{
    if ([self.manipulationService modifyRecord: self.currentlySelectedRecord save:YES])
    {
        DLog(@"Record %ld saved", (long)self.currentlySelectedRecord.localID);
    }
}

-(void)checkToSeeWhetherEnableOrDisableAddEditButton
{
    if (self.tempQuantity > 0 && self.tempPricePerItemOrTotalCost > 0)
    {
        //Editing Item mode
        if (self.currentlySelectedRecord)
        {
            //Only enable button if something is changed
            if (self.currentlySelectedRecord.quantity != self.tempQuantity ||
                self.currentlySelectedRecord.amount != self.tempPricePerItemOrTotalCost ||
                self.currentlySelectedRecord.unitType != self.tempUnitType )
            {
                [self enableAddItemButton];
            }
            else
            {
                [self disableAddItemButton];
            }
        }
        //Adding New Item mode
        else
        {
            [self enableAddItemButton];
        }
    }
    else
    {
        [self disableAddItemButton];
    }
}

#pragma mark - UI Control functions

- (void) showAddRecordControls
{
    [self.itemControlsContainer setHidden: NO];
    
    self.itemControlsContainerActivated = YES;
}

- (void) hideAddRecordControls
{
    [self.itemControlsContainer setHidden: YES];
    
    self.itemControlsContainerActivated = NO;
}

- (void) disablePreviousItemButton
{
    [self.previousItemButton setEnabled: NO];
    [self.previousItemButton setAlpha:0.5f];
}

- (void) enablePreviousItemButton
{
    [self.previousItemButton setEnabled: YES];
    [self.previousItemButton setAlpha:1.0f];
}

- (void) disableNextItemButton
{
    [self.nextItemButton setEnabled: NO];
    [self.nextItemButton setAlpha:0.5f];
}

- (void) enableNextItemButton
{
    [self.nextItemButton setEnabled: YES];
    [self.nextItemButton setAlpha:1.0f];
}

- (void) disableAddItemButton
{
    [self.addOrEditItemButton setEnabled: NO];
    [self.addOrEditItemButton setAlpha:0.5f];
}

- (void) enableAddItemButton
{
    [self.addOrEditItemButton setEnabled: YES];
    [self.addOrEditItemButton setAlpha:1];
}

- (void) disableDeleteItemButton
{
    [self.deleteItemButton setEnabled: NO];
    [self.deleteItemButton setAlpha:0.5f];
}

- (void) enableDeleteItemButton
{
    [self.deleteItemButton setEnabled: YES];
    [self.deleteItemButton setAlpha:1];
}

#pragma mark - Setters
// Use these functions to dynamically manage the UI when data is changed

- (void) setEditReceiptMode: (BOOL) editReceiptMode
{
    _editReceiptMode = editReceiptMode;
    
    if (_editReceiptMode)
    {
        [self.receiptScrollView setHidden: YES];
        [self.recordsCounter setHidden: YES];
        [self.editReceiptTable setHidden: NO];
        [self.editReceiptTable setEditing: YES animated: YES];
        
        [self.editReceiptsButton setTitle: NSLocalizedString(@"Done", nil) forState: UIControlStateNormal];
        
        self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.addPhotoButton];
        self.navigationItem.rightBarButtonItem = self.rightMenuItem;
    }
    else
    {
        [self.receiptScrollView setHidden: NO];
        [self.recordsCounter setHidden: NO];
        [self.editReceiptTable setHidden: YES];
        [self.editReceiptTable setEditing: NO animated: NO];
        
        [self.editReceiptsButton setTitle: NSLocalizedString(@"Edit", nil) forState: UIControlStateNormal];
        
        // if we are straight from the camera, we show the X, and Complete button while hiding the Back button
        if (!self.cameFromReceiptBreakDownViewController)
        {
            self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.completeButton];
            self.navigationItem.rightBarButtonItem = self.rightMenuItem;
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

// Note: self.currentlySelectedRecordIndex is only modified by setCurrentlySelectedRecord
// We never need to explictly set it anywhere in code
- (void) setCurrentlySelectedRecord: (Record *) currentlySelectedRecord
{
    _currentlySelectedRecord = currentlySelectedRecord;

    if (_currentlySelectedRecord)
    {
        [self.addOrEditItemButton setTitle: NSLocalizedString(@"Save", nil) forState: UIControlStateNormal];
        
        [self enableDeleteItemButton];

        // load the record's data to the UI textfields
        self.currentlySelectedRecordIndex = [self.recordsOfCurrentlySelectedCatagory indexOfObject: _currentlySelectedRecord];

        //check tempSavedDataForUnsavedRecordForEachCatagory to see if there is a saved value
        NSMutableDictionary *savedValues = [self.savedDataForUnsavedExistingRecords objectForKey:_currentlySelectedRecord.localID];
        
        if (!savedValues)
        {
            self.tempQuantity = _currentlySelectedRecord.quantity;
            self.tempPricePerItemOrTotalCost = _currentlySelectedRecord.amount;
            self.tempUnitType = _currentlySelectedRecord.unitType;
        }
        else
        {
            self.tempQuantity = [[savedValues objectForKey:kTempQuantityTypeKey] integerValue];
            self.tempPricePerItemOrTotalCost = [[savedValues objectForKey:kTempPricePerItemOrTotalCostTypeKey] floatValue];
            self.tempUnitType = [[savedValues objectForKey:kTempUnitTypeKey] integerValue];
        }
    }
    else
    {
        // Clear the Textfields
        [self.currentItemStatusLabel setText: [NSString stringWithFormat: @"%d/%ld", 0, (unsigned long)self.recordsOfCurrentlySelectedCatagory.count]];

        [self.addOrEditItemButton setTitle: NSLocalizedString(@"Add", nil) forState: UIControlStateNormal];
    
        [self disableDeleteItemButton];

        self.currentlySelectedRecordIndex = -1;
        
        //check tempSavedDataForUnsavedRecordForEachCatagory to see if there is a saved value
        NSMutableDictionary *savedValues = [self.savedDataForUnsavedNewRecordInEachCatagory objectForKey:self.currentlySelectedCatagory.localID];

        if (!savedValues)
        {
            self.tempQuantity = 0;
            self.tempPricePerItemOrTotalCost = 0;
            self.tempUnitType = 0;
        }
        else
        {
            self.tempQuantity = [[savedValues objectForKey:kTempQuantityTypeKey] integerValue];
            self.tempPricePerItemOrTotalCost = [[savedValues objectForKey:kTempPricePerItemOrTotalCostTypeKey] floatValue];
            self.tempUnitType = [[savedValues objectForKey:kTempUnitTypeKey] integerValue];
        }
    }

    [self.receiptItemCollectionView reloadData];
    
    [self.receiptItemCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(self.currentlySelectedRecordIndex + 1) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void) setCurrentlySelectedRecordIndex: (NSInteger) currentlySelectedRecordIndex
{
    _currentlySelectedRecordIndex = currentlySelectedRecordIndex;

    [self.currentItemStatusLabel setText: [NSString stringWithFormat: @"%ld/%ld", (long)(currentlySelectedRecordIndex + 1), (unsigned long)self.recordsOfCurrentlySelectedCatagory.count]];

    if (currentlySelectedRecordIndex == -1)
    {
        [self disablePreviousItemButton];
    }
    else
    {
        [self enablePreviousItemButton];
    }

    if (currentlySelectedRecordIndex == self.recordsOfCurrentlySelectedCatagory.count - 1)
    {
        [self disableNextItemButton];
    }
    else
    {
        [self enableNextItemButton];
    }
}

- (void) setCurrentlySelectedCatagory: (Catagory *) currentlySelectedCatagory
{
    if (!_currentlySelectedCatagory && !currentlySelectedCatagory)
    {
        // do nothing
        return;
    }

    if (_currentlySelectedCatagory && !currentlySelectedCatagory)
    {
        // deselect currentlySelectedRecord and self.recordsOfCurrentlySelectedCatagory
        self.currentlySelectedRecord = nil;
        self.recordsOfCurrentlySelectedCatagory = nil;

        [self hideAddRecordControls];

        _currentlySelectedCatagory = currentlySelectedCatagory;
    }
    else if (!_currentlySelectedCatagory && currentlySelectedCatagory)
    {
        [self showAddRecordControls];

        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
    // User is changing to viewing another catagory's records
    else if (_currentlySelectedCatagory && currentlySelectedCatagory)
    {
        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
}

-(void)setTempPricePerItemOrTotalCost:(float)tempPricePerItemOrTotalCost
{
    _tempPricePerItemOrTotalCost = tempPricePerItemOrTotalCost;
    
    [self checkToSeeWhetherEnableOrDisableAddEditButton];
}

-(void)setTempUnitType:(NSInteger)tempUnitType
{
    _tempUnitType = tempUnitType;
    
    [self checkToSeeWhetherEnableOrDisableAddEditButton];
}

-(void)setTempQuantity:(NSInteger)tempQuantity
{
    _tempQuantity = tempQuantity;
    
    [self checkToSeeWhetherEnableOrDisableAddEditButton];
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

#pragma mark - Button press events

- (void) doneOnKeyboardPressed
{
    [self stopEditing];
}

- (void) stopEditing
{
    [self.view endEditing: YES];
}

- (void) cancelPressed
{
    // if the user has added at least one item, show a confirmation dialog,
    // upon confirmation, delete this Receipt and all of its Records
    // otherwise, just delete the current receipt and pop the view
    
    if ([self calculateNumberOfRecords] > 0)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete this receipt", nil)
                                                          message: NSLocalizedString(@"Are you sure you want delete this receipt along with all its items?", nil)
                                                         delegate: self
                                                cancelButtonTitle: NSLocalizedString(@"No", nil)
                                                otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
        
        [message show];
    }
    else
    {
        [self deleteCurrentReceiptAndQuit];
    }
}

- (void) completePressed
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) deleteRecordPressed: (UIButton *) sender
{
    if ([self.manipulationService deleteRecord: self.currentlySelectedRecord.localID save:YES])
    {
        // delete the record from self.records
        NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: self.currentlySelectedRecord.catagoryID];
        
        [recordsOfThisCatagory removeObject: self.currentlySelectedRecord];
        
        [self.records setObject: recordsOfThisCatagory forKey: self.currentlySelectedRecord.catagoryID];
        
        // calls the setter to refresh UI
        self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;
        
        // finally jump to 0th record again to prepare to add another one
        self.currentlySelectedRecord = nil;
        
        [self refreshRecordsCounter];
    }
}

- (IBAction) addOrEditRecordPressed: (UIButton *) sender
{
    // Edit Mode
    if (self.currentlySelectedRecord)
    {
        if (self.tempPricePerItemOrTotalCost > 0 && self.tempQuantity > 0)
        {
            if (self.currentlySelectedRecord.quantity != self.tempQuantity ||
                self.currentlySelectedRecord.amount != self.tempPricePerItemOrTotalCost ||
                self.currentlySelectedRecord.unitType != self.tempUnitType )
            {
                self.currentlySelectedRecord.quantity = self.tempQuantity;
                self.currentlySelectedRecord.amount = self.tempPricePerItemOrTotalCost;
                self.currentlySelectedRecord.unitType = self.tempUnitType;
                
                // delete the saved value for this catagory from savedDataForUnsavedExistingRecords
                [self.savedDataForUnsavedExistingRecords removeObjectForKey:self.currentlySelectedRecord.localID];
                
                [self saveCurrentlySelectedRecord];
                
                [self checkToSeeWhetherEnableOrDisableAddEditButton];
            }
            
            [self.view endEditing: YES];
        }
    }
    // Add Mode
    else
    {
        NSString *newestRecordID = [self.manipulationService addRecordForCatagoryID:self.currentlySelectedCatagory.localID
                                                                       andReceiptID:self.receipt.localID
                                                                        forQuantity:self.tempQuantity
                                                                             orUnit:self.tempUnitType
                                                                          forAmount:self.tempPricePerItemOrTotalCost save:YES];
        if (newestRecordID)
        {
            Record *record = [self.dataService fetchRecordForID: newestRecordID];
            
            // add that to self.records
            NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: record.catagoryID];
            
            if (!recordsOfThisCatagory)
            {
                recordsOfThisCatagory = [NSMutableArray new];
            }
            
            [recordsOfThisCatagory addObject: record];
            
            [self.records setObject: recordsOfThisCatagory forKey: record.catagoryID];
            
            // delete the saved value for this catagory from tempSavedDataForUnsavedRecordForEachCatagory
            [self.savedDataForUnsavedNewRecordInEachCatagory removeObjectForKey:self.currentlySelectedCatagory.localID];
            
            // calls the setter to refresh UI
            self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;
            
            [self.receiptItemCollectionView reloadData];
            
            [self.receiptItemCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.recordsOfCurrentlySelectedCatagory.count inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            
            [self refreshRecordsCounter];
            
            [self performSelector:@selector(selectedNoRecord) withObject:nil afterDelay:0.3];
        }
    }
}

- (IBAction) editReceiptsPressed: (UIButton *) sender
{
    self.editReceiptMode = !self.editReceiptMode;
    
    [self hideAddRecordControls];
    
    [self.catagoriesBar deselectAnyCategory];
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    // open up the AddCatagoryViewController
    [self.navigationController pushViewController: [self.viewControllerFactory createAddCatagoryViewController] animated: YES];
}

- (IBAction) previousRecordPressed: (UIButton *) sender
{
    if (self.currentlySelectedRecordIndex - 1 >= 0)
    {
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex: self.currentlySelectedRecordIndex - 1];
    }
    else
    {
        self.currentlySelectedRecord = nil;
    }
}

- (IBAction) nextRecordPressed: (UIButton *) sender
{
    if (self.currentlySelectedRecordIndex + 1 < self.recordsOfCurrentlySelectedCatagory.count)
    {
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex: self.currentlySelectedRecordIndex + 1];
    }
}

- (void)addImagePressed:(UIButton *)sender
{
    [self.navigationController pushViewController:[self.viewControllerFactory createCameraOverlayViewControllerWithExistingReceiptID:self.receiptID] animated:YES];
}

#pragma mark - MBProgressHUD WaitView

- (void) createAndShowWaitViewForDownload
{
    if (!self.waitView)
    {
        self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
        self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
        self.waitView.detailsLabelText = NSLocalizedString(@"Downloading Images...", nil);
        self.waitView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview: self.waitView];
    }
    
    [self.waitView show: YES];
}

-(void)hideWaitingView
{
    if (self.waitView)
    {
        //hide the Waiting view
        [self.waitView hide: YES];
    }
}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    //If we were temporarily hiding the itemControlsContainer
    if (self.itemControlsContainerActivated && [self.itemControlsContainer isHidden])
    {
        //Show it again
        [self.itemControlsContainer setHidden: NO];
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];

    if ([title isEqualToString: NSLocalizedString(@"Yes", nil)])
    {
        [self deleteCurrentReceiptAndQuit];
    }
}

#pragma mark - From UICollectionView Delegate/Datasource

- (BOOL) highlightTheFirstIncompleteTextFieldInCell:(ReceiptItemCell *)receiptItemCell
{
    if (self.tempUnitType == UnitItem)
    {
        if (receiptItemCell.qtyField.text.integerValue == 0)
        {
            [receiptItemCell.qtyField becomeFirstResponder];
            
            return YES;
        }
        else if (receiptItemCell.priceField.text.floatValue == 0)
        {
            [receiptItemCell.priceField becomeFirstResponder];
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        if (receiptItemCell.qtyField.text.integerValue == 0)
        {
            [receiptItemCell.qtyField becomeFirstResponder];
            
            return YES;
        }
        else if (receiptItemCell.totalField.text.floatValue == 0)
        {
            [receiptItemCell.totalField becomeFirstResponder];
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.recordsOfCurrentlySelectedCatagory.count + 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    ReceiptItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: ReceiptItemCellIdentifier
                                                                      forIndexPath: indexPath];

    if (!cell)
    {
        cell = [[ReceiptItemCell alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 60)];
    }
    
    [cell.qtyField setDelegate: self];
    [cell.qtyField setTag: TextFieldTypeQuantity];
    [cell.qtyField addTarget: self
                      action: @selector(textFieldDidChange:)
            forControlEvents: UIControlEventEditingChanged];
    cell.qtyField.inputAccessoryView = self.numberToolbar;
    [self.lookAndFeel applyGrayBorderTo:cell.qtyField];
    
    [cell.priceField setDelegate: self];
    [cell.priceField setTag: TextFieldTypePricePerItem];
    [cell.priceField addTarget: self
                        action: @selector(textFieldDidChange:)
              forControlEvents: UIControlEventEditingChanged];
    cell.priceField.inputAccessoryView = self.numberToolbar;
    [self.lookAndFeel applyGrayBorderTo:cell.priceField];

    [cell.totalField setDelegate: self];
    [cell.totalField setTag: TextFieldTypeTotalCost];
    [cell.totalField addTarget: self
                        action: @selector(textFieldDidChange:)
              forControlEvents: UIControlEventEditingChanged];
    cell.totalField.inputAccessoryView = self.numberToolbar;
    
    if (self.tempUnitType == UnitItem)
    {
        [self.lookAndFeel applyGreenBorderTo:cell.totalField];
        
        cell.totalField.text = [NSString stringWithFormat: @"%.2f", self.tempQuantity * self.tempPricePerItemOrTotalCost];
        
        cell.priceField.text = [NSString stringWithFormat: @"%.2f", self.tempPricePerItemOrTotalCost];
    }
    else
    {
        [self.lookAndFeel applyGrayBorderTo:cell.totalField];
        
        cell.totalField.text = [NSString stringWithFormat: @"%.2f", self.tempPricePerItemOrTotalCost];
        
        cell.priceField.text = [NSString stringWithFormat: @""];
    }
    
    cell.qtyField.text = [NSString stringWithFormat: @"%ld", (long)self.tempQuantity];
    
    [cell setUnitTypeTo:self.tempUnitType];
    
    return cell;
}

- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout insetForSectionAtIndex: (NSInteger) section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    if ( [textField.text isEqualToString: @"0"] || [textField.text isEqualToString: @"0.00"] )
    {
        textField.text = @"";
    }
}

- (void) textFieldDidChange: (UITextField *) textField
{
    switch (textField.tag)
    {
        case TextFieldTypeQuantity:
            self.tempQuantity = [textField.text integerValue];
            
            break;

        case TextFieldTypePricePerItem:
            self.tempPricePerItemOrTotalCost = [textField.text floatValue];
            
            break;
            
        case TextFieldTypeTotalCost:
            self.tempPricePerItemOrTotalCost = [textField.text floatValue];
            
            break;

        default:
            break;
    }
    
    if (!self.currentlySelectedRecord)
    {
        //save the temp values to tempSavedDataForUnsavedRecordForEachCatagory
        NSMutableDictionary *savedValues = [NSMutableDictionary new];
        
        [savedValues setObject:[NSNumber numberWithInteger:self.tempQuantity] forKey:kTempQuantityTypeKey];
        [savedValues setObject:[NSNumber numberWithFloat:self.tempPricePerItemOrTotalCost] forKey:kTempPricePerItemOrTotalCostTypeKey];
        [savedValues setObject:[NSNumber numberWithInteger:self.tempUnitType] forKey:kTempUnitTypeKey];
        
        [self.savedDataForUnsavedNewRecordInEachCatagory setObject:savedValues forKey:self.currentlySelectedCatagory.localID];
    }
    else
    {
        //save the temp values to savedDataForUnsavedExistingRecords
        NSMutableDictionary *savedValues = [NSMutableDictionary new];
        
        [savedValues setObject:[NSNumber numberWithInteger:self.tempQuantity] forKey:kTempQuantityTypeKey];
        [savedValues setObject:[NSNumber numberWithFloat:self.tempPricePerItemOrTotalCost] forKey:kTempPricePerItemOrTotalCostTypeKey];
        [savedValues setObject:[NSNumber numberWithInteger:self.tempUnitType] forKey:kTempUnitTypeKey];
        
        [self.savedDataForUnsavedExistingRecords setObject:savedValues forKey:self.currentlySelectedRecord.localID];
    }
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    // if user types nothing for a textField, we default it to 0
    if (textField.text.length == 0)
    {
        switch (textField.tag)
        {
            case TextFieldTypeQuantity:
                textField.text = @"0";
                break;

            case TextFieldTypePricePerItem:
                textField.text = @"0.00";
                break;
            
            case TextFieldTypeTotalCost:
                textField.text = @"0.00";
                break;

            default:
                break;
        }
    }
    
    [self.receiptItemCollectionView reloadData];
}

#pragma mark - ImageCounterIconViewProtocol

- (void) imageCounterIconClicked
{
    //if the view controller stack contains a ReceiptBreakDownViewController, pop current view,
    //otherwise, push a new ReceiptBreakDownViewController
    
    NSArray *viewControllersStack = self.navigationController.viewControllers;
    
    BOOL pop = NO;
    
    for (UIViewController *viewController in viewControllersStack)
    {
        if ([viewController isKindOfClass:[ReceiptBreakDownViewController class]])
        {
            pop = YES;
            break;
        }
    }
    
    if (pop)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
    else
    {
        // push ReceiptCheckingViewController
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: self.receiptID cameFromReceiptCheckingViewController: YES] animated: YES];
    }
}

#pragma mark - UnitPickerViewControllerDelegate

-(void)selectedUnit:(NSInteger)unitType
{
    self.tempUnitType = unitType;
    
    [self.receiptItemCollectionView reloadData];
    
    [self.unitPickerPopoverController dismissPopoverAnimated:YES completion:^{
        
        //If no record was selected
        if (!self.currentlySelectedRecord && !self.itemControlsContainerActivated)
        {
            //Press on the catagoriesBar button that spawned theunitPickerPopoverController
            [self buttonClickedWithIndex:self.categoryIndexLongPressed andName:self.categoryNameLongPressed highlightTextField:YES];
        }
        
        [self popoverControllerDidDismissPopover:self.unitPickerPopoverController];
        
    }];
}

#pragma mark - HorizonalScrollBarViewProtocol

- (void) buttonClickedWithIndex: (NSInteger) index andName: (NSString *) name highlightTextField:(BOOL)highlight
{
    self.currentlySelectedCatagory = [self.catagories objectAtIndex: index];

    self.currentlySelectedRecord = nil;

    [self showAddRecordControls];
    
    [self.view layoutIfNeeded];
   
    if (highlight)
    {
        ReceiptItemCell *itemCell = (ReceiptItemCell *)[self.receiptItemCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        [self highlightTheFirstIncompleteTextFieldInCell:itemCell];
    }
}

- (void) buttonUnselected
{
    self.currentlySelectedCatagory = nil;
}

- (void) buttonLongPressedWithIndex:(NSInteger)index andName:(NSString *)name atPoint:(CGPoint)point
{
    if (![self.itemControlsContainer isHidden])
    {
        [self.itemControlsContainer setHidden:YES];
    }
    
    [self stopEditing];
    
    //Show Unit Picker at given point
    CGRect tinyRect = CGRectMake(self.catagoriesBar.frame.origin.x + point.x,
                                 self.catagoriesBar.frame.origin.y + point.y - 5,
                                 1,
                                 1);
    
    [self.unitPickerPopoverController presentPopoverFromRect: tinyRect
                                                      inView: self.view
                                    permittedArrowDirections: WYPopoverArrowDirectionDown
                                                    animated: YES];
    
    self.categoryIndexLongPressed = index;
    self.categoryNameLongPressed = name;
}

#pragma mark - UITableview DataSource

#define kReceiptEditModeTableViewCellHeight         160

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.receiptImages.count;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    ReceiptEditModeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: ReceiptEditModeTableViewCellIdentifier];

    if (cell == nil)
    {
        cell = [[ReceiptEditModeTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: ReceiptEditModeTableViewCellIdentifier];
    }

    cell.showsReorderControl = YES;
    cell.shouldIndentWhileEditing = NO;

    UIImage *thisReceiptImage = [self.receiptImages objectAtIndex: indexPath.row];

    [cell.receiptImageView setImage: thisReceiptImage];
    
    return cell;
}

- (BOOL) tableView: (UITableView *) tableview canMoveRowAtIndexPath: (NSIndexPath *) indexPath
{
    return YES;
}

- (void) tableView: (UITableView *) tableView moveRowAtIndexPath: (NSIndexPath *) fromIndexPath toIndexPath: (NSIndexPath *) toIndexPath
{
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    
    if (fromIndex != toIndex)
    {
        // fetch the object at the row being moved
        NSString *filename = [self.receipt.fileNames objectAtIndex:fromIndexPath.row];
        
        // remove the original from the data structure
        [self.receipt.fileNames removeObjectAtIndex:fromIndex];
        
        // insert the object at the target row
        [self.receipt.fileNames insertObject:filename atIndex:toIndex];
        
        [self.manipulationService modifyReceipt:self.receipt save:YES];
        
        // reload receipt images from self.receipt.fileName
        [self loadReceiptImages];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (self.receiptImages.count > 1 && self.receipt.fileNames.count > 1)
        {
            [self.receiptImages removeObjectAtIndex:indexPath.row];
            
            NSString *fileToDelete = [self.receipt.fileNames objectAtIndex:indexPath.row];
            
            [Utils deleteImageWithFileName:fileToDelete forUser: self.userManager.user.userKey];
            
            [self.receipt.fileNames removeObjectAtIndex:indexPath.row];
            [self.manipulationService modifyReceipt:self.receipt save:YES];
            [self.receiptScrollView setImages:self.receiptImages];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete last receipt image", nil)
                                                              message: NSLocalizedString(@"Are you sure you want delete this receipt along with all its items?", nil)
                                                             delegate: self
                                                    cancelButtonTitle: NSLocalizedString(@"No", nil)
                                                    otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
            
            [message show];
        }
    }
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kReceiptEditModeTableViewCellHeight;
}

#pragma mark - Tutorial

typedef enum : NSUInteger
{
    TutorialStep1,
    TutorialStep2,
    TutorialStep3,
    TutorialStep4,
    TutorialStep5,
    TutorialStep6,
    TutorialStep7,
    TutorialStepsCount,
} TutorialSteps;

-(void)setupTutorialsForItemControlsContainer
{
    if (self.tutorials.count > 2)
    {
        return;
    }
    
    TutorialStep *tutorialStep3 = [TutorialStep new];
    
    tutorialStep3.text = NSLocalizedString(@"Enter the total number of items purchased and the cost of each item for each selected GF category.", nil);
    tutorialStep3.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep3.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep3.highlightedItemRect = self.itemControlsContainer.frame;
    tutorialStep3.pointsUp = NO;
    
    [self.tutorials addObject:tutorialStep3];
    
    TutorialStep *tutorialStep4 = [TutorialStep new];
    
    tutorialStep4.text = NSLocalizedString(@"Click “Add” to add a new purchase to the selected GF category", nil);
    tutorialStep4.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep4.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    CGRect addButtonFrame = self.addOrEditItemButton.frame;
    
    addButtonFrame.origin.x += self.itemControlsContainer.frame.origin.x;
    addButtonFrame.origin.y += self.itemControlsContainer.frame.origin.y;
    
    tutorialStep4.highlightedItemRect = addButtonFrame;
    tutorialStep4.pointsUp = NO;
    
    [self.tutorials addObject:tutorialStep4];
    
    TutorialStep *tutorialStep5 = [TutorialStep new];
    
    tutorialStep5.text = NSLocalizedString(@"Scroll between purchases allocated in a GF category to edit or review an allocation.", nil);
    tutorialStep5.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep5.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    CGRect leftAndRightButtonsFrame = self.previousItemButton.frame;
    
    leftAndRightButtonsFrame.origin.x += self.itemControlsContainer.frame.origin.x;
    leftAndRightButtonsFrame.origin.y += self.itemControlsContainer.frame.origin.y;
    leftAndRightButtonsFrame.size.width += self.nextItemButton.frame.origin.x - self.previousItemButton.frame.origin.x ;
    
    tutorialStep5.highlightedItemRect = leftAndRightButtonsFrame;
    tutorialStep5.pointsUp = NO;
    
    [self.tutorials addObject:tutorialStep5];
    
    TutorialStep *tutorialStep6 = [TutorialStep new];
    
    tutorialStep6.text = NSLocalizedString(@"Repeat this process for every GF purchase on your receipt, selecting the appropriate GF category to allocate items to.", nil);
    tutorialStep6.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep6.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep6];
    
    TutorialStep *tutorialStep7 = [TutorialStep new];
    
    tutorialStep7.text = NSLocalizedString(@"Click the receipt breakdown icon to view items that have been allocated to the receipt.", nil);
    tutorialStep7.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep7.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep7.pointsUp = YES;
    tutorialStep7.highlightedItemRect = [Utils returnRectBiggerThan:self.recordsCounter.frame by: 3];
    
    [self.tutorials addObject:tutorialStep7];
}

-(void)setupTutorials
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep1 = [TutorialStep new];
    
    tutorialStep1.text = NSLocalizedString(@"This is where you will allocate your receipt purchases to your custom GF categories.", nil);
    tutorialStep1.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep1];
    
    TutorialStep *tutorialStep2 = [TutorialStep new];
    
    tutorialStep2.text = NSLocalizedString(@"Scroll through your GF categories or click the “+” to add a new one and begin allocating.", nil);
    tutorialStep2.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep2.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep2.pointsUp = NO;
    tutorialStep2.highlightedItemRect = self.catagoriesBar.frame;
    
    [self.tutorials addObject:tutorialStep2];
    
    self.currentTutorialStep = TutorialStep1;
}

-(void)setupTutorialsForSecondSet
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep1 = [TutorialStep new];
    
    tutorialStep1.text = NSLocalizedString(@"Need to allocate a purchase based on weight? Click and hold a GF category to bring up various units to choose from. Allocate purchases as usual. *You can switch between metric/imperial in Settings.", nil);
    tutorialStep1.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep1];
    
    TutorialStep *tutorialStep2 = [TutorialStep new];
    
    tutorialStep2.text = NSLocalizedString(@"Forgot to capture the whole receipt? Click ”Edit” and the Camera Icon to add more photos", nil);
    tutorialStep2.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep2.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep2];
    
    TutorialStep *tutorialStep3 = [TutorialStep new];
    
    tutorialStep3.text = NSLocalizedString(@"Click “Edit” to manage each image captured. Delete or re-order images by touching and dragging the ≡ icon.", nil);
    tutorialStep3.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep3.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep3.pointsUp = YES;
    tutorialStep3.highlightedItemRect = [Utils returnRectBiggerThan:self.editReceiptsButton.frame by: 3];
    
    [self.tutorials addObject:tutorialStep3];
    
    TutorialStep *tutorialStep4 = [TutorialStep new];
    
    tutorialStep4.text = NSLocalizedString(@"When you are finished allocating, touch “Complete” to save and store your receipt to The Vault. The Vault is where all of your receipts are saved.", nil);
    tutorialStep4.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep4.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep4.pointsUp = YES;
    
    [self.tutorials addObject:tutorialStep4];
    
    self.currentTutorialStep = TutorialStep1;
}

-(void)displayTutorialStep:(NSInteger)step
{
    if (self.tutorials.count && step < self.tutorials.count)
    {
        TutorialStep *tutorialStep = [self.tutorials objectAtIndex:step];
        
        [self.tutorialManager displayTutorialInViewController:self andTutorial:tutorialStep];
        
        self.currentTutorialStep = step;
    }
}

- (void) tutorialLeftSideButtonPressed
{
    if (!self.shouldDisplaySecondSetOfTutorials)
    {
        switch (self.currentTutorialStep)
        {
            case TutorialStep2:
                //Go back to Step 1
                [self displayTutorialStep:TutorialStep1];
                break;
                
            case TutorialStep3:
                //Go back to Step 2
                [self displayTutorialStep:TutorialStep2];
                break;
                
            case TutorialStep4:
                //Go back to Step 3
                [self displayTutorialStep:TutorialStep3];
                break;
                
            case TutorialStep5:
                //Go back to Step 4
                [self displayTutorialStep:TutorialStep4];
                break;
                
            case TutorialStep6:
                //Go back to Step 5
                [self displayTutorialStep:TutorialStep5];
                break;
                
            case TutorialStep7:
                //Go back to Step 6
                [self displayTutorialStep:TutorialStep6];
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (self.currentTutorialStep)
        {
            case TutorialStep2:
                //Go back to Step 1
                [self displayTutorialStep:TutorialStep1];
                break;
                
            case TutorialStep3:
                //Go back to Step 2
                [self displayTutorialStep:TutorialStep2];
                break;
                
            case TutorialStep4:
                //Go back to Step 3
                [self displayTutorialStep:TutorialStep3];
                break;
                
            default:
                break;
        }
    }
}

- (void) tutorialRightSideButtonPressed
{
    if (!self.shouldDisplaySecondSetOfTutorials)
    {
        switch (self.currentTutorialStep)
        {
            case TutorialStep1:
                //Go to Step 2
                [self displayTutorialStep:TutorialStep2];
                
                break;
                
            case TutorialStep2:
            {
                self.currentlySelectedCatagory = [self.catagories objectAtIndex: 0];
                
                self.currentlySelectedRecord = nil;
                
                [self showAddRecordControls];
                
                [self.view layoutIfNeeded];
                
                [self setupTutorialsForItemControlsContainer];
                
                //Go to Step 3
                [self displayTutorialStep:TutorialStep3];
            }
                
                break;
                
            case TutorialStep3:
            {
                // only add if there are currently none
                if (self.records.count == 0)
                {
                    //add one sample item to the Quantity and Price fields
                    ReceiptItemCell *itemCell = (ReceiptItemCell *)[self.receiptItemCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    
                    [itemCell.qtyField setText:@"2"];
                    [itemCell.priceField setText:@"2.5"];
                    
                    self.tempQuantity = [itemCell.qtyField.text integerValue];
                    
                    self.tempPricePerItemOrTotalCost = [itemCell.priceField.text floatValue];
                    
                    if (!self.currentlySelectedRecord)
                    {
                        //saved the temp values to tempSavedDataForUnsavedRecordForEachCatagory
                        NSMutableDictionary *savedValues = [NSMutableDictionary new];
                        
                        [savedValues setObject:[NSNumber numberWithInteger:self.tempQuantity] forKey:kTempQuantityTypeKey];
                        [savedValues setObject:[NSNumber numberWithFloat:self.tempPricePerItemOrTotalCost] forKey:kTempPricePerItemOrTotalCostTypeKey];
                        [savedValues setObject:[NSNumber numberWithInteger:self.tempUnitType] forKey:kTempUnitTypeKey];
                        
                        [self.savedDataForUnsavedNewRecordInEachCatagory setObject:savedValues forKey:self.currentlySelectedCatagory.localID];
                    }
                }
                
                //Go to Step 4
                [self displayTutorialStep:TutorialStep4];
            }
                break;
                
            case TutorialStep4:
                // only add if there are currently none
                if (self.records.count == 0)
                {
                    //press the Add Button for the user
                    [self addOrEditRecordPressed:self.addOrEditItemButton];
                }
                
                //Go to Step 5
                [self displayTutorialStep:TutorialStep5];
                break;
                
            case TutorialStep5:
                //Go to Step 6
                [self displayTutorialStep:TutorialStep6];
                break;
                
            case TutorialStep6:
            {
                // add 2 more items to other catagories
                if (self.records.count < 3 && self.catagories.count >= 3)
                {
                    Catagory *catagory1 = [self.catagories objectAtIndex:1];
                    Catagory *catagory2 = [self.catagories objectAtIndex:2];
                    
                    NSArray *catagories = [NSArray arrayWithObjects:catagory1, catagory2, nil];
                    
                    for (Catagory *catagory in catagories)
                    {
                        NSString *newestRecordID = [self.manipulationService addRecordForCatagoryID:catagory.localID
                                                                                       andReceiptID:self.receipt.localID
                                                                                        forQuantity:2
                                                                                             orUnit:UnitItem
                                                                                          forAmount:2.5f
                                                                                               save:YES];
                        if (newestRecordID)
                        {
                            Record *record = [self.dataService fetchRecordForID: newestRecordID];
                            
                            // add that to self.records
                            NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: record.catagoryID];
                            
                            if (!recordsOfThisCatagory)
                            {
                                recordsOfThisCatagory = [NSMutableArray new];
                            }
                            
                            [recordsOfThisCatagory addObject: record];
                            
                            [self.records setObject: recordsOfThisCatagory forKey: record.catagoryID];
                            
                            [self refreshRecordsCounter];
                        }
                    }
                }
                
                //Go to Step 7
                [self displayTutorialStep:TutorialStep7];
            }
                
                break;
                
            case TutorialStep7:
            {
                [self.tutorialManager setAutomaticallyShowTutorialNextTime];
                
                [self.tutorialManager dismissTutorial:^{
                    self.shouldDisplaySecondSetOfTutorials = YES;
                    
                    //Go to Receipt Breakdown view
                    [self imageCounterIconClicked];
                }];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (self.currentTutorialStep)
        {
            case TutorialStep1:
                //Go to Step 2
                [self displayTutorialStep:TutorialStep2];
                
                break;
                
            case TutorialStep2:
                //Go to Step 3
                [self displayTutorialStep:TutorialStep3];
                
                break;
                
            case TutorialStep3:
                //Go to Step 4
                [self displayTutorialStep:TutorialStep4];
                
                break;
                
            case TutorialStep4:
            {
                [self.tutorialManager setAutomaticallyShowTutorialNextTime];
                
                [self.tutorialManager dismissTutorial:^{
                    //Go back to Main Screen and then Vault
                    [self.navigationController popViewControllerAnimated: YES];
                }];
            }
                
                break;
                
            default:
                break;
        }
    }
}

@end