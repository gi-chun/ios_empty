#import "OPGPUImageFilter.h"

@interface OPGPUImageBuffer : OPGPUImageFilter
{
    NSMutableArray *bufferedTextures;
}

@property(readwrite, nonatomic) NSUInteger bufferSize;

@end
