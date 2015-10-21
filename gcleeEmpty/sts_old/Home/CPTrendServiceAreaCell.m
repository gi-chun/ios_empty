//
//  CPTrendServiceAreaCell.m
//  11st
//
//  Created by saintsd on 2015. 6. 12..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTrendServiceAreaCell.h"
#import "CPFooterButtonView.h"
#import "AppDelegate.h"
#import "CPHomeViewController.h"

@interface CPTrendServiceAreaCell () < CPFooterButtonViewDelegate >
{
	UIView *_contentView;
}

@end

@implementation CPTrendServiceAreaCell

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
}

- (void)layoutSubviews
{
	self.contentView.frame = self.bounds;
	_contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-10);
	
	for (UIView *subview in _contentView.subviews) {
		[subview removeFromSuperview];
	}

	CPFooterButtonView *areaView = [[CPFooterButtonView alloc] initWithFrame:_contentView.bounds];
	[areaView setType:CPFooterButtonUITypeNormal widthCount:self.columnCount];
	[areaView initData:self.items];
	[areaView setDelegate:self];
	[_contentView addSubview:areaView];
}

#pragma mark - CPFooterButtonViewDelegate
- (void)touchFooterItemButton:(NSString *)url
{
	if (url && [[url trim] length] > 0) {
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		CPHomeViewController *homeViewController = app.homeViewController;
		
		if ([homeViewController respondsToSelector:@selector(didTouchButtonWithUrl:)]) {
			[homeViewController didTouchButtonWithUrl:url];
		}
	}
}


@end
