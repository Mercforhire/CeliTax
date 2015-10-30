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

#define kReceiptCollectionFooterViewCellHeight           30

@interface ReceiptScrollView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ReceiptScrollView

- (void) baseInit
{
    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

    CGRect frame = self.frame;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout: collectionLayout];
    (self.collectionView).backgroundColor = [UIColor whiteColor];

    UINib *receiptCollectionViewCell = [UINib nibWithNibName: @"ReceiptCollectionViewCell"
                                                      bundle: nil];
    [self.collectionView registerNib: receiptCollectionViewCell
          forCellWithReuseIdentifier: ReceiptCollectionViewCellIdentifier];
    
    (self.collectionView).dataSource = self;
    (self.collectionView).delegate = self;
    [self.collectionView setBounces: YES];
    [self.collectionView setAlwaysBounceVertical:YES];
    [self addSubview: self.collectionView];
    
    self.selectedImageIndices = [NSMutableDictionary new];
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

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    (self.collectionView).frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void) setImages: (NSArray *) images
{
    _images= images;

    [self.collectionView reloadData];
}

-(void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    
    (self.collectionView).contentInset = _insets;
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
        cell = [[ReceiptCollectionViewCell alloc] init];
    }
    
    (cell.image).image = (self.images)[indexPath.row];
    
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