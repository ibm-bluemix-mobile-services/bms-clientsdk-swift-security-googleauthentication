Pod::Spec.new do |s|
    s.name         = "BMSGoogleAuthentication"
    s.version      = '0.0.17'
    s.ios.deployment_target = '8.0'
    s.platform     = :ios, '8.0'
    s.requires_arc = true
    s.summary      = "Authentication manager for connecting to IBM Bluemix Mobile Services Google protected resource"
    s.homepage     = "https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-security-googleauthentication"
    s.license      = 'Apache License, Version 2.0'
    s.author       = { "IBM Bluemix Services Mobile SDK" => "mobilsdk@us.ibm.com" }

    #s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-security-googleauthentication.git', :branch => 'development'}
    s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-security-googleauthentication.git', :tag => "v#{s.version}"}

    s.documentation_url = 'https://www.ng.bluemix.net/docs/#services/mobileaccess/index.html'
    s.dependency 'Google/SignIn'
    s.dependency 'BMSSecurity'
    s.resource = 'Source/GoogleAuthenticationManager.swift'
    #s.source_files = 'Source/*.swift'

end
