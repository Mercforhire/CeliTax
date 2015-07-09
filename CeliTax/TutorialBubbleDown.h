//
//  TutorialBubbleDown.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialBubbleProtocol.h"
#import "TutorialBubbleInterface.h"

@interface TutorialBubbleDown : UIView <TutorialBubbleInterface>

@property (nonatomic, weak) id <TutorialBubbleProtocol> delegate;

@property (weak, nonatomic) LookAndFeel *lookAndFeel;

@property (nonatomic) float xOriginOfArrow;

@property (nonatomic) float leftMarginOfBubble;

@property (nonatomic) float bubbleWidth;

@property (nonatomic) float bubbleHeight;

@property (nonatomic, strong) NSString *tutorialText;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

//Run this once after all properties have been set
-(void)setupUI;

@end
