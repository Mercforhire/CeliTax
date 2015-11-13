//
// ReceiptBreakDownViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptBreakDownViewController.h"
#import "XYPieChart.h"
#import "ReceiptBreakDownItemTableViewCell.h"
#import "ReceiptBreakDownToolBarTableViewCell.h"
#import "UIView+Helper.h"
#import "ViewControllerFactory.h"
#import "ReceiptCheckingViewController.h"
#import "WYPopoverController.h"
#import "SelectionsPickerViewController.h"
#import "HollowGreenButton.h"

#import "CeliTax-Swift.h"

@interface ReceiptBreakDownViewController () <XYPieChartDelegate, XYPieChartDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SelectionsPickerPopUpDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noItemsShield;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet HollowGreenButton *viewReceiptButton;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *receiptItemsTable;
@property (nonatomic, strong) UIToolbar *numberToolbar;
@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *catagoryPickerViewController;

// group records into it's category as KEY
@property (nonatomic, strong) NSMutableDictionary *recordsDictionary;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *allCatagories;
@property (nonatomic, strong) NSMutableArray *catagoriesUsedByThisReceipt;
@property (nonatomic, strong) NSMutableArray *slicePercentages;
@property (nonatomic, strong) NSMutableArray *sliceColors;
@property (nonatomic, strong) NSMutableArray *sliceNames;

@property (nonatomic, strong) Record *currentlySelectedRecord;

@end

#define kReceiptBreakDownItemTableViewCellIdentifier        @"ReceiptBreakDownItemTableViewCell"
#define kReceiptBreakDownToolBarTableViewCellIdentifier     @"ReceiptBreakDownToolBarTableViewCell"

#define kReceiptBreakDownItemTableViewCellHeight            65
#define kReceiptBreakDownToolBarTableViewCellHeight         62
#define kPricePerItemFieldTagOffset                         1000

@implementation ReceiptBreakDownViewController

- (void) setupUI
{
    // set up pieChart
    
    (self.pieChart).backgroundColor = [UIColor clearColor]; // get rid of the visual aid background
    (self.pieChart).dataSource = self;
    (self.pieChart).delegate = self;
    [self.pieChart setStartPieAngle: M_PI_2];
    (self.pieChart).animationSpeed = 1.0;
    (self.pieChart).labelFont = [UIFont latoFontOfSize: 10];
    (self.pieChart).labelRadius = self.pieChart.frame.size.width / 4;
    [self.pieChart setShowPercentage: NO];
    [self.pieChart setPieBackgroundColor: [UIColor clearColor]];
    [self.pieChart setUserInteractionEnabled: YES];
    (self.pieChart).labelShadowColor = [UIColor blackColor];
    (self.pieChart).selectedSliceOffsetRadius = 0;

    // set up receiptItemsTable
    UINib *receiptBreakDownItemTableViewCell = [UINib nibWithNibName: @"ReceiptBreakDownItemTableViewCell" bundle: nil];
    [self.receiptItemsTable registerNib: receiptBreakDownItemTableViewCell forCellReuseIdentifier: kReceiptBreakDownItemTableViewCellIdentifier];

    UINib *receiptBreakDownToolBarTableViewCell = [UINib nibWithNibName: @"ReceiptBreakDownToolBarTableViewCell" bundle: nil];
    [self.receiptItemsTable registerNib: receiptBreakDownToolBarTableViewCell forCellReuseIdentifier: kReceiptBreakDownToolBarTableViewCellIdentifier];

    // toolbar for entering price and qty
    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"Done", nil)
                                                                         style: UIBarButtonItemStyleDone
                                                                        target: self
                                                                        action: @selector(doneWithKeyboard)];
    [doneToolbarButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont latoBoldFontOfSize: 15], NSForegroundColorAttributeName: self.lookAndFeel.appGreenColor} forState: UIControlStateNormal];

    self.numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil], doneToolbarButton];
    [self.numberToolbar sizeToFit];

    [self.viewReceiptButton setLookAndFeel:self.lookAndFeel];
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    (self.receiptItemsTable).delegate = self;
    (self.receiptItemsTable).dataSource = self;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    (self.dateFormatter).dateFormat = @"dd/MM/yyyy";
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self loadData];
    
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

