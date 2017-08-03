Pod::Spec.new do |s|
	s.name         = "ATInternet-iOS-ObjC-SDK-AppExtension"
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

	s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) AT_EXTENSION'}
	s.source_files  = "Tracker/Tracker/*.{h,m}"
	s.exclude_files = "Tracker/Tracker/ATBackgroundTask.{h,m}"
	s.frameworks = "CoreData", "CoreFoundation", "WatchKit", "UIKit", "CoreTelephony", "SystemConfiguration"
	s.dependency s.name+'/Res'
	s.requires_arc = true
end
