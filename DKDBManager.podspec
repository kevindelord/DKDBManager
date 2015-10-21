Pod::Spec.new do |s|
  s.name             = "DKDBManager"
  s.version          = "0.5.3"
  s.summary          = "Database manager to use around MagicalRecord to provide a complete CRUD logic for your entities."
  s.homepage         = "https://github.com/kevindelord/DKDBManager"
  s.license          = 'MIT'
  s.author           = { "kevindelord" => "delord.kevin@gmail.com" }
  s.source           = { :git => "https://github.com/kevindelord/DKDBManager.git", :tag => s.version.to_s }
  s.platform         = :ios
  s.requires_arc     = true
  s.ios.deployment_target = '6.1'
  s.framework        = 'CoreData'
  s.source_files     = 'DKDBManager/*'
  s.dependency         'MagicalRecord', '~> 2.3.0'
  s.prefix_header_contents = <<-EOS
#import <CoreData/CoreData.h>
#import "MagicalRecord.h"
EOS
end