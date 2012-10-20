# -*- coding: utf-8 -*-
class DetailViewController < UIViewController
  
  #TODO delete url
  attr_accessor :item, :isStarredRepository, :isWatchingRepository, :isFollowing, :isHaveToRefresh
 
  def viewDidLoad
    super

    @item = item
    @url = item[:link]

    navigationController.setToolbarHidden(false, animated:true)
    #updateUrlInfo(NSURL.URLWithString(@url))

    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@url)))
      v.scalesPageToFit = true;
      v.delegate = self
      view.addSubview(v)
    end

    @toolbarItems = Array.new.tap do |a|
      @backItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(101, target:@webview, action:'goBack')
      @forwardItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(102, target:@webview, action:'goForward')
      @reloadItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:@webview, action:'reload')
      @actionItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
      @readmeItem = UIBarButtonItem.alloc.initWithTitle("README", style:UIBarButtonItemStyleBordered, target:self, action:'readmeButton')
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
      if !isGithubRepository?
        @actionItem.enabled = false
        @readmeItem.enabled = false
      end

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

    @tabbar = UITabBar.new.tap do |t|
      view.addSubview(t)
    end
  end
  
  def viewDidAppear(animated)
    if @isHaveToRefresh
      updateUrlInfo(@webview.request.URL)
      @isHaveToRefresh = false
    end
  end

  def actionButton
    # TODO
    shareURL = NSURL.URLWithString(@url)
    activityItems = [shareURL, navigationController.topViewController];

    includeActivities = Array.new.tap do |arr|
      arr<<ActivityViewInSafari.new
      if isGithubRepository?
        if @isStarredRepository
          arr<<ActivityGithubAPI_StarDelete.new
        else
          arr<<ActivityGithubAPI_StarPut.new
        end

        if @isWatchingRepository
          arr<<ActivityGithubAPI_WatchDelete.new
        else
          arr<<ActivityGithubAPI_WatchPut.new
        end
      end

      if isGithubRepositoryOrUser?
        if @isFollowing
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

  def readmeButton
    url = "https://" + @host + "/" + @userName + "/" + @repositoryName
    @readmeView = ReadmeViewController.new.tap do |v|
      v.url = url
      v.navTitle = "#{@userName}/#{@repositoryName}"
    end
    navigationView = UINavigationController.alloc.initWithRootViewController(@readmeView)
    presentViewController(navigationView, animated:true, completion:nil)
  end

  # UIWebViewDelegate
  def webViewDidStartLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  # UIWebViewDelegate
  def webViewDidFinishLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    updateUrlInfo(webView.request.URL)

    @backItem.enabled = webView.canGoBack
    @forwardItem.enabled = webView.canGoForward
  end

  # UIWebViewDelegate
  def webView(webView, didFailLoadWithError:error)
    webViewDidFinishLoad(webView)
  end

  def updateUrlInfo(url)
    puts "updateUrlInfo: #{url.to_s}"
    @url = url.absoluteString
    @host = url.host
    @path = url.path
    puts "url:#{@url} host: #{@host} path: #{@path}"
    blank, @userName, @repositoryName = @path.componentsSeparatedByString("/")
    navigationItem.title = "#{@userName.to_s}/#{@repositoryName.to_s}"

    # FIXME: Too dirty
    if isGithubRepository?
      @fetchPath = "/user/starred/" + @userName + "/" + @repositoryName
      fetchGithubStatus{|response| @isStarredRepository = response.status_code == 204}

      @fetchPath = "/user/subscriptions/" + @userName + "/" + @repositoryName
      fetchGithubStatus{|response| @isWatchingRepository = response.status_code == 204}
      @readmeItem.enabled = true
    else
      @readmeItem.enabled = false
    end

    if isGithubRepositoryOrUser?
      @fetchPath = "/user/following/" + @userName
      fetchGithubStatus{|response| @isFollowing = response.status_code == 204}
    end

    # TODO: this is bad becouse fetchGithubStatus uses async call
    @actionItem.enabled = true
  end

  def isGithubRepository?
    (@host == "github.com" && @userName != nil && @repositoryName != nil)
  end

  def isGithubUser?
    (@host == "github.com" && @userName != nil && @repositoryName == nil)
  end

  def isGithubRepositoryOrUser?
    (@host == "github.com" && @userName != nil)
  end

  def fetchGithubStatus(&block)
    token = App::Persistence[$USER_DEFAULTS_KEY_GITHUB_API_TOKEN]
    if(!token.nil?)
      url = "https://api.github.com" + @fetchPath
      authStr = token
      authHeader = "token " + authStr
      BW::HTTP.get(url, {headers: {Authorization: authHeader}}) do |response|
        block.call(response)
      end
    end
  end
end