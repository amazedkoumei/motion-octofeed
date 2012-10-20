# -*- coding: utf-8 -*-
class SettingGithubAccountViewController < UITableViewController

  TEXT_FIELD_RECT = CGRectMake(20, 10, 280, 30)

  def viewDidLoad
    navigationItem.title = "GitHub Account"

    @saveButton = UIBarButtonItem.new.tap do |b|
      b.initWithBarButtonSystemItem(UIBarButtonSystemItemSave, target:self, action:"saveButton")
      navigationItem.rightBarButtonItem = b
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    2
  end

  def tableView(tableView, titleForHeaderInSection:section)
    "Github Account"
  end

  def tableView(tableView, titleForFooterInSection:section)
    "Password will be never saved in app. Just use it for authentication only once."
  end

  CELLID = "auth"
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELLID)
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell
    end

    case indexPath.row
      when 0
        @userNameField ||= begin
          textField = UITextField.alloc.initWithFrame(TEXT_FIELD_RECT);
          textField.delegate = self
          textField.placeholder = "Username"
          textField.borderStyle = UITextBorderStyleNone
          textField.keyboardType = UIKeyboardTypeDefault
          textField.returnKeyType = UIReturnKeyNext
          textField.clearButtonMode = true
          textField.text = App::Persistence[$USER_DEFAULTS_KEY_1] || ""
          textField
        end
        cell.addSubview(@userNameField);

      when 1
        @passwordField ||= begin
          textField = UITextField.alloc.initWithFrame(TEXT_FIELD_RECT);
          textField.delegate = self
          textField.placeholder = "Password"
          textField.borderStyle = UITextBorderStyleNone
          textField.keyboardType = UIKeyboardTypeDefault
          textField.returnKeyType = UIReturnKeyDone
          textField.clearButtonMode = true
          textField.secureTextEntry = true
          textField
        end
        cell.addSubview(@passwordField);
    end
    cell
  end

  def textFieldShouldReturn(textField)
    if textField == @userNameField
      @passwordField.becomeFirstResponder()
    else
      textField.resignFirstResponder()
    end
  end

  def saveButton

    userName = @userNameField.text || ""
    password = @passwordField.text || ""

    if userName.include?("@")
      App.alert("Please set your Username not Email Address.")
      return
    end

    # base64 encoding
    authHeader = "Basic " + [userName + ":" + password].pack("m").chomp

    payload = BW::JSON.generate({
      "scopes" => ["public_repo", "user"],
      "note" => App.name
    })

    BW::HTTP.post('https://api.github.com/authorizations',{headers: {Authorization: authHeader}, payload: payload}) do |response|
      if response.ok?

        json = BW::JSON.parse(response.body.to_str)
        App::Persistence[$USER_DEFAULTS_KEY_GITHUB_API_TOKEN] = json[:token]
        
        @alertView = UIAlertView.new.tap do |v|
          v.initWithTitle(nil, message:"Authenticated", delegate:self, cancelButtonTitle:nil, otherButtonTitles:"OK", nil)
          v.show()
        end

      else
        App.alert("Auth Failed")
      end
    end
  end

  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    navigationController.popViewControllerAnimated(true)
  end

end
