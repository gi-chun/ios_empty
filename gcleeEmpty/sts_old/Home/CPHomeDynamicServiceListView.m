//
//  CPHomeDynamicServiceListView.m
//  11st
//
//  Created by saintsd on 2015. 7. 1..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPHomeDynamicServiceListView.h"
#import "CPThumbnailView.h"
#import "UIImageView+WebCache.h"
#import "CPTouchActionView.h"

#define MARGIN	10

@interface CPHomeDynamicServiceListView ()
{
	NSArray *_items;
	NSInteger _columnCount;
	BOOL _isOpen;
	
	CGFloat _fullHeight;
	CGFloat _halfHeight;
}

@end

@implementation CPHomeDynamicServiceListView

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items columnCount:(NSInteger)columnCount isOpen:(BOOL)isOpen
{
	if (self = [super initWithFrame:frame])
	{
		if (items) _items = [[NSArray alloc] initWithArray:items];
		
		_columnCount = columnCount;
		_isOpen = isOpen;
		
		[self initSubviews];
	}
	return self;
}

- (void)initSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	self.clipsToBounds = YES;
	
	CGFloat buttonWidth = (self.frame.size.width-40-((_columnCount-1) * MARGIN)) / _columnCount;
	CGFloat buttonHeight = [Modules getRatioHeight:CGSizeMake(112, 112) screebWidth:buttonWidth];
	
	CGFloat offsetX = 20.f;
	CGFloat offsetY = 10.f;
	NSInteger count = 0;
	
	for (NSInteger i=0; i<[_items count]; i++) {
		UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, offsetY, buttonWidth, buttonHeight)];
		[self addSubview:itemView];
	
		CPThumbnailView *iconView = [[CPThumbnailView alloc] initWithFrame:itemView.bounds];
		[iconView.imageView sd_setImageWithURL:[NSURL URLWithString:_items[i][@"lnkBnnrImgUrl"]]];
		[itemView addSubview:iconView];
		
		CPTouchActionView *actionView = [[CPTouchActionView alloc] initWithFrame:itemView.bounds];
		actionView.actionType = CPButtonActionTypeOpenSubview;
		actionView.actionItem = _items[i][@"dispObjLnkUrl"];
        actionView.wiseLogCode = [self wiseLogCodeWithIndex:i itemCount:[_items count]];
        [actionView setAccessibilityLabel:_items[i][@"dispObjNm"] Hint:@""];
		[itemView addSubview:actionView];
		
		if (++count >= _columnCount) {
			count = 0;
			offsetX = 20;
			offsetY = offsetY + MARGIN + buttonHeight;
		}
		else {
			offsetX += (MARGIN + buttonWidth);
		}
	}

	NSInteger lineNum = (_items.count / _columnCount) + (_items.count % _columnCount != 0 ? 1 : 0);
	_fullHeight = (MARGIN * 2) + (buttonHeight * lineNum) + ((lineNum-1) * MARGIN);
	_halfHeight = (MARGIN * 2) + buttonHeight;
	
	if (self.frame.size.height == 0) {
		CGFloat frameHeight = (!_isOpen ? _halfHeight : _fullHeight);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frameHeight);
	}
}

- (void)setOpenYn:(BOOL)isOpen
{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (isOpen ? _fullHeight : _halfHeight));
}

- (NSString *)wiseLogCodeWithIndex:(NSInteger)index itemCount:(NSInteger)itemCount
{
    NSString *wiseLogCode = @"";
    
    if (itemCount == 10)
    {
        switch (index) {
            case 0:
                wiseLogCode = @"MAJ0201";
                break;
            case 1:
                wiseLogCode = @"MAJ0202";
                break;
            case 2:
                wiseLogCode = @"MAJ0203";
                break;
            case 3:
                wiseLogCode = @"MAJ0204";
                break;
            case 4:
                wiseLogCode = @"MAJ0205";
                break;
            case 5:
                wiseLogCode = @"MAJ0206";
                break;
            case 6:
                wiseLogCode = @"MAJ0207";
                break;
            case 7:
                wiseLogCode = @"MAJ0208";
                break;
            case 8:
                wiseLogCode = @"MAJ0209";
                break;
            case 9:
                wiseLogCode = @"MAJ0210";
                break;
            default:
                break;
        }
    }
    else
    {
        switch (index) {
            case 0:
                wiseLogCode = @"MAJ0201";
                break;
            case 1:
                wiseLogCode = @"MAJ0202";
                break;
            case 2:
                wiseLogCode = @"MAJ0203";
                break;
            case 3:
                wiseLogCode = @"MAJ0204";
                break;
            case 4:
                wiseLogCode = @"MAJ0205";
                break;
            case 5:
                wiseLogCode = @"MAJ0206";
                break;
            case 6:
                wiseLogCode = @"MAJ0207";
                break;
            case 7:
                wiseLogCode = @"MAJ0208";
                break;
            case 8:
                wiseLogCode = @"MAJ0209";
                break;
            case 9:
                wiseLogCode = @"MAJ0210";
                break;
            case 10:
                wiseLogCode = @"MAJ0211";
                break;
            case 11:
                wiseLogCode = @"MAJ0212";
                break;
            default:
                break;
        }
    }
    
    return wiseLogCode;
}

@end
