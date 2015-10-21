//
//  CPHotProductView.h
//  11st
//
//  Created by hjcho86 on 2015. 6. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPHotProductViewDelegate;

@interface CPHotProductView : UIView

@property (nonatomic, weak) id<CPHotProductViewDelegate> delegate;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (id)initWithFrame:(CGRect)frame hotProductInfo:(NSMutableDictionary *)aHotProductInfo listingType:(NSString *)listingType;

@end

@protocol CPHotProductViewDelegate <NSObject>
@optional

@end