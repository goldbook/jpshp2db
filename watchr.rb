# 更新監視して自動テスト実行
# watchr watchr.rb user pass 
require 'sequel'

# このファイル自身が監視対象に入ってない？
watch( '(.*)\.rb' ) do |md|
  puts "*** launch watchr.rb ***"
  puts ARGV.to_s
  
  user = ARGV[1]
  password = ARGV[2]
  
  system("ruby geo_db.rb #{user} #{password}")
  system("ruby tests.rb #{user} #{password}")
  puts "*** finish watchr.rb ***"
end