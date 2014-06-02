Pod::Spec.new do |s|
  s.name             = "DKDBManager"
  s.version          = "0.1.0"
  s.summary          = "Database manager to use around MagicalRecord to provide a complete CRUD logic for your entities."
  s.homepage         = "https://github.com/kevindelord/DKDBManager"
  s.license          = 'MIT'
  s.author           = { "kevindelord" => "delord.kevin@gmail.com" }
  s.source           = { :git => "https://github.com/kevindelord/DKDBManager.git", :tag => s.version.to_s }
  s.platform         = :ios
  s.requires_arc     = true
  s.source_files     = 'DKDBManager/*'
  s.dependency         'MagicalRecord'
  s.dependency         'DKHelper'
end
