//
//  SettingsViewController.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProfileBarView.h"
#import "UserManager.h"
#import "AlertDialogsProvider.h"
#import "SolidGreenButton.h"
#import "SyncManager.h"
#import "ViewControllerFactory.h"
#import "ProfileSettingsViewController.h"
#import "TutorialManager.h"
#import "M13Checkbox.h"
#import "ConfigurationManager.h"
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
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet M13Checkbox *englishLanguageCheckBox;
@property (weak, nonatomic) IBOutlet M13Checkbox *frenchLanguageCheckBox;
@property (weak, nonatomic) IBOutlet M13Checkbox *spanishLanguageCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *metricUnitButton;
@property (weak, nonatomic) IBOutlet SolidGreenButton *imperialUnitButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *faqButton;
@property (weak, nonatomic) IBOutlet UILabel *subscriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *subscriptionStatusLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *purchaseButton;

@property (weak, nonatomic) IBOutlet SolidGreenButton *backupNowButton;
@property (weak, nonatomic) IBOutlet UILabel *lastBackUpLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *insertDemoButton;

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
    
    (self.englishLanguageCheckBox.titleLabel).font = [UIFont latoFontOfSize: 14];
    (self.englishLanguageCheckBox.titleLabel).textColor = [UIColor darkGrayColor];
    (self.englishLanguageCheckBox).strokeColor = [UIColor grayColor];
    (self.englishLanguageCheckBox).checkColor = [UIColor clearColor];
    (self.englishLanguageCheckBox).uncheckedColor = [UIColor clearColor];
    (self.englishLanguageCheckBox).tintColor = self.lookAndFeel.appGreenColor;
    (self.englishLanguageCheckBox).checkAlignment = M13CheckboxAlignmentLeft;
    
    (self.frenchLanguageCheckBox.titleLabel).font = [UIFont latoFontOfSize: 14];
    (self.frenchLanguageCheckBox.titleLabel).textColor = [UIColor darkGrayColor] ;
    (self.frenchLanguageCheckBox).strokeColor = [UIColor grayColor];
    (self.frenchLanguageCheckBox).checkColor = [UIColor clearColor];
    (self.frenchLanguageCheckBox).uncheckedColor = [UIColor clearColor];
    (self.frenchLanguageCheckBox).tintColor = self.lookAndFeel.appGreenColor;
    (self.frenchLanguageCheckBox).checkAlignment = M13CheckboxAlignmentLeft;
    
    (self.spanishLanguageCheckBox.titleLabel).font = [UIFont latoFontOfSize: 14];
    (self.spanishLanguageCheckBox.titleLabel).textColor = [UIColor darkGrayColor] ;
    (self.spanishLanguageCheckBox).strokeColor = [UIColor grayColor];
    (self.spanishLanguageCheckBox).checkColor = [UIColor clearColor];
    (self.spanishLanguageCheckBox).uncheckedColor = [UIColor clearColor];
    (self.spanishLanguageCheckBox).tintColor = self.lookAndFeel.appGreenColor;
    (self.spanishLanguageCheckBox).checkAlignment = M13CheckboxAlignmentLeft;
    
    [self.purchaseButton setLookAndFeel:self.lookAndFeel];
    [self.backupNowButton setLookAndFeel:self.lookAndFeel];
    [self.insertDemoButton setLookAndFeel:self.lookAndFeel];
    
    [self.metricUnitButton setLookAndFeel:self.lookAndFeel];
    [self.imperialUnitButton setLookAndFeel:self.lookAndFeel];
    
    [self refreshLanguage];
}

