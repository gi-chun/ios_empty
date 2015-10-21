//
//  CPFooterButtonView.m
//  11st
//
//  Created by 조휘준 on 2015. 04. 16..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPFooterButtonView.h"
#import "AccessLog.h"

#define SHADOW_HEIGHT   1

@interface CPFooterButtonView()
{
	UIView *footerButtonView;
	NSArray *buttonItems;
}

@end

@implementation CPFooterButtonView

@synthesize width = _width;
@synthesize height = _height;

+ (CGSize)viewSizeWithData:(NSArray *)items UIType:(CPFooterButtonUIType)buttonType columnCount:(NSInteger)columnCount
{
	NSInteger buttonCount = items.count + (items.count % columnCount == 0 ? 0 : (columnCount - items.count % columnCount));
	CGFloat viewHeight = 0;
	
	for (int i = 0; i < buttonCount; i++) {
		NSInteger itemHeight = 34;
		NSInteger itemY = (i / columnCount) * itemHeight + (i / columnCount);
		
		viewHeight = itemY + itemHeight;
	}
	
	return CGSizeMake(kScreenBoundsWidth-20, viewHeight+SHADOW_HEIGHT);
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		//기본 노말타입
		self.buttonType = CPFooterButtonUITypeNormal;
		//기본 가로 3
		self.widthCount = buttonWidth_three;
		
		footerButtonView = [[UIView alloc] initWithFrame:CGRectZero];
		[self addSubview:footerButtonView];
	}
	return self;
}

//타입 설정
- (void)setType:(CPFooterButtonUIType)type widthCount:(NSInteger)widthCount
{
	self.buttonType = type;
	self.widthCount = widthCount <= 0 ? buttonWidth_three : widthCount;
}

- (void)initData:(NSArray*)items
{
	buttonItems = [items copy];
	
	
	UIView *shadowView = [[UIView alloc] init];
	[shadowView setBackgroundColor:UIColorFromRGB(0xe3e3e8)];
	[shadowView setClipsToBounds:YES];
	[footerButtonView addSubview:shadowView];
	
	NSInteger buttonCount = items.count + (items.count % self.widthCount == 0 ? 0 : (self.widthCount - items.count % self.widthCount));
	CGFloat viewHeight = 0;
	
	BOOL isSpecialData = NO;
	
	for (int i = 0; i < buttonCount; i++) {
		
		NSInteger itemWidth = (kScreenBoundsWidth-20) / self.widthCount - 1;
		NSInteger itemHeight = 34;
		NSInteger itemX = (i % self.widthCount) * itemWidth + (i % self.widthCount) % self.widthCount;
		NSInteger itemY = (i / self.widthCount) * itemHeight + (i / self.widthCount);
		
		//뷰 뒷부분에 공백이 남는 부분을 임의로 채워준다.
		if (i != 0 && i % self.widthCount == (self.widthCount-1)) {
			itemWidth = (kScreenBoundsWidth-20) - itemX;
		}
		
		if (self.buttonType == CPFooterButtonUITypeBest && i == 0 && ![[items[i] objectForKey:@"text"] isEqualToString:@"전문관베스트"]) {
			//베스트탭 전문관 베스트
			UIButton *specialButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[specialButton setFrame:CGRectMake(itemX, itemY, itemWidth, itemHeight)];
			[specialButton setTitle:@"전문관베스트" forState:UIControlStateNormal];
			[specialButton setTitleColor:UIColorFromRGB(0x8d96e3) forState:UIControlStateNormal];
			[specialButton setBackgroundColor:[UIColor whiteColor]];
			[specialButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
			[shadowView addSubview:specialButton];
			isSpecialData = YES;
			continue;
		}
		
		NSInteger itemIndex = (isSpecialData ? i-1 : i);
		NSString *title = items.count <= itemIndex ? @"" : [items[itemIndex] objectForKey:@"text"];
		NSString *selected = items.count <= itemIndex ? @"" : [items[itemIndex] objectForKey:@"selected"];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTag:itemIndex];
		[button setFrame:CGRectMake(itemX, itemY, itemWidth, itemHeight)];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"bg_b9b9b9.png"] forState:UIControlStateHighlighted];
		[button setBackgroundColor:[UIColor whiteColor]];
		[button.titleLabel setFont:[UIFont systemFontOfSize:13]];
		
		[shadowView addSubview:button];
		
		//selected
		if ([selected isEqualToString:@"Y"]) {
			[button setTitleColor:UIColorFromRGB(0x8d96e3) forState:UIControlStateNormal];
			[button setUserInteractionEnabled:NO];
			
			if ([items[i] objectForKey:@"linkUrl"] && [[items[itemIndex] objectForKey:@"linkUrl"] length] > 0) {
				[button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
			}
		}
		else {
			[button setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
			[button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
			[button setUserInteractionEnabled:YES];
		}
		
		viewHeight = itemY + itemHeight;
	}
	
	[shadowView setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, viewHeight)];
	[footerButtonView setFrame:CGRectMake(0, 0, kScreenBoundsWidth-20, viewHeight+SHADOW_HEIGHT)];
	
	//쉐도우 라인
	UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, footerButtonView.frame.size.height-1, footerButtonView.frame.size.width, 1)];
	bottomLine.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[footerButtonView addSubview:bottomLine];
	
	self.width = CGRectGetWidth(footerButtonView.frame);
	self.height = CGRectGetHeight(footerButtonView.frame);
}

#pragma mark - clickEvent

- (void)touchButton:(id)sender
{
	UIButton *button = (UIButton *)sender;
	
	if (buttonItems.count <= button.tag) {
		return;
	}
	
	NSDictionary *info = buttonItems[button.tag];
	NSString *url = info[@"linkUrl"];
	
	if (url && [[url trim] length] > 0) {
		if ([self.delegate respondsToSelector:@selector(touchFooterItemButton:)]) {
			[self.delegate touchFooterItemButton:url];
			
			if (self.buttonType == CPFooterButtonUITypeBest) {
				//AccessLog - 전문관
				[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAL0600"];
			}
		}
	}
}

@end
