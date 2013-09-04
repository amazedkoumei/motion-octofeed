# -*- coding: utf-8 -*-
class FeatureTemplateWebViewController < UIViewController
  
  attr_accessor :url, :navTitle, :hideDoneButton
  
  # subclass must override
  def javaScript
    ""
  end

  def parseBeforeDidLoad()
    @url = url + "?mobile=0"
    @parsingWebview = UIWebView.new.tap do |v|
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@url)))
      v.delegate = self
    end
  end   

  def viewDidLoad()
    super

    @url = url + "?mobile=0"
    navigationItem.title = navTitle
    navigationController.navigationBar.tintColor = $NAVIGATIONBAR_COLOR

    if !@hideDoneButton
      @doneButton = UIBarButtonItem.new.tap do |b|
        b.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"doneButtonTap")
        navigationItem.rightBarButtonItem = b
      end
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
    navigationController.setToolbarHidden(true, animated:true)
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
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
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
    end      
  end

  # UIWebViewDelegate
  def webView(webView, didFailLoadWithError:error)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    if error.code != NSURLErrorCancelled
      App.alert($BAD_INTERNET_ACCESS_MESSAGE_FOR_WEBVIEW)
    else
      # skip alert message when
      # called viewDidLoad() before parseBeforeDidLoad() has finished
    end
  end

  def featureElement(webView)
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
    if @content.nil?
      @content = webView.stringByEvaluatingJavaScriptFromString(javaScript)
    end
    preHtml + @content + postHtml
  end

  def doneButtonTap
    dismissViewControllerAnimated(true, completion:nil)
  end
end