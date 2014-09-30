# -*- coding: utf-8 -*-
class FeatureTemplateWebViewController < UIViewController
  
  attr_accessor :url, :navTitle, :hideDoneButton
  
  # subclass must override
  def javaScript
    ""
  end

  def parseBeforeDidLoad()
    @url = url
    @parsingWebview = UIWebView.new.tap do |v|
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@url)))
      v.delegate = self
    end
  end   

  def viewDidLoad()
    super

    @url = url
    navigationItem.title = navTitle

    @toolbarItems = Array.new.tap do |a|
      @doneButton = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:'doneButton')
      end
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@doneButton
      a<<@flexibleSpace

      self.toolbarItems = a
    end

    if @parsingWebview.nil?
      @parsingWebview = UIWebView.new.tap do |v|
        v.frame = self.view.bounds
        v.delegate = self
      end
    end

    @displayWebview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.delegate = self
      v.scrollView.delegate = self
      view.addSubview(v)
    end

    if @content.nil?
      @parsingWebview.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@url)))
    else
      @displayWebview.loadHTMLString(@content, baseURL:nil)
    end

  end
  
  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:true)
  end

  # UIWebViewDelegate
  def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
    if inType == UIWebViewNavigationTypeLinkClicked
      App.open_url(inRequest.URL)
      return false
    end
    return true
  end

  # UIWebViewDelegate
  def webViewDidStartLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  # UIWebViewDelegate
  def webViewDidFinishLoad(webView)
    if webView == @parsingWebview
      @content = featureElement(webView)
      if !@displayWebview.nil?
        @displayWebview.loadHTMLString(@content, baseURL:nil)
      end

      # rewrite cookie for keeping mobile view on webview
      if @rewriteCookiewebview.nil?
        @rewriteCookiewebview = UIWebView.new.tap do |v|
          v.frame = self.view.bounds
          v.delegate = self
        end
      end
      @rewriteCookiewebview.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString("https://github.com/?mobile=1")))
    elsif webView == @displayWebview
      UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    end      
  end

  # UIWebViewDelegate
  def webView(webView, didFailLoadWithError:error)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    if error.code != NSURLErrorCancelled
      App.alert("#{$BAD_INTERNET_ACCESS_MESSAGE_FOR_WEBVIEW} #{error.code}")
    else
      # skip alert message when
      # called viewDidLoad() before parseBeforeDidLoad() has finished
    end
  end

  def featureElement(webView)
    self.load_jquery(webView)
    preHtml = <<-EOS
<html>
<head>
<style type='text/css'>
body {
  background-color: #FDFDFD;
}
div#octofeed-feature {
  font-family: Georgia, "Times New Roman", serif;
  line-height: 150%;
  vertical-align: baseline;
  margin:20px;
  padding-bottom:30px;
}
a {
  color: #9C0001;
  -webkit-tap-highlight-color: #d7dcdf;
  text-decoration: none;
}

</style>
</head>
<body>
<div id='octofeed-feature'>
      EOS

      postHtml = <<-EOS
</div>
</body>
</html>
      EOS
    #if @content.nil? || @content == ""
    if @content.nil?
      @content = webView.stringByEvaluatingJavaScriptFromString(javaScript)
    end
    preHtml + @content + postHtml
  end

  def load_jquery(webView)
    path = NSBundle.mainBundle.pathForResource("jquery-2.1.1.min", ofType:"js")
    jsCode = NSString.stringWithContentsOfFile(path, encoding:NSUTF8StringEncoding, error:nil)
    webView.stringByEvaluatingJavaScriptFromString(jsCode)
    webView
  end


  def scrollViewDidScroll(scrollView)
    translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview)
    if translation.y > 0
      self.navigationController.setNavigationBarHidden(false, animated:true)
    elsif translation.y < 0
      self.navigationController.setNavigationBarHidden(true, animated:true)
    end
  end

  def doneButton
    dismissViewControllerAnimated(true, completion:nil)
  end
 
end