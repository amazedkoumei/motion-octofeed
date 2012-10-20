# -*- coding: utf-8 -*-
class AuthViewController < UITableViewController

  def viewDidLoad
    navigationItem.title = "Account Setting"
    navigationController.navigationBar.tintColor = UIColor.darkGrayColor
    @doneButton ||=begin
      button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"doneButtonTap")
      button
    end
    navigationItem.rightBarButtonItem = @doneButton
  end

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    case section
    when 0
      1
    when 1
      2
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    "Github account"
  end

  def tableView(tableView, titleForFooterInSection:section)
    "blank setting means www.google.com"
  end

  CELLID = "auth"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    case indexPath.section
    when 0
      case indexPath.row
      when 0
        cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
          cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
          cell.selectionStyle = UITableViewCellSelectionStyleNone
          cell.textLabel.text = "Token"
          cell
        end

        @tokenField ||= begin
          textField = UITextField.alloc.initWithFrame(CGRectMake(80, 10, 180, 30));
          textField.delegate = self
          textField.borderStyle = UITextBorderStyleRoundedRect
          textField.keyboardType = UIKeyboardTypeURL
          textField.returnKeyType = UIReturnKeyDone
          textField.clearButtonMode = true
          textField.text = App::Persistence[$USER_DEFAULTS_KEY_0] || ""
          textField
        end
        cell.addSubview(@tokenField);
      end
    when 1
      case indexPath.row
        when 0
          cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
            cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
            cell.selectionStyle = UITableViewCellSelectionStyleNone
            cell.textLabel.text = "Username"
            cell
          end

          @userNameField ||= begin
            textField = UITextField.alloc.initWithFrame(CGRectMake(212, 10, 80, 30));
            textField.delegate = self
            textField.borderStyle = UITextBorderStyleRoundedRect
            textField.keyboardType = UIKeyboardTypeURL
            textField.returnKeyType = UIReturnKeyDone
            textField.text = App::Persistence[$USER_DEFAULTS_KEY_1] || ""
            textField
          end
          cell.addSubview(@userNameField);

        when 1
          cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
            cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
            cell.selectionStyle = UITableViewCellSelectionStyleNone
            cell.textLabel.text = "password"
            cell
          end

          @passwordField ||= begin
            textField = UITextField.alloc.initWithFrame(CGRectMake(212, 10, 80, 30));
            textField.delegate = self
            textField.borderStyle = UITextBorderStyleRoundedRect
            textField.keyboardType = UIKeyboardTypeURL
            textField.returnKeyType = UIReturnKeyDone
            textField.text = App::Persistence[$USER_DEFAULTS_KEY_2] || ""
            textField
          end
          cell.addSubview(@passwordField);
      end
    end
    cell
  end

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder()
    true
  end

  def doneButtonTap
    App::Persistence[$USER_DEFAULTS_KEY_0] = @tokenField.text
    App::Persistence[$USER_DEFAULTS_KEY_1] = @userNameField.text
    App::Persistence[$USER_DEFAULTS_KEY_2] = @passwordField.text
    dismissModalViewControllerAnimated(true)
  end
end
