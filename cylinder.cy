var set_hierarchy = false;
var ios = [UIDevice currentDevice].systemVersion.intValue

genscrol = function(scrollView, n, view)
{
    var offset = scrollView.contentOffset.x;
    if(ios < 7) //spotlight
    {
        offset = offset - 320;
    }
    offset = offset - n*320;
    if(offset < -320 || offset > 320)
    {
        view.layer.transform = def;
        return;
    }
    var pi = 3.14159265;
    var percent = -offset/320;
    var angle = percent*pi/2;
    view.layer.transform = CATransform3DRotate(def, angle, 0, 1, 0);
};

scroled = function(scrollView)
{
    if(!set_hierarchy && ios < 7)
    {
        [scrollView.superview sendSubviewToBack:scrollView];
        set_hierarchy = true;
    }

    var views = [];
    for each(var view in scrollView.subviews)
    {
        if([view isKindOfClass:SBIconListView])
        {
            views.push(view);
        }
    }
    views.sort(function(a,b){
        return a.frame.origin.x - b.frame.origin.x;
    });
    for(var i = 0; i < views.length; i++)
    {
        var view = views[i];
        genscrol(scrollView, i, view);
    }
};

@import com.saurik.substrate.MS

def = {m11:1,m12:0,m13:0,m14:0,m21:0,m22:1,m23:0,m24:0,m31:0,m32:0,m33:1,m34:-0.002,m41:0,m42:0,m43:0,m44:1}
var oldm = {};
var cls = objc_getClass("SBRootFolderView"); //iOS 7
cls = ([cls class] ? cls : SBIconController) //iOS 5, we check for SBRootFolderView first because SBIconController is also defined in iOS 7 but is apparently deprecated

MS.hookMessage(cls, @selector(scrollViewDidScroll:), function(sv){
    scroled(sv);
    return oldm->call(this, sv);
}, oldm);

