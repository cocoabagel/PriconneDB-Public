# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
inhibit_all_warnings!

target 'PriconneDB' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PriconneDB
  pod 'Reveal-SDK', :configurations => ['Debug']
  pod 'SwiftLint'
  pod 'Firebase/Core', :inhibit_warnings => true
  pod 'Firebase/Firestore', :inhibit_warnings => true
  pod 'Firebase/Performance', :inhibit_warnings => true
  pod 'Firebase/Analytics', :inhibit_warnings => true
  pod 'Firebase/Auth', :inhibit_warnings => true
  pod 'Fabric', '~> 1.9.0', :inhibit_warnings => true
  pod 'Crashlytics', '~> 3.12.0', :inhibit_warnings => true
  pod 'Kingfisher', '~> 5.0'
  pod 'KingfisherWebP'
  pod 'TTGTagCollectionView'
  pod 'PanModal'
  pod 'SwiftyBeaver'
  pod 'RealmSwift'
  pod 'Then'
  pod 'JJFloatingActionButton'
  pod 'ViewAnimator'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-PriconneDB/Pods-PriconneDB-acknowledgements.plist', 'PriconneDB/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
