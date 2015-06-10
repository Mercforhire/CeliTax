//
//  EditCatagoriesViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "CatagoriesManagementViewController.h"
#import "AlertDialogsProvider.h"
#import "Catagory.h"
#import "Record.h"
#import "User.h"
#import "UserManager.h"
#import "DeleteCatagoryViewController.h"
#import "TransferCatagoryViewController.h"
#import "ModifyCatagoryViewController.h"
#import "ViewControllerFactory.h"
#import "AddCatagoryViewController.h"
#import "CatagoriesManagementTableViewCell.h"
#import "WYPopoverController.h"
#import "ModifyCatagoryPopUpViewController.h"
#import "WYPopoverController.h"

#define kCatagoryTableRowHeight     70

@interface CatagoriesManagementViewController () <UITableViewDataSource, UITableViewDelegate, ModifyCatagoryPopUpDelegate, PopUpViewControllerProtocol>

@property (nonatomic, strong) NSMutableArray *itemCatagories; //of ItemCatagory
@property (strong, nonatomic) NSMutableDictionary *RecordsDictionary; //Key: ItemCatagoryID, Value: NSArray of Record

@property (weak, nonatomic) IBOutlet UITableView *catagoriesTable;
@property (weak, nonatomic) IBOutlet UIButton *addCatagoryButton;

@property (weak, nonatomic) Catagory *currentlySelectedCatagory;
@property CGRect tinyRect; //the position the current currentlySelectedCatagory's table cell's center

@property (nonatomic, strong) WYPopoverController *floatBarPickerPopover;

@property (nonatomic, strong) ModifyCatagoryPopUpViewController *modifyCatagoryPopUpViewController;
@property (nonatomic, strong) DeleteCatagoryViewController *deleteCatagoryViewController;
@property (nonatomic, strong) TransferCatagoryViewController *transferCatagoryViewController;
@property (nonatomic, strong) ModifyCatagoryViewController *modifyCatagoryViewController;

@end

@implementation CatagoriesManagementViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.catagoriesTable.dataSource = self;
    self.catagoriesTable.delegate = self;
    
    self.modifyCatagoryPopUpViewController = [self.viewControllerFactory createModifyCatagoryPopUpViewController];
    self.floatBarPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.modifyCatagoryPopUpViewController];
    [self.modifyCatagoryPopUpViewController setDelegate:self];
    
    UINib *catagoriesManagementTableViewCell = [UINib nibWithNibName:@"CatagoriesManagementTableViewCell" bundle:nil];
    [self.catagoriesTable registerNib:catagoriesManagementTableViewCell forCellReuseIdentifier:@"CatagoriesManagementTableViewCell"];
    
    self.itemCatagories = [NSMutableArray new];
    self.RecordsDictionary = [NSMutableDictionary new];
    
    //quickly show and dismiss to get rid of a visual bug
    [self.floatBarPickerPopover presentPopoverFromRect:self.tinyRect inView:self.view permittedArrowDirections:WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown animated:NO];
    [self.floatBarPickerPopover dismissPopoverAnimated:NO];
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
    [self.dataService fetchCatagoriesSuccess:^(NSArray *catagories) {
            
            if (catagories && catagories.count)
            {
                [self.itemCatagories addObjectsFromArray:catagories];
            }
            
        } failure:^(NSString *reason) {
            //should not happen
        }];
    
    [self.RecordsDictionary removeAllObjects];
    
    //load catagoryRe cordsDictionary
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
    
    [self.catagoriesTable reloadData];
}

- (IBAction)addCatagoryPressed:(UIButton *)sender
{
    //open up the AddCatagoryViewController
    [self.navigationController pushViewController:[self.viewControllerFactory createAddCatagoryViewController] animated:YES];
}

#pragma mark - PopUpViewControllerProtocol
-(void)requestPopUpToDismiss
{
    [self refreshData];
    
    [self.floatBarPickerPopover dismissPopoverAnimated:YES];
}

#pragma mark - UITableview ModifyCatagoryPopUpDelegate

-(void)editButtonPressed
{
    DLog("Edit button pressed for catagory: %@", self.currentlySelectedCatagory.name);
    
    [self.floatBarPickerPopover dismissPopoverAnimated:NO];
    
    self.modifyCatagoryViewController = [self.viewControllerFactory createModifyCatagoryViewControllerWith:self.currentlySelectedCatagory];
    self.modifyCatagoryViewController.delegate = self;
    
    self.floatBarPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.modifyCatagoryViewController];
    
    [self.floatBarPickerPopover setPopoverContentSize:self.modifyCatagoryViewController.viewSize];
    
    [self.floatBarPickerPopover presentPopoverFromRect:self.tinyRect inView:self.view permittedArrowDirections:WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown animated:YES];
}

