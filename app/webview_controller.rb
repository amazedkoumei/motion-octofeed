# -*- coding: utf-8 -*-
class WebViewController < UIViewController
  
  attr_accessor :item, :isHaveToRefresh
 
  def viewDidLoad()
    super

    @item = item
    @url_string = item[:link]
    navigationItem.title = @url_string

    @manager = GithubManager.new(@url_string, self)

    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.loadRequest(NSURLRequest.requestWithURL(@manager.url))
      v.scalesPageToFit = true;
      v.delegate = self
      view.addSubview(v)
    end

    @toolbarItems = Array.new.tap do |a|
      @backItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(101, target:@webview, action:'goBack')
        i.enabled = false
      end
      @forwardItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(102, target:@webview, action:'goForward')
        i.enabled = false
      end
      @reloadItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:@webview, action:'reload')
      end
      @actionItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
        if !@manager.isGithubRepository?
          i.enabled = false
        end
      end
      @readmeItem = UIBarButtonItem.new.tap do |i|
        i.initWithTitle("README", style:UIBarButtonItemStyleBordered, target:self, action:'readmeButton')
        if !@manager.isGithubRepository?
          i.enabled = false
        end
      end
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@backItem
      a<<@flexibleSpace
      a<<@forwardItem
      a<<@flexibleSpace
      a<<@reloadItem
      a<<@flexibleSpace
      a<<@actionItem
      a<<@flexibleSpace
      a<<@readmeItem

      self.toolbarItems = a
    end
  end
  
  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:true)
  end

  def viewDidAppear(animated)
    super
    
    if @isHaveToRefresh
      @manager.fetchGithubStatus()
      @isHaveToRefresh = false
    end
  end

  def viewWillDisappear(animated)
    super
    navigationController.setToolbarHidden(true, animated:animated)
  end

  def actionButton
    @activityController = AMP::ActivityViewController.new.tap do |a|

      activityItems = [@manager.url, navigationController.topViewController];

      includeActivities = Array.new.tap do |arr|

        authToken = @manager.authToken

        arr<<AMP::ActivityViewController.activityOpenInSafariActivity()
        arr<<AMP::ActivityViewController.activityHatenaBookmark(@manager.url.absoluteString, {:backurl => "octofeed:/", :backtitle => "octofeed"})

        if @manager.isGithubRepository?
          
          #TODO: display always after fixed that setting title to text the case of gist
          arr<<UIActivityTypePostToTwitter
          arr<<UIActivityTypeMail

          if @manager.isStarredRepo
            arr<<AMP::ActivityViewController.activityGithubAPI_StarDelete(authToken, self)
          else
            arr<<AMP::ActivityViewController.activityGithubAPI_StarPut(authToken, self)
          end

          if @manager.isWatchingRepo
            arr<<AMP::ActivityViewController.activityGithubAPI_WatchDelete(authToken, self)
          else
            arr<<AMP::ActivityViewController.activityGithubAPI_WatchPut(authToken, self)
          end
        end

        if @manager.isGithubRepositoryOrUser?
          if @manager.isFollowingUser
            arr<<AMP::ActivityViewController.activityGithubAPI_FollowDelete(authToken, self)
          else
            arr<<AMP::ActivityViewController.activityGithubAPI_FollowPut(authToken, self)
          end
        end
      end

      a.initWithActivityItems(activityItems, applicationActivities:includeActivities)
      presentViewController(a, animated:true, completion:nil)
    end
  end

  def readmeButton()
    # generate @readmeView in updateUrlInfo method
    navigationView = UINavigationController.alloc.initWithRootViewController(@readmeViewController)
    presentViewController(navigationView, animated:true, completion:nil)
  end

  # UIWebViewDelegate
  def webViewDidStartLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
    @actionItem.enabled = false
    @readmeItem.enabled = false
    @retryCount = 0
  end

  # UIWebViewDelegate
  def webViewDidFinishLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    @backItem.enabled = webView.canGoBack
    @forwardItem.enabled = webView.canGoForward
    
    @url_string = webView.request.URL.absoluteString
    @manager = GithubManager.new(@url_string, self)
    navigationItem.title = @url_string
    @manager.fetchGithubStatus()
    if @manager.isGithubRepository?
      @readmeViewController = FeatureReadmeViewController.new.tap do |v|
        v.url = "https://" + @manager.url.host + "/" + @manager.owner + "/" + @manager.repo
        v.navTitle = "#{@manager.owner}/#{@manager.repo}"
        v.parseBeforeDidLoad()
        @readmeItem.enabled = true
      end
    end
  end

  # UIWebViewDelegate
  def webView(webView, didFailLoadWithError:error)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    App.alert($BAD_INTERNET_ACCESS_MESSAGE_FOR_WEBVIEW)
  end

  # GithubManager delegate
  def githubFetchDidFinish()
    if @manager.isGithubRepositoryOrUser?
      @actionItem.enabled = true
    end
  end

  def prepareGithubPerformActivity(activity)
    @actionItem.enabled = false
    AMP::InformView.show(activity.informationMessage(), target:view, animated:true)
  end

  # GithubApiTemplateActivity delegate
  def completeGithubPerformActivity()
    AMP::InformView.hide(true)
    @manager.fetchGithubStatus()
    App.alert("Success")
    @actionItem.enabled = true
  end

  # GithubApiTemplateActivity delegate
  def completeGithubPerformActivityWithError(errorCode)
    AMP::InformView.hide(true)
    if errorCode == 401
      subView = SettingListViewController.new
      subView.moveTo = subView.MOVE_TO_SETTING_GITHUB_ACCOUNT
      view = UINavigationController.alloc.initWithRootViewController(subView)
      
      isHaveToRefresh = true

      # FIXME: get following warning and not be present....Why?
      # Warning: Attempt to present <UINavigationController: 0x1750ae90> on <UINavigationController: 0xd0bfd70> while a presentation is in progress!
      #presentViewController(view, animated:true, completion:nil)

      # alternative to presentViewController
      App.alert("Error")
      
    else
      App.alert("Error")
    end
    @actionItem.enabled = true
  end

end