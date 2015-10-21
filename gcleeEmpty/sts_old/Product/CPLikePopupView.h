//
//  CPLikePopupView.h
//  11st
//
//  Created by 11st_mac_20 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface CPLikePopupView : UIView
//
//@end

typedef NS_ENUM(NSUInteger, LikeStatusPopupButton)
{
    LikeStatusPopupButtonMyLikedProductList,
    LikeStatusPopupButtonMyLikedPlanningList,
    LikeStatusPopupButtonClose
};

typedef NS_ENUM(NSUInteger, LikePopupType)
{
    LikePopupTypeProduct,
    LikePopupTypePlanning
};

@class CPLikePopupView;

@protocol CPLikePopupViewDelegate <NSObject>

@required
- (void)likeStatusPopupView:(CPLikePopupView *)view didClickedButton:(NSNumber *)buttonType;

@end

@interface CPLikePopupView : UIView

- (id)initWithFrame:(CGRect)frame popupType:(LikePopupType)type;

@property (nonatomic, assign) BOOL likeSuccess;
@property (nonatomic, weak) id<CPLikePopupViewDelegate> delegate;

@end