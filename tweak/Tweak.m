/*
Copyright (C) 2014 Reed Weichler

This file is part of Cylinder.

Cylinder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cylinder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cylinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <substrate.h>
#import <UIKit/UIKit.h>
#import "luashit.h"
#import "macros.h"
#import "UIView+Cylinder.h"

void write_error(const char *error);

static NSMutableArray *_folders;

static Class SB_list_class;
static Class SB_icon_class;

static BOOL _enabled;

static u_int32_t _rand;
static int _page = -100;

static void did_scroll(UIScrollView *scrollView);
void layout_icons(UIView *self);

void reset_everything(UIView *view)
{
    view.layer.transform = CATransform3DIdentity;
    [view.layer restorePosition];
    view.alpha = 1;
    view.isOnScreen = false;
    for(UIView *v in view.subviews)
    {
        v.layer.transform = CATransform3DIdentity;
        [v.layer restorePosition];
        v.alpha = 1;
        v.isOnScreen = false;
    }
}

//view is an SBIconListView (or SBIconList on older iOS)
void genscrol(UIScrollView *scrollView, UIView *view)
{
    CGSize size = scrollView.frame.size;
    float offset = scrollView.contentOffset.x - view.frame.origin.x;

    int page = (int)(scrollView.contentOffset.x/size.width);
    if(page != _page)
    {
        _rand = arc4random();
        _page = page;
    }

    if(fabs(offset/size.width) < 1)
    {
        if(view.hasDifferentSubviews)
        {
            layout_icons(view);
        }
        _enabled = manipulate(view, offset, _rand); //defined in luashit.m
    }
}

void switch_pos(CALayer *layer)
{
    if(!layer.hasSavedPosition) return;

    CGPoint pos = layer.position;
    CGPoint savedPos = layer.savedPosition;

    [layer restorePosition];
    layer.position = pos;
    [layer savePosition];
    layer.position = savedPos;

}

//scrunch fix
static void(*original_SB_showAllIcons)(id, SEL);
void SB_showAllIcons(UIView *self, SEL _cmd)
{
    unsigned long count = self.subviews.count;

    //store our transforms and set them to the identity before calling showAllIcons
    CATransform3D myTransform = self.layer.transform;
    CATransform3D *iconTransforms = (CATransform3D *)malloc(count*sizeof(CATransform3D));

    self.layer.transform = CATransform3DIdentity;
    switch_pos(self.layer);

    for(int i = 0; i < count; i++)
    {
        UIView *icon = [self.subviews objectAtIndex:i];
        iconTransforms[i] = icon.layer.transform;
        icon.layer.transform = CATransform3DIdentity;
        switch_pos(icon.layer);
    }

    //call showAllIcons
    original_SB_showAllIcons(self, _cmd);

    //set everything back to the way it was
    self.layer.transform = myTransform;
    switch_pos(self.layer);
    for(int i = 0; i < count; i++)
    {
        UIView *icon = [self.subviews objectAtIndex:i];
        icon.layer.transform = iconTransforms[i];
        switch_pos(icon.layer);
    }

    free(iconTransforms);

}

void end_scroll(UIScrollView *self)
{
    for(UIView *view in self.subviews)
        reset_everything(view);
    _rand = arc4random();
}

static void(*original_SB_scrollViewDidEndDecelerating)(id, SEL, id);
void SB_scrollViewDidEndDecelerating(id self, SEL _cmd, UIScrollView *scrollView)
{
    original_SB_scrollViewDidEndDecelerating(self, _cmd, scrollView);
    end_scroll(scrollView);
}

static void(*original_SB_scrollViewDidEndScrollingAnimation)(id, SEL, id);
void SB_scrollViewDidEndScrollingAnimation(id self, SEL _cmd, UIScrollView *scrollView)
{
    original_SB_scrollViewDidEndScrollingAnimation(self, _cmd, scrollView);
    end_scroll(scrollView);
}

//in iOS 6-, the dock is actually *BEHIND* the icon scroll view, so this fixes that
static void(*original_SB_scrollViewWillBeginDragging)(id, SEL, id);
void SB_scrollViewWillBeginDragging(id self, SEL _cmd, UIScrollView *scrollView)
{
    original_SB_scrollViewWillBeginDragging(self, _cmd, scrollView);
    if(IOS_VERSION < 7)
        [scrollView.superview sendSubviewToBack:scrollView];
    did_scroll(scrollView);
}

//in iOS 6- only 5 columns are shown at a time (for performance, probably)
//since the animations are unpredictable we want to show all icons in a page
//if it is visible on the screen. performance loss is pretty negligible
static int biggestTo = 0;
static void(*original_SB_showIconImages)(id, SEL, int, int, int, BOOL);
void SB_showIconImages(UIView *self, SEL _cmd, int from, int to, int total, BOOL jittering)
{
    if(to > biggestTo) biggestTo = to;
    if(self.isOnScreen)
    {
        from = 0;
        to = biggestTo;
        total = biggestTo + 1;
    }
    original_SB_showIconImages(self, _cmd, from, to, total, jittering);
}

static void(*original_SB_scrollViewDidScroll)(id, SEL, id);
void SB_scrollViewDidScroll(id self, SEL _cmd, UIScrollView *scrollView)
{
    original_SB_scrollViewDidScroll(self, _cmd, scrollView);
    did_scroll(scrollView);
}

static void did_scroll(UIScrollView *scrollView)
{
    if(!_enabled) return;

    CGSize size = scrollView.frame.size;

    CGRect eye = CGRectMake(scrollView.contentOffset.x, 0, size.width, size.height);

    int i = 0;
    for(UIView *view in scrollView.subviews)
    {
        if(![view isKindOfClass:SB_list_class]) continue;

        if(view.isOnScreen)
            reset_everything(view);

        if(CGRectIntersectsRect(eye, view.frame))
            genscrol(scrollView, view);

        i++;
    }

}

//iOS 7 folder blur glitch hotfix for 3D effects.
static CGRect(*original_SB_wallpaperRelativeBounds)(id, SEL);
CGRect SB_wallpaperRelativeBounds(id self, SEL _cmd)
{
    CGRect frame = original_SB_wallpaperRelativeBounds(self, _cmd);
    if(frame.origin.x < 0) frame.origin.x = 0;
    if(frame.origin.x > SCREEN_SIZE.width - frame.size.width) frame.origin.x = SCREEN_SIZE.width - frame.size.width;
    if(frame.origin.y > SCREEN_SIZE.height - frame.size.height) frame.origin.y = SCREEN_SIZE.height - frame.size.height;
    if(frame.origin.y < 0) frame.origin.y = 0;
    return frame;
}

//special thanks to @noahd for this fix: https://github.com/rweichler/cylinder/issues/17
static Class(*original_SB_layerClass)(id, SEL);
Class SB_layerClass(id self, SEL _cmd)
{
    return [CATransformLayer class];
}

void layout_icons(UIView *self)
{
    NSMutableArray *icons = self.subviews.mutableCopy;

    [icons sortUsingComparator:^NSComparisonResult(UIView *icon1, UIView *icon2)
    {
        if(fabs(icon1.frame.origin.y - icon2.frame.origin.y) > 0.01)
            return [[NSNumber numberWithFloat:icon1.frame.origin.y] compare:[NSNumber numberWithFloat:icon2.frame.origin.y]];
        else
            return [[NSNumber numberWithFloat:icon1.frame.origin.x] compare:[NSNumber numberWithFloat:icon2.frame.origin.x]];
    }];

    for(UIView *icon in icons)
    {
        [icon.superview bringSubviewToFront:icon];
    }
}

static id(*original_SB_insertIcon)(id, SEL, id, unsigned, BOOL, BOOL);
id SB_insertIcon(UIView *self, SEL _cmd, UIView *icon, unsigned index, BOOL now, BOOL pop)
{
    id result = original_SB_insertIcon(self, _cmd, icon, index, now, pop);
    self.hasDifferentSubviews = true;
    return result;
}

void load_that_shit()
{
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];

    BOOL enabled = _enabled;

    if(settings && ![[settings valueForKey:PrefsEnabledKey] boolValue])
    {
        close_lua();
        _enabled = false;
    }
    else
    {
        BOOL random = [[settings valueForKey:PrefsRandomizedKey] boolValue];
        NSArray *effects = [settings valueForKey:PrefsEffectKey];
        if(![effects isKindOfClass:NSArray.class]) effects = nil; //this is for backwards compatibility
        _enabled = init_lua(effects, random);
    }
}

static inline void setSettingsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    load_that_shit();
}

CGRect SB_frame(UIView *self)
{
    CGPoint pos = self.layer.savedPosition;
    CGSize size = self.layer.bounds.size;

    pos.x -= size.width/2;
    pos.y -= size.height/2;

    CGRect frame = {pos, size};
    return frame;
}

static CGRect(*original_SB_list_frame)(id, SEL);
CGRect SB_list_frame(UIView *self, SEL _cmd)
{
    if(!self.isOnScreen)
        return original_SB_list_frame(self, _cmd);
    else
        return SB_frame(self);
}

static CGRect(*original_SB_icon_frame)(id, SEL);
CGRect SB_icon_frame(UIView *self, SEL _cmd)
{
    if(!self.isOnScreen)
        return original_SB_icon_frame(self, _cmd);
    else
        return SB_frame(self);
}

static void(*original_SB_list_setFrame)(id, SEL, CGRect);
void SB_list_setFrame(UIView *self, SEL _cmd, CGRect frame)
{
    CATransform3D transform = self.layer.transform;
    self.layer.transform = CATransform3DIdentity;
    [self.layer restorePosition];

    original_SB_list_setFrame(self, _cmd, frame);

    self.layer.transform = transform;
}

static void(*original_SB_icon_setFrame)(id, SEL, CGRect);
void SB_icon_setFrame(UIView *self, SEL _cmd, CGRect frame)
{
    CATransform3D transform = self.layer.transform;
    self.layer.transform = CATransform3DIdentity;
    [self.layer restorePosition];

    original_SB_icon_setFrame(self, _cmd, frame);

    self.layer.transform = transform;
}

// The attribute forces this function to be called on load.
__attribute__((constructor))
static void initialize()
{
    _folders = [NSMutableArray array];

    SB_icon_class = NSClassFromString(@"SBIconView"); //iOS 4+
    if(!SB_icon_class) SB_list_class = NSClassFromString(@"SBIcon"); //iOS 3
    SB_list_class = NSClassFromString(@"SBIconListView"); //iOS 4+
    if(!SB_list_class) SB_list_class = NSClassFromString(@"SBIconList"); //iOS 3
    load_that_shit();

    Class cls = NSClassFromString(IOS_VERSION < 7 ? @"SBIconController" : @"SBFolderView");

    MSHookMessageEx(cls, @selector(scrollViewDidScroll:), (IMP)SB_scrollViewDidScroll, (IMP *)&original_SB_scrollViewDidScroll);
    MSHookMessageEx(cls, @selector(scrollViewDidEndDecelerating:), (IMP)SB_scrollViewDidEndDecelerating, (IMP *)&original_SB_scrollViewDidEndDecelerating);
    MSHookMessageEx(cls, @selector(scrollViewDidEndScrollingAnimation:), (IMP)SB_scrollViewDidEndScrollingAnimation, (IMP *)&original_SB_scrollViewDidEndScrollingAnimation);
    MSHookMessageEx(cls, @selector(scrollViewWillBeginDragging:), (IMP)SB_scrollViewWillBeginDragging, (IMP *)&original_SB_scrollViewWillBeginDragging);

    //iOS 7 bug hotfix
    Class bg_cls = NSClassFromString(@"SBFolderIconBackgroundView");
    if(bg_cls) MSHookMessageEx(bg_cls, @selector(wallpaperRelativeBounds), (IMP)SB_wallpaperRelativeBounds, (IMP *)&original_SB_wallpaperRelativeBounds);

    //iOS 6- not-all-icons-showing hotfix
    if(SB_list_class) MSHookMessageEx(SB_list_class, @selector(showIconImagesFromColumn:toColumn:totalColumns:visibleIconsJitter:), (IMP)SB_showIconImages, (IMP *)&original_SB_showIconImages);

    //fix for https://github.com/rweichler/cylinder/issues/17
    //MSHookMessageEx(object_getClass(SB_list_class), @selector(layerClass), (IMP)SB_layerClass, (IMP *)&original_SB_layerClass);

    //the above fix hides the dock, so we needa fix dat shit YO
    //Class SBDockIconListView = NSClassFromString(@"SBDockIconListView");
    //if(SBDockIconListView) MSHookMessageEx(object_getClass(SBDockIconListView), @selector(layerClass), (IMP)original_SB_layerClass, NULL);

    //fix icon scrunching in certain circumstances
    MSHookMessageEx(SB_list_class, @selector(showAllIcons), (IMP)SB_showAllIcons, (IMP *)&original_SB_showAllIcons);
    MSHookMessageEx(SB_list_class, @selector(frame), (IMP)SB_list_frame, (IMP *)&original_SB_list_frame);
    MSHookMessageEx(SB_icon_class, @selector(frame), (IMP)SB_icon_frame, (IMP *)&original_SB_icon_frame);
    MSHookMessageEx(SB_list_class, @selector(setFrame), (IMP)SB_list_setFrame, (IMP *)&original_SB_list_setFrame);
    MSHookMessageEx(SB_icon_class, @selector(setFrame), (IMP)SB_icon_setFrame, (IMP *)&original_SB_icon_setFrame);


    MSHookMessageEx(SB_list_class, @selector(insertIcon:atIndex:moveNow:pop:), (IMP)SB_insertIcon, (IMP *)&original_SB_insertIcon);

    //listen to notification center (for settings change)
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kCylinderSettingsChanged, NULL, 0);
}
