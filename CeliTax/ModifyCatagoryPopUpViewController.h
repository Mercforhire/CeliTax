//
//  ModifyCatagoryPopUpViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-12.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModifyCatagoryPopUpDelegate <NSObject>

-(void)editButtonPressed;

-(void)transferButtonPressed;

-(void)deleteButtonPressed;

@end

@interface ModifyCatagoryPopUpViewController : UIViewController

@property CGSize viewSize;

@property (nonatomic, weak) id <ModifyCatagoryPopUpDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end