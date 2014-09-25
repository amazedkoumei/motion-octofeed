# -*- coding: utf-8 -*-
class NotificationTableViewController < UITableViewController
  
  def viewDidLoad()
    super
    
    navigationItem.title = "Notifications"

    @footerView = AMP::LoadingTableFooterView.new.tap do |v|
      v.initWithFrame([[0, 0], [tableView.frame.size.width, 44]])
      tableView.tableFooterView = v
    end

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"refresh", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end

    @manager = GithubManager.new(nil, self)
    @page = 1

  end

  def viewWillAppear(animated)
    super
    tableView.reloadData()

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
      @json.size
    else
      0
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if(!@json.nil?)
      key = @json.keys[section]
      @json[key].length
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    key = @json.keys[indexPath.section]
    notification = @json[key][indexPath.row]

    cellId = notification[:id].to_s
    cell = tableView.dequeueReusableCellWithIdentifier(cellId)
      
    if cell.nil?
      cell = NotificationTableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        c.dataSource = notification
      end
    else
      cell.dataSource = notification
      cell.aContentView.setNeedsDisplay()
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    
    key = @json.keys[indexPath.section]
    notification = @json[key][indexPath.row]

    @manager.api.patchNotifications(notification[:id]) do |ret|
      notification[:unread] = false if ret
    end

    UINavigationController.new.tap do |n|
      @webView = WebViewController.new.tap do |v|
        v.url_string = @json[key][indexPath.row][:subject][:url]
      end
      n.initWithRootViewController(@webView)
      n.modalTransitionStyle = UIModalTransitionStyleCrossDissolve
      presentViewController(n, animated:true, completion:nil)
      tableView.deselectRowAtIndexPath(indexPath, animated:false)
    end

  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    key = @json.keys[indexPath.section]
    notification = @json[key][indexPath.row]
    NotificationTableViewCell.contentHeight(notification[:subject][:title])
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if(!@json.nil?)
      @json.keys[section]
    end
  end

  def refresh()
    begin
      payload = {
        per_page: 100
      }
      @manager.api.getNotifications(payload) do |response|
        if response.ok?
          json = BW::JSON.parse(response.body)
          @json = reHash(json)
          finishRefresh()
        end
      end
    rescue => e
      finishRefresh()
      App.alert(e)
    end
  end

  def scrollViewDidScroll(scrollView)
    bottomPoint = CGPointMake(
      160, 
      self.view.bounds.size.height + scrollView.contentOffset.y
    )
    index_path = tableView.indexPathForRowAtPoint(bottomPoint)
    unless index_path.nil?
      if index_path.section == @json.size - 1
        key = @json.keys[index_path.section]
        if index_path.row == @json[key].size - 1
          self.paginate()
        end
      end
    end
  end

  def paginate()
    return if @is_paginating == true

    @footerView.startAnimating

    @is_paginating = true
    @page = @page + 1
    payload = {
      page: @page
    }
    @manager.api.getNotifications(payload) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body)
        #p json
        @json = reHash(json)
        @footerView.stopAnimating
        finishRefresh()
        @is_paginating = false
      end
    end
  end

  def reHash(json)
    if @json.nil?
      @json = Hash.new
    end

    for obj in json
      repo = obj[:repository][:full_name]
      @json[repo] ||= begin
        Array.new
      end
      @json[repo].push(obj)
    end
    @json
  end

  def finishRefresh()
    tableView.reloadData()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
  end

  def settingButton
    subView = SettingListViewController.new()
    view = UINavigationController.alloc.initWithRootViewController(subView)
    presentViewController(view, animated:true, completion:nil)
  end

end
