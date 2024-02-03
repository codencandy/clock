#include <AppKit/AppKit.h>

@interface MainWindowDelegate : NSObject<NSWindowDelegate>
{
    @public
        bool* m_running;
}

- (instancetype)initWithBool:(bool*)running;

@end

@implementation MainWindowDelegate

- (instancetype)initWithBool:(bool*)running
{
    self = [super init];
    m_running = running;

    return self;
}

- (BOOL)windowShouldClose:(NSWindow*)sender
{
    *m_running = false;
    return true;
}

@end

@interface MainWindow : NSWindow
{
    @public
        CVDisplayLinkRef m_displayLink;
        NSCondition*     m_displayLinkSignal;
}
@end

@implementation MainWindow

- (BOOL)windowCanBecomeKey { return true; }
- (BOOL)windowCanBecomeMain { return true; }

@end

CVReturn DisplayCallback( CVDisplayLinkRef   displayLink, 
                          const CVTimeStamp* inNow, 
                          const CVTimeStamp* inOutputTime, 
                          CVOptionFlags      flagsIn, 
                          CVOptionFlags*     flagsOut, 
                          void*              mainwindow )
{
    MainWindow* window = (MainWindow*)mainwindow;

    [window->m_displayLinkSignal signal];
    return kCVReturnSuccess;
}                              

MainWindow* CreateMainWindow( bool* running )
{
    NSRect contentRect = NSMakeRect( 0, 0, 600, 600);
    MainWindowDelegate* delegate = [[MainWindowDelegate alloc] initWithBool:running];
    MainWindow*         window   = [[MainWindow alloc] initWithContentRect: contentRect
                                                                 styleMask: NSWindowStyleMaskClosable | NSWindowStyleMaskTitled
                                                                   backing: NSBackingStoreBuffered
                                                                     defer: false];
    [window setTitle: @"clock by cnc"];
    [window makeKeyAndOrderFront: NULL];
    [window setDelegate: delegate];

    window->m_displayLinkSignal = [NSCondition new];
    CVDisplayLinkCreateWithActiveCGDisplays( &window->m_displayLink );
    CVDisplayLinkSetOutputCallback( window->m_displayLink, &DisplayCallback, (void*)window );
    CVDisplayLinkStart( window->m_displayLink );

    return window;
}