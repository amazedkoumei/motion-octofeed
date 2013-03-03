# -*- coding: utf-8 -*-
class NotificationTableViewController < UITableViewController
  
  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self

    navigationItem.title = App.name
    navigationController.navigationBar.tintColor = $NAVIGATIONBAR_COLOR

    @settingButton = UIBarButtonItem.new.tap do |b|
      b.initWithTitle("setting", style:UIBarButtonItemStylePlain, target:self, action:"settingButton")
      navigationItem.rightBarButtonItem = b
    end

    @manager = GithubManager.new(nil, self)

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"refresh", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(true, animated:false)
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
    
    AMP::InformView.show("loading..", target:navigationController.view, animated:true)

    key = @json.keys[indexPath.section]
    notification = @json[key][indexPath.row]

    @manager.api.patchNotifications(notification[:id]) do |ret|
      notification[:unread] = false if ret
    end

    @manager.api.request(@json[key][indexPath.row][:subject][:url]) do |response, query|
      json = BW::JSON.parse(response.body)
      @detailView = DetailViewController.new.tap do |v|
        v.initWithStyle(UITableViewStyleGrouped)
        v.url_string = json[:html_url]
        v.hidesBottomBarWhenPushed = true
      end
      AMP::InformView.hide(true)
      navigationController.pushViewController(@detailView, animated:true)
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
      AMP::InformView.show("loading..", target:navigationController.view, animated:true)
      payload = {
        per_page: 100
      }
      @manager.api.getNotifications(payload) do |response|
        if response.ok?
          @json = BW::JSON.parse(response.body)
          @json = reHash(@json)
          finishRefresh()
        end
      end
    rescue => e
      finishRefresh()
      App.alert(e)
    end
  end

  def reHash(json)
    Hash.new.tap do |hash|
      for obj in json
        repo = obj[:repository][:full_name]
        hash[repo] ||= begin
          Array.new
        end
        hash[repo].push(obj)
      end
    end
  end

  def finishRefresh()
    tableView.reloadData()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
    AMP::InformView.hide(true)
  end

  def settingButton
    subView = SettingListViewController.new()
    view = UINavigationController.alloc.initWithRootViewController(subView)
    presentViewController(view, animated:true, completion:nil)
  end

end
