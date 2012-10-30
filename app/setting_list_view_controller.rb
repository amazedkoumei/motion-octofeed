# -*- coding: utf-8 -*-
class SettingListViewController < UITableViewController

  attr_accessor :moveTo, :mainTableViewContoroller

  # FIXME: How to write Ruby's Constant
  def MOVE_TO_SETTING_GITHUB_FEED
    0
  end
  
  # FIXME: How to write Ruby's Constant
  def MOVE_TO_SETTING_GITHUB_ACCOUNT 
    1
  end

  def viewDidLoad()
    super

    view.dataSource = view.delegate = self
    navigationItem.title = "Setting"
    navigationController.navigationBar.tintColor = $NAVIGATIONBAR_COLOR

    @doneButton = UIBarButtonItem.new.tap do |b|
      b.initWithTitle("done", style:UIBarButtonItemStylePlain, target:self, action:"doneButton")
      navigationItem.rightBarButtonItem = b
    end
  end

  def viewDidAppear(animated)
    super
    
    @moveTo = moveTo
    if !@moveTo.nil?
      tableView(tableView, didSelectRowAtIndexPath:NSIndexPath.indexPathForRow(@moveTo, inSection:0))
      @moveTo = nil
    end
  end

  def numberOfSectionsInTableView(tableView)
    sectionCount = 1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    menus.count
  end

  CELLID = "menus"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
      cell
    end

    cell.selectionStyle = UITableViewCellSelectionStyleBlue
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.textLabel.text = menus[indexPath.row]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if(indexPath.row < menus.count)
      case indexPath.row
        when 0
          @detail_controller = SettingGithubAccountViewController.new.tap do |v|
            v.initWithStyle(UITableViewStyleGrouped)
          end
        else
      end
    end
    navigationController.pushViewController(@detail_controller, animated:true)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end

  def menus
    @menus = [
      "Github Account"
    ]
  end

  def doneButton
    mainTableViewContoroller.fetchFeed()
    dismissViewControllerAnimated(true, completion:nil)
  end
end
