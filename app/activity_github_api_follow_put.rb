# -*- coding: utf-8 -*-
class ActivityGithubAPI_FollowPut < ActivityTemplateGithubApi

  def informationMessage()
    "Start Following..."
  end

  def apiUrl
    "https://api.github.com/user/following/" + @userName
  end
  
  def methodName
    "put"
  end

  def activityType
    App.name + "_follow"
  end

  def activityTitle
    "Follow"
  end

  def activityImage
    UIImage.imageNamed("activity_follow.png")
  end
end