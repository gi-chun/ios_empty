//
//  CPTrendCommonMoreCell.m
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendCommonMoreCell.h"
#import "CPTouchActionView.h"

@interface CPTrendCommonMoreCell ()
{
	UIView *_contentView;
	UIView *_lineView;
}

@end

@implementation CPTrendCommonMoreCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.contentView.backgroundColor = [UIColor clearColor];
	
	_contentView = [[UIView alloc] init];
	_contentView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_contentView];
	
	_lineView = [[UIView alloc] init];
	_lineView.backgroundColor = UIColorFromRGB(0xd1d1d6);
	[self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
	self.contentView.frame = self.bounds;
	_contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-11);
	
	for (UIView *subview in _contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	[label setTextColor:UIColorFromRGB(0x2d348c)];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont boldSystemFontOfSize:14]];
	[_contentView addSubview:label];

	[label setText:self.item[@"text"]];
	CGSize moreTitleSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(10000, 34) lineBreakMode:label.lineBreakMode];
	NSInteger size = moreTitleSize.width + 12;
	[label setFrame:CGRectMake((CGRectGetWidth(_contentView.frame)-size)/2, 0, moreTitleSize.width, 34)];

	UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
	arrowView.image = [UIImage imageNamed:@"bt_arrow_go.png"];
	[_contentView addSubview:arrowView];
	
	[arrowView setFrame:CGRectMake(CGRectGetMaxX(label.frame)+5, (CGRectGetHeight(_contentView.frame)-11)/2, 7, 11)];
	
	CPTouchActionView *btn = [[CPTouchActionView alloc] init];
	[btn setFrame:_contentView.bounds];
	[btn setActionType:CPButtonActionTypeOpenSubview];
	[btn setActionItem:self.item[@"linkUrl"]];
	[btn setWiseLogCode:@"MAH0300"];
	[_contentView addSubview:btn];
	
	[btn setAccessibilityLabel:label.text Hint:@""];
	
	[_lineView setFrame:CGRectMake(_contentView.frame.origin.x,
								   CGRectGetMaxY(_contentView.frame),
								   _contentView.frame.size.width,
								   1)];
}

@end
