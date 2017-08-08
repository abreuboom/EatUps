# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'EatUps' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Facebook
  pod 'FacebookCore', '~> 0.2'
  pod 'FacebookLogin', '~> 0.2'
  pod 'FacebookShare', '~> 0.2'
  pod 'FBSDKCoreKit', '~> 4.22.1'
  pod 'FBSDKLoginKit', '~> 4.22.1'
  pod 'FBSDKShareKit', '~> 4.22.1'

  # Pods for Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'

  # Other Pods
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'KeychainAccess'
  pod 'Alamofire', '~> 4.4'
  pod 'AlamofireImage', '~> 3.1'
  pod 'BouncyLayout'
  pod 'DZNEmptyDataSet'
  pod 'ChameleonFramework/Swift'
  pod 'SRCountdownTimer'
  pod 'EasyAnimation'
  pod 'ActiveLabel'
  pod 'YYKit'
  pod 'DateToolsSwift'
  pod 'ARCL'

  target 'EatUpsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EatUpsUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
