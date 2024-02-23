#include "CNC_Application.h"
#include <time.h>

void createTextureVertices( VertexInput* vertices, f32 w, f32 h );
void updateTextureVertices( VertexInput* vertices, u32 numVertices, f32 angle );
void printTimeDetails( Clock* clock );

void Load( Application* application )
{
    Platform* platform = &application->m_platform;

    application->m_permanentMemory = CreateMemoryPool( MEGABYTE(100) );
    application->m_transientMemory = CreateMemoryPool( MEGABYTE(100) );

    ImageFile* background  = platform->loadImage( "res/background.png", application->m_permanentMemory );
    ImageFile* hoursHand   = platform->loadImage( "res/hours_hand.png", application->m_permanentMemory );
    ImageFile* minutesHand = platform->loadImage( "res/minutes_hand.png", application->m_permanentMemory );
    ImageFile* secondsHand = platform->loadImage( "res/seconds_hand.png", application->m_permanentMemory );

    void* renderer = platform->m_renderer;

    background->m_textureId  = platform->uploadToGpu( background, renderer );
    hoursHand->m_textureId   = platform->uploadToGpu( hoursHand, renderer );
    minutesHand->m_textureId = platform->uploadToGpu( minutesHand, renderer );
    secondsHand->m_textureId = platform->uploadToGpu( secondsHand, renderer );

    application->m_background  = background;
    application->m_hoursHand   = hoursHand;
    application->m_minutesHand = minutesHand;
    application->m_secondsHand = secondsHand;

    application->m_vertices = (VertexInput*)AllocBytes( sizeof( VertexInput) * 6 * 4, application->m_permanentMemory );
    VertexInput* vertices   = application->m_vertices;
    
    for( u32 i=0; i<4; ++i )
    {
        vertices = &vertices[i*6];
        createTextureVertices( vertices, SCREEN_WIDTH, SCREEN_HEIGHT );
    }

    platform->freeImageFile( background );
    platform->freeImageFile( hoursHand );
    platform->freeImageFile( minutesHand );
    platform->freeImageFile( secondsHand );
}

void Update( Application* application )
{
    // update the clock
    Clock* clock = &application->m_clock;

    time_t now  = time(NULL);
    tm*    time = localtime(&now); 

    clock->m_hours   = time->tm_hour % 12;
    clock->m_minutes = time->tm_min;
    clock->m_seconds = time->tm_sec;

    clock->m_hoursAngle   = (CNC_2PI / 12.0) * clock->m_hours;
    clock->m_minutesAngle = (CNC_2PI / 60.0) * clock->m_minutes;
    clock->m_secondsAngle = (CNC_2PI / 60.0) * clock->m_seconds;

    printTimeDetails( clock );

    VertexInput* vertices = application->m_vertices;

    VertexInput* backgroundVertices  = &vertices[0];
    VertexInput* hourHandVertices    = &vertices[6];
    VertexInput* minutesHandVertices = &vertices[12];
    VertexInput* secondsHandVertices = &vertices[18];

    updateTextureVertices( hourHandVertices,    6, clock->m_hoursAngle );
    updateTextureVertices( minutesHandVertices, 6, clock->m_minutesAngle );
    updateTextureVertices( secondsHandVertices, 6, clock->m_secondsAngle );
}

void Render( Application* application )
{
    MemoryPool* transientPool = application->m_transientMemory;
    ClearMemoryPool( transientPool );

    // render the clock
    DrawCall* background = AllocStruct( DrawCall, transientPool );
    DrawCall* hours      = AllocStruct( DrawCall, transientPool );
    DrawCall* minutes    = AllocStruct( DrawCall, transientPool );
    DrawCall* seconds    = AllocStruct( DrawCall, transientPool );

    f32 w = 600.0f;
    f32 h = 600.0f;

    background->m_textureId = application->m_background->m_textureId;
    background->m_size      = vec2( w, h );
    background->m_position  = vec2( 0.0f, 0.0f );
    background->m_angle     = 0.0f;
    background->m_vertices  = application->m_vertices;

    hours->m_textureId      = application->m_hoursHand->m_textureId;
    hours->m_size           = vec2( w, h );
    hours->m_position       = vec2( 0.0f, 0.0f );
    hours->m_angle          = application->m_clock.m_hoursAngle;
    hours->m_vertices       = &application->m_vertices[6];

    minutes->m_textureId    = application->m_minutesHand->m_textureId;
    minutes->m_size         = vec2( w, h );
    minutes->m_position     = vec2( 0.0f, 0.0f );
    minutes->m_angle        = application->m_clock.m_minutesAngle;
    minutes->m_vertices     = &application->m_vertices[12];

    seconds->m_textureId    = application->m_secondsHand->m_textureId;
    seconds->m_size         = vec2( w, h );
    seconds->m_position     = vec2( 0.0f, 0.0f );
    seconds->m_angle        = application->m_clock.m_secondsAngle;
    seconds->m_vertices     = &application->m_vertices[18];

    application->m_platform.submitDrawCalls( transientPool->m_memory, 4, application->m_platform.m_renderer );
}

void Exit( Application* application )
{
    // not needed 
}

// private implementation 
void createTextureVertices( VertexInput* vertices, f32 w, f32 h )
{
    /*
        D ---- C
        |      |
        A ---- B
     */
    struct VertexInput* quad = vertices;

    v3 A = { 0.0f,    h, 0.0f };
    v3 B = {    w,    h, 0.0f };
    v3 C = {    w, 0.0f, 0.0f };
    v3 D = { 0.0f, 0.0f, 0.0f };

    /*
        P4(0,0) ---- P3(1,0)
        |                  |
        P1(0,1) ---- P2(1,1)
     */

    v2 P1 = { 0.0f, 1.0f };
    v2 P2 = { 1.0f, 1.0f };
    v2 P3 = { 1.0f, 0.0f };
    v2 P4 = { 0.0f, 0.0f };

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

void updateTextureVertices( VertexInput* vertices, u32 numVertices, f32 angle )
{
    struct VertexInput* quad = vertices;

    for( u32 i=0; i<numVertices; ++i )
    {
        quad[i].m_angle = angle;
    }
}

void printTimeDetails( Clock* clock )
{
    f32 toDegreesFactor = CNC_2PI / 360.0f;

    printf( "%d:%d:%d\n", clock->m_hours, clock->m_minutes, clock->m_seconds );
    printf( "hours angle:   %f\n", clock->m_hoursAngle   / toDegreesFactor );
    printf( "minutes angle: %f\n", clock->m_minutesAngle / toDegreesFactor );
    printf( "seconds angle: %f\n", clock->m_secondsAngle / toDegreesFactor );
    fflush( NULL );
}