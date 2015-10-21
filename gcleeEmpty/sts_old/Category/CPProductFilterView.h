//
//  CPProductFilterView.h
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductFilterViewDelegate;

@interface CPProductFilterView : UIView

@property (nonatomic, weak) id<CPProductFilterViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame metaInfo:(NSMutableDictionary *)aMetaInfo selectedKey:(NSString *)aSelectedKey;
- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;
- (void)refreshTabData:(NSMutableDictionary *)searchMetaInfo;

@end

@protocol CPProductFilterViewDelegate <NSObject>
@optional

//Category
- (void)didTouchCategoryButton:(NSString *)url;

//Brand
- (void)didTouchBrandCheckButton:(NSString *)parameter;

//Partenr
- (void)didTouchPartnerCheckButton:(NSString *)parameter;

//Detail Search
- (void)didTouchDetailSearchButton:(NSString *)parameter;

@end