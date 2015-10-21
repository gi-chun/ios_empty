//
//  ProductSmartOptionContainerModel.h
//  ShockingDeal
//
//  Created by Hokun Baek on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductSmartOptionModel;

@interface ProductSmartOptionContainerModel : NSObject

@property (nonatomic, strong) NSArray *allItems;          // 헤더이미지 + 옵션 + 옵션 상세 + 푸터이미지
@property (nonatomic, strong) NSArray *detailOptions;     // 옵션 상세만
@property (nonatomic, strong) NSArray *realDetailOptions; // 옵션 상세만. grid 처리를 위해 Array를 한겹 씌워놓은 것을 풀어서

@property (nonatomic, assign) BOOL hasItem;

- (instancetype)initWithOptionInfo:(NSDictionary *)optionInfo;
- (instancetype)initWithProductImages:(NSArray *)images;
- (NSInteger)detailOptionIndexAtOption:(ProductSmartOptionModel *)option;

@end
