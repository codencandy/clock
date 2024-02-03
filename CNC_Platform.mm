#include "CNC_Platform.h"
#include <stdlib.h>
#include <assert.h>

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

void InitPlatform( struct Platform* platform )
{
    platform->loadImage     = &LoadImageFile;
    platform->uploadToGpu   = &UploadToGpu;
    platform->freeImageFile = &FreeImageFile;
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

    return image;
}

u32 UploadToGpu( struct ImageFile* image, void* renderer )
{
    u32 textureId = 0;

    return textureId;
}

void FreeImageFile( struct ImageFile* image )
{

}
