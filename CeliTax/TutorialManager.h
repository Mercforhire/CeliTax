//
//  TutorialManager.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-03.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewControllerFactory, LookAndFeel;

@interface TutorialManager : NSObject

- (instancetype) initWithViewControllerFactory: (ViewControllerFactory *)factory
                                andLookAndFeel: (LookAndFeel *)lookAndFeel;

-(void)startTutorialInViewController: (UIViewController *) viewController andTutorials:(NSArray *)tutorials;

-(void)setCurrentTutorialStageForViewController:(UIViewController *)viewController forStage:(NSInteger)stage;

-(void)setTutorialDoneForViewController:(UIViewController *)viewController;

-(NSInteger)getCurrentTutorialStageForViewController:(UIViewController *)viewController;

-(BOOL)areAllTutorialsShown;

-(void)resetTutorialStages;

@end
