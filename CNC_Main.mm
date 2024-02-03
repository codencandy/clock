#include <AppKit/AppKit.h>
#include "CNC_Window.mm"

int main(void)
{
    NSApplication* app = [NSApplication sharedApplication];
    [app setActivationPolicy: NSApplicationActivationPolicyRegular];
    [app setPresentationOptions: NSApplicationPresentationDefault];
    [app activateIgnoringOtherApps:true];
    [app finishLaunching];

    bool running = true;

    MainWindow* window = CreateMainWindow( &running );

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

            // run your code here
        }
    }

    return 0;
}