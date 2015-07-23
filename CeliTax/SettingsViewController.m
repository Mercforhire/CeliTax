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
#import "SolidGreenButton.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet ProfileBarView *profileBarView;
@property (weak, nonatomic) IBOutlet SolidGreenButton *backupNowButton;
@property (weak, nonatomic) IBOutlet UILabel *lastBackUpLabel;
@property (weak, nonatomic) IBOutlet SolidGreenButton *insertDemoButton;

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
    
    [self.backupNowButton setLookAndFeel:self.lookAndFeel];
    [self.insertDemoButton setLookAndFeel:self.lookAndFeel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    NSDate *lastUploadDate = [self.syncService getLastBackUpDate];
    
    [self setLastBackUpLabelDate:lastUploadDate];
    
    //move to did appear
    
    if ([self.syncService needToBackUp])
    {
        [self.backupNowButton setEnabled:YES];
        [self.backupNowButton setTitle:@"Sync" forState:UIControlStateNormal];
    }
    else
    {
        [self.backupNowButton setEnabled:NO];
        [self.backupNowButton setTitle:@"Up to Date" forState:UIControlStateNormal];
    }
}

-(void)setLastBackUpLabelDate:(NSDate *)date
{
    if (!date)
    {
        [self.lastBackUpLabel setText:[NSString stringWithFormat:@"Last Sync: Never"]];
        
        return;
    }
    
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStringFromUploadDate = [gmtDateFormatter stringFromDate:date];
    
    [self.lastBackUpLabel setText:[NSString stringWithFormat:@"Last Sync: %@", dateStringFromUploadDate]];
}

- (void) editProfilePressed: (UIButton *) sender
{
    [AlertDialogsProvider showWorkInProgressDialog];
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
    
    //1. Download and merge data from server first
    [self.syncService downloadUserData:^{
        
        //2.Upload local data to server
        [self.syncService startSyncingUserData:^(NSDate *updateDate) {
            
            //disable the Backup Now Button
            [self.backupNowButton setEnabled:NO];
            [self.backupNowButton setTitle:@"Synced" forState:UIControlStateNormal];
            
            [self setLastBackUpLabelDate:updateDate];
            
        } failure:^(NSString *reason) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:reason
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"Dismiss",nil];
            
            [message show];
            
            [self.backupNowButton setEnabled:YES];
            [self.backupNowButton setTitle:@"Sync" forState:UIControlStateNormal];
        }];
        
    } failure:^(NSString *reason) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:reason
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Dismiss",nil];
        
        [message show];
        
        [self.backupNowButton setEnabled:YES];
        [self.backupNowButton setTitle:@"Sync" forState:UIControlStateNormal];
    }];
}

@end
