# -*- coding: utf-8 -*-
class IssueTableViewController < UITableViewController
  
  attr_accessor :manager
  attr_accessor :state  # "open" or "closed". if nil, "open"

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "issues/#{@manager.repo}" unless navigationItem.nil?
    tabBarController.title = "issues/#{@manager.repo}" unless tabBarController.nil?

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"refresh", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(true, animated:false)
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

  def viewDidAppear(animated)
    super
    self.tabBarController.navigationItem.backBarButtonItem = BW::UIBarButtonItem.styled(:plain, "")
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

end
