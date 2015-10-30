//
// LeftSideMenuView.m
// CeliTax
//
// Created by Leon Chen on 2015-05-28.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SideMenuView.h"
#import "MenuSelectionTableViewCell.h"

@interface SideMenuView () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *menuSelections; // of NSString
    UITableView *menuSelectionsTable;
}

@end

@implementation SideMenuView

-(void)refreshMenuSelections
{
    menuSelections = @[NSLocalizedString(@"Home", nil),
                      NSLocalizedString(@"Account", nil),
                      NSLocalizedString(@"Vault", nil),
                      NSLocalizedString(@"Help", nil),
                      NSLocalizedString(@"Settings", nil),
                      NSLocalizedString(@"Logout", nil)];
    
    [menuSelectionsTable reloadData];
}

- (void) baseInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;

    self.profileImageView = [[UIImageView alloc] initWithFrame: CGRectMake(20, 20, 50, 50)];
    (self.profileImageView).backgroundColor = [UIColor greenColor];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileImageView.layer.borderWidth = 1.0f;
    [self.profileImageView setClipsToBounds: YES];
    [self.profileImageView setUserInteractionEnabled:YES];

    [self addSubview: self.profileImageView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.profileImageView.frame.origin.x + self.profileImageView.frame.size.width + 15,
                                                               self.profileImageView.frame.origin.y,
                                                               self.frame.size.width - self.profileImageView.frame.origin.x - self.profileImageView.frame.size.width - 15 - 15,
                                                               50)];
    (self.usernameLabel).font = [UIFont latoFontOfSize: 14];
    [self.usernameLabel setUserInteractionEnabled:YES];
    [self addSubview: self.usernameLabel];

    menuSelectionsTable = [[UITableView alloc] initWithFrame:
                           CGRectMake(0,
                                      self.profileImageView.frame.origin.y + self.profileImageView.frame.size.height + 28,
                                      self.frame.size.width,
                                      self.frame.size.height - self.profileImageView.frame.origin.y - self.profileImageView.frame.size.height - 28)];
    menuSelectionsTable.delegate = self;
    menuSelectionsTable.dataSource = self;
    [menuSelectionsTable setAllowsSelection: YES];
    menuSelectionsTable.backgroundColor = [UIColor clearColor];
    menuSelectionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [menuSelectionsTable setBounces:NO];

    UINib *tablecell = [UINib nibWithNibName: @"MenuSelectionTableViewCell" bundle: nil];

    [menuSelectionsTable registerNib: tablecell forCellReuseIdentifier: @"MenuCell"];

    [self addSubview: menuSelectionsTable];
    
    [self refreshMenuSelections];
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    (self.profileImageView).frame = CGRectMake(20, 20, 50, 50);

    (self.usernameLabel).frame = CGRectMake(self.profileImageView.frame.origin.x + self.profileImageView.frame.size.width + 10,
                                        self.profileImageView.frame.origin.y,
                                        self.frame.size.width - self.profileImageView.frame.origin.x - self.profileImageView.frame.size.width - 10 - 20,
                                        50);

    menuSelectionsTable.frame = CGRectMake(0,
                                              self.profileImageView.frame.origin.y + self.profileImageView.frame.size.height,
                                              self.frame.size.width,
                                              self.frame.size.height - self.profileImageView.frame.origin.y - self.profileImageView.frame.size.height);
}

- (instancetype) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (instancetype) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (instancetype) init
{
    self = [super init];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (void)didMoveToWindow
{
    if (self.window)
    {
        // Added to a window, similar to -viewDidLoad.
        
        [self refreshMenuSelections];
    }
}

- (void) setProfileImage: (UIImage *) profileImage
{
    _profileImage = profileImage;

    (self.profileImageView).image = _profileImage;
}

- (void) setUserName: (NSString *) userName
{
    _userName = userName;

    (self.usernameLabel).text = _userName;
}

- (void) setCurrentlySelectedIndex: (NSInteger) currentlySelectedIndex
{
    _currentlySelectedIndex = currentlySelectedIndex;

    [menuSelectionsTable reloadData];
}

#pragma mark - UITableview DataSource and Delegate

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 56;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return menuSelections.count;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString *menuCellReuseIdentifier = @"MenuCell";

    MenuSelectionTableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier: menuCellReuseIdentifier];

    if (!menuCell)
    {
        menuCell = [[MenuSelectionTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: menuCellReuseIdentifier];
    }

    if (indexPath.row == self.currentlySelectedIndex)
    {
        [menuCell.selectionIndicator setHidden: NO];
    }
    else
    {
        [menuCell.selectionIndicator setHidden: YES];
    }

    (menuCell.selectionName).text = menuSelections[indexPath.row];

    menuCell.backgroundColor = [UIColor clearColor];

    return menuCell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.delegate)
    {
        [self.delegate selectedMenuIndex: indexPath.row];
    }

    self.currentlySelectedIndex = indexPath.row;
}

// make table seperator line full width
- (void) tableView: (UITableView *) tableView willDisplayCell: (UITableViewCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath
{
    if ([cell respondsToSelector: @selector(setSeparatorInset:)])
    {
        cell.separatorInset = UIEdgeInsetsZero;
    }

    if ([cell respondsToSelector: @selector(setLayoutMargins:)])
    {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void) viewDidLayoutSubviews
{
    if ([menuSelectionsTable respondsToSelector: @selector(setSeparatorInset:)])
    {
        menuSelectionsTable.separatorInset = UIEdgeInsetsZero;
    }

    if ([menuSelectionsTable respondsToSelector: @selector(setLayoutMargins:)])
    {
        menuSelectionsTable.layoutMargins = UIEdgeInsetsZero;
    }
}

@end