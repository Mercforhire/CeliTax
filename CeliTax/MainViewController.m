//
// MainViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainViewController.h"
#import "Catagory.h"
#import "MainViewTableViewCell.h"
#import "UserManager.h"
#import "User.h"
#import "AddCatagoryViewController.h"
#import "AlertDialogsProvider.h"
#import "ReceiptCheckingViewController.h"
#import "CameraViewController.h"
#import "ViewControllerFactory.h"
#import "MyAccountViewController.h"
#import "VaultViewController.h"
#import "SelectionsPickerViewController.h"
#import "WYPopoverController.h"
#import "ReceiptBreakDownViewController.h"

#define kRecentUploadTableRowHeight         40

typedef enum : NSUInteger
{
    SectionReceiptsUploads,
    SectionQuickLinks,
    SectionCount,
} SectionTitles;

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, SelectionsPickerPopUpDelegate> {
    NSDateFormatter *dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *taxYearLabel;
@property (weak, nonatomic) IBOutlet UIImageView *greenTriangle;
@property (nonatomic, strong) WYPopoverController *selectionPopover;
@property (nonatomic, strong) SelectionsPickerViewController *taxYearPickerViewController;

// Dictionaries of keys: kReceiptIDKey,kColorKey,kCatagoryNameKey,kCatagoryTotalAmountKey
@property (nonatomic, strong) NSArray *receiptInfos;

// NSNumbers of the years of all receipts timestamps, sorted from most recent to oldest
@property (nonatomic, strong) NSArray *yearsRange;

@property (nonatomic, strong) NSNumber *currentlySelectedYear;

@end

@implementation MainViewController

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil])
    {
        // initialize the slider bar menu button
        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle: @"+ Add Catagory" style: UIBarButtonItemStylePlain target: self action: @selector(addCatagoryPressed:)];
        self.navigationItem.leftBarButtonItem = menuItem;

        [self.navigationItem setHidesBackButton: YES];
    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.dataService loadDemoData];

    self.recentUploadsTable.dataSource = self;
    self.recentUploadsTable.delegate = self;

    dateFormatter = [[NSDateFormatter alloc] init];

    UINib *mainTableCell = [UINib nibWithNibName: @"MainViewTableViewCell" bundle: nil];
    [self.recentUploadsTable registerNib: mainTableCell forCellReuseIdentifier: @"MainTableCell"];

    UITapGestureRecognizer *taxYearPressedTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(taxYearPressed)];
    [self.taxYearLabel addGestureRecognizer: taxYearPressedTap];

    [self.dataService fetchReceiptsYearsRange:^(NSArray *yearsRange)
    {
        self.yearsRange = yearsRange;
        self.currentlySelectedYear = [self.yearsRange firstObject];

        NSMutableArray *yearSelections = [NSMutableArray new];

        for (NSNumber *year in yearsRange)
        {
            [yearSelections addObject: [NSString stringWithFormat: @"%ld Tax Year", year.integerValue]];
        }

        self.taxYearPickerViewController = [self.viewControllerFactory createNamesPickerViewControllerWithNames: yearSelections];
        self.selectionPopover = [[WYPopoverController alloc] initWithContentViewController: self.taxYearPickerViewController];
        [self.taxYearPickerViewController setDelegate: self];
        [self.selectionPopover setPopoverContentSize: self.taxYearPickerViewController.viewSize];
    }                                 failure:^(NSString *reason) {
        // should not happen
    }];
}

- (void) setCurrentlySelectedYear: (NSNumber *) currentlySelectedYear
{
    _currentlySelectedYear = currentlySelectedYear;

    [self setYearLabelToBe: self.currentlySelectedYear.integerValue];

    [self.dataService fetchNewestReceiptInfo: 5
                                      inYear: self.currentlySelectedYear.integerValue
                                     success: ^(NSArray *receiptInfos)
    {
        self.receiptInfos = receiptInfos;
        [self.recentUploadsTable reloadData];
    }                                failure: ^(NSString *reason)
    {
        // should not happen
    }];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}

- (void) taxYearPressed
{
    [self.selectionPopover presentPopoverFromRect: self.taxYearLabel.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionUp animated: YES];
}

- (IBAction) addCatagoryPressed: (UIButton *) sender
{
    // open up the AddCatagoryViewController
    [self.navigationController pushViewController: [self.viewControllerFactory createAddCatagoryViewController] animated: YES];
}

- (IBAction) cameraButtonPressed: (UIButton *) sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createCameraOverlayViewController] animated: YES];
}

- (void) setYearLabelToBe: (NSInteger) year
{
    [self.taxYearLabel setText: [NSString stringWithFormat: @"%ld Tax Year", year]];
}

- (void) setGreenArrowUp
{
    [self.greenTriangle setImage: [UIImage imageNamed: @"greenTrianglePointUp"]];
}

- (void) setGreenArrowDown
{
    [self.greenTriangle setImage: [UIImage imageNamed: @"greenTrianglePointDown"]];
}

- (IBAction) myAccountPressed: (UIButton *) sender
{
    [super selectedMenuIndex: RootViewControllerAccount];
}

- (IBAction) vaultPressed: (UIButton *) sender
{
    [super selectedMenuIndex: RootViewControllerVault];
}

#pragma mark - NamesPickerPopUpDelegate

- (void) selectedSelectionAtIndex: (NSInteger) index
{
    [self.selectionPopover dismissPopoverAnimated: YES];

    self.currentlySelectedYear = self.yearsRange [index];
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.receiptInfos.count;
}

- (MainViewTableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = @"MainTableCell";
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

    if (cell == nil)
    {
        cell = [[MainViewTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
    }

    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];

    NSDictionary *uploadInfoDictionary = self.receiptInfos [indexPath.row];

    NSDate *uploadDate = [uploadInfoDictionary objectForKey: kUploadTimeKey];

    [dateFormatter setDateFormat: @"dd/MM/yyyy"];

    [cell.calenderDateLabel setText: [dateFormatter stringFromDate: uploadDate]];

    [dateFormatter setDateFormat: @"hh:mm a"];

    [cell.timeOfDayLabel setText: [[dateFormatter stringFromDate: uploadDate] lowercaseString]];

    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kRecentUploadTableRowHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSDictionary *uploadInfoDictionary = self.receiptInfos [indexPath.row];

    DLog(@"Receipt ID %@ clicked", [uploadInfoDictionary objectForKey: kReceiptIDKey]);

    NSString *clickedReceiptID = [uploadInfoDictionary objectForKey: kReceiptIDKey];

    [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: clickedReceiptID cameFromReceiptCheckingViewController: NO] animated: YES];
}

#pragma mark - CameraManager

- (void) receivedImageFromCamera: (UIImage *) newImage
{
    DLog(@"Image received from camera");
}

@end