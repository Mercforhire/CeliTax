//
//  TaxYearSummaryViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "YearSummaryViewController.h"
#import "YearSummaryTableViewCell.h"
#import "HollowGreenButton.h"
#import "AlertDialogsProvider.h"
#import "WYPopoverController.h"
#import "SendReceiptsToViewController.h"
#import "ViewControllerFactory.h"

#import "CeliTax-Swift.h"

#define kYearSummaryTableViewCellIdentifier             @"YearSummaryTableViewCell"
#define kYearSummaryTableViewCellHeight                 60

@interface YearSummaryViewController () <UITableViewDataSource, UITableViewDelegate, SendReceiptsViewPopUpDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSavingsLabel;
@property (weak, nonatomic) IBOutlet UITableView *summaryTableView;
@property (weak, nonatomic) IBOutlet HollowGreenButton *exportButton;

@property (nonatomic, strong) WYPopoverController *sendReceiptsPopover;
@property (nonatomic, strong) SendReceiptsToViewController *sendReceiptsToViewController;

@property (nonatomic, strong) NSArray *catagories; // of ItemCategory
// NSMutableArray of NSArray of a fixed size 4:
// (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
@property (strong, nonatomic) NSMutableArray *catagoryRows;

@end

@implementation YearSummaryViewController

-(void)setupUI
{
    [self.exportButton setLookAndFeel:self.lookAndFeel];
    
    self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld Gluten-Free Tax Savings", nil), (long)[self.configurationManager fetchTaxYear]];
    
    // set up tableview
    UINib *yearSummaryTableViewCell = [UINib nibWithNibName: @"YearSummaryTableViewCell" bundle: nil];
    [self.summaryTableView registerNib: yearSummaryTableViewCell forCellReuseIdentifier: kYearSummaryTableViewCellIdentifier];
    
    self.sendReceiptsToViewController = [self.viewControllerFactory createSendReceiptsToViewController];
    self.sendReceiptsPopover = [[WYPopoverController alloc] initWithContentViewController: self.sendReceiptsToViewController];
    (self.sendReceiptsPopover).theme = [WYPopoverTheme theme];
    
    WYPopoverTheme *popUpTheme = self.sendReceiptsPopover.theme;
    popUpTheme.fillTopColor = self.lookAndFeel.appGreenColor;
    popUpTheme.fillBottomColor = self.lookAndFeel.appGreenColor;
    
    (self.sendReceiptsPopover).theme = popUpTheme;
    
    [self.exportButton setTitle:NSLocalizedString(@"Export Report", nil) forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    // load all ItemCategory
    NSArray *catagories = [self.dataService fetchCategories];
    
    self.catagories = catagories;
    
    self.summaryTableView.dataSource = self;
    self.summaryTableView.delegate = self;
    
    (self.sendReceiptsToViewController).delegate = self;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // reset all state values
    self.catagoryRows = [NSMutableArray new];
    
    float totalSavingsAmount = 0;
    
    // Start filling in self.catagoryRows: (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
    
    for (ItemCategory *category in self.catagories)
    {
        NSArray *recordsForThisCatagory = [self.dataService fetchRecordsForCatagoryID:category.localID taxYear:[self.configurationManager fetchTaxYear]];
        
        // Separate recordsForThisCatagory into groups of the same Unit Type
        NSMutableDictionary *recordsOfEachType = [NSMutableDictionary new];
        
        for (Record *record in recordsForThisCatagory)
        {
            NSString *key = [Record unitTypeToUnitTypeString:record.unitType];
            
            NSMutableArray *recordsOfSameType = recordsOfEachType[key];
            
            if (!recordsOfSameType)
            {
                recordsOfSameType = [NSMutableArray new];
            }
            
            [recordsOfSameType addObject:record];
            
            recordsOfEachType[key] = recordsOfSameType;
        }
        
        //Process the Unit Types in order: Item, ML, L, G, KG
        NSArray *orderOfUnitTypesToProcess = @[Record.kUnitItemKey, Record.kUnitMLKey, Record.kUnitLKey, Record.kUnitGKey, Record.kUnit100GKey, Record.kUnitKGKey, Record.kUnitFlozKey, Record.kUnitPtKey, Record.kUnitQtKey, Record.kUnitGalKey, Record.kUnitOzKey, Record.kUnitLbKey];
        
        for (NSString *key in orderOfUnitTypesToProcess)
        {
            NSMutableArray *recordsOfSameType = recordsOfEachType[key];
            
            if (!recordsOfSameType.count)
            {
                continue;
            }
            
            float totalAmountSpentOnThisCatagoryAndUnitType = 0;
            NSInteger totalQuantityForThisCatagoryAndUnitType = 0;
            
            for (Record *record in recordsOfSameType)
            {
                totalQuantityForThisCatagoryAndUnitType += record.quantity;
                totalAmountSpentOnThisCatagoryAndUnitType += [record calculateTotal];
            }
            
            NSNumber *nationalAverageCost = category.nationalAverageCosts[key];
            
            float totalAvgCost = 0;
            
            if (!nationalAverageCost)
            {
                nationalAverageCost = @-1.0f;
                
                totalAvgCost = -1;
            }
            else
            {
                totalAvgCost = nationalAverageCost.floatValue * totalQuantityForThisCatagoryAndUnitType;
            }
            
            float gfSavings = 0;
            
            if (totalAvgCost >= 0)
            {
                gfSavings = totalAmountSpentOnThisCatagoryAndUnitType - totalAvgCost;
            }
            else
            {
                gfSavings = -1;
            }
            
            if (gfSavings >= 0)
            {
                totalSavingsAmount += gfSavings;
            }
            
            // (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
            NSMutableArray *rowArray = [NSMutableArray arrayWithObjects:category.localID, key, @(totalAmountSpentOnThisCatagoryAndUnitType), @(totalAvgCost), @(gfSavings), nil];
            
            [self.catagoryRows addObject:rowArray];
        }
    }
    
    [self.summaryTableView reloadData];
    
    self.totalSavingsLabel.text = [NSString stringWithFormat: @"$%.2f", totalSavingsAmount];
    
    //do this on a background thread
    
    //build the YearSummaryData object from above data
    YearSummaryData *yearSummaryData = [[YearSummaryData alloc] init];
    
    yearSummaryData.taxYear = self.configurationManager.fetchTaxYear;
    yearSummaryData.totalSaving = totalSavingsAmount;
    
    for (ItemCategory *category in self.catagories)
    {
        SimpleCategory *simpleCategory = [[SimpleCategory alloc] initWithCategory:category];
        
        [yearSummaryData addSimpleCategory:simpleCategory];
    }
}

- (IBAction)exportPressed:(HollowGreenButton *)sender
{
    // open up 'Send Receipts To' pop up
    [self.sendReceiptsPopover presentPopoverFromRect: self.exportButton.frame inView: self.view permittedArrowDirections: WYPopoverArrowDirectionDown animated: YES];
}

-(void)showSavingWarningDialog
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil)
                                                      message:NSLocalizedString(@"The total average price should not be higher than the actual total spent, please check to see if the correct average price was entered.", nil)
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"Ok", nil),nil];
    
    [message show];
}

