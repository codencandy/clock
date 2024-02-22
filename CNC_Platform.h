#ifndef CNC_PLATFORM_H
#define CNC_PLATFORM_H

#include "CNC_Types.h"

struct MemoryPool
{
    u32   m_size;
    u32   m_usedBytes;
    u32   m_freeBytes;
    void* m_memory;
};

struct Platform
{
    // these are the services offered by the platform
    ImageFile* (*loadImage)(const char* imageFile, struct MemoryPool* pool );
    u32  (*uploadToGpu)(ImageFile* image, void* renderer);
    void (*freeImageFile)(ImageFile* image );
    void (*submitDrawCalls)(void*, u32, void* );

    void* m_renderer;
};

struct MemoryPool* CreateMemoryPool( u32 sizeInBytes );
void               InitPlatform( struct Platform* platform, void* renderer );
void*              AllocateStruct( u32 sizeInBytes, struct MemoryPool* pool );
void               ClearMemoryPool( struct MemoryPool* pool );

struct ImageFile*  LoadImageFile( const char* filename, struct MemoryPool* pool );
u32                UploadToGpu( ImageFile* image, void* renderer );
void               FreeImageFile( ImageFile* image );
void               SubmitDrawCalls( void* memory, u32 numberOfDrawCalls, void* renderer );

#define AllocStruct( x, pool ) (x*)AllocateStruct( sizeof(x), pool )
#define AllocBytes(  x, pool )     AllocateBytes( x, pool )

#endif//CNC_PLATFORM_H
