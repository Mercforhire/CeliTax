//
//  MainViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "MainViewController.h"
#import "Catagory.h"
#import "MainViewTableViewCell.h"
#import "UserManager.h"
#import "User.h"
#import "AddCatagoryViewController.h"
#import "ViewControllerFactory.h"
#import "AlertDialogsProvider.h"
#import "PieView.h"
#import "ReceiptCheckingViewController.h"
#import "CameraViewController.h"

#define kCatagoryTableRowHeight     70

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource> {
    RevealBlock _revealBlock;
    NSDateFormatter *dateFormatter;
}

@property (weak, nonatomic) IBOutlet UITableView *recentUploadsTable;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) NSArray *receiptInfos;
//of Dictionaries of keys: kReceiptIDKey,kColorKey,kCatagoryNameKey,kCatagoryTotalAmountKey

@end

@implementation MainViewController

-(id)initWithRevealBlock:(RevealBlock)revealBlock
{
    if (self = [super initWithNibName:@"MainViewController" bundle:nil])
    {
        _revealBlock = [revealBlock copy];
        
        //initialize the slider bar menu button
        UIButton* menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        menuButton.tintColor = [UIColor colorWithRed:7.0/255 green:61.0/255 blue:48.0/255 alpha:1.0f];
        [menuButton addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = menuItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.dataService loadDemoData];
    
    self.recentUploadsTable.dataSource = self;
    self.recentUploadsTable.delegate = self;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm 'on' MM-dd"];
    
    UINib *mainTableCell = [UINib nibWithNibName:@"MainViewTableViewCell" bundle:nil];
    [self.recentUploadsTable registerNib:mainTableCell forCellReuseIdentifier:@"MainTableCell"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //load the newest 10 receipts for user, sorted by date, calculate
    [self.dataService fetchNewestTenReceiptInfoSuccess:^(NSArray *receiptInfos) {
          
          self.receiptInfos = receiptInfos;
          [self.recentUploadsTable reloadData];
          
    } failure:^(NSString *reason) {
        //should not happen
    }];
}

- (IBAction)addCatagoryPressed:(UIButton *)sender
{
    //open up the AddCatagoryViewController
    [self.navigationController pushViewController:[self.viewControllerFactory createAddCatagoryViewController] animated:YES];
}

//slide out the slider bar
- (void)revealSidebar
{
    _revealBlock();
}

- (IBAction)cameraButtonPressed:(UIButton *)sender
{
    [self.navigationController pushViewController:[self.viewControllerFactory createCameraOverlayViewController] animated:YES];
}

#pragma mark - UITableview DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.receiptInfos.count;
}

- (MainViewTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MainTableCell";
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[MainViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *uploadInfoDictionary = self.receiptInfos[indexPath.row];
    
    cell.colorBox.colors = [uploadInfoDictionary objectForKey:kColorsKey];
    
    NSDate *uploadDate = [uploadInfoDictionary objectForKey:kUploadTimeKey];
    
    [cell.timeUploadedLabel setText:[dateFormatter stringFromDate: uploadDate]];
    
    float totalAmount = [[uploadInfoDictionary objectForKey:kTotalAmountKey] floatValue];
    
    [cell.totalRecordedLabel setText:[NSString stringWithFormat:@"Total: $%.2f", totalAmount]];
    
    return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCatagoryTableRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *uploadInfoDictionary = self.receiptInfos[indexPath.row];
    
    DLog(@"Receipt ID %@ clicked", [uploadInfoDictionary objectForKey:kReceiptIDKey]);
    
    NSInteger clickedReceiptID = [[uploadInfoDictionary objectForKey:kReceiptIDKey] integerValue];
    
    [self.navigationController pushViewController:[self.viewControllerFactory createReceiptCheckingViewControllerForReceiptID:clickedReceiptID] animated:YES];
}

#pragma mark - CameraManager

-(void)receivedImageFromCamera:(UIImage *)newImage
{
    DLog(@"Image received from camera");
}

@end
