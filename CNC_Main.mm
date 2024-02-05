#include <AppKit/AppKit.h>
#include "CNC_Window.mm"
#include "CNC_Platform.mm"
#include "CNC_Renderer.mm"

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

    MainWindow* window   = CreateMainWindow( &running );
    Renderer*   renderer = CreateRenderer( SCREEN_WIDTH, SCREEN_HEIGHT );

    window.contentView = renderer->m_view;
        
    struct Application ClockApp      = {0};
    struct Platform    MacosPlatform = {0};
    InitPlatform( &MacosPlatform, renderer );

    ClockApp.m_platform = MacosPlatform;
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

            [renderer Render];
        }
    }

    Exit( &ClockApp );

    return 0;
}