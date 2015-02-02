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

int IOS_VERSION;
Class _listClass;

void write_error(const char *error);

static BOOL _enabled;

static u_int32_t _rand;
static int _page = -100;

static void did_scroll(UIScrollView *scrollView);
static void layout_icons(UIView *self);

static void reset_everything(UIView *view)
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
static void genscrol(UIScrollView *scrollView, UIView *view)
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

static CGRect SB_frame(UIView *self)
{
    CGPoint pos = self.layer.savedPosition;
    CGSize size = self.layer.bounds.size;

    pos.x -= size.width/2;
    pos.y -= size.height/2;

    CGRect frame = {pos, size};
    return frame;
}

%hook SBIconList //SBIconListView
//scrunch fix
-(void)showAllIcons
{
    unsigned long count = [self subviews].count;

    //store our transforms and set them to the identity before calling showAllIcons
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

    //call showAllIcons
    %orig;

    //set everything back to the way it was
    [self layer].transform = myTransform;
    switch_pos([self layer]);
    for(int i = 0; i < count; i++)
    {
        UIView *icon = [[self subviews] objectAtIndex:i];
        icon.layer.transform = iconTransforms[i];
        switch_pos(icon.layer);
    }
}
-(CGRect)frame
{
    if(![self isOnScreen])
        return %orig;
    else
        return SB_frame(self);
}
-(void)setFrame:(CGRect)frame
{
    CATransform3D transform = [self layer].transform;
    [self layer].transform = CATransform3DIdentity;
    [[self layer] restorePosition];

    %orig;

    [self layer].transform = transform;
}
-(void)addSubview:(UIView *)view
{
    objc_setAssociatedObject(self, @selector(hasDifferentSubviews), [NSNumber numberWithBool:true], OBJC_ASSOCIATION_RETAIN);
    %orig;
}

//in iOS 6- only 5 columns are shown at a time (for performance, probably)
//since the animations are unpredictable we want to show all icons in a page
//if it is visible on the screen. performance loss is pretty negligible
static int biggestTo = 0;
-(void)showIconImagesFromColumn:(int)from toColumn:(int)to totalColumns:(int)total visibleIconsJitter:(BOOL)jittering
{
    if(to > biggestTo) biggestTo = to;
    if([self isOnScreen])
    {
        from = 0;
        to = biggestTo;
        total = biggestTo + 1;
    }
    %orig(from, to, total, jittering);
}
%end

%hook SBIcon //SBIconView

-(CGRect)frame
{
    if(![self isOnScreen])
        return %orig;
    else
        return SB_frame(self);
}

-(void)setFrame:(CGRect)frame
{
    CATransform3D transform = [self layer].transform;
    [self layer].transform = CATransform3DIdentity;
    [[self layer] restorePosition];

    %orig;

    [self layer].transform = transform;
}

%end

static void end_scroll(UIScrollView *self)
{
    for(UIView *view in [self subviews])
        reset_everything(view);
    _rand = arc4random();
}

static CGSize _scrollViewSize;
static BOOL _setScrollViewSize = false;
static BOOL _justSetScrollViewSize;

%hook SBFolderView //SBIconController
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //if the scroll view size changed, then the we are rotating and not actually scrolling
    if(_setScrollViewSize)
    {
        if(!CGSizeEqualToSize(_scrollViewSize, scrollView.frame.size))
        {
            _scrollViewSize = scrollView.frame.size;
            _justSetScrollViewSize = true;
            return;
        }
    }
    else
    {
        _scrollViewSize = scrollView.frame.size;
        _setScrollViewSize = true;
    }
    //weird stuff happens. when rotating, it sets the size to itself for some reason. causes the bug to happen when a folder is open. this fixes it.
    if(_justSetScrollViewSize)
    {
        _justSetScrollViewSize = false;
        return;
    }
    %orig;
    did_scroll(scrollView);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    %orig;
    end_scroll(scrollView);
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    %orig;
    end_scroll(scrollView);
}

//in iOS 6-, the dock is actually *BEHIND* the icon scroll view, so this fixes that
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    %orig;
    if(IOS_VERSION < 7)
        [scrollView.superview sendSubviewToBack:scrollView];
    did_scroll(scrollView);
}
%end

static void did_scroll(UIScrollView *scrollView)
{
    if(!_enabled) return;

    CGSize size = scrollView.frame.size;

    CGRect eye = CGRectMake(scrollView.contentOffset.x, 0, size.width, size.height);

    int i = 0;
    for(UIView *view in scrollView.subviews)
    {
        if(![view isKindOfClass:_listClass]) continue;

        if(view.isOnScreen)
            reset_everything(view);

        if(CGRectIntersectsRect(eye, view.frame))
            genscrol(scrollView, view);

        i++;
    }

}

//iOS 7 folder blur glitch hotfix for 3D effects.
%hook SBFolderIconBackgroundView
-(CGRect)wallpaperRelativeBounds
{
    CGRect frame = %orig;
    if(frame.origin.x < 0) frame.origin.x = 0;
    if(frame.origin.x > SCREEN_SIZE.width - frame.size.width) frame.origin.x = SCREEN_SIZE.width - frame.size.width;
    if(frame.origin.y > SCREEN_SIZE.height - frame.size.height) frame.origin.y = SCREEN_SIZE.height - frame.size.height;
    if(frame.origin.y < 0) frame.origin.y = 0;
    return frame;
}
%end

static void layout_icons(UIView *self)
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
        if(![effects isKindOfClass:NSArray.class]) effects = nil; //this is for backwards compatibility
        _enabled = init_lua(effects, random);
    }
}

static inline void setSettingsNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    load_that_shit();
}

%ctor{
    IOS_VERSION = UIDevice.currentDevice.systemVersion.intValue;
    load_that_shit();

    Class iconClass = %c(SBIconView) ?: %c(SBIcon);
    _listClass = %c(SBIconListView) ?: %c(SBIconList);
    Class folderClass;
    if(IOS_VERSION >= 7)
        folderClass = %c(SBFolderView);
    else
        folderClass = %c(SBIconController);

    %init(SBIcon=iconClass, SBIconList=_listClass, SBFolderView=folderClass);

    //listen to notification center (for settings change)
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &setSettingsNotification, (CFStringRef)kCylinderSettingsChanged, NULL, 0);
}
