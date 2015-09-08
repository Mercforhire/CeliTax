//
// UploadsHistoryTableViewCell.m
// CeliTax
//
// Created by Leon Chen on 2015-06-04.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "UploadsHistoryTableViewCell.h"
#import "ReceiptTableViewCell.h"
#import "DataService.h"
#import "Notifications.h"
#import "NoItemsTableViewCell.h"

#define kReceiptTableTableCellHeight                    35
#define kReceiptTableViewCellIdentifier                 @"ReceiptTableViewCell"

#define kNoItemsTableViewCellHeight                     40
#define kNoItemsTableViewCellIdentifier                 @"NoItemsTableViewCell"

@interface UploadsHistoryTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL recentUploadsSelected;

@property (weak, nonatomic) IBOutlet UILabel *recentUploadsQtyLabel;

@property (weak, nonatomic) IBOutlet UILabel *recentUploadsTotalLabel;
@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recentUploadsHeightBar;

@property (nonatomic) BOOL previousWeekSelected;

@property (weak, nonatomic) IBOutlet UILabel *previousWeekQtyLabel;

@property (weak, nonatomic) IBOutlet UILabel *previousWeekTotalLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousWeekTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previousWeekHeightBar;

@property (nonatomic) BOOL previousMonthSelected;
@property (weak, nonatomic) IBOutlet UILabel *previousMonthQtyLabel;

@property (weak, nonatomic) IBOutlet UILabel *previousMonthTotalLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousMonthTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previousMonthHeightBar;

@property (nonatomic) BOOL viewAllSelected;

@property (weak, nonatomic) IBOutlet UILabel *viewAllQtyLabel;

@property (weak, nonatomic) IBOutlet UILabel *viewAllTotalLabel;
@property (weak, nonatomic) IBOutlet UITableView *viewAllTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAllHeightBar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation UploadsHistoryTableViewCell

- (void) awakeFromNib
{
    // Initialization code
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];

    UINib *noItemTableCell = [UINib nibWithNibName: @"NoItemsTableViewCell" bundle: nil];
    
    UINib *receiptTableViewCell = [UINib nibWithNibName: @"ReceiptTableViewCell" bundle: nil];

    [self.recentUploadsLabel setText:NSLocalizedString(@"Recent Uploads", nil)];
    [self.recentUploadsQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.recentUploadsTotalLabel setText:NSLocalizedString(@"Total", nil)];
    self.recentUploadsTable.dataSource = self;
    self.recentUploadsTable.delegate = self;
    [self.recentUploadsTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];
    [self.recentUploadsTable registerNib: noItemTableCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];
    
    [self.previousWeekLabel setText:NSLocalizedString(@"Previous Week", nil)];
    [self.previousWeekQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.previousWeekTotalLabel setText:NSLocalizedString(@"Total", nil)];
    self.previousWeekTable.dataSource = self;
    self.previousWeekTable.delegate = self;
    [self.previousWeekTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];
    [self.previousWeekTable registerNib: noItemTableCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];
    
    [self.previousMonthLabel setText:NSLocalizedString(@"Previous Month", nil)];
    [self.previousMonthQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.previousMonthTotalLabel setText:NSLocalizedString(@"Total", nil)];
    self.previousMonthTable.dataSource = self;
    self.previousMonthTable.delegate = self;
    [self.previousMonthTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];
    [self.previousMonthTable registerNib: noItemTableCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];
    
    [self.viewAllLabel setText:NSLocalizedString(@"View All", nil)];
    [self.viewAllQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.viewAllTotalLabel setText:NSLocalizedString(@"Total", nil)];
    self.viewAllTable.dataSource = self;
    self.viewAllTable.delegate = self;
    [self.viewAllTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];
    [self.viewAllTable registerNib: noItemTableCell forCellReuseIdentifier: kNoItemsTableViewCellIdentifier];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat: @"dd/MM/yyyy"];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

