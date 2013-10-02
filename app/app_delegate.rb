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
            image = AMP::Util.imageForRetina(UIImage.imageNamed("tabbar_feed.png"))
            sv.tabBarItem = UITabBarItem.new.initWithTitle("Feed", image:image, tag:0)
            nv.initWithRootViewController(sv)
          end
        end,
        UINavigationController.new.tap do |nv|
          NotificationTableViewController.new.tap do |sv|
            image = AMP::Util.imageForRetina(UIImage.imageNamed("tabbar_notification.png"))
            sv.tabBarItem = UITabBarItem.new.initWithTitle("Notification", image:image, tag:1)
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
