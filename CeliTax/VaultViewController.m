//
// VaultViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-02.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "VaultViewController.h"
#import "TimePeriodSelectionTableViewCell.h"
#import "ReceiptTimeTableViewCell.h"
#import "Receipt.h"
#import "WYPopoverController.h"
#import "SelectionsPickerViewController.h"
#import "ViewControllerFactory.h"
#import "Utils.h"
#import "M13Checkbox.h"
#import "SendReceiptsToViewController.h"
#import "AlertDialogsProvider.h"

typedef enum : NSUInteger
{
    TimePeriodRecent,
    TimePeriodPreviousWeek,
    TimePeriodPreviousMonth,
    TimePeriodViewAll,
    TimePeriodCount
} TimePeriodSelections;

#define kTimePeriodSelectionTableViewCellHeight         44
#define kTimePeriodSelectionTableViewCellIdentifier     @"TimePeriodSelectionTableViewCell"

#define kReceiptTimeTableViewCellHeight                 40
#define kReceiptTimeTableViewCellIdentifier             @"ReceiptTimeTableViewCell"

@interface VaultViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate, SendReceiptsViewPopUpDelegate>

@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (weak, nonatomic) IBOutlet M13Checkbox *selectAllCheckBox;
@property (weak, nonatomic) IBOutlet UITableView *uploadHistoryTable;
@property (weak, nonatomic) IBOutlet UIButton *downloadReceiptButton;
@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *taxYearPickerViewController;
@property (nonatomic, strong) WYPopoverController *sendReceiptsPopover;
@property (nonatomic, strong) SendReceiptsToViewController *sendReceiptsToViewController;

@property (nonatomic, strong) NSArray *recentUploadReceipts;
@property (nonatomic, strong) NSArray *previousWeekReceipts;
@property (nonatomic, strong) NSArray *previousMonthReceipts;
@property (nonatomic, strong) NSArray *viewAllReceipts;

@property (nonatomic) BOOL recentUploadSelected;
@property (nonatomic) BOOL previousWeekSelected;
@property (nonatomic) BOOL previousMonthSelected;
@property (nonatomic) BOOL viewAllSelected;

// NSNumbers of the years of all receipts timestamps, sorted from most recent to oldest
@property (nonatomic, strong) NSArray *yearsRange;

@property (nonatomic, strong) NSNumber *currentlySelectedYear;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) BOOL selectAllReceipts;
@property (nonatomic, strong) NSMutableDictionary *selectedReceipts;

@end

@implementation VaultViewController

