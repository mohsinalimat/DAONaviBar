Pod::Spec.new do |s|
  s.name         = "DAONaviBar"
  s.version      = "0.3.0"
  s.summary      = "DaoNaviBar is a navigation bar with smooth auto-scrolling animation."
  s.homepage     = "https://github.com/daoseng33/DAONaviBar"
  s.screenshots  = "https://media.giphy.com/media/aMkjGZk8fA8HC/giphy.gif"
  s.license      = "WTFPL"
  s.author             = { "daoseng33" => "lc.ray2011@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/daoseng33/DAONaviBar.git", :tag => "#{s.version}" }
  s.source_files = "DAONaviBar", "DAONaviBarDemo/DAONaviBar/**/*.{h,m}"
  s.framework    = "UIKit"
  s.dependency 'HTDelegateProxy', '~> 0.0.2'
  # s.frameworks = "SomeFramework", "AnotherFramework"
end