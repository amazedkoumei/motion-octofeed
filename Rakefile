# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler/setup'
require 'yaml'

Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = "Octofeed"
  app.version = '1.0.0'
  app.frameworks += ["MessageUI"]
  app.sdk_version = "6.0"
  app.deployment_target = "6.0"
  app.device_family = [:iphone]
  app.interface_orientations = [:portrait]
  app.icons = ["iTunesArtwork.png", "Icon.png", "Icon@2x.png", "Icon-72.png", "Icon-Small.png", "Icon-Small-50.png", "Icon-Small@2x.png","Default.png"]
  app.prerendered_icon = false
=begin
  app.files_dependencies 'app/activity_github_api_star_put.rb' => 'app/activity_template_github_api.rb'
  app.files_dependencies 'app/activity_github_api_star_delete.rb' => 'app/activity_template_github_api.rb'
  app.files_dependencies 'app/activity_github_api_follow_put.rb' => 'app/activity_template_github_api.rb'
  app.files_dependencies 'app/activity_github_api_follow_delete.rb' => 'app/activity_template_github_api.rb'
  app.files_dependencies 'app/activity_github_api_watch_put.rb' => 'app/activity_template_github_api.rb'
  app.files_dependencies 'app/activity_github_api_watch_delete.rb' => 'app/activity_template_github_api.rb'
  app.files_dependencies 'app/feature_profile_view_controller.rb' => 'app/feature_template_webview_controller.rb'
  app.files_dependencies 'app/feature_readme_view_controller.rb' => 'app/feature_template_webview_controller.rb'
=end
  if File.exists?('./config.yml')
    config = YAML::load_file('./config.yml')

    app.identifier = config['identifier']
    app.development do
      app.codesign_certificate = config['development']['certificate']
      app.provisioning_profile = config['development']['provisioning']

      app.testflight.sdk = 'vendor/TestFlight'
      app.testflight.api_token = config['testflight']['api_token']
      app.testflight.team_token = config['testflight']['team_token']
      if config['testflight']['provisioning']
        app.provisioning_profile = config['testflight']['provisioning']
      end
    end
    app.release do
      app.codesign_certificate = config['release']['certificate']
      app.provisioning_profile = config['release']['provisioning']
      app.seed_id = config['release']['seed_id']
    end
  end
end