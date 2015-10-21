//
//  CPPriceDetailSatisfyScoreCell.m
//  11st
//
//  Created by 김응학 on 2015. 7. 9..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPPriceDetailSatisfyScoreCell.h"

@interface CPPriceDetailSatisfyScoreCell ()
{
    UIView *_contentView;
    UIView *_lineView;
}

@end

@implementation CPPriceDetailSatisfyScoreCell

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
    
    CGFloat offsetY = 0.f;
    
    NSInteger satisfyScore = [_item[@"satisfyScore"] integerValue];
    NSInteger femaleScore = [_item[@"femaleScore"] integerValue];
    
    //만족, 불만족
    UIView *satisfyBarView = [self drawSatisfyBarGraphWithLeftText:@"만족"
                                                         LeftColor:UIColorFromRGB(0x38adff)
                                                         RightText:@"불만"
                                                        RightColor:UIColorFromRGB(0x8b8b8b)
                                                      satisfyValue:satisfyScore];
    
    CGRect satisfyBarFrame = satisfyBarView.frame;
    satisfyBarFrame.origin.y = offsetY;
    satisfyBarView.frame = satisfyBarFrame;
    [_contentView addSubview:satisfyBarView];
    
    offsetY = CGRectGetMaxY(satisfyBarView.frame);
    
    //여자, 남자
    UIView *femaleBarView = [self drawSatisfyBarGraphWithLeftText:@"여성"
                                                         LeftColor:UIColorFromRGB(0xf86767)
                                                         RightText:@"남성"
                                                        RightColor:UIColorFromRGB(0x426edc)
                                                      satisfyValue:femaleScore];
    
    CGRect femaleBarFrame = femaleBarView.frame;
    femaleBarFrame.origin.y = offsetY;
    femaleBarView.frame = femaleBarFrame;
    [_contentView addSubview:femaleBarView];
    
    offsetY = CGRectGetMaxY(femaleBarView.frame);
    
    //연령별 그래프
    UIView *ageBarView = [self drawAgeScoreGraphWithScore10:[_item[@"age10Score"] integerValue]
                                                    Score20:[_item[@"age20Score"] integerValue]
                                                    Score30:[_item[@"age30Score"] integerValue]
                                                    Score40:[_item[@"age40Score"] integerValue]];

    CGRect ageBarFrame = ageBarView.frame;
    ageBarFrame.origin.y = offsetY;
    ageBarView.frame = ageBarFrame;
    [_contentView addSubview:ageBarView];

    
    _lineView.frame = CGRectMake(_contentView.frame.origin.x, self.frame.size.height-1, _contentView.frame.size.width, 1);
}

