#import "theos/include/substrate.h"
#include <dlfcn.h>

#define IOS_VERSION [NSClassFromString(@"UIDevice") currentDevice].systemVersion.intValue
#define SCREEN_SIZE [NSClassFromString(@"UIScreen") mainScreen].bounds.size

static IMP original_SB_scrollViewDidScroll;

static const CATransform3D _transform = {1,0,0,0,0,1,0,0,0,0,1,-0.002,0,0,0,1};
static BOOL _setHierarchy = false;
static NSComparator _comparator;

typedef CATransform3D (*CATransform3DRotate_)(CATransform3D, float, float, float, float);
static CATransform3DRotate_ Rotate;

void genscrol(UIScrollView *scrollView, int i, UIView *view)
{
    float offset = scrollView.contentOffset.x;
    if(IOS_VERSION < 7) offset -= SCREEN_SIZE.width;
    offset -= i*SCREEN_SIZE.width;

    if(fabs(offset) > SCREEN_SIZE.width)
    {
        view.layer.transform = _transform;
        return;
    }
    float percent = -offset/SCREEN_SIZE.width;
    float angle = percent*M_PI/2;

    view.layer.transform = Rotate(_transform, angle, 0, 1, 0);
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
            if(_comparator == nil)
            _comparator = ^NSComparisonResult(UIView *obj1, UIView *obj2)
            {
                NSNumber *n1 = [NSNumber numberWithFloat:obj1.frame.origin.x];
                NSNumber *n2 = [NSNumber numberWithFloat:obj2.frame.origin.x];
                return [n1 compare:n2];
            };

            NSUInteger sortedIndex = [views indexOfObject:view
                    inSortedRange:(NSRange){0, views.count}
                    options:NSBinarySearchingInsertionIndex
                    usingComparator:_comparator];

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
    Rotate = (CATransform3DRotate_)(dlsym(RTLD_DEFAULT, "CATransform3DRotate"));
    Class cls = NSClassFromString(@"SBRootFolderView"); //iOS 7
    if(cls == nil) cls = NSClassFromString(@"SBIconController");
    MSHookMessageEx(cls, @selector(scrollViewDidScroll:), (IMP)SB_scrollViewDidScroll, (IMP *)&original_SB_scrollViewDidScroll);
}
