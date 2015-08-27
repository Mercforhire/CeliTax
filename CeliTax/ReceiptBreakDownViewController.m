//
// ReceiptBreakDownViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-31.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptBreakDownViewController.h"
#import "XYPieChart.h"
#import "Record.h"
#import "Catagory.h"
#import "ReceiptBreakDownItemTableViewCell.h"
#import "ReceiptBreakDownToolBarTableViewCell.h"
#import "UIView+Helper.h"
#import "Receipt.h"
#import "ViewControllerFactory.h"
#import "ReceiptCheckingViewController.h"
#import "WYPopoverController.h"
#import "SelectionsPickerViewController.h"
#import "TutorialManager.h"
#import "TutorialStep.h"
#import "ConfigurationManager.h"
#import "HollowGreenButton.h"
#import "TutorialManager.h"
#import "TutorialStep.h"

@interface ReceiptBreakDownViewController () <XYPieChartDelegate, XYPieChartDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SelectionsPickerPopUpDelegate, TutorialManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noItemsShield;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet HollowGreenButton *viewReceiptButton;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *receiptItemsTable;
@property (nonatomic, strong) UIToolbar *numberToolbar;
@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *catagoryPickerViewController;

// group records into it's catagory as KEY
@property (nonatomic, strong) NSMutableDictionary *recordsDictionary;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *allCatagories;
@property (nonatomic, strong) NSMutableArray *catagoriesUsedByThisReceipt;
@property (nonatomic, strong) NSMutableArray *slicePercentages;
@property (nonatomic, strong) NSMutableArray *sliceColors;
@property (nonatomic, strong) NSMutableArray *sliceNames;

@property (nonatomic, strong) Record *currentlySelectedRecord;

//Tutorials
@property (nonatomic, strong) NSMutableArray *tutorials;
@property (nonatomic) NSUInteger currentTutorialStep;

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
    // get rid of the visual aid backgrounds
    [self.pieChart setBackgroundColor: [UIColor clearColor]];
    [self.pieChart setDataSource: self];
    [self.pieChart setDelegate: self];
    [self.pieChart setStartPieAngle: M_PI_2];
    [self.pieChart setAnimationSpeed: 1.0];
    [self.pieChart setLabelFont: [UIFont latoFontOfSize: 10]];
    [self.pieChart setLabelRadius: self.pieChart.frame.size.width / 4];
    [self.pieChart setShowPercentage: NO];
    [self.pieChart setPieBackgroundColor: [UIColor clearColor]];
    [self.pieChart setUserInteractionEnabled: YES];
    [self.pieChart setLabelShadowColor: [UIColor blackColor]];
    [self.pieChart setSelectedSliceOffsetRadius: 0];

    // set up receiptItemsTable
    UINib *receiptBreakDownItemTableViewCell = [UINib nibWithNibName: @"ReceiptBreakDownItemTableViewCell" bundle: nil];
    [self.receiptItemsTable registerNib: receiptBreakDownItemTableViewCell forCellReuseIdentifier: kReceiptBreakDownItemTableViewCellIdentifier];

    UINib *receiptBreakDownToolBarTableViewCell = [UINib nibWithNibName: @"ReceiptBreakDownToolBarTableViewCell" bundle: nil];
    [self.receiptItemsTable registerNib: receiptBreakDownToolBarTableViewCell forCellReuseIdentifier: kReceiptBreakDownToolBarTableViewCellIdentifier];

    // toolbar for entering price and qty
    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *doneToolbarButton = [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneWithKeyboard)];
    [doneToolbarButton setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont latoBoldFontOfSize: 15], NSFontAttributeName, self.lookAndFeel.appGreenColor, NSForegroundColorAttributeName, nil] forState: UIControlStateNormal];

    self.numberToolbar.items = [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil], doneToolbarButton, nil];
    [self.numberToolbar sizeToFit];

    [self.viewReceiptButton setLookAndFeel:self.lookAndFeel];
}

