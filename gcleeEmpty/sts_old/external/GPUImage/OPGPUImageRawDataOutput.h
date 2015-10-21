#import <Foundation/Foundation.h>
#import "OPGPUImageContext.h"

struct OPGPUByteColorVector {
    GLubyte red;
    GLubyte green;
    GLubyte blue;
    GLubyte alpha;
};
typedef struct OPGPUByteColorVector OPGPUByteColorVector;

@protocol OPGPUImageRawDataProcessor;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@interface OPGPUImageRawDataOutput : NSObject <OPGPUImageInput> {
    CGSize imageSize;
    CVOpenGLESTextureCacheRef rawDataTextureCache;
    CVPixelBufferRef renderTarget;
    OPGPUImageRotationMode inputRotation;
    BOOL outputBGRA;
    CVOpenGLESTextureRef renderTexture;
    
    __unsafe_unretained id<OPGPUImageTextureDelegate> textureDelegate;
}
#else
@interface OPGPUImageRawDataOutput : NSObject <GPUImageInput> {
    CGSize imageSize;
    CVOpenGLTextureCacheRef rawDataTextureCache;
    CVPixelBufferRef renderTarget;
    OPGPUImageRotationMode inputRotation;
    BOOL outputBGRA;
    CVOpenGLTextureRef renderTexture;
    
    __unsafe_unretained id<OPGPUImageTextureDelegate> textureDelegate;
}
#endif

@property(readonly) GLubyte *rawBytesForImage;
@property(nonatomic, copy) void(^newFrameAvailableBlock)(void);
@property(nonatomic) BOOL enabled;

// Initialization and teardown
- (id)initWithImageSize:(CGSize)newImageSize resultsInBGRAFormat:(BOOL)resultsInBGRAFormat;

// Data access
- (OPGPUByteColorVector)colorAtLocation:(CGPoint)locationInImage;
- (NSUInteger)bytesPerRowInOutput;

- (void)setImageSize:(CGSize)newImageSize;

@end
