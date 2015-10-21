//
//  CPPriceDetailSaleGraphCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailSaleGraphCell.h"
#import "AccessLog.h"

@interface CPPriceDetailSaleGraphCell ()
{
    UIView *_contentView;
    UIView *_lineView;
}

@end

@implementation CPPriceDetailSaleGraphCell

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
    _lineView.backgroundColor = UIColorFromRGB(0xd7d7d7);
    [self.contentView addSubview:_lineView];
}

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.bounds;
    
    _contentView.frame = CGRectMake(10, 0, self.contentView.frame.size.width-20.f, self.contentView.frame.size.height-1);
    
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    //버튼영역
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, _contentView.frame.size.width-20, 36)];
    [_contentView addSubview:buttonView];
    
    UIImage *buttonBG = [UIImage imageNamed:@"tab_pd_review_bg.png"];
    buttonBG = [buttonBG resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 18)];
    
    UIImageView *buttonBgView = [[UIImageView alloc] initWithFrame:buttonView.bounds];
    buttonBgView.image = buttonBG;
    [buttonView addSubview:buttonBgView];
    
    NSArray *items = _item[@"items"];
    NSInteger buttonWidth = (NSInteger)(buttonView.frame.size.width / [items count]);
    for (NSInteger i=0; i<[items count]; i++) {
        
        NSString *imageName = @"";
        NSString *selected = items[i][@"selected"];
        
        if (i == 0)                         imageName = @"tab_pd_review_01.png";
        else if (i == [items count]-1)      imageName = @"tab_pd_review_02.png";
        else                                imageName = @"tab_price_graph_center.png";
        
        UIImage *selectedImage = [UIImage imageNamed:imageName];
        selectedImage = [selectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 18)];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(buttonWidth * i, 0,
                               (i != [items count]-1 ? buttonWidth : buttonView.frame.size.width-(buttonWidth * i)),
                               buttonView.frame.size.height);
        [btn setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
        [btn setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [btn setTitle:items[i][@"title"] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
        [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn setTag:i];
        [btn addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:btn];
        
        if (i != [items count]-1) {
            UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(btn.frame.size.width-1, 0, 1, btn.frame.size.height)];
            middleLine.backgroundColor = UIColorFromRGBA(0xe6e6e6, 0.7);
            [btn addSubview:middleLine];
        }
        
        if ([selected isEqualToString:@"Y"])    btn.selected = YES;
        else                                    btn.selected = NO;
    }
    
    NSInteger selectedIdx = 0;
    for (NSInteger i=0; i<[items count]; i++) {
        NSString *selected = items[i][@"selected"];
        
        if ([selected isEqualToString:@"Y"]) {
            selectedIdx = i;
            break;
        }
    }

    CGFloat maxScore = 0;
    for (NSInteger i=0; i<[items count]; i++) {
        NSArray *countList = items[i][@"countList"];
        for (NSInteger j=0; j<[countList count]; j++) {
            NSInteger score = [countList[j] intValue];
            
            if (maxScore <= score)
            {
                maxScore = score;
            }
        }
    }

    NSDictionary *dataDict = items[selectedIdx];
    UIView *graphView = [self drawGraphWithFrame:CGRectMake(10, CGRectGetMaxY(buttonView.frame)+5,
                                                            _contentView.frame.size.width-20,
                                                            _contentView.frame.size.height-(CGRectGetMaxY(buttonView.frame)+5))
                                            data:dataDict
                                        maxScore:maxScore];
    [_contentView addSubview:graphView];
    
    
    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, self.frame.size.height-1, _contentView.frame.size.width, 1);
}

- (void)onTouchButton:(id)sender
{
    if ([sender tag] == 0) {
        //2주
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDM02"];
    }
    else if ([sender tag] == 1) {
        //1개월
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDM03"];
    }
    else if ([sender tag] == 2) {
        //3개월
        [[AccessLog sharedInstance] sendAccessLogWithCode:@"ASRPDMDM04"];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(saleGraphCellSelectedIndex:)]) {
        [self.delegate saleGraphCellSelectedIndex:[sender tag]];
    }
}

