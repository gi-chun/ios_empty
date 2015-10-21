#import "OPGPUImageOutput.h"
#import "OPGPUImageFilter.h"

@interface OPGPUImageFilterGroup : OPGPUImageOutput <OPGPUImageInput, OPGPUImageTextureDelegate>
{
    NSMutableArray *filters;
}

@property(readwrite, nonatomic, strong) OPGPUImageOutput<OPGPUImageInput> *terminalFilter;
@property(readwrite, nonatomic, strong) NSArray *initialFilters;
@property(readwrite, nonatomic, strong) OPGPUImageOutput<OPGPUImageInput> *inputFilterToIgnoreForUpdates; 
@property(readwrite, nonatomic) BOOL isEndProcessing;

// Filter management
- (void)addFilter:(OPGPUImageOutput<OPGPUImageInput> *)newFilter;
- (OPGPUImageOutput<OPGPUImageInput> *)filterAtIndex:(NSUInteger)filterIndex;
- (NSUInteger)filterCount;

@end
