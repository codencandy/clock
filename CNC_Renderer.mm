#include <Metal/Metal.h>
#include <MetalKit/MetalKit.h>

#include "CNC_Types.h"

void CheckError( NSError* error )
{
    if( error != NULL )
    {
        NSLog( @"%@", [error localizedDescription] );
    }
}

@interface Renderer : NSObject<MTKViewDelegate>
{
    @public
        id<MTLDevice>              m_device;
        id<MTLCommandQueue>        m_queue;
        id<MTLRenderPipelineState> m_pipelineState;
        MTKView*                   m_view;
}

- (void)Prepare;
- (void)Render;

@end

@implementation Renderer

- (void)Prepare
{
    NSError* error = NULL;

    // 1. create the vertexa and fragment shader
    // 2. create the render pipeline state
    // 3. create the 2d projection matrix
    // 4. create default vertices 

    NSString* shaderSource = [NSString stringWithContentsOfFile: @"CNC_Shader.metal"
                                                       encoding: NSUTF8StringEncoding
                                                          error: &error];

    CheckError( error );

    MTLCompileOptions* options = [MTLCompileOptions new];
    id<MTLLibrary> library = [m_device newLibraryWithSource: shaderSource
                                                    options: options
                                                      error: &error];

    CheckError( error );                                                      

    id<MTLFunction> vertexShader   = [library newFunctionWithName: @"VertexShader" ];
    id<MTLFunction> fragmentShader = [library newFunctionWithName: @"FragmentShader" ];                                                      

    if( vertexShader == NULL || fragmentShader == NULL )
    {
        NSLog( @"error reading shaders" );
    }
    
    MTLRenderPipelineDescriptor* renderDesc = [MTLRenderPipelineDescriptor new];
    MTLVertexDescriptor*         vertexDesc = [MTLVertexDescriptor new];

    vertexDesc.attributes[0].bufferIndex = 0;
    vertexDesc.attributes[0].format      = MTLVertexFormatFloat3;
    vertexDesc.attributes[0].offset      = offsetof( struct VertexInput, m_position );

    vertexDesc.attributes[1].bufferIndex = 0;
    vertexDesc.attributes[1].format      = MTLVertexFormatFloat2;
    vertexDesc.attributes[1].offset      = offsetof( struct VertexInput, m_uv );

    vertexDesc.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    vertexDesc.layouts[0].stride       = sizeof( struct VertexInput );

    renderDesc.vertexDescriptor = vertexDesc;
    renderDesc.colorAttachments[0].pixelFormat = [m_view colorPixelFormat];
    renderDesc.vertexFunction   = vertexShader;
    renderDesc.fragmentFunction = fragmentShader;

    m_pipelineState = [m_device newRenderPipelineStateWithDescriptor:renderDesc error: &error];

    CheckError( error );
}

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

    [renderer Prepare];

    return renderer;
}