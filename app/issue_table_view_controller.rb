# -*- coding: utf-8 -*-
class IssueTableViewController < UITableViewController
  
  attr_accessor :manager

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "#{@manager.repo}/issues"

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

  def viewDidDisappear(animated)
    AMP::InformView.hide(false)
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
        c.issue = issue
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
    80
  end

  def refresh()
    begin
      #@informView.showWithAnimation(false)
      AMP::InformView.show("loading..", target:navigationController.view, animated:true)

      @manager.api.getRepositoryIssueList(@manager.owner, @manager.repo) do |response|
        if response.ok?
          @json = BW::JSON.parse(response.body)

          finishRefresh()
        end
      end
    rescue => e
      finishRefresh()
      App.alert(e)
    end
  end

  def finishRefresh()
    view.reloadData
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
    #@informView.hideWithAnimation(true)
    AMP::InformView.hide(true)
  end

end
