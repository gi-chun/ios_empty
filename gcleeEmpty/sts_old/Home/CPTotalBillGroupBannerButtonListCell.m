//
//  CPTotalBillGroupBannerButtonListCell.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPTotalBillGroupBannerButtonListCell.h"
#import "CPTouchActionView.h"

@interface CPTotalBillGroupBannerButtonListCell ()
{
	UIView *buttonView;
}

@end

@implementation CPTotalBillGroupBannerButtonListCell

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

	buttonView = [[UIView alloc] initWithFrame:CGRectZero];
	buttonView.backgroundColor = UIColorFromRGB(0xe5e5e5);
	[self.contentView addSubview:buttonView];
}

- (void)layoutSubviews
{
	self.contentView.frame = self.bounds;
	
	CGRect viewRt = self.bounds;
	
	CGFloat screenWidth = (IS_IPAD ? 360 : self.frame.size.width-20);
	buttonView.frame = CGRectMake((viewRt.size.width/2)-(screenWidth/2), 0, screenWidth, 40);

	NSInteger buttonWidth = (NSInteger)(buttonView.frame.size.width / self.items.count)-1;
	NSInteger buttonHeight = 40.f;
	
	CGFloat offsetX = 0.f;
	for (NSInteger i=0; i<self.items.count; i++) {
		
		if (i == self.items.count-1) buttonWidth = screenWidth - offsetX;
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, buttonWidth, buttonHeight)];
		view.backgroundColor = [UIColor whiteColor];
		[buttonView addSubview:view];
		
		UIImage *arrowImage = [UIImage imageNamed:@"bt_home_arrow_contents.png"];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = UIColorFromRGB(0x311b92);
		label.font = [UIFont systemFontOfSize:15];
		label.text = self.items[i][@"text"];
		[label sizeToFitWithVersion];
		[view addSubview:label];
		
		label.frame = CGRectMake((buttonWidth/2)-((label.frame.size.width+6+arrowImage.size.width)/2),
								 (view.frame.size.height/2)-(label.frame.size.height/2),
								 label.frame.size.width, label.frame.size.height);
		
		UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame)+6, label.frame.origin.y+2,
																			   arrowImage.size.width, arrowImage.size.height)];
		arrowView.image = arrowImage;
		[view addSubview:arrowView];
		
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:view.bounds];
		actionView.actionType = CPButtonActionTypeOpenSubview;
		actionView.actionItem = self.items[i][@"linkUrl"];
		[view addSubview:actionView];
		
		offsetX += (buttonWidth + 1);
	}
}


@end
