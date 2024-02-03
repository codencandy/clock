#ifndef CNC_APPLICATION_H
#define CNC_APPLICATION_H

#include "CNC_Types.h"
#include "CNC_Platform.h"

struct Clock
{
    u32 m_hours;
    u32 m_minutes;
    u32 m_seconds;

    f32 m_hoursAngle;
    f32 m_minutesAngle;
    f32 m_secondsAngle;
};

struct Application
{
    Clock       m_clock;
    Platform    m_platform;
    MemoryPool* m_permanentMemory;
    MemoryPool* m_transientMemory;
};

void Load( Application* application );
void Update( Application* application );
void Render( Application* application );
void Exit( Application* application );

#endif//CNC_APPLICATION_H