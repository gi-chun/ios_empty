//
//  CPHomeShadowTitleView.m
//  11st
//
//  Created by saintsd on 2015. 6. 25..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeShadowTitleView.h"

#define TITLE_HEADER_HEIGHT			35

@interface CPHomeShadowTitleView ()
{
	NSDictionary *_item;
	UIFont *_font;
	UIColor *_tColor;
	UIColor *_sColor;
}

@end

@implementation CPHomeShadowTitleView

+ (CGSize)viewSizeWithData:(CGFloat)width
{
	return CGSizeMake(width, TITLE_HEADER_HEIGHT);
}

- (id)initWithFrame:(CGRect)frame item:(NSDictionary *)item font:(UIFont *)font textColor:(UIColor *)tColor shadowColor:(UIColor *)sColor
{
	if (self = [super initWithFrame:frame]) {
		
		if (item) _item = [[NSDictionary alloc] initWithDictionary:item];
		if (font) _font = font;
		if (tColor) _tColor = tColor;
		if (sColor) _sColor = sColor;
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	NSString *_title = _item[@"titleText"];
	
	//HeaderView
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TITLE_HEADER_HEIGHT)];
	[self addSubview:headerView];
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = _tColor;
	textLabel.textAlignment = NSTextAlignmentLeft;
	textLabel.font = _font;
	textLabel.text = _title;
	[textLabel sizeToFitWithVersion];
	[headerView addSubview:textLabel];
	
	textLabel.frame = CGRectMake((headerView.frame.size.width/2)-(textLabel.frame.size.width/2),
								 (headerView.frame.size.height/2)-(textLabel.frame.size.height/2)+2,
								 textLabel.frame.size.width, textLabel.frame.size.height);
	
	UILabel *shadowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	shadowLabel.backgroundColor = [UIColor clearColor];
	shadowLabel.textColor = _sColor;
	shadowLabel.textAlignment = NSTextAlignmentLeft;
	shadowLabel.font = _font;
	shadowLabel.text = _title;
	[shadowLabel sizeToFitWithVersion];
	[headerView addSubview:shadowLabel];
	
	shadowLabel.frame = CGRectMake(textLabel.frame.origin.x+1,
								   textLabel.frame.origin.y+1,
								   shadowLabel.frame.size.width, shadowLabel.frame.size.height);
	
	[headerView sendSubviewToBack:shadowLabel];
}

@end
