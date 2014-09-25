class AppDelegate
  $BAD_INTERNET_ACCESS_MESSAGE = "Bad Internet Connection or Serverside Accident. Please Retry to Pull to Refresh."
  $BAD_INTERNET_ACCESS_MESSAGE_FOR_WEBVIEW = "Failed to load page."
  #BubbleWrap.debug = true

  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @root_view_controller = UINavigationController.new.tap do |nav|
      SettingListViewController.new.tap do |v|
        nav.initWithRootViewController(v)
      end
    end

    self.configure_appearance(application)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @root_view_controller
    @window.makeKeyAndVisible
    true
  end

  def configure_appearance(application)
    application.setStatusBarStyle(UIStatusBarStyleLightContent)
    UINavigationBar.appearance.barTintColor = '#003399'.to_color
    UINavigationBar.appearance.tintColor = UIColor.whiteColor
    UINavigationBar.appearance.titleTextAttributes = {
      NSForegroundColorAttributeName => UIColor.whiteColor
    }

    UIBarButtonItem.appearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000), forBarMetrics:UIBarMetricsDefault)
  end

end
