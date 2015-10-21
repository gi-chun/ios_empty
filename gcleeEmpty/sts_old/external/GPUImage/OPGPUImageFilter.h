#import "OPGPUImageOutput.h"

#define OPSTRINGIZE(x) #x
#define OPSTRINGIZE2(x) OPSTRINGIZE(x)
#define OPSHADER_STRING(text) @ OPSTRINGIZE2(text)

#define OPGPUImageHashIdentifier #
#define OPGPUImageWrappedLabel(x) x
#define OPGPUImageEscapedHashIdentifier(a) OPGPUImageWrappedLabel(OPGPUImageHashIdentifier)a

extern NSString *const kOPGPUImageVertexShaderString;
extern NSString *const kOPGPUImagePassthroughFragmentShaderString;

struct OPGPUVector4 {
    GLfloat one;
    GLfloat two;
    GLfloat three;
    GLfloat four;
};
typedef struct OPGPUVector4 OPGPUVector4;

struct OPGPUVector3 {
    GLfloat one;
    GLfloat two;
    GLfloat three;
};
typedef struct OPGPUVector3 OPGPUVector3;

struct OPGPUMatrix4x4 {
    OPGPUVector4 one;
    OPGPUVector4 two;
    OPGPUVector4 three;
    OPGPUVector4 four;
};
typedef struct OPGPUMatrix4x4 OPGPUMatrix4x4;

struct OPGPUMatrix3x3 {
    OPGPUVector3 one;
    OPGPUVector3 two;
    OPGPUVector3 three;
};
typedef struct OPGPUMatrix3x3 OPGPUMatrix3x3;

/** GPUImage's base filter class
 
 Filters and other subsequent elements in the chain conform to the GPUImageInput protocol, which lets them take in the supplied or processed texture from the previous link in the chain and do something with it. Objects one step further down the chain are considered targets, and processing can be branched by adding multiple targets to a single output or filter.
 */
@interface OPGPUImageFilter : OPGPUImageOutput <OPGPUImageInput>
{
    GLuint filterSourceTexture;

    GLuint filterFramebuffer;

    OPGLProgram *filterProgram;
    GLint filterPositionAttribute, filterTextureCoordinateAttribute;
    GLint filterInputTextureUniform;
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
    
    BOOL preparedToCaptureImage;
	BOOL isEndProcessing;

    // Texture caches are an iOS-specific capability
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CVOpenGLESTextureCacheRef filterTextureCache;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureRef renderTexture;
#else
#endif
    
    CGSize currentFilterSize;
    OPGPUImageRotationMode inputRotation;
    
    BOOL currentlyReceivingMonochromeInput;
    
    NSMutableDictionary *uniformStateRestorationBlocks;
}

@property(readonly) CVPixelBufferRef renderTarget;
@property(readwrite, nonatomic) BOOL preventRendering;
@property(readwrite, nonatomic) BOOL currentlyReceivingMonochromeInput;
@property(readwrite, nonatomic) BOOL isEndProcessing;

/// @name Initialization and teardown

/**
 Initialize with vertex and fragment shaders
 
 You make take advantage of the OPSHADER_STRING macro to write your shaders in-line.
 @param vertexShaderString Source code of the vertex shader to use
 @param fragmentShaderString Source code of the fragment shader to use
 */
- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;

/**
 Initialize with a fragment shader
 
 You may take advantage of the OPSHADER_STRING macro to write your shader in-line.
 @param fragmentShaderString Source code of fragment shader to use
 */
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
/**
 Initialize with a fragment shader
 @param fragmentShaderFilename Filename of fragment shader to load
 */
- (id)initWithFragmentShaderFromFile:(NSString *)fragmentShaderFilename;
- (void)initializeAttributes;
- (void)setupFilterForSize:(CGSize)filterFrameSize;
- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(OPGPUImageRotationMode)rotation;

- (void)recreateFilterFBO;

/// @name Managing the display FBOs
/** Size of the frame buffer object
 */
- (CGSize)sizeOfFBO;
- (void)createFilterFBOofSize:(CGSize)currentFBOSize;

/** Destroy the current filter frame buffer object
 */
- (void)destroyFilterFBO;
- (void)setFilterFBO;
- (void)setOutputFBO;
- (void)releaseInputTexturesIfNeeded;

/// @name Rendering
+ (const GLfloat *)textureCoordinatesForRotation:(OPGPUImageRotationMode)rotationMode;
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
- (CGSize)outputFrameSize;

/// @name Input parameters
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
- (void)setInteger:(GLint)newInteger forUniformName:(NSString *)uniformName;
- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName;
- (void)setSize:(CGSize)newSize forUniformName:(NSString *)uniformName;
- (void)setPoint:(CGPoint)newPoint forUniformName:(NSString *)uniformName;
- (void)setFloatVec3:(OPGPUVector3)newVec3 forUniformName:(NSString *)uniformName;
- (void)setFloatVec4:(OPGPUVector4)newVec4 forUniform:(NSString *)uniformName;
- (void)setFloatArray:(GLfloat *)array length:(GLsizei)count forUniform:(NSString*)uniformName;

- (void)setMatrix3f:(OPGPUMatrix3x3)matrix forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setMatrix4f:(OPGPUMatrix4x4)matrix forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setFloat:(GLfloat)floatValue forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setPoint:(CGPoint)pointValue forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setSize:(CGSize)sizeValue forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setVec3:(OPGPUVector3)vectorValue forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setVec4:(OPGPUVector4)vectorValue forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setFloatArray:(GLfloat *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;
- (void)setInteger:(GLint)intValue forUniform:(GLint)uniform program:(OPGLProgram *)shaderProgram;

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(OPGLProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock;
- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;

@end
