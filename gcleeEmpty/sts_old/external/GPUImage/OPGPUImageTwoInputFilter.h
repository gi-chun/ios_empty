#import "OPGPUImageFilter.h"

extern NSString *const kOPGPUImageTwoInputTextureVertexShaderString;

@interface OPGPUImageTwoInputFilter : OPGPUImageFilter
{
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterInputTextureUniform2;
    OPGPUImageRotationMode inputRotation2;
    GLuint filterSourceTexture2;
    CMTime firstFrameTime, secondFrameTime;
    
    BOOL hasSetFirstTexture, hasReceivedFirstFrame, hasReceivedSecondFrame, firstFrameWasVideo, secondFrameWasVideo;
    BOOL firstFrameCheckDisabled, secondFrameCheckDisabled;
    
    __unsafe_unretained id<OPGPUImageTextureDelegate> secondTextureDelegate;
}

- (void)disableFirstFrameCheck;
- (void)disableSecondFrameCheck;

@end
