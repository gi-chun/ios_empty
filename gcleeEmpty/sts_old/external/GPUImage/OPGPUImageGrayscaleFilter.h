#import "OPGPUImageFilter.h"

extern NSString *const kOPGPUImageLuminanceFragmentShaderString;

/** Converts an image to grayscale (a slightly faster implementation of the saturation filter, without the ability to vary the color contribution)
 */
@interface OPGPUImageGrayscaleFilter : OPGPUImageFilter

@end
