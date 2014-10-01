# -*- coding: utf-8 -*-
class IssueDetailTableViewController < UITableViewController
  
  attr_accessor :manager, :issue

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "issue##{@issue[:number]}"

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"refresh", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(true, animated:false)
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

    width = self.tableView.frame.size.width
    height = self.tableView(tableView, heightForRowAtIndexPath:indexPath)

    case indexPath.section
    when 0
      cellId = @issue[:id].to_s + @issue[:updated_at]
      cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
        cell = IssueDetailTableViewCell.new.tap do |c|
          c.frame = [[0, 0], [width, height]]
          c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
          c.selectionStyle = UITableViewCellSelectionStyleBlue
          c.userInteractionEnabled = false
          c.dataSource = @issue
        end
        cell
      end
    when 1
      cellId = @json[indexPath.row][:id].to_s + @json[indexPath.row][:updated_at]
      cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
        cell = IssueDetailCommentTableViewCell.new.tap do |c|
          c.frame = [[0, 0], [width, height]]
          c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
          c.selectionStyle = UITableViewCellSelectionStyleBlue
          c.userInteractionEnabled = false
          c.dataSource = @json[indexPath.row]
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

  def refresh()
    begin
      @manager.api.getRepositoryIssueComment(@manager.owner, @manager.repo, @issue[:number], {per_page: 100}) do |response|
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
    tableView.reloadData()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
  end

end
