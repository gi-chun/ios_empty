//
//  CPProductFilterSearchView.h
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductFilterSearchViewDelegate;

@interface CPProductFilterSearchView : UIView

@property (nonatomic, weak) id<CPProductFilterSearchViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame detailInfo:(NSMutableDictionary *)aDetailInfo listingType:(NSString *)aListingType;
- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;

@end

@protocol CPProductFilterSearchViewDelegate <NSObject>
@optional

- (void)didTouchDetailSearchButton:(NSString *)parameter;
- (void)removeFilterView;

@end
