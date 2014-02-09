#import "substrate/substrate.h"
#import <UIKit/UIKit.h>
#import "luashit.h"
#import "macros.h"

static IMP original_SB_scrollViewDidScroll;
static IMP original_SB_dealloc;
static NSMutableArray *_scrollViews = nil;

static BOOL _setHierarchy = false;

static BOOL _enabled;

void reset_everything(UIView *view)
{
    view.layer.transform = CATransform3DIdentity;
    view.alpha = 1;
    for(UIView *v in view.subviews)
    {
        v.layer.transform = CATransform3DIdentity;
        v.alpha = 1;
    }
}

void genscrol(UIScrollView *scrollView, int i, UIView *view)
{
    CGSize size = scrollView.frame.size;
    float offset = scrollView.contentOffset.x;
    if(IOS_VERSION < 7) i++; //on iOS 6-, the spotlight is a page to the left, so we gotta bump the pageno. up a notch
    offset -= i*size.width;

    if(fabs(offset) > size.width)
    {
        reset_everything(view);
        return;
    }

    _enabled = manipulate(view, offset, size.width, size.height);
}

void SB_dealloc(id self, SEL _cmd)
{
    [_scrollViews removeObject:self];
    original_SB_dealloc(self, _cmd);
}

void SB_scrollViewDidScroll(id self, SEL _cmd, UIScrollView *scrollView)
{
    original_SB_scrollViewDidScroll(self, _cmd, scrollView);

    if(!_scrollViews) _scrollViews = [[NSMutableArray alloc] init];

    if(![_scrollViews containsObject:scrollView])
    {
        [_scrollViews addObject:scrollView];
        [scrollView release];
    }

    if(!_enabled) return;

    if(!_setHierarchy)
    {
        if(IOS_VERSION < 7)
        {
            [scrollView.superview sendSubviewToBack:scrollView];
        }
        _setHierarchy = true;
    }

    int i = 0;
    for(UIView *view in scrollView.subviews)
    {
        if([view isKindOfClass:NSClassFromString(@"SBIconListView")])
        {
            genscrol(scrollView, i, view);
            if(!_enabled) break;
            i++;
        }
    }
}

void load_that_shit()
{
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    for(UIScrollView *scrollView in _scrollViews)
    {
        for(UIView *view in scrollView.subviews)
        {
            if([view isKindOfClass:NSClassFromString(@"SBIconListView")])
            {
                reset_everything(view);
            }
        }
    }

    if(settings[@"enabled"] != nil && ![settings[@"enabled"] boolValue])
    {
        close_lua();
        _enabled = false;
    }
    else
    {
        NSString *key = settings[PrefsEffectKey];
        _enabled = init_lua(key.UTF8String);
    }
}

static inline void setSettingsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    load_that_shit();
}

// The attribute forces this function to be called on load.
__attribute__((constructor))
static void initialize() {
    load_that_shit();

    //hook scroll
    Class cls = NSClassFromString(@"SBFolderView"); //iOS 7
    if(cls == nil) cls = NSClassFromString(@"SBIconController"); //iOS 5
    MSHookMessageEx(cls, @selector(scrollViewDidScroll:), (IMP)SB_scrollViewDidScroll, (IMP *)&original_SB_scrollViewDidScroll);
    MSHookMessageEx(UIScrollView.class, @selector(dealloc), (IMP)SB_dealloc, (IMP *)&original_SB_dealloc);

    //listen to notification center (for settings change)
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kCylinderSettingsChanged, NULL, 0);
}
