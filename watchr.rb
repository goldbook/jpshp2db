# 更新監視して自動テスト実行
# watchr watchr.rb user pass 
require 'sequel'
require 'ruby_gntp'

class Result
  @ok
  @ng
  
  def initialize
    @ok = 0
    @ng = 0
  end

  attr_reader :ok, :ng
  
  def check(boolean, explain="")
    if(boolean == true)
      puts "#{explain}: OK"
      @ok += 1
      return true
    else
      puts "#{explain}: NG"
      @ng += 1
      return false
    end
  end
  
  def all
    return @ok + @ng
  end
  
  def to_s
    return [:ok => @ok, :ng => @ng, :all => @ok + @ng]
  end
end

# このファイル自身が監視対象に入ってない？
watch( '(.*)\.rb' ) do |md|
  puts ARGV
  puts "Time.now: #{Time.now}"
  begin
    system("ruby #{md[0]} #{ARGV[1]} #{ARGV[2]}")
    
    result = Result.new
    db = Sequel.connect(
      :adapter=>'postgres', 
      :host=>'localhost', 
      :database=>'geo', 
      :user=>ARGV[1], 
      :password=>ARGV[2]
    )
    
    result.check(db.table_exists?(:n03_001), "db.table_exists?(:n03_001)")
    if(db.table_exists?(:n03_001))
      result.check(db[:n03_001].all.count == 47, "db[:n03_001].all.count == 47")
    end
    
    puts result.to_s  
  rescue
    system("watchr watchr.rb #{ARGV[1]} #{ARGV[2]}")
  end
end

