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
#import "User.h"
#import "AlertDialogsProvider.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet ProfileBarView *profileBarView;
@property (weak, nonatomic) IBOutlet UIButton *backupNowButton;
@property (weak, nonatomic) IBOutlet UILabel *lastBackUpLabel;

@end

@implementation SettingsViewController

- (void) setupUI
{
    [self.profileBarView setBackgroundColor:[UIColor clearColor]];
    
    // load user info
    [self.profileBarView.nameLabel setText: [NSString stringWithFormat: @"%@ %@", self.userManager.user.firstname, self.userManager.user.lastname]];
    
    self.profileBarView.profileImageView.layer.cornerRadius = self.profileBarView.profileImageView.frame.size.width / 2;
    self.profileBarView.profileImageView.layer.borderColor = [UIColor colorWithWhite: 187.0f/255.0f alpha: 1].CGColor;
    self.profileBarView.profileImageView.layer.borderWidth = 1.0f;
    [self.profileBarView.profileImageView setClipsToBounds: YES];
    [self.profileBarView.profileImageView setImage: self.userManager.user.avatarImage];
    
    [self.profileBarView.editButton1 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.profileBarView.editButton2 addTarget:self action:@selector(editProfilePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.lookAndFeel applySolidGreenButtonStyleTo:self.backupNowButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    NSDate *lastUploadDate = [self.syncService getLastBackUpDate];
    
    [self setLastBackUpLabelDate:lastUploadDate];
    
    if ([self.syncService needToBackUp])
    {
        [self.backupNowButton setEnabled:YES];
        [self.backupNowButton setTitle:@"Back Up Now" forState:UIControlStateNormal];
    }
    else
    {
        [self.backupNowButton setEnabled:NO];
        [self.backupNowButton setTitle:@"Up to Date" forState:UIControlStateNormal];
        [self.lookAndFeel applyDisabledButtonStyleTo:self.backupNowButton];
    }
}

-(void)setLastBackUpLabelDate:(NSDate *)date
{
    if (!date)
    {
        [self.lastBackUpLabel setText:[NSString stringWithFormat:@"Last Backup: Never"]];
        
        return;
    }
    
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStringFromUploadDate = [gmtDateFormatter stringFromDate:date];
    
    [self.lastBackUpLabel setText:[NSString stringWithFormat:@"Last Backup: %@", dateStringFromUploadDate]];
}

- (void) editProfilePressed: (UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
}

#define kKeyLastUpdatedDateTime        @"LastUpdatedDateTime"

- (IBAction)backupPressed:(UIButton *)sender
{
    [self.backupNowButton setEnabled:NO];
    [self.backupNowButton setTitle:@"Backing Up..." forState:UIControlStateNormal];
    
    [self.syncService startSyncingUserData:^(NSDictionary *lastestDataInfo) {
        //disable the Backup Now Button
        [self.backupNowButton setEnabled:NO];
        [self.backupNowButton setTitle:@"Backed Up" forState:UIControlStateNormal];
        [self.lookAndFeel applyDisabledButtonStyleTo:self.backupNowButton];
        
        NSDate *uploadDate = [lastestDataInfo objectForKey:kKeyLastUpdatedDateTime];
        
        [self setLastBackUpLabelDate:uploadDate];
        
    } failure:^(NSString *reason) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Back up failed, please try again later"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Dismiss",nil];
        
        [message show];
        
        [self.backupNowButton setEnabled:YES];
        [self.backupNowButton setTitle:@"Back Up Now" forState:UIControlStateNormal];
    }];
}

@end
