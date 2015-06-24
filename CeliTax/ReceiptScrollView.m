//
// ReceiptScrollView.m
// CeliTax
//
// Created by Leon Chen on 2015-06-13.
// Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ReceiptScrollView.h"
#import "ReceiptCollectionViewCell.h"
#import "ReceiptCollectionFooterViewCell.h"

NSString *ReceiptCollectionViewCellIdentifier = @"ReceiptCollectionViewCell";
NSString *ReceiptCollectionFooterViewCellIdentifier = @"ReceiptCollectionFooterViewCell";

#define kReceiptCollectionFooterViewCellHeight           30

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

    UINib *receiptCollectionViewCell = [UINib nibWithNibName: @"ReceiptCollectionViewCell"
                                                      bundle: nil];
    [self.collectionView registerNib: receiptCollectionViewCell
          forCellWithReuseIdentifier: ReceiptCollectionViewCellIdentifier];
    
    UINib *receiptCollectionFooterViewCell = [UINib nibWithNibName: @"ReceiptCollectionFooterViewCell"
                                                      bundle: nil];
    [self.collectionView registerNib: receiptCollectionFooterViewCell
          forCellWithReuseIdentifier: ReceiptCollectionFooterViewCellIdentifier];
    
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

-(void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    
    [self.collectionView setContentInset:_insets];
}

#pragma mark - From UICollectionView Delegate/Datasource

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.images.count + 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row < self.images.count)
    {
        ReceiptCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: ReceiptCollectionViewCellIdentifier forIndexPath: indexPath];
        
        if (!cell)
        {
            cell = [[ReceiptCollectionViewCell alloc] init];
        }
        
        [cell.image setImage: [self.images objectAtIndex: indexPath.row]];
        
        return cell;
    }
    else
    {
        ReceiptCollectionFooterViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: ReceiptCollectionFooterViewCellIdentifier forIndexPath: indexPath];
        
        if (!cell)
        {
            cell = [[ReceiptCollectionFooterViewCell alloc] init];
        }
        
        return cell;
    }
    
    return nil;
}

- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout insetForSectionAtIndex: (NSInteger) section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize) collectionView: (UICollectionView *) collectionView layout: (UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row < self.images.count)
    {
        UIImage *imageForThisImage  = self.images [indexPath.row];
        
        float ratioHeightVsWidth = imageForThisImage.size.height / imageForThisImage.size.width;
        
        float heightForThisImage = collectionView.frame.size.width * ratioHeightVsWidth;
        
        return CGSizeMake(collectionView.frame.size.width, heightForThisImage);
    }
    else
    {
        return CGSizeMake(collectionView.frame.size.width, kReceiptCollectionFooterViewCellHeight);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.images.count)
    {
        if (self.delegate)
        {
            [self.delegate addImagePressed];
        }

    }
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