=begin 更新監視して自動テスト実行
watchr watchr.rb user pass 
=end
require 'sequel'

watch( '(.*)\.rb' ) do |md|
  puts "*** launch watchr.rb ***"
  puts ARGV.to_s
  
  user = ARGV[1]
  password = ARGV[2]
  
  system("ruby geo_db.rb #{user} #{password}")
  system("ruby tests.rb #{user} #{password}")
  puts "*** finish watchr.rb ***"
end