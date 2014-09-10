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
=begin
      @backItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(101, target:@webview, action:'goBack')
        i.enabled = false
      end
      @forwardItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(102, target:@webview, action:'goForward')
        i.enabled = false
      end
=end
      @reloadItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:@webview, action:'reload')
      end

      @actionItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
        if !@manager.isGithubRepository?
          i.enabled = false
        end
      end

      @infoItem = UIBarButtonItem.new.tap do |i|
        image = AMP::Util.imageForRetina(UIImage.imageNamed("toolbar_info.png"))
        i.initWithImage(image, style:UIBarButtonItemStylePlain, target:self, action:"infoButton")
      end

      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@closeItem
      a<<@flexibleSpace
=begin
      a<<@backItem
      a<<@flexibleSpace
      a<<@forwardItem
      a<<@flexibleSpace
=end
      a<<@reloadItem
      a<<@flexibleSpace
      a<<@actionItem
      a<<@flexibleSpace
      a<<@infoItem

      self.toolbarItems = a
    end

    UIScreenEdgePanGestureRecognizer.new.tap do |r|
      r.initWithTarget(self, action:"leftSwipe:")
      r.edges = UIRectEdgeLeft
      @webview.addGestureRecognizer(r)
    end

    @arrayImagenes = {}
  end

  def viewDidAppear(animated)
    super
    unless self.navigationController.nil?
      self.navigationController.setNavigationBarHidden(true, animated:animated)
      self.navigationController.setToolbarHidden(false, animated:false)
    end
  end

  def viewWillDisappear(animated)
    super
    unless self.navigationController.nil?
      #navigationController.setToolbarHidden(true, animated:animated)
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
    @detailView = DetailViewController.new.tap do |v|
      v.initWithStyle(UITableViewStyleGrouped)
      v.url_string = @webview.stringByEvaluatingJavaScriptFromString("document.URL")
      v.hidesBottomBarWhenPushed = true
    end
    navigationView = UINavigationController.alloc.initWithRootViewController(@detailView)
    presentViewController(navigationView, animated:true, completion:nil)
  end

  # UIWebViewDelegate
  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    if navigationType != UIWebViewNavigationTypeBackForward
      UIGraphicsBeginImageContext(@webview.frame.size)
      @webview.layer.renderInContext(UIGraphicsGetCurrentContext())
      grab = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      @arrayImagenes[request.URL.absoluteString] = grab
    end
    true
  end

  # UIWebViewDelegate
  def webViewDidStartLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  # UIWebViewDelegate
  def webViewDidFinishLoad(webView)
    #@imgvcChild1.removeFromSuperview unless @imgvcChild1.nil?
    @imgvcChild2.removeFromSuperview unless @imgvcChild2.nil?

    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    #@backItem.enabled = webView.canGoBack
    #@forwardItem.enabled = webView.canGoForward
    
    @url_string = webView.request.URL.absoluteString
    @manager = GithubManager.new(@url_string, self)
    navigationItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
  end

  def webView(webView, didFailLoadWithError:error)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
  end

  def leftSwipe(gesture)
    return unless @webview.canGoBack
    if gesture.state == UIGestureRecognizerStateBegan

      UIGraphicsBeginImageContext(@webview.frame.size)
      @webview.layer.renderInContext(UIGraphicsGetCurrentContext())

      grab = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      @imgvcChild1.removeFromSuperview unless @imgvcChild1.nil?
      @imgvcChild1 = UIImageView.alloc.initWithImage(grab)
      @imgvcChild1.frame = @webview.frame
      @imgvcChild1.userInteractionEnabled = true

      if @arrayImagenes.length > 0
        #img = @arrayImagenes.lastObject
        img = @arrayImagenes.values.lastObject
        @imgvcChild2.removeFromSuperview unless @imgvcChild2.nil?
        @imgvcChild2 = UIImageView.alloc.initWithImage(img)
        @imgvcChild2.frame = @webview.frame
        @imgvcChild2.userInteractionEnabled = true
      end
=begin
      if @webview.canGoBack
        @webview.goBack
      end
=end
      self.view.addSubview(@imgvcChild2)
      self.view.addSubview(@imgvcChild1)
    end

    if gesture.state == UIGestureRecognizerStateChanged
      @imgvcChild1.frame = [
        [
          gesture.locationInView(@imgvcChild1.superview).x,
          @imgvcChild1.frame.origin.y
        ],
        [
          @imgvcChild1.frame.size.width,
          @imgvcChild1.frame.size.height
        ]
      ]
    end

    if gesture.state == UIGestureRecognizerStateEnded
      if gesture.locationInView(@imgvcChild1.superview).x >= self.view.frame.size.width / 2
        if @webview.canGoBack
          @webview.goBack
          #@arrayImagenes.pop()
          @imgvcChild1.removeFromSuperview unless @imgvcChild1.nil?
          @arrayImagenes.delete(@arrayImagenes.keys.lastObject)
        end
      else
        @imgvcChild1.removeFromSuperview unless @imgvcChild1.nil?
        @imgvcChild2.removeFromSuperview unless @imgvcChild2.nil?
      end
    end   
  end
=begin
  def leftSwipe(gesture)
    if gesture.state == UIGestureRecognizerStateEnded
      if @webview.canGoBack
        @webview.goBack
      end
    end
  end
=end
end