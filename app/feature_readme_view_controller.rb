# -*- coding: utf-8 -*-
class FeatureReadmeViewController < FeatureTemplateWebViewController
  
  # url is String "https://github.com/:username/:reponame"
  attr_accessor :url, :navTitle
  def javaScript
    #{}"$('#readme')[0].innerHTML"
    "$('.blob-file-content')[0].innerHTML"
  end
end