//
//  CPFilterUtility.m
//  11st
//
//  Created by spearhead on 2015. 1. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPFilterUtility.h"
#import "CPVideoCompositionItem.h"

@interface NSArray (CurveExtension)

- (NSArray *)convertedToneCurveArray;

@end

@implementation NSArray (CurveExtension)

- (NSArray *)convertedToneCurveArray {
    NSMutableArray *toneCurveList = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (NSValue *value in self) {
        CGPoint curvePoint = [value CGPointValue];
        curvePoint.x = curvePoint.x / 255.f;
        curvePoint.y = curvePoint.y / 255.f;
        
        [toneCurveList addObject:[NSValue valueWithCGPoint:curvePoint]];
    }
    
    return toneCurveList;
}

@end

@interface CPFilterUtility ()

@end

@implementation CPFilterUtility

- (id)init
{
    self = [super init];
    if (self) {
        self.filters = [NSMutableDictionary dictionary];
//        self.sourcePictures = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (CPFilterUtility *)sharedFilterUtility
{
    static dispatch_once_t pred;
    static CPFilterUtility *sharedFilterUtility = nil;
    
    dispatch_once(&pred, ^{
        sharedFilterUtility = [[CPFilterUtility alloc] init];
    });
    
    return sharedFilterUtility;
}

- (OPGPUImageOutput<OPGPUImageInput> *)getFilter:(CPVideoFilterType)filterType showWatermark:(BOOL)showWatermark isEncoding:(BOOL)isEncoding
{
    OPGPUImageFilterGroup *filterGroup = [[OPGPUImageFilterGroup alloc] init];
    
    OPGPUImageToneCurveFilter *curveFilter = [[OPGPUImageToneCurveFilter alloc] init];
    OPGPUImageSaturationFilter *saturationFilter = [[OPGPUImageSaturationFilter alloc] init];
    OPGPUImageBrightnessFilter *brightnessFilter = [[OPGPUImageBrightnessFilter alloc] init];
    OPGPUImageContrastFilter *contrastFilter = [[OPGPUImageContrastFilter alloc] init];
    OPGPUImageGrayscaleFilter *grayscaleFilter = [[OPGPUImageGrayscaleFilter alloc] init];
    
    NSMutableArray *rgbCurve = [NSMutableArray array];
    NSMutableArray *redCurve = [NSMutableArray array];
    NSMutableArray *greenCurve = [NSMutableArray array];
    NSMutableArray *blueCurve = [NSMutableArray array];
    
    CGFloat saturation = CGFLOAT_MAX;
    CGFloat brightness = CGFLOAT_MAX;
    CGFloat contrast = CGFLOAT_MAX;
    BOOL gray = NO;
    
    switch (filterType) {
        case 95: // Original
        {
            FW_ADD_CURVE_2(rgbCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(redCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,0.f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.f)
            FW_ADD_CONTRAST(1.f)
            FW_ADD_GRAY(0)
        }
            break;
            
        case 46582: // 화사하게
        {
            FW_ADD_CURVE_2(rgbCurve, 0.f,26.f, 255.f,255.f)
            FW_ADD_CURVE_DEFAULT(redCurve)
            FW_ADD_CURVE_DEFAULT(greenCurve)
            FW_ADD_CURVE_2(blueCurve, 0.f,0.f, 212.f,250.f)
            FW_ADD_SATURATION(1.758f)
            FW_ADD_BRIGHTNESS(0.166f)
            FW_ADD_CONTRAST(1.1)
            FW_ADD_GRAY(0)
        }
            break;
            
        case 127: // 진하게
        {
            FW_ADD_CURVE_DEFAULT(rgbCurve)
            FW_ADD_CURVE_4(redCurve, 0.f,0.f, 62.f,40.f, 191.f,206.f, 255.f,255.f)
            FW_ADD_CURVE_4(greenCurve, 0.f,0.f, 84.5f,69.5f, 177.5f,199.f, 255.f,255.f)
            FW_ADD_CURVE_4(blueCurve, 0.f,0.f, 62.f,79.f, 193.f,154.f, 255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.008f)
            FW_ADD_CONTRAST(0.946f)
            FW_ADD_GRAY(0)
            // vignette03, alpha=58
        }
            break;
            
        case 46409: // 귀엽게
        {
            FW_ADD_CURVE_2(rgbCurve, 0.f,73.5f, 255.f,229.f)
            FW_ADD_CURVE_DEFAULT(redCurve)
            FW_ADD_CURVE_2(greenCurve, 32.f,0.f, 255.0f,255.0f)
            FW_ADD_CURVE_DEFAULT(blueCurve)
            FW_ADD_SATURATION(0.958f)
            FW_ADD_BRIGHTNESS(0.137)
            FW_ADD_CONTRAST(0.975)
            FW_ADD_GRAY(0)
        }
            break;
            
        case 35673: // 산뜻하게
        {
            FW_ADD_CURVE_6(rgbCurve, 0.f,23.f, 24.f,52.f, 62.f,105.f, 110.f,167.f, 192.f,223.f, 251.f,251.f)
            FW_ADD_CURVE_5(redCurve, 0.f,38.f, 59.f,92.f, 115.f,151.f, 176.f,181.f, 255.f,255.f)
            FW_ADD_CURVE_4(greenCurve, 29.f,37.f, 73.f,115.f, 150.f,175.f, 255.f,255.f)
            FW_ADD_CURVE_4(blueCurve, 0.f,65.f, 83.f,147.f, 177.f,211.f, 254.f,236.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.043f)
            FW_ADD_CONTRAST(1.f)
            FW_ADD_GRAY(0)
            // vignetting05, alpha=30 / texture27, alpha=138
        }
            break;
            
        case 100: // 빈티지
        {
            FW_ADD_CURVE_6(rgbCurve, 0.f,0.5f, 48.5f,97.5f, 71.f,121.f, 157.f,182.5f, 200.f,214.f, 255.f,255.f)
            FW_ADD_CURVE_6(redCurve, 0.f,0.f, 74.f,61.5f, 128.f,123.f, 168.5f,186.f, 202.5f,218.5f, 255.f,255.f)
            FW_ADD_CURVE_4(greenCurve, 29.f,37.f, 73.f,115.f, 150.f,175.f, 255.f,255.f)
            FW_ADD_CURVE_6(blueCurve, 0.f,0.f, 54.5f,50.5f, 81.5f,73.5f, 170.5f,160.5f, 194.5f,185.5f, 255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.033f)
            FW_ADD_CONTRAST(0.978f)
            FW_ADD_GRAY(0)
            // vignetting02, alpha=37 / texture01, alpha=76
        }
            break;
            
        case 101: // 흑백으로
        {
            FW_ADD_CURVE_4(rgbCurve, 0.f,0.f, 77.f,69.f, 175.f,206.f, 255.f,255.f)
            FW_ADD_CURVE_DEFAULT(redCurve)
            FW_ADD_CURVE_DEFAULT(greenCurve)
            FW_ADD_CURVE_DEFAULT(blueCurve)
            FW_ADD_SATURATION(0.f)
            FW_ADD_BRIGHTNESS(0.042f)
            FW_ADD_CONTRAST(1.114f)
            FW_ADD_GRAY(0)
            // vignetting03, alpha=57
        }
            break;
            
        case 55: // Magic Hour
        {
            FW_ADD_CURVE_6(rgbCurve,0.f,0.5f,48.5f,97.5f,71.f,121.f,157.f,182.5f,200.f,214.f,255.f,255.f)
            FW_ADD_CURVE_6(redCurve,0.f,0.f,74.f,61.5f,128.f,123.f,168.5f,186.f,202.5f,218.5f,255.f,255.f)
            FW_ADD_CURVE_6(greenCurve,0.f,0.f,54.5f,50.5f,81.5f,73.5f,170.5f,160.5f,194.5f,185.5f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,40.5f,56.f,66.f,228.f,210.5f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.033f)
            FW_ADD_CONTRAST(0.978f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(37)
            // texture : texture01(76)
        }
            break;
        case 61: // Purple Skin
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,66.5f,82.5f,166.f,145.f,223.5f,185.5f,255.f,255.f)
            FW_ADD_CURVE_6(redCurve,0.f,0.f,77.f,56.f,124.5f,114.f,168.f,180.5f,214.5f,222.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,21.5f,90.f,45.f,217.5f,190.5f,255.f,255.f)
            FW_ADD_CURVE_6(blueCurve,9.5f,0.f,61.5f,68.f,148.f,105.f,209.f,154.5f,239.f,200.f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.109f)
            FW_ADD_CONTRAST(1.164f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(56)
            // texture : texture19(47)
        }
            break;
        case 91: // Sepia
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,76.f,61.5f,205.f,195.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,96.5f,62.f,153.5f,166.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,90.f,45.f,192.5f,189.5f,255.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,0.f,109.5f,42.f,174.f,100.5f,236.5f,218.f,255.f,255.f)
            FW_ADD_SATURATION(1.22f)
            FW_ADD_BRIGHTNESS(-0.024f)
            FW_ADD_CONTRAST(0.934f)
            FW_ADD_GRAY(1)
        }
            break;
        case 62: // T-Max Film
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,77.f,69.f,175.f,206.f,255.f,255.f)
            FW_ADD_CURVE_2(redCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,0.f,255.f,255.f)
            FW_ADD_SATURATION(0.f)
            FW_ADD_BRIGHTNESS(0.042f)
            FW_ADD_CONTRAST(1.114f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(57)
        }
            break;
        case 66: // Dry Black & White
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,74.f,45.f,159.5f,175.5f,202.f,223.5f,255.f,255.f)
            FW_ADD_CURVE_2(redCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,0.f,255.f,255.f)
            FW_ADD_SATURATION(0.f)
            FW_ADD_BRIGHTNESS(0.012f)
            FW_ADD_CONTRAST(1.128f)
            FW_ADD_GRAY(0)
            // texture : texture02(179)
        }
            break;
        case 73: // Black & White in 1962
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,75.5f,44.f,189.5f,205.f,255.f,255.f)
            FW_ADD_CURVE_2(redCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_3(greenCurve,0.f,0.f,88.f,94.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,0.f,255.f,255.f)
            FW_ADD_SATURATION(0.972f)
            FW_ADD_BRIGHTNESS(-0.077f)
            FW_ADD_CONTRAST(0.913f)
            FW_ADD_GRAY(1)
        }
            break;
        case 82: // ILFORD Film
        {
            FW_ADD_CURVE_7(rgbCurve,0.f,0.f,53.f,25.5f,107.5f,89.f,121.5f,131.5f,151.5f,179.5f,192.f,209.5f,255.f,237.5f)
            FW_ADD_CURVE_5(redCurve,0.f,23.f,77.f,47.5f,138.5f,123.5f,205.f,189.5f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,27.f,0.f,255.f,224.f)
            FW_ADD_CURVE_4(blueCurve,4.f,33.5f,87.f,68.5f,205.f,162.f,255.f,176.5f)
            FW_ADD_SATURATION(0.728f)
            FW_ADD_BRIGHTNESS(0.021f)
            FW_ADD_CONTRAST(1.035f)
            FW_ADD_GRAY(1)
        }
            break;
        case 58: // Emo
        {
            FW_ADD_CURVE_3(rgbCurve,0.f,0.f,164.f,180.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,93.f,99.5f,109.5f,128.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,17.5f,112.f,99.5f,133.5f,135.f,255.f,221.5f)
            FW_ADD_CURVE_4(blueCurve,0.f,34.5f,80.f,90.f,168.f,152.f,255.f,211.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.147f)
            FW_ADD_CONTRAST(0.857f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(75)
            // texture : texture26(107)
        }
            break;
        case 77: // Old & Faded
        {
            FW_ADD_CURVE_3(rgbCurve,0.f,0.f,120.f,135.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,32.f,65.f,65.f,190.5f,172.f,255.f,208.f)
            FW_ADD_CURVE_4(greenCurve,29.f,0.f,103.f,85.5f,165.f,180.5f,229.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,0.f,32.f,15.f,134.5f,119.5f,226.f,239.f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.092f)
            FW_ADD_CONTRAST(0.871f)
            FW_ADD_GRAY(1)
            // vignette : vignetting06(140)
            // texture : texture01(87)
        }
            break;
        case 56: // Old Magazine
        {
            FW_ADD_CURVE_6(rgbCurve,0.f,21.f,67.f,54.f,92.f,79.5f,131.f,136.f,201.5f,218.f,255.f,255.f)
            FW_ADD_CURVE_7(redCurve,0.f,36.f,64.f,71.f,90.f,106.f,135.f,164.5f,183.5f,209.f,226.f,226.5f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,73.f,80.5f,107.f,116.5f,203.f,184.5f,255.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,10.f,44.5f,75.f,82.f,99.5f,224.5f,164.5f,255.f,225.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.121f)
            FW_ADD_CONTRAST(1.05f)
            FW_ADD_GRAY(1)
            // texture : texture01(255)
        }
            break;
        case 65: // Lite X-Pro
        {
            FW_ADD_CURVE_2(rgbCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,62.f,40.f,191.f,206.f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,84.5f,69.5f,177.5f,199.f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,0.f,62.f,79.f,193.f,154.f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.008f)
            FW_ADD_CONTRAST(0.946f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(47)
        }
            break;
        case 60: // X-Pro
        {
            FW_ADD_CURVE_2(rgbCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_6(redCurve,0.f,0.f,47.f,36.f,99.f,83.5f,161.f,201.f,196.f,217.f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,98.f,94.f,194.f,207.f,255.f,255.f)
            FW_ADD_CURVE_7(blueCurve,1.f,0.f,44.f,68.f,67.5f,92.5f,151.f,135.f,214.5f,166.f,236.5f,201.5f,255.f,255.f)
            FW_ADD_SATURATION(0.835f)
            FW_ADD_BRIGHTNESS(-0.075f)
            FW_ADD_CONTRAST(0.896f)
            FW_ADD_GRAY(0)
        }
            break;
        case 87: // Red X-Pro
        {
            FW_ADD_CURVE_6(rgbCurve,3.5f,0.f,62.f,36.f,113.f,99.5f,190.f,184.f,229.f,213.f,255.f,226.5f)
            FW_ADD_CURVE_6(redCurve,0.f,0.f,85.5f,61.5f,121.5f,138.5f,155.f,195.f,199.f,230.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,119.5f,87.f,157.5f,155.f,191.f,205.5f,255.f,254.5f)
            FW_ADD_CURVE_6(blueCurve,5.f,8.5f,98.5f,38.5f,157.f,99.f,201.5f,160.5f,234.5f,206.f,255.f,255.f)
            FW_ADD_SATURATION(0.692f)
            FW_ADD_BRIGHTNESS(0.117f)
            FW_ADD_CONTRAST(0.996f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(99)
            // texture : texture12(90)
        }
            break;
        case 74: // Lite blue
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,59.5f,47.5f,195.f,203.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,80.5f,62.5f,204.f,180.f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,65.f,43.5f,197.5f,197.f,255.f,218.5f)
            FW_ADD_CURVE_4(blueCurve,15.f,0.f,58.5f,39.5f,179.5f,196.5f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.075f)
            FW_ADD_CONTRAST(1.282f)
            FW_ADD_GRAY(0)
            // texture : texture25(0)
        }
            break;
        case 76: // Cool Deep Blue
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,67.5f,60.5f,168.f,198.5f,205.f,230.5f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,85.5f,50.f,204.f,195.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,70.5f,47.5f,111.f,108.f,194.5f,184.5f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,0.f,83.f,60.5f,210.f,216.5f,255.f,255.f)
            FW_ADD_SATURATION(0.896f)
            FW_ADD_BRIGHTNESS(-0.044f)
            FW_ADD_CONTRAST(0.886f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(76)
            // texture : texture25(68)
        }
            break;
        case 84: // Strong Contrast
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,84.5f,65.5f,190.f,189.f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,86.f,63.f,153.f,168.f,200.5f,212.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,93.5f,70.f,136.f,142.5f,184.f,203.5f,255.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,0.f,100.5f,57.f,160.f,147.f,187.f,195.5f,255.f,255.f)
            FW_ADD_SATURATION(0.9f)
            FW_ADD_BRIGHTNESS(0.016f)
            FW_ADD_CONTRAST(1.053f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(127)
            // texture : texture04(171)
        }
            break;
        case 57: // Antique
        {
            FW_ADD_CURVE_3(rgbCurve,0.f,0.f,108.f,138.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,64.f,72.5f,187.5f,160.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,74.f,51.5f,175.f,194.5f,255.f,255.f)
            FW_ADD_CURVE_3(blueCurve,25.f,0.f,126.f,133.f,255.f,229.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.092f)
            FW_ADD_CONTRAST(1.132f)
            FW_ADD_GRAY(0)
            // vignette : vignetting01(173)
            // texture : texture02(153)
        }
            break;
        case 59: // Grunge
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,95.f,69.f,114.f,88.f,199.5f,185.f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,83.f,82.f,93.f,106.f,167.f,191.f,255.f,255.f)
            FW_ADD_CURVE_6(greenCurve,0.f,19.f,63.5f,57.f,108.f,106.f,123.f,135.f,193.5f,212.f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,0.f,61.f,70.f,199.5f,170.f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.092f)
            FW_ADD_CONTRAST(0.875f)
            FW_ADD_GRAY(1)
            // texture : texture20(151)
        }
            break;
        case 64: // Being Alone
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,43.5f,47.5f,234.f,219.5f,255.f,255.f)
            FW_ADD_CURVE_7(redCurve,0.f,0.f,37.f,20.f,103.f,80.f,116.5f,115.f,185.f,213.f,226.f,237.f,248.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,69.f,60.f,130.f,129.f,211.f,225.f,247.f,255.f)
            FW_ADD_CURVE_6(blueCurve,0.f,26.f,60.f,63.f,139.f,128.f,188.f,174.f,225.f,217.f,249.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.159f)
            FW_ADD_CONTRAST(1.089f)
            FW_ADD_GRAY(0)
            // vignette : vignetting01(96)
            // texture : texture03(255)
        }
            break;
        case 67: // Postcard
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,80.5f,50.5f,182.5f,224.5f,217.5f,245.f,255.f,255.f)
            FW_ADD_CURVE_3(redCurve,0.f,0.f,153.5f,124.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,71.f,66.f,193.5f,184.f,255.f,255.f)
            FW_ADD_CURVE_3(blueCurve,0.f,0.f,135.5f,113.5f,255.f,255.f)
            FW_ADD_SATURATION(0.931f)
            FW_ADD_BRIGHTNESS(-0.024f)
            FW_ADD_CONTRAST(0.872f)
            FW_ADD_GRAY(0)
        }
            break;
        case 68: // Nostalgia
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,61.5f,50.5f,126.f,122.f,213.5f,197.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,73.5f,86.5f,175.f,152.f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,11.f,78.5f,52.5f,176.5f,186.f,255.f,255.f)
            FW_ADD_CURVE_3(blueCurve,0.f,25.f,131.f,114.5f,255.f,229.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.092f)
            FW_ADD_CONTRAST(0.867f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(159)
            // texture : texture02(168)
        }
            break;
        case 86: // Vintage
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,67.f,48.f,128.f,126.f,191.f,211.f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,72.f,58.5f,123.f,142.f,202.f,182.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,70.f,60.f,141.f,152.5f,196.5f,213.f,255.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,15.f,76.f,60.f,133.f,117.f,198.f,194.f,255.f,217.5f)
            FW_ADD_SATURATION(0.728f)
            FW_ADD_BRIGHTNESS(0.008f)
            FW_ADD_CONTRAST(0.989f)
            FW_ADD_GRAY(0)
            // texture : texture03(197)
        }
            break;
        case 89: // Vivid
        {
            FW_ADD_CURVE_7(rgbCurve,0.f,0.f,79.5f,41.5f,108.f,79.5f,132.f,138.5f,162.f,187.f,198.5f,221.5f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,103.5f,75.5f,191.f,190.5f,255.f,255.f)
            FW_ADD_CURVE_3(greenCurve,0.f,0.f,198.f,191.5f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,0.f,85.f,78.f,214.5f,190.f,255.f,255.f)
            FW_ADD_SATURATION(0.942f)
            FW_ADD_BRIGHTNESS(0.016f)
            FW_ADD_CONTRAST(1.103f)
            FW_ADD_GRAY(0)
        }
            break;
        case 79: // Like a Picture
        {
            FW_ADD_CURVE_3(rgbCurve,0.f,0.f,67.5f,59.f,255.f,255.f)
            FW_ADD_CURVE_7(redCurve,0.f,0.f,66.f,36.f,106.5f,67.f,142.f,123.f,179.5f,216.f,232.f,246.f,248.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,80.5f,62.f,138.f,147.5f,196.f,218.5f,247.f,255.f)
            FW_ADD_CURVE_6(blueCurve,0.f,26.f,79.5f,58.5f,129.5f,115.f,188.f,174.f,225.f,217.f,249.f,255.f)
            FW_ADD_SATURATION(0.772f)
            FW_ADD_BRIGHTNESS(-0.105f)
            FW_ADD_CONTRAST(0.941f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(58)
            // texture : texture20(69)
        }
            break;
        case 88: // Weak Lomo
        {
            FW_ADD_CURVE_7(rgbCurve,0.f,0.f,59.f,26.f,96.f,60.f,127.f,120.f,181.5f,183.5f,218.5f,216.5f,255.f,255.f)
            FW_ADD_CURVE_6(redCurve,0.f,0.f,54.f,75.5f,95.f,119.f,142.f,147.f,210.f,194.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,83.5f,56.5f,184.5f,163.f,205.f,197.f,255.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,23.5f,81.5f,46.f,163.f,133.5f,223.f,186.5f,255.f,255.f)
            FW_ADD_SATURATION(0.521f)
            FW_ADD_BRIGHTNESS(0.159f)
            FW_ADD_CONTRAST(1.06f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(113)
        }
            break;
        case 85: // Strong Lomo
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,19.5f,67.5f,49.f,139.5f,112.f,199.5f,198.5f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,25.f,61.5f,62.5f,88.5f,119.5f,190.f,235.5f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,9.f,91.5f,78.5f,153.5f,166.5f,208.5f,218.5f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,18.5f,84.f,60.f,209.5f,187.5f,255.f,255.f)
            FW_ADD_SATURATION(0.892f)
            FW_ADD_BRIGHTNESS(-0.021f)
            FW_ADD_CONTRAST(1.082f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(255)
            // texture : texture02(127)
        }
            break;
        case 70: // Rusty
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,75.f,50.5f,195.5f,198.5f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,38.5f,65.f,63.f,175.f,202.f,255.f,243.f)
            FW_ADD_CURVE_3(greenCurve,0.f,0.f,126.f,130.f,255.f,255.f)
            FW_ADD_CURVE_3(blueCurve,0.f,65.5f,136.f,103.5f,255.f,184.f)
            FW_ADD_SATURATION(0.868f)
            FW_ADD_BRIGHTNESS(0.008f)
            FW_ADD_CONTRAST(0.944f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(64)
            // texture : texture01(159)
        }
            break;
        case 94: // Silhouette
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,91.5f,64.f,188.5f,207.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,62.f,40.f,162.5f,177.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,76.f,62.5f,193.f,199.f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,0.f,96.f,49.5f,217.f,177.5f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.02f)
            FW_ADD_CONTRAST(0.931f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(43)
        }
            break;
        case 90: // Weak Cross Process
        {
            FW_ADD_CURVE_2(rgbCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,64.5f,32.f,126.f,136.f,191.f,206.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,62.f,67.f,126.f,134.f,194.f,195.5f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,31.5f,62.f,79.f,212.5f,176.5f,255.f,223.5f)
            FW_ADD_SATURATION(0.9f)
            FW_ADD_BRIGHTNESS(0.f)
            FW_ADD_CONTRAST(1.064f)
            FW_ADD_GRAY(0)
            // texture : texture03(127)
        }
            break;
        case 71: // Cross Process
        {
            FW_ADD_CURVE_3(rgbCurve,30.f,0.f,193.f,206.f,255.f,234.5f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,70.f,47.f,133.5f,148.5f,196.f,206.f,255.f,227.f)
            FW_ADD_CURVE_5(greenCurve,0.f,40.f,65.f,66.f,127.f,127.f,212.5f,227.5f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,31.f,255.f,171.f)
            FW_ADD_SATURATION(0.965f)
            FW_ADD_BRIGHTNESS(0.025f)
            FW_ADD_CONTRAST(0.965f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(39)
        }
            break;
        case 72: // Strong Cross Process
        {
            FW_ADD_CURVE_2(rgbCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,0.f,77.f,56.f,172.f,198.f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,0.f,0.f,68.5f,39.f,174.f,176.f,255.f,255.f)
            FW_ADD_CURVE_4(blueCurve,0.f,0.f,75.5f,59.5f,202.f,156.f,255.f,255.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(-0.046f)
            FW_ADD_CONTRAST(0.937f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(64)
        }
            break;
        case 75: // Slide film
        {
            FW_ADD_CURVE_5(rgbCurve,19.f,0.f,67.5f,37.5f,118.f,112.5f,185.5f,198.5f,255.f,255.f)
            FW_ADD_CURVE_3(redCurve,0.f,0.f,150.f,125.f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,2.f,38.f,255.f,184.f)
            FW_ADD_SATURATION(1.f)
            FW_ADD_BRIGHTNESS(0.016f)
            FW_ADD_CONTRAST(1.071f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(155)
            // texture : texture01(111)
        }
            break;
        case 80: // Slide film Kodek E-100V
        {
            FW_ADD_CURVE_7(rgbCurve,0.f,0.f,53.f,25.5f,107.5f,89.f,121.5f,131.5f,151.5f,179.5f,192.f,209.5f,255.f,237.5f)
            FW_ADD_CURVE_5(redCurve,0.f,23.f,77.f,47.5f,138.5f,123.5f,205.f,189.5f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,27.f,0.f,255.f,224.f)
            FW_ADD_CURVE_4(blueCurve,4.f,33.5f,87.f,68.5f,205.f,162.f,255.f,176.5f)
            FW_ADD_SATURATION(0.728f)
            FW_ADD_BRIGHTNESS(0.021f)
            FW_ADD_CONTRAST(1.035f)
            FW_ADD_GRAY(0)
        }
            break;
        case 81: // Faded Memory
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,77.f,61.5f,159.5f,191.5f,202.5f,230.5f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,78.5f,56.5f,145.f,117.f,192.f,191.f,255.f,227.f)
            FW_ADD_CURVE_5(greenCurve,0.f,40.f,65.f,66.f,127.f,127.f,232.f,233.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,31.f,255.f,171.f)
            FW_ADD_SATURATION(0.807f)
            FW_ADD_BRIGHTNESS(0.109f)
            FW_ADD_CONTRAST(1.039f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(164)
        }
            break;
        case 83: // Under the Cafe light
        {
            FW_ADD_CURVE_5(rgbCurve,0.f,0.f,63.f,52.f,132.5f,144.5f,209.f,217.5f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,0.f,0.f,86.5f,48.5f,167.f,190.f,218.5f,229.5f,255.f,255.f)
            FW_ADD_CURVE_4(greenCurve,35.f,0.f,69.f,74.f,184.5f,206.f,255.f,255.f)
            FW_ADD_CURVE_2(blueCurve,0.f,26.f,255.f,212.5f)
            FW_ADD_SATURATION(0.828f)
            FW_ADD_BRIGHTNESS(-0.037f)
            FW_ADD_CONTRAST(0.95f)
            FW_ADD_GRAY(0)
            // vignette : vignetting03(127)
        }
            break;
        case 93: // Snap Shot SX-70
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,66.5f,72.f,173.f,185.f,255.f,255.f)
            FW_ADD_CURVE_5(redCurve,12.f,0.f,82.5f,57.5f,123.f,144.f,188.f,216.f,255.f,255.f)
            FW_ADD_CURVE_2(greenCurve,0.f,0.f,255.f,255.f)
            FW_ADD_CURVE_5(blueCurve,0.f,11.f,56.f,78.f,132.f,128.f,217.f,179.f,255.f,244.f)
            FW_ADD_SATURATION(0.813f)
            FW_ADD_BRIGHTNESS(0.f)
            FW_ADD_CONTRAST(0.982f)
            FW_ADD_GRAY(0)
        }
            break;
        case 69: // Like a Movie
        {
            FW_ADD_CURVE_4(rgbCurve,0.f,0.f,74.5f,43.f,190.f,191.5f,255.f,255.f)
            FW_ADD_CURVE_4(redCurve,0.f,12.5f,60.5f,61.f,140.f,174.f,255.f,232.f)
            FW_ADD_CURVE_4(greenCurve,0.f,19.5f,68.f,62.5f,161.f,175.f,255.f,234.f)
            FW_ADD_CURVE_4(blueCurve,0.f,19.f,49.5f,27.f,184.f,194.f,255.f,237.5f)
            FW_ADD_SATURATION(0.917f)
            FW_ADD_BRIGHTNESS(-0.113f)
            FW_ADD_CONTRAST(0.924f)
            FW_ADD_GRAY(0)
            // vignette : vignetting04(69)
        }
            break;
        case 78: // Cinema Paradise
        {
            FW_ADD_CURVE_3(rgbCurve,0.f,0.f,199.5f,197.5f,255.f,255.f)
            FW_ADD_CURVE_6(redCurve,0.f,0.f,64.f,59.f,104.f,119.f,122.f,170.5f,178.f,229.f,255.f,255.f)
            FW_ADD_CURVE_5(greenCurve,0.f,0.f,78.f,43.5f,123.f,135.f,193.5f,216.5f,255.f,255.f)
            FW_ADD_CURVE_6(blueCurve,0.f,0.f,75.f,22.5f,116.5f,59.5f,182.5f,176.5f,210.5f,213.f,255.f,255.f)
            FW_ADD_SATURATION(0.917f)
            FW_ADD_BRIGHTNESS(-0.067f)
            FW_ADD_CONTRAST(0.948f)
            FW_ADD_GRAY(0)
            // vignette : vignetting02(126)
            // texture : texture12(99)
        }
            break;
            
        default:
            break;
    }
    
    if (gray) {
        // 참고 :
        // GPUImageFilterGroup에서 GPUImageGrayscaleFilter를 가장 먼저 넣고 initialFilter로 설정하면 화면이 전부 검정색(혹은 필터의 톤으로 채워진)으로 화면이 칠해진다.
        OPGPUImageToneCurveFilter *dummyCurveFilter = [[OPGPUImageToneCurveFilter alloc] init];
        [filterGroup addFilter:dummyCurveFilter];
        [filterGroup addFilter:grayscaleFilter];
    }
    
    if (rgbCurve != nil && [rgbCurve count] > 0) {
        [curveFilter setRgbCompositeControlPoints:[rgbCurve convertedToneCurveArray]];
    }
    
    if (redCurve != nil && [redCurve count] > 0) {
        [curveFilter setRedControlPoints:[redCurve convertedToneCurveArray]];
    }
    
    if (greenCurve != nil && [greenCurve count] > 0) {
        [curveFilter setGreenControlPoints:[greenCurve convertedToneCurveArray]];
    }
    
    if (blueCurve != nil && [blueCurve count] > 0) {
        [curveFilter setBlueControlPoints:[blueCurve convertedToneCurveArray]];
    }
    
    [filterGroup addFilter:curveFilter];
    
    //	OPGPUImageOutput<OPGPUImageInput> *terminalFilter = nil;
    
    if (saturation != CGFLOAT_MAX) {
        saturationFilter.saturation = saturation;
        [filterGroup addFilter:saturationFilter];
    }
    
    if (brightness != CGFLOAT_MAX) {
        brightnessFilter.brightness = brightness;
        [filterGroup addFilter:brightnessFilter];
    }
    
    if (contrast != CGFLOAT_MAX) {
        contrastFilter.contrast = contrast;
        [filterGroup addFilter:contrastFilter];
    }
    
