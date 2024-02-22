#include <metal_stdlib>

using namespace metal;

struct VertexInput
{
    float3 m_position [[attribute(0)]];
    float2 m_uv       [[attribute(1)]];
    float  m_angle    [[attribute(2)]];
};

struct VertexOutput
{
    float4 m_position [[position]];
    float2 m_uv;
};

struct UniformData
{
    float4x4 m_projection2d;
    float2   m_screenSize;
};

constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

vertex VertexOutput VertexShader( VertexInput in [[stage_in]],
                                  constant UniformData& uniform [[buffer(1)]] )
{
    VertexOutput out;

    float angle = in.m_angle;
    // rotate the vertices 
    float2x2 rotationMatrix = {
        { cos(angle), -sin(angle) }, // important to define row major
        { sin(angle),  cos(angle) }  // important to define row major
    };

    float4 position   = float4( in.m_position, 1.0 );

    out.m_position    = uniform.m_projection2d * position;
    out.m_position.xy = out.m_position.xy * rotationMatrix;
    out.m_uv          = in.m_uv;

    return out;
}                   

fragment float4 FragmentShader( VertexOutput in [[stage_in]],
                                texture2d<float> image )
{
    float4 color = image.sample( textureSampler, in.m_uv );
    return color;
}
