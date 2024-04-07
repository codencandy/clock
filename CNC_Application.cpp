#include "CNC_Application.h"
#include <time.h>

void createTextureVertices( VertexInput* vertices, f32 w, f32 h, f32 x, f32 y );
void updateTextureVertices( VertexInput* vertices, u32 numVertices, f32 angle );

void Load( Application* application )
{
    Platform* platform = &application->m_platform;

    application->m_permanentMemory = CreateMemoryPool( MEGABYTE(100) );
    application->m_transientMemory = CreateMemoryPool( MEGABYTE(100) );

    ImageFile* bg      = platform->loadImage( "res/clock_bg.png",      application->m_permanentMemory );
    ImageFile* knob    = platform->loadImage( "res/clock_knob.png",    application->m_permanentMemory );
    ImageFile* hours   = platform->loadImage( "res/clock_hours.png",   application->m_permanentMemory );
    ImageFile* minutes = platform->loadImage( "res/clock_minutes.png", application->m_permanentMemory );
    ImageFile* dash    = platform->loadImage( "res/clock_dash.png",    application->m_permanentMemory );

    void* renderer = platform->m_renderer;

    bg->m_textureId      = platform->uploadToGpu( bg,      renderer );
    knob->m_textureId    = platform->uploadToGpu( knob,    renderer );
    hours->m_textureId   = platform->uploadToGpu( hours,   renderer );
    minutes->m_textureId = platform->uploadToGpu( minutes, renderer );
    dash->m_textureId    = platform->uploadToGpu( dash,    renderer );

    application->m_bg      = bg;
    application->m_knob    = knob;
    application->m_hours   = hours;
    application->m_minutes = minutes;
    application->m_dash    = dash;

    platform->freeImageFile( bg );
    platform->freeImageFile( knob );
    platform->freeImageFile( hours );
    platform->freeImageFile( minutes );
    platform->freeImageFile( dash );
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

    clock->m_hoursAngle   = (CNC_2PI / 12.0) * ((f32)clock->m_hours + ((f32)clock->m_minutes) / 60.0f);
    clock->m_minutesAngle = (CNC_2PI / 60.0) * clock->m_minutes;
    clock->m_secondsAngle = (CNC_2PI / 60.0) * clock->m_seconds;
}

void Render( Application* application )
{
    MemoryPool* transientPool = application->m_transientMemory;
    ClearMemoryPool( transientPool );

    // render the clock
    DrawCall* background = AllocStruct( DrawCall, transientPool );
    DrawCall* newMinutes = AllocStruct( DrawCall, transientPool );
    DrawCall* newHours   = AllocStruct( DrawCall, transientPool );
    DrawCall* knob       = AllocStruct( DrawCall, transientPool );
    DrawCall* dash       = AllocStruct( DrawCall, transientPool );

    f32 w = 600.0f;
    f32 h = 600.0f;

    background->m_textureId = application->m_bg->m_textureId;
    background->m_size      = vec2( w, h );
    background->m_position  = vec2( 0.0f, 0.0f );
    background->m_angle     = 0.0f;
    createTextureVertices( background->m_vertices, w, h, 0.0f, 0.0f );
    
    v2 minutesSize = vec2( application->m_minutes->m_width, application->m_minutes->m_height );
    newMinutes->m_textureId = application->m_minutes->m_textureId;
    newMinutes->m_size      = minutesSize;
    newMinutes->m_position  = vec2( w/2, h/2);
    newMinutes->m_angle     = application->m_clock.m_minutesAngle;
    createTextureVertices( newMinutes->m_vertices, minutesSize.x, minutesSize.y, w/2 - (minutesSize.x / 2), h/2 - (minutesSize.y) );
    updateTextureVertices( newMinutes->m_vertices, 6, application->m_clock.m_minutesAngle ); 

    v2 hoursSize = vec2( application->m_hours->m_width, application->m_hours->m_height );
    newHours->m_textureId = application->m_hours->m_textureId;
    newHours->m_size      = hoursSize;
    newHours->m_position  = vec2( w/2, h/2 );
    newHours->m_angle     = application->m_clock.m_hoursAngle;
    createTextureVertices( newHours->m_vertices, hoursSize.x, hoursSize.y, w/2 - (hoursSize.x / 2), h/2 - (hoursSize.y) );
    updateTextureVertices( newHours->m_vertices, 6, application->m_clock.m_hoursAngle );

    v2 knobSize = vec2( application->m_knob->m_width, application->m_knob->m_height );
    knob->m_textureId = application->m_knob->m_textureId;
    knob->m_size      = knobSize;
    knob->m_position  = vec2( w/2, h/2 );
    knob->m_angle     = 0.0f;
    createTextureVertices( knob->m_vertices, knobSize.x, knobSize.y, w/2 - (knobSize.x / 2), h/2 - (knobSize.y / 2) );
    updateTextureVertices( knob->m_vertices, 6, 0.0f );

    v2 dashSize = vec2( application->m_dash->m_width, application->m_dash->m_height );
    dash->m_textureId = application->m_dash->m_textureId;
    dash->m_size      = dashSize;
    dash->m_position  = vec2( w/2, h/2 );
    createTextureVertices( dash->m_vertices, dashSize.x, dashSize.y, w/2 - (dashSize.x / 2), 90.0f );
    updateTextureVertices( dash->m_vertices, 6, 0.0f );
    
    application->m_platform.submitDrawCalls( transientPool->m_memory, 5, application->m_platform.m_renderer );
}

void Exit( Application* application )
{
    // not needed 
}

// private implementation 
void createTextureVertices( VertexInput* vertices, f32 w, f32 h, f32 x, f32 y )
{
    struct VertexInput* quad = vertices;
    
    /*
        D(0,0) ---- C(w,0)
        |                |
        A(0,h) ---- B(w,h)
    */
    v3 A = {    x,   h+y, 0.0f };
    v3 B = {    x+w, h+y, 0.0f };
    v3 C = {    x+w,   y, 0.0f };
    v3 D = {    x,     y, 0.0f };

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
    quad[0].m_angle    = 0.0f;
    quad[1].m_position = B;
    quad[1].m_uv       = P2;
    quad[1].m_angle    = 0.0f;
    quad[2].m_position = C;
    quad[2].m_uv       = P3;
    quad[2].m_angle    = 0.0f;
    quad[3].m_position = C;
    quad[3].m_uv       = P3;
    quad[3].m_angle    = 0.0f;
    quad[4].m_position = D;
    quad[4].m_uv       = P4;
    quad[4].m_angle    = 0.0f;
    quad[5].m_position = A;  
    quad[5].m_uv       = P1; 
    quad[5].m_angle    = 0.0f; 
}

void updateTextureVertices( VertexInput* vertices, u32 numVertices, f32 angle )
{
    struct VertexInput* quad = vertices;

    for( u32 i=0; i<numVertices; ++i )
    {
        quad[i].m_angle = angle;
    }
}
