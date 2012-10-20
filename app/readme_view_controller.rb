# -*- coding: utf-8 -*-
class ReadmeViewController < UIViewController
  
  attr_accessor :url, :navTitle
 
  def viewDidLoad
    super

    # url is "https://github.com/:username/:reponame"
    @url = url + "#readme"
#    @title = title
    navigationItem.title = navTitle
    navigationController.navigationBar.tintColor = $NAVIGATIONBAR_COLOR

    @doneButton = UIBarButtonItem.new.tap do |b|
      b.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"doneButtonTap")
      navigationItem.rightBarButtonItem = b
    end

    @parsingWebview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(@url)))
      v.delegate = self
    end

    @displayWebview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.delegate = self
      view.addSubview(v)
    end

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
      @displayWebview.loadHTMLString(readmeElement(webView), baseURL:nil)
    end      
  end

  # UIWebViewDelegate
  def webView(webView, didFailLoadWithError:error)
    App.alert("Sorry, try again.")
  end

  def readmeElement(webView)
    preHtml = <<-EOS
<html>
<head>
<style type='text/css'>
body {
  background-color: #FDFDFD;
}
div#readme {
  font-family: Georgia, "Times New Roman", serif;
  line-height: 150%;
  vertical-align: baseline;
  margin:20px;
}
a {
  color: #9C0001;
  -webkit-tap-highlight-color: #d7dcdf;
  text-decoration: none;
}

</style>
</head>
<body>
<div id='readme'>
      EOS

      postHtml = <<-EOS
</div>
</body>
</html>
      EOS

    preHtml + webView.stringByEvaluatingJavaScriptFromString("document.getElementById('readme').innerHTML") + postHtml
  end

  def doneButtonTap
    dismissViewControllerAnimated(true, completion:nil)
  end
end