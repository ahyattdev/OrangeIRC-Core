Pod::Spec.new do |s|
  
	s.name = "OrangeIRC"
	s.version = "0.0.1"
	s.summary = "IRC client framework written in Swift"
	s.homepage = "https://github.com/ahyattdev/OrangeIRC"
	s.license = "Apache License, Version 2.0"
  s.authors = { "Andrew Hyatt" => "ahyattdev@icloud.com" }
  
	s.social_media_url = "https://github.com/ahyattdev"
  
	s.screenshots = []
  
	s.source = { :git => "https://github.com/ahyattdev/OrangeIRC.git", :tag => "v#{s.version}" }
	s.source_files = "OrangeIRC Core/**/*.swift"
  s.resources = [ "OrangeIRC Core/*.lproj" ]
  
  s.dependency = "CocoaAsyncSocket", "~> 7.6.1"
  
	s.requires_arc = true
  
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  # s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "10.0"
  
  s.framework = "CocoaAsyncSocket"
  s.ios.framework = "UIKit"
  s.tvos.framework = "UIKit"
  s.osx.framework = "Cocoa"
  
end