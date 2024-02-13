#include "CNC_Types.h"
#include "CNC_Platform.h"
#include <stdlib.h>
#include <assert.h>

#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
#include "libs/stb_image.h"

struct MemoryPool* CreateMemoryPool( u32 sizeInBytes )
{
    void* data = malloc( sizeInBytes + sizeof( struct MemoryPool) );
    
    struct MemoryPool* pool = ( struct MemoryPool* )data;
    pool->m_size      = sizeInBytes;
    pool->m_usedBytes = 0;
    pool->m_freeBytes = sizeInBytes;
    pool->m_memory    = (u8*)data + sizeof( struct MemoryPool );

    return pool;
}

void InitPlatform( struct Platform* platform, void* renderer )
{
    platform->loadImage     = &LoadImageFile;
    platform->uploadToGpu   = &UploadToGpu;
    platform->freeImageFile = &FreeImageFile;
    platform->m_renderer    = renderer;
}

void* AllocateStruct( u32 sizeInBytes, struct MemoryPool* pool )
{
    assert( pool->m_freeBytes >= sizeInBytes );
    void* data = (u8*)pool->m_memory + pool->m_usedBytes;

    pool->m_usedBytes += sizeInBytes;
    pool->m_freeBytes -= sizeInBytes;

    return data;
}

struct ImageFile* LoadImageFile( const char* filename, struct MemoryPool* pool )
{
    struct ImageFile* image = AllocStruct( struct ImageFile, pool );

    s32 channels = 0;
    image->m_data = stbi_load( filename, &image->m_width, &image->m_height, &channels, 4 );

    assert( image->m_data != NULL );

    return image;
}

void FreeImageFile( struct ImageFile* image )
{
    stbi_image_free( image->m_data );
}
