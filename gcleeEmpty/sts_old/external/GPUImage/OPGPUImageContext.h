#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import "OPGLProgram.h"

#define OPGPUImageRotationSwapsWidthAndHeight(rotation) ((rotation) == kOPGPUImageRotateLeft || (rotation) == kOPGPUImageRotateRight || (rotation) == kOPGPUImageRotateRightFlipVertical || (rotation) == kOPGPUImageRotateRightFlipHorizontal)

typedef enum { kOPGPUImageNoRotation, kOPGPUImageRotateLeft, kOPGPUImageRotateRight, kOPGPUImageFlipVertical, kOPGPUImageFlipHorizonal, kOPGPUImageRotateRightFlipVertical, kOPGPUImageRotateRightFlipHorizontal, kOPGPUImageRotate180 } OPGPUImageRotationMode;

@interface OPGPUImageContext : NSObject

@property(readonly, nonatomic) dispatch_queue_t contextQueue;
@property(readwrite, retain, nonatomic) OPGLProgram *currentShaderProgram;
@property(readonly, retain, nonatomic) EAGLContext *context;

+ (void *)contextKey;
+ (OPGPUImageContext *)sharedImageProcessingContext;
+ (dispatch_queue_t)sharedContextQueue;
+ (void)useImageProcessingContext;
+ (void)setActiveShaderProgram:(OPGLProgram *)shaderProgram;
+ (GLint)maximumTextureSizeForThisDevice;
+ (GLint)maximumTextureUnitsForThisDevice;
+ (BOOL)deviceSupportsOpenGLESExtension:(NSString *)extension;
+ (BOOL)deviceSupportsRedTextures;
+ (BOOL)deviceSupportsFramebufferReads;
+ (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize;

- (void)presentBufferForDisplay;
- (OPGLProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;

- (void)useSharegroup:(EAGLSharegroup *)sharegroup;

// Manage fast texture upload
+ (BOOL)supportsFastTextureUpload;

// Modified by FUTUREWIZ
//  : cancel 시킬 때 기존에 있던 dispatch_queue 관리 블럭들을 모두 리셋시키기 위한 함수
+ (void)resetSharedContextQueue;

@end

@protocol OPGPUImageTextureDelegate;

@protocol OPGPUImageInput <NSObject>
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex;
- (void)setTextureDelegate:(id<OPGPUImageTextureDelegate>)newTextureDelegate atIndex:(NSInteger)textureIndex;
- (NSInteger)nextAvailableTextureIndex;
- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
- (void)setInputRotation:(OPGPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
- (CGSize)maximumOutputSize;
- (void)endProcessing;
- (BOOL)shouldIgnoreUpdatesToThisTarget;
- (BOOL)enabled;
- (void)conserveMemoryForNextFrame;
- (BOOL)wantsMonochromeInput;
- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;
@end

@protocol OPGPUImageTextureDelegate <NSObject>
- (void)textureNoLongerNeededForTarget:(id<OPGPUImageInput>)textureTarget;
@end

