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

        struct UniformData         m_uniform;
        id<MTLBuffer>              m_uniformBuffer;

        u32                        m_nextTextureId;
        NSMutableArray*            m_textures;

        u32                        m_nrOfDrawCalls;
        void*                      m_drawCallMemory;
};

- (void)Prepare;
- (void)Render;
- (u32)UploadTexture:(struct ImageFile*)image;

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

    vertexDesc.attributes[2].bufferIndex = 0;
    vertexDesc.attributes[2].format      = MTLVertexFormatFloat;
    vertexDesc.attributes[2].offset      = offsetof( struct VertexInput, m_angle );

    vertexDesc.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    vertexDesc.layouts[0].stride       = sizeof( struct VertexInput );

    renderDesc.vertexDescriptor = vertexDesc;
    renderDesc.colorAttachments[0].pixelFormat = [m_view colorPixelFormat];
    renderDesc.vertexFunction   = vertexShader;
    renderDesc.fragmentFunction = fragmentShader;

    renderDesc.colorAttachments[0].blendingEnabled = true;
    renderDesc.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    renderDesc.colorAttachments[0].rgbBlendOperation   = MTLBlendOperationAdd;

    renderDesc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    renderDesc.colorAttachments[0].sourceRGBBlendFactor   = MTLBlendFactorSourceAlpha;

    renderDesc.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    renderDesc.colorAttachments[0].destinationRGBBlendFactor   = MTLBlendFactorOneMinusSourceAlpha;

    m_renderPipelineState = [m_device newRenderPipelineStateWithDescriptor:renderDesc error: &error];

    CheckError( error );

    m_textures      = [[NSMutableArray alloc] initWithCapacity:10];
    m_nextTextureId = 0;
}

- (void)Render
{
    [m_view draw];
}

- (u32)UploadTexture:(struct ImageFile*)image
{
    u32 textureId = m_nextTextureId;

    MTLTextureDescriptor* textureDesc = [MTLTextureDescriptor new];
    textureDesc.width       = image->m_width;
    textureDesc.height      = image->m_height;
    textureDesc.pixelFormat = MTLPixelFormatRGBA8Unorm;
    id<MTLTexture> texture  = [m_device newTextureWithDescriptor: textureDesc];

    MTLRegion region = MTLRegionMake2D( 0, 0, image->m_width, image->m_height );
    [texture replaceRegion: region mipmapLevel: 0 withBytes: image->m_data bytesPerRow:image->m_width * 4];
    [m_textures addObject: texture];

    m_nextTextureId++;
    return textureId;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    @autoreleasepool
    {
        id<MTLCommandBuffer>        commandBuffer = [m_queue commandBuffer];
        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:[m_view currentRenderPassDescriptor]];

        [encoder setRenderPipelineState: m_renderPipelineState];

        // only need once
        
        struct DrawCall* drawCalls = (struct DrawCall*)m_drawCallMemory;
        for( u32 i=0; i<m_nrOfDrawCalls; ++i )
        {
            struct DrawCall* call = &drawCalls[i];
            [encoder setVertexBytes: call->m_vertices length: sizeof( struct VertexInput ) * 6 atIndex:0];
            [encoder setVertexBuffer: m_uniformBuffer offset: 0 atIndex: 1];
            [encoder setFragmentTexture: [m_textures objectAtIndex: call->m_textureId ] atIndex:0];
            [encoder drawPrimitives: MTLPrimitiveTypeTriangle vertexStart: 0 vertexCount: 6];
        }
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
    
    CreateProjection2d( renderer, w, h );

    return renderer;
}

u32 UploadToGpu( struct ImageFile* image, void* renderer )
{
    Renderer* macosRenderer = (Renderer*)renderer;
    u32 textureId = [macosRenderer UploadTexture: image];

    return textureId;
}

void SubmitDrawCalls( void* memory, u32 numberOfDrawCalls, void* renderer )
{
    Renderer* macosRenderer = (Renderer*)renderer;
    macosRenderer->m_drawCallMemory = memory;
    macosRenderer->m_nrOfDrawCalls  = numberOfDrawCalls;
}
