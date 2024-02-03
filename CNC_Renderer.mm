#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>

@interface Renderer : NSObject<MTKViewDelegate>
{
    @public
        id<MTLDevice>       m_device;
        id<MTLCommandQueue> m_queue;
        
}
@end

@implementation Renderer

- (void)drawInMTKView:(nonnull MTKView *)view
{

}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{

}

@end