-(void)transferButtonPressed
{
    DLog("Transfer button pressed for catagory: %@", self.currentlySelectedCatagory.name);
    
    [self.floatBarPickerPopover dismissPopoverAnimated:NO];
    
    self.transferCatagoryViewController = [self.viewControllerFactory createTransferCatagoryViewController:self.currentlySelectedCatagory];
    self.transferCatagoryViewController.delegate = self;
    
    self.floatBarPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.transferCatagoryViewController];
    
    [self.floatBarPickerPopover setPopoverContentSize:self.transferCatagoryViewController.viewSize];
    
    [self.floatBarPickerPopover presentPopoverFromRect:self.tinyRect inView:self.view permittedArrowDirections:WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown animated:YES];
}

-(void)deleteButtonPressed
{
    DLog("Delete button pressed for catagory: %@", self.currentlySelectedCatagory.name);
    
    [self.floatBarPickerPopover dismissPopoverAnimated:NO];
    
    self.deleteCatagoryViewController = [self.viewControllerFactory createDeleteCatagoryViewController:self.currentlySelectedCatagory];
    self.deleteCatagoryViewController.delegate = self;
    
    self.floatBarPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.deleteCatagoryViewController];
    
    [self.floatBarPickerPopover setPopoverContentSize:self.deleteCatagoryViewController.viewSize];
    
    [self.floatBarPickerPopover presentPopoverFromRect:self.tinyRect inView:self.view permittedArrowDirections:WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown animated:YES];
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

- (CatagoriesManagementTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CatagoriesManagementTableViewCell";
    CatagoriesManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[CatagoriesManagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    Catagory *thisItemCatagory = [self.itemCatagories objectAtIndex:indexPath.row];
    
    NSArray *recordsForThisCatagory = [self.RecordsDictionary objectForKey:thisItemCatagory.identifer];
    
    NSInteger sumQuantity = 0;
    float sumAmount = 0.0;
    
    for (Record *record in recordsForThisCatagory)
    {
        sumQuantity = sumQuantity + record.quantity;
        sumAmount = sumAmount + [record calculateTotal];
    }
    
    [cell.colorView setBackgroundColor:thisItemCatagory.color];
    [cell.nameLabel setText:thisItemCatagory.name];
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
    Catagory *thisItemCatagory = [self.itemCatagories objectAtIndex:indexPath.row];
    
    if (!self.currentlySelectedCatagory || self.currentlySelectedCatagory != thisItemCatagory)
    {
        self.currentlySelectedCatagory = thisItemCatagory;
        
        DLog(@"Catagory %ld: %@ selected", (long)self.currentlySelectedCatagory.identifer, self.currentlySelectedCatagory.name );
    }
    
    CGRect rectOfCellInTableView = [tableView rectForRowAtIndexPath:indexPath];
    CGRect rectOfCellInSuperview = [tableView convertRect:rectOfCellInTableView toView:[tableView superview]];
    
    self.tinyRect = CGRectMake(rectOfCellInSuperview.origin.x + rectOfCellInSuperview.size.width / 2,
                               rectOfCellInSuperview.origin.y + rectOfCellInSuperview.size.height / 2, 1, 1);
    
    //check for modifyCatagoryPopUpViewController's buttons states
    if (self.itemCatagories.count > 1 && [self.RecordsDictionary objectForKey:thisItemCatagory.identifer] )
    {
        [self.modifyCatagoryPopUpViewController.transferButton setEnabled:YES];
    }
    else
    {
        [self.modifyCatagoryPopUpViewController.transferButton setEnabled:NO];
    }
    
    self.floatBarPickerPopover = [[WYPopoverController alloc] initWithContentViewController: self.modifyCatagoryPopUpViewController];
    
    [self.floatBarPickerPopover setPopoverContentSize:self.modifyCatagoryPopUpViewController.viewSize];
    
    [self.floatBarPickerPopover presentPopoverFromRect:self.tinyRect inView:self.view permittedArrowDirections:WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown animated:YES];
    
    [tableView reloadData];
}

@end
