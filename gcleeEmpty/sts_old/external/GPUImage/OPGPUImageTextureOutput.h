#import <Foundation/Foundation.h>
#import "OPGPUImageContext.h"

@protocol OPGPUImageTextureOutputDelegate;

@interface OPGPUImageTextureOutput : NSObject <OPGPUImageInput>
{
    __unsafe_unretained id<OPGPUImageTextureDelegate> textureDelegate;
}

@property(readwrite, unsafe_unretained, nonatomic) id<OPGPUImageTextureOutputDelegate> delegate;
@property(readonly) GLuint texture;
@property(nonatomic) BOOL enabled;

@end

@protocol OPGPUImageTextureOutputDelegate
- (void)newFrameReadyFromTextureOutput:(OPGPUImageTextureOutput *)callbackTextureOutput;
@end
