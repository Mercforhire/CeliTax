//
//  SubscriptionViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-09-27.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SubscriptionViewController.h"
#import "SubscriptionManager.h"
#import "SolidGreenButton.h"
#import "MBProgressHUD.h"
#import "UserManager.h"

#import "CeliTax-Swift.h"

#define kSubscriptionTableViewCellHeight                    45
#define kSubscriptionTableViewCellIdentifier                @"SubscriptionTableViewCell"

@interface SubscriptionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiryDateLabel;
@property (weak, nonatomic) IBOutlet UITableView *subscriptionsTableView;
@property (strong, nonatomic) MBProgressHUD *waitView;
@property (strong, nonatomic) MBProgressHUD *waitView2;

@property (strong, nonatomic) NSArray *products;

@end

@implementation SubscriptionViewController

- (void) setupUI
{
    [self.titleLabel setText:NSLocalizedString(@"Purchase Subscriptions", nil)];
    
    self.waitView = [[MBProgressHUD alloc] initWithView: self.view];
    self.waitView.labelText = NSLocalizedString(@"Please wait", nil);
    self.waitView.detailsLabelText = NSLocalizedString(@"Loading subscriptions...", nil);
    self.waitView.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview: self.waitView];
    
    self.waitView2 = [[MBProgressHUD alloc] initWithView: self.view];
    self.waitView2.labelText = NSLocalizedString(@"Please wait", nil);
    self.waitView2.detailsLabelText = NSLocalizedString(@"Purchasing subscription...", nil);
    self.waitView2.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview: self.waitView2];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    self.subscriptionsTableView.dataSource = self;
    self.subscriptionsTableView.delegate = self;
    
    //load Products
    [self.waitView show: YES];
    
    [self.subscriptionManager requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        
        [self.waitView hide: YES];
        
        if (success)
        {
            _products = products;
            [self.subscriptionsTableView reloadData];
        }
        else
        {
            NSString *errorMessage = NSLocalizedString(@"Can not connect to our server, please try again later", nil);
            
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: NSLocalizedString(@"Error", nil)
                                    message: errorMessage
                                    delegate: nil
                                    cancelButtonTitle: nil
                                    otherButtonTitles: @"Ok", nil];
            
            [message show];
        }
        
    }];
    
    [self refreshExpiryDateLabel];
}

-(void)refreshExpiryDateLabel
{
    if (self.userManager.subscriptionActive)
    {
        (self.expiryDateLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Expiry Date: %@", nil), self.userManager.user.subscriptionExpirationDate];
    }
    else
    {
        (self.expiryDateLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Expired on: %@", nil), self.userManager.user.subscriptionExpirationDate];
    }
}

-(void)buyPressed:(UIButton *)button
{
    if (self.products.count && button.tag < self.products.count)
    {
        SKProduct *product = (SKProduct *)self.products[button.tag];
        
        [self.waitView2 show: YES];
        
        [self.subscriptionManager buyProduct:product success:^{
            
            [self.waitView2 hide: YES];
            
            [self refreshExpiryDateLabel];
            
        } failure:^(NSInteger errorCode) {
            
            [self.waitView2 hide: YES];
            
            NSString *errorMessage = NSLocalizedString(@"Purchase failed.", nil);
            
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle: NSLocalizedString(@"Error", nil)
                                    message: errorMessage
                                    delegate: nil
                                    cancelButtonTitle: nil
                                    otherButtonTitles: @"Ok", nil];
            
            [message show];
            
        }];
    }
}

#pragma mark - UITableview DataSource

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    if (self.products.count)
    {
        return self.products.count;
    }
    
    return 1;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *cellId = kSubscriptionTableViewCellIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellId];
        (cell.textLabel).font = [UIFont latoFontOfSize:14];
    }
    
    if (self.products.count)
    {
        SKProduct *product = (SKProduct *)self.products[indexPath.row];
        
        cell.textLabel.text = product.localizedTitle;
        
        SolidGreenButton *buyButton = [[SolidGreenButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        
        [buyButton setTitle:NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
        [buyButton.titleLabel setFont:[UIFont latoFontOfSize:14]];
        buyButton.tag = indexPath.row;
        [buyButton setLookAndFeel:self.lookAndFeel];
        [buyButton sizeToFit];
        
        CGRect frame = buyButton.frame;
        frame.size.width += 10; //l + r padding
        [buyButton setFrame:frame];
        
        [buyButton addTarget: self
                      action: @selector(buyPressed:)
            forControlEvents: UIControlEventTouchUpInside];
        
        cell.accessoryView = buyButton;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.textLabel.text = NSLocalizedString(@"No subscriptions loaded", nil);
    }
    
    return cell;
}

#pragma mark - UITableview Delegate
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kSubscriptionTableViewCellHeight;
}

@end
