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

@interface ReceiptBreakDownViewController () <XYPieChartDelegate, XYPieChartDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SelectionsPickerPopUpDelegate>

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewReceiptButton;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *receiptItemsTable;
@property (nonatomic, strong) UIToolbar *numberToolbar;
@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *catagoryPickerViewController;

// group records into it's catagory as KEY
@property (nonatomic, strong) NSMutableDictionary *recordsDictionary;

@property (nonatomic, strong) NSArray *allCatagories;
@property (nonatomic, strong) NSMutableArray *catagoriesUsedByThisReceipt;
@property (nonatomic, strong) NSMutableArray *slicePercentages;
@property (nonatomic, strong) NSMutableArray *sliceColors;
@property (nonatomic, strong) NSMutableArray *sliceNames;

@property (nonatomic, strong) Record *currentlySelectedRecord;
@property (weak, nonatomic) IBOutlet UILabel *noItemsShield;

@end

#define kReceiptBreakDownItemTableViewCellIdentifier        @"ReceiptBreakDownItemTableViewCell"
#define kReceiptBreakDownToolBarTableViewCellIdentifier     @"ReceiptBreakDownToolBarTableViewCell"

#define kReceiptBreakDownItemTableViewCellHeight            44
#define kReceiptBreakDownToolBarTableViewCellHeight         60
#define kPricePerItemFieldTagOffset                         1000

@implementation ReceiptBreakDownViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // set up pieChart
    // get rid of the visual aid backgrounds
    [self.pieChart setBackgroundColor: [UIColor clearColor]];
    [self.pieChart setDataSource: self];
    [self.pieChart setDelegate: self];
    [self.pieChart setStartPieAngle: M_PI_2];
    [self.pieChart setAnimationSpeed: 1.0];
    [self.pieChart setLabelFont: [UIFont systemFontOfSize: 14]];
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

    [self.receiptItemsTable setDelegate: self];
    [self.receiptItemsTable setDataSource: self];

    self.numberToolbar = [[UIToolbar alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.numberToolbar.barStyle = UIBarStyleDefault;
    self.numberToolbar.items = [NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                [[UIBarButtonItem alloc]initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneWithKeyboard)],
                                nil];
    [self.numberToolbar sizeToFit];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat: @"dd/MM/yyyy"];

    [self.dataService fetchReceiptForReceiptID: self.receiptID success: ^(Receipt *receipt) {
        [self.dateLabel setText: [self.dateFormatter stringFromDate: receipt.dateCreated]];
    } failure: ^(NSString *reason) {
        // should not happen
    }];

    [self.dataService fetchCatagoriesSuccess: ^(NSArray *catagories) {
        self.allCatagories = catagories;

        NSMutableArray *catagorySelections = [NSMutableArray new];

        for (Catagory *catagory in self.allCatagories)
        {
            [catagorySelections addObject: catagory.name];
        }

        self.catagoryPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: catagorySelections];
        self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.catagoryPickerViewController];
        [self.catagoryPickerViewController setDelegate: self];
    } failure: ^(NSString *reason) {
        // should not happen
    }];
}