- (void) setRecentUploadsSelected: (BOOL) recentUploadsSelected
{
    _recentUploadsSelected = recentUploadsSelected;

    if (_recentUploadsSelected)
    {
        [self.recentUploadsQtyLabel setHidden: NO];
        [self.recentUploadsTriangle setGreenArrowUp];
        [self.recentUploadsTotalLabel setHidden: NO];
        [self.recentUploadsTable setHidden: NO];
        
        if (self.recentUploadReceipts.count)
        {
            [self.recentUploadsHeightBar setConstant: kReceiptTableTableCellHeight * self.recentUploadReceipts.count];
        }
        else
        {
            [self.recentUploadsHeightBar setConstant: kNoItemsTableViewCellHeight];
        }
        
        [self.recentUploadsTable reloadData];
    }
    else
    {
        [self.recentUploadsQtyLabel setHidden: YES];
        [self.recentUploadsTriangle setGreenArrowDown];
        [self.recentUploadsTotalLabel setHidden: YES];
        [self.recentUploadsTable setHidden: YES];
        [self.recentUploadsHeightBar setConstant: 0];
    }

    [self layoutIfNeeded];
}

- (void) setPreviousWeekSelected: (BOOL) previousWeekSelected
{
    _previousWeekSelected = previousWeekSelected;

    if (_previousWeekSelected)
    {
        [self.previousWeekQtyLabel setHidden: NO];
        [self.previousWeekTriangle setGreenArrowUp];
        [self.previousWeekTotalLabel setHidden: NO];
        [self.previousWeekTable setHidden: NO];
        
        if (self.previousWeekReceipts.count)
        {
            [self.previousWeekHeightBar setConstant: kReceiptTableTableCellHeight * self.previousWeekReceipts.count];
        }
        else
        {
            [self.previousWeekHeightBar setConstant: kNoItemsTableViewCellHeight];
        }

        [self.previousWeekTable reloadData];
    }
    else
    {
        [self.previousWeekQtyLabel setHidden: YES];
        [self.previousWeekTriangle setGreenArrowDown];
        [self.previousWeekTotalLabel setHidden: YES];
        [self.previousWeekTable setHidden: YES];
        [self.previousWeekHeightBar setConstant: 0];
    }

    [self layoutIfNeeded];
}

- (void) setPreviousMonthSelected: (BOOL) previousMonthSelected
{
    _previousMonthSelected = previousMonthSelected;

    if (_previousMonthSelected)
    {
        [self.previousMonthQtyLabel setHidden: NO];
        [self.previousMonthTriangle setGreenArrowUp];
        [self.previousMonthTotalLabel setHidden: NO];
        [self.previousMonthTable setHidden: NO];
        
        if (self.previousMonthReceipts.count)
        {
            [self.previousMonthHeightBar setConstant: kReceiptTableTableCellHeight * self.previousMonthReceipts.count];
        }
        else
        {
            [self.previousMonthHeightBar setConstant: kNoItemsTableViewCellHeight];
        }

        [self.previousMonthTable reloadData];
    }
    else
    {
        [self.previousMonthQtyLabel setHidden: YES];
        [self.previousMonthTriangle setGreenArrowDown];
        [self.previousMonthTotalLabel setHidden: YES];
        [self.previousMonthTable setHidden: YES];
        [self.previousMonthHeightBar setConstant: 0];
    }

    [self layoutIfNeeded];
}

- (void) setViewAllSelected: (BOOL) viewAllSelected
{
    _viewAllSelected = viewAllSelected;

    if (_viewAllSelected)
    {
        [self.viewAllQtyLabel setHidden: NO];
        [self.viewAllTriangle setGreenArrowUp];
        [self.viewAllTotalLabel setHidden: NO];
        [self.viewAllTable setHidden: NO];

        if (self.viewAllReceipts.count)
        {
            [self.viewAllHeightBar setConstant: kReceiptTableTableCellHeight * self.viewAllReceipts.count];
        }
        else
        {
            [self.viewAllHeightBar setConstant: kNoItemsTableViewCellHeight + 5];
        }

        [self.viewAllTable reloadData];
    }
    else
    {
        [self.viewAllQtyLabel setHidden: YES];
        [self.viewAllTriangle setGreenArrowDown];
        [self.viewAllTotalLabel setHidden: YES];
        [self.viewAllTable setHidden: YES];
        [self.viewAllHeightBar setConstant: 0];
    }

    [self layoutIfNeeded];
}

