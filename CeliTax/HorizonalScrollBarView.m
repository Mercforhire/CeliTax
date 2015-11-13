//
// HorizonalScrollBarView.m
// CeliTax
//
// Created by Leon Chen on 2015-05-17.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "HorizonalScrollBarView.h"
#import "SelectionCollectionViewCell.h"
#import "YIInnerShadowView.h"
#import "CeliTax-Swift.h"

NSString *SelectionCollectionViewCellReuseIdentifier = @"SelectionCollectionViewCell";

@interface HorizonalScrollBarView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *buttonNames;
@property (nonatomic, strong) NSArray *buttonColors;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) NSInteger selectedButtonIndex;

@property (nonatomic, strong) UILongPressGestureRecognizer* longPress;

@end

@implementation HorizonalScrollBarView

- (void) baseInit
{
    self.selectedButtonIndex = -1;

    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionLayout.itemSize = CGSizeMake(87, 60);
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    CGRect frame = self.frame;

    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout: collectionLayout];
    (self.collectionView).backgroundColor = [UIColor clearColor];

    UINib *selectionCollectionViewCell = [UINib nibWithNibName: @"SelectionCollectionViewCell" bundle: nil];
    [self.collectionView registerNib: selectionCollectionViewCell forCellWithReuseIdentifier: SelectionCollectionViewCellReuseIdentifier];

    (self.collectionView).dataSource = self;
    (self.collectionView).delegate = self;
    [self.collectionView setBounces: NO];
    [self addSubview: self.collectionView];
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPress.minimumPressDuration = 0.5; //seconds
    self.longPress.delegate = self;
    [self.collectionView addGestureRecognizer:self.longPress];
    
    self.unselectable = YES;
}

- (instancetype) initWithFrame: (CGRect) frame;
{
    self = [super initWithFrame: frame];

    if (self)
    {
        [self baseInit];
    }

    return self;
}

- (instancetype) initWithCoder: (NSCoder *) aDecoder;
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

    (self.collectionView).contentSize = CGSizeMake(self.collectionView.contentSize.width + 10, self.collectionView.contentSize.height);

    [self.collectionView reloadData];
}

-(void)deselectAnyCategory
{
    if (self.unselectable)
    {
        self.selectedButtonIndex = -1;
        
        [self.collectionView reloadData];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (indexPath)
        {
            NSString *clickedName = (self.buttonNames)[indexPath.row];
            
            UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
            
            CGRect cellRect = attributes.frame;
            
            cellRect = [self.collectionView convertRect:cellRect toView:self];
            
            point.x = cellRect.origin.x + cellRect.size.width / 2;
            
            point.y = 0;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClickedWithIndex:andName:)])
            {
                [self.delegate buttonLongPressedWithIndex: indexPath.row andName: clickedName atPoint:point];
            }
        }
    }
}

-(void)simulateLongPressedOnFirstButton
{
    NSString *clickedName = (self.buttonNames)[0];
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGRect cellRect = attributes.frame;
    
    cellRect = [self.collectionView convertRect:cellRect toView:self];
    
    CGPoint point = CGPointMake(cellRect.origin.x + cellRect.size.width / 2, 0);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonLongPressedWithIndex:andName:atPoint:)])
    {
        [self.delegate buttonLongPressedWithIndex: 0 andName: clickedName atPoint:point];
    }
}

-(void)simulateNormalPressOnButton: (NSInteger) index
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

#pragma mark - From UICollectionView Delegate / Datasource

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.buttonNames.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: SelectionCollectionViewCellReuseIdentifier forIndexPath: indexPath];

    if ( !cell )
    {
        cell = [[SelectionCollectionViewCell alloc] initWithFrame: CGRectMake(0, 0, 87, 60)];
    }

    UIColor *cellColor = (self.buttonColors)[indexPath.row];

    (cell.selectionLabel).text = (self.buttonNames)[indexPath.row];

    if (indexPath.row == self.selectedButtonIndex)
    {
        (cell.shadowbackground).shadowMask = YIInnerShadowMaskAll;
        (cell.shadowbackground).backgroundColor = cellColor;
        (cell.selectionColorBox).backgroundColor = [UIColor whiteColor];
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.selectionColorBox];
        (cell.selectionLabel).textColor = [UIColor whiteColor];
    }
    else
    {
        (cell.shadowbackground).shadowMask = YIInnerShadowMaskNone;
        (cell.shadowbackground).backgroundColor = [UIColor whiteColor];
        (cell.selectionColorBox).backgroundColor = cellColor;
        [self.lookAndFeel applySlightlyDarkerBorderTo: cell.selectionColorBox];
        (cell.selectionLabel).textColor = [UIColor blackColor];
    }

    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.unselectable)
    {
        if (indexPath.row == self.selectedButtonIndex)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(buttonUnselected)])
            {
                [self.delegate buttonUnselected];
            }
            
            self.selectedButtonIndex = -1;
        }
        // deselect the previously selected and select the new one
        else
        {
            NSString *clickedName = (self.buttonNames)[indexPath.row];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClickedWithIndex:andName:)])
            {
                [self.delegate buttonClickedWithIndex: indexPath.row andName: clickedName];
            }
            
            self.selectedButtonIndex = indexPath.row;
        }
        
        [collectionView reloadData];
        
        [collectionView selectItemAtIndexPath:indexPath
                                     animated:YES
                               scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    else
    {
        if (indexPath.row == self.selectedButtonIndex)
        {
            //do nothing
        }
        // deselect the previously selected and select the new one
        else
        {
            NSString *clickedName = (self.buttonNames)[indexPath.row];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(buttonClickedWithIndex:andName:)])
            {
                [self.delegate buttonClickedWithIndex: indexPath.row andName: clickedName];
            }
            
            self.selectedButtonIndex = indexPath.row;
            
            [collectionView reloadData];
            
            [collectionView selectItemAtIndexPath:indexPath
                                         animated:YES
                                   scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }
}

@end