- (void) loadData
{
    self.currentlySelectedRecord = nil;
    
    self.recordsDictionary = [NSMutableDictionary new];
    self.catagoriesUsedByThisReceipt = [NSMutableArray new];

    // get all the items in this receipt
    // load catagory records for this receipt
    [self.dataService fetchRecordsForReceiptID: self.receiptID
                                       success: ^(NSArray *records) {
        if (!records || records.count == 0)
        {
            [self.noItemsShield setHidden: NO];

            [self.view bringSubviewToFront: self.noItemsShield];
        }

        // get all the catagories used in this receipt
        for (Record *record in records)
        {
            // get the catagory of this Record
            [self.dataService fetchCatagory: record.catagoryID
                                    Success: ^(Catagory *catagory) {
                if (![self.catagoriesUsedByThisReceipt containsObject: catagory])
                {
                    [self.catagoriesUsedByThisReceipt addObject: catagory];
                }

                NSMutableArray *recordsOfThisCatagory = [self.recordsDictionary objectForKey: catagory.identifer];

                if (!recordsOfThisCatagory)
                {
                    recordsOfThisCatagory = [NSMutableArray new];
                }

                [recordsOfThisCatagory addObject: record];

                [self.recordsDictionary setObject: recordsOfThisCatagory forKey: catagory.identifer];
            } failure: ^(NSString *reason) {
                NSAssert(NO, @"INVALID RECORD");
            }];
        }
    } failure: ^(NSString *reason) {
        // failure
    }];

    [self refreshPieChart];

    [self.receiptItemsTable reloadData];
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
            totalAmount = totalAmount + record.quantity * record.amount;
        }
    }

    DLog(@"Receipt total:%.2f", totalAmount);

    // calculate the percentage of total of each catagory of items and
    // populate the self.slices, self.sliceColors, and self.sliceNames arrays
    for (Catagory *catagory in self.catagoriesUsedByThisReceipt)
    {
        [self.sliceColors addObject: catagory.color];
        [self.sliceNames addObject: catagory.name];

        NSMutableArray *recordsOfThisCatagory = [self.recordsDictionary objectForKey: catagory.identifer];

        float totalForThisCatagory = 0;

        for (Record *record in recordsOfThisCatagory)
        {
            totalForThisCatagory = totalForThisCatagory + record.amount * record.quantity;
        }

        [self.slicePercentages addObject: [NSNumber numberWithInt: totalForThisCatagory * 100 / totalAmount]];

        DLog("Catagory %@, Catagory Total %.2f, Percentage of total %@", catagory.name, totalForThisCatagory, [self.slicePercentages lastObject]);
    }

    [self.pieChart reloadData];
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

- (void) doneWithKeyboard
{
    [self.view endEditing: YES];
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
    NSPredicate *findCatagories = [NSPredicate predicateWithFormat: @"identifer == %@", catagoryID];
    NSArray *catagory = [self.catagoriesUsedByThisReceipt filteredArrayUsingPredicate: findCatagories];

    return [catagory firstObject];
}

- (void) transferButtonPressed: (UIButton *) sender
{
    Record *thisRecord = [self getNthRecordFromRecordsDictionary: sender.tag];

    DLog(@"Transfer button for record %@ pressed", thisRecord.identifer);

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

    DLog(@"Delete button for record %@ pressed", thisRecord.identifer);

    [self.manipulationService deleteRecord: thisRecord.identifer WithSuccess: ^{
        [self loadData];
    } andFailure: ^(NSString *reason) {
        // should not happen
    }];
}

