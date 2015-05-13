//
//  SidebarController.m
//  ADVFlatUI
//
//  Created by Tope on 05/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "SidebarViewController.h"
#import "SidebarCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GHRevealViewController.h"

@interface SidebarViewController ()

@property (nonatomic, strong) GHRevealViewController *sidebarVC;
@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) NSArray *cellInfos;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SidebarViewController

-(id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC withControllers:(NSArray *)controllers withCellInfos:(NSArray *)cellInfos
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
		self.sidebarVC = sidebarVC;
		self.controllers = controllers;
		self.cellInfos = cellInfos;
		
		self.sidebarVC.sidebarViewController = self;
		self.sidebarVC.contentViewController = controllers[0][0];
	}
	return self;
}

-(void)loadView
{
    [super loadView];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height - 110)];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.view.frame = CGRectMake(0.0f, 0.0f,kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
}


#pragma mark - UITableView Delegate/Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cellInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return ((NSArray *)self.cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"SidebarCell";
    
    SideBarCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( !cell )
    {
        cell = [[SideBarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary* item = self.cellInfos[indexPath.section][indexPath.row];
    
    cell.titleLabel.text = item[@"title"];
    cell.iconImageView.image = [UIImage imageNamed:item[@"icon"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5 && indexPath.section == 1)
    {
        //log off
        DLog(@"Log off requested");
    }
    else {
        self.sidebarVC.contentViewController = self.controllers[indexPath.section][indexPath.row];
        [self.sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
    }
}

//make table seperator line full width
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