- (void) loadData
{
    Receipt *receipt = [self.dataService fetchReceiptForReceiptID: self.receiptID];
    
    if (receipt)
    {
        (self.dateLabel).text = [self.dateFormatter stringFromDate: receipt.dateCreated];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSArray *catagories = [self.dataService fetchCategories];
    
    self.allCatagories = catagories;
    
    NSMutableArray *catagorySelections = [NSMutableArray new];
    
    for (ItemCategory *category in self.allCatagories)
    {
        [catagorySelections addObject: category.name];
    }
    
    self.catagoryPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: catagorySelections];
    self.catagoryPickerViewController.highlightedSelectionIndex = -1;
    self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.catagoryPickerViewController];
    (self.catagoryPickerViewController).delegate = self;

    self.currentlySelectedRecord = nil;

    self.recordsDictionary = [NSMutableDictionary new];
    self.catagoriesUsedByThisReceipt = [NSMutableArray new];

    // get all the items in this receipt
    // load category records for this receipt
    NSArray *records = [self.dataService fetchRecordsForReceiptID: self.receiptID];
    
    if (!records || records.count == 0)
    {
        [self.noItemsShield setHidden: NO];
        
        [self.view bringSubviewToFront: self.noItemsShield];
    }
    else
    {
        [self.noItemsShield setHidden: YES];
    }
    
    // get all the catagories used in this receipt
    for (Record *record in records)
    {
        // get the category of this Record
        ItemCategory *category = [self.dataService fetchCategory: record.categoryID];
        
        if (![self.catagoriesUsedByThisReceipt containsObject: category])
        {
            [self.catagoriesUsedByThisReceipt addObject: category];
        }
        
        NSMutableArray *recordsOfThisCatagory = (self.recordsDictionary)[category.localID];
        
        if (!recordsOfThisCatagory)
        {
            recordsOfThisCatagory = [NSMutableArray new];
        }
        
        [recordsOfThisCatagory addObject: record];
        
        self.recordsDictionary[category.localID] = recordsOfThisCatagory;
    }
    
    // Sort each recordsOfThisCatagory by Unit Type order: Item, ML, L, G, KG
    for (NSString *catagoryIDKey in self.recordsDictionary.allKeys)
    {
        NSMutableArray *unsortedRecordsOfThisCatagory = (self.recordsDictionary)[catagoryIDKey];
        
        NSArray *sortedRecordsOfThisCatagory = [unsortedRecordsOfThisCatagory sortedArrayUsingComparator: ^NSComparisonResult (Record *a, Record *b)
        {
            
            return a.unitType > b.unitType;
            
        }];
        
        (self.recordsDictionary)[catagoryIDKey] = sortedRecordsOfThisCatagory;
    }

    [self refreshPieChart];

    [self.receiptItemsTable reloadData];
}

- (void) refreshPieChart
{
    self.slicePercentages = [NSMutableArray new];
    self.sliceColors = [NSMutableArray new];
    self.sliceNames = [NSMutableArray new];

    float totalAmount = 0;

    for (NSMutableArray *records in self.recordsDictionary.allValues)
    {
        for (Record *record in records)
        {
            totalAmount = totalAmount + [record calculateTotal];
        }
    }

    // calculate the percentage of total of each category of items and
    // populate the self.slices, self.sliceColors, and self.sliceNames arrays
    for (ItemCategory *category in self.catagoriesUsedByThisReceipt)
    {
        [self.sliceColors addObject: category.color];
        [self.sliceNames addObject: category.name];

        NSMutableArray *recordsOfThisCatagory = (self.recordsDictionary)[category.localID];

        float totalForThisCatagory = 0;

        for (Record *record in recordsOfThisCatagory)
        {
            totalForThisCatagory = totalForThisCatagory + [record calculateTotal];
        }

        [self.slicePercentages addObject: [NSNumber numberWithInt: totalForThisCatagory * 100 / totalAmount]];
    }

    [self.pieChart reloadData];
}

- (NSInteger) getTotalNumberOfRecordsFromRecordsDictionary
{
    NSInteger total = 0;

    for (NSMutableArray *records in self.recordsDictionary.allValues)
    {
        total = total + records.count;
    }

    return total;
}

- (NSInteger) getRecordPosition: (Record *) recordToFind
{
    NSInteger position = 0;

    BOOL foundAlready = NO;

    for (NSString *catagoryID in self.recordsDictionary.allKeys)
    {
        if (foundAlready)
        {
            break;
        }

        NSMutableArray *records = (self.recordsDictionary)[catagoryID];

        for (Record *record in records)
        {
            if ([recordToFind.localID isEqualToString: record.localID])
            {
                foundAlready = YES;
                break;
            }

            position++;
        }
    }

    return position;
}

