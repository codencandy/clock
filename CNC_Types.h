#ifndef CNC_TYPES_H
#define CNC_TYPES_H

#include <simd/simd.h>

#define SCREEN_WIDTH  600
#define SCREEN_HEIGHT 600
#define CNC_PI        3.14159265359
#define CNC_2PI       (CNC_PI * 2)
#define CNC_PIHALF    (CNC_PI / 2)
#define KILOBYTE      1024
#define MEGABYTE(x)   (x*KILOBYTE)

typedef unsigned int   u32;
typedef unsigned short u16;
typedef unsigned char   u8;

typedef signed int   s32;
typedef signed short s16;

typedef float  f32;
typedef double f64;

typedef simd_float2     v2;
typedef simd_float3     v3;
typedef simd_float4     v4;
typedef simd_float3x3   m3;
typedef simd_float4x4   m4;

v2 vec2( f32 a, f32 b )
{
    v2 result;
    result.x = a;
    result.y = b;
    return result;
}

// mirror image of the types passed to the shader
struct VertexInput
{
    v3  m_position;
    v2  m_uv;
    f32 m_angle;
};

struct UniformData
{
    m4 m_projection2d;
    v2 m_screenSize;
};

struct DrawCall
{
    VertexInput  m_vertices[6];
    u32          m_textureId;
    v2           m_position; // upper left corner
    v2           m_size;
    f32          m_angle;
};

struct ImageFile
{
    s32   m_width;
    s32   m_height;
    u32   m_textureId;
    void* m_data;
};


#endif//CNC_TYPES_H
