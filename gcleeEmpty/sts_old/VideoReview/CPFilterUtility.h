//
//  CPFilterUtility.h
//  11st
//
//  Created by spearhead on 2015. 1. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPGPUImage.h"

#define FW_ADD_SATURATION(value) \
saturation = value;

#define FW_ADD_BRIGHTNESS(value) \
brightness = value;

#define FW_ADD_CONTRAST(value) \
contrast = value;

#define FW_ADD_GRAY(value) \
gray = (value ? YES : NO);

#define FW_ADD_CURVE_DEFAULT(curve) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(0.f, 0.f)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(255.f, 255.f)]];

#define FW_ADD_CURVE_2(curve,c1x,c1y,c2x,c2y) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c1x, c1y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c2x, c2y)]];

#define FW_ADD_CURVE_3(curve,c1x,c1y,c2x,c2y,c3x,c3y) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c1x, c1y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c2x, c2y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c3x, c3y)]];

#define FW_ADD_CURVE_4(curve,c1x,c1y,c2x,c2y,c3x,c3y,c4x,c4y) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c1x, c1y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c2x, c2y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c3x, c3y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c4x, c4y)]];

#define FW_ADD_CURVE_5(curve,c1x,c1y,c2x,c2y,c3x,c3y,c4x,c4y,c5x,c5y) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c1x, c1y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c2x, c2y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c3x, c3y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c4x, c4y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c5x, c5y)]];

#define FW_ADD_CURVE_6(curve,c1x,c1y,c2x,c2y,c3x,c3y,c4x,c4y,c5x,c5y,c6x,c6y) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c1x, c1y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c2x, c2y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c3x, c3y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c4x, c4y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c5x, c5y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c6x, c6y)]];

#define FW_ADD_CURVE_7(curve,c1x,c1y,c2x,c2y,c3x,c3y,c4x,c4y,c5x,c5y,c6x,c6y,c7x,c7y) \
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c1x, c1y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c2x, c2y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c3x, c3y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c4x, c4y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c5x, c5y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c6x, c6y)]];\
[curve addObject:[NSValue valueWithCGPoint:CGPointMake(c7x, c7y)]];

#define FW_ADD_FILTER(list,type,name) \
[list addObject:[CPFilterInfo filterInfoWithFilterID:type filterName:name]];

#define FW_ADD_FILTER_SECRET(list,type) \
[list addObject:[CPFilterInfo filterInfoWithFilterID:type filterName:[NSString stringWithFormat:@"%ld", (long)type]]];

typedef enum {
    CPVideoFilterTypeNone					= 95,
    
    CPVideoFilterTypeGorgeous				= 46582,
    CPVideoFilterTypeDeeply                 = 127,
    CPVideoFilterTypeCute					= 46409,
    CPVideoFilterTypeFresh					= 35673,
    CPVideoFilterTypeVintage				= 100,
    CPVideoFilterTypeBlackAndWhite			= 101,
    
    CPVideoFilterTypeMagicHour				= 55,
    CPVideoFilterTypePurpleSkin             = 61,
    CPVideoFilterTypeSepia					= 91,
    CPVideoFilterTypeTMaxFilm				= 62,
    CPVideoFilterTypeDryBlackAndWhite		= 66,
    CPVideoFilterTypeBlackAndWhiteIn1962	= 73,
    CPVideoFilterTypeIlfordFilm             = 82,
    CPVideoFilterTypeEmo					= 58,
    CPVideoFilterTypeOldAndFaded			= 77,
    CPVideoFilterTypeOldMagazine			= 56,
    CPVideoFilterTypeLiteXPro				= 65,
    CPVideoFilterTypeXPro					= 60,
    CPVideoFilterTypeRedXPro				= 87,
    CPVideoFilterTypeLiteBlue				= 74,
    CPVideoFilterTypeCoolDeepBlue			= 76,
    CPVideoFilterTypeStrongContrast         = 84,
    CPVideoFilterTypeAntique				= 57,
    CPVideoFilterTypeGrunge                 = 59,
    CPVideoFilterTypeBeingAlone             = 64,
    CPVideoFilterTypePostcard				= 67,
    CPVideoFilterTypeNostalgia				= 68,
    CPVideoFilterTypeVintage2				= 86,
    CPVideoFilterTypeVivid					= 89,
    CPVideoFilterTypeLikeAPicture			= 79,
    CPVideoFilterTypeWeakLomo				= 88,
    CPVideoFilterTypeStrongLomo             = 85,
    CPVideoFilterTypeRusty					= 70,
    CPVideoFilterTypeSilhouette             = 94,
    CPVideoFilterTypeWeakCrossProcess		= 90,
    CPVideoFilterTypeCrossProcess			= 71,
    CPVideoFilterTypeStrongCrossProcess     = 72,
    CPVideoFilterTypeSlideFilm				= 75,
    CPVideoFilterTypeSlideFilmKodekE100V	= 80,
    CPVideoFilterTypeFadedMemory			= 81,
    CPVideoFilterTypeUnderTheCafeLight		= 83,
    CPVideoFilterTypeSnapShotSX70			= 93,
    CPVideoFilterTypeLikeAMovie             = 69,
    CPVideoFilterTypeCinemaParadise         = 78
} CPVideoFilterType;

typedef enum {
    CPVideoWatermarkPositionNone,
    CPVideoWatermarkPositionTopLeft,
    CPVideoWatermarkPositionTopRight,
    CPVideoWatermarkPositionBottomLeft,
    CPVideoWatermarkPositionBottomRight
} CPVideoWatermarkPosition;

typedef void (^CPApplyFilterCompletion)(UIImage *outputImage);

@interface CPFilterUtility : NSObject

@property (nonatomic, strong) NSMutableDictionary *filters;

//+ (NSArray *)getFilterInfoList;

+ (CPFilterUtility *)sharedFilterUtility;

//- (OPGPUImageOutput<OPGPUImageInput> *)getFilter:(CPVideoFilterType)filterType;
//- (OPGPUImageOutput<OPGPUImageInput> *)getFilter:(CPVideoFilterType)filterType showWatermark:(BOOL)showWatermark;
- (OPGPUImageOutput<OPGPUImageInput> *)getFilter:(CPVideoFilterType)filterType showWatermark:(BOOL)showWatermark isEncoding:(BOOL)isEncoding;
//- (void)cleanupSourcePictures;
//- (void)cleanupSourcePicturesWithKey:(NSString *)key;

@end
