# -*- coding: utf-8 -*-
class SettingGithubAccountViewController < UITableViewController

  TEXT_FIELD_RECT = CGRectMake(20, 10, 280, 30)

  def viewDidLoad()
    super
    
    navigationItem.title = "GitHub Account"

    @saveButton = UIBarButtonItem.new.tap do |b|
      b.initWithTitle("save", style:UIBarButtonItemStylePlain, target:self, action:"saveButton")
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
          textField.text = App::Persistence[$USER_DEFAULTS_KEY_USERNAME] || ""
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
    
    @userName = @userNameField.text || ""
    @password = @passwordField.text || ""

    if @userName.include?("@")
      App.alert("Please set your Username not Email Address.")
      @saveButton.enabled = true
      return
    end

    AMP::InformView.show("user authenticated.", target:navigationController.view, animated:true)

    @saveButton.enabled = false
    navigationItem.hidesBackButton = true

    App::Persistence[$USER_DEFAULTS_KEY_USERNAME] = @userName

    #@githubAPI = AMP::GithubAPI.new()
    payload = {
      scopes: ["public_repo", "user", "repo", "notifications"],
      note: App.name, 
      note_url: "http://amazedkoumei.github.com/motion-octofeed/"
    }

    # FIXME: I'd like to use tap but I can't
    @githubAPI = AMP::GithubAPI.instance()
    @githubAPI.createAuthorization(@userName, @password, payload) do |error|
      if error.nil?
        # set auth token
        App::Persistence[AMP::GithubAPI::USER_DEFAULT_AUTHTOKEN] = @githubAPI.authToken
        
        AMP::InformView.hide(true)
        AMP::InformView.show("getting feed token.", target:navigationController.view, animated:true)

        @githubAPI.fetchNewsFeedToken() do
          # set news feed token
          App::Persistence[$USER_DEFAULTS_KEY_FEED_TOKEN] = @githubAPI.newsFeedToken

          AMP::InformView.hide(true)

          @alertView = UIAlertView.new.tap do |v|
            v.initWithTitle(nil, message:"Authenticated", delegate:self, cancelButtonTitle:nil, otherButtonTitles:"OK", nil)
            v.show()
          end

          @saveButton.enabled = true
        end
      else
        App.alert("Auth Failed")
        AMP::InformView.hide(true)
        @saveButton.enabled = true
        navigationItem.hidesBackButton = false
      end
    end
  end

  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    navigationController.popViewControllerAnimated(true)
  end

end
