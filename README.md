motion-octofeed
===============

概要 / Overview
----------
### ja
[Rubymotion](http://www.rubymotion.com/)製のGithub news feed リーダーアプリです。

### en
This is ios app for reading Github news feed written in [Rubymotion](http://www.rubymotion.com/).


機能 / Feature
----------
### ja
- Github news feed のリスト表示
- ワンタップで starの追加/削除, watchの開始/終了, followの開始/終了 を実行
- readme, リポジトリオーナーのProfileを見やすく表示

### en
- make a list github news feed
- just one tap to add/remove star, watch/unwatch, follow/unfollow
- readable view of readme and repository owner's profile



インストール / Install
----------
### ja
1. [BubbleWrap](https://github.com/rubymotion/BubbleWrap) をインストールしてください。 (*1 参照)
2. ルートディレクトリにRakefileを追加してください。 (*2 参照)
3. ビルドを実行してください。ビルド手順についてはrubymotion.jpの[Welcome to RubyMotion](http://rubymotion.jp/RubyMotionDocumentation/guides/getting-started/index.html)をご覧ください。

    
### en
1. Install [BubbleWrap](https://github.com/rubymotion/BubbleWrap) (watch *1 bellow)
2. Add "Rakefile" to root directory. (watch *2 bellow)
3. do build. if you'd like to know how to build, watch [Welcome to RubyMotion](http://www.rubymotion.com/developer-center/guides/getting-started/) on rubymotion.com


#### *1 Install BubbleWrap
    gem install bubble-wrap


#### *2 Rakefile
	# -*- coding: utf-8 -*-
	$:.unshift("/Library/RubyMotion/lib")
	require 'motion/project'

	require 'bubble-wrap'
	require 'bubble-wrap/all'

	version = '1.0'
	Motion::Project::App.setup do |app|
  		# Use `rake config' to see complete project settings.
  		app.name = "Octofeed"
  		app.version = version
  		app.frameworks<<"MessageUI"
  		app.sdk_version = "6.0"
  		app.deployment_target = "6.0"
  		app.device_family = [:iphone]
  		app.interface_orientations = [:portrait]
  		app.icons = ["iTunesArtwork.png", "Icon.png", "Icon@2x.png", "Icon-72.png", "Icon-Small.png", "Icon-Small-50.png", "Icon-Small@2x.png","Default.png"]
  		app.prerendered_icon = false
  		app.files_dependencies 'app/activity_github_api_star_put.rb' => 'app/activity_template_github_api.rb'
  		app.files_dependencies 'app/activity_github_api_star_delete.rb' => 'app/activity_template_github_api.rb'
  		app.files_dependencies 'app/activity_github_api_follow_put.rb' => 'app/activity_template_github_api.rb'
  		app.files_dependencies 'app/activity_github_api_follow_delete.rb' => 'app/activity_template_github_api.rb'
  		app.files_dependencies 'app/activity_github_api_watch_put.rb' => 'app/activity_template_github_api.rb'
		app.files_dependencies 'app/activity_github_api_watch_delete.rb' => 'app/activity_template_github_api.rb'
		app.files_dependencies 'app/feature_profile_view_controller.rb' => 'app/feature_template_webview_controller.rb'
		app.files_dependencies 'app/feature_readme_view_controller.rb' => 'app/feature_template_webview_controller.rb'
	end
 

スクリーンショット / Screenshot
----------
![main_table_view_controller.png](https://raw.github.com/amazedkoumei/motion-octofeed/master/screenshot/main_table_view_controller.png "main_table_view_controller.png")

![detail_view_controller.png](https://raw.github.com/amazedkoumei/motion-octofeed/master/screenshot/detail_view_controller.png "detail_view_controller")
  ![web_view_controller.png](https://raw.github.com/amazedkoumei/motion-octofeed/master/screenshot/web_view_controller.png "web_view_controller")
![feature_profile_view_controller.png](https://raw.github.com/amazedkoumei/motion-octofeed/master/screenshot/feature_profile_view_controller.png "feature_profile_view_controller")
  ![feature_readme_view_controller.png](https://raw.github.com/amazedkoumei/motion-octofeed/master/screenshot/feature_readme_view_controler.png "feature_readme_view_controller")


ライセンス / License
----------
Copyright &copy; 2012 amazedkoumei
Licensed under the [GPL version 3][gpl]
 
[gpl]: http://opensource.org/licenses/gpl-3.0.html