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

#define kTableCellHeight            35

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

@property (weak, nonatomic) IBOutlet UILabel *viewAllLabelQtyLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewAllTotalLabel;
@property (weak, nonatomic) IBOutlet UITableView *viewAllTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAllHeightBar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation UploadsHistoryTableViewCell

#define kReceiptTableViewCellIdentifier      @"ReceiptTableViewCell"

- (void) awakeFromNib
{
    // Initialization code

    [self setSelectionStyle: UITableViewCellSelectionStyleNone];

    UINib *receiptTableViewCell = [UINib nibWithNibName: @"ReceiptTableViewCell" bundle: nil];

    self.recentUploadsTable.dataSource = self;
    self.recentUploadsTable.delegate = self;
    [self.recentUploadsTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];

    self.previousWeekTable.dataSource = self;
    self.previousWeekTable.delegate = self;
    [self.previousWeekTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];

    self.previousMonthTable.dataSource = self;
    self.previousMonthTable.delegate = self;
    [self.previousMonthTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];

    self.viewAllTable.dataSource = self;
    self.viewAllTable.delegate = self;
    [self.viewAllTable registerNib: receiptTableViewCell forCellReuseIdentifier: kReceiptTableViewCellIdentifier];

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
        [self.recentUploadsTotalLabel setHidden: NO];
        [self.recentUploadsTable setHidden: NO];
        [self.recentUploadsHeightBar setConstant: kTableCellHeight * self.recentUploadReceipts.count];

        [self.recentUploadsTable reloadData];
    }
    else
    {
        [self.recentUploadsQtyLabel setHidden: YES];
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
        [self.previousWeekTotalLabel setHidden: NO];
        [self.previousWeekTable setHidden: NO];
        [self.previousWeekHeightBar setConstant: kTableCellHeight * self.previousWeekReceipts.count];

        [self.previousWeekTable reloadData];
    }
    else
    {
        [self.previousWeekQtyLabel setHidden: YES];
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
        [self.previousMonthTotalLabel setHidden: NO];
        [self.previousMonthTable setHidden: NO];
        [self.previousMonthHeightBar setConstant: kTableCellHeight * self.previousMonthReceipts.count];

        [self.previousMonthTable reloadData];
    }
    else
    {
        [self.previousMonthQtyLabel setHidden: YES];
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
        [self.viewAllLabelQtyLabel setHidden: NO];
        [self.viewAllTotalLabel setHidden: NO];
        [self.viewAllTable setHidden: NO];
        [self.viewAllHeightBar setConstant: kTableCellHeight * self.viewAllReceipts.count];

        [self.viewAllTable reloadData];
    }
    else
    {
        [self.viewAllLabelQtyLabel setHidden: YES];
        [self.viewAllTotalLabel setHidden: YES];
        [self.viewAllTable setHidden: YES];
        [self.viewAllHeightBar setConstant: 0];
    }

    [self layoutIfNeeded];
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
        return self.recentUploadReceipts.count;
    }
    else if (tableView == self.previousWeekTable)
    {
        return self.previousWeekReceipts.count;
    }
    else if (tableView == self.previousMonthTable)
    {
        return self.previousMonthReceipts.count;
    }
    else if (tableView == self.viewAllTable)
    {
        return self.viewAllReceipts.count;
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

    if (tableView == self.recentUploadsTable)
    {
        thisCatagoryInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousWeekTable)
    {
        thisCatagoryInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousMonthTable)
    {
        thisCatagoryInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.viewAllTable)
    {
        thisCatagoryInfo = [self.viewAllReceipts objectAtIndex: indexPath.row];
    }

    // Keys: kReceiptTimeKey, kTotalQtyKey, kTotalAmountKey
    NSDate *receiptDate = [thisCatagoryInfo objectForKey: kReceiptTimeKey];
    NSInteger totalQty = [[thisCatagoryInfo objectForKey: kTotalQtyKey] integerValue];
    float totalAmount = [[thisCatagoryInfo objectForKey: kTotalAmountKey] floatValue];

    [cell.colorBox setBackgroundColor: self.catagoryColor];

    [cell.dateLabel setText: [self.dateFormatter stringFromDate: receiptDate]];

    [cell.qtyLabel setText: [NSString stringWithFormat: @"%ld", totalQty]];

    [cell.totalLabel setText: [NSString stringWithFormat: @"$%.2f", totalAmount]];

    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kTableCellHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSDictionary *thisCatagoryInfo;

    if (tableView == self.recentUploadsTable)
    {
        thisCatagoryInfo = [self.recentUploadReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousWeekTable)
    {
        thisCatagoryInfo = [self.previousWeekReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.previousMonthTable)
    {
        thisCatagoryInfo = [self.previousMonthReceipts objectAtIndex: indexPath.row];
    }
    else if (tableView == self.viewAllTable)
    {
        thisCatagoryInfo = [self.viewAllReceipts objectAtIndex: indexPath.row];
    }

    NSString *receiptID = [thisCatagoryInfo objectForKey: kReceiptIDKey];

    DLog(@"Receipt %@ pressed", receiptID);

    [[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName: kReceiptItemsTableReceiptPressedNotification object: nil userInfo: thisCatagoryInfo]];
}

@end