//
// MyAccountViewController.m
// CeliTax
//
// Created by Leon Chen on 2015-05-01.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MyAccountViewController.h"
#import "AccountTableViewCell.h"
#import "Catagory.h"
#import "Record.h"
#import "UserManager.h"
#import "User.h"
#import "AlertDialogsProvider.h"
#import "ViewControllerFactory.h"
#import "XYPieChart.h"
#import "UploadsHistoryTableViewCell.h"
#import "Notifications.h"
#import "ReceiptBreakDownViewController.h"
#import "Utils.h"
#import "ConfigurationManager.h"
#import "ProfileBarView.h"
#import "TutorialManager.h"
#import "TutorialStep.h"

#define kCatagoryTableRowHeight                     65

#define kCatagoryDetailsKeyTotalQty                 @"CatagoryDetailsKeyTotalQty"
#define kCatagoryDetailsKeyTotalAmount              @"CatagoryDetailsKeyTotalAmount"

#define kAccountTableViewCellIdentifier             @"AccountTableViewCell"
#define kUploadsHistoryTableViewCellIdentifier      @"UploadsHistoryTableViewCell"

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) XYPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (nonatomic, strong) NSArray *catagories; // of Catagory
// Key: Catagory ID, Value: NSMutableDictionary of :
// KEY: kCatagoryDetailsKeyTotalQty, VALUE: total quantity for this catagory
// KEY: kCatagoryDetailsKeyTotalAmount, VALUE: total amount spent for this catagory
@property (strong, nonatomic) NSMutableDictionary *catagoryDetails;
@property (nonatomic, strong) NSMutableArray *slicePercentages;
@property (nonatomic, strong) NSMutableArray *sliceColors;
@property (nonatomic, strong) NSMutableArray *sliceNames;
@property (nonatomic, strong) Catagory *currentlySelectedCatagory;
@property (nonatomic, strong) NSArray *catagoryInfosToShow;
@property (nonatomic) BOOL recentUploadsSelected;
@property (nonatomic) BOOL previousWeekSelected;
@property (nonatomic) BOOL previousMonthSelected;
@property (nonatomic) BOOL viewAllSelected;

@end

@implementation MyAccountViewController

