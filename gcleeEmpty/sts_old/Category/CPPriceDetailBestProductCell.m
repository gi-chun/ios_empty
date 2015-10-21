//
//  CPPriceDetailBestProductCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailBestProductCell.h"
#import "CPProductDetailBestProductItemCell.h"

@interface CPPriceDetailBestProductCell () <    UICollectionViewDataSource,
                                                UICollectionViewDelegate,
                                                CPProductDetailBestProductItemCellDelegate >
{
    UICollectionView *_contentView;
    UIView *_lineView;
}

@end

@implementation CPPriceDetailBestProductCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _contentView.dataSource = self;
    _contentView.delegate = self;
    _contentView.bounces = NO;
    [_contentView registerClass:[CPProductDetailBestProductItemCell class] forCellWithReuseIdentifier:@"productDetailBestProductItemCell"];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_contentView];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    [self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-1);
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, self.frame.size.height-1, _contentView.frame.size.width, 1);
}

- (void)setItem:(NSDictionary *)item
{
    if (_item != item) {
        _item = item;
        
        [self updateView];
    }
}

- (void)updateView
{
    [_contentView setContentOffset:CGPointZero animated:NO];
    [_contentView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *items = _item[@"items"];
    NSInteger count = items.count;
    
    if ([@"Y" isEqualToString:_item[@"isMore"]]) {
        count++;
    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = _item[@"items"];
    
    CPProductDetailBestProductItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"productDetailBestProductItemCell"
                                                                                         forIndexPath:indexPath];

    if (indexPath.row >= items.count) {
        cell.item = nil;
        cell.isMore = YES;
    }
    else {
        cell.item = items[indexPath.row];
        cell.isMore = NO;
    }

    cell.delegate = self;
    [cell updateCell];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = 110.f;
    return CGSizeMake(cellWidth, _contentView.frame.size.height-20);
}

#pragma mark - CPProductDetailBestProductItemCellDelegate

- (void)productDetailBestProductItemCell:(CPProductDetailBestProductItemCell *)cell onTouchLinkUrl:(NSString *)linkUrl
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailBestProductCell:onTouchMoreLink:)])
    {
        [self.delegate priceDetailBestProductCell:self onTouchMoreLink:linkUrl];
    }
}

- (void)productDetailBestProductItemCellOnTouchMoreItem
{
    NSString *linkUrl = _item[@"linkUrl"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(priceDetailBestProductCell:onTouchMoreLink:)])
    {
        [self.delegate priceDetailBestProductCell:self onTouchMoreLink:linkUrl];
    }
}

@end
