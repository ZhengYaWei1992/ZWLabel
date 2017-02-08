
Pod::Spec.new do |s|
  s.name         = "ZWLabel"
  s.version      = "0.0.2"
  s.summary      = "这是我的框架"
  s.homepage     = "https://github.com/ZhengYaWei1992/ZWLabel"
  s.license      = "MIT"
  s.author             = { "ZhengYaWei1992" => "email@address.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ZhengYaWei1992/ZWLabel.git", :tag => s.version }
  s.source_files  = "ZWLabel", "ZWlabelDemo/ZWlabelDemo/ZWlabel/*.{h,m}"
  s.requires_arc = true
end
