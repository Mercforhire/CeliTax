//
//  SettingsViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfileBarView.h"
#import "SolidGreenButton.h"
#import "ViewControllerFactory.h"
#import "ProfileSettingsViewController.h"
#import "M13Checkbox.h"
#import "LoginSettingsViewController.h"
#import "SubscriptionViewController.h"

#import "CeliTax-Swift.h"

typedef NS_ENUM(NSUInteger, Languages) {
    LanguageEnglish,
    LanguageFrench,
    LanguageSpanish
};

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet ProfileBarView *profileBarView;
@property (weak, nonatomic) IBOutlet UIButton *profileSettingsButton;
@property (weak, nonatomic) IBOutlet UIButton *loginSettingsButton;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *metricUnitButton;
@property (weak, nonatomic) IBOutlet SolidGreenButton *imperialUnitButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UILabel *subscriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscriptionStatusLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *purchaseButton;

@end

@implementation SettingsViewController

- (void) setupUI
{
    (self.profileBarView).backgroundColor = [UIColor clearColor];
    
    self.profileBarView.profileImageView.layer.cornerRadius = self.profileBarView.profileImageView.frame.size.width / 2;
    self.profileBarView.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileBarView.profileImageView.layer.borderWidth = 1.0f;
    [self.profileBarView.profileImageView setClipsToBounds: YES];
    [self.profileBarView setLookAndFeel:self.lookAndFeel];
    [self.profileBarView setEditButtonsVisible:NO];
    
    UITapGestureRecognizer *profileImageViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(profileSettingsPressed:)];
    [self.profileBarView.profileImageView addGestureRecognizer: profileImageViewTap];
    
    UITapGestureRecognizer *profileImageViewTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(profileSettingsPressed:)];
    [self.profileBarView.nameLabel addGestureRecognizer: profileImageViewTap2];
    
    [self.purchaseButton setLookAndFeel:self.lookAndFeel];
    
    [self.metricUnitButton setLookAndFeel:self.lookAndFeel];
    [self.imperialUnitButton setLookAndFeel:self.lookAndFeel];
    
    [self refreshLanguage];
}

-(void)refreshLanguage
{
    [self.titleLabel setText:NSLocalizedString(@"Settings", nil)];
    
    [self.profileSettingsButton setTitle:NSLocalizedString(@"Profile Settings", nil) forState:UIControlStateNormal];
    [self.loginSettingsButton setTitle:NSLocalizedString(@"Login Settings", nil) forState:UIControlStateNormal];
    
    [self.unitsLabel setText:NSLocalizedString(@"Units:", nil)];
    [self.metricUnitButton setTitle:NSLocalizedString(@"Metric", nil)
                           forState:UIControlStateNormal];
    
    [self.imperialUnitButton setTitle:NSLocalizedString(@"Imperial", nil)
                             forState:UIControlStateNormal];
    
    [self.aboutButton setTitle:NSLocalizedString(@"About", nil) forState:UIControlStateNormal];
    
    [self.subscriptionLabel setText:NSLocalizedString(@"Subscription:", nil)];
    [self.purchaseButton setTitle:NSLocalizedString(@"Purchase", nil) forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    [self selectUnitSystem];
    
    Language *currentLanguage = [LocalizationManager sharedInstance].currentLanguage;
    
    if (!currentLanguage)
    {
        [self setLanguageTo:LanguageEnglish];
    }
    if ([currentLanguage.code isEqualToString: @"en"])
    {
        [self setLanguageTo:LanguageEnglish];
    }
    else if ([currentLanguage.code isEqualToString: @"fr"])
    {
        [self setLanguageTo:LanguageFrench];
    }
    else if ([currentLanguage.code isEqualToString: @"es"])
    {
        [self setLanguageTo:LanguageSpanish];
    }
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // load user info
    (self.profileBarView.nameLabel).text = [NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname];
    
    (self.profileBarView.profileImageView).image = self.userManager.user.avatarImage;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshLanguage)
                                                 name: Notifications.kAppLanguageChangedNotification
                                               object: nil];
    
    if (self.userManager.subscriptionActive)
    {
        (self.subscriptionStatusLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Expiry Date: %@", nil), self.userManager.user.subscriptionExpirationDate];
    }
    else
    {
        (self.subscriptionStatusLabel).text = [NSString stringWithFormat:NSLocalizedString(@"Expired on: %@", nil), self.userManager.user.subscriptionExpirationDate];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: Notifications.kAppLanguageChangedNotification
                                                  object: nil];
}

-(void)selectUnitSystem
{
    UnitSystem savedUnitSystem = [self.configurationManager fetchUnitType];
    
    if (!savedUnitSystem)
    {
        [self.configurationManager setUnitType: UnitSystemMetric];
    }
    
    [self setUnitSystemToType: [self.configurationManager fetchUnitType]];
}

-(void)setUnitSystemToType:(NSInteger)unitSystem
{
    switch (unitSystem)
    {
        case UnitSystemMetric:
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.metricUnitButton];
            [self.lookAndFeel applyDisabledButtonStyleTo:self.imperialUnitButton];
            
            [self.configurationManager setUnitType:UnitSystemMetric];
            break;
            
        case UnitSystemImperial:
            [self.lookAndFeel applyDisabledButtonStyleTo:self.metricUnitButton];
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.imperialUnitButton];
            
            [self.configurationManager setUnitType:UnitSystemImperial];
            break;
            
        default:
            break;
    }
    
    [self.lookAndFeel applySlightlyDarkerBorderTo:self.metricUnitButton];
    [self.lookAndFeel applySlightlyDarkerBorderTo:self.imperialUnitButton];
}

-(void)setLanguageTo:(NSInteger)language
{
    switch (language)
    {
        case LanguageEnglish:
            [[LocalizationManager sharedInstance] changeLanguage:@"en"];
            break;
            
        case LanguageFrench:
            [[LocalizationManager sharedInstance] changeLanguage:@"fr"];
            break;
            
        case LanguageSpanish:
            [[LocalizationManager sharedInstance] changeLanguage:@"es"];
            break;
            
        default:
            break;
    }
}

- (IBAction)profileSettingsPressed:(id)sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createProfileSettingsViewController] animated: YES];
}

- (IBAction)loginSettingsPressed:(UIButton *)sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createLoginSettingsViewController] animated: YES];
}

- (IBAction)metricPressed:(SolidGreenButton *)sender
{
    [self setUnitSystemToType:UnitSystemMetric];
}

- (IBAction)imperialPressed:(SolidGreenButton *)sender
{
    [self setUnitSystemToType:UnitSystemImperial];
}

- (IBAction)aboutPressed:(UIButton *)sender
{
    [Utils OpenLink:@"http://celitax.ca/about.html"];
}

- (IBAction)purchasePressed:(SolidGreenButton *)sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createSubscriptionViewController] animated: YES];
}

@end
