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
        id<MTLRenderPipelineState> m_renderPipelineState;
        MTKView*                   m_view;

        struct VertexInput         m_quadVertices[6];
        struct UniformData         m_uniform;
        id<MTLBuffer>              m_uniformBuffer;
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

    m_renderPipelineState = [m_device newRenderPipelineStateWithDescriptor:renderDesc error: &error];

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
        id<MTLCommandBuffer>        commandBuffer = [m_queue commandBuffer];
        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:[m_view currentRenderPassDescriptor]];

        [encoder setRenderPipelineState: m_renderPipelineState];
        [encoder setVertexBytes: m_quadVertices length: sizeof( struct VertexInput ) * 6 atIndex:0];
        [encoder setVertexBuffer: m_uniformBuffer offset: 0 atIndex: 0];
        [encoder drawPrimitives: MTLPrimitiveTypeTriangle vertexStart: 0 vertexCount: 6];
        
        [encoder endEncoding];

        [commandBuffer presentDrawable:[m_view currentDrawable]];
        [commandBuffer commit];
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    f32 w = size.width;
    f32 h = size.height;

    v2 screenSize = { w, h };
    m_uniform.m_screenSize = screenSize;

    memcpy( [m_uniformBuffer contents], &m_uniform, sizeof( struct UniformData ) );
}

@end

void CreateQuad( Renderer* renderer, f32 w, f32 h )
{
    /*
        D ---- C
        |      |
        A ---- B
     */
     struct VertexInput* quad = renderer->m_quadVertices;

    v3 A = { 0.0f,    h, 0.0f };
    v3 B = {    w,    h, 0.0f };
    v3 C = {    w, 0.0f, 0.0f };
    v3 D = { 0.0f, 0.0f, 0.0f };

    /*
        P4 ---- P3
        |       |
        P1 ---- P2
     */

    v2 P1 = { 0.0f, 0.0f };
    v2 P2 = { 1.0f, 0.0f };
    v2 P3 = { 1.0f, 1.0f };
    v2 P4 = { 0.0f, 1.0f };

    quad[0].m_position = A;
    quad[0].m_uv       = P1;
    quad[1].m_position = B;
    quad[1].m_uv       = P2;
    quad[2].m_position = C;
    quad[2].m_uv       = P3;
    quad[3].m_position = C;
    quad[3].m_uv       = P3;
    quad[4].m_position = D;
    quad[4].m_uv       = P4;
    quad[5].m_position = A;  
    quad[5].m_uv       = P1;  
}

void CreateProjection2d( Renderer* renderer, f32 w, f32 h )
{
    /*
        upper left in world space is 0,0
        upper left in projection space -1,1

        lower right in world space is 1,1
        lower right in projection space is 1,-1

        |x| |a 0 0 e|
        |y| |0 b 0 f|
        |0| |0 0 1 0|
        |1| |0 0 0 1|

        result is:
        (x*a) + (y*0) + (0*0) + (1*e)
        (x*0) + (y*b) + (0*1) + (1*f)
        0
        1

        now we need to solve this for a, b, e and f
        
        with x=0 we get x'=-1
        f(0) = 0 + 0 + 0 + 1*e = -1 => e = -1
        
        with x=w we get x'=1
        f(w) = (w*a) + 0 + 0 - 1 = 1
        w*a = 2 => a = 2/w
        
        with y=0 we get y'=1
        f(0) = 0 + 0 + 0 + f = 1 => f = 1
        
        with y=h we get y'=-1
        f(h) = 0 + (h*b) + 0 + 1 = -1
        h*b + 1 = -1
        h*b = -2
        b = -2/h
     */

    f32 e = -1.0f;     
    f32 f =  1.0f;
    f32 a =  2.0f/w;
    f32 b = -2.0f/h;

    v4 row1 = { 2.0f/w,    0.0f, 0.0f,    e };
    v4 row2 = {   0.0f, -2.0f/h, 0.0f,    f };
    v4 row3 = {   0.0f,    0.0f, 1.0f, 0.0f };
    v4 row4 = {   0.0f,    0.0f, 0.0f, 1.0f };

    v2 screenSize = { w, h };
    renderer->m_uniform.m_projection2d = simd_matrix_from_rows( row1, row2, row3, row4 );
    renderer->m_uniform.m_screenSize   = screenSize;

    renderer->m_uniformBuffer = [renderer->m_device newBufferWithLength: sizeof( struct UniformData )
                                                                options: MTLResourceCPUCacheModeDefaultCache];

    memcpy( [renderer->m_uniformBuffer contents], &renderer->m_uniform, sizeof( struct UniformData ) );
}

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
    
    f32 w = renderer->m_view.frame.size.width;
    f32 h = renderer->m_view.frame.size.height;
    
    CreateQuad( renderer, w, h );
    CreateProjection2d( renderer, w, h );

    return renderer;
}
