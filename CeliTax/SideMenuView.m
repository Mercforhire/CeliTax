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
    UIImageView *profileImageView;
    UILabel *usernameLabel;

    UITableView *menuSelectionsTable;
}

@end

@implementation SideMenuView

- (void) baseInit
{
    [self setBackgroundColor: [UIColor clearColor]];
    self.opaque = NO;

    profileImageView = [[UIImageView alloc] initWithFrame: CGRectMake(20, 20, 50, 50)];
    [profileImageView setBackgroundColor: [UIColor greenColor]];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    profileImageView.layer.borderWidth = 1.0f;
    [profileImageView setClipsToBounds: YES];

    [self addSubview: profileImageView];

    usernameLabel = [[UILabel alloc] initWithFrame: CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 15,
                                                               profileImageView.frame.origin.y,
                                                               self.frame.size.width - profileImageView.frame.origin.x - profileImageView.frame.size.width - 15 - 15,
                                                               50)];
    [usernameLabel setFont: [UIFont latoFontOfSize: 14]];
    [self addSubview: usernameLabel];

    menuSelectionsTable = [[UITableView alloc] initWithFrame:
                           CGRectMake(0,
                                      profileImageView.frame.origin.y + profileImageView.frame.size.height + 28,
                                      self.frame.size.width,
                                      self.frame.size.height - profileImageView.frame.origin.y - profileImageView.frame.size.height - 28)];
    menuSelectionsTable.delegate = self;
    menuSelectionsTable.dataSource = self;
    [menuSelectionsTable setAllowsSelection: YES];
    menuSelectionsTable.backgroundColor = [UIColor clearColor];
    [menuSelectionsTable setSeparatorStyle: UITableViewCellSeparatorStyleNone];

    UINib *tablecell = [UINib nibWithNibName: @"MenuSelectionTableViewCell" bundle: nil];

    [menuSelectionsTable registerNib: tablecell forCellReuseIdentifier: @"MenuCell"];

    [self addSubview: menuSelectionsTable];
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    [profileImageView setFrame: CGRectMake(20, 20, 50, 50)];

    [usernameLabel setFrame: CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 10,
                                        profileImageView.frame.origin.y,
                                        self.frame.size.width - profileImageView.frame.origin.x - profileImageView.frame.size.width - 10 - 20,
                                        50)];

    [menuSelectionsTable setFrame: CGRectMake(0,
                                              profileImageView.frame.origin.y + profileImageView.frame.size.height,
                                              self.frame.size.width,
                                              self.frame.size.height - profileImageView.frame.origin.y - profileImageView.frame.size.height)];
}

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (id) init
{
    self = [super init];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (void) setProfileImage: (UIImage *) profileImage
{
    _profileImage = profileImage;

    [profileImageView setImage: _profileImage];
}

- (void) setUserName: (NSString *) userName
{
    _userName = userName;

    [usernameLabel setText: _userName];
}

- (void) setMenuSelections: (NSArray *) menuSelections
{
    _menuSelections = menuSelections;

    [menuSelectionsTable reloadData];
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
    return self.menuSelections.count;
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

    [menuCell.selectionName setText: [self.menuSelections objectAtIndex: indexPath.row]];

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
        [cell setSeparatorInset: UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector: @selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins: UIEdgeInsetsZero];
    }
}

- (void) viewDidLayoutSubviews
{
    if ([menuSelectionsTable respondsToSelector: @selector(setSeparatorInset:)])
    {
        [menuSelectionsTable setSeparatorInset: UIEdgeInsetsZero];
    }

    if ([menuSelectionsTable respondsToSelector: @selector(setLayoutMargins:)])
    {
        [menuSelectionsTable setLayoutMargins: UIEdgeInsetsZero];
    }
}

@end