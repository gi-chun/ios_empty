//
//  CPEventServiceView.m
//  11st
//
//  Created by saintsd on 2015. 6. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPEventServiceView.h"
#import "UIImageView+WebCache.h"
#import "Accesslog.h"

@interface CPEventServiceView ()
{
	NSArray *_items;
}

@end

@implementation CPEventServiceView

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
	if (self = [super initWithFrame:frame]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	CGFloat buttonWidth = self.frame.size.width / _items.count;
	CGFloat buttonHeight = self.frame.size.height-1;
	
	for (NSInteger i=0; i<_items.count; i++) {
		NSString *buttonTitle = _items[i][@"text"];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, buttonHeight);
		btn.tag = i;
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3) width:CGRectGetWidth(btn.frame) height:CGRectGetHeight(btn.frame)]
					   forState:UIControlStateHighlighted];
		[btn addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:btn];
		
		UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		[iconView sd_setImageWithURL:[NSURL URLWithString:_items[i][@"lnkBnnrImgUrl"]]];
		[btn addSubview:iconView];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setFont:[UIFont systemFontOfSize:14]];
		[label setTextColor:UIColorFromRGB(0x333333)];
		[label setTextAlignment:NSTextAlignmentLeft];
		[label setText:buttonTitle];
		[label sizeToFit];
		[btn addSubview:label];

		[btn setAccessibilityLabel:buttonTitle Hint:@""];
		
		CGFloat attheight = CGRectGetHeight(iconView.frame) + 4.f + CGRectGetHeight(label.frame);
		CGFloat offsetY = (btn.frame.size.height/2)-(attheight/2);
		
		iconView.frame = CGRectMake((btn.frame.size.width/2)-(iconView.frame.size.width/2), offsetY,
									iconView.frame.size.width, iconView.frame.size.height);
		
		label.frame = CGRectMake((btn.frame.size.width/2)-(label.frame.size.width/2), CGRectGetMaxY(iconView.frame),
								 label.frame.size.width, label.frame.size.height);
	}
	
	for (NSInteger i=1; i<_items.count; i++) {
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i * buttonWidth)-1, 0, 1, buttonHeight)];
		lineView.backgroundColor = UIColorFromRGB(0xe8e8e8);
		[self addSubview:lineView];
	}
	
	UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
	bottomLine.backgroundColor = UIColorFromRGB(0xdfe1e8);
	[self addSubview:bottomLine];
}

- (void)onTouchButton:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSString * linkUrl = _items[tag][@"linkUrl"];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(touchEventServiceViewItemButton:)]) {
		[self.delegate touchEventServiceViewItemButton:linkUrl];
	}
	
	if (tag == 0)		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0300"];
	else if (tag == 1)	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0303"];
	else if (tag == 2)	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0301"];
}

@end
