#ifndef CNC_TYPES_H
#define CNC_TYPES_H

#include <simd/simd.h>

#define SCREEN_WIDTH  600
#define SCREEN_HEIGHT 600
#define CNC_PI 3.14159265359

typedef unsigned int   u32;
typedef unsigned short u16;
typedef unsigned char   u8;

typedef float  f32;
typedef double f64;

typedef simd_float2     v2;
typedef simd_float3     v3;
typedef simd_float3x3   m3;
typedef simd_float4x4   m4;

#endif//CNC_TYPES_H