- (void) setupUI
{
    ProfileBarView *profileBarView = [[ProfileBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    // load user info
    [profileBarView.nameLabel setText: [NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];

    profileBarView.profileImageView.layer.cornerRadius = profileBarView.profileImageView.frame.size.width / 2;
    profileBarView.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    profileBarView.profileImageView.layer.borderWidth = 1.0f;
    [profileBarView.profileImageView setClipsToBounds: YES];
    [profileBarView.profileImageView setImage: self.userManager.user.avatarImage];
    
    [profileBarView.editButton1 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    [profileBarView.editButton2 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // set up tableview
    UINib *accountTableCell = [UINib nibWithNibName: @"AccountTableViewCell" bundle: nil];
    [self.accountTableView registerNib: accountTableCell forCellReuseIdentifier: kAccountTableViewCellIdentifier];

    UINib *uploadsHistoryTableViewCell = [UINib nibWithNibName: @"UploadsHistoryTableViewCell" bundle: nil];
    [self.accountTableView registerNib: uploadsHistoryTableViewCell forCellReuseIdentifier: kUploadsHistoryTableViewCellIdentifier];

    // set up pieChart
    UIView *pieChartContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 250)];
    
    [pieChartContainer addSubview: profileBarView];

    self.pieChart = [[XYPieChart alloc] initWithFrame: CGRectMake(0, 60, 180, 180)];
    CGPoint pieChartCenter = pieChartContainer.center;
    pieChartCenter.y = pieChartCenter.y + 30;
    
    [self.pieChart setCenter: pieChartCenter];

    [pieChartContainer addSubview: self.pieChart];

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

    [self.accountTableView setTableHeaderView: pieChartContainer];

    // other set up
    [self.lookAndFeel applyHollowGreenButtonStyleTo: self.calculateButton];
    
    [self.titleLabel setText:[NSString stringWithFormat:@"Tax Year for %ld", (long)self.configurationManager.getCurrentTaxYear]];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];

    self.accountTableView.dataSource = self;
    self.accountTableView.delegate = self;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(openReceiptBreakDownView:)
                                                 name: kReceiptItemsTableReceiptPressedNotification
                                               object: nil];

    // reset all state values
    self.catagoryDetails = [NSMutableDictionary new];
    self.slicePercentages = [NSMutableArray new];
    self.sliceColors = [NSMutableArray new];
    self.sliceNames = [NSMutableArray new];

    // load all Catagory
    NSArray *catagories = [self.dataService fetchCatagories];
    
    self.catagories = catagories;
    
    float totalAmount = 0;
    
    for (Catagory *catagory in self.catagories)
    {
        NSArray *records = [self.dataService fetchRecordsForCatagoryID: catagory.localID
                                                             inTaxYear: self.configurationManager.getCurrentTaxYear];
        NSArray *recordsForThisCatagory = records;
        
        // calculate the totals for each catagory from recordsForThisCatagory
        NSInteger totalQuantityForThisCatagory = 0;
        float totalAmountSpentOnThisCatagory = 0;
        
        for (Record *record in recordsForThisCatagory)
        {
            totalQuantityForThisCatagory = totalQuantityForThisCatagory + record.quantity;
            totalAmountSpentOnThisCatagory = totalAmountSpentOnThisCatagory + [record calculateTotal];
        }
        
        totalAmount = totalAmount + totalAmountSpentOnThisCatagory;
        
        NSMutableDictionary *catagoryDetail = [NSMutableDictionary new];
        [catagoryDetail setObject: [NSNumber numberWithInteger: totalQuantityForThisCatagory] forKey: kCatagoryDetailsKeyTotalQty];
        [catagoryDetail setObject: [NSNumber numberWithFloat: totalAmountSpentOnThisCatagory] forKey: kCatagoryDetailsKeyTotalAmount];
        
        [self.catagoryDetails setObject: catagoryDetail forKey: catagory.localID];
    }
    
    [self.accountTableView reloadData];
    
    // refresh pie chart
    for (Catagory *catagory in self.catagories)
    {
        [self.sliceColors addObject: catagory.color];
        [self.sliceNames addObject: catagory.name];
        
        NSMutableDictionary *catagoryDetailForThisCatagory = [self.catagoryDetails objectForKey: catagory.localID];
        
        float sumAmount = [[catagoryDetailForThisCatagory objectForKey: kCatagoryDetailsKeyTotalAmount] floatValue];
        
        [self.slicePercentages addObject: [NSNumber numberWithInt: sumAmount * 100 / totalAmount]];
    }
    
    [self.pieChart reloadData];
}

-(void)displayTutorials
{
    NSMutableArray *tutorials = [NSMutableArray new];
    
    //Each Stage represents a different group of Tutorial pop ups
    NSInteger currentTutorialStage = [self.tutorialManager getCurrentTutorialStageForViewController:self];
    
    if ( currentTutorialStage == 1 )
    {
        TutorialStep *tutorialStep1 = [TutorialStep new];
        
        tutorialStep1.text = @"Quickly view purchase totals for each category.\n\nClick a receipt to easily edit/transfer/delete the purchase allocations";
        tutorialStep1.size = CGSizeMake(290, 120);
        tutorialStep1.pointsUp = YES;
        
        [tutorials addObject:tutorialStep1];
        
        TutorialStep *tutorialStep2 = [TutorialStep new];
        
        tutorialStep2.origin = self.calculateButton.center;
        
        tutorialStep2.text = @"The Calculate button is the MOST important feature. Simply click Calculate and we will provide you with the correct GF tax claim based on your allocations for you!";
        tutorialStep2.size = CGSizeMake(290, 120);
        tutorialStep2.pointsUp = NO;
        
        [tutorials addObject:tutorialStep2];
        
        TutorialStep *tutorialStep3 = [TutorialStep new];
        
        tutorialStep3.text = @"All you need to do is add in the average price of a regular food item per category before the calculate feature can be used.\n\nYou can find these average food price items either online or in the quick help link we have provided";
        tutorialStep3.size = CGSizeMake(290, 160);
        tutorialStep3.pointsUp = YES;
        
        [tutorials addObject:tutorialStep3];
        
        [self.tutorialManager setTutorialDoneForViewController:self];
    }
    else
    {
        //don't show any tutorial
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
        [self displayTutorials];
    }
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    self.navigationController.navigationBarHidden = NO;

    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kReceiptItemsTableReceiptPressedNotification
                                                  object: nil];
}

