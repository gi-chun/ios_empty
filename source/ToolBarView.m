//
//  ToolBarView.m
//
//  Created by gclee on 2015. 10. 27..
//  Copyright (c) gclee. All rights reserved.
//

#import "ToolBarView.h"
//#import "CPSnapshotPopOverView.h"
//#import "CPPopOverView.h"
//#import "AccessLog.h"

//@interface ToolBarView () <CPSnapshotPopOverViewDelegate,
//                             CPPopOverViewViewDelegate>
@interface ToolBarView ()
{
    NSArray *toolbarItems;
    
//    CPPopOverView *popOverView;
//    CPSnapshotPopOverView *snapshotPopOverView;
}

@end

@implementation ToolBarView

- (id)initWithFrame:(CGRect)frame toolbarType:(NSInteger)toolbarType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat marginY = (kScreenBoundsWidth > 320)?0:0;
        CGFloat marginBY = (kScreenBoundsWidth > 320)?0:0;
        
        [self setBackgroundColor:[UIColor clearColor]];
        //[self setBackgroundColor:UIColorFromRGB(0xffffff)];
        
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, kToolBarHeight)];
        [backgroundImageView setImage:[UIImage imageNamed:@"bottom_banner.png"]];
        
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill; //UIViewContentModeScaleAspectFit
        [self addSubview:backgroundImageView];
        
//        UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [prevButton setFrame:CGRectMake(13, 20-marginBY, 41, 41)];
//        [prevButton setImage:[UIImage imageNamed:@"bottom_back_btn.png"] forState:UIControlStateNormal];
//        [prevButton setImage:[UIImage imageNamed:@"bottom_back_btn_press.png"] forState:UIControlStateHighlighted];
//        [prevButton addTarget:self action:@selector(touchToolbar:) forControlEvents:UIControlEventTouchUpInside];
//        [prevButton setTag:1];
//        [self addSubview:prevButton];
        
        UIButton *adButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [adButton setFrame:CGRectMake(0, 0, kScreenBoundsWidth, kToolBarHeight)];
        [adButton setBackgroundColor:[UIColor clearColor]];
        [adButton addTarget:self action:@selector(touchToolbar:) forControlEvents:UIControlEventTouchUpInside];
        [adButton setTag:2];
        [self addSubview:adButton];
        
//        UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [topButton setFrame:CGRectMake(kScreenBoundsWidth-31-13, 20-marginBY, 41, 41)];
//        [topButton setImage:[UIImage imageNamed:@"bottom_top_btn.png"] forState:UIControlStateNormal];
//        [topButton setImage:[UIImage imageNamed:@"bottom_top_btn_press.png"] forState:UIControlStateHighlighted];
//        [topButton addTarget:self action:@selector(touchToolbar:) forControlEvents:UIControlEventTouchUpInside];
//        [topButton setTag:3];
//        [self addSubview:topButton];
        
        
        
        
        
        
//        NSString *plistPath = @"subToolbar";
//        NSString *path = [[NSBundle mainBundle] pathForResource:plistPath ofType:@"plist"];
//        
//        toolbarItems = [NSArray arrayWithContentsOfFile:path];
//        
////        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(count == %i)", _cutCount];
////        _filteredFrameItems= [frameItems filteredArrayUsingPredicate:predicate];
////        NSLog(@"toolbarItems:%@", toolbarItems);
//        
//        CGFloat buttonWidth = kScreenBoundsWidth / 7;
//        CGFloat buttonHeight = kToolBarHeight;
//        
//        for (NSInteger i = 0; i < toolbarItems.count; i++) {
//            NSDictionary *toolbar = toolbarItems[i];
//
//            CGRect kToolbarImageViewFrame = CGRectMake(0, 0, buttonWidth, buttonHeight);
//            CGRect toolbarImageViewFrame = CGRectMake(kToolbarImageViewFrame.origin.x + (buttonWidth * i),
//                                                        kToolbarImageViewFrame.origin.y,
//                                                        kToolbarImageViewFrame.size.width,
//                                                        kToolbarImageViewFrame.size.height);
//            
//            UIButton *toolbarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            [toolbarButton setFrame:toolbarImageViewFrame];
//            [toolbarButton setImage:[UIImage imageNamed:toolbar[@"imageNormal"]] forState:UIControlStateNormal];
//            [toolbarButton setImage:[UIImage imageNamed:toolbar[@"imageHighlighted"]] forState:UIControlStateHighlighted];
//			
//            if (i == 2) {
//                [toolbarButton setImage:[UIImage imageNamed:toolbar[@"imageDisabled"]] forState:UIControlStateDisabled];
//            }
//            
//            [toolbarButton addTarget:self action:@selector(touchToolbar:) forControlEvents:UIControlEventTouchUpInside];
//            [toolbarButton setTag:i];
//            //[toolbarButton setAccessibilityLabel:toolbar[@"accessibility"] Hint:@""];
//            [self addSubview:toolbarButton];
//            
//            //백버튼은 홈으로 이동하기 위해 활성화 시켜놓음
//            if (i == 2) {
//                [self setButtonProperties:toolbarButton enable:NO];
//            }
//        }
//        
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 1)];
//        [lineView setBackgroundColor:UIColorFromRGB(0xd3d3d6)];
//        [self addSubview:lineView];
        
