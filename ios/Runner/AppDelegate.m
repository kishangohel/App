#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"AIzaSyD6mXR7XtiPugZ7a_ybwjIj7IsfGnLeUIA"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
