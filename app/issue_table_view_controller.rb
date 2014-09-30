# -*- coding: utf-8 -*-
class IssueTableViewController < UITableViewController
  
  attr_accessor :manager
  attr_accessor :state  # "open" or "closed".

  STATE_OPEN = "open"
  STATE_CLOSED = "closed"

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "#{self.state.capitalize} Issues"
    navigationItem.setHidesBackButton(true)
    navigationItem.backBarButtonItem = BW::UIBarButtonItem.styled(:plain, "")

    @toolbarItems = Array.new.tap do |a|
      @doneButton = UIBarButtonItem.new.tap do |i|
        i.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:'doneButton')
      end
      @turnButton = UIBarButtonItem.new.tap do |i|
        i.initWithTitle(self.turnState(), style:UIBarButtonItemStylePlain, target:self, action:'turnView')
      end
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

      a<<@doneButton
      a<<@flexibleSpace
      a<<@turnButton

      self.toolbarItems = a
    end

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"refresh", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:animated)
    App.notification_center.unobserve @managerErrorObserver
    @managerErrorObserver = App.notification_center.observe GithubManager::ERROR_NOTIFICATION do |notification|
      GithubManager.showAccountSettingViewController(self)
    end
    refresh() if @json.nil?
  end

  def viewWillDisappear(animated)
    super
    App.notification_center.unobserve @managerErrorObserver
  end

  def numberOfSectionsInTableView(tableView)
    if(!@json.nil?)
      1
    else
      0
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if(!@json.nil?)
      @json.length
    else
      0
    end
  end

  CELLID = "feed"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    issue = @json[indexPath.row]

    cellId = issue[:id].to_s
    cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
      cell = IssueTableViewCell.new.tap do |c|
        width = self.tableView.frame.size.width
        height = self.tableView(tableView, heightForRowAtIndexPath:indexPath)
        c.frame = [[0, 0], [width, height]]
        c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        c.dataSource = issue
      end
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    @detailView = IssueDetailTableViewController.new.tap do |v|
      v.manager = @manager
      v.issue = @json[indexPath.row]
    end

    navigationController.pushViewController(@detailView, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    issue = @json[indexPath.row]
    IssueTableViewCell.contentHeight(issue[:title])
  end

  def turnView()
    IssueTableViewController.new.tap do |sv|
      # display open issue
      sv.manager = @manager
      sv.state = self.turnState()
      sv.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal

      UIView.beginAnimations(nil, context:nil)
      UIView.setAnimationCurve(UIViewAnimationCurveEaseInOut)
      UIView.setAnimationDuration(0.75)
      navigationController.pushViewController(sv, animated:false)    
      UIView.setAnimationTransition(UIViewAnimationTransitionFlipFromRight, forView:self.navigationController.view, cache:false)
      UIView.commitAnimations
    end
  end

  def turnState()
    if self.state.nil?
      STATE_CLOSED
    elsif self.state == STATE_OPEN
      STATE_CLOSED
    elsif self.state == STATE_CLOSED
      STATE_OPEN
    end
  end

  def refresh()
    begin
      #@informView.showWithAnimation(false)
      payload = {
        per_page: 100
      }
      payload[:state] = @state unless state.nil?
      @manager.api.getRepositoryIssueList(@manager.owner, @manager.repo, payload) do |response|
        if response.ok?
          @json = BW::JSON.parse(response.body)
          tabBarItem.badgeValue = @json.length.to_s
          finishRefresh()
        end
      end
    rescue => e
      finishRefresh()
      App.alert(e)
    end
  end

  def finishRefresh()
    tableView.reloadData()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
  end

  def doneButton
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical
    dismissViewControllerAnimated(true, completion:nil)
  end

end
