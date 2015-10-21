//
//  NetFunnelWaitView.h
//  NetFUNNEL
//
//  Created by jacojang on 13. 6. 14..
//  Copyright (c) 2013년 jacojang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NetFunnelResult.h"

#define RGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

enum TextStyleType {
    TSTypeTitleNormal = 0,
    TSTypeTitleBold,
    TSTypeTitleBold2,
    TSTypeWaitTimeNormal,
    TSTypeWaitTimeBold,
    TSTypeContentNormal,
    TSTypeContentBold,
    TSTypeFooterNormal,
    TSTypeFooterBold
};

/**
	NetFunnelWaitViewProtocol
		- 응답에 따라 대기창을 show/hide 할때 실행 해야할 내용을 정의 할 수 있는 Protocol
		- 추가로 Custom 대기창을 만들기 위해서는 NetFunnelWaitView Class를 상속받고 이 Protocol을 꼭 정의해 줘야한다.
*/
@protocol NetFunnelWaitViewProtocol <NSObject>

@required

/**
	action요청후 서버로 부터 대기(continue)응답을 받았을 경우 호출되는 함수 
*/
-(void)show;

/**
	화면의 대기창을 없애야 할 경우에 호출되는 함수
*/
-(void)hide;

/**
	action요청후 서버로 부터 IPBlock 응답을 받았을 경우 호출되는 함수
		- 가상대기창을 출력해 주고 NETFUNNEL_DEF_IPBLOCK_WAIT_TIME 만큼 대기하고 다시 요청하게 된다.
*/
-(void)showVirtualWait;

/**
	Service나 Action의 설정을 "Block"으로 설정했을 경우 호출되는 함수
*/
-(void)showBlockAlert;

@end

// ---------------------------------------------------------------------
// NetFunnelWaitData
// ---------------------------------------------------------------------
@interface NetFunnelWaitData : NSObject {
    NSInteger _waitUser;
    NSInteger _totalWaitUser;
    float _tps;
    float _progress;
    NSInteger _waitTime;
}
@property NSInteger _waitUser;
@property NSInteger _totalWaitUser;
@property float _tps;
@property float _progress;
@property NSInteger _waitTime;

@end

// ---------------------------------------------------------------------
// NetFunnelCustomAlertView
// ---------------------------------------------------------------------
@interface NetFunnelCustomAlertView : UIView

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIView *dialogView;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *buttonView;

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSArray *buttonTitles;

- (id)initWithParentView: (UIView *)_parentView;

- (void)show;
- (void)close;

@end


/**
	NetFunnel Wait View (대기창) Base Class
		- 대기창 Class를 만들기위한 Base Class로서 Default대기창 이외의 대기창을 만들고자 할때는 이 Class를 상속해야 한다.
		- NetFunnelWaitViewProtocol 를 구현해 줘야 한다.
*/
@interface NetFunnelWaitView : NSObject {
	NSDictionary *_initailResult;
    NSDictionary *_currResult;
    NSInteger _lastWaitTime;
    UIView *_pview;
    id _netfunnel;
}
@property (readonly) NSDictionary *_initailResult;
@property (readonly) NSDictionary *_currResult;
@property (readonly) NSInteger _lastWaitTime;
@property (readonly) id _netfunnel;

-(id)initWithParentView:(UIView *)view;
-(void)initailData;
-(void)setResult:(NSDictionary *)result;
-(void)setNetFunnel:(id)netfunnel;

-(NetFunnelWaitData *)getWaitData;
-(NSDictionary *)getTextStyle:(enum TextStyleType)type;
-(void)setStyleTextWithLabel:(UILabel *)label data:(NSArray *)strings;
-(void)setParentView:(UIView *)view;
-(void)setStop;

@end

// ---------------------------------------------------------------------
// NetFunnelWaitView
// ---------------------------------------------------------------------
@interface NetFunnelDefaultWaitView : NetFunnelWaitView <NetFunnelWaitViewProtocol> {
    NetFunnelCustomAlertView *_alert;
    
	UIProgressView *_progress;
	UILabel *_title;
	UILabel *_waittm;
    UILabel *_contents;
    UILabel *_footer;
    UIButton *_stop;
	NSInteger _last_wait_tm;
}

-(UIView *)createWaitView;
-(void)stopButtonClick:(id)sender;

@end
