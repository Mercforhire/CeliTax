//
//  YearSavingViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-08-14.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "YearSavingViewController.h"
#import "HollowWhiteButton.h"
#import "ConfigurationManager.h"
#import "Catagory.h"
#import "Record.h"
#import "YearSummaryViewController.h"
#import "ViewControllerFactory.h"

@interface YearSavingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *yearSavingsTitle;
@property (weak, nonatomic) IBOutlet UILabel *amountTitle;
@property (weak, nonatomic) IBOutlet HollowWhiteButton *viewDetailsButton;

@end

@implementation YearSavingViewController

-(void)setupUI
{
    [self.view setBackgroundColor:self.lookAndFeel.appGreenColor];
    
    [self.viewDetailsButton setLookAndFeel:self.lookAndFeel];
    
    [self.yearSavingsTitle setText:[NSString stringWithFormat:@"Your %ld savings:", (long)self.configurationManager.getCurrentTaxYear]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // load all Catagory
    NSArray *catagories = [self.dataService fetchCatagories];
    
    float totalSavingsAmount = 0;
    
    for (Catagory *catagory in catagories)
    {
        NSArray *recordsForThisCatagory = [self.dataService fetchRecordsForCatagoryID: catagory.localID
                                                                            inTaxYear: self.configurationManager.getCurrentTaxYear];
        
        // Separate recordsForThisCatagory into groups of the same Unit Type
        NSMutableDictionary *recordsOfEachType = [NSMutableDictionary new];
        
        for (Record *record in recordsForThisCatagory)
        {
            NSString *key = [Record unitTypeIntToUnitTypeString:record.unitType];
            
            NSMutableArray *recordsOfSameType = [recordsOfEachType objectForKey:key];
            
            if (!recordsOfSameType)
            {
                recordsOfSameType = [NSMutableArray new];
            }
            
            [recordsOfSameType addObject:record];
            
            [recordsOfEachType setObject:recordsOfSameType forKey:key];
        }
        
        //Process the Unit Types in order: Item, ML, L, G, KG
        NSArray *orderOfUnitTypesToProcess = [NSArray arrayWithObjects:kUnitItemKey, kUnitMLKey, kUnitLKey, kUnitGKey, kUnit100GKey, kUnitKGKey, nil];
        
        for (NSString *key in orderOfUnitTypesToProcess)
        {
            NSMutableArray *recordsOfSameType = [recordsOfEachType objectForKey:key];
            
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
            
            NSNumber *nationalAverageCost = [catagory.nationalAverageCosts objectForKey:key];
            
            float totalAvgCost = 0;
            
            if (!nationalAverageCost)
            {
                nationalAverageCost = [NSNumber numberWithFloat: -1];
                
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
        }
    }
    
    [self.amountTitle setText: [NSString stringWithFormat: @"$%.2f", totalSavingsAmount]];
}

- (IBAction)viewDetailsPressed:(HollowWhiteButton *)sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createYearSummaryViewController] animated: YES];
}

@end
