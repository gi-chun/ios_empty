//
//  CPIndicatorView.m
//

#import "CPIndicatorView.h"

@interface CPIndicatorView()

@property (nonatomic, strong) UIImageView *activityImageView;
@property (nonatomic, strong) NSTimer *indicatorTimer;

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) BOOL animating;

@end


@implementation CPIndicatorView

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 40.f, 40.f)])
    {
        [self setAnimating:YES];
        [self setHidesWhenStopped:YES];
        
        [self setBackgroundColor:[UIColor clearColor]];
//        [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.8f)];
        
        UIImage *indicatorImage = [UIImage imageNamed:@"list_indicator.png"];
        UIImageView *activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        self.activityImageView = activityImageView;
        
        [self.activityImageView setImage:indicatorImage];
        
        self.angle = 0;
        
        [self addSubview:self.activityImageView];
    }
    
    return self;
}

- (void)startAnimating
{
    self.animating = YES;
    self.hidden = NO;
    
    if (self.indicatorTimer == nil) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.02f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
        
        self.indicatorTimer = timer;
    }
    
    [[NSRunLoop currentRunLoop] addTimer:self.indicatorTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimating
{
    self.animating = NO;
    self.hidden = self.hidesWhenStopped;
    self.angle = 0;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    
    [self.activityImageView setTransform:transform];
    
    if (self.indicatorTimer) {
        [self.indicatorTimer invalidate];
        self.indicatorTimer = nil;
    }
}

- (void)handleTimer:(NSTimer *)timer
{
    if (self.animating) self.angle += 0.13f;
    if (self.angle > 6.283f) self.angle = 0;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(self.angle);
    
    [self.activityImageView setTransform:transform];
}

@end