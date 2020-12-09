Pod::Spec.new do |spec|

  spec.name         = "SipTru"
  spec.version      = "0.0.9"
  spec.summary      = "广东触点科技有限公司云对讲库"
  spec.homepage     = "https://github.com/1691665955/SipTru.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "masterzeng" => "1691665955@qq.com" }
  spec.source       = { :git => "https://github.com/1691665955/SipTru.git", :tag => spec.version }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  spec.requires_arc = true
  spec.ios.deployment_target = '9.0'
  spec.dependency 'linphone-sdk','4.3'
  spec.vendored_frameworks = "SipTru.framework"

end
