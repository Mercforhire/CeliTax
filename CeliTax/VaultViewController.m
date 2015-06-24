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
#import "ConfigurationManager.h"
#import "NoItemsTableViewCell.h"
#import "ReceiptBreakDownViewController.h"
#import "ReceiptCheckingViewController.h"

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

#define kNoItemsTableViewCellHeight                     40
#define kNoItemsTableViewCellIdentifier                 @"NoItemsTableViewCell"

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

// sorted from most recent to oldest
@property (nonatomic, strong) NSArray *taxYears;

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
    UINib *noItemsTableViewCell = [UINib nibWithNibName: @"NoItemsTableViewCell" bundle: nil];

    [self.uploadHistoryTable registerNib: timePeriodSelectionTableViewCell forCellReuseIdentifier: kTimePeriodSelectionTableViewCellIdentifier];
    [self.uploadHistoryTable registerNib: receiptTimeTableViewCellTableViewCell forCellReuseIdentifier: kReceiptTimeTableViewCellIdentifier];
    [self.uploadHistoryTable registerNib: noItemsTableViewCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];

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
    
    self.taxYears = [self.dataService fetchTaxYears];
    
    NSMutableArray *yearSelections = [NSMutableArray new];
    
    for (NSNumber *year in self.taxYears)
    {
        [yearSelections addObject: [NSString stringWithFormat: @"%ld Tax Year", (long)year.integerValue]];
    }

    self.taxYearPickerViewController = [self.viewControllerFactory createSelectionsPickerViewControllerWithSelections: yearSelections];
    self.taxYearPickerViewController.highlightedSelectionIndex = -1;
    self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
    [self.taxYearPickerViewController setDelegate: self];
    
    //if there is no selected tax year saved, select the newest year by default
    if (![self.configurationManager getCurrentTaxYear])
    {
        self.currentlySelectedYear = [self.taxYears firstObject];
    }
    else
    {
        self.currentlySelectedYear = [NSNumber numberWithInteger:[self.configurationManager getCurrentTaxYear]];
    }
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

-(NSDictionary *)getReceiptInfoFromTag:(NSInteger)tag
{
    // get the Receipt object refered to by the checkBox's tag
    
    NSInteger timePeriodSelection = tag / 10000;
    
    NSInteger receiptIndex = tag % 10000;
    
    NSDictionary *receiptInfo;
    
    switch (timePeriodSelection)
    {
        case TimePeriodRecent:
            receiptInfo = [self.recentUploadReceipts objectAtIndex: receiptIndex];
            break;
            
        case TimePeriodPreviousWeek:
            receiptInfo = [self.previousWeekReceipts objectAtIndex: receiptIndex];
            break;
            
        case TimePeriodPreviousMonth:
            receiptInfo = [self.previousMonthReceipts objectAtIndex: receiptIndex];
            break;
            
        case TimePeriodViewAll:
            receiptInfo = [self.viewAllReceipts objectAtIndex: receiptIndex];
            break;
            
        default:
            break;
    }
    
    return receiptInfo;
}

- (void) singleReceiptCheckChangedValue: (M13Checkbox *) checkBox
{
    DLog(@"Checkbox of tag %ld Value changed to %ld", (long)checkBox.tag, (long)checkBox.checkState);

    NSDictionary *thisReceiptInfo = [self getReceiptInfoFromTag:checkBox.tag];

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

-(void)receiptDetailsPressed:(UIButton *)sender
{
    NSDictionary *thisReceiptInfo = [self getReceiptInfoFromTag:sender.tag];
    
    NSString *receiptID = [thisReceiptInfo objectForKeyedSubscript: kReceiptIDKey];
    
    //push to Receipt Checking view directly if this receipt has no items
    [self.dataService fetchRecordsForReceiptID: receiptID
                                       success: ^(NSArray *records)
     {
         if (!records || records.count == 0)
         {
             // push ReceiptCheckingViewController
             [self.navigationController pushViewController: [self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID: receiptID cameFromReceiptBreakDownViewController: YES] animated: YES];
         }
         else
         {
             [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: receiptID cameFromReceiptCheckingViewController: NO] animated: YES];
         }
         
     } failure: ^(NSString *reason) {
         // failure
     }];
}

