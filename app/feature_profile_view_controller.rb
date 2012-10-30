# -*- coding: utf-8 -*-
class FeatureProfileViewController < FeatureTemplateWebViewController
  
  # url is "https://github.com/:username"
  attr_accessor :url, :navTitle, :hideDoneButton  
  def javaScript
    "$('.avatared')[0].innerHTML"
  end
end