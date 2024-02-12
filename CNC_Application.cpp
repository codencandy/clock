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
    // render the clock
}

void Exit( Application* application )
{
    // not needed 
}
