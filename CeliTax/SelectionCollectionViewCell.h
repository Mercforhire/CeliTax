//
//  SelectionCollectionViewCell.h
//  CeliTax
//
//  Created by Leon Chen on 2015-06-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *selectionLabel;
@property (weak, nonatomic) IBOutlet UIView *selectionColorBox;

@end
