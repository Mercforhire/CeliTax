//
//  TutorialBubbleUp.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialBubbleProtocol.h"
#import "TutorialBubbleInterface.h"
#import "HollowGreenButton.h"
#import "SolidGreenButton.h"

@interface TutorialBubbleUp : UIView <TutorialBubbleInterface>

@property (nonatomic, weak) id <TutorialBubbleProtocol> delegate;

@property (weak, nonatomic) LookAndFeel *lookAndFeel;

@property (nonatomic) float xOriginOfArrow;

@property (nonatomic) float leftMarginOfBubble;

@property (nonatomic) float bubbleWidth;

@property (nonatomic) float bubbleHeight;

@property (nonatomic, strong) NSString *tutorialText;

@property (weak, nonatomic) IBOutlet HollowGreenButton *skipButton;

@property (weak, nonatomic) IBOutlet SolidGreenButton *continueButton;

//Run this once after all properties have been set
-(void)setupUI;

@end
