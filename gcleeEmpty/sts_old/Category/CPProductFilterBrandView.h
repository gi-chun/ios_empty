//
//  CPProductFilterBrandView.h
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductFilterBrandViewDelegate;

@interface CPProductFilterBrandView : UIView

@property (nonatomic, weak) id<CPProductFilterBrandViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame brandInfo:(NSMutableDictionary *)aBrandInfo listingType:(NSString *)aListingType;
- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;

@end

@protocol CPProductFilterBrandViewDelegate <NSObject>
@optional

- (void)didTouchBrandCheckButton:(NSString *)parameter;

@end
