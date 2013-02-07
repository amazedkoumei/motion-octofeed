# -*- coding: utf-8 -*-
class IssueDetailTableViewController < UITableViewController
  
  attr_accessor :manager, :issue

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "#{@manager.repo}/issues"

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
    2
  end

  def tableView(tableView, titleForHeaderInSection:section)
    case section
    when 0
      "Issue"
    when 1
      "Comments"
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
    when 0
      1
    when 1
      if(!@json.nil?)
        @json.length
      else
        0
      end
    end
  end

  CELLID = "feed"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    case indexPath.section
    when 0
      cellId = @issue[:id].to_s + @issue[:updated_at]
      cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
        cell = IssueDetailTableViewCell.new.tap do |c|
          c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
          c.selectionStyle = UITableViewCellSelectionStyleBlue
          c.userInteractionEnabled = false
          c.issue = @issue
        end
        cell
      end
    when 1
      cellId = @json[indexPath.row][:id].to_s + @json[indexPath.row][:updated_at]
      cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
        cell = IssueDetailCommentTableViewCell.new.tap do |c|
          c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
          c.selectionStyle = UITableViewCellSelectionStyleBlue
          c.userInteractionEnabled = false
          c.comment = @json[indexPath.row]
        end
        cell
      end
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    # do nothing
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    case indexPath.section
    when 0
      cell_content_width = 250
      cell_content_margin = 50 + 10
      text = @issue[:body]
      constraint = CGSizeMake(cell_content_width, 20000);   
      size = text.sizeWithFont(UIFont.systemFontOfSize(14), constrainedToSize:constraint, lineBreakMode:NSLineBreakByWordWrapping)
      height = [size.height, 80].max
      height + cell_content_margin
    when 1
      cell_content_width = 250
      cell_content_margin = 50 + 10
      text = @json[indexPath.row][:body]
      constraint = CGSizeMake(cell_content_width, 20000);   
      size = text.sizeWithFont(UIFont.systemFontOfSize(14), constrainedToSize:constraint, lineBreakMode:NSLineBreakByWordWrapping)
      height = [size.height, 80].max
      height + cell_content_margin
    end
  end

  def fetchFeed()
    begin
      AMP::InformView.show("loading..", target:navigationController.view, animated:true)

      @manager.api.getRepositoryIssueComment(@manager.owner, @manager.repo, @issue[:number]) do |response|
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
end
