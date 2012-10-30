# -*- coding: utf-8 -*-
class ActivityGithubAPI_FollowDelete < ActivityTemplateGithubApi

  def informationMessage()
    "Stop Following..."
  end

  def apiUrl
    "https://api.github.com/user/following/" + @userName
  end
  
  def methodName
    "delete"
  end

  def activityType
    App.name + "_unfollow"
  end

  def activityTitle
    "UnFollow"
  end

  def activityImage
    UIImage.imageNamed("activity_follow.png")
  end
end