# -*- coding: utf-8 -*-
class WhatGithubFeedViewController < UIViewController
  
  def viewDidLoad
    super
    navigationItem.title = "What's Github Feed?"
    @webview = UIWebView.new.tap do |v|
      v.frame = self.view.bounds
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString("http://amazedkoumei.github.com/motion-octofeed/whats_github_feed.html")))
      v.delegate = self
      view.addSubview(v)
    end
  end
end