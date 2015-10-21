//
//  CPHomeTotalBillBannerView.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeTotalBillBannerView.h"
#import "CPTotalBillBannerTitleCell.h"
#import "CPTotalBillGroupBannerCell.h"
#import "CPTotalBillGroupBannerButtonListCell.h"

@interface CPHomeTotalBillBannerView () <UITableViewDataSource, UITableViewDelegate >
{
	UITableView *_tableView;
	UIButton *_closeButton;
	UIButton *_topScrollButton;
}

@end

@implementation CPHomeTotalBillBannerView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = UIColorFromRGBA(0x000000, 0.8);
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero];
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.separatorColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self addSubview:_tableView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_closeButton addTarget:self action:@selector(onTouchCloseButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_closeButton];

	_topScrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_topScrollButton setImage:[UIImage imageNamed:@"btn_top.png"] forState:UIControlStateNormal];
	[_topScrollButton addTarget:self action:@selector(onTouchTopScroll) forControlEvents:UIControlEventTouchUpInside];
	[_topScrollButton setAccessibilityLabel:@"위로" Hint:@"화면을 위로 이동합니다"];
	[_topScrollButton setHidden:YES];
	[self addSubview:_topScrollButton];
}

- (void)layoutSubviews {
	CGFloat screenWidth = (IS_IPAD ? 360 : self.frame.size.width-20);
	
	_tableView.frame = self.bounds;
	_closeButton.frame = CGRectMake(((self.frame.size.width/2)+(screenWidth/2))-40, 0, 40, 40);
	
	[_closeButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(0x000000, 0.2f)
													  width:_closeButton.frame.size.width
													 height:_closeButton.frame.size.height]
							forState:UIControlStateNormal];
	[_closeButton setImage:[UIImage imageNamed:@"bt_billboard_close.png"] forState:UIControlStateNormal];
	
	_topScrollButton.frame = CGRectMake(self.frame.size.width-(self.frame.size.width/7), self.frame.size.height-50, (self.frame.size.width/7), 45);
	
	[_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	NSString *groupName = self.items[indexPath.row][@"groupName"];
	if ([groupName isEqualToString:@"billGroupBannerTitle"]) {
		cell = (UITableViewCell *)[self makeBillGroupBannerTitleCell:tableView indexPath:indexPath];
	}
	else if ([groupName isEqualToString:@"billGroupBanner"]) {
		cell = (UITableViewCell *)[self makeBillGroupBannerCell:tableView indexPath:indexPath];
	}
	else if ([groupName isEqualToString:@"billGroupBannerButtonList"]) {
		cell = (UITableViewCell *)[self makeBillGroupBannerButtonListCell:tableView indexPath:indexPath];
	}
	else {
		cell = (UITableViewCell *)[self makeDefaultCell:tableView indexPath:indexPath];
	}
		
	return cell;
}

- (UITableViewCell *)makeBillGroupBannerTitleCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"billGroupBannerTitle";
	
	CPTotalBillBannerTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	
	if (!cell) {
		cell = [[CPTotalBillBannerTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width,
							[self tableView:tableView heightForRowAtIndexPath:indexPath]);
	
	cell.item = _items[indexPath.row][@"billGroupBannerTitle"];
	
	return cell;
}

- (UITableViewCell *)makeBillGroupBannerCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"billGroupBanner";
	
	CPTotalBillGroupBannerCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	
	if (!cell) {
		cell = [[CPTotalBillGroupBannerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width,
							[self tableView:tableView heightForRowAtIndexPath:indexPath]);
	
	cell.item = _items[indexPath.row][@"billGroupBanner"];
    cell.wiseLogCode = @"MAJ0103";
	
	return cell;
}

- (UITableViewCell *)makeBillGroupBannerButtonListCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"billGroupBannerButtonList";
	
	CPTotalBillGroupBannerButtonListCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	
	if (!cell) {
		cell = [[CPTotalBillGroupBannerButtonListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width,
							[self tableView:tableView heightForRowAtIndexPath:indexPath]);
	
	cell.items = _items[indexPath.row][@"billGroupBannerButtonList"];
	
	return cell;
}

- (UITableViewCell *)makeDefaultCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	NSString *ideneifier = @"defaultCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideneifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width,
							[self tableView:tableView heightForRowAtIndexPath:indexPath]);
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 0.f;
	
	CGFloat screenWidth = (IS_IPAD ? 360 : tableView.frame.size.width-20);
	
	NSString *groupName = self.items[indexPath.row][@"groupName"];
	if ([groupName isEqualToString:@"billGroupBannerTitle"]) {
		height = 40;
	}
	else if ([groupName isEqualToString:@"billGroupBanner"]) {
		height = [Modules getRatioHeight:CGSizeMake(340, 170) screebWidth:screenWidth] + 1;
	}
	else if ([groupName isEqualToString:@"billGroupBannerButtonList"]) {
		height = 45;
	}
	else {
		height = 0;
	}

	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_topScrollButton setHidden:0 < scrollView.contentOffset.y ? NO : YES];
}

- (void)onTouchCloseButton:(id)sender
{
	[self removeFromSuperview];
}

- (void)onTouchTopScroll
{
	[_tableView setContentOffset:CGPointZero animated:YES];
}

@end
