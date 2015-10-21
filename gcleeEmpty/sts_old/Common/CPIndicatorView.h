//
//  CPIndicatorView.h
//  11st
//
//  Created by spearhead on 2014. 9. 25..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPIndicatorView : UIView

@property (nonatomic, assign) BOOL hidesWhenStopped;

- (void)startAnimating;
- (void)stopAnimating;

@end