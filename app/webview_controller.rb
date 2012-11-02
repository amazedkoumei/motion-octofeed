# -*- coding: utf-8 -*-
class WebViewController < UIViewController
  
  attr_accessor :item, :isHaveToRefresh
 
  def viewDidLoad()
    super

    @item = item
    @url = item[:link]
    navigationItem.title = @url

    @github = Github.new(NSURL.URLWithString(@url))

    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@url)))
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
        if !@github.isGithubRepository?
          i.enabled = false
        end
      end
      @readmeItem = UIBarButtonItem.new.tap do |i|
        i.initWithTitle("README", style:UIBarButtonItemStyleBordered, target:self, action:'readmeButton')
        if !@github.isGithubRepository?
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
  
  def viewDidAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:animated)
    
    if @isHaveToRefresh
      githubStatusUpdate()
      @isHaveToRefresh = false
    end
  end

  def viewWillDisappear(animated)
    super
    navigationController.setToolbarHidden(true, animated:animated)
  end

  def actionButton
    # TODO
    shareURL = NSURL.URLWithString(@url)
    activityItems = [shareURL, navigationController.topViewController];

    includeActivities = Array.new.tap do |arr|
      arr<<ActivityViewInSafari.new
      if @github.isGithubRepository?
        if @github.isStarredRepository?
          arr<<ActivityGithubAPI_StarDelete.new
        else
          arr<<ActivityGithubAPI_StarPut.new
        end

        if @github.isWatchingRepository?
          arr<<ActivityGithubAPI_WatchDelete.new
        else
          arr<<ActivityGithubAPI_WatchPut.new
        end
      end

      if @github.isGithubRepositoryOrUser?
        if @github.isFollowingUser?
          arr<<ActivityGithubAPI_FollowDelete.new
        else
          arr<<ActivityGithubAPI_FollowPut.new
        end
      end
    end

    excludeActivities = [
      UIActivityTypePostToFacebook,
      UIActivityTypePostToTwitter,
      UIActivityTypePostToWeibo,
      UIActivityTypeMessage,
      UIActivityTypePrint,
      UIActivityTypeCopyToPasteboard,
      UIActivityTypeAssignToContact,
      UIActivityTypeSaveToCameraRoll
    ]

    @activityController = UIActivityViewController.alloc.initWithActivityItems(activityItems, applicationActivities:includeActivities)
    @activityController.excludedActivityTypes = excludeActivities
    presentViewController(@activityController, animated:true, completion:nil)
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
    
    @url = webView.request.URL.absoluteString
    navigationItem.title = @url
    githubStatusUpdate()
    if @github.isGithubRepository?
      @readmeViewController = FeatureReadmeViewController.new.tap do |v|
        v.url = "https://" + @github.host + "/" + @github.userName + "/" + @github.repositoryName
        v.navTitle = "#{@github.userName}/#{@github.repositoryName}"
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

  # ActivityTemplateGithubApi delegate
  def completePerformActivity()
    githubStatusUpdate()
  end

  def githubStatusUpdate()
    @github = Github.new(NSURL.URLWithString(@url))
    @github.fetchGithubStatus do
      if @github.isGithubRepositoryOrUser?
        @actionItem.enabled = true
      end
    end
  end
end