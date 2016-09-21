#line 1 "tweak.x"


















#import "tweak.h"
#import "luashit.h"
#import "macros.h"
#import "UIView+Cylinder.h"
#import "icon_sort.h"

int IOS_VERSION;

static BOOL _enabled;
static u_int32_t _randSeedForCurrentPage;
static int _lastAnimatedPageIndex = -100;

static void page_swipe(UIScrollView *scrollView)
{
    if(!_enabled) return;

    CGRect eye = {scrollView.contentOffset, scrollView.frame.size};

    
    int page = (int)(scrollView.contentOffset.x/eye.size.width);
    if(page != _lastAnimatedPageIndex)
    {
        _randSeedForCurrentPage = arc4random();
        _lastAnimatedPageIndex = page;
    }

    int i = 0;
    for(UIView *view in scrollView.subviews)
    {
        if(![view isKindOfClass:_listClass]) continue;


        BOOL shouldSortIcons = true;
        if (view.wasModifiedByCylinder)
        {
            shouldSortIcons = false;
            reset_icon_layout(view);
        }

        if(CGRectIntersectsRect(eye, view.frame))
        {
            CGSize size = scrollView.frame.size;
            float offset = scrollView.contentOffset.x - view.frame.origin.x;

            if(fabs(offset/size.width) < 1)
            {
                if(view.cylinderLastSubviewCount != view.subviews.count || shouldSortIcons)
                {
                    sort_icons_for_list(view);
                }
                _enabled = manipulate(view, offset, _randSeedForCurrentPage); 
                view.wasModifiedByCylinder = true;
            }
        }

        i++;
    }
}

static void reset_icon_layout(UIView *self)
{
    self.layer.transform = CATransform3DIdentity;
    [self.layer restorePosition];
    self.alpha = 1;
    self.wasModifiedByCylinder = false;
    for(UIView *v in self.subviews)
    {
        v.layer.transform = CATransform3DIdentity;
        [v.layer restorePosition];
        v.alpha = 1;
        v.wasModifiedByCylinder = false;
    }
    objc_setAssociatedObject(self, @selector(hasDifferentSubviews), [NSNumber numberWithBool:true], OBJC_ASSOCIATION_RETAIN);
}

static void switch_pos(CALayer *layer)
{
    if(!layer.hasSavedPosition) return;

    CGPoint pos = layer.position;
    CGPoint savedPos = layer.savedPosition;

    [layer restorePosition];
    layer.position = pos;
    [layer savePosition];
    layer.position = savedPos;

}

static CGRect get_untransformed_frame(UIView *self)
{
    CGPoint pos = self.layer.savedPosition;
    CGSize size = self.layer.bounds.size;

    pos.x -= size.width/2;
    pos.y -= size.height/2;

    CGRect frame = {pos, size};
    return frame;
}

#include <logos/logos.h>
#include <substrate.h>
@class SBFolderIconBackgroundView; @class SBIconView; @class SBIcon; @class SBIconList; @class SBIconController; @class SBIconListView; @class SBFolderView; 
static void (*_logos_orig$_ungrouped$SBIconList$showAllIcons)(id, SEL); static void _logos_method$_ungrouped$SBIconList$showAllIcons(id, SEL); static CGRect (*_logos_orig$_ungrouped$SBIconList$frame)(id, SEL); static CGRect _logos_method$_ungrouped$SBIconList$frame(id, SEL); static void (*_logos_orig$_ungrouped$SBIconList$setFrame$)(id, SEL, CGRect); static void _logos_method$_ungrouped$SBIconList$setFrame$(id, SEL, CGRect); static void (*_logos_orig$_ungrouped$SBIconList$addSubview$)(id, SEL, UIView *); static void _logos_method$_ungrouped$SBIconList$addSubview$(id, SEL, UIView *); static void (*_logos_orig$_ungrouped$SBIconList$showIconImagesFromColumn$toColumn$totalColumns$visibleIconsJitter$)(id, SEL, int, int, int, BOOL); static void _logos_method$_ungrouped$SBIconList$showIconImagesFromColumn$toColumn$totalColumns$visibleIconsJitter$(id, SEL, int, int, int, BOOL); static void (*_logos_orig$_ungrouped$SBIconList$dealloc)(id, SEL); static void _logos_method$_ungrouped$SBIconList$dealloc(id, SEL); static CGRect (*_logos_orig$_ungrouped$SBIcon$frame)(id, SEL); static CGRect _logos_method$_ungrouped$SBIcon$frame(id, SEL); static void (*_logos_orig$_ungrouped$SBIcon$setFrame$)(id, SEL, CGRect); static void _logos_method$_ungrouped$SBIcon$setFrame$(id, SEL, CGRect); static void (*_logos_orig$_ungrouped$SBFolderView$scrollViewDidScroll$)(id, SEL, UIScrollView *); static void _logos_method$_ungrouped$SBFolderView$scrollViewDidScroll$(id, SEL, UIScrollView *); static void (*_logos_orig$_ungrouped$SBFolderView$scrollViewDidEndDecelerating$)(id, SEL, UIScrollView *); static void _logos_method$_ungrouped$SBFolderView$scrollViewDidEndDecelerating$(id, SEL, UIScrollView *); static void (*_logos_orig$_ungrouped$SBFolderView$scrollViewDidEndScrollingAnimation$)(id, SEL, UIScrollView *); static void _logos_method$_ungrouped$SBFolderView$scrollViewDidEndScrollingAnimation$(id, SEL, UIScrollView *); static void (*_logos_orig$_ungrouped$SBFolderView$scrollViewWillBeginDragging$)(id, SEL, UIScrollView *); static void _logos_method$_ungrouped$SBFolderView$scrollViewWillBeginDragging$(id, SEL, UIScrollView *); static CGRect (*_logos_orig$_ungrouped$SBFolderIconBackgroundView$wallpaperRelativeBounds)(SBFolderIconBackgroundView*, SEL); static CGRect _logos_method$_ungrouped$SBFolderIconBackgroundView$wallpaperRelativeBounds(SBFolderIconBackgroundView*, SEL); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIconView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconView"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIcon"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIconList(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconList"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIconController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconController"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBFolderView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBFolderView"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIconListView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconListView"); } return _klass; }
#line 120 "tweak.x"
 


