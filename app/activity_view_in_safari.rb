# -*- coding: utf-8 -*-
class ActivityViewInSafari < UIActivity

  def activityType
    App.name + "_safari"
  end

  def activityTitle
    "View in Safari"
  end

  def activityImage
    UIImage.imageNamed("activitiy_safari.png")
  end

  def canPerformWithActivityItems(activityItems)
    true
  end

  def prepareWithActivityItems(activityItems)
    for item in activityItems
      if item.class.name == "NSURL"
        @url = item
      end
    end
  end

  def performActivity()
    if !@url.nil?
      App.open_url(@url);
    else
      App.alert("Invalid URL")
    end
  end
end