-(void)deleteRecordFromRecordsDictionary:(Record *)recordToDelete
{
    for (NSString *catagoryID in self.recordsDictionary.allKeys)
    {
        NSMutableArray *records = [(self.recordsDictionary)[catagoryID] mutableCopy];
        
        if ([records containsObject:recordToDelete])
        {
            [records removeObject:recordToDelete];
            
            (self.recordsDictionary)[catagoryID] = records;
        }
    }
}

- (Record *) getNthRecordFromRecordsDictionary: (NSInteger) nTh
{
    for (NSString *catagoryID in self.recordsDictionary.allKeys)
    {
        NSMutableArray *records = (self.recordsDictionary)[catagoryID];

        if (nTh < records.count)
        {
            return records[nTh];
        }
        else
        {
            nTh = nTh - records.count;
        }
    }

    return nil;
}

- (ItemCategory *) getCatagoryOfNthRecordFromRecordsDictionary: (NSInteger) nTh
{
    for (NSString *catagoryID in self.recordsDictionary.allKeys)
    {
        NSMutableArray *records = (self.recordsDictionary)[catagoryID];

        if (nTh < records.count)
        {
            return [self getCatagoryFromCatagoryID: catagoryID];
        }
        else
        {
            nTh = nTh - records.count;
        }
    }

    return nil;
}

- (ItemCategory *) getCatagoryFromCatagoryID: (NSString *) catagoryID
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *category = [self.catagoriesUsedByThisReceipt filteredArrayUsingPredicate: findCatagories];

    return category.firstObject;
}

- (void) setCurrentlySelectedRecord: (Record *) currentlySelectedRecord
{
    if (_currentlySelectedRecord != currentlySelectedRecord)
    {
        _currentlySelectedRecord = currentlySelectedRecord;

        [self.receiptItemsTable reloadData];
    }
}

- (void) doneWithKeyboard
{
    [self.view endEditing: YES];
}

#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification events

// Called when the UIKeyboardDidShowNotification is sent.
- (void) keyboardWillShow: (NSNotification *) aNotification
{
    NSDictionary *info = aNotification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self.view scrollToY: 0 - kbSize.height];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void) keyboardWillHide: (NSNotification *) aNotification
{
    [self.view scrollToY: 0];
}

#pragma mark - Button press events

- (IBAction) viewReceiptButtonPressed: (UIButton *) sender
{
    if (self.cameFromReceiptCheckingViewController)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
    else
    {
        // push ReceiptCheckingViewController
        [self.navigationController pushViewController: [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID: self.receiptID cameFromReceiptBreakDownViewController: YES] animated: YES];
    }
}

- (void) transferButtonPressed: (UIButton *) sender
{
    CGRect rectOfCellInTableView = [self.receiptItemsTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow: sender.tag * 2 + 1 inSection: 0]];
    CGRect rectOfCellInSuperview = [self.receiptItemsTable convertRect: rectOfCellInTableView toView: (self.receiptItemsTable).superview];
    
    CGRect tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + sender.frame.origin.x + sender.frame.size.width / 2,
                                 rectOfCellInSuperview.origin.y +  sender.frame.origin.y + sender.frame.size.height / 2,
                                 1,
                                 1);
    
    [self.selectionPopover presentPopoverFromRect: tinyRect
                                           inView: self.view
                         permittedArrowDirections: (WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown)
                                         animated: YES];
}

- (void) deleteButtonPressed: (UIButton *) sender
{
    Record *thisRecord = [self getNthRecordFromRecordsDictionary: sender.tag];
    
    if ([self.manipulationService deleteRecord: thisRecord.localID save:YES])
    {
        [self loadData];
    }
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.selectionPopover dismissPopoverAnimated: YES];

    // change the current selected record to this new category
    ItemCategory *chosenCatagory = (self.allCatagories)[index];

    if ([self.currentlySelectedRecord.categoryID isEqualToString: chosenCatagory.localID])
    {
        return;
    }

    self.currentlySelectedRecord.categoryID = chosenCatagory.localID;

    if ([self.manipulationService modifyRecord: self.currentlySelectedRecord save:YES])
    {
        [self loadData];
    }
}

#pragma mark - XYPieChart Data Source

