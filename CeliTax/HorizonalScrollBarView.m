//
// HorizonalScrollBarView.m
// CeliTax
//
// Created by Leon Chen on 2015-05-17.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HorizonalScrollBarView.h"
#import "SelectionCollectionViewCell.h"

NSString *SelectionCollectionViewCellReuseIdentifier = @"SelectionCollectionViewCell";

@interface HorizonalScrollBarView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *buttonNames;
@property (nonatomic, strong) NSArray *buttonColors;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) NSInteger selectedButtonIndex;
@end

@implementation HorizonalScrollBarView

- (void) baseInit
{
    self.selectedButtonIndex = -1;

    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionLayout setItemSize: CGSizeMake(87, 60)];
    [collectionLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];

    CGRect frame = self.frame;

    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout: collectionLayout];
    [self.collectionView setBackgroundColor: [UIColor clearColor]];

    UINib *selectionCollectionViewCell = [UINib nibWithNibName: @"SelectionCollectionViewCell" bundle: nil];
    [self.collectionView registerNib: selectionCollectionViewCell forCellWithReuseIdentifier: SelectionCollectionViewCellReuseIdentifier];

    [self.collectionView setDataSource: self];
    [self.collectionView setDelegate: self];
    [self.collectionView setBounces: NO];
    [self addSubview: self.collectionView];
}

- (id) initWithFrame: (CGRect) frame;
{
    self = [super initWithFrame: frame];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (id) initWithCoder: (NSCoder *) aDecoder;
{
    self = [super initWithCoder: aDecoder];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (void) setButtonNames: (NSArray *) buttonNames andColors: (NSArray *) buttonColors
{
    self.buttonNames = buttonNames;
    self.buttonColors = buttonColors;

    [self.collectionView setContentSize: CGSizeMake(self.collectionView.contentSize.width + 10, self.collectionView.contentSize.height)];

    [self.collectionView reloadData];
}

-(void)deselectAnyCategory
{
    self.selectedButtonIndex = -1;
    
    [self.collectionView reloadData];
}

#pragma mark - From UICollectionView Delegate/Datasource

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.buttonNames.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: SelectionCollectionViewCellReuseIdentifier forIndexPath: indexPath];

    if (!cell)
    {
        cell = [[SelectionCollectionViewCell alloc] initWithFrame: CGRectMake(0, 0, 87, 60)];
    }

    UIColor *cellColor = [self.buttonColors objectAtIndex: indexPath.row];

    [cell.selectionColorBox setBackgroundColor: cellColor];
    [self.lookAndFeel applyGrayBorderTo: cell.selectionColorBox];

    [cell.selectionLabel setText: [self.buttonNames objectAtIndex: indexPath.row]];

    if (indexPath.row == self.selectedButtonIndex)
    {
        [self.lookAndFeel applyGreenBorderTo: cell.contentView];
    }
    else
    {
        cell.contentView.layer.borderWidth = 0;
    }

    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == self.selectedButtonIndex)
    {
        if (self.delegate)
        {
            [self.delegate buttonUnselected];
        }

        self.selectedButtonIndex = -1;
    }
    // deselect the previously selected and select the new one
    else
    {
        NSString *clickedName = [self.buttonNames objectAtIndex: indexPath.row];

        if (self.delegate)
        {
            [self.delegate buttonClickedWithIndex: indexPath.row andName: clickedName];
        }

        self.selectedButtonIndex = indexPath.row;
    }
    
    [collectionView reloadData];
    
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

@end