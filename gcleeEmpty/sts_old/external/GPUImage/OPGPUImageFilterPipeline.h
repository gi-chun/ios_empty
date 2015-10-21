#import <Foundation/Foundation.h>
#import "OPGPUImageFilter.h"

@interface OPGPUImageFilterPipeline : NSObject
{
    NSString *stringValue;
}

@property (strong) NSMutableArray *filters;

@property (strong) OPGPUImageOutput *input;
@property (strong) id <OPGPUImageInput> output;

- (id) initWithOrderedFilters:(NSArray*) filters input:(OPGPUImageOutput*)input output:(id <OPGPUImageInput>)output;
- (id) initWithConfiguration:(NSDictionary*) configuration input:(OPGPUImageOutput*)input output:(id <OPGPUImageInput>)output;
- (id) initWithConfigurationFile:(NSURL*) configuration input:(OPGPUImageOutput*)input output:(id <OPGPUImageInput>)output;

- (void) addFilter:(OPGPUImageFilter*)filter;
- (void) addFilter:(OPGPUImageFilter*)filter atIndex:(NSUInteger)insertIndex;
- (void) replaceFilterAtIndex:(NSUInteger)index withFilter:(OPGPUImageFilter*)filter;
- (void) replaceAllFilters:(NSArray*) newFilters;
- (void) removeFilterAtIndex:(NSUInteger)index;
- (void) removeAllFilters;

- (UIImage *) currentFilteredFrame;
- (UIImage *) currentFilteredFrameWithOrientation:(UIImageOrientation)imageOrientation;
- (CGImageRef) newCGImageFromCurrentFilteredFrame;
- (CGImageRef) newCGImageFromCurrentFilteredFrameWithOrientation:(UIImageOrientation)imageOrientation;

@end
