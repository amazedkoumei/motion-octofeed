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

    @tabBarController = UITabBarController.new.tap do |tab|
      viewControllers = [
        # UINavigationController exists for keeping tableview layout in tabbarController
        UINavigationController.new.tap do |nav|
          MainTableViewController.new.tap do |v|
            image = AMP::Util.imageForRetina(UIImage.imageNamed("tabbar_feed.png"))
            v.tabBarItem = UITabBarItem.new.initWithTitle("Feed", image:image, tag:0)
            nav.initWithRootViewController(v)
          end
        end,
        # UINavigationController exists for keeping tableview layout in tabbarController
        UINavigationController.new.tap do |nav|
          NotificationTableViewController.new.tap do |v|
            image = AMP::Util.imageForRetina(UIImage.imageNamed("tabbar_notification.png"))
            v.tabBarItem = UITabBarItem.new.initWithTitle("Notification", image:image, tag:1)
            nav.initWithRootViewController(v)
          end
        end
      ]
      tab.setViewControllers(viewControllers, animated:false)
    end

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @tabBarController
    @window.makeKeyAndVisible
    true
  end

end
