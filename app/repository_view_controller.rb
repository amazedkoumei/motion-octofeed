# -*- coding: utf-8 -*-
class RepsitoryViewController < UITableViewController

  attr_accessor :url_string, :isHaveToRefresh
  
  def viewDidLoad()
    super

    @manager = GithubManager.new(@url_string, self)
    @paser = GithubPageParser.new(@manager.owner, @manager.repo)
    @hasFinishFetch = false

    navigationItem.title = "#{@manager.repo}"

    @toolbarItems = Array.new.tap do |a|
      @doneButton = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:'doneButton')
      end
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@doneButton
      a<<@flexibleSpace

      self.toolbarItems = a
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

  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:true)

    @parseObserver = App.notification_center.observe GithubPageParser::NOTIFICATION_FINISH_LOADING do |notification|
      @readmeViewController ||= begin
        FeatureReadmeViewController.new.tap do |v|
          v.url = @paser.readme_url
          p @paser.readme_url
          v.navTitle = "#{@manager.owner}/#{@manager.repo}"
          v.hideDoneButton = true
          v.parseBeforeDidLoad()
        end
      end

      self.cell_enable(@readmeCell)
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
      3
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
=begin
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:CELLID)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end
    end
=end
    case indexPath.section
    when 0
      cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
        cell = UITableViewCell.new.tap do |c|
          c.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:CELLID)
          c.selectionStyle = UITableViewCellSelectionStyleBlue
          c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        end
      end

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

        if @readmeViewController.nil?
          self.cell_disable(cell)
        end
        
        @readmeCell = cell
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
        # star
        cell = RepsitoryViewActionCell.new.tap do |c|
          if @hasFinishFetch == true
            if @manager.isStarredRepo
              c.textLabel.text = "Unstar"
            else
              c.textLabel.text = "Star"
            end
          end
          c.iconLabel.text = "\uf02a"
        end
      when 1
        # wath
        cell = RepsitoryViewActionCell.new.tap do |c|
          if @hasFinishFetch == true
            if @manager.isWatchingRepo
              c.textLabel.text = "Unwatch"
            else
              c.textLabel.text = "Watch"
            end
          end
          c.iconLabel.text = "\uf04e"
        end
      when 2
        # follow
        cell = RepsitoryViewActionCell.new.tap do |c|
          if @hasFinishFetch == true
            if @manager.isFollowingUser
              c.textLabel.text = "Unfollow"
            else
              c.textLabel.text = "Follow"
            end
          end
          c.iconLabel.text = "\uf018"
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
        if @manager.isStarredRepo
          self.tapActionCell("unstarRepository", "Removing Star...")
        else
          self.tapActionCell("starRepository", "Adding Star...")
        end
      when 1
        if @manager.isWatchingRepo
          self.tapActionCell("unwatchRepository", "Stop Watching...")
        else
          self.tapActionCell("watchRepository", "Start Watching...")
        end
      when 2
        if @manager.isFollowingUser
          self.tapActionCell("unfollowUser", "Stop Following...")
        else
          self.tapActionCell("followUser", "Start Following...")
        end
      end
    end

    backButton = UIBarButtonItem.new.tap do |b|
      b.title = "back"
      navigationItem.backBarButtonItem = b
    end
    
    navigationController.pushViewController(view, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
  end

  def tapActionCell(method, message)
    AMP::InformView.show(message, target:self.view, animated:true)
    if method == "followUser" || method == "unfollowUser"
      @manager.api.send(method, @manager.owner) do |ret|
        if ret == true
          completeGithubPerformActivity()
        else
          AMP::InformView.hide(true)
          App.alert("Error")
        end 
      end
    else
      @manager.api.send(method, @manager.owner, @manager.repo) do |ret|
        if ret == true
          completeGithubPerformActivity()
        else
          AMP::InformView.hide(true)
          App.alert("Error")
        end 
      end
    end
    tableView.reloadData
  end

  def doneButton
    dismissViewControllerAnimated(true, completion:nil)
  end

  # GithubManager delegate
  def githubFetchDidFinish()
    @hasFinishFetch = true
    tableView.reloadData
  end

  def prepareGithubPerformActivity(activity)
    AMP::InformView.show(activity.informationMessage(), target:view, animated:true)
  end

  # GithubApiTemplateActivity delegate
  def completeGithubPerformActivity()
    AMP::InformView.hide(true)
    @manager.fetchGithubStatus()
    App.alert("Success")
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

  def cell_disable(cell)
    cell.userInteractionEnabled = false
    cell.textLabel.enabled = false
  end

  def cell_enable(cell)
    cell.userInteractionEnabled = true
    cell.textLabel.enabled = true
  end

end
