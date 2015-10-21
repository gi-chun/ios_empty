//
//  CPTotalBillBannerTitleCell.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTotalBillBannerTitleCell.h"

@interface CPTotalBillBannerTitleCell()
{
	UILabel *_titleLabel;
}

@end

@implementation CPTotalBillBannerTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor clearColor];
	self.contentView.backgroundColor = [UIColor clearColor];
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textColor = UIColorFromRGB(0xffffff);
	_titleLabel.font = [UIFont boldSystemFontOfSize:19];
	_titleLabel.numberOfLines = 1;
	[self.contentView addSubview:_titleLabel];
}

- (void)layoutSubviews
{
	self.contentView.frame = self.bounds;
	
	CGRect viewRt = self.bounds;
	
	_titleLabel.text = self.item[@"billBannerGroupTitle"];
	[_titleLabel sizeToFitWithVersion];
	
	_titleLabel.frame = CGRectMake((viewRt.size.width/2)-(_titleLabel.frame.size.width/2),
								   (viewRt.size.height/2)-(_titleLabel.frame.size.height/2),
								   _titleLabel.frame.size.width, _titleLabel.frame.size.height);
	
}

@end
