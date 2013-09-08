# -*- coding: utf-8 -*-
class DetailViewController < UITableViewController

  attr_accessor :url_string, :isHaveToRefresh
  
  def viewDidLoad()
    super

    navigationItem.title = @url_string

    @manager = GithubManager.new(@url_string, self)

    navigationItem.title = "#{@manager.owner}/#{@manager.repo}"
    navigationController.navigationBar.tintColor = $NAVIGATIONBAR_COLOR

    @doneButton = UIBarButtonItem.new.tap do |b|
      b.initWithTitle("done", style:UIBarButtonItemStylePlain, target:self, action:"doneButton")
      navigationItem.rightBarButtonItem = b
    end

    @toolbarItems = Array.new.tap do |a|
      @actionItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
        i.enabled = false
      end
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@flexibleSpace
      a<<@actionItem

      self.toolbarItems = a
    end

    @profileViewController = FeatureProfileViewController.new.tap do |v|
      v.url = "https://" + @manager.url.host + "/" + @manager.owner
      v.navTitle = "#{@manager.owner}"
      v.hideDoneButton = true
      #v.parseBeforeDidLoad()
    end

    @issueTableViewController = UITabBarController.new.tap do |v|
      v.viewControllers = [
        IssueTableViewController.new.tap do |sv|
          # display open issue
          sv.manager = @manager
          sv.tabBarItem = UITabBarItem.new.initWithTitle("Open", image:nil, tag:0)
        end,
        IssueTableViewController.new.tap do |sv|
          # display closed issue
          sv.manager = @manager
          sv.state = "closed"
          sv.tabBarItem = UITabBarItem.new.initWithTitle("Closed", image:nil, tag:1)
        end
      ]
    end

    @readmeViewController = FeatureReadmeViewController.new.tap do |v|
      v.url = "https://" + @manager.url.host + "/" + @manager.owner + "/" + @manager.repo
      v.navTitle = "#{@manager.owner}/#{@manager.repo}"
      v.hideDoneButton = true
      v.parseBeforeDidLoad()
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:true)
    @managerErrorObserver = App.notification_center.observe GithubManager::ERROR_NOTIFICATION do |notification|
      GithubManager.showAccountSettingViewController(self)
    end
  end

  def viewDidAppear(animated)
    super
    @manager.fetchGithubStatus()
  end

  def viewWillDisappear(animated)
    super
    navigationController.setToolbarHidden(true, animated:animated)
    App.notification_center.unobserve @managerErrorObserver
  end

  def numberOfSectionsInTableView(tableView)
    3
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
      when 0
        0
      when 1
        2
      when 2
        1
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    case section
      when 0
        "URL"
      when 1
        "Repository: #{@manager.repo}"
      when 2
        "Owner: #{@manager.owner}"
    end
  end

  def tableView(tableView, viewForFooterInSection:section)
    if section == 0
      view = UIView.new.tap do |v|
        label = UILabel.new.tap do |l|
          l.frame = CGRectMake(20, 0, 280, 10)
          l.backgroundColor = UIColor.clearColor
          l.textAlignment = UITextAlignmentLeft
          l.textColor = UIColor.blueColor
          l.lineBreakMode = UILineBreakModeCharacterWrap
          l.numberOfLines = 0
          l.font = UIFont.boldSystemFontOfSize(16)
          l.shadowColor = UIColor.whiteColor
          l.shadowOffset = CGSizeMake(0, 1);
          l.text = @url_string
          l.when_tapped do
            view = WebViewController.new.tap do |v|
              v.url_string = @url_string
              navigationController.pushViewController(v, animated:true)
            end
          end
          l.sizeToFit()
        end
        v.addSubview(label)
      end
    end
  end

  def tableView(tableView, heightForFooterInSection:section)
    if section == 0
      70
    else
      # default height
      -1
    end
  end

  CELLID = "detailmenu"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:CELLID)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end
    end

    case indexPath.section
      when 1
      # Repository section
      case indexPath.row
      when 0
        cell.textLabel.text = "README"
        if @manager.isGithubRepository?
          cell.detailTextLabel.text = @manager.repo
        else
          cell.textColor = UIColor.grayColor
          cell.accessoryType = UITableViewCellAccessoryNone
          cell.userInteractionEnabled = false
        end
      when 1
        @issuesCell = cell
        cell.textLabel.text = "Issues"
        cell.userInteractionEnabled = false
        if @manager.isGithubRepository?
          @manager.api.repositoryIssueCount(@manager.owner, @manager.repo, {per_page: 100}) do |count|
            if count.is_a?(Numeric)
              cell.userInteractionEnabled = true
              @issuesCell.detailTextLabel.text = count.to_s
              @issueTableViewController.viewControllers[0].tabBarItem.badgeValue = count.to_s
            else
              @issuesCell.detailTextLabel.text = "disable"
            end
          end
          @manager.api.repositoryIssueCount(@manager.owner, @manager.repo, {per_page: 100, state: "closed"}) do |count|
            if count.is_a?(Numeric)
              @issueTableViewController.viewControllers[1].tabBarItem.badgeValue = count.to_s
            end
          end
        else
          cell.textColor = UIColor.grayColor
          cell.accessoryType = UITableViewCellAccessoryNone
        end
      end

      when 2
      # info section
      case indexPath.row
      when 0
        cell.textLabel.text = "Owner"
        if @manager.isGithubRepositoryOrUser?
          cell.detailTextLabel.text = @manager.owner
        else
          cell.textColor = UIColor.grayColor
          cell.accessoryType = UITableViewCellAccessoryNone
          cell.userInteractionEnabled = false
        end
      end
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    case indexPath.section
      when 1
      # repositry section
      case indexPath.row
      when 0
        view = @readmeViewController
      when 1
        view = @issueTableViewController
      end

      when 2
      # info section
      case indexPath.row
      when 0
        view = @profileViewController
      end
    end

    backButton = UIBarButtonItem.new.tap do |b|
      b.title = "back"
      navigationItem.backBarButtonItem = b
    end
    navigationController.pushViewController(view, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
  end

  def actionButton
    @activityController = AMP::ActivityViewController.new.tap do |a|

      #TODO: set html's title to text the case of gist
      activityItems = [@manager.url, "#{@manager.path} - Github"];

      includeActivities = Array.new.tap do |arr|
        
        authToken = @manager.authToken

        arr<<AMP::ActivityViewController.activityOpenInSafariActivity()
        arr<<AMP::ActivityViewController.activityHatenaBookmark(@manager.url.absoluteString, {:backurl => "octofeed:/", :backtitle => "octofeed"})

        if @manager.isGithubRepository?

          #TODO: display always after fixed that setting title to text the case of gist
          arr<<UIActivityTypePostToTwitter
          arr<<UIActivityTypeMail

          if @manager.isStarredRepo
            arr<<AMP::ActivityViewController.activityGithubAPI_StarDelete(authToken, self)
          else
            arr<<AMP::ActivityViewController.activityGithubAPI_StarPut(authToken, self)
          end

          if @manager.isWatchingRepo
            arr<<AMP::ActivityViewController.activityGithubAPI_WatchDelete(authToken, self)
          else
            arr<<AMP::ActivityViewController.activityGithubAPI_WatchPut(authToken, self)
          end
        end

        if @manager.isGithubRepositoryOrUser?
          if @manager.isFollowingUser
            arr<<AMP::ActivityViewController.activityGithubAPI_FollowDelete(authToken, self)
          else
            arr<<AMP::ActivityViewController.activityGithubAPI_FollowPut(authToken, self)
          end
        end

      end

      a.initWithActivityItems(activityItems, applicationActivities:includeActivities)
      presentViewController(a, animated:true, completion:nil)
    end
  end

  def doneButton
    dismissViewControllerAnimated(true, completion:nil)
  end

  # GithubManager delegate
  def githubFetchDidFinish()
    if @manager.isGithubRepositoryOrUser?
      @actionItem.enabled = true
    end
  end

  def prepareGithubPerformActivity(activity)
    @actionItem.enabled = false
    AMP::InformView.show(activity.informationMessage(), target:view, animated:true)
  end

  # GithubApiTemplateActivity delegate
  def completeGithubPerformActivity()
    AMP::InformView.hide(true)
    @manager.fetchGithubStatus()
    App.alert("Success")
    @actionItem.enabled = true
  end

  # GithubApiTemplateActivity delegate
  def completeGithubPerformActivityWithError(errorCode)
    AMP::InformView.hide(true)
    if errorCode == 401
      subView = SettingListViewController.new
      subView.moveTo = subView.MOVE_TO_SETTING_GITHUB_ACCOUNT
      view = UINavigationController.alloc.initWithRootViewController(subView)
      
      isHaveToRefresh = true

      # FIXME: get following warning and not be present....Why?
      # Warning: Attempt to present <UINavigationController: 0x1750ae90> on <UINavigationController: 0xd0bfd70> while a presentation is in progress!
      #presentViewController(view, animated:true, completion:nil)

      # alternative to presentViewController
      App.alert("Error")
      
    else
      App.alert("Error")
    end
    @actionItem.enabled = true
  end
end
