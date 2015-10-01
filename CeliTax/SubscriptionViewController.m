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

#define kSubscriptionTableViewCellHeight                    45
#define kSubscriptionTableViewCellIdentifier                @"SubscriptionTableViewCell"

@interface SubscriptionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *subscriptionsTableView;
@property (strong, nonatomic) MBProgressHUD *waitView;

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
        [cell.textLabel setFont:[UIFont latoFontOfSize:18]];
    }
    
    cell.textLabel.text = NSLocalizedString(@"No subscriptions loaded", nil);
    
    if (self.products.count)
    {
        SKProduct *product = (SKProduct *)self.products[indexPath.row];
        cell.textLabel.text = product.localizedTitle;
        
        SolidGreenButton *buyButton = [[SolidGreenButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [buyButton setTitle:NSLocalizedString(@"Buy", nil) forState:UIControlStateNormal];
        [buyButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        [buyButton sizeToFit];
        [buyButton setTag:indexPath.row];
        [buyButton setLookAndFeel:self.lookAndFeel];
        
        cell.accessoryView = buyButton;
        [cell setAccessoryType: UITableViewCellAccessoryNone];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - UITableview Delegate
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return kSubscriptionTableViewCellHeight;
}

@end
