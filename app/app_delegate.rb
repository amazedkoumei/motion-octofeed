class AppDelegate
  $USER_DEFAULTS_KEY_GITHUB_API_TOKEN = "github_api_token"
  $USER_DEFAULTS_KEY_GITHUB_FEED_URL = "github_feed_url"
  $USER_DEFAULTS_KEY_0 = "token"
  $USER_DEFAULTS_KEY_1 = "username_or_email"
  $USER_DEFAULTS_KEY_2 = "password"
  $NAVIGATIONBAR_COLOR = '#003399'.to_color

  #BubbleWrap.debug = true

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    application.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(MainTableViewController.new)
    @window.makeKeyAndVisible
    true
  end
end