- (void) setToDisplayItems
{
    [self.recentUploadsQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.previousWeekQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.previousMonthQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
    [self.viewAllQtyLabel setText:NSLocalizedString(@"Total Qty.", nil)];
}

- (void) setToDisplayWeight
{
    [self.recentUploadsQtyLabel setText:NSLocalizedString(@"Weight", nil)];
    [self.previousWeekQtyLabel setText:NSLocalizedString(@"Weight", nil)];
    [self.previousMonthQtyLabel setText:NSLocalizedString(@"Weight", nil)];
    [self.viewAllQtyLabel setText:NSLocalizedString(@"Weight", nil)];
}

- (void) selectNothing
{
    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;
}

- (void) selectRecentUpload
{
    self.recentUploadsSelected = YES;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;
}

- (void) selectPreviousWeek
{
    self.recentUploadsSelected = NO;
    self.previousWeekSelected = YES;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;
}

- (void) selectPreviousMonth
{
    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = YES;
    self.viewAllSelected = NO;
}

- (void) selectViewAll
{
    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = YES;
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    if (tableView == self.recentUploadsTable)
    {
        return self.recentUploadReceipts.count > 0 ? self.recentUploadReceipts.count : 1;
    }
    else if (tableView == self.previousWeekTable)
    {
        return self.previousWeekReceipts.count > 0 ? self.previousWeekReceipts.count : 1;
    }
    else if (tableView == self.previousMonthTable)
    {
        return self.previousMonthReceipts.count > 0 ? self.previousMonthReceipts.count : 1;
    }
    else if (tableView == self.viewAllTable)
    {
        return self.viewAllReceipts.count > 0 ? self.viewAllReceipts.count : 1;
    }

    return 0;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = kReceiptTableViewCellIdentifier;
    ReceiptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

    if (cell == nil)
    {
        cell = [[ReceiptTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
    }

    [cell setClipsToBounds: YES];

    NSDictionary *thisCatagoryInfo;

    if (tableView == self.recentUploadsTable && self.recentUploadReceipts.count)
    {
        thisCatagoryInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousWeekTable && self.previousWeekReceipts.count)
    {
        thisCatagoryInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousMonthTable && self.previousMonthReceipts.count)
    {
        thisCatagoryInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.viewAllTable && self.viewAllReceipts.count)
    {
        thisCatagoryInfo = [self.viewAllReceipts objectAtIndex: indexPath.row];
    }
    
    if (!thisCatagoryInfo)
    {
        //show a NoItemsTableViewCell
        NoItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kNoItemsTableViewCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[NoItemsTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: kNoItemsTableViewCellIdentifier];
        }
        
        return cell;
    }

    // Keys: kReceiptTimeKey, kTotalQtyKey, kTotalAmountKey
    NSDate *receiptDate = [thisCatagoryInfo objectForKey: kReceiptTimeKey];
    NSInteger totalQty = [[thisCatagoryInfo objectForKey: kTotalQtyKey] integerValue];
    float totalAmount = [[thisCatagoryInfo objectForKey: kTotalAmountKey] floatValue];

    [cell.colorBox setBackgroundColor: self.catagoryColor];

    [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorBox];

    [cell.dateLabel setText: [self.dateFormatter stringFromDate: receiptDate]];

    [cell.qtyLabel setText: [NSString stringWithFormat: @"%ld", (long)totalQty]];

    [cell.totalLabel setText: [NSString stringWithFormat: @"$%.2f", totalAmount]];

    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
   if (tableView == self.recentUploadsTable)
    {
        if (!self.recentUploadReceipts.count)
        {
            return kNoItemsTableViewCellHeight;
        }
    }
    else if (tableView == self.previousWeekTable)
    {
        if (!self.previousWeekReceipts.count)
        {
            return kNoItemsTableViewCellHeight;
        }
    }
    else if (tableView == self.previousMonthTable)
    {
        if (!self.previousMonthReceipts.count)
        {
            return kNoItemsTableViewCellHeight;
        }
    }
    else if (tableView == self.viewAllTable)
    {
        if (!self.viewAllReceipts.count)
        {
            return kNoItemsTableViewCellHeight + 5;
        }
    }
    
    return kReceiptTableTableCellHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSDictionary *thisCatagoryInfo;

    if (tableView == self.recentUploadsTable)
    {
        if (self.recentUploadReceipts.count)
            thisCatagoryInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousWeekTable)
    {
        if (self.previousWeekReceipts.count)
            thisCatagoryInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousMonthTable)
    {
        if (self.previousMonthReceipts.count)
            thisCatagoryInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.viewAllTable)
    {
        if (self.viewAllReceipts.count)
            thisCatagoryInfo = [self.viewAllReceipts objectAtIndex: indexPath.row];
    }
    
    if (thisCatagoryInfo)
    {
        [[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName: kReceiptItemsTableReceiptPressedNotification object: nil userInfo: thisCatagoryInfo]];
    }
}

@end