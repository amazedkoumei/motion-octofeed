class AppDelegate
  $USER_DEFAULTS_KEY_API_TOKEN = "github_api_token"
  $USER_DEFAULTS_KEY_FEED_TOKEN = "token"
  $USER_DEFAULTS_KEY_USERNAME = "username"
  $NAVIGATIONBAR_COLOR = '#003399'.to_color
  $BAD_INTERNET_ACCESS_MESSAGE = "Bad Internet Connection or Serverside Accident. Please Retry to Pull to Refresh."
  $BAD_INTERNET_ACCESS_MESSAGE_FOR_WEBVIEW = "Failed to load page."
  #BubbleWrap.debug = true

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    application.setStatusBarStyle(UIStatusBarStyleBlackOpaque)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(MainTableViewController.new)
    @window.makeKeyAndVisible
    true
  end
end
