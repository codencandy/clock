#include "CNC_Application.h"
#include <time.h>

void Load( Application* application )
{
    // load resources
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