- (void) setupUI
{
    [self.lookAndFeel applyHollowGreenButtonStyleTo: self.downloadReceiptButton];

    [self.selectAllCheckBox.titleLabel setFont: [UIFont latoFontOfSize: 13]];
    [self.selectAllCheckBox.titleLabel setTextColor: [UIColor blackColor]];
    [self.selectAllCheckBox setStrokeColor: [UIColor grayColor]];
    [self.selectAllCheckBox setCheckColor: self.lookAndFeel.appGreenColor];
    [self.selectAllCheckBox setCheckAlignment: M13CheckboxAlignmentLeft];
    [self.selectAllCheckBox.titleLabel setText: @"Select All"];

    UINib *timePeriodSelectionTableViewCell = [UINib nibWithNibName: @"TimePeriodSelectionTableViewCell" bundle: nil];
    UINib *receiptTimeTableViewCellTableViewCell = [UINib nibWithNibName: @"ReceiptTimeTableViewCell" bundle: nil];

    [self.uploadHistoryTable registerNib: timePeriodSelectionTableViewCell forCellReuseIdentifier: kTimePeriodSelectionTableViewCellIdentifier];
    [self.uploadHistoryTable registerNib: receiptTimeTableViewCellTableViewCell forCellReuseIdentifier: kReceiptTimeTableViewCellIdentifier];

    self.sendReceiptsToViewController = [self.viewControllerFactory createSendReceiptsToViewController];
    self.sendReceiptsPopover = [[WYPopoverController alloc] initWithContentViewController: self.sendReceiptsToViewController];
    [self.sendReceiptsPopover setTheme: [WYPopoverTheme theme]];

    WYPopoverTheme *popUpTheme = self.sendReceiptsPopover.theme;
    popUpTheme.fillTopColor = self.lookAndFeel.appGreenColor;
    popUpTheme.fillBottomColor = self.lookAndFeel.appGreenColor;

    [self.sendReceiptsPopover setTheme: popUpTheme];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupUI];

    self.selectedReceipts = [NSMutableDictionary new];

    self.uploadHistoryTable.dataSource = self;
    self.uploadHistoryTable.delegate = self;

    self.dateFormatter = [[NSDateFormatter alloc] init];

    UITapGestureRecognizer *taxYearPressedTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(taxYearPressed)];
    [self.taxYearLabel addGestureRecognizer: taxYearPressedTap];

    [self.selectAllCheckBox addTarget: self action: @selector(selectAllCheckChangedValue:) forControlEvents: UIControlEventValueChanged];

    [self.sendReceiptsToViewController setDelegate: self];

    [self.dataService fetchReceiptsYearsRange: ^(NSArray *yearsRange)
    {
        self.yearsRange = yearsRange;
        self.currentlySelectedYear = [self.yearsRange firstObject];

        NSMutableArray *yearSelections = [NSMutableArray new];

        for (NSNumber *year in yearsRange)
        {
            [yearSelections addObject: [NSString stringWithFormat: @"%ld Tax Year", (long)year.integerValue]];
        }

        self.taxYearPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: yearSelections];
        self.taxYearPickerViewController.highlightedSelectionIndex = -1;
        self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
        [self.taxYearPickerViewController setDelegate: self];
    }                                 failure: ^(NSString *reason) {
        // should not happen
    }];
}

- (IBAction) downloadReceiptsPressed: (UIButton *) sender
{
    // open up 'Send Receipts To' pop up

    [self.sendReceiptsPopover presentPopoverFromRect: self.downloadReceiptButton.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionDown animated: YES];
}

- (void) selectAllCheckChangedValue: (M13Checkbox *) checkBox
{
    DLog(@"Select All checkbox Value changed to %ld", (long)checkBox.checkState);

    if (checkBox.checkState == M13CheckboxStateChecked)
    {
        self.selectAllReceipts = YES;

        [self.downloadReceiptButton setEnabled: YES];
    }
    else
    {
        self.selectAllReceipts = NO;

        if (self.selectedReceipts.count)
        {
            [self.downloadReceiptButton setEnabled: YES];
        }
        else
        {
            [self.downloadReceiptButton setEnabled: NO];
        }
    }

    [self.uploadHistoryTable reloadData];
}

- (void) singleReceiptCheckChangedValue: (M13Checkbox *) checkBox
{
    DLog(@"Checkbox of tag %ld Value changed to %ld", (long)checkBox.tag, (long)checkBox.checkState);

    // get the Receipt object refered to by the checkBox's tag

    NSInteger timePeriodSelection = checkBox.tag / 10000;

    NSInteger receiptIndex = checkBox.tag % 10000;

    NSDictionary *thisReceiptInfo;

    switch (timePeriodSelection)
    {
        case TimePeriodRecent:
            thisReceiptInfo = [self.recentUploadReceipts objectAtIndex: receiptIndex];
            break;

        case TimePeriodPreviousWeek:
            thisReceiptInfo = [self.previousWeekReceipts objectAtIndex: receiptIndex];
            break;

        case TimePeriodPreviousMonth:
            thisReceiptInfo = [self.previousMonthReceipts objectAtIndex: receiptIndex];
            break;

        case TimePeriodViewAll:
            thisReceiptInfo = [self.viewAllReceipts objectAtIndex: receiptIndex];
            break;

        default:
            break;
    }

    NSString *receiptID = [thisReceiptInfo objectForKeyedSubscript: kReceiptIDKey];

    if (checkBox.checkState == M13CheckboxStateChecked)
    {
        [self.selectedReceipts setObject: @"GARBAGE" forKey: receiptID];
    }
    else
    {
        [self.selectedReceipts removeObjectForKey: receiptID];
    }

    if (self.selectedReceipts.count)
    {
        [self.downloadReceiptButton setEnabled: YES];
    }
    else
    {
        [self.downloadReceiptButton setEnabled: NO];
    }

    [self.uploadHistoryTable reloadData];
}