#pragma mark - Life Cycle Functions

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    [self.receiptItemsTable setDelegate: self];
    [self.receiptItemsTable setDataSource: self];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat: @"dd/MM/yyyy"];
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
    
    if (![self.tutorialManager hasTutorialBeenShown])
    {
        if ([self.tutorialManager automaticallyShowTutorialNextTime])
        {
            [self setupTutorials];
            
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

- (void) loadData
{
    Receipt *receipt = [self.dataService fetchReceiptForReceiptID: self.receiptID];
    
    if (receipt)
    {
        [self.dateLabel setText: [self.dateFormatter stringFromDate: receipt.dateCreated]];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.allCatagories = catagories;
    
    NSMutableArray *catagorySelections = [NSMutableArray new];
    
    for (Catagory *catagory in self.allCatagories)
    {
        [catagorySelections addObject: catagory.name];
    }
    
    self.catagoryPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: catagorySelections];
    self.catagoryPickerViewController.highlightedSelectionIndex = -1;
    self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.catagoryPickerViewController];
    [self.catagoryPickerViewController setDelegate: self];

    self.currentlySelectedRecord = nil;

    self.recordsDictionary = [NSMutableDictionary new];
    self.catagoriesUsedByThisReceipt = [NSMutableArray new];

    // get all the items in this receipt
    // load catagory records for this receipt
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
        // get the catagory of this Record
        Catagory *catagory = [self.dataService fetchCatagory: record.catagoryID];
        
        if (![self.catagoriesUsedByThisReceipt containsObject: catagory])
        {
            [self.catagoriesUsedByThisReceipt addObject: catagory];
        }
        
        NSMutableArray *recordsOfThisCatagory = [self.recordsDictionary objectForKey: catagory.localID];
        
        if (!recordsOfThisCatagory)
        {
            recordsOfThisCatagory = [NSMutableArray new];
        }
        
        [recordsOfThisCatagory addObject: record];
        
        [self.recordsDictionary setObject: recordsOfThisCatagory forKey: catagory.localID];
    }
    
    // Sort each recordsOfThisCatagory by Unit Type order: Item, ML, L, G, KG
    for (NSString *catagoryIDKey in self.recordsDictionary.allKeys)
    {
        NSMutableArray *unsortedRecordsOfThisCatagory = [self.recordsDictionary objectForKey:catagoryIDKey];
        
        NSArray *sortedRecordsOfThisCatagory = [unsortedRecordsOfThisCatagory sortedArrayUsingComparator: ^NSComparisonResult (Record *a, Record *b)
        {
            
            return a.unitType > b.unitType;
            
        }];
        
        [self.recordsDictionary setObject: sortedRecordsOfThisCatagory forKey: catagoryIDKey];
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

    // calculate the percentage of total of each catagory of items and
    // populate the self.slices, self.sliceColors, and self.sliceNames arrays
    for (Catagory *catagory in self.catagoriesUsedByThisReceipt)
    {
        [self.sliceColors addObject: catagory.color];
        [self.sliceNames addObject: catagory.name];

        NSMutableArray *recordsOfThisCatagory = [self.recordsDictionary objectForKey: catagory.localID];

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

        NSMutableArray *records = [self.recordsDictionary objectForKey: catagoryID];

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

- (Record *) getNthRecordFromRecordsDictionary: (NSInteger) nTh
{
    for (NSString *catagoryID in self.recordsDictionary.allKeys)
    {
        NSMutableArray *records = [self.recordsDictionary objectForKey: catagoryID];

        if (nTh < records.count)
        {
            return [records objectAtIndex: nTh];
        }
        else
        {
            nTh = nTh - records.count;
        }
    }

    return nil;
}

- (Catagory *) getCatagoryOfNthRecordFromRecordsDictionary: (NSInteger) nTh
{
    for (NSString *catagoryID in self.recordsDictionary.allKeys)
    {
        NSMutableArray *records = [self.recordsDictionary objectForKey: catagoryID];

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

- (Catagory *) getCatagoryFromCatagoryID: (NSString *) catagoryID
{
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"localID == %@", catagoryID];
    NSArray *catagory = [self.catagoriesUsedByThisReceipt filteredArrayUsingPredicate: findCatagories];

    return [catagory firstObject];
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
    CGRect rectOfCellInSuperview = [self.receiptItemsTable convertRect: rectOfCellInTableView toView: [self.receiptItemsTable superview]];
    
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

    // change the current selected record to this new catagory
    Catagory *chosenCatagory = [self.allCatagories objectAtIndex: index];

    if ([self.currentlySelectedRecord.catagoryID isEqualToString: chosenCatagory.localID])
    {
        return;
    }

    self.currentlySelectedRecord.catagoryID = chosenCatagory.localID;

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
    return [[self.slicePercentages objectAtIndex: index] intValue];
}

- (UIColor *) pieChart: (XYPieChart *) pieChart colorForSliceAtIndex: (NSUInteger) index
{
    return [self.sliceColors objectAtIndex: (index % self.sliceColors.count)];
}

- (NSString *) pieChart: (XYPieChart *) pieChart textForSliceAtIndex: (NSUInteger) index
{
    NSString *sliceText = [NSString stringWithFormat: @"%@\n%d%%",
                           [self.sliceNames objectAtIndex: (index % self.sliceNames.count)],
                           [[self.slicePercentages objectAtIndex: index] intValue]];

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
    // determine if this textField is a quantityField or pricePerItemField

    if (textField.tag >= kPricePerItemFieldTagOffset)
    {
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: (textField.tag - kPricePerItemFieldTagOffset) / 2];

        // this is a pricePerItemField
        DLog(@"pricePerItemField edited");

        if (!textField.text.length)
        {
            textField.text = @"0.00";
        }

        thisRecord.amount = [textField.text floatValue];

        if ([self.manipulationService modifyRecord: thisRecord save:YES])
        {
            DLog(@"Record %@ saved", thisRecord.localID);
        }
    }
    else
    {
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: textField.tag / 2];

        // this is a quantityField
        DLog(@"quantityField edited");

        if (!textField.text.length)
        {
            textField.text = @"0";
        }

        thisRecord.quantity = [textField.text integerValue];

        if ([self.manipulationService modifyRecord: thisRecord save:YES])
        {
            DLog(@"Record %@ saved", thisRecord.localID);
        }
    }

    [self refreshPieChart];
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
    Catagory *thisCatagory = [self.catagoriesUsedByThisReceipt objectAtIndex: index];

    DLog(@"Catagory %@ clicked", thisCatagory.name);

    NSMutableArray *recordsOfThisCatagory = [self.recordsDictionary objectForKey: thisCatagory.localID];

    if (self.currentlySelectedRecord != [recordsOfThisCatagory firstObject])
    {
        self.currentlySelectedRecord = [recordsOfThisCatagory firstObject];

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
        Catagory *thisCatagory = [self getCatagoryOfNthRecordFromRecordsDictionary: indexPath.row / 2];

        cell.catagoryColor = thisCatagory.color;
        
        cell.catagoryName.text = thisCatagory.name;

        cell.quantityField.tag = indexPath.row / 2;
        [cell.quantityField setDelegate: self];
        [cell.quantityField setText: [NSString stringWithFormat: @"%ld", (long)thisRecord.quantity]];
        [self.lookAndFeel applyGrayBorderTo: cell.quantityField];
        cell.quantityField.inputAccessoryView = self.numberToolbar;
        [cell.quantityField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];

        cell.pricePerItemField.tag = kPricePerItemFieldTagOffset + indexPath.row / 2;
        [cell.pricePerItemField setDelegate: self];
        [cell.pricePerItemField setText: [NSString stringWithFormat: @"%.2f", thisRecord.amount]];
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
        
        if (thisRecord.unitType == UnitItem)
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

#pragma mark - Tutorial

typedef enum : NSUInteger
{
    TutorialStep1,
    TutorialStep2,
    TutorialStep3,
    TutorialStepsCount,
} TutorialSteps;

-(void)setupTutorials
{
    [self.tutorialManager setDelegate:self];
    
    self.tutorials = [NSMutableArray new];
    
    TutorialStep *tutorialStep1 = [TutorialStep new];
    
    tutorialStep1.text = @"Manage items you have allocated to a single receipt. Easily view the breakdown by GF category in the pie chart.";
    tutorialStep1.rightButtonTitle = @"Continue";
    tutorialStep1.pointsUp = YES;
    tutorialStep1.highlightedItemRect = self.pieChart.frame;
    
    [self.tutorials addObject:tutorialStep1];
    
    TutorialStep *tutorialStep2 = [TutorialStep new];
    
    tutorialStep2.text = @"Quickly Transfer, Edit, or Delete items as needed.";
    tutorialStep2.leftButtonTitle = @"Back";
    tutorialStep2.rightButtonTitle = @"Continue";
    tutorialStep2.pointsUp = NO;
    tutorialStep2.highlightedItemRect = self.receiptItemsTable.frame;
    
    [self.tutorials addObject:tutorialStep2];
    
    TutorialStep *tutorialStep3 = [TutorialStep new];
    
    tutorialStep3.text = @"Click to return to your receipt and keep allocating purchases.";
    tutorialStep3.leftButtonTitle = @"Back";
    tutorialStep3.rightButtonTitle = @"Continue";
    tutorialStep3.pointsUp = YES;
    tutorialStep3.highlightedItemRect = self.viewReceiptButton.frame;
    
    [self.tutorials addObject:tutorialStep3];
    
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
        default:
            break;
    }
}

- (void) tutorialRightSideButtonPressed
{
    switch (self.currentTutorialStep)
    {
        case TutorialStep1:
        {
            //select the first item in receiptItemsTable
            [self tableView:self.receiptItemsTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            //Go to Step 2
            [self displayTutorialStep:TutorialStep2];
        }
            break;
            
        case TutorialStep2:
            //Go to Step 3
            [self displayTutorialStep:TutorialStep3];
            break;
            
        case TutorialStep3:
        {
            [self.tutorialManager setAutomaticallyShowTutorialNextTime];
            
            [self.tutorialManager dismissTutorial:^{
                //Go to Receipt Breakdown view
                [self viewReceiptButtonPressed:self.viewReceiptButton];
            }];
        }
            break;
    
        default:
            break;
    }
}

@end