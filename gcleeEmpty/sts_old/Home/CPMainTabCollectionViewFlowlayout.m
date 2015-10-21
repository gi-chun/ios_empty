//
//  CPMainTabCollectionViewFlowlayout.m
//  11st
//
//  Created by saintsd on 2015. 6. 10..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPMainTabCollectionViewFlowlayout.h"

@implementation CPMainTabCollectionViewFlowlayout

-(id)init
{
	self = [super init];
	if (self) {
		CGFloat screenWidth = kScreenBoundsWidth-20;
		CGFloat columnCount = IS_IPAD ? 4 : 2;
		CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
		
		self.itemSize = CGSizeMake(cellWidth, cellWidth+75);
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
		self.minimumLineSpacing = 10;
		self.minimumInteritemSpacing = 10;
	}
	return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
	return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray* array = [super layoutAttributesForElementsInRect:rect];
	CGRect visibleRect;
	visibleRect.origin = self.collectionView.contentOffset;
	visibleRect.size = self.collectionView.bounds.size;
	
	return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
	CGFloat offsetAdjustment = MAXFLOAT;
	CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
	
	CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
	NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
	
	for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
		CGFloat itemHorizontalCenter = layoutAttributes.center.x;
		if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
			offsetAdjustment = itemHorizontalCenter - horizontalCenter;
		}
	}
	
	return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
