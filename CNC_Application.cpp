#include "CNC_Application.h"
#include <time.h>

void Load( Application* application )
{
    Platform* platform = &application->m_platform;

    application->m_permanentMemory = CreateMemoryPool( MEGABYTE(100) );
    application->m_transientMemory = CreateMemoryPool( MEGABYTE(100) );

    application->m_background  = platform->loadImage( "res/background.png", application->m_permanentMemory );
    application->m_hoursHand   = platform->loadImage( "res/hours_hand.png", application->m_permanentMemory );
    application->m_minutesHand = platform->loadImage( "res/minutes_hand.png", application->m_permanentMemory );
    application->m_secondsHand = platform->loadImage( "res/seconds_hand.png", application->m_permanentMemory );
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