-(void)refreshLanguage
{
    [self.titleLabel setText:NSLocalizedString(@"Settings", nil)];
    
    [self.englishLanguageCheckBox.titleLabel setText: NSLocalizedString(@"English", nil)];
    [self.frenchLanguageCheckBox.titleLabel setText: NSLocalizedString(@"French", nil)];
    [self.spanishLanguageCheckBox.titleLabel setText: NSLocalizedString(@"Spanish", nil)];
    
    [self.profileSettingsButton setTitle:NSLocalizedString(@"Profile Settings", nil) forState:UIControlStateNormal];
    [self.loginSettingsButton setTitle:NSLocalizedString(@"Login Settings", nil) forState:UIControlStateNormal];
    [self.languageLabel setText:NSLocalizedString(@"Language:", nil)];
    
    [self.unitsLabel setText:NSLocalizedString(@"Units:", nil)];
    [self.metricUnitButton setTitle:NSLocalizedString(@"Metric", nil)
                           forState:UIControlStateNormal];
    
    [self.imperialUnitButton setTitle:NSLocalizedString(@"Imperial", nil)
                             forState:UIControlStateNormal];
    
    [self.aboutButton setTitle:NSLocalizedString(@"About", nil) forState:UIControlStateNormal];
    [self.faqButton setTitle:NSLocalizedString(@"FAQ", nil) forState:UIControlStateNormal];
    
    [self.subscriptionLabel setText:NSLocalizedString(@"Subscription:", nil)];
    [self.purchaseButton setTitle:NSLocalizedString(@"Purchase", nil) forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    [self.englishLanguageCheckBox addTarget: self
                                     action: @selector(languageCheckBoxChanged:)
                           forControlEvents: UIControlEventTouchUpInside];
    
    [self.frenchLanguageCheckBox addTarget: self
                                     action: @selector(languageCheckBoxChanged:)
                           forControlEvents: UIControlEventTouchUpInside];
    
    [self.spanishLanguageCheckBox addTarget: self
                                     action: @selector(languageCheckBoxChanged:)
                           forControlEvents: UIControlEventTouchUpInside];
    
    NSDate *lastUploadDate = [self.syncManager getLastBackUpDate];
    
    [self setLastBackUpLabelDate:lastUploadDate];
    
    //move to did appear
    if ([self.syncManager needToBackUp])
    {
        [self.backupNowButton setEnabled:YES];
        [self.backupNowButton setTitle:@"Sync" forState:UIControlStateNormal];
    }
    else
    {
        [self.backupNowButton setEnabled:NO];
        [self.backupNowButton setTitle:@"Up to Date" forState:UIControlStateNormal];
    }
    
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
    NSNumber *savedUnitSystem = [self.configurationManager getUnitSystem];
    
    if (!savedUnitSystem)
    {
        [self.configurationManager setUnitSystem:UnitSystemMetric];
    }
    
    [self setUnitSystemToType: [self.configurationManager getUnitSystem].integerValue];
}

-(void)setUnitSystemToType:(NSInteger)unitSystem
{
    switch (unitSystem)
    {
        case UnitSystemMetric:
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.metricUnitButton];
            [self.lookAndFeel applyDisabledButtonStyleTo:self.imperialUnitButton];
            
            [self.configurationManager setUnitSystem:UnitSystemMetric];
            break;
            
        case UnitSystemImperial:
            [self.lookAndFeel applyDisabledButtonStyleTo:self.metricUnitButton];
            [self.lookAndFeel applySolidGreenButtonStyleTo:self.imperialUnitButton];
            
            [self.configurationManager setUnitSystem:UnitSystemImperial];
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
            (self.englishLanguageCheckBox).checkState = M13CheckboxStateChecked;
            (self.frenchLanguageCheckBox).checkState = M13CheckboxStateUnchecked;
            (self.spanishLanguageCheckBox).checkState = M13CheckboxStateUnchecked;
            
            [[LocalizationManager sharedInstance] changeLanguage:@"en"];
            break;
            
        case LanguageFrench:
            (self.englishLanguageCheckBox).checkState = M13CheckboxStateUnchecked;
            (self.frenchLanguageCheckBox).checkState = M13CheckboxStateChecked;
            (self.spanishLanguageCheckBox).checkState = M13CheckboxStateUnchecked;
            
            [[LocalizationManager sharedInstance] changeLanguage:@"fr"];
            break;
            
        case LanguageSpanish:
            (self.englishLanguageCheckBox).checkState = M13CheckboxStateUnchecked;
            (self.frenchLanguageCheckBox).checkState = M13CheckboxStateUnchecked;
            (self.spanishLanguageCheckBox).checkState = M13CheckboxStateChecked;
            
            [[LocalizationManager sharedInstance] changeLanguage:@"es"];
            break;
            
        default:
            break;
    }
}

-(void)languageCheckBoxChanged:(M13Checkbox *)checkbox
{
    if (checkbox == self.englishLanguageCheckBox)
    {
        [self setLanguageTo:LanguageEnglish];
    }
    else if (checkbox == self.frenchLanguageCheckBox)
    {
        [self setLanguageTo:LanguageFrench];
    }
    else if (checkbox == self.spanishLanguageCheckBox)
    {
        [self setLanguageTo:LanguageSpanish];
    }
}

-(void)setLastBackUpLabelDate:(NSDate *)date
{
    if (!date)
    {
        (self.lastBackUpLabel).text = [NSString stringWithFormat:@"Never"];
        
        return;
    }
    
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStringFromUploadDate = [gmtDateFormatter stringFromDate:date];
    
    (self.lastBackUpLabel).text = [NSString stringWithFormat:@"%@", dateStringFromUploadDate];
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
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (IBAction)faqPressed:(UIButton *)sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

- (IBAction)purchasePressed:(SolidGreenButton *)sender
{
    [self.navigationController pushViewController: [self.viewControllerFactory createSubscriptionViewController] animated: YES];
}

- (IBAction)insertDemoDataPressed:(UIButton *)sender
{
    [self.insertDemoButton setEnabled:NO];
    [self.insertDemoButton setTitle:@"Generating..." forState:UIControlStateNormal];
    
    [self.syncService loadDemoData:^{
        
        [self.insertDemoButton setTitle:@"Demo Data Generated" forState:UIControlStateNormal];
        [self.insertDemoButton setEnabled:YES];
        
    }];
}

#define kKeyLastUpdatedDateTime        @"LastUpdatedDateTime"

- (IBAction)backupPressed:(UIButton *)sender
{
    [self.backupNowButton setEnabled:NO];
    [self.backupNowButton setTitle:@"Syncing..." forState:UIControlStateNormal];
    
    [self.syncManager startSync:^(NSDate *syncDate)
    {
        //disable the Backup Now Button
        [self.backupNowButton setEnabled:NO];
        [self.backupNowButton setTitle:@"Synced" forState:UIControlStateNormal];
        
        [self setLastBackUpLabelDate:syncDate];
        
    } failure:^(NSString *reason) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:reason
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss",nil];
        
        [alertView show];
        
        [self.backupNowButton setEnabled:YES];
        [self.backupNowButton setTitle:@"Sync" forState:UIControlStateNormal];
        
    }];
}

@end
