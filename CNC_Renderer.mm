#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>

#include "CNC_Types.h"

@interface Renderer : NSObject<MTKViewDelegate>
{
    @public
        id<MTLDevice>       m_device;
        id<MTLCommandQueue> m_queue;
        MTKView*            m_view;
        
}

- (void)Render;
@end

@implementation Renderer

- (void)Render
{
    [m_view draw];
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    @autoreleasepool
    {
        id<MTLCommandBuffer> commandBuffer = [m_queue commandBuffer];
        id<MTLCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:[m_view currentRenderPassDescriptor]];

        [commandEncoder endEncoding];

        [commandBuffer presentDrawable:[m_view currentDrawable]];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{

}

@end

Renderer* CreateRenderer( u32 width, u32 height )
{
    Renderer* renderer = [Renderer new];

    CGRect contentFrame = CGRectMake( 0, 0, width, height );

    renderer->m_device        = MTLCreateSystemDefaultDevice();
    renderer->m_view          = [[MTKView alloc] initWithFrame: contentFrame 
                                                       device: renderer->m_device];
    renderer->m_queue         = [renderer->m_device newCommandQueue];
    renderer->m_view.delegate = renderer;      
    renderer->m_view.clearColor = MTLClearColorMake( 1.0, 0.0, 1.0, 1.0 );


    return renderer;
}