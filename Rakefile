# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler/setup'
require 'yaml'

Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = "Octofeed"
  app.version = '1.0.1'
  app.frameworks += ["MessageUI"]
  app.sdk_version = "6.1"
  app.deployment_target = "6.0"
  app.device_family = [:iphone]
  app.interface_orientations = [:portrait]
  app.icons = ["iTunesArtwork.png", "Icon.png", "Icon@2x.png", "Icon-72.png", "Icon-Small.png", "Icon-Small-50.png", "Icon-Small@2x.png","Default.png"]
  app.prerendered_icon = false

  if File.exists?('./config.yml')
    config = YAML::load_file('./config.yml')

    app.identifier = config['identifier']
    # for URL scheme
    app.info_plist['CFBundleURLTypes'] = [
      { 
        'CFBundleURLName' => config['identifier'],
        'CFBundleURLSchemes' => ["octofeed"]
      }
    ]

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