static void _logos_method$_ungrouped$SBIconList$showAllIcons(id self, SEL _cmd) {
    unsigned long count = [self subviews].count;

    
    CATransform3D myTransform = [self layer].transform;
    CATransform3D iconTransforms[count];

    [self layer].transform = CATransform3DIdentity;
    switch_pos([self layer]);

    for(int i = 0; i < count; i++)
    {
        UIView *icon = [[self subviews] objectAtIndex:i];
        iconTransforms[i] = icon.layer.transform;
        icon.layer.transform = CATransform3DIdentity;
        switch_pos(icon.layer);
    }

    
    _logos_orig$_ungrouped$SBIconList$showAllIcons(self, _cmd);

    
    [self layer].transform = myTransform;
    switch_pos([self layer]);
    for(int i = 0; i < count; i++)
    {
        UIView *icon = [[self subviews] objectAtIndex:i];
        icon.layer.transform = iconTransforms[i];
        switch_pos(icon.layer);
    }
}

static CGRect _logos_method$_ungrouped$SBIconList$frame(id self, SEL _cmd) {
    if(![self wasModifiedByCylinder])
        return _logos_orig$_ungrouped$SBIconList$frame(self, _cmd);
    else
        return get_untransformed_frame(self);
}

static void _logos_method$_ungrouped$SBIconList$setFrame$(id self, SEL _cmd, CGRect frame) {
    CATransform3D transform = [self layer].transform;
    [self layer].transform = CATransform3DIdentity;
    [[self layer] restorePosition];

    _logos_orig$_ungrouped$SBIconList$setFrame$(self, _cmd, frame);

    [self layer].transform = transform;
}

static void _logos_method$_ungrouped$SBIconList$addSubview$(id self, SEL _cmd, UIView * view) {
    objc_setAssociatedObject(self, @selector(hasDifferentSubviews), [NSNumber numberWithBool:true], OBJC_ASSOCIATION_RETAIN);
    _logos_orig$_ungrouped$SBIconList$addSubview$(self, _cmd, view);
}




static int biggestTo = 0;

static void _logos_method$_ungrouped$SBIconList$showIconImagesFromColumn$toColumn$totalColumns$visibleIconsJitter$(id self, SEL _cmd, int from, int to, int total, BOOL jittering) {
    if(to > biggestTo) biggestTo = to;
    if([self wasModifiedByCylinder])
    {
        from = 0;
        to = biggestTo;
        total = biggestTo + 1;
    }
    _logos_orig$_ungrouped$SBIconList$showIconImagesFromColumn$toColumn$totalColumns$visibleIconsJitter$(self, _cmd, from, to, total, jittering);
}


static void _logos_method$_ungrouped$SBIconList$dealloc(id self, SEL _cmd) {
    dealloc_sorted_icon_array_for_list(self);
    _logos_orig$_ungrouped$SBIconList$dealloc(self, _cmd);
}


 


