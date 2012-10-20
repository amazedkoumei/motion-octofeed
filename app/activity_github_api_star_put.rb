# -*- coding: utf-8 -*-
class ActivityGithubAPI_StarPut < ActivityTemplateGithubApi

  def informationMessage()
    "Adding Star..."
  end

  def apiUrl
    "https://api.github.com/user/starred/" + @userName + "/" + @repositoryName
  end
  
  def methodName
    "put"
  end

  def activityType
    App.name + "_add_star"
  end

  def activityTitle
    "Add Star"
  end

  def activityImage
    UIImage.imageNamed("activity_star.png")
  end

  def activityDidFinish(completed)
    super(completed)
    @parentViewController.isStarredRepository = true
  end
end