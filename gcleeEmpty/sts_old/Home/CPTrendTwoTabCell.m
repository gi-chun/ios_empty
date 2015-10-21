//
//  CPTrendTwoTabCell.m
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendTwoTabCell.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"
#import "AccessLog.h"

@interface CPTrendTwoTabCell ()
{
	UIView *_contentView;
	UIView *_lineView;
}

@end

@implementation CPTrendTwoTabCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor clearColor];
	
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
	
	CGFloat itemWidth = _contentView.frame.size.width/2;
	CGFloat itemHeight = _contentView.frame.size.height;
	
	_contentView.backgroundColor = UIColorFromRGB(0xf4f4f4);
	
	for (NSInteger i=0; i<[self.items count]; i++) {
		
		NSString *btnTitle = self.items[i][@"title"];
		BOOL isSelected = [@"Y" isEqualToString:self.items[i][@"selected"]];
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(i * itemWidth, 0, (NSInteger)itemWidth, itemHeight)];
		[btn setTitle:btnTitle forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0x888888) forState:UIControlStateNormal];
		[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
		[btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
		[btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf4f4f4) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateNormal];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x00befa) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateHighlighted];
		
		[btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x00befa) width:btn.frame.size.width height:btn.frame.size.height]
					   forState:UIControlStateSelected];
		[btn setTag:i];
		[btn setSelected:isSelected];
		[btn addTarget:self action:@selector(onTouchSubStyleTwoTab:) forControlEvents:UIControlEventTouchUpInside];
		
		[_contentView addSubview:btn];
	}
	
	[_lineView setFrame:CGRectMake(_contentView.frame.origin.x,
								   CGRectGetMaxY(_contentView.frame),
								   _contentView.frame.size.width,
								   1)];
}

- (void)onTouchSubStyleTwoTab:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSString *key = self.items[tag][@"key"];
	if (key && [key length] > 0) {
		
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(goToPageAction:)]) {
			[homeViewController goToPageAction:key];
		}
	}
}


@end
