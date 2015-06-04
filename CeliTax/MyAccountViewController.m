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
#import "CatagoriesManagementViewController.h"
#import "XYPieChart.h"

#define kCatagoryTableRowHeight                 70

#define kCatagoryDetailsKeyTotalQty             @"CatagoryDetailsKeyTotalQty"
#define kCatagoryDetailsKeyTotalAmount          @"CatagoryDetailsKeyTotalAmount"

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;

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

@end

@implementation MyAccountViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // load user info
    [self.nameLabel setText: [NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];

    // set up tableview
    UINib *accountTableCell = [UINib nibWithNibName: @"AccountTableViewCell" bundle: nil];
    [self.accountTableView registerNib: accountTableCell forCellReuseIdentifier: @"AccountTableCell"];
    self.accountTableView.dataSource = self;
    self.accountTableView.delegate = self;
    
    [self.avatarImageView setImage:self.userManager.user.avatarImage];
    
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
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    self.catagoryDetails = [NSMutableDictionary new];
    self.slicePercentages = [NSMutableArray new];
    self.sliceColors = [NSMutableArray new];
    self.sliceNames = [NSMutableArray new];

    // load all Catagory
    [self.dataService fetchCatagoriesSuccess: ^(NSArray *catagories) {
        self.catagories = catagories;
        
        __block float totalAmount = 0;
        
        for (Catagory *catagory in self.catagories)
        {
            [self.dataService fetchRecordsForCatagoryID: catagory.identifer success: ^(NSArray *records) {
                NSArray *recordsForThisCatagory = records;

                // calculate the totals for each catagory from recordsForThisCatagory
                NSInteger totalQuantityForThisCatagory = 0;
                float totalAmountSpentOnThisCatagory = 0;

                for (Record *record in recordsForThisCatagory)
                {
                    totalQuantityForThisCatagory = totalQuantityForThisCatagory + record.quantity;
                    totalAmountSpentOnThisCatagory = totalAmountSpentOnThisCatagory + record.quantity * record.amount;
                }
                
                totalAmount = totalAmount + totalAmountSpentOnThisCatagory;

                NSMutableDictionary *catagoryDetail = [NSMutableDictionary new];
                [catagoryDetail setObject: [NSNumber numberWithInteger: totalQuantityForThisCatagory] forKey: kCatagoryDetailsKeyTotalQty];
                [catagoryDetail setObject: [NSNumber numberWithFloat: totalAmountSpentOnThisCatagory] forKey: kCatagoryDetailsKeyTotalAmount];

                [self.catagoryDetails setObject: catagoryDetail forKey: catagory.identifer];
            } failure: ^(NSString *reason) {
                // shouldn't happen
            }];
        }
        
        [self.accountTableView reloadData];
        
        //refresh pie chart
        for (Catagory *catagory in self.catagories)
        {
            [self.sliceColors addObject: catagory.color];
            [self.sliceNames addObject: catagory.name];
            
            NSMutableDictionary *catagoryDetailForThisCatagory = [self.catagoryDetails objectForKey:catagory.identifer];
            
            float sumAmount = [[catagoryDetailForThisCatagory objectForKey:kCatagoryDetailsKeyTotalAmount] floatValue];
            
            [self.slicePercentages addObject: [NSNumber numberWithInt: sumAmount * 100 / totalAmount]];
        }
        
        [self.pieChart reloadData];
        
    } failure: ^(NSString *reason) {
        // should not happen
    }];
}

- (IBAction) calculateButtonPressed: (UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (IBAction)editProfilePressed:(UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (void) editCatagoriesPressed
{
    [self.navigationController pushViewController: [self.viewControllerFactory createCatagoriesManagementViewController] animated: YES];
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
    
    DLog(@"Catagory %@ clicked", thisCatagory.name);
    
    DLog(@"Catagory %@: %@ pressed", thisCatagory.identifer, thisCatagory.name);
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.catagories.count;
}

- (AccountTableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = @"AccountTableCell";
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];

    if (cell == nil)
    {
        cell = [[AccountTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
    }

    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];

    Catagory *thisCatagory = [self.catagories objectAtIndex: indexPath.row];

    NSMutableDictionary *catagoryDetailForThisCatagory = [self.catagoryDetails objectForKey:thisCatagory.identifer];

    NSInteger sumQuantity = [[catagoryDetailForThisCatagory objectForKey:kCatagoryDetailsKeyTotalQty] integerValue];
    float sumAmount = [[catagoryDetailForThisCatagory objectForKey:kCatagoryDetailsKeyTotalAmount] floatValue];

    cell.colorBoxColor = thisCatagory.color;
    [cell.catagoryNameLabel setText: thisCatagory.name];
    [cell.totalQuantityField setText: [NSString stringWithFormat: @"%ld", (long)sumQuantity]];
    [cell.totalAmountField setText: [NSString stringWithFormat: @"%.2f", sumAmount]];

    if (thisCatagory.nationalAverageCost > 0)
    {
        [cell.averageNationalPriceField setText: [NSString stringWithFormat: @"%.2f", thisCatagory.nationalAverageCost]];
    }
    else
    {
        [cell.averageNationalPriceField setText: @"--"];
    }
    
    [cell setTableCellToSelectedMode];

    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kCatagoryTableRowHeight;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Catagory *thisCatagory = [self.catagories objectAtIndex: indexPath.row];

    DLog(@"Catagory %@: %@ pressed", thisCatagory.identifer, thisCatagory.name);
}

@end