- (UIView *)drawSatisfyBarGraphWithLeftText:(NSString *)lText
                                  LeftColor:(UIColor *)lColor
                                  RightText:(NSString *)rText
                                 RightColor:(UIColor *)rColor
                               satisfyValue:(NSInteger)score
{
    UIView *graphView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, 61)];
    
    CGFloat margin = 40;
    CGFloat barWidth = _contentView.frame.size.width - (margin * 2);
    CGFloat colorBarWidth = (barWidth * 0.01) * score;
    
    UIView *backBarView = [[UIView alloc] initWithFrame:CGRectMake(margin, (graphView.frame.size.height/2)-12, barWidth, 23)];
    backBarView.backgroundColor = rColor;
    [graphView addSubview:backBarView];
    
    UIView *colorBarView = [[UIView alloc] initWithFrame:CGRectMake(margin, backBarView.frame.origin.y,
                                                                    colorBarWidth, backBarView.frame.size.height)];
    colorBarView.backgroundColor = lColor;
    [graphView addSubview:colorBarView];
    
    //Left Label
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = UIColorFromRGB(0x333333);
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.text = lText;
    [leftLabel sizeToFitWithVersion];
    [graphView addSubview:leftLabel];
    
    leftLabel.frame = CGRectMake(margin-7-leftLabel.frame.size.width,
                                 (graphView.frame.size.height/2)-(leftLabel.frame.size.height/2),
                                 leftLabel.frame.size.width, leftLabel.frame.size.height);

    //right Label
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.textColor = UIColorFromRGB(0x333333);
    rightLabel.font = [UIFont systemFontOfSize:14];
    rightLabel.text = rText;
    [rightLabel sizeToFitWithVersion];
    [graphView addSubview:rightLabel];
    
    rightLabel.frame = CGRectMake(CGRectGetMaxX(backBarView.frame)+7,
                                  (graphView.frame.size.height/2)-(rightLabel.frame.size.height/2),
                                  rightLabel.frame.size.width, rightLabel.frame.size.height);
    
    //left Score
    if (score >= 10) {
        UILabel *leftScoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        leftScoreLabel.backgroundColor = [UIColor clearColor];
        leftScoreLabel.textColor = UIColorFromRGB(0xffffff);
        leftScoreLabel.font = [UIFont systemFontOfSize:14];
        leftScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
        [leftScoreLabel sizeToFitWithVersion];
        [graphView addSubview:leftScoreLabel];
        
        leftScoreLabel.frame = CGRectMake(margin+5,
                                          (graphView.frame.size.height/2)-(leftScoreLabel.frame.size.height/2),
                                          leftScoreLabel.frame.size.width, leftScoreLabel.frame.size.height);
    }

    //right Score
    if (score <= 90) {
        UILabel *rightScoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        rightScoreLabel.backgroundColor = [UIColor clearColor];
        rightScoreLabel.textColor = UIColorFromRGB(0xffffff);
        rightScoreLabel.font = [UIFont systemFontOfSize:14];
        rightScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)(100-score)];
        [rightScoreLabel sizeToFitWithVersion];
        [graphView addSubview:rightScoreLabel];
        
        rightScoreLabel.frame = CGRectMake(CGRectGetMaxX(backBarView.frame)-5-rightScoreLabel.frame.size.width,
                                          (graphView.frame.size.height/2)-(rightScoreLabel.frame.size.height/2),
                                          rightScoreLabel.frame.size.width, rightScoreLabel.frame.size.height);
    }
    
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, graphView.frame.size.height-1, graphView.frame.size.width, 1)];
    underLine.backgroundColor = UIColorFromRGB(0xededed);
    [graphView addSubview:underLine];
    
    return graphView;
}

