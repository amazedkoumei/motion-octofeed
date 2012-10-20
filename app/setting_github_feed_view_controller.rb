# -*- coding: utf-8 -*-
class SettingGithubFeedViewController < UITableViewController

  TEXT_FIELD_RECT = CGRectMake(20, 10, 280, 30)

  def viewDidLoad
    navigationItem.title = "Feed Setting"

    @saveButton = UIBarButtonItem.new.tap do |b|
      b.initWithBarButtonSystemItem(UIBarButtonSystemItemSave, target:self, action:"saveButton")
      navigationItem.rightBarButtonItem = b
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    1
  end

  def tableView(tableView, titleForHeaderInSection:section)
    "Github Feed URL"
  end

=begin
  def tableView(tableView, titleForFooterInSection:section)
    "What's Github Feed?"
  end
=end
  def tableView(tableView, viewForFooterInSection:section)
    @footerLabel = UILabel.new.tap do |l|
      l.backgroundColor = UIColor.clearColor
      l.textAlignment = UITextAlignmentCenter
      l.textColor = UIColor.blueColor
      l.font = UIFont.italicSystemFontOfSize(14)
      l.shadowColor = UIColor.whiteColor
      l.shadowOffset = CGSizeMake(0, 1);
      l.text = "What's Github Feed?"
      l.whenTapped do
        navigationController.pushViewController(WhatGithubFeedViewController.new, animated:true)
      end
    end
    @footerLabel
  end
  
  def tableView(tableView, heightForFooterInSection:section)
    40
  end

  CELLID = "feed"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell
    end

    @feedUrlField ||= begin
      textField = UITextField.alloc.initWithFrame(TEXT_FIELD_RECT);
      textField.delegate = self
      textField.placeholder = "Github Feed URL"
      textField.borderStyle = UITextBorderStyleNone
      textField.keyboardType = UIKeyboardTypeURL
      textField.returnKeyType = UIReturnKeyDone
      textField.clearButtonMode = true
      textField.text = App::Persistence[$USER_DEFAULTS_KEY_GITHUB_FEED_URL] || ""
      textField
    end
    cell.addSubview(@feedUrlField);
    cell
  end

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder()
    true
  end

  def saveButton
    # input > https://github.com/[:userName].private.atom?token=[:token]
    /.+?github\.com\/(.+?)\.private\.atom\?token=([^&]*)/ =~ @feedUrlField.text
    userName = $1
    token = $2

    if(userName.nil? || token.nil?)
      App.alert("Invalid URL")
    else
      App::Persistence[$USER_DEFAULTS_KEY_GITHUB_FEED_URL] = @feedUrlField.text
      App::Persistence[$USER_DEFAULTS_KEY_0] = token
      App::Persistence[$USER_DEFAULTS_KEY_1] = userName
      @alertView = UIAlertView.new.tap do |v|
        v.initWithTitle(nil, message:"Saved", delegate:self, cancelButtonTitle:nil, otherButtonTitles:"OK", nil)
        v.show()
      end
    end
  end

  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    navigationController.popViewControllerAnimated(true)
  end

end
