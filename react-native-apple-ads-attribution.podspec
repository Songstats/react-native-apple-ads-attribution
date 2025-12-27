require "json"
require_relative File.join(__dir__, "..", "..", "react-native", "scripts", "react_native_pods")

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-apple-ads-attribution"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.ios.weak_framework = 'AdServices'
  s.source       = { :git => "https://github.com/joel-bitar/react-native-apple-ads-attribution.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"

  s.dependency "React-Core"

  if ENV['RCT_NEW_ARCH_ENABLED'] == '1'
    s.compiler_flags = ['-DRCT_NEW_ARCH_ENABLED=1']
    s.pod_target_xcconfig = {
      "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
    }

    install_modules_dependencies(s)
  end
end
