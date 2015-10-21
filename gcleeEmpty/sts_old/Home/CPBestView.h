//
//  CPBestView.h
//  11st
//
//  Created by spearhead on 2014. 11. 13..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CPTabButtonType){
    CPTabButtonTypeHome = 0,                    //홈
	CPTabButtonTypeShockingDeal,                //쇼킹딜
	CPTabButtonTypeMobileBest,                  //모바일 베스트
	CPTabButtonTypeElevenstBest,                //11번가 베스트
    CPTabButtonTypeTalk,                        //쇼핑톡
    CPTabButtonTypeEvent,                       //이벤트
    CPTabButtonTypePlan,                        //기획전
    CPTabButtonTypeTrend,                       //트랜드
    CPTabButtonTypeCuration,                    //신상
    CPTabButtonTypeMart,                        //마트
    CPTabButtonTypeHidden                       //히든
};

@protocol CPBestViewDelegate;

@interface CPBestView : UIView

@property (nonatomic, weak) id<CPBestViewDelegate> delegate;

- (void)setInfo:(NSDictionary *)info;
- (void)reloadData;
- (void)reloadDataWithIgnoreCache:(NSNumber *)delay;
- (void)reloadDataWithErrorRequest;
- (void)goToTopScroll;

@end

@protocol CPBestViewDelegate <NSObject>
@optional
- (void)didTouchButtonWithUrl:(NSString *)productUrl;
- (void)didTouchTabButton:(id)sender;
@end
