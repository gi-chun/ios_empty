//
//  CPEventWinnerView.m
//  11st
//
//  Created by saintsd on 2015. 6. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPEventWinnerView.h"
#import "AccessLog.h"

@interface CPEventWinnerView ()
{
	NSArray *_items;
}

@end

@implementation CPEventWinnerView

+ (CGFloat)getViewHeight:(NSArray *)items
{
	CGFloat height = 0.f;
	
	for (NSInteger i=0; i<[items count]; i++) {
		
		NSString *groupName = items[i][@"groupName"];
		
		if ([@"eventWinnerHeader" isEqualToString:groupName]) {
			height += 40.f;
		}
		else if ([@"eventWinnerList" isEqualToString:groupName]) {
			NSArray *eventWinnerList = items[i][groupName];
			
			height += ([eventWinnerList count] * 30.f);
		}
	}
	
	return height;
}

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
	for (NSInteger i=0; i<[_items count]; i++) {
		
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"eventWinnerHeader" isEqualToString:groupName]) {
			UIView *headerView = [self getHeaderViewItem:_items[i][groupName] frame:CGRectMake(0, 0, self.frame.size.width, 40.f)];
			[self addSubview:headerView];
		}
		else if ([@"eventWinnerList" isEqualToString:groupName]) {
			NSArray *list = _items[i][groupName];

			for (NSInteger j=0; j<[list count]; j++) {
				UIView *listItem = [self getListViewItem:list[j] frame:CGRectMake(0, 40 + (j * 30), self.frame.size.width, 30.f) index:j];
				[self addSubview:listItem];
			}
		}
	}
}

- (UIView *)getHeaderViewItem:(NSDictionary *)dict frame:(CGRect)frame
{
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = UIColorFromRGB(0xffffff);

	//arrow
	UIImage *imgIcon = [UIImage imageNamed:@"bt_arrow_more.png"];
	UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-15.f-imgIcon.size.width,
																		  (frame.size.height/2)-(imgIcon.size.height/2),
																		  imgIcon.size.width, imgIcon.size.height)];
	iconView.image = imgIcon;
	[view addSubview:iconView];

	//title
	NSString *text = dict[@"text"];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, frame.size.width-(15+6+iconView.frame.size.width+15), 0)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = UIColorFromRGB(0x444444);
	label.font = [UIFont systemFontOfSize:15];
	label.numberOfLines = 1;
	label.textAlignment = NSTextAlignmentLeft;
	label.text = text;
	[label sizeToFitWithVersionHoldWidth];
	[view addSubview:label];
	
	label.frame = CGRectMake(15, (frame.size.height/2)-(label.frame.size.height/2), label.frame.size.width, label.frame.size.height);
	
	//bottomLine
	UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-1, frame.size.width, 1)];
	bottomLine.backgroundColor = UIColorFromRGB(0xf0f2f3);
	[view addSubview:bottomLine];
	
	UIButton *touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[touchButton setFrame:view.bounds];
	[touchButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
													  width:view.frame.size.width
													 height:view.frame.size.height]
						   forState:UIControlStateHighlighted];
	[touchButton addTarget:self action:@selector(onTouchHeaderView:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:touchButton];
	
	[touchButton setAccessibilityLabel:text Hint:@""];
	
	return view;
}

- (UIView *)getListViewItem:(NSDictionary *)dict frame:(CGRect)frame index:(NSInteger)index
{
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = UIColorFromRGB(0xffffff);
	
	NSString *dateStr = dict[@"createDt"];
	NSString *text = dict[@"text"];
	
	//date
	UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.textColor = UIColorFromRGB(0x999999);
	dateLabel.font = [UIFont systemFontOfSize:14];
	dateLabel.numberOfLines = 1;
	dateLabel.textAlignment = NSTextAlignmentLeft;
	dateLabel.text = dateStr;
	[dateLabel sizeToFitWithVersion];
	[view addSubview:dateLabel];
	
	dateLabel.frame = CGRectMake(frame.size.width-15-dateLabel.frame.size.width,
								 (frame.size.height/2)-(dateLabel.frame.size.height/2),
								 dateLabel.frame.size.width, dateLabel.frame.size.height);
	
	//text
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, frame.size.width-15-5-dateLabel.frame.size.width-15, 0)];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textColor = UIColorFromRGB(0x666666);
	textLabel.font = [UIFont systemFontOfSize:14];
	textLabel.numberOfLines = 1;
	textLabel.textAlignment = NSTextAlignmentLeft;
	textLabel.text = text;
	[textLabel sizeToFitWithVersionHoldWidth];
	[view addSubview:textLabel];
	
	textLabel.frame = CGRectMake(15, (frame.size.height/2)-(textLabel.frame.size.height/2),
								 textLabel.frame.size.width, textLabel.frame.size.height);
	
	UIButton *touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[touchButton setFrame:view.bounds];
	[touchButton setTag:index];
	[touchButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.3)
													  width:view.frame.size.width
													 height:view.frame.size.height]
						   forState:UIControlStateHighlighted];
	[touchButton addTarget:self action:@selector(onTouchListItem:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:touchButton];
	
	[touchButton setAccessibilityLabel:text Hint:@""];
	
	return view;
}

- (void)onTouchHeaderView:(id)sender
{
	NSString *linkUrl = @"";
	for (NSInteger i=0; i<[_items count]; i++) {
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"eventWinnerHeader" isEqualToString:groupName]) {
			linkUrl = _items[i][groupName][@"linkUrl"];
		}
	}

	if ([linkUrl length] > 0) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(touchEventWinnerViewItemButton:)]) {
			[self.delegate touchEventWinnerViewItemButton:linkUrl];
		}
		
		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0500"];
	}
}

- (void)onTouchListItem:(id)sender
{
	NSInteger tag = [sender tag];
	
	NSString *linkUrl = @"";
	for (NSInteger i=0; i<[_items count]; i++) {
		NSString *groupName = _items[i][@"groupName"];
		
		if ([@"eventWinnerList" isEqualToString:groupName]) {
			linkUrl = _items[i][groupName][tag][@"linkUrl"];
		}
	}

	if ([linkUrl length] > 0) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(touchEventWinnerViewItemButton:)]) {
			[self.delegate touchEventWinnerViewItemButton:linkUrl];
		}
		
		[[AccessLog sharedInstance] sendAccessLogWithCode:@"MAN0501"];
	}
}

@end