- (void) setCurrentlySelectedRecord: (Record *) currentlySelectedRecord
{
    if (_currentlySelectedRecord != currentlySelectedRecord)
    {
        _currentlySelectedRecord = currentlySelectedRecord;

        [self.receiptItemsTable reloadData];
    }
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index
{
    [self.selectionPopover dismissPopoverAnimated: YES];

    // change the current selected record to this new catagory
    Catagory *chosenCatagory = [self.allCatagories objectAtIndex: index];

    if ([self.currentlySelectedRecord.catagoryID isEqualToString: chosenCatagory.identifer])
    {
        return;
    }

    self.currentlySelectedRecord.catagoryID = chosenCatagory.identifer;
    self.currentlySelectedRecord.catagoryName = chosenCatagory.name;

    [self.manipulationService modifyRecord: self.currentlySelectedRecord WithSuccess:^{
        [self loadData];
    } andFailure:^(NSString *reason) {
        DLog(@"self.manipulationService modifyRecord failed");
    }];
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
        // this is a pricePerItemField
        DLog(@"pricePerItemField edited");

        if (!textField.text.length)
        {
            textField.text = @"0.00";
        }

        self.currentlySelectedRecord.amount = [textField.text floatValue];

        [self.manipulationService modifyRecord: self.currentlySelectedRecord WithSuccess: ^{
            DLog(@"Record %@ saved", self.currentlySelectedRecord.identifer);
        } andFailure: ^(NSString *reason) {
            // should not happen
        }];
    }
    else
    {
        // this is a quantityField
        DLog(@"quantityField edited");

        if (!textField.text.length)
        {
            textField.text = @"0";
        }

        self.currentlySelectedRecord.quantity = [textField.text integerValue];

        [self.manipulationService modifyRecord: self.currentlySelectedRecord WithSuccess: ^{
            DLog(@"Record %@ saved", self.currentlySelectedRecord.identifer);
        } andFailure: ^(NSString *reason) {
            // should not happen
        }];
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

    NSMutableArray *recordsOfThisCatagory = [self.recordsDictionary objectForKey: thisCatagory.identifer];

    if (self.currentlySelectedRecord != [recordsOfThisCatagory firstObject])
    {
        self.currentlySelectedRecord = [recordsOfThisCatagory firstObject];
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

        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        cell.clipsToBounds = YES;

        Record *thisRecord = [self getNthRecordFromRecordsDictionary: indexPath.row / 2];
        Catagory *thisCatagory = [self getCatagoryOfNthRecordFromRecordsDictionary: indexPath.row / 2];

        [cell.colorBoxView setBackgroundColor: thisCatagory.color];

        cell.catagoryName.text = thisCatagory.name;

        cell.quantityField.tag = indexPath.row / 2;
        [cell.quantityField setDelegate: self];
        [cell.quantityField setText: [NSString stringWithFormat: @"%ld", thisRecord.quantity]];
        cell.quantityField.inputAccessoryView = self.numberToolbar;
        [cell.quantityField addTarget: self
                               action: @selector(textFieldDidChange:)
                     forControlEvents: UIControlEventEditingChanged];

        cell.pricePerItemField.tag = kPricePerItemFieldTagOffset + indexPath.row / 2;
        [cell.pricePerItemField setDelegate: self];
        [cell.pricePerItemField setText: [NSString stringWithFormat: @"%.2f", thisRecord.amount]];
        cell.pricePerItemField.inputAccessoryView = self.numberToolbar;
        [cell.pricePerItemField addTarget: self
                                   action: @selector(textFieldDidChange:)
                         forControlEvents: UIControlEventEditingChanged];

        return cell;
    }
    // display a kReceiptBreakDownToolBarTableViewCell
    else
    {
        static NSString *cellId = kReceiptBreakDownToolBarTableViewCellIdentifier;
        ReceiptBreakDownToolBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[ReceiptBreakDownToolBarTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        cell.clipsToBounds = YES;

        cell.transferButton.tag = indexPath.row / 2;
        cell.deleteButton.tag = indexPath.row / 2;

        [cell.transferButton addTarget: self action: @selector(transferButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
        [cell.deleteButton addTarget: self action: @selector(deleteButtonPressed:) forControlEvents: UIControlEventTouchUpInside];

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
        Record *thisRecord = [self getNthRecordFromRecordsDictionary: indexPath.row / 2];

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
    Catagory *thisCatagory = [self getCatagoryOfNthRecordFromRecordsDictionary: indexPath.row / 2];

    // clicked a ReceiptBreakDownItemTableViewCell
    if (indexPath.row % 2 == 0)
    {
        DLog(@"Catagory %@'s record %@ clicked", thisCatagory.name, thisRecord.identifer);

        if (self.currentlySelectedRecord == thisRecord)
        {
            // deselect
            self.currentlySelectedRecord = nil;
        }
        else
        {
            self.currentlySelectedRecord = thisRecord;
        }
    }
    // clicked a kReceiptBreakDownToolBarTableViewCell
    else
    {
        DLog(@"Catagory %@'s record %@ Tool Bar clicked", thisCatagory.name, thisRecord.identifer);
    }
}

@end