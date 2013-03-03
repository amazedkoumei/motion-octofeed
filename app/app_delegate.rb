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

    @tabBarController = UITabBarController.new.tap do |v|
      viewControllers = [
        UINavigationController.new.tap do |nv|
          MainTableViewController.new.tap do |sv|
            sv.tabBarItem = UITabBarItem.new.initWithTitle("Feed", image:UIImage.imageNamed("tabbar_feed.png"), tag:0)
            nv.initWithRootViewController(sv)
          end
        end,
        UINavigationController.new.tap do |nv|
          NotificationTableViewController.new.tap do |sv|
            sv.tabBarItem = UITabBarItem.new.initWithTitle("Notification", image:UIImage.imageNamed("tabbar_notification.png"), tag:1)
            nv.initWithRootViewController(sv)
          end
        end
      ]
      v.setViewControllers(viewControllers, animated:false)
    end

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible
    true
  end

end
