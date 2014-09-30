# -*- coding: utf-8 -*-
class WebViewController < UIViewController
  
  attr_accessor :url_string
 
  def viewDidLoad()
    super

    @manager = GithubManager.new(@url_string, self)

    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.loadRequest(NSURLRequest.requestWithURL(@manager.url))
      v.scalesPageToFit = true;
      v.delegate = self
      view.addSubview(v)
    end

    @toolbarItems = Array.new.tap do |a|
      @closeItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:'close')
      end

      @backItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(101, target:@webview, action:'goBack')
        i.enabled = false
      end

      @infoItem = UIBarButtonItem.new.tap do |i|
        image = AMP::Util.imageForRetina(UIImage.imageNamed("toolbar_info.png"))
        i.initWithImage(image, style:UIBarButtonItemStylePlain, target:self, action:"infoButton")
      end

      @forwardItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(102, target:@webview, action:'goForward')
        i.enabled = false
      end

      @actionItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
        if !@manager.isGithubRepository?
          i.enabled = false
        end
      end

      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@closeItem
      a<<@flexibleSpace
      a<<@backItem
      a<<@flexibleSpace
      a<<@infoItem
      a<<@flexibleSpace
      a<<@forwardItem
      a<<@flexibleSpace
      a<<@actionItem

      self.toolbarItems = a
    end

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.tintColor = UIColor.whiteColor
      r.addTarget(self, action:"reload", forControlEvents:UIControlEventValueChanged)
      @webview.scrollView.addSubview(r)
    end

  end

  def viewDidAppear(animated)
    super
    unless self.navigationController.nil?
      self.navigationController.setNavigationBarHidden(true, animated:animated)
      self.navigationController.setToolbarHidden(false, animated:false)
    end
  end

  def reload()
    @webview.reload()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end    
  end

  def close
    dismissViewControllerAnimated(true, completion:nil)
  end

  def actionButton
    @activityController = AMP::ActivityViewController.new.tap do |a|

      activityItems = [@manager.url, @manager.url.absoluteString];

      includeActivities = Array.new.tap do |arr|
        arr<<UIActivityTypePostToTwitter
        arr<<UIActivityTypeMail
        arr<<AMP::ActivityViewController.activityOpenInSafariActivity()
        arr<<AMP::ActivityViewController.activityHatenaBookmark(@manager.url.absoluteString, {:backurl => "octofeed:/", :backtitle => "octofeed"})
      end

      a.initWithActivityItems(activityItems, applicationActivities:includeActivities)
      presentViewController(a, animated:true, completion:nil)
    end
  end

  def infoButton()
    @repositoryView = RepsitoryViewController.new.tap do |v|
      v.initWithStyle(UITableViewStyleGrouped)
      v.url_string = @url_string
      v.hidesBottomBarWhenPushed = true
    end
    navigationView = UINavigationController.alloc.initWithRootViewController(@repositoryView)
    presentViewController(navigationView, animated:true, completion:nil)
  end

  # UIWebViewDelegate
  def webViewDidStartLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  # UIWebViewDelegate
  def webViewDidFinishLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    @backItem.enabled = webView.canGoBack
    @forwardItem.enabled = webView.canGoForward
    
    @url_string = webView.request.URL.absoluteString
    @manager = GithubManager.new(@url_string, self)
    navigationItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
  end

  def webView(webView, didFailLoadWithError:error)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
  end

end