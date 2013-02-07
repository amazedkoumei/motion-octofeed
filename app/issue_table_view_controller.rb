# -*- coding: utf-8 -*-
class IssueTableViewController < UITableViewController
  
  attr_accessor :manager

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "#{@manager.repo}/issues"

=begin
    @settingButton = UIBarButtonItem.new.tap do |b|
      b.initWithTitle("setting", style:UIBarButtonItemStylePlain, target:self, action:"settingButton")
      navigationItem.rightBarButtonItem = b
    end
=end
    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"fetchFeed", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end

    if(!hasFeedAuthInfo?)
      showGithubFeedViewController()
    else
      fetchFeed()
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(true, animated:false)
  end

  def viewDidDisappear(animated)
    AMP::InformView.hide(false)
  end

  def numberOfSectionsInTableView(tableView)
    if(!@json.nil?)
      #@json.size
      #p @json.size
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

  def fetchFeed()
    begin
      #@informView.showWithAnimation(false)
      AMP::InformView.show("loading..", target:navigationController.view, animated:true)

      @manager.api.getRepositoryIssueList(@manager.owner, @manager.repo) do |response|
        if response.ok?
          @json = BW::JSON.parse(response.body)

          finishFetch()
        end
      end
    rescue => e
      finishFetch()
      App.alert(e)
    end
  end

  def finishFetch()
    view.reloadData
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
    #@informView.hideWithAnimation(true)
    AMP::InformView.hide(true)
  end

  def hasFeedAuthInfo?
    token = App::Persistence[AMP::GithubAPI::USER_DEFAULT_AUTHTOKEN] || ""
    username = App::Persistence[$USER_DEFAULTS_KEY_USERNAME] || ""

    (!token.empty? && !username.empty?)
  end

  def showGithubFeedViewController()
    subView = SettingListViewController.new.tap do |v|
      v.moveTo = v.MOVE_TO_SETTING_GITHUB_FEED
      v.mainTableViewContoroller = self
    end
    view = UINavigationController.alloc.initWithRootViewController(subView)
    presentViewController(view, animated:true, completion:nil)
  end

  def settingButton
    subView = SettingListViewController.new.tap do |v|
      v.mainTableViewContoroller = self
    end
    view = UINavigationController.alloc.initWithRootViewController(subView)
    presentViewController(view, animated:true, completion:nil)
  end
end
