# -*- coding: utf-8 -*-
class ActivityTemplateGithubApi < UIActivity

  # FIXME: I'd like to wride Const but I don't know how to overwride Const
  def informationMessage
    ""
  end

  def apiUrl
    # subclass must override
    # used in performActivity method
    nil
  end
  
  def methodName
    # subclass must override
    # used in performActivity method
    nil
  end

  def activityType
    # subclass must override
    nil
  end

  def activityTitle
    # subclass must override
    nil
  end

  def activityImage
    # subclass must override
    nil
  end

  def canPerformWithActivityItems(activityItems)
    true
  end

  def prepareWithActivityItems(activityItems)
    for item in activityItems
      if item.class.name == "NSURL"

        @url = item
        if !@url.nil?
          blank, @userName, @repositoryName = @url.path.componentsSeparatedByString("/")
        end

      elsif item.class.name == "DetailViewController"

        @parentViewController = item
        @informView = InformView.new.tap do |v|
          v.message = informationMessage()
        end
        @parentViewController.navigationController.view.addSubview(@informView)

      else
        puts "class name: " + item.class.name
      end
    end
  end

  def performActivity()
    @informView.showWithAnimation(false)
    #App::Persistence[$USER_DEFAULTS_KEY_GITHUB_API_TOKEN] = nil
    authHeader = "token " + (App::Persistence[$USER_DEFAULTS_KEY_GITHUB_API_TOKEN] || "")
    activityDidFinish(true)
    BW::HTTP.send(methodName, apiUrl, {headers: {Authorization: authHeader}}) do |response|
      if response.status_code == 204
        # success
        @informView.hideWithAnimation(true)
        App.alert("OK")
      elsif response.status_code == 401
        # auth error
        @informView.hideWithAnimation(true)
        showSettingGithubAccountViewContoller()
      else
        # unknown error
        @informView.hideWithAnimation(true)
        App.alert("Error")
      end
    end
  end

  def activityDidFinish(completed)
    super(completed)
  end

  def showSettingGithubAccountViewContoller()
    subView = SettingListViewController.new
    subView.moveTo = subView.MOVE_TO_SETTING_GITHUB_ACCOUNT
    view = UINavigationController.alloc.initWithRootViewController(subView)
    @parentViewController.isHaveToRefresh = true
    @parentViewController.presentViewController(view, animated:true, completion:lambda{puts "hoge"})
  end
end