- (void) taxYearPressed
{
    [self.selectionPopover presentPopoverFromRect: self.taxYearLabel.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (void) setYearLabelToBe: (NSInteger) year
{
    [self.taxYearLabel setText: [NSString stringWithFormat: @"%ld Tax Year", (long)year]];
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];

    // TODO: do some receipt loading operation here
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) sendReceiptsToEmailRequested: (NSString *) emailAddress
{
    [self.sendReceiptsPopover dismissPopoverAnimated: YES];

    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - SelectionsPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index fromPopUp:(SelectionsPickerViewController *)popUpController
{
    [self.selectionPopover dismissPopoverAnimated: YES];

    self.currentlySelectedYear = self.yearsRange [index];
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return TimePeriodCount;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    switch (section)
    {
        case TimePeriodRecent:

            if (self.recentUploadSelected)
            {
                return (1 + self.recentUploadReceipts.count);
            }

            break;

        case TimePeriodPreviousWeek:

            if (self.previousWeekSelected)
            {
                return (1 + self.previousWeekReceipts.count);
            }

            break;

        case TimePeriodPreviousMonth:

            if (self.previousMonthSelected)
            {
                return (1 + self.previousMonthReceipts.count);
            }

            break;

        case TimePeriodViewAll:

            if (self.viewAllSelected)
            {
                return (1 + self.viewAllReceipts.count);
            }

            break;

        default:
            break;
    }

    return 1;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a TimePeriodSelectionTableViewCell
    if (indexPath.row == 0)
    {
        static NSString *cellId = kTimePeriodSelectionTableViewCellIdentifier;
        TimePeriodSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[TimePeriodSelectionTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        switch (indexPath.section)
        {
            case TimePeriodRecent:
                [cell.periodLabel setText: @"Recent Uploads"];
                break;

            case TimePeriodPreviousWeek:
                [cell.periodLabel setText: @"Previous Week"];
                break;

            case TimePeriodPreviousMonth:
                [cell.periodLabel setText: @"Previous Month"];
                break;

            case TimePeriodViewAll:
                [cell.periodLabel setText: @"View All"];
                break;

            default:
                break;
        }

        return cell;
    }
    // display a kReceiptTimeTableViewCellIdentifier
    else
    {
        NSDictionary *thisReceiptInfo;

        NSInteger checkBoxTagOffset = indexPath.section * 10000;

        switch (indexPath.section)
        {
            case TimePeriodRecent:
                thisReceiptInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row - 1];
                break;

            case TimePeriodPreviousWeek:
                thisReceiptInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row - 1];
                break;

            case TimePeriodPreviousMonth:
                thisReceiptInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row - 1];
                break;

            case TimePeriodViewAll:
                thisReceiptInfo = [self.viewAllReceipts objectAtIndex: indexPath.row - 1];
                break;

            default:
                break;
        }

        static NSString *cellId2 = kReceiptTimeTableViewCellIdentifier;
        ReceiptTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId2];

        if (cell == nil)
        {
            cell = [[ReceiptTimeTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId2];
        }

        [cell.checkBoxView.titleLabel setFont: [UIFont latoFontOfSize: 13]];
        [cell.checkBoxView.titleLabel setTextColor: [UIColor blackColor]];
        [cell.checkBoxView setStrokeColor: [UIColor grayColor]];
        [cell.checkBoxView setCheckColor: self.lookAndFeel.appGreenColor];
        [cell.checkBoxView setCheckAlignment: M13CheckboxAlignmentLeft];
        [cell.checkBoxView setTag: (checkBoxTagOffset + indexPath.row - 1)];
        [cell.checkBoxView addTarget: self action: @selector(singleReceiptCheckChangedValue:) forControlEvents: UIControlEventValueChanged];

        NSString *receiptID = [thisReceiptInfo objectForKeyedSubscript: kReceiptIDKey];

        if (self.selectAllReceipts || [self.selectedReceipts objectForKey: receiptID])
        {
            [cell.checkBoxView setCheckState: M13CheckboxStateChecked];
        }
        else
        {
            [cell.checkBoxView setCheckState: M13CheckboxStateUnchecked];
        }

        NSDate *receiptDate = [thisReceiptInfo objectForKey: kUploadTimeKey];

        [self.dateFormatter setDateFormat: @"dd/MM/yyyy"];

        [cell.dateLabel setText: [self.dateFormatter stringFromDate: receiptDate]];

        [self.dateFormatter setDateFormat: @"hh:mm a"];

        [cell.timeLabel setText: [[self.dateFormatter stringFromDate: receiptDate] lowercaseString]];

        return cell;
    }

    return nil;
}

