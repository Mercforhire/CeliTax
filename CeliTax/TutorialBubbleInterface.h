//
//  TutorialBubbleInterface.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-08.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LookAndFeel;

#define TOP_BUBBLE_MARGIN       13
#define BOTTOM_BUBBLE_MARGIN    60

@protocol TutorialBubbleInterface <NSObject>

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
