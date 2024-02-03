#include <AppKit/AppKit.h>
#include "CNC_Window.mm"
#include "CNC_Platform.mm"

#include "CNC_Application.h"
#include "CNC_Application.cpp"

int main(void)
{
    NSApplication* app = [NSApplication sharedApplication];
    [app setActivationPolicy: NSApplicationActivationPolicyRegular];
    [app setPresentationOptions: NSApplicationPresentationDefault];
    [app activateIgnoringOtherApps:true];
    [app finishLaunching];

    bool running = true;

    MainWindow* window = CreateMainWindow( &running );
    struct Platform    Platform = {0};
    struct Application ClockApp = {0};

    InitPlatform( &Platform );
    Load( &ClockApp );

    @autoreleasepool
    {
        NSEvent* event = NULL;
        while( running )
        {
            do
            {
                event = [app nextEventMatchingMask:NSEventMaskAny
                                         untilDate:NULL
                                            inMode:NSDefaultRunLoopMode
                                           dequeue:true];

                [app sendEvent: event];
                [app updateWindows];                                           
            }
            while( event != NULL );

            [window->m_displayLinkSignal wait];
            
            // run your code here
            Update( &ClockApp );
            Render( &ClockApp );
        }
    }

    Exit( &ClockApp );

    return 0;
}