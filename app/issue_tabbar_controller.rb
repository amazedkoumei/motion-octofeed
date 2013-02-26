class IssueTabBarController < UITabBarController
=begin
#import "TabBarSampleAppDelegate.h"
#import "Page1Controller.h"
#import "Page2Controller.h"

@implementation TabBarSampleAppDelegate

@synthesize window, myTabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {

  Page1Controller *page1 = [[[Page1Controller alloc] initWithNibName:nil bundle:nil] autorelease];
  Page2Controller *page2 = [[[Page2Controller alloc] initWithNibName:nil bundle:nil] autorelease];
  
  myTabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
  [myTabBarController setViewControllers:[NSArray arrayWithObjects:page1, page2, nil] animated:NO];

  [window addSubview:myTabBarController.view];
  [window makeKeyAndVisible];
}

- (void)dealloc {
  [myTabBarController release];
  [window release];
  [super dealloc];
}
@end
=end
end