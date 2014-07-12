#import <Foundation/Foundation.h>

#define TWITTER_URL_COUNT 5

static NSString *TWITTER_URL_SCHEMES[TWITTER_URL_COUNT] = {
    @"twitterrific:///profile?screen_name=rweichler",
    @"tweetbot:///user_profile/rweichler",
    @"twitter://user?screen_name=rweichler",
    @"https://twitter.com/rweichler",
    @"http://twitter.com/rweichler",
};

static BOOL open_twitter_url(int index)
{
    if(index >= TWITTER_URL_COUNT) return true;

    UIApplication *app = UIApplication.sharedApplication;
    NSURL *URL = [NSURL URLWithString:TWITTER_URL_SCHEMES[index]];
    if([app canOpenURL:URL])
    {
        [app openURL:URL];
        return true;
    }
    else
    {
        //[[UIAlertView.alloc initWithTitle:@"Can't open Twitter" message:@"Probably because you need to enter your passcode?" delegate:nil cancelButtonTitle:@"Oh, my bad" otherButtonTitles:nil] show];
        return false;
    }
}

static void open_twitter()
{
    for(int i = 0; !open_twitter_url(i); i++);
}
