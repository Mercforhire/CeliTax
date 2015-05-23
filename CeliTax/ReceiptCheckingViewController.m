//
//  ReceiptCheckingViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptCheckingViewController.h"
#import "HorizonalScrollBarView.h"
#import "ReceiptScrollBarView.h"
#import "AddCatagoryViewController.h"
#import "Catagory.h"
#import "User.h"
#import "UserManager.h"
#import "Record.h"
#import "ImageCounterIconView.h"
#import "AddCatagoryViewController.h"
#import "ViewControllerFactory.h"
#import "AlertDialogsProvider.h"
#include <QuartzCore/QuartzCore.h>

@interface ReceiptCheckingViewController () <ImageCounterIconViewProtocol, HorizonalScrollBarViewProtocol>

@property (weak, nonatomic) IBOutlet ReceiptScrollBarView *receiptScrollView;
@property (weak, nonatomic) IBOutlet UIView *bottombarContainer;
@property (strong, nonatomic) HorizonalScrollBarView *bottomBar;
@property (weak, nonatomic) IBOutlet ImageCounterIconView *recordsCounter;
@property (weak, nonatomic) IBOutlet UIButton *previousItemButton;
@property (weak, nonatomic) IBOutlet UIButton *nextItemButton;
@property (weak, nonatomic) IBOutlet UIButton *addItemButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteItemButton;
@property (weak, nonatomic) IBOutlet UITextField *qtyField;
@property (weak, nonatomic) IBOutlet UITextField *pricePerItemField;
@property (weak, nonatomic) IBOutlet UITextField *totalField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animatedBar;

@property (strong, nonatomic) NSMutableArray *receiptImages;
@property (strong, nonatomic) NSArray *catagories;
@property (strong, nonatomic) NSMutableArray *catagoryNames;
@property (strong, nonatomic) NSMutableArray *RecordsForThisReceipt;

@property (nonatomic, strong) Catagory *currentlySelectedCatagory;

@end

@implementation ReceiptCheckingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bottomBar = [[HorizonalScrollBarView alloc] initWithFrame:self.bottombarContainer.frame];
    self.bottomBar.delegate = self;
    [self.view addSubview:self.bottomBar];
    
    self.RecordsForThisReceipt = [NSMutableArray new];
    
    //load the receiptImages array with some demo images
    self.receiptImages = [NSMutableArray new];
    
    UIImage *receiptImage = [UIImage imageNamed:@"receipt.png"];
    [self.recordsCounter setImage:receiptImage];
    [self.recordsCounter setDelegate:self];
    
    UIImage *image1 = [UIImage imageNamed:@"ReceiptPic-1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"ReceiptPic-2.jpg"];
    
    [self.receiptImages addObject:image1];
    [self.receiptImages addObject:image2];
    
    [self.receiptScrollView setImages:self.receiptImages];
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.receiptScrollView.bounds;
    maskLayer.shadowRadius = 2.5f;
    maskLayer.shadowPath = CGPathCreateWithRoundedRect(CGRectInset(self.receiptScrollView.bounds, 8, 8), 10, 10, nil);
    maskLayer.shadowOpacity = 1;
    maskLayer.shadowOffset = CGSizeZero;
    maskLayer.shadowColor = [UIColor whiteColor].CGColor;
    
    self.receiptScrollView.layer.mask = maskLayer;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //load the receipt images for this receipt
    
    
    //load all the catagories
    [self.dataService fetchCatagoriesSuccess:^(NSArray *catagories) {
            
            self.catagories = catagories;
            
        } failure:^(NSString *reason) {
            //if no catagories
        }];
    
    self.catagoryNames = [NSMutableArray new];
    
    for (Catagory *itemCatagory in self.catagories)
    {
        [self.catagoryNames addObject:itemCatagory.name];
    }
    
    //load catagory records for this receipt
    [self.dataService fetchRecordsForReceiptID:self.receiptID
                                       success:^(NSArray *Record) {
                                           
                                           [self.RecordsForThisReceipt addObjectsFromArray:Record];
                                           
                                           [self.recordsCounter setCounter:self.RecordsForThisReceipt.count];
                                       } failure:^(NSString *reason) {
                                           //failure
                                       }];
    
    [self refreshButtonBar];
}

-(void)refreshButtonBar
{
    [self.bottomBar setButtonNames:self.catagoryNames];
}

- (IBAction)addCatagoryPressed:(UIButton *)sender
{
    //open up the AddCatagoryViewController
    [self.navigationController pushViewController:[self.viewControllerFactory createAddCatagoryViewController] animated:YES];
}

#pragma mark - ImageCounterIconViewProtocol

-(void)imageCounterIconClicked
{
    DLog(@"Image counter icon clicked");
    
    [AlertDialogsProvider showWorkInProgressDialog];
}

#pragma mark - HorizonalScrollBarViewProtocol

-(void)buttonClickedWithIndex:(NSInteger)index andName:(NSString *)name
{
    DLog(@"Bottom Bar button %ld:%@ pressed", (long)index, name);
    
    [AlertDialogsProvider showWorkInProgressDialog];
}

@end
