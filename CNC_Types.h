#ifndef CNC_TYPES_H
#define CNC_TYPES_H

#include <simd/simd.h>

#define SCREEN_WIDTH  600
#define SCREEN_HEIGHT 600
#define CNC_PI 3.14159265359
#define KILOBYTE 1024
#define MEGABYTE(x) (x*KILOBYTE)

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

struct ImageFile
{
    s32   m_width;
    s32   m_height;
    void* m_data;
};

// mirror image of the types passed to the shader
struct VertexInput
{
    v3 m_position;
    v2 m_uv;
};

struct UniformData
{
    m4 m_projection2d;
    v2 m_screenSize;
};

#endif//CNC_TYPES_H
