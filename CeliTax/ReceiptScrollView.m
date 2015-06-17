//
// ReceiptScrollView.m
// CeliTax
//
// Created by Leon Chen on 2015-06-13.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptScrollView.h"
#import "ReceiptCollectionViewCell.h"

NSString *ReceiptCollectionViewCellIdentifier = @"ReceiptCollectionViewCell";

@interface ReceiptScrollView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ReceiptScrollView

- (void) baseInit
{
    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionLayout setScrollDirection: UICollectionViewScrollDirectionVertical];

    CGRect frame = self.frame;

    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout: collectionLayout];
    [self.collectionView setBackgroundColor: [UIColor clearColor]];

    UINib *receiptCollectionViewCell = [UINib nibWithNibName: @"ReceiptCollectionViewCell" bundle: nil];
    [self.collectionView registerNib: receiptCollectionViewCell forCellWithReuseIdentifier: ReceiptCollectionViewCellIdentifier];

    [self.collectionView setDataSource: self];
    [self.collectionView setDelegate: self];
    [self.collectionView setBounces: YES];
    [self addSubview: self.collectionView];

    self.selectedImageIndices = [NSMutableDictionary new];
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

- (void) setImages: (NSArray *) images
{
    _images= images;

    [self.collectionView reloadData];
}

- (void) receiptChecked: (M13Checkbox *) checkBox
{
    DLog(@"Select All checkbox Value changed to %ld", (long)checkBox.checkState);

    NSNumber *thisIndex = [NSNumber numberWithInteger: checkBox.tag];

    if (checkBox.checkState == M13CheckboxStateChecked)
    {
        [self.selectedImageIndices setObject: @"GARBAGE" forKey: thisIndex];
    }
    else
    {
        [self.selectedImageIndices removeObjectForKey: thisIndex];
    }

    if (self.delegate)
    {
        [self.delegate selectedChanged];
    }
}

#pragma mark - From UICollectionView Delegate/Datasource

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.images.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    ReceiptCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: ReceiptCollectionViewCellIdentifier forIndexPath: indexPath];

    if (!cell)
    {
        cell = [[ReceiptCollectionViewCell alloc] initWithFrame: CGRectMake(0, 0, 87, 60)];
    }

    [cell.image setImage: [self.images objectAtIndex: indexPath.row]];

    NSNumber *thisIndex = [NSNumber numberWithInteger: indexPath.row];

    [cell.checkBox setStrokeColor: [UIColor grayColor]];
    [cell.checkBox setTintColor:[UIColor whiteColor]];
    [cell.checkBox setUncheckedColor:[UIColor whiteColor]];
    [cell.checkBox setCheckColor: self.lookAndFeel.appGreenColor];
    [cell.checkBox setTag: indexPath.row];
    [cell.checkBox addTarget: self action: @selector(receiptChecked:) forControlEvents: UIControlEventValueChanged];

    if ([self.selectedImageIndices objectForKey: thisIndex])
    {
        [cell.checkBox setCheckState: M13CheckboxStateChecked];
    }
    else
    {
        [cell.checkBox setCheckState: M13CheckboxStateUnchecked];
    }

    return cell;
}

- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout insetForSectionAtIndex: (NSInteger) section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UIImage *imageForThisImage  = self.images [indexPath.row];

    float ratioHeightVsWidth = imageForThisImage.size.height / imageForThisImage.size.width;

    float heightForThisImage = collectionView.frame.size.width * ratioHeightVsWidth;

    return CGSizeMake(collectionView.frame.size.width, heightForThisImage);
}

- (CGFloat) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout minimumInteritemSpacingForSectionAtIndex: (NSInteger) section
{
    return 0.0;
}

- (CGFloat) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout minimumLineSpacingForSectionAtIndex: (NSInteger) section
{
    return 0.0;
}

@end