#pragma mark - SendReceiptsViewPopUpDelegate

- (void) sendReceiptsToEmailRequested: (NSString *) emailAddress
{
    [self.sendReceiptsPopover dismissPopoverAnimated: YES];
    
    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.catagoryRows.count;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = kYearSummaryTableViewCellIdentifier;
    YearSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    
    if (cell == nil)
    {
        cell = [[YearSummaryTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        cell.clipsToBounds = YES;
    }
    
    // (CatagoryID, UnitTypeString, Total Spent, Total average cost, Total GF savings)
    NSArray *dataForThisRow = (self.catagoryRows)[indexPath.row];
    
    NSString *catagoryID = dataForThisRow.firstObject;
    
    ItemCategory *thisCatagory = [self.dataService fetchCategory:catagoryID];
    
    NSString *unitTypeString = dataForThisRow[1];
    
    float totalSpent = [dataForThisRow[2] floatValue];
    
    float totalAvgCost = [dataForThisRow[3] floatValue];
    
    float totalSavings = [dataForThisRow[4] floatValue];
    
    cell.colorView.backgroundColor = thisCatagory.color;
    
    if ([unitTypeString isEqualToString:Record.kUnitItemKey])
    {
        (cell.catagoryNameLabel).text = thisCatagory.name;
    }
    else if ([unitTypeString isEqualToString:Record.kUnitGKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (g)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnit100GKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (100g)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitKGKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (kg)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitLKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (L)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitMLKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (mL)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitFlozKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (fl oz)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitPtKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (pt)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitQtKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (qt)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitGalKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (gal)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitOzKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (oz)", nil), thisCatagory.name];
    }
    else if ([unitTypeString isEqualToString:Record.kUnitLbKey])
    {
        (cell.catagoryNameLabel).text = [NSString stringWithFormat:NSLocalizedString(@"%@ per (lb)", nil), thisCatagory.name];
    }
    
    (cell.totalSpentField).text = [NSString stringWithFormat: @"%.2f", totalSpent];
    (cell.totalAvgCostField).text = [NSString stringWithFormat: @"%.2f", totalAvgCost];
    
    if (totalSavings >= 0)
    {
        (cell.gfSavingsField).text = [NSString stringWithFormat: @"%.2f", totalSavings];
        (cell.gfSavingsField).textColor = self.lookAndFeel.appGreenColor;
        [cell.gfSavingsField setEnabled:YES];
        [cell.exclaimationButton setHidden:YES];
    }
    else
    {
        (cell.gfSavingsField).text = @"";
        [cell.gfSavingsField setEnabled:NO];
        [cell.exclaimationButton setHidden:NO];
        
        [cell.exclaimationButton addTarget:self
                                    action:@selector(showSavingWarningDialog)
                          forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.lookAndFeel applyGrayBorderTo: cell.totalSpentField];
    [self.lookAndFeel applyGrayBorderTo: cell.totalAvgCostField];
    [self.lookAndFeel applyGreenBorderTo: cell.gfSavingsField];
    
    [self.lookAndFeel applySlightlyDarkerBorderTo: cell.colorView];
    
    if (indexPath.row == 0)
    {
        [cell showLabels];
    }
    else
    {
        [cell hideLabels];
    }
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kYearSummaryTableViewCellHeight;
}

@end
