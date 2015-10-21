//
//  CPSearchTabMenuView.m
//  11st
//
//  Created by spearhead on 2014. 9. 29..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPSearchTabMenuView.h"
#import "AccessLog.h"

@interface CPSearchTabMenuView()
{
    NSArray *tabTitles;
    NSArray *tabContents;
    NSArray *riseTabItems;
    
    UIView *containerView;
    UIView *indicatorView;
}

@end

@implementation CPSearchTabMenuView

- (id)initWithFrame:(CGRect)frame tabTitleItems:(NSArray *)tabTitleItems tabContentsItems:(NSArray *)tabContentsItems
{
    self = [super initWithFrame:frame];
    if (self) {
        
        tabTitles = tabTitleItems;
        tabContents = tabContentsItems;
        
        [self setBackgroundColor:UIColorFromRGB(0xf0f0f2)];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xd3d3d6)];
        [self addSubview:lineView];
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(frame)-16, 42)];
        [containerView setBackgroundColor:UIColorFromRGB(0xd3d3d6)];
        [self addSubview:containerView];
        
        indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        [indicatorView setBackgroundColor:[UIColor clearColor]];
        
        for (NSInteger i = 0; i < tabTitles.count; i++) {
            NSDictionary *tab = tabTitles[i];
            
            CGFloat buttonWidth = (CGRectGetWidth(containerView.frame) - 4) / 3;
            CGFloat buttonHeight = 40;
            
            CGRect kMenuButtonFrame = CGRectMake(1, 0, buttonWidth, buttonHeight);
            CGRect menuButtonFrame = CGRectMake(kMenuButtonFrame.origin.x + (buttonWidth * i) + (1 * i),
                                                kMenuButtonFrame.origin.y + 1,
                                                kMenuButtonFrame.size.width,
                                                kMenuButtonFrame.size.height);
            
            UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuButton setFrame:menuButtonFrame];
            //            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_tab_nor.png"] forState:UIControlStateNormal];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_tab_press.png"] forState:UIControlStateHighlighted];
            [menuButton setBackgroundImage:[UIImage imageNamed:@"gnb_tab_press.png"] forState:UIControlStateSelected];
            [menuButton setTitle:tab[@"title"] forState:UIControlStateNormal];
            [menuButton addTarget:self action:@selector(touchTabMenu:) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setTag:i];
            [menuButton setAccessibilityLabel:tab[@"title"] Hint:@""];
            [self setButtonProperties:menuButton];
            [containerView addSubview:menuButton];
            
            // 급상승 인디케이터
            if ([tab[@"key"] isEqualToString:@"rise"]) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key == 'rise')"];
                riseTabItems = [tabContents filteredArrayUsingPredicate:predicate];
                
                for (int i = 0; i < riseTabItems.count; i++) {
                    UIButton *indicatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [indicatorButton setFrame:CGRectMake(0+(i*10), 0, 5, 5)];
                    [indicatorButton setImage:[UIImage imageNamed:@"search_tab_indicator_off.png"] forState:UIControlStateNormal];
                    [indicatorButton setImage:[UIImage imageNamed:@"search_tab_indicator_on.png"] forState:UIControlStateSelected];
                    [indicatorButton setTag:i];
                    [indicatorView addSubview:indicatorButton];
                }

                [indicatorView setFrame:CGRectMake(CGRectGetMinX(menuButton.frame), 30, 10+((riseTabItems.count-1)*10), 5)];
                [indicatorView setCenter:CGPointMake(menuButton.center.x, 35)];
            }
            
            if (i == 0) {
                [self setHighlightedButtonProperties:menuButton];
//                [barIamgeView setHidden:NO];
            }
        }
        
        [containerView addSubview:indicatorView];
    }
    return self;
}

#pragma mark - Public Methods

- (void)tabMenuCurrentItemIndexDidChange:(NSInteger)index
{
    for (UIView *subView in [containerView subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            
            NSDictionary *title = tabTitles[button.tag];
            NSDictionary *content = tabContents[index];
            
            if ([title[@"key"] isEqualToString:content[@"key"]]) {
                [self setHighlightedButtonProperties:button];
            }
            else {
                [self setButtonProperties:button];
            }
        }
    }
    
    for (UIView *subView in [indicatorView subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            
            NSDictionary *indicator = riseTabItems[button.tag];
            NSDictionary *content = tabContents[index];
            
            
//            if ([indicator[@"page"] isEqualToString:content[@"page"]]) {
            if (indicator[@"page"] == content[@"page"]) {
//                [self setHighlightedButtonProperties:button];
                [button setSelected:YES];
            }
            else {
                [button setSelected:NO];
            }
        }
    }
}

#pragma mark - Button & Label Properties

- (void)setButtonProperties:(UIButton *)button
{
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    [button setTitleColor:UIColorFromRGB(0x959698) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x959698) forState:UIControlStateHighlighted];
    [button setBackgroundColor:UIColorFromRGB(0xd4d5d9)];
}

- (void)setHighlightedButtonProperties:(UIButton *)button
{
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [button setBackgroundColor:UIColorFromRGB(0x8f95af)];
}

#pragma mark - Selectors

- (void)touchTabMenu:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
    switch (tag) {
        case 0:
            //AccessLog - 최근 검색어 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB02"];
            break;
        case 1:
            //AccessLog - 급상승 검색어 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB09"];
            break;
        case 2:
            tag = tabContents.count - 1;
            
            //AccessLog - 인기 검색어 탭
            [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRB04"];
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchTabMenuButton:)]) {
        [self.delegate didTouchTabMenuButton:tag];
    }
}

@end
