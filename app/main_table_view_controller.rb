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
      r.addTarget(self, action:"fetchFeed", forControlEvents:UIControlEventValueChanged)
      self.refreshControl = r
    end

    @informView = InformView.new.tap do |v|
      v.message = "loading.."
      navigationController.view.addSubview(v)
    end

    if(!hasFeedAuthInfo?)
      showGithubFeedViewController()
    else
      fetchFeed()
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

  CELLID = "feed"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    key = @parsedHash.keys[indexPath.section]
    feed = @parsedHash[key][indexPath.row]

    cellId = feed[:title] + feed[:updated]
    cell = tableView.dequeueReusableCellWithIdentifier(cellId) || begin
      cell = MainTableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellId)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        c.feed = feed
      end
      cell
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    view = DetailViewController.new.tap do |v|
      v.initWithStyle(UITableViewStyleGrouped)
      key = @parsedHash.keys[indexPath.section]
      v.item = @parsedHash[key][indexPath.row]
    end
    navigationController.pushViewController(view, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    80
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if(!@parsedHash.nil?)
      @parsedHash.keys[section]
    end
  end

  def fetchFeed()
    begin
      @informView.showWithAnimation(false)

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
      finishFetch()
      App.alert(e)
    end
  end

  def finishFetch()
    if @refreshControl.isRefreshing == true
      @refreshControl.endRefreshing()
    end
    @informView.hideWithAnimation(true)
  end

  # BW::RSSParser delegate
  def when_parser_is_done
    finishFetch()
    @parsedHash = @parsingHash.clone
    view.reloadData
  end

  # BW::RSSParser delegate
  def when_parser_errors
    finishFetch()
    App.alert($BAD_INTERNET_ACCESS_MESSAGE)
  end

  def hasFeedAuthInfo?
    token = App::Persistence[$USER_DEFAULTS_KEY_FEED_TOKEN] || ""
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
