//
//  EditCatagoriesViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesManagementViewController.h"
#import "AlertDialogsProvider.h"
#import "AccountTableViewCell.h"
#import "ItemCatagory.h"
#import "CatagoryRecord.h"
#import "User.h"
#import "UserManager.h"
#import "DeleteCatagoryViewController.h"
#import "TransferCatagoryViewController.h"
#import "ModifyCatagoryViewController.h"
#import "ViewControllerFactory.h"

#define kCatagoryTableRowHeight     70

@interface CatagoriesManagementViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *itemCatagories; //of ItemCatagory
@property (strong, nonatomic) NSMutableDictionary *catagoryRecordsDictionary; //Key: ItemCatagoryID, Value: NSArray of CatagoryRecord

@property (weak, nonatomic) IBOutlet UITableView *accountTable;
@property (weak, nonatomic) IBOutlet UIButton *addCatagoryButton;

@property (weak, nonatomic) ItemCatagory *currentlySelectedCatagory;


@end

@implementation CatagoriesManagementViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.accountTable.dataSource = self;
    self.accountTable.delegate = self;
    
    UINib *accountTableCell = [UINib nibWithNibName:@"AccountTableViewCell" bundle:nil];
    [self.accountTable registerNib:accountTableCell forCellReuseIdentifier:@"AccountTableCell"];
    
    self.itemCatagories = [NSMutableArray new];
    self.catagoryRecordsDictionary = [NSMutableDictionary new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshData];
}

-(void)refreshData
{
    self.currentlySelectedCatagory = nil;
    
    [self.itemCatagories removeAllObjects];
    
    //load itemCatagories
    [self.dataService fetchCatagoriesForUserKey:self.userManager.user.userKey
        success:^(NSArray *catagories) {
            
            if (catagories && catagories.count)
            {
                [self.itemCatagories addObjectsFromArray:catagories];
            }
            
        } failure:^(NSString *reason) {
            //should not happen
        }];
    
    [self.catagoryRecordsDictionary removeAllObjects];
    
    //load catagoryRe cordsDictionary
    for (ItemCatagory *catagory in self.itemCatagories)
    {
        [self.dataService fetchCatagoryRecordsForUserKey:self.userManager.user.userKey forCatagoryID:catagory.identifer
                 success:^(NSArray *catagoryRecord) {
                     
                     if (catagoryRecord && catagoryRecord.count)
                     {
                         [self.catagoryRecordsDictionary setObject:catagoryRecord forKey:[NSNumber numberWithInteger:catagory.identifer]];
                     }
                     
                 } failure:^(NSString *reason) {
                     //should not happen
                 }];
    }
    
    [self.accountTable reloadData];
}

- (IBAction)addCatagoryPressed:(UIButton *)sender
{
    
}

#pragma mark - UITableview DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemCatagories.count;
}

- (AccountTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"AccountTableCell";
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[AccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ItemCatagory *thisItemCatagory = [self.itemCatagories objectAtIndex:indexPath.row];
    
    if (self.currentlySelectedCatagory == thisItemCatagory)
    {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSArray *recordsForThisCatagory = [self.catagoryRecordsDictionary objectForKey:[NSNumber numberWithInteger:thisItemCatagory.identifer]];
    
    NSInteger sumQuantity = 0;
    float sumAmount = 0.0;
    
    for (CatagoryRecord *record in recordsForThisCatagory)
    {
        sumQuantity = sumQuantity + record.quantity;
        sumAmount = sumAmount + record.amount;
    }
    
    [cell.colorBox setBackgroundColor:thisItemCatagory.color];
    [cell.catagoryNameLabel setText:thisItemCatagory.name];
    [cell.quantityLabel setText:[NSString stringWithFormat:@"%ld", (long)sumQuantity]];
    [cell.totalAmountLabel setText:[NSString stringWithFormat:@"$%.2f",sumAmount]];
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCatagoryTableRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCatagory *thisItemCatagory = [self.itemCatagories objectAtIndex:indexPath.row];
    
    if (!self.currentlySelectedCatagory || self.currentlySelectedCatagory != thisItemCatagory)
    {
        self.currentlySelectedCatagory = thisItemCatagory;
        
        DLog(@"Catagory %ld: %@ selected", (long)self.currentlySelectedCatagory.identifer, self.currentlySelectedCatagory.name );
    }
    else
    {
        self.currentlySelectedCatagory = nil;
        
        DLog(@"Catagory unselected");
    }
    
    [tableView reloadData];
}

@end