static CGRect _logos_method$_ungrouped$SBIcon$frame(id self, SEL _cmd) {
    if(![self wasModifiedByCylinder])
        return _logos_orig$_ungrouped$SBIcon$frame(self, _cmd);
    else
        return get_untransformed_frame(self);
}


static void _logos_method$_ungrouped$SBIcon$setFrame$(id self, SEL _cmd, CGRect frame) {
    CATransform3D transform = [self layer].transform;
    [self layer].transform = CATransform3DIdentity;
    [[self layer] restorePosition];

    _logos_orig$_ungrouped$SBIcon$setFrame$(self, _cmd, frame);

    [self layer].transform = transform;
}



static void end_scroll(UIScrollView *self)
{
    for(UIView *view in [self subviews])
        reset_icon_layout(view);
    _randSeedForCurrentPage = arc4random();
}




static CGSize _scrollViewSize;
static BOOL _setScrollViewSize = false;
static BOOL _justSetScrollViewSize;

 

static void _logos_method$_ungrouped$SBFolderView$scrollViewDidScroll$(id self, SEL _cmd, UIScrollView * scrollView) {
    
    if(_setScrollViewSize)
    {
        if(!CGSizeEqualToSize(_scrollViewSize, scrollView.frame.size))
        {
            _scrollViewSize = scrollView.frame.size;
            _justSetScrollViewSize = true;
            return _logos_orig$_ungrouped$SBFolderView$scrollViewDidScroll$(self, _cmd, scrollView);
        }
    }
    else
    {
        _scrollViewSize = scrollView.frame.size;
        _setScrollViewSize = true;
    }
    
    if(_justSetScrollViewSize)
    {
        _justSetScrollViewSize = false;
        return _logos_orig$_ungrouped$SBFolderView$scrollViewDidScroll$(self, _cmd, scrollView);
    }
    _logos_orig$_ungrouped$SBFolderView$scrollViewDidScroll$(self, _cmd, scrollView);
    page_swipe(scrollView);
}


static void _logos_method$_ungrouped$SBFolderView$scrollViewDidEndDecelerating$(id self, SEL _cmd, UIScrollView * scrollView) {
    _logos_orig$_ungrouped$SBFolderView$scrollViewDidEndDecelerating$(self, _cmd, scrollView);
    end_scroll(scrollView);
}


static void _logos_method$_ungrouped$SBFolderView$scrollViewDidEndScrollingAnimation$(id self, SEL _cmd, UIScrollView * scrollView) {
    _logos_orig$_ungrouped$SBFolderView$scrollViewDidEndScrollingAnimation$(self, _cmd, scrollView);
    end_scroll(scrollView);
}



static void _logos_method$_ungrouped$SBFolderView$scrollViewWillBeginDragging$(id self, SEL _cmd, UIScrollView * scrollView) {
    _logos_orig$_ungrouped$SBFolderView$scrollViewWillBeginDragging$(self, _cmd, scrollView);
    if(IOS_VERSION < 7)
        [scrollView.superview sendSubviewToBack:scrollView];
    page_swipe(scrollView);
}





static CGRect _logos_method$_ungrouped$SBFolderIconBackgroundView$wallpaperRelativeBounds(SBFolderIconBackgroundView* self, SEL _cmd) {
    CGRect frame = _logos_orig$_ungrouped$SBFolderIconBackgroundView$wallpaperRelativeBounds(self, _cmd);
    if(frame.origin.x < 0) frame.origin.x = 0;
    if(frame.origin.x > SCREEN_SIZE.width - frame.size.width) frame.origin.x = SCREEN_SIZE.width - frame.size.width;
    if(frame.origin.y > SCREEN_SIZE.height - frame.size.height) frame.origin.y = SCREEN_SIZE.height - frame.size.height;
    if(frame.origin.y < 0) frame.origin.y = 0;
    return frame;
}


static void load_that_shit()
{
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];

    if(settings && ![[settings valueForKey:PrefsEnabledKey] boolValue])
    {
        close_lua();
        _enabled = false;
    }
    else
    {
        BOOL random = [[settings valueForKey:PrefsRandomizedKey] boolValue];
        NSArray *effects = [settings valueForKey:PrefsEffectKey];
        if(![effects isKindOfClass:NSArray.class]) effects = nil; 
        _enabled = init_lua(effects, random);
    }
}

static inline void setSettingsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    load_that_shit();
}

