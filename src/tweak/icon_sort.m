#import "icon_sort.h"
#import <objc/runtime.h>
#import <macros.h>

//this could have been a single statement,
//but id rather have it be readable
static BOOL compare(UIView *a, UIView *b)
{
    CGPoint left = a.frame.origin;
    CGPoint right = b.frame.origin;

    return left.y < right.y || (left.y == right.y && left.x <= right.x);
}

static void insertion_sort(NSArray *subviews, UIView **arr, int max)
{
    int count = 0;
    for(UIView *view in subviews)
    {
        int i;
        for(i = count - 1; i >= 0; i--)
        {
            if(compare(arr[i], view))
            {
                break;
            }
            else
            {
                arr[i + 1] = arr[i];
            }
        }
        arr[i + 1] = view;
        count++;
    }
    //set the rest to NULL
    memset(&arr[count], (int)NULL, (max - count)*sizeof(UIView *));
}

int get_max_icons_for_list(UIView *self)
{
    id obj;
    SEL sel;
    if(IOS_VERSION >= 13) {
        obj = self;
        sel = @selector(maximumIconCount);
    } else {
        obj = self.class;
        sel = @selector(maxIcons);
    }
    typedef int (*func_t)(id, SEL);
    return ((func_t)[obj methodForSelector:sel])(obj, sel);
}

UIView ** get_sorted_icons_from_list(id self)
{
    return [objc_getAssociatedObject(self, sort_icons_for_list) pointerValue];
}

static void set_obj(id self, id val)
{
    objc_setAssociatedObject(self, sort_icons_for_list, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

void sort_icons_for_list(UIView *self)
{
    int max = get_max_icons_for_list(self);

    UIView **arr = get_sorted_icons_from_list(self);
    if(arr == NULL)
    {
        arr = malloc(max*sizeof(UIView *));
        set_obj(self, [NSValue valueWithPointer:arr]);
    }
    insertion_sort(self.subviews, arr, max);
}

void dealloc_sorted_icon_array_for_list(UIView *self)
{
    void *val = get_sorted_icons_from_list(self);
    if(val != NULL)
    {
        free(val);
        set_obj(self, nil);
    }
}
