//
//  MyAccountViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
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

#define kCatagoryTableRowHeight     70

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate> {
    RevealBlock _revealBlock;
}

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

@property (nonatomic, strong) NSMutableArray *itemCatagories; //of ItemCatagory
@property (strong, nonatomic) NSMutableDictionary *RecordsDictionary; //Key: ItemCatagoryID, Value: NSArray of Record

@end

@implementation MyAccountViewController

-(id)initWithRevealBlock:(RevealBlock)revealBlock
{
    if (self = [super initWithNibName:@"MyAccountViewController" bundle:nil])
    {
        _revealBlock = [revealBlock copy];
        
        //initialize the slider bar menu button
        UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        menuButton.tintColor = [UIColor colorWithRed:7.0/255 green:61.0/255 blue:48.0/255 alpha:1.0f];
        [menuButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = menuItem;
        
        //add an Edit button for the right side
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCatagoriesPressed)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
    return self;
}

//slide out the slider bar
- (void)revealSidebar
{
    _revealBlock();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load user info
    [self.nameLabel setText:[NSString stringWithFormat:@"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];
    [self.addressLabel setText:[NSString stringWithFormat:@"%@, %@", self.userManager.user.country, self.userManager.user.postalCode]];
    
    //set up tableview
    UINib *accountTableCell = [UINib nibWithNibName:@"AccountTableViewCell" bundle:nil];
    [self.accountTableView registerNib:accountTableCell forCellReuseIdentifier:@"AccountTableCell"];
    self.accountTableView.dataSource = self;
    self.accountTableView.delegate = self;
    
    self.itemCatagories = [NSMutableArray new];
    self.RecordsDictionary = [NSMutableDictionary new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.itemCatagories removeAllObjects];
    
    [self.RecordsDictionary removeAllObjects];
    
    //load itemCatagories
    [self.dataService fetchCatagoriesSuccess:^(NSArray *catagories) {
        
        if (catagories && catagories.count)
        {
            [self.itemCatagories addObjectsFromArray:catagories];
        }
        
    } failure:^(NSString *reason) {
        //should not happen
    }];
    
    //load RecordsDictionary
    for (Catagory *catagory in self.itemCatagories)
    {
        [self.dataService fetchRecordsForCatagoryID:catagory.identifer
                                            success:^(NSArray *Record) {
                                                
                                                if (Record && Record.count)
                                                {
                                                    [self.RecordsDictionary setObject:Record forKey:catagory.identifer];
                                                }
                                                
                                            } failure:^(NSString *reason) {
                                                //should not happen
                                            }];
    }
    
    [self.accountTableView reloadData];
}

- (IBAction)calculateButtonPressed:(UIButton *)sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

-(void)editCatagoriesPressed
{
    [self.navigationController pushViewController:[self.viewControllerFactory createCatagoriesManagementViewController] animated:YES];
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
    
    Catagory *thisItemCatagory = [self.itemCatagories objectAtIndex:indexPath.row];
    
    NSArray *recordsForThisCatagory = [self.RecordsDictionary objectForKey:thisItemCatagory.identifer];
    
    NSInteger sumQuantity = 0;
    float sumAmount = 0.0;
    
    for (Record *record in recordsForThisCatagory)
    {
        sumQuantity = sumQuantity + record.quantity;
        sumAmount = sumAmount + record.quantity * record.amount;
    }
    
    [cell.colorBox setBackgroundColor: thisItemCatagory.color];
    [cell.catagoryNameLabel setText: thisItemCatagory.name];
    [cell.quantityLabel setText: [NSString stringWithFormat:@"%ld", (long)sumQuantity]];
    [cell.totalAmountLabel setText: [NSString stringWithFormat:@"$%.2f",sumAmount]];
    
    if (thisItemCatagory.nationalAverageCost > 0)
    {
        [cell.averageCostLabel setText: [NSString stringWithFormat:@"$%.2f",thisItemCatagory.nationalAverageCost]];
    }
    else
    {
        [cell.averageCostLabel setText: @"--"];
    }
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCatagoryTableRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Catagory *thisItemCatagory = [self.itemCatagories objectAtIndex:indexPath.row];
    
    DLog(@"Catagory %ld: %@ pressed", (long)thisItemCatagory.identifer, thisItemCatagory.name );
    
    [AlertDialogsProvider showWorkInProgressDialog];
}


@end
