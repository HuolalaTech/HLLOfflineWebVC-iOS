#
# Be sure to run `pod lib lint HLLOfflineWebVC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HLLOfflineWebVC'
  s.version          = '1.0.0'
  s.summary          = 'HLLOfflineWebVC 包含展示的容器webvc及离线包管理工具. subspec仅用来分组功能类'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      =  'HUOLALA Offline WebVC SDK'
  s.homepage         = 'https://xxx.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'GPL', :file => 'LICENSE' }
  s.author           = { '货拉拉' => '货拉拉' }
  s.source           = { :git => ' ', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = {
      'ENABLE_BITCODE' => 'NO',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'VALID_ARCHS' => 'arm64 armv7 x86_64'
  }

  s.source_files = 'HLLOfflineWebVC/Classes/*.{h,m}'  
  # 离线包管理模块，核心模块，包含离线包查询、下载、缓存管理、数据上报功能
  s.subspec 'OfflineWebPackage' do |package|
    package.source_files = 'HLLOfflineWebVC/Classes/OfflineWebPackage/*.{h,m}'
    package.dependency 'HLLOfflineWebVC/OfflineWebConst'
    package.dependency 'HLLOfflineWebVC/OfflineWebUtils'
    package.dependency 'HLLOfflineWebVC/Private'
  end
  
  #开发者debug调试工具。方便开发和测试阶段查看和清除离线包
  s.subspec 'OfflineWebDevTool' do |webDevTool|
    webDevTool.source_files = 'HLLOfflineWebVC/Classes/OfflineWebDevTool/*.{h,m}'
    webDevTool.dependency 'HLLOfflineWebVC/OfflineWebPackage' #本地离线包文件删除等管理操作用到
    webDevTool.dependency 'HLLOfflineWebVC/OfflineWebConst'
    webDevTool.dependency 'CRToast'
  end

  # 一此辅助功能工具类
  s.subspec 'OfflineWebUtils' do |util|
    util.source_files = 'HLLOfflineWebVC/Classes/OfflineWebUtils/*.{h,m}' 
    util.dependency 'HLLOfflineWebVC/OfflineWebConst'
    util.dependency 'SSZipArchive' #文件解压用到
  end

  # 离线包URL和bisName自动匹配
  s.subspec 'OfflineWebBisNameMatch' do |util|
    util.source_files = 'HLLOfflineWebVC/Classes/OfflineWebBisNameMatch/*.{h,m}'
  end
  
  # SDK内部使用的私有类
  s.subspec 'Private' do |_private|
    _private.source_files = 'HLLOfflineWebVC/Classes/Private/*.{h,m}'
    _private.dependency 'HLLOfflineWebVC/OfflineWebConst'
    _private.dependency 'HLLOfflineWebVC/OfflineWebUtils'
  end

  # 定义一些公用的常量、回调、宏等
  s.subspec 'OfflineWebConst' do |webConst|
    webConst.source_files = 'HLLOfflineWebVC/Classes/OfflineWebConst/*.{h,m}'
  end
end
