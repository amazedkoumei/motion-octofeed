class GithubManager

  attr_accessor :api
  attr_accessor :url
  attr_accessor :path
  attr_accessor :owner
  attr_accessor :repo
  attr_accessor :isStarredRepo
  attr_accessor :isWatchingRepo
  attr_accessor :isFollowingUser

  ERROR_NOTIFICATION = "github_manager_error_notification"

  def initialize(url_string, delegate)
    @delegate = delegate
    unless url_string.nil?
      @url_string = url_string
      @url = NSURL.URLWithString(@url_string)
      @path = @url.path.slice(1, @url.path.length - 1)
      @path = @path + "#" + @url.fragment unless @url.fragment.nil?
      @owner, @repo = urlToOwnerAndRepo(@url)
    end
    @api = AMP::GithubAPI.instance
    def @api.errorAction(response, query)
      App.notification_center.post ERROR_NOTIFICATION
    end
  end

  def self.showAccountSettingViewController(viewController)
    subView = SettingListViewController.new.tap do |v|
      v.moveTo = v.MOVE_TO_SETTING_GITHUB_FEED
    end
    view = UINavigationController.alloc.initWithRootViewController(subView)
    viewController.presentViewController(view, animated:true, completion:nil)
  end

  def authToken
    App::Persistence[AMP::GithubAPI::USER_DEFAULT_AUTHTOKEN]
  end

  def urlToOwnerAndRepo(url)
    blank, owner, repo = url.path.componentsSeparatedByString("/")
    [owner.to_s, repo.to_s]
  end

  def fetchGithubStatus()
    @api.isStarredRepository(@owner, @repo) do |ret|
      @isStarredRepo = ret
      hasFinishedFetching()
    end
    @api.isWatchingRepository(@owner, @repo) do |ret|
      @isWatchingRepo = ret
      hasFinishedFetching()
    end
    @api.isFollowingUser(@owner) do |ret|
      @isFollowingUser = ret
      hasFinishedFetching()
    end
  end

  def hasFinishedFetching()
    ret = !@isStarredRepo.nil? && !@isWatchingRepo.nil? && !@isFollowingUser.nil?
    if ret && @delegate.respond_to?("githubFetchDidFinish")
      @delegate.send("githubFetchDidFinish")
    end
  end

  def isGithubRepositoryOrUser?
    (@url.host == "github.com" && !@owner.empty?)
  end

  def isGithubRepository?
    (@url.host == "github.com" && !@owner.empty? && !@repo.empty?)
  end

end