//    if (showWatermark && [CPVideoCompositionItem currentCompositionItem].watermarkPosition != CPMovieWatermarkPositionNone) {
//        OPGPUImagePicture *sourcePicture = nil;
//        BOOL hasSourcePicture = NO;
//        
//        if (self.sourcePictures == nil) {
//            self.sourcePictures = [NSMutableDictionary dictionary];
//        }
//        else {
//            if (isEncoding && [self.sourcePictures count] > 0) {
//                for (NSString *objKey in [self.sourcePictures allKeys]) {
//                    if ([objKey hasPrefix:@"Encoding"]) {
//                        sourcePicture = (OPGPUImagePicture *)[self.sourcePictures objectForKey:objKey];
//                        hasSourcePicture = YES;
//                        break;
//                    }
//                }
//            }
//        }
//        
//        OPLog(@"sourcePicture? : %@", sourcePicture != nil ? @"YES" : @"NO");
//        if (sourcePicture == nil) {
//            CGSize filterSize = [OutplayVideoUtility getMovieSizeFromOptions];
//            
//            UIGraphicsBeginImageContextWithOptions(filterSize, NO, [UIScreen mainScreen].scale);
//            
//            // create rect that fills screen
//            UIImage *logoImage = UIImageBundleContentsOfFile(@"11st-watermark.png");
//            CGRect bounds = CGRectZero;
//            
//            CGSize logoImageSize = logoImage.size;
//            //			if ([UIScreen mainScreen].scale == 2.f) {
//            //				logoImageSize.width *= 2.f;
//            //				logoImageSize.height *= 2.f;
//            //			}
//            
//            OPLog(@"logoImageSize : %@", NSStringFromCGSize(logoImageSize));
//            
//            switch ([OutplayVideoCompositionItem currentCompositionItem].watermarkPosition) {
//                case OutplayMovieWatermarkPositionTopLeft:
//                    bounds = CGRectMake(10.f, 10.f, logoImageSize.width, logoImageSize.height);
//                    break;
//                    
//                case OutplayMovieWatermarkPositionBottomLeft:
//                    bounds = CGRectMake(10.f, filterSize.height - (logoImageSize.height + 10.f), logoImageSize.width, logoImageSize.height);
//                    break;
//                    
//                case OutplayMovieWatermarkPositionTopRight:
//                    bounds = CGRectMake(filterSize.width - (logoImageSize.width + 10.f), 10.f, logoImageSize.width, logoImageSize.height);
//                    break;
//                    
//                case OutplayMovieWatermarkPositionBottomRight:
//                    bounds = CGRectMake(filterSize.width - (logoImageSize.width + 10.f), filterSize.height - (logoImageSize.height + 10.f), logoImageSize.width, logoImageSize.height);
//                    break;
//                    
//                    
//                default:
//                    break;
//            }
//            
//            [logoImage drawInRect:bounds];
//            
//            UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            UIImage *inputImage = [UIImage imageWithCGImage:outputImage.CGImage
//                                                      scale:[UIScreen mainScreen].scale
//                                                orientation:outputImage.imageOrientation];
//            
//            OPLog(@"inputImage size : %@", NSStringFromCGSize(inputImage.size));
//            
//            sourcePicture = [[OPGPUImagePicture alloc] initWithImage:inputImage
//                                                 smoothlyScaleOutput:NO];
//        }
//        else {
//            [sourcePicture removeAllTargets];
//        }
//        
//        [sourcePicture processImage];
//        
//        OPGPUImageAlphaBlendFilter *alphaBlendFilter = [[OPGPUImageAlphaBlendFilter alloc] init];
//        alphaBlendFilter.mix = 1.f;//0.5f;
//        
//        if (isEncoding == NO) {
//            // test
//            [alphaBlendFilter disableSecondFrameCheck];
//        }
//        
//        [sourcePicture addTarget:alphaBlendFilter atTextureLocation:1];
//        [filterGroup addFilter:alphaBlendFilter];
//        
//        SAFE_ARC_RELEASE(alphaBlendFilter);
//        
//        //		[self.sourcePictures addObject:sourcePicture];
//        
//        if (hasSourcePicture == NO) {
//            NSString *sourcePictureKey = nil;
//            NSString *uuidString = [OutplayUtility generateUUID];
//            
//            if (isEncoding) {
//                sourcePictureKey = [NSString stringWithFormat:@"Encoding_%@", uuidString];
//            }
//            else {
//                sourcePictureKey = [NSString stringWithFormat:@"CoverImage_%@", uuidString];
//            }
//            
//            //			OPLog(@"sourcePictureKey : %@", sourcePictureKey);
//            
//            [self.sourcePictures setObject:sourcePicture forKey:sourcePictureKey];
//            
//            SAFE_ARC_RELEASE(sourcePicture);
//        }
//    }
    
    for (NSInteger i = 0; i < [filterGroup filterCount] - 1; i++) {
        //		if (i + 1 == [filterGroup filterCount]) {
        //			terminalFilter = [filterGroup filterAtIndex:i];
        //			break;
        //		}
        
        OPGPUImageOutput<OPGPUImageInput> *curFilter = [filterGroup filterAtIndex:i];
        OPGPUImageOutput<OPGPUImageInput> *nextFilter = [filterGroup filterAtIndex:i + 1];
        [curFilter addTarget:nextFilter];
    }
    
    //	OPLog(@"[filterGroup filterAtIndex:0] : %@", [[[filterGroup filterAtIndex:0] class] description]);
    
    //	if (gray) {
    //		[filterGroup setInitialFilters:[NSArray arrayWithObjects:[filterGroup filterAtIndex:0], [filterGroup filterAtIndex:1], nil]];
    //	}
    //	else {
    [filterGroup setInitialFilters:[NSArray arrayWithObject:[filterGroup filterAtIndex:0]]];
    //	}
    
    [filterGroup setTerminalFilter:[filterGroup filterAtIndex:[filterGroup filterCount] - 1]];
    
    return filterGroup;
}

@end