- (UIView *)drawAgeScoreGraphWithScore10:(NSInteger)score10
                                 Score20:(NSInteger)score20
                                 Score30:(NSInteger)score30
                                 Score40:(NSInteger)score40
{
    UIView *graphView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, 181)];

    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(16, 39+(19*5), graphView.frame.size.width-32, 1)];
    bottomLine.backgroundColor = UIColorFromRGB(0x73747a);
    [graphView addSubview:bottomLine];
    
    CGFloat lineOffsetY = 39;
    NSInteger lineNumber = 100;
    for (NSInteger i=0; i<5; i++) {
        UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(36, lineOffsetY, _contentView.frame.size.width-(36+16), 1)];
        horizontalLine.backgroundColor = UIColorFromRGB(0xf2f2f3);
        [graphView addSubview:horizontalLine];
        
        if (i % 2 == 0) {
            //그래프 앞 숫자
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = UIColorFromRGB(0x6c6e7f);
            label.font = [UIFont systemFontOfSize:11];
            label.text = [NSString stringWithFormat:@"%ld", (long)lineNumber];
            [label sizeToFitWithVersion];
            [graphView addSubview:label];
            
            label.frame = CGRectMake(36-2-label.frame.size.width,
                                     lineOffsetY-(label.frame.size.height/2),
                                     label.frame.size.width,
                                     label.frame.size.height);
            
            lineNumber = lineNumber - 40;
        }
        
        lineOffsetY += 19;
    }
    
    //그래프 중점
    CGFloat graphPointWidth = (_contentView.frame.size.width-(36+16)) / 5;
    CGFloat graphPointOffsetX = 36;
    CGFloat graphMaxHeight = 19*5;

    for (NSInteger i=0; i<4; i++) {
        
        NSInteger score = 0;
        NSString *ageStr = @"";
        
        if (i == 0)         score = score10, ageStr = @"10대";
        else if (i == 1)    score = score20, ageStr = @"20대";
        else if (i == 2)    score = score30, ageStr = @"30대";
        else if (i == 3)    score = score40, ageStr = @"40대이상";
        
        CGFloat viewX = graphPointOffsetX + ((graphPointWidth * (i+1)) - 21);
        CGFloat viewY = 39 + ((graphMaxHeight * 0.01) * (100-score));
        CGFloat viewW = 42;
        CGFloat viewH = (graphMaxHeight * 0.01) * score;
        
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        if (i == 0)         barView.backgroundColor = UIColorFromRGB(0x60c1ff);
        else if (i == 1)    barView.backgroundColor = UIColorFromRGB(0xff8a81);
        else if (i == 2)    barView.backgroundColor = UIColorFromRGB(0x62d2e0);
        else if (i == 3)    barView.backgroundColor = UIColorFromRGB(0x8d96e3);
        [graphView addSubview:barView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UIColorFromRGB(0x333333);
        label.font = [UIFont systemFontOfSize:13];
        label.text = ageStr;
        [label sizeToFitWithVersion];
        [graphView addSubview:label];
        
        label.frame = CGRectMake((graphPointOffsetX + (graphPointWidth * (i+1)))-(label.frame.size.width/2),
                                 39 + graphMaxHeight + 10,
                                 label.frame.size.width,
                                 label.frame.size.height);
        
        UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.textColor = UIColorFromRGB(0x333333);
        scoreLabel.font = [UIFont systemFontOfSize:13];
        scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
        [scoreLabel sizeToFitWithVersion];
        [graphView addSubview:scoreLabel];
        
        scoreLabel.frame = CGRectMake((viewX+21)-(scoreLabel.frame.size.width/2),
                                      viewY-scoreLabel.frame.size.height-10,
                                      scoreLabel.frame.size.width,
                                      scoreLabel.frame.size.height);
        
        //말풍선 이미지 그리기
        UIImage *imgBallonBody = [UIImage imageNamed:@"ballon_body.png"];
        UIImage *imgBallontail = [UIImage imageNamed:@"ballon_tail.png"];
        
        imgBallonBody = [imgBallonBody resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 11)];
        
        UIImageView *ballonBodyView = [[UIImageView alloc] initWithFrame:CGRectMake(scoreLabel.center.x-((scoreLabel.frame.size.width/2)+4),
                                                                                    scoreLabel.center.y-((scoreLabel.frame.size.height/2)+2),
                                                                                    ((scoreLabel.frame.size.width/2)+4)*2,
                                                                                    ((scoreLabel.frame.size.height/2)+2)*2)];
        ballonBodyView.image = imgBallonBody;
        [graphView addSubview:ballonBodyView];
        
        UIImageView *ballonTailView = [[UIImageView alloc] initWithFrame:CGRectMake(scoreLabel.center.x-(imgBallontail.size.width/2),
                                                                                    CGRectGetMaxY(ballonBodyView.frame),
                                                                                    imgBallontail.size.width, imgBallontail.size.height)];
        ballonTailView.image = imgBallontail;
        [graphView addSubview:ballonTailView];
        
        [graphView bringSubviewToFront:scoreLabel];
        
    }
    
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, graphView.frame.size.height-1, graphView.frame.size.width, 1)];
    underLine.backgroundColor = UIColorFromRGB(0xd8d7dd);
    [graphView addSubview:underLine];

    return graphView;
}

@end
