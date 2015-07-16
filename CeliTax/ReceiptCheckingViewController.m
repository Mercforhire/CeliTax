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

NSString *ReceiptItemCellIdentifier = @"ReceiptItemCellIdentifier";
NSString *ReceiptEditModeTableViewCellIdentifier = @"ReceiptEditModeTableViewCellIdentifier";

typedef enum : NSUInteger
{
    TextFieldTypeQuantity,
    TextFieldTypePricePerItem
} TextFieldTypes;

@interface ReceiptCheckingViewController ()
<ImageCounterIconViewProtocol, HorizonalScrollBarViewProtocol, UITextFieldDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, ReceiptScrollViewProtocol>
{
    // these values store the temp values user entered in the Quantity and Price/Item fields
    // for a soon to be added item
    NSInteger tempQuantity;
    float tempPricePerItem;
}

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
@property (weak, nonatomic) IBOutlet UIButton *editReceiptsButton;
@property (weak, nonatomic) IBOutlet UITableView *editReceiptTable;

@property (strong, nonatomic) NSMutableArray *receiptImages;
@property (strong, nonatomic) NSArray *catagories;
@property (nonatomic, strong) Receipt *receipt;
@property (strong, nonatomic) NSMutableDictionary *records; // all Records for this receipt
@property (nonatomic, strong) Catagory *currentlySelectedCatagory;
@property (strong, nonatomic) NSMutableArray *recordsOfCurrentlySelectedCatagory; // Records belonging to currentlySelectedCatagory
@property (nonatomic, strong) Record *currentlySelectedRecord;
@property (nonatomic) NSInteger currentlySelectedRecordIndex;  // index of the currentlySelectedRecord's position in recordsOfCurrentlySelectedCatagory

@property (nonatomic) BOOL editReceiptMode;

@end

@implementation ReceiptCheckingViewController

- (void) setupUI
{
    self.catagoriesBar.lookAndFeel = self.lookAndFeel;

    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneWithNumberPad)];
    [doneToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];

    self.numberToolbar.items = [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                doneToolbarButton,
                                nil];

    [self.numberToolbar sizeToFit];

    UIImage *receiptImage = [UIImage imageNamed: @"receipt_icon.png"];
    [self.recordsCounter setImage: receiptImage];

    self.receiptScrollView.lookAndFeel = self.lookAndFeel;
    [self.receiptScrollView setBackgroundColor: [UIColor blackColor]];
    [self.receiptScrollView setInsets:UIEdgeInsetsMake(64, 0, 0, 0)];

    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionLayout setItemSize: CGSizeMake(self.view.frame.size.width, 53)];
    [collectionLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
    [self.receiptItemCollectionView setCollectionViewLayout: collectionLayout];
    [self.receiptItemCollectionView setBackgroundColor: [UIColor clearColor]];

    UINib *receiptItemCell = [UINib nibWithNibName: @"ReceiptItemCell" bundle: nil];
    [self.receiptItemCollectionView registerNib: receiptItemCell forCellWithReuseIdentifier: ReceiptItemCellIdentifier];

    UINib *receiptEditModeTableViewCell = [UINib nibWithNibName: @"ReceiptEditModeTableViewCell" bundle: nil];
    [self.editReceiptTable registerNib: receiptEditModeTableViewCell forCellReuseIdentifier: ReceiptEditModeTableViewCellIdentifier];

    [self.lookAndFeel applySolidGreenButtonStyleTo: self.editReceiptsButton];

    // if we are straight from the camera, we show the X, and Complete button while hiding the Back button
    if (!self.cameFromReceiptBreakDownViewController)
    {
        // initialize the left side Cancel menu button button
        self.cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
        [self.cancelButton setTitle: @"X" forState: UIControlStateNormal];
        [self.cancelButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.cancelButton.titleLabel setFont: [UIFont latoBoldFontOfSize: 14]];
        [self.cancelButton addTarget: self action: @selector(cancelPressed) forControlEvents: UIControlEventTouchUpInside];

        self.leftMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancelButton];
        self.navigationItem.leftBarButtonItem = self.leftMenuItem;

        // initialize the right side Complete menu button button
        self.completeButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 90, 25)];
        [self.completeButton setTitle: @"Complete" forState: UIControlStateNormal];
        [self.completeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.completeButton setTitleEdgeInsets: UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.completeButton.titleLabel setFont: [UIFont latoBoldFontOfSize: 14]];
        [self.lookAndFeel applySolidGreenButtonStyleTo: self.completeButton];
        [self.completeButton addTarget: self action: @selector(completePressed) forControlEvents: UIControlEventTouchUpInside];

        self.rightMenuItem = [[UIBarButtonItem alloc] initWithCustomView: self.completeButton];
        self.navigationItem.rightBarButtonItem = self.rightMenuItem;
    }

    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void) cancelPressed
{
    // if the user has added at least one item, show a confirmation dialog,
    // upon confirmation, delete this Receipt and all of its Records
    // otherwise, just delete the current receipt and pop the view

    if ([self calculateNumberOfRecords] > 0)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Delete this receipt"
                                                          message: @"Are you sure you want delete this receipt along with all its items?"
                                                         delegate: self
                                                cancelButtonTitle: @"No"
                                                otherButtonTitles: @"Yes", nil];

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

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    self.catagoriesBar.delegate = self;

    [self.recordsCounter setDelegate: self];
    
    self.receiptScrollView.delegate = self;

    self.receiptItemCollectionView.delegate = self;
    self.receiptItemCollectionView.dataSource = self;

    self.editReceiptTable.delegate = self;
    self.editReceiptTable.dataSource = self;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self hideAddRecordControls];
    
    self.records = [NSMutableDictionary new];
    
    self.receiptImages = [NSMutableArray new];

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
    
    // load images from this receipt
    for (NSString *filename in self.receipt.fileNames)
    {
        UIImage *image = [Utils readImageWithFileName: filename forUser: self.userManager.user.userKey];
        
        if (image)
        {
            [self.receiptImages addObject: image];
        }
    }
    
    [self.receiptScrollView setImages: self.receiptImages];
    [self.editReceiptTable reloadData];

    // load all the catagories
    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = catagories;
    
    [self refreshButtonBar];

    // load catagory records for this receipt
    NSArray *records = [self.dataService fetchRecordsForReceiptID: self.receiptID];
    
    [self populateRecordsDictionaryUsing: records];
    
    [self refreshRecordsCounter];
}

