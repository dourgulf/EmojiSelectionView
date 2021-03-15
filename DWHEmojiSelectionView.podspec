Pod::Spec.new do |s|
  s.name             = 'DWHEmojiSelectionView'
  s.version          = '0.1.0'
  s.summary          = 'An emoji selection view like WeChat.'
  s.description      = <<-DESC
  An emoji selection view like WeChat.
                         DESC

  s.homepage         = 'https://github.com/dourgulf/EmojiSelectionView.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lidawen' => 'dawenhing@gmail.com' }
  s.source           = { :git => 'https://github.com/dourgulf/EmojiSelectionView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'DWHEmojiSelectionView/Classes/**/*'
  s.resources = 'DWHEmojiSelectionView/Assets/EmojisList.plist'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
