# -*- coding: utf-8 -*-
class DetailViewController < UITableViewController

  attr_accessor :url_string, :isHaveToRefresh
  
  def viewDidLoad()
    super

    @manager = GithubManager.new(@url_string, self)

    navigationItem.title = "#{@manager.repo}"

    @toolbarItems = Array.new.tap do |a|
      @doneButton = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:'doneButton')
      end
      @actionItem = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
        i.enabled = false
      end
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@doneButton
      a<<@flexibleSpace
      a<<@actionItem

      self.toolbarItems = a
    end

    @profileViewController = FeatureProfileViewController.new.tap do |v|
      v.url = "https://" + @manager.url.host + "/" + @manager.owner
      v.navTitle = "#{@manager.owner}"
      v.hideDoneButton = true
    end

    @issueTableViewController = UITabBarController.new.tap do |v|
      viewControllers = [
        UINavigationController.new.tap do |nv|
          IssueTableViewController.new.tap do |sv|
            # display open issue
            sv.manager = @manager
            sv.tabBarItem = UITabBarItem.new.tap do |ti|
              image = AMP::Util.imageForRetina(UIImage.imageNamed("tabbar_open.png"))            
              ti.initWithTitle("Open", image:image, tag:0)
            end
            nv.initWithRootViewController(sv)
          end
        end,
        UINavigationController.new.tap do |nv|
          IssueTableViewController.new.tap do |sv|
            # display closed issue
            sv.manager = @manager
            sv.state = "closed"
            sv.tabBarItem = UITabBarItem.new.tap do |ti|
              image = AMP::Util.imageForRetina(UIImage.imageNamed("tabbar_close.png"))            
              ti.initWithTitle("Closed", image:image, tag:1)
            end
            nv.initWithRootViewController(sv)
          end
        end
      ]
      v.setViewControllers(viewControllers, animated:false)
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
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
    when 0
      2
    when 1
      1
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    case section
    when 0
      "Repository"
    when 1
      "Owner"
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
    when 0
      # Repository section
      case indexPath.row
      when 0
        # README cell
        cell.textLabel.text = "README"
        if @manager.isGithubRepository?
          cell.detailTextLabel.text = @manager.repo
        else
          cell.textColor = UIColor.grayColor
          cell.accessoryType = UITableViewCellAccessoryNone
          cell.userInteractionEnabled = false
        end
      when 1
        # Issues cell
        @issuesCell = cell
        cell.textLabel.text = "Issues"
        cell.userInteractionEnabled = false
        cell = self.setIssueTableViewBadge(cell)
      end

    when 1
      # info section
      case indexPath.row
      when 0
        # Owner cell
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

  def setIssueTableViewBadge(cell)
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
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    case indexPath.section
    when 0
      # repositry section
      case indexPath.row
      when 0
        view = @readmeViewController
      when 1
        view = @issueTableViewController
      end

    when 1
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
