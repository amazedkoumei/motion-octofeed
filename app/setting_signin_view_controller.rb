# -*- coding: utf-8 -*-
class SettingGithubAccountViewController < UIViewController

  def viewDidLoad()
    super
    
    navigationItem.title = "GitHub Account"

    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      url = NSURL.URLWithString("https://github.com/login")
      v.loadRequest(NSURLRequest.requestWithURL(url))
      v.scalesPageToFit = true;
      v.delegate = self
      view.addSubview(v)
    end

  end

  # UIWebViewDelegate
  def webView(webView, shouldStartLoadWithRequest:request, navigationType:navigationType)
    white_list = [
      "https://github.com/login",
      "https://github.com/session",
      "https://github.com/logout"
    ]
    if request.URL.absoluteString == "https://github.com/"
      self.authnication()
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

  def authnication()
    @userName = @webview.stringByEvaluatingJavaScriptFromString("document.getElementsByName('login')[0].value")
    @password = @webview.stringByEvaluatingJavaScriptFromString("document.getElementsByName('password')[0].value")
    
    AMP::InformView.show("authentication...", target:navigationController.view, animated:true)

    @githubAPI = AMP::GithubAPI.instance()
    payload = {
      client_secret: ENV_VARS[:github][:client_secret],
      #scopes: ["public_repo", "user", "repo", "notifications"],
      scopes: ["public_repo", "user", "notifications"],
      note: App.name, 
      note_url: "http://amazedkoumei.github.com/motion-octofeed/"
    }
    client_id = ENV_VARS[:github][:client_id]
    path = "clients/#{client_id}"
    @githubAPI.get_or_createAuthorization(@userName, @password, payload, path) do |response|
      if response != AMP::GithubAPI::AUTH_ERROR_MESSAGE
        AMP::InformView.hide(true)
        self.navigationController.popViewControllerAnimated(true)
      else
        AMP::InformView.hide(true)
        url = NSURL.URLWithString("https://github.com/logout")
        @webview.loadRequest(NSURLRequest.requestWithURL(url))
        authErrorAction()
      end
    end

  end

  def authErrorAction()
    App.alert("API Auth Failed.\nTry Again.")
    navigationItem.hidesBackButton = false
  end
end
