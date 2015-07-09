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

-(void)setCurrentTutorialStageForViewControllerNamed:(NSString *)viewControllerName forStage:(NSInteger)stage;

-(NSInteger)getCurrentTutorialStageForViewControllerNamed:(NSString *)viewControllerName;

@end