-(void)showTutorial
{
    NSMutableArray *tutorials = [NSMutableArray new];
    
    //Each Stage represents a different group of Tutorial pop ups
    NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
    
    if ( currentTutorialStage == 1 )
    {
        //add Tutorials specific for this step
        TutorialStep *tutorialStep1 = [TutorialStep new];
        
        tutorialStep1.text = @"Scroll up and down your receipt to view all items that need to be allocated";
        tutorialStep1.origin = self.editReceiptTable.center;
        tutorialStep1.size = CGSizeMake(290, 70);
        tutorialStep1.pointsUp = YES;
        
        [tutorials addObject:tutorialStep1];
        
        TutorialStep *tutorialStep2 = [TutorialStep new];
        
        tutorialStep2.origin = self.catagoriesBar.center;
        
        tutorialStep2.text = @"Choose a category to allocate a purchase.\n\nClick the + button if you need to add another category!";
        tutorialStep2.size = CGSizeMake(290, 120);
        tutorialStep2.pointsUp = NO;
        
        [tutorials addObject:tutorialStep2];
        
        currentTutorialStage++;
        
        [self.tutorialManager setCurrentTutorialStageForViewController:self forStage:currentTutorialStage];
    }
    else if ( currentTutorialStage == 3 )
    {
        //add Tutorials specific for this step
        TutorialStep *tutorialStep3 = [TutorialStep new];
        
        tutorialStep3.text = @"Use the Add Item button to add an additional item to the current category";
        
        CGPoint addOrEditItemButtonCenterInContainer = self.addOrEditItemButton.center;
        CGPoint containerOrigin = self.itemControlsContainer.frame.origin;
        
        tutorialStep3.origin = CGPointMake(containerOrigin.x + addOrEditItemButtonCenterInContainer.x
                                           , containerOrigin.y + addOrEditItemButtonCenterInContainer.y);
        tutorialStep3.size = CGSizeMake(290, 70);
        tutorialStep3.pointsUp = NO;
        
        [tutorials addObject:tutorialStep3];
        
        TutorialStep *tutorialStep4 = [TutorialStep new];
        
        tutorialStep4.text = @"Use the < > arrows to quickly review or delete purchases allocated to this category";
        
        CGPoint previousItemButtonCenterInContainer = self.previousItemButton.center;
        CGPoint nextItemButtonInContainer = self.nextItemButton.center;
        
        tutorialStep4.origin = CGPointMake(containerOrigin.x + (previousItemButtonCenterInContainer.x + nextItemButtonInContainer.x) / 2, containerOrigin.y + (previousItemButtonCenterInContainer.y + nextItemButtonInContainer.y) / 2);
        tutorialStep4.size = CGSizeMake(290, 80);
        tutorialStep4.pointsUp = NO;
        
        [tutorials addObject:tutorialStep4];
        
        TutorialStep *tutorialStep5 = [TutorialStep new];
        
        tutorialStep5.text = @"Once you are done with one category, simply click on a different category to add more purcahses until you are done allocating all eligible purchases";
        
        tutorialStep5.origin = self.catagoriesBar.center;
        tutorialStep5.size = CGSizeMake(290, 100);
        tutorialStep5.pointsUp = NO;
        
        [tutorials addObject:tutorialStep5];
        
        TutorialStep *tutorialStep6 = [TutorialStep new];
        
        tutorialStep6.text = @"When finished allocating the entire receipt, click Complete";
        
        CGPoint barButtonCenter = CGPointMake(self.view.frame.size.width - self.completeButton.frame.size.width / 2 - 15,
                                              [UIApplication sharedApplication].statusBarFrame.size.height + 30);
        
        tutorialStep6.origin = barButtonCenter;
        tutorialStep6.size = CGSizeMake(290, 65);
        tutorialStep6.pointsUp = YES;
        
        [tutorials addObject:tutorialStep6];
        
        TutorialStep *tutorialStep7 = [TutorialStep new];
        
        tutorialStep7.text = @"Don’t have time to allocate right now? No worries. You can always review, add, edit and delete receipts and allocations from, Recent Uploads, the Vault or My Account";
        
        tutorialStep7.size = CGSizeMake(290, 120);
        tutorialStep7.pointsUp = YES;
        
        [tutorials addObject:tutorialStep7];
        
        [self.tutorialManager setTutorialDoneForViewController:self];
    }
    else
    {
        return;
    }
    
    [self.tutorialManager startTutorialInViewController:self andTutorials:tutorials];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Create tutorial items if it's ON
    if ([self.configurationManager isTutorialOn])
    {
        NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
        
        if (currentTutorialStage == 1)
        {
            [self showTutorial];
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

- (void) disablePreviousItemButton
{
    [self.previousItemButton setEnabled: NO];
    [self.previousItemButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
}

- (void) enablePreviousItemButton
{
    [self.previousItemButton setEnabled: YES];
    [self.previousItemButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
}

- (void) disableNextItemButton
{
    [self.nextItemButton setEnabled: NO];
    [self.nextItemButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
}

- (void) enableNextItemButton
{
    [self.nextItemButton setEnabled: YES];
    [self.nextItemButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
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

- (IBAction) editReceiptsPressed: (UIButton *) sender
{
    self.editReceiptMode = !self.editReceiptMode;

    if (self.editReceiptMode)
    {
        [self.editReceiptsButton setTitle: @"Done" forState: UIControlStateNormal];
    }
    else
    {
        [self.editReceiptsButton setTitle: @"Edit" forState: UIControlStateNormal];
    }
    
    [self hideAddRecordControls];
    
    [self.catagoriesBar deselectAnyCategory];
}

- (void) setEditReceiptMode: (BOOL) editReceiptMode
{
    _editReceiptMode = editReceiptMode;

    if (_editReceiptMode)
    {
        [self.receiptScrollView setHidden: YES];
        [self.recordsCounter setHidden: YES];
        [self.editReceiptTable setHidden: NO];
        [self.editReceiptTable setEditing: YES animated: YES];
    }
    else
    {
        [self.receiptScrollView setHidden: NO];
        [self.recordsCounter setHidden: NO];
        [self.editReceiptTable setHidden: YES];
        [self.editReceiptTable setEditing: NO animated: NO];
    }
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

- (void) deleteCurrentReceiptAndQuit
{
    // delete the receipt
    if ([self.manipulationService deleteReceiptAndAllItsRecords: self.receiptID])
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}

- (IBAction) nextRecordPressed: (UIButton *) sender
{
    if (self.currentlySelectedRecordIndex + 1 < self.recordsOfCurrentlySelectedCatagory.count)
    {
        self.currentlySelectedRecord = [self.recordsOfCurrentlySelectedCatagory objectAtIndex: self.currentlySelectedRecordIndex + 1];
    }
}

- (IBAction) addOrEditRecordPressed: (UIButton *) sender
{
    // Edit Mode
    if (self.currentlySelectedRecord)
    {
        if (tempPricePerItem > 0 && tempQuantity > 0)
        {
            self.currentlySelectedRecord.quantity = tempQuantity;
            self.currentlySelectedRecord.amount = tempPricePerItem;

            [self saveCurrentlySelectedRecord];
            
            [self.view endEditing: YES];
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Missing field"
                                                              message: @"Please make sure both Quantity and Price Per Item is filled."
                                                             delegate: nil
                                                    cancelButtonTitle: @"Dismiss"
                                                    otherButtonTitles: nil];

            [message show];
        }
    }
    // Add Mode
    else
    {
        NSString *newestRecordID = [self.manipulationService addRecordForCatagoryID: self.currentlySelectedCatagory.localID
                                                                       forReceiptID: self.receipt.localID
                                                                        forQuantity: tempQuantity
                                                                          forAmount: tempPricePerItem];
        
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
            
            // calls the setter to refresh UI
            self.recordsOfCurrentlySelectedCatagory = recordsOfThisCatagory;
            
            [self.receiptItemCollectionView reloadData];
            
            [self.receiptItemCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.recordsOfCurrentlySelectedCatagory.count inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            
            [self refreshRecordsCounter];
            
            [self performSelector:@selector(selectedNoRecord) withObject:nil afterDelay:0.3];
        }
    }
}

-(void)selectedNoRecord
{
    self.currentlySelectedRecord = 0;
}

- (IBAction) deleteRecordPressed: (UIButton *) sender
{
    if ([self.manipulationService deleteRecord: self.currentlySelectedRecord.localID])
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

- (void) showAddRecordControls
{
    [self.itemControlsContainer setHidden: NO];
}

- (void) hideAddRecordControls
{
    [self.itemControlsContainer setHidden: YES];
}

- (void) saveCurrentlySelectedRecord
{
    if ([self.manipulationService modifyRecord: self.currentlySelectedRecord])
    {
        DLog(@"Record %ld saved", (long)self.currentlySelectedRecord.localID);
    }
}

// use these functions to dynamically manage the UI when data is changed

// Note: self.currentlySelectedRecordIndex is only modified by setCurrentlySelectedRecord
// We never need to explictly set it anywhere in code
- (void) setCurrentlySelectedRecord: (Record *) currentlySelectedRecord
{
    _currentlySelectedRecord = currentlySelectedRecord;

    if (_currentlySelectedRecord)
    {
        [self.addOrEditItemButton setTitle: @"Save" forState: UIControlStateNormal];
        [self enableDeleteItemButton];
        [self enableAddItemButton];

        // load the record's data to the UI textfields
        self.currentlySelectedRecordIndex = [self.recordsOfCurrentlySelectedCatagory indexOfObject: _currentlySelectedRecord];

        tempQuantity = _currentlySelectedRecord.quantity;
        tempPricePerItem = _currentlySelectedRecord.amount;
    }
    else
    {
        // clear the textfields
        [self.currentItemStatusLabel setText: [NSString stringWithFormat: @"%d/%ld", 0, (unsigned long)self.recordsOfCurrentlySelectedCatagory.count]];

        [self.addOrEditItemButton setTitle: @"Add" forState: UIControlStateNormal];
        [self disableDeleteItemButton];
        [self disableAddItemButton];

        self.currentlySelectedRecordIndex = -1;

        tempQuantity = 0;
        tempPricePerItem = 0;
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

    [self disableAddItemButton];
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
    // user is changing to viewing another catagory's records
    else if (_currentlySelectedCatagory && currentlySelectedCatagory)
    {
        _currentlySelectedCatagory = currentlySelectedCatagory;

        [self loadFirstRecordFromCurrentlySelectedCatagory];
    }
}

- (void) setRecordsOfCurrentlySelectedCatagory: (NSMutableArray *) recordsOfCurrentlySelectedCatagory
{
    _recordsOfCurrentlySelectedCatagory = recordsOfCurrentlySelectedCatagory;
}

- (void) doneWithNumberPad
{
    [self.view endEditing: YES];
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

#pragma mark - ReceiptScrollViewProtocol

-(void)addImagePressed
{
    [self.navigationController pushViewController:[self.viewControllerFactory createCameraOverlayViewControllerWithExistingReceiptID:self.receiptID] animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex: buttonIndex];

    if ([title isEqualToString: @"Yes"])
    {
        [self deleteCurrentReceiptAndQuit];
    }
}

#pragma mark - From UICollectionView Delegate/Datasource

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

    cell.qtyField.text = [NSString stringWithFormat: @"%ld", (long)tempQuantity];
    cell.priceField.text = [NSString stringWithFormat: @"%.2f", tempPricePerItem];
    cell.totalField.text = [NSString stringWithFormat: @"%.2f", tempQuantity * tempPricePerItem];
    [self.lookAndFeel applyGreenBorderTo:cell.totalField];
    
    return cell;
}

- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout insetForSectionAtIndex: (NSInteger) section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    if ([textField.text isEqualToString: @"0"] || [textField.text isEqualToString: @"0.00"])
    {
        textField.text = @"";
    }
}

- (void) textFieldDidChange: (UITextField *) textField
{
    switch (textField.tag)
    {
        case TextFieldTypeQuantity:
            tempQuantity = [textField.text integerValue];
            break;

        case TextFieldTypePricePerItem:
            tempPricePerItem = [textField.text floatValue];
            break;

        default:
            break;
    }

    if (tempQuantity > 0 && tempPricePerItem > 0)
    {
        [self enableAddItemButton];
    }
    else
    {
        [self disableAddItemButton];
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

#pragma mark - HorizonalScrollBarViewProtocol

- (void) buttonClickedWithIndex: (NSInteger) index andName: (NSString *) name
{
    DLog(@"Bottom Bar button %ld:%@ pressed", (long)index, name);

    self.currentlySelectedCatagory = [self.catagories objectAtIndex: index];

    self.currentlySelectedRecord = nil;

    [self showAddRecordControls];
    
    [self.view layoutIfNeeded];
    
    if ([self.configurationManager isTutorialOn] && !self.cameFromReceiptBreakDownViewController)
    {
        NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
        
        if (currentTutorialStage == 2)
        {
            currentTutorialStage++;
            
            [self.tutorialManager setCurrentTutorialStageForViewController:self forStage:currentTutorialStage];
            
            [self showTutorial];
            
            return;
        }
    }
   
    ReceiptItemCell *itemCell = (ReceiptItemCell *)[self.receiptItemCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [itemCell.qtyField becomeFirstResponder];
}

- (void) buttonUnselected
{
    DLog(@"Bottom Bar buttons unselected");

    [self hideAddRecordControls];

    self.currentlySelectedCatagory = nil;
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
    [self.receiptImages exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self.receipt.fileNames exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self.manipulationService modifyReceipt:self.receipt];
    
    [self.receiptScrollView setImages:self.receiptImages];
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
            [self.manipulationService modifyReceipt:self.receipt];
            [self.receiptScrollView setImages:self.receiptImages];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Delete last receipt image"
                                                              message: @"Are you sure you want delete this receipt along with all its items?"
                                                             delegate: self
                                                    cancelButtonTitle: @"No"
                                                    otherButtonTitles: @"Yes", nil];
            
            [message show];
        }
    }
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kReceiptEditModeTableViewCellHeight;
}

@end