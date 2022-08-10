
Pod::Spec.new do |spec|

  spec.name         = "TodoItem"
  
  spec.version      = "0.0.1"
  
  spec.summary      = "Xa4y dop ball"

  spec.homepage     = "https://gitlab.com/itimur317/to-do"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "Timur" => "itimur317@gmail.com" }

  spec.platform     = :ios
  
  spec.ios.deployment_target = "14.0"

  spec.source       = { :http => 'file:' + __dir__ + '/TodoItem.zip' }

  spec.source_files = "TodoItem/*.{h,swift}"
  
#  spec.resource_bundles = {
#  'TodoItem' => ['TodoItem/*.lproj/*.strings']
#  }
  
  spec.resources = "TodoItem/*.{xib,xcassets,json,storyboard,xcdatamodeld,ttf,strings,sks,png}"

  spec.requires_arc = true

  spec.swift_versions = "5.0"

end

