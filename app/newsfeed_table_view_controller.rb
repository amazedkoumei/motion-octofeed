# -*- coding: utf-8 -*-
class NewsfeedTableViewController < UITableViewController
  
  def viewDidLoad()
    super
    
    navigationItem.title = "News Feed"

    @footerView = AMP::LoadingTableFooterView.new.tap do |v|
      v.frame = [[0, 0], [tableView.frame.size.width, 44]]
      self.tableView.tableFooterView = v
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
    if(@dataSource.nil?)
      refresh()
    end
  end

  def numberOfSectionsInTableView(tableView)
    unless @dataSource.nil?
      @dataSource.size
    else
      0
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    unless @dataSource.nil?
      key = @dataSource.keys[section]
      @dataSource[key].length
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    key = @dataSource.keys[indexPath.section]
    data = @dataSource[key][indexPath.row]

    cellId = data[:id]
    cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
      
      data = data.merge(@manager.api.feed_info(data))
      @dataSource[key][indexPath.row] = data
      
      cell = NewsfeedTableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.dataSource = data
      end
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    UINavigationController.new.tap do |n|
      @webView = WebViewController.new.tap do |v|
        key = @dataSource.keys[indexPath.section]
        v.url_string = @dataSource[key][indexPath.row][:url]
        v.hidesBottomBarWhenPushed = true
      end
      n.initWithRootViewController(@webView)
      n.modalTransitionStyle = UIModalTransitionStyleCrossDissolve
      presentViewController(n, animated:true, completion:nil)
      tableView.deselectRowAtIndexPath(indexPath, animated:false)
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    NewsfeedTableViewCell.contentHeight("")
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if(!@dataSource.nil?)
      @dataSource.keys[section]
    end
  end

  def scrollViewDidScroll(scrollView)
    bottomPoint = CGPointMake(
      160, 
      self.view.bounds.size.height + scrollView.contentOffset.y
    )
    index_path = tableView.indexPathForRowAtPoint(bottomPoint)
    unless index_path.nil?
      if index_path.section == @dataSource.size - 1
        key = @dataSource.keys[index_path.section]
        if index_path.row == @dataSource[key].size - 1
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
    @manager.api.getFeeds(payload) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body)
        #p json
        @json = reHash(json)
        @footerView.stopAnimating()
        finishRefresh()
        @is_paginating = false
      else
        p "response error"
      end
    end
  end

  def refresh()
    payload = {}
    @manager.api.getFeeds(payload) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body)
        #p json
        @json = reHash(json)
        finishRefresh()
      end
    end
  end

  def reHash(json)
    if @dataSource.nil?
      @dataSource = Hash.new
    end
    json.each do |item|
      inputFormatter ||=begin
        f = NSDateFormatter.new
        f.setTimeZone(NSTimeZone.timeZoneWithAbbreviation("GMT"))
        f.setDateFormat("YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'")
      end
      outputDateFormatter ||=begin
        f = NSDateFormatter.new
        f.setLocale(NSLocale.systemLocale)
        f.setTimeZone(NSTimeZone.systemTimeZone)
        f.setDateFormat("YYYY-MM-dd")
      end
      outputTimeFormatter ||=begin
        f = NSDateFormatter.new
        f.setLocale(NSLocale.systemLocale)
        f.setTimeZone(NSTimeZone.systemTimeZone)
        f.setDateFormat("HH:mm:ss")
      end
      
      nsDate = inputFormatter.dateFromString(item[:created_at])
      date = outputDateFormatter.stringFromDate(nsDate)
      time = outputTimeFormatter.stringFromDate(nsDate)

      feed = item.to_hash()
      feed[:date] = date
      feed[:time] = time
      
      @dataSource[date] ||= begin
        Array.new
      end
      @dataSource[date].push(feed)
    end

    finishRefresh()
    tableView.reloadData()
  end

  def finishRefresh()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
  end

end