- (void) setYearLabelToBe: (NSInteger) year
{
    [self.taxYearLabel setText: [NSString stringWithFormat: @"%ld Tax Year", (long)year]];
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];

     [self.configurationManager setCurrentTaxYear:_currentlySelectedYear.integerValue];
    
    self.taxYearPickerViewController.highlightedSelectionIndex = [self.taxYears indexOfObject:self.currentlySelectedYear];
    
    //reset the self.uploadHistoryTable table
    [self.selectedReceipts removeAllObjects];
    
    self.recentUploadReceipts = nil;
    self.previousWeekReceipts = nil;
    self.previousMonthReceipts = nil;
    self.viewAllReceipts = nil;
    
    self.recentUploadSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;
    
    [self.selectAllCheckBox setCheckState:M13CheckboxStateUnchecked];
    [self selectAllCheckChangedValue:self.selectAllCheckBox];
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

    self.currentlySelectedYear = self.taxYears[index];
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
                if (self.recentUploadReceipts.count)
                {
                    return (1 + self.recentUploadReceipts.count);
                }
                else
                {
                    return 2;
                }
                
            }

            break;

        case TimePeriodPreviousWeek:

            if (self.previousWeekSelected)
            {
                if (self.previousWeekReceipts.count)
                {
                    return (1 + self.previousWeekReceipts.count);
                }
                else
                {
                    return 2;
                }
            }

            break;

        case TimePeriodPreviousMonth:

            if (self.previousMonthSelected)
            {
                if (self.previousMonthReceipts.count)
                {
                    return (1 + self.previousMonthReceipts.count);
                }
                else
                {
                    return 2;
                }
            }

            break;

        case TimePeriodViewAll:

            if (self.viewAllSelected)
            {
                if (self.viewAllReceipts.count)
                {
                    return (1 + self.viewAllReceipts.count);
                }
                else
                {
                    return 2;
                }
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
                
                if (self.recentUploadSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            case TimePeriodPreviousWeek:
                [cell.periodLabel setText: @"Previous Week"];
                
                if (self.previousWeekSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            case TimePeriodPreviousMonth:
                [cell.periodLabel setText: @"Previous Month"];
                
                if (self.previousMonthSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            case TimePeriodViewAll:
                [cell.periodLabel setText: @"View All"];
                
                if (self.viewAllSelected)
                {
                    [cell.triangle setGreenArrowUp];
                }
                else
                {
                    [cell.triangle setGreenArrowDown];
                }
                
                break;

            default:
                break;
        }

        return cell;
    }
    // display a ReceiptTimeTableViewCell or NoItemsTableViewCell
    else
    {
        NSDictionary *thisReceiptInfo;

        NSInteger checkBoxTagOffset = indexPath.section * 10000;

        switch (indexPath.section)
        {
            case TimePeriodRecent:
                if (self.recentUploadReceipts.count)
                {
                    thisReceiptInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row - 1];
                }
                break;

            case TimePeriodPreviousWeek:
                if (self.previousWeekReceipts.count)
                {
                    thisReceiptInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row - 1];
                }
                break;

            case TimePeriodPreviousMonth:
                if (self.previousMonthReceipts.count)
                {
                    thisReceiptInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row - 1];

                }
                break;

            case TimePeriodViewAll:
                if (self.viewAllReceipts.count)
                {
                    thisReceiptInfo = [self.viewAllReceipts objectAtIndex: indexPath.row - 1];
                }
                break;

            default:
                break;
        }
        
        if (!thisReceiptInfo)
        {
            //show a NoItemsTableViewCell
            static NSString *cellId3 = kNoItemsTableViewCellIdentifier;
            
            NoItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId3];
            
            if (cell == nil)
            {
                cell = [[NoItemsTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId3];
            }
            
            return cell;
        }
        else
        {
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
            
            cell.detailsButton.tag = (checkBoxTagOffset + indexPath.row - 1);
            [cell.detailsButton addTarget:self action:@selector(receiptDetailsPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.lookAndFeel applySolidGreenButtonStyleTo:cell.detailsButton];
            
            return cell;
        }
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
                    [self.dataService fetchNewestReceiptInfo : 5
                                                       inYear: self.currentlySelectedYear.integerValue
                                                      success:^(NSArray *receiptInfos)
                     {
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
                    
                    [self.dataService fetchReceiptInfoFromDate: mondayOfPreviousWeek
                                                        toDate: mondayOfThisWeek
                                                     inTaxYear: self.currentlySelectedYear.integerValue
                                                       success:^(NSArray *receiptInfos)
                     {
                         self.previousWeekReceipts = receiptInfos;
                     } failure:^(NSString *reason) {
                         // should not happen
                     }];
                }

                break;

            case TimePeriodPreviousMonth:
                period = @"Previous Month";
                self.previousMonthSelected = !self.previousMonthSelected;

                if ( !self.previousMonthReceipts )
                {
                    NSDate *firstDayOfThisMonth = [Utils dateForFirstDayOfThisMonth];
                    
                    NSDate *firstDayOfPreviousMonth = [Utils dateForFirstDayOfPreviousMonth];
                    
                    [self.dataService fetchReceiptInfoFromDate: firstDayOfPreviousMonth
                                                        toDate: firstDayOfThisMonth
                                                     inTaxYear: self.currentlySelectedYear.integerValue
                                                       success:^(NSArray *receiptInfos)
                     {
                         
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
                    [self.dataService fetchNewestReceiptInfo: 999
                                                      inYear: self.currentlySelectedYear.integerValue
                                                     success:^(NSArray *receiptInfos)
                     {
                         
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