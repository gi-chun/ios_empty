//
//  CPFooterButtonView.h
//  11st
//
//  Created by 조휘준 on 2015. 04. 16..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define buttonWidth_three   3
#define buttonWidth_four    4

typedef NS_ENUM(NSUInteger, CPFooterButtonUIType){
	CPFooterButtonUITypeNormal = 0,         //노말타입
	CPFooterButtonUITypeHome,               //홈타입
	CPFooterButtonUITypeBest                //베스트타입
};

@protocol CPFooterButtonViewDelegate;

@interface CPFooterButtonView : UIView

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CPFooterButtonUIType buttonType;  // 버튼타입
@property (nonatomic, assign) NSInteger widthCount;             // 가로count

@property (nonatomic, weak) id<CPFooterButtonViewDelegate> delegate;

//뷰 사이즈만 계산
+ (CGSize)viewSizeWithData:(NSArray *)items UIType:(CPFooterButtonUIType)buttonType columnCount:(NSInteger)columnCount;

- (void)setType:(CPFooterButtonUIType)type widthCount:(NSInteger)widthCount;
- (void)initData:(NSArray*)items;

@end

@protocol CPFooterButtonViewDelegate <NSObject>
@optional
- (void)touchFooterItemButton:(NSString *)url;

@end
