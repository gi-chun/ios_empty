#import "OPGPUImageOutput.h"

// The bytes passed into this input are not copied or retained, but you are free to deallocate them after they are used by this filter.
// The bytes are uploaded and stored within a texture, so nothing is kept locally.
// The default format for input bytes is GPUPixelFormatBGRA, unless specified with pixelFormat:
// The default type for input bytes is GPUPixelTypeUByte, unless specified with pixelType:

typedef enum {
	OPGPUPixelFormatBGRA = GL_BGRA,
	OPGPUPixelFormatRGBA = GL_RGBA,
	OPGPUPixelFormatRGB = GL_RGB
} OPGPUPixelFormat;

typedef enum {
	OPGPUPixelTypeUByte = GL_UNSIGNED_BYTE,
	OPGPUPixelTypeFloat = GL_FLOAT
} OPGPUPixelType;

@interface OPGPUImageRawDataInput : OPGPUImageOutput
{
    CGSize uploadedImageSize;
	
	dispatch_semaphore_t dataUpdateSemaphore;
}

// Initialization and teardown
- (id)initWithBytes:(GLubyte *)bytesToUpload size:(CGSize)imageSize;
- (id)initWithBytes:(GLubyte *)bytesToUpload size:(CGSize)imageSize pixelFormat:(OPGPUPixelFormat)pixelFormat;
- (id)initWithBytes:(GLubyte *)bytesToUpload size:(CGSize)imageSize pixelFormat:(OPGPUPixelFormat)pixelFormat type:(OPGPUPixelType)pixelType;

/** Input data pixel format
 */
@property (readwrite, nonatomic) OPGPUPixelFormat pixelFormat;
@property (readwrite, nonatomic) OPGPUPixelType   pixelType;

// Image rendering
- (void)updateDataFromBytes:(GLubyte *)bytesToUpload size:(CGSize)imageSize;
- (void)processData;
- (CGSize)outputImageSize;

@end
