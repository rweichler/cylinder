#import "substrate/substrate.h"
#import <UIKit/UIKit.h>

#include "luashit.m" //this is HORRIBLE PRACTICE! but I fucking suck with linking binaries.
#import "macros.h"

static IMP original_SB_scrollViewDidScroll;

static const CATransform3D DEFAULT_TRANSFORM = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};

static BOOL _setHierarchy = false;

void genscrol(UIScrollView *scrollView, int i, UIView *view)
{
    float offset = scrollView.contentOffset.x;
    if(IOS_VERSION < 7) i++; //on iOS 6-, the spotlight is a page to the left, so we gotta bump the pageno. up a notch
    offset -= i*SCREEN_SIZE.width;

    if(fabs(offset) > SCREEN_SIZE.width)
    {
        view.layer.transform = DEFAULT_TRANSFORM;
        for(UIView *v in view.subviews)
            v.layer.transform = DEFAULT_TRANSFORM;
        return;
    }

    manipulate(view, SCREEN_SIZE.width, offset);
}

void SB_scrollViewDidScroll(id self, SEL _cmd, UIScrollView *scrollView)
{
    if(!_setHierarchy)
    {
        if(IOS_VERSION < 7)
        {
            [scrollView.superview sendSubviewToBack:scrollView];
        }
        _setHierarchy = true;
    }

    NSMutableArray *views = [NSMutableArray arrayWithCapacity:scrollView.subviews.count];
    for(UIView *view in scrollView.subviews)
    {
        if([view isKindOfClass:NSClassFromString(@"SBIconListView")])
        {
            NSUInteger sortedIndex = [views indexOfObject:view
                    inSortedRange:(NSRange){0, views.count}
                    options:NSBinarySearchingInsertionIndex
                    usingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2)
                    {
                        NSNumber *n1 = [NSNumber numberWithFloat:obj1.frame.origin.x];
                        NSNumber *n2 = [NSNumber numberWithFloat:obj2.frame.origin.x];
                        return [n1 compare:n2];
                    }];

            [views insertObject:view atIndex:sortedIndex];

        }
    }

    for(int i = 0; i < views.count; i++)
    {
        genscrol(scrollView, i, views[i]);
    }

    original_SB_scrollViewDidScroll(self, _cmd, scrollView);
}

// The attribute forces this function to be called on load.
__attribute__((constructor))
static void initialize() {
    init_lua();

    Class cls = NSClassFromString(@"SBRootFolderView"); //iOS 7
    if(cls == nil) cls = NSClassFromString(@"SBIconController"); //iOS 5
    MSHookMessageEx(cls, @selector(scrollViewDidScroll:), (IMP)SB_scrollViewDidScroll, (IMP *)&original_SB_scrollViewDidScroll);
}
