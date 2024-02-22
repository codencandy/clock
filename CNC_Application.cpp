#include "CNC_Application.h"
#include <time.h>

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

    application->m_vertices    = (VertexInput*)AllocBytes( sizeof( VertexInput) * 6 * 4, application->m_permanentMemory );

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

    clock->m_hoursAngle   = ((2*CNC_PI) / 12.0) * ((clock->m_hours) + (60.0 / clock->m_minutes));
    clock->m_minutesAngle = ((2*CNC_PI) / 60.0) * clock->m_minutes;
    clock->m_secondsAngle = ((2*CNC_PI) / 60.0) * clock->m_seconds;
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

    ImageFile* backgroundImg = application->m_background;
    background->m_textureId = backgroundImg->m_textureId;
    background->m_size      = vec2( backgroundImg->m_width, backgroundImg->m_height );
    background->m_position  = vec2( 0.0f, 0.0f );
    background->m_angle     = 0.0f;

    ImageFile* hoursImg     = application->m_hoursHand;
    hours->m_textureId      = hoursImg->m_textureId;
    hours->m_size           = vec2( hoursImg->m_width, hoursImg->m_height );
    hours->m_position       = vec2( 0.0f, 0.0f );
    hours->m_angle          = application->m_clock.m_hoursAngle;

    ImageFile* minutesImg   = application->m_minutesHand;
    minutes->m_textureId    = minutesImg->m_textureId;
    minutes->m_size         = vec2( minutesImg->m_width, minutesImg->m_height );
    minutes->m_position     = vec2( 0.0f, 0.0f );
    minutes->m_angle        = application->m_clock.m_minutesAngle;

    ImageFile* secondsImg   = application->m_secondsHand;
    seconds->m_textureId    = secondsImg->m_textureId;
    seconds->m_size         = vec2( secondsImg->m_width, secondsImg->m_height );
    seconds->m_position     = vec2( 0.0f, 0.0f );
    seconds->m_angle        = application->m_clock.m_secondsAngle;

    application->m_platform.submitDrawCalls( transientPool->m_memory, 4, application->m_platform.m_renderer );
}

void Exit( Application* application )
{
    // not needed 
}
