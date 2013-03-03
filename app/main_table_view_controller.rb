# -*- coding: utf-8 -*-
class MainTableViewController < UITableViewController
  
  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = App.name
    navigationController.navigationBar.tintColor = $NAVIGATIONBAR_COLOR

    @settingButton = UIBarButtonItem.new.tap do |b|
      b.initWithTitle("setting", style:UIBarButtonItemStylePlain, target:self, action:"settingButton")
      navigationItem.rightBarButtonItem = b
    end

    @refreshControl = UIRefreshControl.new.tap do |r|
      r.attributedTitle = NSAttributedString.alloc.initWithString("now refreshing...")
      r.addTarget(self, action:"refresh", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end

    if(!hasFeedAuthInfo?)
      GithubManager.showAccountSettingViewController(self)
    end
  end

  def viewWillAppear(animated)
    super
    tabBarController.tabBar.setHidden(false)
    navigationController.setToolbarHidden(true, animated:false)
    if(@parsedHash.nil?)
      refresh()
    end
  end

  def numberOfSectionsInTableView(tableView)
    if(!@parsedHash.nil?)
      @parsedHash.size
    else
      0
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if(!@parsedHash.nil?)
      key = @parsedHash.keys[section]
      @parsedHash[key].length
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    key = @parsedHash.keys[indexPath.section]
    feed = @parsedHash[key][indexPath.row]

    cellId = feed[:title] + feed[:updated]
    cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
      cell = MainTableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        c.dataSource = feed
      end
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    # App will crash if @detailView release before "@github.fetchGithubStatus" callend in DetailViewController have not finished
    @detailViewStack ||= []
    if @detailViewStack.size < 5
      @detailViewStack << @detailView
    else
      @detailViewStack = []
      @detailViewStack << @detailView
    end

    @detailView = DetailViewController.new.tap do |v|
      v.initWithStyle(UITableViewStyleGrouped)
      key = @parsedHash.keys[indexPath.section]
      v.url_string = @parsedHash[key][indexPath.row][:link]
    end
    tabBarController.tabBar.setHidden(true)
    navigationController.pushViewController(@detailView, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    key = @parsedHash.keys[indexPath.section]
    feed = @parsedHash[key][indexPath.row]
    MainTableViewCell.contentHeight(feed[:title])
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if(!@parsedHash.nil?)
      @parsedHash.keys[section]
    end
  end

  def refresh()
    begin
      AMP::InformView.show("loading..", target:navigationController.view, animated:true)

      token = App::Persistence[$USER_DEFAULTS_KEY_FEED_TOKEN] || ""
      username = App::Persistence[$USER_DEFAULTS_KEY_USERNAME] || ""

      @url = NSURL.alloc.initWithString("https://github.com/" + username + ".private.atom?token=" + token)
      @feed_parser = BW::RSSParserForGithub.new(@url)
      @feed_parser.delegate = self


      @parsingHash = Hash.new.tap do |hash|
        @feed_parser.parse do |item|
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
          nsDate = inputFormatter.dateFromString(item.updated)
          date = outputDateFormatter.stringFromDate(nsDate)
          time = outputTimeFormatter.stringFromDate(nsDate)

          feed = item.to_hash()
          feed[:date] = date
          feed[:time] = time
          
          # url > https://secure.gravatar.com/avatar/[:fileName]?s=30&;d=[:original image url]
          /.+?\/avatar\/(.+?)\?s=30.*/ =~ feed[:thumbnail]
          fileName = $1 + ".png"
          fileManager = NSFileManager.defaultManager()
          filePath = "#{App.documents_path}/#{fileName}"
          if !fileManager.fileExistsAtPath(filePath)
            Dispatch::Queue.concurrent.async{
              thumbnailData = NSData.dataWithContentsOfURL(NSURL.URLWithString(feed[:thumbnail]))
              thumbnailData.writeToFile(filePath, atomically:false)
            }
          end


          hash[date] ||= begin
            Array.new
          end
          hash[date].push(feed)
        end
      end
    rescue => e
      finishRefresh()
      App.alert(e)
    end
  end

  def finishRefresh()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
    AMP::InformView.hide(true)
  end

  # BW::RSSParser delegate
  def when_parser_is_done
    finishRefresh()
    @parsedHash = @parsingHash.clone
    view.reloadData
  end

  # BW::RSSParser delegate
  def when_parser_errors
    finishRefresh()
    GithubManager.showAccountSettingViewController(self)
  end

  def hasFeedAuthInfo?
    token = App::Persistence[AMP::GithubAPI::USER_DEFAULT_AUTHTOKEN] || ""
    username = App::Persistence[$USER_DEFAULTS_KEY_USERNAME] || ""

    (!token.empty? && !username.empty?)
  end

  def settingButton
    subView = SettingListViewController.new()
    view = UINavigationController.alloc.initWithRootViewController(subView)
    presentViewController(view, animated:true, completion:nil)
  end
end
