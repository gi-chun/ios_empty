//
//  CPProductFilterPartnerView.h
//  11st
//
//  Created by spearhead on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductFilterPartnerViewDelegate;

@interface CPProductFilterPartnerView : UIView

@property (nonatomic, weak) id<CPProductFilterPartnerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame partnerInfo:(NSMutableDictionary *)aPartnerInfo listingType:(NSString *)aListingType;
- (void)refreshData:(NSMutableDictionary *)searchMetaInfo;

@end

@protocol CPProductFilterPartnerViewDelegate <NSObject>
@optional

- (void)didTouchPartnerCheckButton:(NSString *)parameter;

@end