- (IBAction) calculateButtonPressed: (UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (void) editProfilePressed: (UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (void) openReceiptBreakDownView: (NSNotification *) notification
{
    NSDictionary *notificationDictionary = [notification userInfo];

    NSString *receiptID = [notificationDictionary objectForKey: kReceiptIDKey];

    [self.navigationController pushViewController: [self.viewControllerFactory createReceiptBreakDownViewControllerForReceiptID: receiptID cameFromReceiptCheckingViewController: NO] animated: YES];
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

#pragma mark - XYPieChart Delegate
- (void) pieChart: (XYPieChart *) pieChart didDeselectSliceAtIndex: (NSUInteger) index
{
    // does same thing as didSelectSliceAtIndex
    [self pieChart: pieChart didSelectSliceAtIndex: index];
}

- (void) pieChart: (XYPieChart *) pieChart didSelectSliceAtIndex: (NSUInteger) index
{
    Catagory *thisCatagory = [self.catagories objectAtIndex: index];

    DLog(@"Catagory %@: %@ pressed", thisCatagory.localID, thisCatagory.name);

    self.currentlySelectedCatagory = thisCatagory;

    self.catagoryInfosToShow = nil;

    [self.accountTableView reloadData];

    [self.accountTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: index * 2 inSection: 0] atScrollPosition: UITableViewScrollPositionTop animated: YES];

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;
}

#pragma mark - UploadsHistoryTableViewCell function

- (void) recentUploadsLabelPressed
{
    NSAssert(self.currentlySelectedCatagory, @"self.currentlySelectedCatagory must not be nil");

    if (self.recentUploadsSelected)
    {
        self.recentUploadsSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = YES;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;

    // get the last 5 recent uploads
    if (self.currentlySelectedCatagory)
    {
        NSArray *catagoryInfos = [self.dataService fetchLatestNthCatagoryInfosforCatagory: self.currentlySelectedCatagory.localID forNth: 5 inTaxYear: self.configurationManager.getCurrentTaxYear];
        
        DLog(@"%@", catagoryInfos);
        self.catagoryInfosToShow = catagoryInfos;
        
        [self.accountTableView reloadData];
    }
}

- (void) previousWeekLabelPressed
{
    NSAssert(self.currentlySelectedCatagory, @"self.currentlySelectedCatagory must not be nil");

    if (self.previousWeekSelected)
    {
        self.previousWeekSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = YES;
    self.previousMonthSelected = NO;
    self.viewAllSelected = NO;

    NSDate *mondayOfThisWeek = [Utils dateForMondayOfThisWeek];
    DLog(@"Monday of this week is %@", mondayOfThisWeek.description);
    NSDate *mondayOfPreviousWeek = [Utils dateForMondayOfPreviousWeek];
    DLog(@"Monday of previous week is %@", mondayOfPreviousWeek.description);
    
    NSArray *catagoryInfos = [self.dataService fetchCatagoryInfoFromDate: mondayOfPreviousWeek
                                                                  toDate: mondayOfThisWeek
                                                               inTaxYear: self.configurationManager.getCurrentTaxYear
                                                             forCatagory: self.currentlySelectedCatagory.localID];
    
    DLog(@"%@", catagoryInfos);
    self.catagoryInfosToShow = catagoryInfos;
    
    [self.accountTableView reloadData];
}

- (void) previousMonthLabelPressed
{
    NSAssert(self.currentlySelectedCatagory, @"self.currentlySelectedCatagory must not be nil");

    if (self.previousMonthSelected)
    {
        self.previousMonthSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = YES;
    self.viewAllSelected = NO;

    NSDate *firstDayOfThisMonth = [Utils dateForFirstDayOfThisMonth];
    DLog(@"First day of this month is %@", firstDayOfThisMonth.description);

    NSDate *firstDayOfPreviousMonth = [Utils dateForFirstDayOfPreviousMonth];
    DLog(@"First Day Of Previous Month is %@", firstDayOfPreviousMonth.description);

    NSArray *catagoryInfos = [self.dataService fetchCatagoryInfoFromDate: firstDayOfPreviousMonth
                                                                  toDate: firstDayOfThisMonth
                                                               inTaxYear: self.configurationManager.getCurrentTaxYear
                                                             forCatagory: self.currentlySelectedCatagory.localID];
    DLog(@"%@", catagoryInfos);
    self.catagoryInfosToShow = catagoryInfos;
    
    [self.accountTableView reloadData];
}

- (void) viewAllLabelPressed
{
    NSAssert(self.currentlySelectedCatagory, @"self.currentlySelectedCatagory must not be nil");

    if (self.viewAllSelected)
    {
        self.viewAllSelected = NO;
        self.catagoryInfosToShow = nil;

        [self.accountTableView reloadData];

        return;
    }

    self.recentUploadsSelected = NO;
    self.previousWeekSelected = NO;
    self.previousMonthSelected = NO;
    self.viewAllSelected = YES;

    // all receipts from this catagory
    NSArray *catagoryInfos = [self.dataService fetchLatestNthCatagoryInfosforCatagory: self.currentlySelectedCatagory.localID
                                                                               forNth: -1
                                                                            inTaxYear: self.configurationManager.getCurrentTaxYear];
    
    self.catagoryInfosToShow = catagoryInfos;
    
    [self.accountTableView reloadData];
}

#pragma mark - UITableview DataSource

#define kBiggestLabelHeight         20
#define kMargin                     10
#define kTableCellHeight            35
#define kNoItemsTableViewCellHeight 40

- (CGFloat) calculateHeightForCellWithNumberOfCatagoryInfos: (NSInteger) numberOfCatagoryInfos
{
    if (numberOfCatagoryInfos)
    {
        float totalHeight = (kMargin + kBiggestLabelHeight + kMargin) * 4 + kTableCellHeight * numberOfCatagoryInfos + kMargin;
        
        return totalHeight;
    }
    else
    {
        float totalHeight = (kMargin + kBiggestLabelHeight + kMargin) * 4 + kNoItemsTableViewCellHeight + kMargin;
        
        return totalHeight;
    }
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.catagories.count * 2;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a AccountTableCell
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellId = kAccountTableViewCellIdentifier;
        AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[AccountTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        cell.clipsToBounds = YES;

        Catagory *thisCatagory = [self.catagories objectAtIndex: indexPath.row / 2];

        NSMutableDictionary *catagoryDetailForThisCatagory = [self.catagoryDetails objectForKey: thisCatagory.localID];

        NSInteger sumQuantity = [[catagoryDetailForThisCatagory objectForKey: kCatagoryDetailsKeyTotalQty] integerValue];
        float sumAmount = [[catagoryDetailForThisCatagory objectForKey: kCatagoryDetailsKeyTotalAmount] floatValue];

        cell.colorBoxColor = thisCatagory.color;
        cell.colorBox.backgroundColor = thisCatagory.color;

        [cell.catagoryNameLabel setText: thisCatagory.name];
        [cell.totalQuantityField setText: [NSString stringWithFormat: @"%ld", (long)sumQuantity]];
        [cell.totalAmountField setText: [NSString stringWithFormat: @"%.2f", sumAmount]];
        [self.lookAndFeel applyGrayBorderTo: cell.totalQuantityField];
        [self.lookAndFeel applyGrayBorderTo: cell.totalAmountField];

        if (thisCatagory.nationalAverageCost > 0)
        {
            [cell.averageNationalPriceField setText: [NSString stringWithFormat: @"%.2f", thisCatagory.nationalAverageCost]];
        }
        else
        {
            [cell.averageNationalPriceField setText: @"--"];
        }

        [self.lookAndFeel applyGreenBorderTo: cell.averageNationalPriceField];
        
        if (self.currentlySelectedCatagory)
        {
            if (thisCatagory == self.currentlySelectedCatagory)
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
        }
        
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorBox];
        
        if (thisCatagory == [self.catagories firstObject])
        {
            if (!self.currentlySelectedCatagory)
            {
                [cell.totalQtyLabel setHidden:NO];
                [cell.totalAmountLabel setHidden:NO];
                [cell.avgPriceLabel setHidden:NO];
            }
        }
        else
        {
            if (self.currentlySelectedCatagory)
            {
                if (thisCatagory == self.currentlySelectedCatagory)
                {
                    [cell.totalQtyLabel setHidden:NO];
                    [cell.totalAmountLabel setHidden:NO];
                    [cell.avgPriceLabel setHidden:NO];
                }
                else
                {
                    [cell.totalQtyLabel setHidden:YES];
                    [cell.totalAmountLabel setHidden:YES];
                    [cell.avgPriceLabel setHidden:YES];
                }
            }
            else
            {
                [cell.totalQtyLabel setHidden:YES];
                [cell.totalAmountLabel setHidden:YES];
                [cell.avgPriceLabel setHidden:YES];
            }
        }

        return cell;
    }
    // display a UploadsHistoryTableViewCell
    else
    {
        static NSString *cellId = kUploadsHistoryTableViewCellIdentifier;
        UploadsHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

        if (cell == nil)
        {
            cell = [[UploadsHistoryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        }

        cell.lookAndFeel = self.lookAndFeel;

        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        cell.clipsToBounds = YES;

        UITapGestureRecognizer *recentUploadsLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(recentUploadsLabelPressed)];

        UITapGestureRecognizer *previousWeekLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(previousWeekLabelPressed)];

        UITapGestureRecognizer *previousMonthLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(previousMonthLabelPressed)];

        UITapGestureRecognizer *viewAllLabelTap =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(viewAllLabelPressed)];

        [cell.recentUploadsLabel addGestureRecognizer: recentUploadsLabelTap];

        [cell.previousWeekLabel addGestureRecognizer: previousWeekLabelTap];

        [cell.previousMonthLabel addGestureRecognizer: previousMonthLabelTap];

        [cell.viewAllLabel addGestureRecognizer: viewAllLabelTap];

        Catagory *thisCatagory = [self.catagories objectAtIndex: (indexPath.row - 1) / 2];

        cell.catagoryColor = thisCatagory.color;

        if (thisCatagory == self.currentlySelectedCatagory)
        {
            if (self.recentUploadsSelected)
            {
                cell.recentUploadReceipts = self.catagoryInfosToShow;

                [cell selectRecentUpload];
            }
            else if (self.previousWeekSelected)
            {
                cell.previousWeekReceipts = self.catagoryInfosToShow;

                [cell selectPreviousWeek];
            }
            else if (self.previousMonthSelected)
            {
                cell.previousMonthReceipts = self.catagoryInfosToShow;

                [cell selectPreviousMonth];
            }
            else if (self.viewAllSelected)
            {
                cell.viewAllReceipts = self.catagoryInfosToShow;
                [cell selectViewAll];
            }
            else
            {
                [cell selectNothing];
            }
        }

        return cell;
    }
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    // display a ReceiptBreakDownItemTableViewCell
    if (indexPath.row % 2 == 0)
    {
        return kCatagoryTableRowHeight;
    }
    // display a kReceiptBreakDownToolBarTableViewCell
    else
    {
        Catagory *thisCatagory = [self.catagories objectAtIndex: (indexPath.row - 1) / 2];

        // only show the row if currentlySelectedRecord == thisRecord
        if (thisCatagory == self.currentlySelectedCatagory)
        {
            return [self calculateHeightForCellWithNumberOfCatagoryInfos: self.catagoryInfosToShow.count];
        }
    }

    return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row % 2 == 0)
    {
        Catagory *thisCatagory = [self.catagories objectAtIndex: indexPath.row / 2];

        if (thisCatagory == self.currentlySelectedCatagory)
        {
            self.currentlySelectedCatagory = nil;

            self.catagoryInfosToShow = nil;

            [tableView reloadData];
        }
        else
        {
            self.currentlySelectedCatagory = thisCatagory;

            self.catagoryInfosToShow = nil;

            [tableView reloadData];

            [tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }

        self.recentUploadsSelected = NO;
        self.previousWeekSelected = NO;
        self.previousMonthSelected = NO;
        self.viewAllSelected = NO;
    }
}

@end