#pragma mark - UITableview Delegate
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        return kTimePeriodSelectionTableViewCellHeight;
    }
    else
    {
        return kReceiptTimeTableViewCellHeight;
    }
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        NSString *period;

        switch (indexPath.section)
        {
            case TimePeriodRecent:
                period = @"Recent Uploads";
                self.recentUploadSelected = !self.recentUploadSelected;

                if (!self.recentUploadReceipts)
                {
                    [self.dataService fetchNewestReceiptInfo : 5 inYear: [Utils currentYear] success:^(NSArray *receiptInfos) {
                    self.recentUploadReceipts = receiptInfos;
                } failure:^(NSString *reason) {
                    // should not happen
                }];
                }

                break;

            case TimePeriodPreviousWeek:
                period = @"Previous Week";
                self.previousWeekSelected = !self.previousWeekSelected;

                if (!self.previousWeekReceipts)
                {
                    NSDate *mondayOfThisWeek = [Utils dateForMondayOfThisWeek];

                    NSDate *mondayOfPreviousWeek = [Utils dateForMondayOfPreviousWeek];

                    [self.dataService fetchReceiptInfoFromDate: mondayOfPreviousWeek toDate: mondayOfThisWeek success:^(NSArray *receiptInfos) {
                    self.previousWeekReceipts = receiptInfos;
                } failure:^(NSString *reason) {
                    // should not happen
                }];
                }

                break;

            case TimePeriodPreviousMonth:
                period = @"Previous Month";
                self.previousMonthSelected = !self.previousMonthSelected;

                if (!self.previousMonthReceipts)
                {
                    NSDate *firstDayOfThisMonth = [Utils dateForFirstDayOfThisMonth];

                    NSDate *firstDayOfPreviousMonth = [Utils dateForFirstDayOfPreviousMonth];

                    [self.dataService fetchReceiptInfoFromDate: firstDayOfPreviousMonth toDate: firstDayOfThisMonth success:^(NSArray *receiptInfos) {
                    self.previousMonthReceipts = receiptInfos;
                } failure:^(NSString *reason) {
                    // should not happen
                }];
                }

                break;

            case TimePeriodViewAll:
                period = @"View All";
                self.viewAllSelected = !self.viewAllSelected;

                if (!self.viewAllReceipts)
                {
                    [self.dataService fetchNewestReceiptInfo: 999 inYear: [Utils currentYear] success:^(NSArray *receiptInfos) {
                    self.viewAllReceipts = receiptInfos;
                } failure:^(NSString *reason) {
                    // should not happen
                }];
                }

                break;

            default:
                break;
        }

        DLog(@"Receipt Time period %@ clicked", period);

        [tableView reloadData];
        
        [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

@end