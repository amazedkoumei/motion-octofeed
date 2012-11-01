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

    @informView = InformView.new.tap do |v|
      navigationController.view.addSubview(v)
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

    @informView.message = "user authenticated."
    @informView.setNeedsDisplay()
    @informView.showWithAnimation(true)

    @saveButton.enabled = false
    navigationItem.hidesBackButton = true

    App::Persistence[$USER_DEFAULTS_KEY_USERNAME] = @userName
    # base64 encoding
    authHeader = "Basic " + [@userName + ":" + @password].pack("m").chomp

    payload = BW::JSON.generate({
      "scopes" => ["public_repo", "user"],
      "note" => App.name
    })

    BW::HTTP.post('https://api.github.com/authorizations',{headers: {Authorization: authHeader}, payload: payload}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        App::Persistence[$USER_DEFAULTS_KEY_API_TOKEN] = json[:token]
        getAndSaveFeedToken()
      else
        App.alert("Auth Failed")
        @informView.hideWithAnimation(true)
        @saveButton.enabled = true
        navigationItem.hidesBackButton = false
      end
    end
  end

  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    navigationController.popViewControllerAnimated(true)
  end

  def getAndSaveFeedToken()
    @informView.message = "getting feed token."
    @informView.setNeedsDisplay()
    @webview = UIWebView.new.tap do |v|
      v.loadRequest(NSURLRequest.requestWithURL(NSURL.URLWithString("https://github.com/login")))
      v.delegate = self
    end
  end

  def webViewDidFinishLoad(webView)
    path = webView.request.URL.path
    if path == "/login"
      webView.stringByEvaluatingJavaScriptFromString("$('#login_field').val('#{@userName}');$('#password').val('#{@password}');$('#login_field')[0].form.submit()")
    elsif path == "/"
      token = webView.stringByEvaluatingJavaScriptFromString("$('a.feed')[0].href.match(/token=(.*)/)[1]")
      App::Persistence[$USER_DEFAULTS_KEY_FEED_TOKEN] = token
      @informView.hideWithAnimation(true)
      @alertView = UIAlertView.new.tap do |v|
        v.initWithTitle(nil, message:"Authenticated", delegate:self, cancelButtonTitle:nil, otherButtonTitles:"OK", nil)
        v.show()
      end
      @saveButton.enabled = true
    end      
  end

end