- (NSUInteger) numberOfSlicesInPieChart: (XYPieChart *) pieChart
{
    return self.slicePercentages.count;
}

- (CGFloat) pieChart: (XYPieChart *) pieChart valueForSliceAtIndex: (NSUInteger) index
{
    return [(self.slicePercentages)[index] intValue];
}

- (UIColor *) pieChart: (XYPieChart *) pieChart colorForSliceAtIndex: (NSUInteger) index
{
    return (self.sliceColors)[(index % self.sliceColors.count)];
}

- (NSString *) pieChart: (XYPieChart *) pieChart textForSliceAtIndex: (NSUInteger) index
{
    NSString *sliceText = [NSString stringWithFormat: @"%@\n%d%%",
                           (self.sliceNames)[(index % self.sliceNames.count)],
                           [(self.slicePercentages)[index] intValue]];

    return sliceText;
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing: (UITextField *) textField
{
    Record *thisRecord = [self getNthRecordFromRecordsDictionary: textField.tag];

    self.currentlySelectedRecord = thisRecord;

    [textField becomeFirstResponder];
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    BOOL needToRefreshTable = NO;
    
    // determine if this textField is a quantityField or pricePerItemField
    if (textField.tag >= kPricePerItemFieldTagOffset)
    {
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: (textField.tag - kPricePerItemFieldTagOffset)];

        // this is a pricePerItemField
        DLog(@"pricePerItemField edited");

        if (!textField.text.length)
        {
            textField.text = @"0.00";
        }

        thisRecord.amount = (textField.text).floatValue;

        if (thisRecord.amount > 0)
        {
            if ([self.manipulationService modifyRecord: thisRecord save:YES])
            {
                DLog(@"Record %@ saved", thisRecord.localID);
            }
        }
        else
        {
            if ([self.manipulationService deleteRecord: thisRecord.localID save:YES])
            {
                DLog(@"Record %@ deleted", thisRecord.localID);
                
                [self deleteRecordFromRecordsDictionary:thisRecord];
                
                needToRefreshTable = YES;
            }
        }
    }
    else
    {
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: textField.tag];

        // this is a quantityField
        DLog(@"quantityField edited");

        if (!textField.text.length)
        {
            textField.text = @"0";
        }

        thisRecord.quantity = (textField.text).integerValue;

        if (thisRecord.quantity > 0)
        {
            if ([self.manipulationService modifyRecord: thisRecord save:YES])
            {
                DLog(@"Record %@ saved", thisRecord.localID);
            }
        }
        else
        {
            if ([self.manipulationService deleteRecord: thisRecord.localID save:YES])
            {
                DLog(@"Record %@ deleted", thisRecord.localID);
                
                [self deleteRecordFromRecordsDictionary:thisRecord];
                
                needToRefreshTable = YES;
            }
        }
    }

    [self refreshPieChart];
    
    if (needToRefreshTable)
    {
        self.currentlySelectedRecord = nil;
        
        [self.receiptItemsTable reloadData];
    }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];

    Record *thisRecord = [self getNthRecordFromRecordsDictionary: textField.tag];

    self.currentlySelectedRecord = thisRecord;

    return NO;
}

- (void) textFieldDidChange: (UITextField *) textField
{
    Record *thisRecord = [self getNthRecordFromRecordsDictionary: textField.tag];

    self.currentlySelectedRecord = thisRecord;
}

#pragma mark - XYPieChart Delegate
- (void) pieChart: (XYPieChart *) pieChart didDeselectSliceAtIndex: (NSUInteger) index
{
    // does same thing as didSelectSliceAtIndex
    [self pieChart: pieChart didSelectSliceAtIndex: index];
}

