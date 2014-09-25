# -*- coding: utf-8 -*-
class SettingListViewController < UITableViewController

  attr_accessor :moveTo

  # FIXME: How to write Ruby's Constant
  def MOVE_TO_SETTING_GITHUB_FEED
    0
  end
  
  # FIXME: How to write Ruby's Constant
  def MOVE_TO_SETTING_GITHUB_ACCOUNT 
    0
  end

  def viewDidLoad()
    super
    
    view.dataSource = view.delegate = self
    navigationItem.title = "Index"
  end

  def viewWillAppear(animated)
    @logged_in = self.is_logged_in()
    tableView.reloadData()
  end

  def viewDidAppear(animated)
    super
    self.navigationItem.backBarButtonItem = BW::UIBarButtonItem.styled(:plain, "")
    @moveTo = moveTo
    if !@moveTo.nil?
      tableView(tableView, didSelectRowAtIndexPath:NSIndexPath.indexPathForRow(@moveTo, inSection:0))
      @moveTo = nil
    end
  end

  def numberOfSectionsInTableView(tableView)
    sectionCount = 2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
    when 0
      settings.count
    when 1
      menus.count
    else
      0
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    case section
    when 0
      "Setting"
    when 1
      "Menu"
    else
      ""
    end
  end

  CELLID = "menus"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
      cell
    end

    cell.selectionStyle = UITableViewCellSelectionStyleBlue
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    case indexPath.section
    when 0
      cell.textLabel.text = settings[indexPath.row]
    when 1
      cell.textLabel.text = menus[indexPath.row]
      if @logged_in == true
        self.cell_enable(cell)
      else
        self.cell_disable(cell)
      end
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if(indexPath.row < menus.count)
      case indexPath.section
      when 0
        case indexPath.row
        when 0
          if @logged_in == true
            @detail_controller = SettingSignoutViewController.new
          else
            @detail_controller = SettingGithubAccountViewController.new
          end
        end
      when 1
        case indexPath.row
        when 0
          @detail_controller = NewsfeedTableViewController.new.tap do |v|
          end
        when 1
          @detail_controller = NotificationTableViewController.new.tap do |v|
          end
        else
        end
      end
    end

    navigationController.pushViewController(@detail_controller, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end

  def is_logged_in()
    cookieJar = NSHTTPCookieStorage.sharedHTTPCookieStorage
    url = NSURL.URLWithString("https://github.com")

    logged_in = false
    cookieJar.cookiesForURL(url).each do |cookie|
      if cookie.name == "logged_in" && cookie.value == "yes"
        logged_in = true
        break
      end
    end

    @manager = GithubManager.new(nil, self)

    logged_in && !@manager.authToken.nil?
  end

  def cell_disable(cell)
    cell.userInteractionEnabled = false
    cell.textLabel.enabled = false
  end

  def cell_enable(cell)
    cell.userInteractionEnabled = true
    cell.textLabel.enabled = true
  end

  def settings
    if @logged_in == true
      @settings = [
        "Sign out"      
      ]
    else
      @settings = [
        "Sign in"      
      ]
    end      
  end

  def menus
    @menus = [
      "News Feed",
      "Notification"
    ]
  end

end
