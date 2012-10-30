# -*- coding: utf-8 -*-
class ActivityGithubAPI_StarDelete < ActivityTemplateGithubApi

  def informationMessage()
    "Removing Star..."
  end

  def apiUrl
    "https://api.github.com/user/starred/" + @userName + "/" + @repositoryName
  end
  
  def methodName
    "delete"
  end

  def activityType
    App.name + "_remove_star"
  end

  def activityTitle
    "Remove Star"
  end

  def activityImage
    UIImage.imageNamed("activity_star.png")
  end
end