static __attribute__((constructor)) void _logosLocalCtor_40fd8c23(){
    IOS_VERSION = UIDevice.currentDevice.systemVersion.intValue;
    load_that_shit();

    Class iconClass = _logos_static_class_lookup$SBIconView() ?: _logos_static_class_lookup$SBIcon();
    _listClass = _logos_static_class_lookup$SBIconListView() ?: _logos_static_class_lookup$SBIconList();
    Class folderClass = IOS_VERSION >= 7 ? _logos_static_class_lookup$SBFolderView() : _logos_static_class_lookup$SBIconController();

    {Class _logos_class$_ungrouped$SBIconList = _listClass; MSHookMessageEx(_logos_class$_ungrouped$SBIconList, @selector(showAllIcons), (IMP)&_logos_method$_ungrouped$SBIconList$showAllIcons, (IMP*)&_logos_orig$_ungrouped$SBIconList$showAllIcons);MSHookMessageEx(_logos_class$_ungrouped$SBIconList, @selector(frame), (IMP)&_logos_method$_ungrouped$SBIconList$frame, (IMP*)&_logos_orig$_ungrouped$SBIconList$frame);MSHookMessageEx(_logos_class$_ungrouped$SBIconList, @selector(setFrame:), (IMP)&_logos_method$_ungrouped$SBIconList$setFrame$, (IMP*)&_logos_orig$_ungrouped$SBIconList$setFrame$);MSHookMessageEx(_logos_class$_ungrouped$SBIconList, @selector(addSubview:), (IMP)&_logos_method$_ungrouped$SBIconList$addSubview$, (IMP*)&_logos_orig$_ungrouped$SBIconList$addSubview$);MSHookMessageEx(_logos_class$_ungrouped$SBIconList, @selector(showIconImagesFromColumn:toColumn:totalColumns:visibleIconsJitter:), (IMP)&_logos_method$_ungrouped$SBIconList$showIconImagesFromColumn$toColumn$totalColumns$visibleIconsJitter$, (IMP*)&_logos_orig$_ungrouped$SBIconList$showIconImagesFromColumn$toColumn$totalColumns$visibleIconsJitter$);MSHookMessageEx(_logos_class$_ungrouped$SBIconList, @selector(dealloc), (IMP)&_logos_method$_ungrouped$SBIconList$dealloc, (IMP*)&_logos_orig$_ungrouped$SBIconList$dealloc);Class _logos_class$_ungrouped$SBIcon = iconClass; MSHookMessageEx(_logos_class$_ungrouped$SBIcon, @selector(frame), (IMP)&_logos_method$_ungrouped$SBIcon$frame, (IMP*)&_logos_orig$_ungrouped$SBIcon$frame);MSHookMessageEx(_logos_class$_ungrouped$SBIcon, @selector(setFrame:), (IMP)&_logos_method$_ungrouped$SBIcon$setFrame$, (IMP*)&_logos_orig$_ungrouped$SBIcon$setFrame$);Class _logos_class$_ungrouped$SBFolderView = folderClass; MSHookMessageEx(_logos_class$_ungrouped$SBFolderView, @selector(scrollViewDidScroll:), (IMP)&_logos_method$_ungrouped$SBFolderView$scrollViewDidScroll$, (IMP*)&_logos_orig$_ungrouped$SBFolderView$scrollViewDidScroll$);MSHookMessageEx(_logos_class$_ungrouped$SBFolderView, @selector(scrollViewDidEndDecelerating:), (IMP)&_logos_method$_ungrouped$SBFolderView$scrollViewDidEndDecelerating$, (IMP*)&_logos_orig$_ungrouped$SBFolderView$scrollViewDidEndDecelerating$);MSHookMessageEx(_logos_class$_ungrouped$SBFolderView, @selector(scrollViewDidEndScrollingAnimation:), (IMP)&_logos_method$_ungrouped$SBFolderView$scrollViewDidEndScrollingAnimation$, (IMP*)&_logos_orig$_ungrouped$SBFolderView$scrollViewDidEndScrollingAnimation$);MSHookMessageEx(_logos_class$_ungrouped$SBFolderView, @selector(scrollViewWillBeginDragging:), (IMP)&_logos_method$_ungrouped$SBFolderView$scrollViewWillBeginDragging$, (IMP*)&_logos_orig$_ungrouped$SBFolderView$scrollViewWillBeginDragging$);Class _logos_class$_ungrouped$SBFolderIconBackgroundView = objc_getClass("SBFolderIconBackgroundView"); MSHookMessageEx(_logos_class$_ungrouped$SBFolderIconBackgroundView, @selector(wallpaperRelativeBounds), (IMP)&_logos_method$_ungrouped$SBFolderIconBackgroundView$wallpaperRelativeBounds, (IMP*)&_logos_orig$_ungrouped$SBFolderIconBackgroundView$wallpaperRelativeBounds);}

    
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kCylinderSettingsChanged, NULL, 0);
}
