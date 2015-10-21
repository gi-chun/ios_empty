//
//  CPTalkTagView.m
//  11st
//
//  Created by saintsd on 2015. 6. 4..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTalkTagView.h"
#import "AccessLog.h"

@interface CPTalkTagView ()
{
	NSArray *_items;
}

@end

@implementation CPTalkTagView

- (id)initWithItems:(NSArray *)items
{
	if (self = [super init]) {
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	CGFloat offsetX = 0.f;
	CGFloat sizeH = 0.f;
	
	NSInteger itemCount = ([_items count] > 3 ? 3 : [_items count]);
	
	for (NSInteger i=0; i<itemCount; i++) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.text = [NSString stringWithFormat:@"#%@", _items[i][@"tagNm"]];
		label.font = [UIFont systemFontOfSize:14];
		label.numberOfLines = 1;
		[label sizeToFitWithVersion];
		
		CGRect rt = CGRectMake(offsetX, 0, label.frame.size.width+6.f, label.frame.size.height+6.f);
		
		if (CGRectGetMaxX(rt) >= kScreenBoundsWidth-20) {
			break;
		}
		
		UIButton *btn = [[UIButton alloc] initWithFrame:rt];
		[btn setTitle:label.text forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0x757575) forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0x0000ff) forState:UIControlStateHighlighted];
		[btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
		[btn setTag:i];
		[btn addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:btn];
		
		offsetX = CGRectGetMaxX(btn.frame)+3.f;
		sizeH = CGRectGetHeight(btn.frame);
	}
	
	self.frame = CGRectMake(0, 0, offsetX, sizeH);
}

- (void)onClickButton:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSString *url = _items[tag][@"tagLink"];
	if (self.delegate && [self.delegate respondsToSelector:@selector(touchTalkTagViewItemButton:)]) {
		[self.delegate touchTalkTagViewItemButton:url];
	}
	
	[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAF0300"];
}

@end