- (void) pieChart: (XYPieChart *) pieChart didSelectSliceAtIndex: (NSUInteger) index
{
    ItemCategory *thisCatagory = (self.catagoriesUsedByThisReceipt)[index];

    DLog(@"ItemCategory %@ clicked", thisCatagory.name);

    NSMutableArray *recordsOfThisCatagory = (self.recordsDictionary)[thisCatagory.localID];

    if (self.currentlySelectedRecord != recordsOfThisCatagory.firstObject)
    {
        self.currentlySelectedRecord = recordsOfThisCatagory.firstObject;

        // scroll the table to the row that shows self.currentlySelectedRecord
        [self.receiptItemsTable scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: [self getRecordPosition: self.currentlySelectedRecord] * 2 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return [self getTotalNumberOfRecordsFromRecordsDictionary] * 2;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a ReceiptBreakDownItemTableViewCell
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellId = kReceiptBreakDownItemTableViewCellIdentifier;
        ReceiptBreakDownItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[ReceiptBreakDownItemTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                            reuseIdentifier  : cellId];
        }

        cell.clipsToBounds = YES;

        Record *previousRecord;
        if (indexPath.row >= 2)
        {
            previousRecord = [self getNthRecordFromRecordsDictionary:(indexPath.row - 2) / 2];
        }
        
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: indexPath.row / 2];
        ItemCategory *thisCatagory = [self getCatagoryOfNthRecordFromRecordsDictionary: indexPath.row / 2];

        cell.catagoryColor = thisCatagory.color;
        
        cell.catagoryName.text = thisCatagory.name;

        cell.quantityField.tag = indexPath.row / 2;
        (cell.quantityField).delegate = self;
        (cell.quantityField).text = [NSString stringWithFormat: @"%ld", (long)thisRecord.quantity];
        [self.lookAndFeel applyGrayBorderTo: cell.quantityField];
        cell.quantityField.inputAccessoryView = self.numberToolbar;
        [cell.quantityField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];

        cell.pricePerItemField.tag = indexPath.row / 2 + kPricePerItemFieldTagOffset;
        (cell.pricePerItemField).delegate = self;
        (cell.pricePerItemField).text = [NSString stringWithFormat: @"%.2f", thisRecord.amount];
        [self.lookAndFeel applyGreenBorderTo: cell.pricePerItemField];
        cell.pricePerItemField.inputAccessoryView = self.numberToolbar;
        [cell.pricePerItemField addTarget: self
                                   action: @selector(textFieldDidChange:)
                         forControlEvents: UIControlEventEditingChanged];

        if (self.currentlySelectedRecord)
        {
            if (thisRecord == self.currentlySelectedRecord)
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
            
            if (previousRecord)
            {
                // hide cell labels if the previous cell is same type
                if (previousRecord.unitType == thisRecord.unitType)
                {
                    [cell hideLabels];
                }
                else
                {
                    [cell showLabels];
                }
            }
            else
            {
                // this is the first row
                [cell showLabels];
            }
        }
        
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorBoxView];
        
        if (thisRecord.unitType == UnitTypesUnitItem)
        {
            [cell setToDisplayItem];
        }
        else
        {
            [cell setToDisplayUnit:thisRecord.unitType];
        }

        return cell;
    }
    // display a ReceiptBreakDownToolBarTableViewCell
    else
    {
        static NSString *cellId = kReceiptBreakDownToolBarTableViewCellIdentifier;
        ReceiptBreakDownToolBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[ReceiptBreakDownToolBarTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        cell.clipsToBounds = YES;

        cell.transferButton.tag = (indexPath.row - 1) / 2;
        cell.deleteButton.tag = (indexPath.row - 1) / 2;
        
        [cell.transferButton setLookAndFeel:self.lookAndFeel];
        [cell.deleteButton setLookAndFeel:self.lookAndFeel];

        [cell.transferButton addTarget: self
                                action: @selector(transferButtonPressed:)
                      forControlEvents: UIControlEventTouchUpInside];
        [cell.deleteButton addTarget: self
                              action: @selector(deleteButtonPressed:)
                    forControlEvents: UIControlEventTouchUpInside];

        return cell;
    }

    return nil;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a ReceiptBreakDownItemTableViewCell
    if (indexPath.row % 2 == 0)
    {
        return kReceiptBreakDownItemTableViewCellHeight;
    }
    // display a kReceiptBreakDownToolBarTableViewCell
    else
    {
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: (indexPath.row - 1) / 2];

        // only show the row if currentlySelectedRecord == thisRecord

        if (thisRecord == self.currentlySelectedRecord)
        {
            return kReceiptBreakDownToolBarTableViewCellHeight;
        }
    }

    return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Record *thisRecord = [self getNthRecordFromRecordsDictionary: indexPath.row / 2];

    // clicked a ReceiptBreakDownItemTableViewCell
    if (indexPath.row % 2 == 0)
    {
        if (self.currentlySelectedRecord == thisRecord)
        {
            // deselect
            self.currentlySelectedRecord = nil;
        }
        else
        {
            self.currentlySelectedRecord = thisRecord;

            [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }
    }
}

@end