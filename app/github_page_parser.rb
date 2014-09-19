class GithubPageParser

  attr_accessor :readme_url

  NOTIFICATION_FINISH_LOADING = "GithubPageParser_NOTIFICATION_FINISH_LOADING"

  def initialize(owner, repo)
    super
    @owner = owner
    @repo = repo

    url = "https://github.com/#{@owner}/#{@repo}"
    @parsingWebview = UIWebView.new.tap do |v|
      v.delegate = self
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString(url)))
    end
  end

  def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
    true
  end

  def webViewDidFinishLoad(webView)
    self.load_jquery(webView)
    @readme_url = "https://github.com"
    @readme_url += webView.stringByEvaluatingJavaScriptFromString("$($('.bubble-expand')[1]).attr('href')")
    App.notification_center.post NOTIFICATION_FINISH_LOADING
  end

  def load_jquery(webView)
    path = NSBundle.mainBundle.pathForResource("jquery-2.1.1.min", ofType:"js")
    jsCode = NSString.stringWithContentsOfFile(path, encoding:NSUTF8StringEncoding, error:nil)
    webView.stringByEvaluatingJavaScriptFromString(jsCode)
    webView
  end

end