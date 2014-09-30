# -*- coding: utf-8 -*-
class SettingSignoutViewController < UIViewController

  def viewDidLoad()
    super
    
    navigationItem.title = "Sign out"

    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      url = NSURL.URLWithString("https://github.com/logout")
      v.loadRequest(NSURLRequest.requestWithURL(url))
      v.scalesPageToFit = true;
      v.delegate = self
      view.addSubview(v)
    end

  end

  # UIWebViewDelegate
  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    p request.URL.absoluteString
    white_list = [
      "https://github.com/logout",
      "https://github.com/session"
    ]
    
    if request.URL.absoluteString == "https://github.com/"
      self.navigationController.popViewControllerAnimated(true)
      false
    elsif white_list.include?(request.URL.absoluteString)
      true
    else
      false
    end
  end

  # UIWebViewDelegate
  def webViewDidStartLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = true
  end

  def webViewDidFinishLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
  end

  # UIWebViewDelegate
  def webViewDidFinishLoad(webView)
    UIApplication.sharedApplication.networkActivityIndicatorVisible = false
  end

end
