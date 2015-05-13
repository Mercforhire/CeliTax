//
//  ReceiptCheckingViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptCheckingViewController.h"
#import "HMSegmentedControl.h"
#import "ReceiptScrollBarView.h"
#import "AddCatagoryViewController.h"
#import "ItemCatagory.h"
#import "User.h"
#import "UserManager.h"
#import "CatagoryRecord.h"

@interface ReceiptCheckingViewController () <UITableViewDelegate, UITableViewDataSource> 

@property (weak, nonatomic) IBOutlet UITableView *catagoryRecordsTable;


@property (weak, nonatomic) IBOutlet ReceiptScrollBarView *receiptScrollView;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *buttonBarPlaceHolder;
@property (strong, nonatomic) HMSegmentedControl *buttonBar;

@property (strong, nonatomic) NSMutableArray *receiptImages;
@property (strong, nonatomic) NSArray *catagories;
@property (strong, nonatomic) NSMutableArray *catagoryNames;
@property (strong, nonatomic) NSMutableArray *catagoryRecordsForThisReceipt;

@property (nonatomic, strong) ItemCatagory *currentlySelectedCatagory;

@end

@implementation ReceiptCheckingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.catagoryRecordsForThisReceipt = [NSMutableArray new];
    
    //load the receiptImages array with some demo images
    self.receiptImages = [NSMutableArray new];
    
    UIImage *image1 = [UIImage imageNamed:@"ReceiptPic-1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"ReceiptPic-2.jpg"];
    
    [self.receiptImages addObject:image1];
    [self.receiptImages addObject:image2];
    
    self.receiptID = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //load all the catagories
    [self.dataService fetchCatagoriesForUserKey:self.userManager.user.userKey
        success:^(NSArray *catagories) {
            
            self.catagories = catagories;
            
        } failure:^(NSString *reason) {
            //if no catagories
        }];
    
    self.catagoryNames = [NSMutableArray new];
    
    for (ItemCatagory *itemCatagory in self.catagories)
    {
        [self.catagoryNames addObject:itemCatagory.name];
    }
    
    [self refreshButtonBar];
    
    //load catagory records for this receipt
    [self.dataService fetchCatagoryRecordsForUserKey:self.userManager.user.userKey
                                        forReceiptID:self.receiptID
         success:^(NSArray *catagoryRecord) {
        
        [self.catagoryRecordsForThisReceipt addObjectsFromArray:catagoryRecord];
        
    } failure:^(NSString *reason) {
        //failure
    }];
}

-(void)refreshButtonBar
{
    if (self.buttonBar)
    {
        [self.buttonBar removeFromSuperview];
    }
    
    // Segmented control with scrolling
    self.buttonBar = [[HMSegmentedControl alloc] initWithSectionTitles: self.catagoryNames];
    self.buttonBar.frame = self.buttonBarPlaceHolder.frame;
    self.buttonBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.buttonBar.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.buttonBar.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.buttonBar.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.buttonBar.verticalDividerEnabled = YES;
    self.buttonBar.verticalDividerColor = [UIColor blackColor];
    self.buttonBar.verticalDividerWidth = 1.0f;
    [self.buttonBar setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
        return attString;
    }];
    [self.buttonBar addTarget:self action:@selector(catagoryBarChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.buttonBar];
}

-(void)catagoryBarChanged:(HMSegmentedControl *)sender
{
    self.currentlySelectedCatagory = self.catagories[sender.selectedSegmentIndex];
    
    DLog(@"Catagory %@ selected", self.currentlySelectedCatagory.name);
}

- (IBAction)confirmPressed:(UIButton *)sender
{
    [self.manipulationService addRecordForUserKey:self.userManager.user.userKey
                                    forCatagoryID:self.currentlySelectedCatagory.identifer
                                     forReceiptID:self.receiptID
                                      forQuantity:self.quantityField.text.integerValue
                                        forAmount:self.amountField.text.floatValue
                                          success:^{
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSString *reason) {
        //should not happen
    }];
}

#pragma mark - UITableview DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.catagoryRecordsForThisReceipt.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CatagoryRecordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CatagoryRecord *thisCatagoryRecord = [self.catagoryRecordsForThisReceipt objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:thisCatagoryRecord.itemCatagoryName];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%ld X $%.2f",thisCatagoryRecord.quantity, thisCatagoryRecord.amount]];
    
    return cell;
}

#pragma mark - UITableview Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatagoryRecord *thisCatagoryRecord = [self.catagoryRecordsForThisReceipt objectAtIndex:indexPath.row];
    
    DLog(@"CatagoryRecord %ld pressed", (long)thisCatagoryRecord.identifer );
}

@end