//        // 더보기 팝오버메뉴
//        CGFloat popOverHeight = kScreenBoundsHeight-(kToolBarHeight+kNavigationHeight);
//        popOverView = [[CPPopOverView alloc] initWithFrame:CGRectMake(0, -popOverHeight, kScreenBoundsWidth, popOverHeight) toolbarType:toolbarType];
//        [popOverView setDelegate:self];
//        [popOverView setHidden:YES];
//        [self addSubview:popOverView];
//        
//        // 즐겨찾기 팝오버메뉴
//        snapshotPopOverView = [[CPSnapshotPopOverView alloc] initWithFrame:CGRectMake(0, -popOverHeight, kScreenBoundsWidth, popOverHeight) toolbarType:toolbarType];
//        [snapshotPopOverView setDelegate:self];
//        [snapshotPopOverView setHidden:YES];
//        [self addSubview:snapshotPopOverView];
    }
    return self;
}

#pragma mark - Public Methods

- (void)setButtonProperties:(UIButton *)button enable:(BOOL)enable
{
    [button setEnabled:enable];
}

- (void)setReloadButtonProperties:(UIButton *)button isReload:(BOOL)isReload
{
    if (isReload) {
        [button setImage:[UIImage imageNamed:@"icon_bar_pause.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_bar_pause_press.png"] forState:UIControlStateHighlighted];
    }
    else {
        [button setImage:[UIImage imageNamed:@"icon_bar_refresh.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_bar_refresh_press.png"] forState:UIControlStateHighlighted];
    }
}

// productOpting이 나타날때 툴바를 강제로 등장시키기위해 만들어놓음.
- (void)touchToggleButton
{
	for (UIButton *button in self.subviews) {
		if ([button isKindOfClass:[UIButton class]]) {
			if (button.tag == 1) {
				[self touchToolbar:button];
			}
		}
	}
}

- (void)setHiddenPopover:(BOOL)hidden
{
//    [popOverView setHidden:hidden];
//    
//    [snapshotPopOverView setHidden:hidden];
}

#pragma mark - Selectors

- (void)touchToolbar:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *buttonInfo = toolbarItems[button.tag];
    
//    if (![popOverView isHidden] && button.tag != CPToolBarButtonTypeMore) {
//        [popOverView setHidden:YES];
//    }
//    
//    if (![snapshotPopOverView isHidden] && button.tag != CPToolBarButtonTypeSnapshot) {
//        [snapshotPopOverView setHidden:YES];
//    }
    
    switch (button.tag) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        default:
            if ([self.delegate respondsToSelector:@selector(didTouchToolBarButton:buttonInfo:)]) {
                [self.delegate didTouchToolBarButton:button buttonInfo:buttonInfo];
            }
            break;
    }
    
}

#pragma mark - CPSnapshotPopOverViewDelegate

- (void)didTouchSnapshotPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
    if ([self.delegate respondsToSelector:@selector(didTouchSnapshotPopOverButton:buttonInfo:)]) {
        [self.delegate didTouchSnapshotPopOverButton:button buttonInfo:buttonInfo];
        //[snapshotPopOverView setHidden:YES];
    }
}

#pragma mark - CPPopOverViewViewDelegate

- (void)didTouchPopOverButton:(UIButton *)button buttonInfo:(NSDictionary *)buttonInfo
{
    if ([self.delegate respondsToSelector:@selector(didTouchPopOverButton:buttonInfo:)]) {
        [self.delegate didTouchPopOverButton:button buttonInfo:buttonInfo];
        //[popOverView setHidden:YES];
    }
}

#pragma mark - Override Methods

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
            }
        }
    }
    
    return nil;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    // UIView will be 'transparent' for touch events if we return NO.
//    NSLog(@"startItem: %f,%f -> point : %f/%f", self.frame.origin.x, self.frame.origin.y, point.x, point.y);
//    if (CGRectContainsPoint(self.frame, point)) {
//        return YES;
//    }
//    
////    return NO;
//    return YES;
//}

@end
