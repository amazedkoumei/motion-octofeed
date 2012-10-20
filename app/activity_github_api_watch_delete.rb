# -*- coding: utf-8 -*-
class ActivityGithubAPI_WatchDelete < ActivityTemplateGithubApi

  def informationMessage()
    "Stop Watching..."
  end

  def apiUrl
    "https://api.github.com/user/subscriptions/" + @userName + "/" + @repositoryName
  end
  
  def methodName
    "delete"
  end

  def activityType
    App.name + "_unwatch_repository"
  end

  def activityTitle
    "UnWatch"
  end

  def activityImage
    UIImage.imageNamed("activity_watch.png")
  end

  def activityDidFinish(completed)
    super(completed)
    @parentViewController.isWatchingRepository = false
  end
end