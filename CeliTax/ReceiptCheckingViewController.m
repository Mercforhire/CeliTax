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
#import "MainViewController.h"

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

@property (weak, nonatomic) IBOutlet HorizonalScrollBarView *categoriesBar;
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

//tempUnitType will default to this. This is set after user explictly selects a Unit Type
@property (nonatomic) NSInteger userSelectedUnitType;

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

@end

@implementation ReceiptCheckingViewController
{
    BOOL shouldHighlight;
}

- (void) setupUI
{
    self.categoriesBar.lookAndFeel = self.lookAndFeel;

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
    
    [self.receiptItemCollectionView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];

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

    self.categoriesBar.delegate = self;

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

    if (self.receiptID)
    {
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
    // demo mode
    else
    {
        // add fake categories
        Catagory *sampleCategory1 = [Catagory new];
        sampleCategory1.name = @"Rice";
        sampleCategory1.color = [UIColor yellowColor];
        sampleCategory1.localID = @"1";
        
        Catagory *sampleCategory2 = [Catagory new];
        sampleCategory2.name = @"Bread";
        sampleCategory2.color = [UIColor orangeColor];
        sampleCategory2.localID = @"2";
        
        Catagory *sampleCategory3 = [Catagory new];
        sampleCategory3.name = @"Meat";
        sampleCategory3.color = [UIColor redColor];
        sampleCategory3.localID = @"3";
        
        Catagory *sampleCategory4 = [Catagory new];
        sampleCategory4.name = @"Flour";
        sampleCategory4.color = [UIColor lightGrayColor];
        sampleCategory4.localID = @"4";
        
        Catagory *sampleCategory5 = [Catagory new];
        sampleCategory5.name = @"Cake";
        sampleCategory5.color = [UIColor purpleColor];
        sampleCategory5.localID = @"5";
        
        self.catagories = [[NSArray alloc] initWithObjects:sampleCategory1, sampleCategory2, sampleCategory3, sampleCategory4, sampleCategory5, nil];
        
        [self refreshButtonBar];
        
        // add fake receipt images
        
        UIImage *testImage1 = [UIImage imageNamed: @"ReceiptPic-1.jpg"];
        UIImage *testImage2 = [UIImage imageNamed: @"ReceiptPic-2.jpg"];
        
        self.receiptImages = [[NSMutableArray alloc] initWithObjects:testImage1, testImage2, nil];
        
        [self.receiptScrollView setImages: self.receiptImages];
        [self.editReceiptTable reloadData];
        
        // add fake records (not yet)
        
        [self refreshRecordsCounter];
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
    
    if (![self.tutorialManager hasTutorialBeenShown] && [self.tutorialManager automaticallyShowTutorialNextTime])
    {
        [self setupTutorials];
        
        // decide which set of tutorials to show based on self.tutorialManager.currentStep
        if (self.tutorialManager.currentStep == 11)
        {
            [self displayTutorialStep:TutorialStep11];
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

    [self.categoriesBar setButtonNames: catagoryNames andColors: catagoryColors];
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
            self.tempUnitType = self.userSelectedUnitType;
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
    
    [self.categoriesBar deselectAnyCategory];
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
    self.userSelectedUnitType = unitType;
    
    self.tempUnitType = unitType;
    
    [self.receiptItemCollectionView reloadData];
    
    [self.unitPickerPopoverController dismissPopoverAnimated:YES completion:^{
        
        //If no record was selected
        if (!self.currentlySelectedRecord && !self.itemControlsContainerActivated)
        {
            shouldHighlight = YES;
            
            //Press on the catagoriesBar button that spawned theunitPickerPopoverController
            [self buttonClickedWithIndex:self.categoryIndexLongPressed andName:self.categoryNameLongPressed];
        }
        
        [self popoverControllerDidDismissPopover:self.unitPickerPopoverController];
        
    }];
}

#pragma mark - HorizonalScrollBarViewProtocol

- (void) buttonClickedWithIndex: (NSInteger) index andName: (NSString *) name
{
    self.currentlySelectedCatagory = [self.catagories objectAtIndex: index];

    self.currentlySelectedRecord = nil;

    [self showAddRecordControls];
    
    [self.view layoutIfNeeded];
   
    if (shouldHighlight)
    {
        ReceiptItemCell *itemCell = (ReceiptItemCell *)[self.receiptItemCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        [self highlightTheFirstIncompleteTextFieldInCell:itemCell];
        
        shouldHighlight = NO;
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
    
    // set the correct default unit
    if (self.metricUnitPickerViewController)
    {
        [self.metricUnitPickerViewController setDefaultSelectedUnit:self.tempUnitType];
    }
    else if (self.imperialUnitPickerViewController)
    {
        [self.imperialUnitPickerViewController setDefaultSelectedUnit:self.tempUnitType];
    }
    
    //Show Unit Picker at given point
    CGRect tinyRect = CGRectMake(self.categoriesBar.frame.origin.x + point.x,
                                 self.categoriesBar.frame.origin.y + point.y - 5,
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
    TutorialStep11,
    TutorialStep12,
    TutorialStep13,
    TutorialStep14,
    TutorialStep15,
    TutorialStep16,
    TutorialStep17
} TutorialSteps;

-(void)setupTutorials
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep11 = [TutorialStep new];
    
    tutorialStep11.text = NSLocalizedString(@"To allocate your GF purchases, scroll through your GF categories or click \"+\" to create one.", nil);
    tutorialStep11.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep11.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep11.pointsUp = NO;
    tutorialStep11.highlightedItemRect = self.categoriesBar.frame;
    
    [self.tutorials addObject:tutorialStep11];
    
    TutorialStep *tutorialStep12 = [TutorialStep new];
    
    tutorialStep12.text = NSLocalizedString(@"Enter the total number and cost of each GF item purchased for each GF category.", nil);
    tutorialStep12.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep12.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep12.pointsUp = NO;
    tutorialStep12.highlightedItemRect = self.itemControlsContainer.frame;
    
    [self.tutorials addObject:tutorialStep12];
    
    TutorialStep *tutorialStep13 = [TutorialStep new];
    
    tutorialStep13.text = NSLocalizedString(@"After you add an item, use the \"< >\" buttons to navigate between items allocated to that category.", nil);
    tutorialStep13.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep13.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep13.pointsUp = NO;
    
    CGRect leftAndRightButtonsFrame = self.previousItemButton.frame;
    
    leftAndRightButtonsFrame.origin.x += self.itemControlsContainer.frame.origin.x;
    leftAndRightButtonsFrame.origin.y += self.itemControlsContainer.frame.origin.y;
    leftAndRightButtonsFrame.size.width += self.nextItemButton.frame.origin.x - self.previousItemButton.frame.origin.x ;
    
    tutorialStep13.highlightedItemRect = leftAndRightButtonsFrame;
    
    [self.tutorials addObject:tutorialStep13];
    
    TutorialStep *tutorialStep14 = [TutorialStep new];
    
    tutorialStep14.text = NSLocalizedString(@"Need to allocate a GF purchase based on weight/volume? Simply click and hold a category to view various units.", nil);
    tutorialStep14.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep14.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep14.pointsUp = NO;
    
    NSNumber *savedUnitSystem = [self.configurationManager getUnitSystem];
    
    if (!savedUnitSystem || savedUnitSystem.integerValue == UnitSystemMetric)
    {
        tutorialStep14.highlightedItemRect = CGRectMake(0, self.categoriesBar.frame.origin.y - self.metricUnitPickerViewController.viewSize.height - 20, 80, self.metricUnitPickerViewController.viewSize.height);
    }
    else
    {
        tutorialStep14.highlightedItemRect = CGRectMake(0, self.categoriesBar.frame.origin.y - self.imperialUnitPickerViewController.viewSize.height - 20, 80, self.imperialUnitPickerViewController.viewSize.height);
    }
    
    [self.tutorials addObject:tutorialStep14];
    
    TutorialStep *tutorialStep15 = [TutorialStep new];
    
    tutorialStep15.text = NSLocalizedString(@"Repeat this process until all of your GF purchases have been allocated from your receipt.", nil);
    tutorialStep15.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep15.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    
    [self.tutorials addObject:tutorialStep15];
    
    TutorialStep *tutorialStep16 = [TutorialStep new];
    
    tutorialStep16.text = NSLocalizedString(@"Click this icon to see a detailed breakdown of all items allocated to a receipt.", nil);
    tutorialStep16.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep16.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep16.pointsUp = YES;
    tutorialStep16.highlightedItemRect = CGRectMake(self.recordsCounter.frame.origin.x + 10,
                                                    self.recordsCounter.frame.origin.y,
                                                    self.recordsCounter.frame.size.width,
                                                    self.recordsCounter.frame.size.height);
    
    [self.tutorials addObject:tutorialStep16];
    
    TutorialStep *tutorialStep17 = [TutorialStep new];
    
    tutorialStep17.text = NSLocalizedString(@"Once you complete your receipt, it is saved in the Vault.", nil);
    tutorialStep17.leftButtonTitle = NSLocalizedString(@"Back", nil);
    tutorialStep17.rightButtonTitle = NSLocalizedString(@"Continue", nil);
    tutorialStep17.pointsUp = YES;
    tutorialStep17.highlightedItemRect = CGRectMake(self.view.frame.size.width - 80, 40, self.completeButton.frame.size.width, self.completeButton.frame.size.height);
    
    [self.tutorials addObject:tutorialStep17];
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
        case 11:
        {
            //Go back to Step 9 in Camera view
            self.tutorialManager.currentStep = 9;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
            
            break;
            
        case 12:
            //Go back to Step 11
            self.tutorialManager.currentStep = 11;
            [self hideAddRecordControls];
            [self displayTutorialStep:TutorialStep11];
            break;
            
        case 13:
            [self showAddRecordControls];
            //Go back to Step 12
            self.tutorialManager.currentStep = 12;
            [self displayTutorialStep:TutorialStep12];
            break;
            
        case 14:
        {
            //Go back to Step 13
            [self.unitPickerPopoverController dismissPopoverAnimated:YES completion:^{
                [self showAddRecordControls];
                self.tutorialManager.currentStep = 13;
                [self displayTutorialStep:TutorialStep13];
                
            }];
        }
            break;
            
        case 15:
        {
            CGRect tinyRect = CGRectMake(self.categoriesBar.frame.origin.x + 40,
                                         self.categoriesBar.frame.origin.y - 5,
                                         1,
                                         1);
            
            [self.unitPickerPopoverController presentPopoverFromRect: tinyRect
                                                              inView: self.view
                                            permittedArrowDirections: WYPopoverArrowDirectionDown
                                                            animated: YES];
            //Go back to Step 14
            self.tutorialManager.currentStep = 14;
            [self displayTutorialStep:TutorialStep14];
        }
            break;
            
        case 16:
            //Go back to Step 15
            self.tutorialManager.currentStep = 15;
            [self displayTutorialStep:TutorialStep15];
            break;
            
        case 17:
            //Go back to Step 16
            self.tutorialManager.currentStep = 16;
            [self displayTutorialStep:TutorialStep15];
            break;
            
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.tutorialManager.currentStep)
    {
        case 11:
            // press on the first Category, add a sample Record, and go to Step 12
            self.currentlySelectedCatagory = [self.catagories objectAtIndex: 0];
            
            self.currentlySelectedRecord = nil;
            
            [self showAddRecordControls];
            
            [self.view layoutIfNeeded];
            
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
            
            self.tutorialManager.currentStep = 12;
            [self displayTutorialStep:TutorialStep12];
            
            break;
            
        case 12:
            //Add the previously entered fields and then go to Step 13
            if (self.records.count == 0)
            {
                // add a fake record
                Record *record = [Record new];
                record.catagoryID = self.currentlySelectedCatagory.localID;
                record.quantity = self.tempQuantity;
                record.amount = self.tempPricePerItemOrTotalCost;
                record.unitType = self.tempUnitType;
                
                // add that to self.records
                NSMutableArray *recordsOfThisCatagory = [self.records objectForKey: self.currentlySelectedCatagory.localID];
                
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
                
                self.currentlySelectedRecord = 0;
            }
            
            self.tutorialManager.currentStep = 13;
            [self displayTutorialStep:TutorialStep13];
            break;
            
        case 13:
            //Simulate a long hold press on first Category and go to Step 14
            [self hideAddRecordControls];
            
            CGRect tinyRect = CGRectMake(self.categoriesBar.frame.origin.x + 40,
                                         self.categoriesBar.frame.origin.y - 5,
                                         1,
                                         1);
            
            [self.unitPickerPopoverController presentPopoverFromRect: tinyRect
                                                              inView: self.view
                                            permittedArrowDirections: WYPopoverArrowDirectionDown
                                                            animated: YES];
            self.tutorialManager.currentStep = 14;
            [self displayTutorialStep:TutorialStep14];
            break;
            
        case 14:
        {
            // dismiss the previous pop up, add 2 more items to other catagories, and go to step 15
            [self.unitPickerPopoverController dismissPopoverAnimated:YES completion:^{
                
                self.tutorialManager.currentStep = 15;
                [self displayTutorialStep:TutorialStep15];
                
            }];
        }
            
            break;
            
        case 15:
            //Go to Step 16
            self.tutorialManager.currentStep = 16;
            [self displayTutorialStep:TutorialStep16];
            break;
            
        case 16:
            //Go to Step 17
            self.tutorialManager.currentStep = 17;
            [self displayTutorialStep:TutorialStep17];
            break;
            
        case 17:
        {
            self.tutorialManager.currentStep = 18;
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            [self.tutorialManager dismissTutorial:^{
                
                NSArray *viewControllersStack = self.navigationController.viewControllers;
                
                id mainViewController;
                
                for (UIViewController *viewController in viewControllersStack)
                {
                    if ([viewController isKindOfClass:[MainViewController class]])
                    {
                        mainViewController = viewController;
                        
                        break;
                    }
                }
                
                if (mainViewController)
                {
                    [self.navigationController popToViewController:mainViewController animated:YES];
                }
                else
                {
                    [self.navigationController setViewControllers:[NSArray arrayWithObject:[self.viewControllerFactory createMainViewController]] animated:YES];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

@end