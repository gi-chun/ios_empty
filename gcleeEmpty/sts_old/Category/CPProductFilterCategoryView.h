//
//  CPProductFilterCategoryView.h
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductFilterCategoryViewDelegate;

@interface CPProductFilterCategoryView : UIView

@property (nonatomic, weak) id<CPProductFilterCategoryViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame categoryInfo:(NSMutableDictionary *)aCategoryInfo listingType:(NSString *)aListingType;
- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;

@end

@protocol CPProductFilterCategoryViewDelegate <NSObject>
@optional

- (void)didTouchCategoryButton:(NSString *)url;

@end
