# -*- coding: utf-8 -*-
class FeatureReadmeViewController < FeatureTemplateWebViewController
  
  # url is String "https://github.com/:username/:reponame"
  attr_accessor :url, :navTitle, :hideDoneButton
  def javaScript
    "$('#readme')[0].innerHTML"
  end
end