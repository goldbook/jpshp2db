# 更新監視して自動実行
# watchr -l watchr.rb user pass 
watch( 'geo_db.rb' )  {|md| system("ruby #{md[0]} #{ARGV[1]} #{ARGV[2]}") }