//
//  ProfileBarView.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-18.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LookAndFeel, SolidGreenButton;

@interface ProfileBarView : UIView

- (void) setLookAndFeel: (LookAndFeel *) lookAndFeel;

- (void) setEditButtonsVisible:(BOOL)visible;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet SolidGreenButton *editButton1;
@property (weak, nonatomic) IBOutlet UIButton *editButton2;


@end
