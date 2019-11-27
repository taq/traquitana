%w(traquitana/version config selector deployer packager ssh bar cleaner).each do |file|
   require File.dirname(__FILE__)+"/"+file
end
