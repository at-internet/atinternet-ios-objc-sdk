Pod::Spec.new do |s|
	s.name         = "ATInternet-iOS-ObjC-SDK"
	s.version      = '2.2.7.1'
	s.summary      = "AT Internet mobile analytics solution for iOS"
	s.homepage     = "https://github.com/at-internet/atinternet-ios-objc-sdk"
	s.documentation_url = 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license      = "MIT"
	s.author     = "AT Internet"
	s.platform = :ios
  	s.ios.deployment_target = '7.0'

	s.source       = { :git => "https://github.com/summerize/atinternet-ios-objc-sdk.git", :tag => s.version}
	s.prefix_header_file = "Tracker/Tracker/ATTracker-prefix.pch"

	s.subspec 'Res' do |res|
		res.resource_bundle = {'ATAssets' => ['Tracker/Tracker/*.{xcdatamodeld,png,json}','Tracker/Tracker/ATDefaultConfiguration.plist']}
	end

	s.subspec 'iOS' do |ios|
		ios.source_files  = "Tracker/Tracker/*.{h,m}"
		ios.frameworks = "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration"
		ios.dependency s.name+'/Res'
	end

	s.subspec 'AppExtension' do |appExt|
		pchwatch = <<-EOS
			#define AT_EXTENSION
		EOS
		appExt.prefix_header_contents = pchwatch
		appExt.source_files  = "Tracker/Tracker/*.{h,m}"
		appExt.exclude_files = "Tracker/Tracker/ATBackgroundTask.{h,m}"
		appExt.frameworks = "CoreData", "CoreFoundation", "WatchKit", "UIKit", "CoreTelephony", "SystemConfiguration"
		appExt.dependency s.name+'/Res'
	end
	s.requires_arc = true
end
