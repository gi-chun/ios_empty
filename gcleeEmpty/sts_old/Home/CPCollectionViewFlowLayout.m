//
//  CPCollectionViewFlowLayout.m
//  11st
//
//  Created by spearhead on 2014. 11. 14..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPCollectionViewFlowLayout.h"

@interface CPCollectionViewFlowLayout()
{
    CGFloat preCellY;
}

@end

@implementation CPCollectionViewFlowLayout

-(id)init
{
    self = [super init];
    if (self) {
//        self.itemSize = CGSizeMake([Modules getBestLayoutItemWidth], [Modules getBestLayoutItemWidth]+75);
//        self.scrollDirection = UICollectionViewScrollDirectionVertical;
//        self.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
//        self.minimumLineSpacing = 0;
//        self.minimumInteritemSpacing = 10;
//        //self.headerReferenceSize = CGSizeMake(320.0f, 20.0f);
        
        CGFloat screenWidth = kScreenBoundsWidth-20;
        CGFloat columnCount = IS_IPAD ? 4 : 2;
        CGFloat cellWidth = [Modules getBestLayoutItemWidth:screenWidth columnCount:columnCount];
        
        self.itemSize = CGSizeMake(cellWidth, cellWidth+75);
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 10;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];
    
    CGFloat leftMargin = self.sectionInset.left; //initalized to silence compiler, and actaully safer, but not planning to use.
    
    //this loop assumes attributes are in IndexPath order
    for (UICollectionViewLayoutAttributes *attributes in attributesForElementsInRect) {
        
        if (!([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] || [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter])) {
            
            if (attributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left; //will add outside loop
            } else {
                
                //SearchProductGrid 개수가 홀수이면서 뒤에 다른 cell이 올 경우 중앙배치되는 현상방지
                if (preCellY != attributes.frame.origin.y) {
                    CGRect newLeftAlignedFrame = attributes.frame;
                    newLeftAlignedFrame.origin.x = self.sectionInset.left;
                    attributes.frame = newLeftAlignedFrame;
                }
                else {
                    CGRect newLeftAlignedFrame = attributes.frame;
                    newLeftAlignedFrame.origin.x = leftMargin;
                    attributes.frame = newLeftAlignedFrame;
                }
            }
            
            preCellY = attributes.frame.origin.y;
            leftMargin += attributes.frame.size.width + (kScreenBoundsWidth-20-([Modules getBestLayoutItemWidth])*(IS_IPAD?4:2))/(IS_IPAD?3:1);
        }
        
        [newAttributesForElementsInRect addObject:attributes];
    }
    
    return newAttributesForElementsInRect;
}

@end
