# -*- coding: utf-8 -*-
class DetailViewController < UITableViewController

  attr_accessor :item, :isHaveToRefresh
  
  def viewDidLoad()
    super

    @url = item[:link]

    navigationItem.title = @url

    @github = Github.new(NSURL.URLWithString(@url))
    @github.fetchGithubStatus do
      if @github.isGithubRepository?
        @actionItem.enabled = true
      end
    end
    navigationItem.title = "#{@github.userName}/#{@github.repositoryName}"


    @toolbarItems = Array.new.tap do |a|
      @actionItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target:self, action:'actionButton')
      @actionItem.enabled = false
      @flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
      if !@github.isGithubRepository?
        @actionItem.enabled = false
      end

      a<<@flexibleSpace
      a<<@actionItem

      self.toolbarItems = a
    end

    @profileViewController = FeatureProfileViewController.new.tap do |v|
      v.url = "https://" + @github.host + "/" + @github.userName
      v.navTitle = "#{@github.userName}"
      v.hideDoneButton = true
      v.parseBeforeDidLoad()
    end

    @readmeViewController = FeatureReadmeViewController.new.tap do |v|
      v.url = "https://" + @github.host + "/" + @github.userName + "/" + @github.repositoryName
      v.navTitle = "#{@github.userName}/#{@github.repositoryName}"
      v.hideDoneButton = true
      v.parseBeforeDidLoad()
    end
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(false, animated:true)
  end

  def viewDidAppear(animated)
    super
    
    @github.fetchGithubStatus do
      if @github.isGithubRepository?
        @actionItem.enabled = true
      end
    end
  end

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
      when 0
        0
      when 1
        2
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    case section
      when 0
        "URL"
      when 1
        "info"
    end
  end

  def tableView(tableView, viewForFooterInSection:section)
    if section == 0
      view = UIView.new.tap do |v|
        label = UILabel.new.tap do |l|
          l.frame = CGRectMake(20, 0, 280, 10)
          l.backgroundColor = UIColor.clearColor
          l.textAlignment = UITextAlignmentLeft
          l.textColor = UIColor.blueColor
          l.lineBreakMode = UILineBreakModeCharacterWrap
          l.numberOfLines = 0
          l.font = UIFont.boldSystemFontOfSize(16)
          l.shadowColor = UIColor.whiteColor
          l.shadowOffset = CGSizeMake(0, 1);
          l.text = @url
          l.when_tapped do
            view = WebViewController.new.tap do |v|
              v.item = @item
              navigationController.pushViewController(v, animated:true)
            end
          end
          l.sizeToFit()
        end
        v.addSubview(label)
      end
    end
  end

  def tableView(tableView, heightForFooterInSection:section)
    if section == 0
      70
    else
      # default height
      -1
    end
  end

  CELLID = "detailmenu"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.new.tap do |c|
        c.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:CELLID)
        c.selectionStyle = UITableViewCellSelectionStyleBlue
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end
    end

    case indexPath.section
      when 1
        # info section
        case indexPath.row
          when 0
            cell.textLabel.text = "Owner"
            if @github.isGithubRepositoryOrUser?
              cell.detailTextLabel.text = @userName
            else
              cell.textColor = UIColor.grayColor
              cell.accessoryType = UITableViewCellAccessoryNone
              cell.userInteractionEnabled = false
            end
          when 1
            cell.textLabel.text = "README"
            if @github.isGithubRepository?
              cell.detailTextLabel.text = @repositoryName
            else
              cell.textColor = UIColor.grayColor
              cell.accessoryType = UITableViewCellAccessoryNone
              cell.userInteractionEnabled = false
            end
        end
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    case indexPath.section
      when 1
        # info section
        case indexPath.row
          when 0
            view = @profileViewController
          when 1
            view = @readmeViewController
        end
        navigationController.pushViewController(view, animated:true)
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
    end
  end

  def actionButton
    activityItems = [NSURL.URLWithString(@url), navigationController.topViewController];

    includeActivities = Array.new.tap do |arr|
      if @github.isGithubRepository?
        if @github.isStarredRepository?
          arr<<ActivityGithubAPI_StarDelete.new
        else
          arr<<ActivityGithubAPI_StarPut.new
        end

        if @github.isWatchingRepository?
          arr<<ActivityGithubAPI_WatchDelete.new
        else
          arr<<ActivityGithubAPI_WatchPut.new
        end
      end

      if @github.isGithubRepositoryOrUser?
        if @github.isFollowingUser?
          arr<<ActivityGithubAPI_FollowDelete.new
        else
          arr<<ActivityGithubAPI_FollowPut.new
        end
      end
    end

    excludeActivities = [
      UIActivityTypePostToFacebook,
      UIActivityTypePostToTwitter,
      UIActivityTypePostToWeibo,
      UIActivityTypeMessage,
      UIActivityTypeMail,
      UIActivityTypePrint,
      UIActivityTypeCopyToPasteboard,
      UIActivityTypeAssignToContact,
      UIActivityTypeSaveToCameraRoll
    ]

    @activityController = UIActivityViewController.alloc.initWithActivityItems(activityItems, applicationActivities:includeActivities)
    @activityController.excludedActivityTypes = excludeActivities

    presentViewController(@activityController, animated:true, completion:nil)
  end

  def completePerformActivity()
    @actionItem.enabled = false
    @github.fetchGithubStatus do
      if @github.isGithubRepository?
        @actionItem.enabled = true
      end
    end
  end
end