- (UIView *)drawGraphWithFrame:(CGRect)frame data:(NSDictionary *)dataDict maxScore:(NSInteger)maxScore
{
    NSArray *dateList = dataDict[@"dateList"];
    NSArray *countList = dataDict[@"countList"];
    
    UIView *graphView = [[UIView alloc] initWithFrame:frame];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(6, graphView.frame.size.height-40, graphView.frame.size.width-12, 1)];
    bottomLine.backgroundColor = UIColorFromRGB(0x73747a);
    [graphView addSubview:bottomLine];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(6, bottomLine.frame.origin.y-100, graphView.frame.size.width-12, 1)];
    topLine.backgroundColor = UIColorFromRGB(0xf2f2f3);
    [graphView addSubview:topLine];
    
    NSInteger topOffsetY = topLine.frame.origin.y;
    NSInteger graphOffsetX = (!IS_IPAD ? 20 : 40);
    NSInteger graphWidth = bottomLine.frame.size.width-(graphOffsetX * 2);
    NSInteger graphMaxHeight = CGRectGetMaxY(bottomLine.frame)-CGRectGetMaxY(topLine.frame);
    NSInteger graphBarWidth = graphWidth / [countList count];
    
    CGFloat lineX = graphOffsetX + 6;
    for (NSInteger i=0; i<[dateList count]; i++)
    {
        NSString *dateTaxt = dateList[i];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UIColorFromRGB(0x333333);
        label.font = [UIFont systemFontOfSize:12];
        label.text = dateTaxt;
        [label sizeToFitWithVersion];
        [graphView addSubview:label];
        
        label.frame = CGRectMake(lineX - (label.frame.size.width/2),
                                 bottomLine.frame.origin.y+9,
                                 label.frame.size.width,
                                 label.frame.size.height);
        
        UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(lineX, topOffsetY, 1, graphMaxHeight)];
        middleLine.backgroundColor = UIColorFromRGB(0xe6e6e6);
        [graphView addSubview:middleLine];
        
        lineX += graphBarWidth;
    }

    CGFloat maxNumIndex = 0;
    CGFloat currentAreaMaxScore = 0;
    for (NSInteger i=0; i<[countList count]; i++) {
        NSInteger score = [countList[i] intValue];
        
        if (currentAreaMaxScore <= score)
        {
            currentAreaMaxScore = score;
            maxNumIndex = i;
        }
    }
    
    lineX = graphOffsetX + 6;
    CGFloat graphTopOffset = topOffsetY + ((graphMaxHeight * 0.01) * 10);
    graphMaxHeight = graphMaxHeight - ((graphMaxHeight * 0.01) * 10);
    
    for (NSInteger i=0; i<[countList count]; i++) {
        NSInteger score = [countList[i] intValue];
        
        NSInteger per = ((CGFloat)score / (CGFloat)maxScore) * 100.f;
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(lineX,
                                                                   graphTopOffset + (graphMaxHeight * 0.01) * (100 - per),
                                                                   graphBarWidth,
                                                                   (graphMaxHeight * 0.01) * per)];
        barView.backgroundColor = (maxNumIndex == i ? UIColorFromRGBA(0x0084ff, 0.3) : UIColorFromRGBA(0x60c1ff, 0.3));
        [graphView addSubview:barView];
        
        UIView *pointLine = [[UIView alloc] initWithFrame:CGRectMake(lineX, barView.frame.origin.y, barView.frame.size.width, 1)];
        pointLine.backgroundColor = UIColorFromRGB(0x53aef4);
        [graphView addSubview:pointLine];
        
        if (i == maxNumIndex) {
            UILabel *maxScoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            maxScoreLabel.backgroundColor = [UIColor clearColor];
            maxScoreLabel.textColor = UIColorFromRGB(0x666666);
            maxScoreLabel.font = [UIFont systemFontOfSize:14];
            maxScoreLabel.text = [Modules numberFormat:score];
            [maxScoreLabel sizeToFitWithVersion];
            [graphView addSubview:maxScoreLabel];
            
            maxScoreLabel.frame = CGRectMake(pointLine.center.x-(maxScoreLabel.frame.size.width/2),
                                             barView.frame.origin.y-3-23,
                                             maxScoreLabel.frame.size.width,
                                             maxScoreLabel.frame.size.height);
            
            UIImage *imgBallonBody = [UIImage imageNamed:@"ballon_body.png"];
            UIImage *imgBallontail = [UIImage imageNamed:@"ballon_tail.png"];
            
            imgBallonBody = [imgBallonBody resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 11)];
            
            UIImageView *ballonBodyView = [[UIImageView alloc] initWithFrame:CGRectMake(maxScoreLabel.center.x-((maxScoreLabel.frame.size.width/2)+4),
                                                                                        maxScoreLabel.center.y-((maxScoreLabel.frame.size.height/2)+2),
                                                                                        ((maxScoreLabel.frame.size.width/2)+4)*2,
                                                                                        ((maxScoreLabel.frame.size.height/2)+2)*2)];
            ballonBodyView.image = imgBallonBody;
            [graphView addSubview:ballonBodyView];
            
            UIImageView *ballonTailView = [[UIImageView alloc] initWithFrame:CGRectMake(maxScoreLabel.center.x-(imgBallontail.size.width/2),
                                                                                        CGRectGetMaxY(ballonBodyView.frame),
                                                                                        imgBallontail.size.width, imgBallontail.size.height)];
            ballonTailView.image = imgBallontail;
            [graphView addSubview:ballonTailView];
            
            [graphView bringSubviewToFront:maxScoreLabel];
        }
        
        lineX = lineX + graphBarWidth;
    }
    
    [graphView bringSubviewToFront:bottomLine];
    
    return graphView;
}

@end

