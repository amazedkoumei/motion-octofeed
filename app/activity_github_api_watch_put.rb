# -*- coding: utf-8 -*-
class ActivityGithubAPI_WatchPut < ActivityTemplateGithubApi

  def informationMessage()
    "Start Watching..."
  end

  def apiUrl
    "https://api.github.com/user/subscriptions/" + @userName + "/" + @repositoryName
  end
  
  def methodName
    "put"
  end

  def activityType
    App.name + "_watch_repository"
  end

  def activityTitle
    "Watch"
  end

  def activityImage
    UIImage.imageNamed("activity_watch.png")
  end
end