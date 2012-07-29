# 更新監視して自動実行
# watchr watchr.rb user pass 
require 'sequel'

puts ARGV
puts "Time.now: #{Time.now}"

# このファイル自身が監視対象に入ってない？
watch( '(.*)\.rb' ) do |md|
  
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
    result.check(!db[:n03_001].all.nil?)
    result.check(db[:n03_001].all.count == 47)
    
    p result
    
  rescue
    system("watchr watchr.rb #{ARGV[1]} #{ARGV[2]}")
  end
end

class Result
  @ok
  @ng
  
  def initialize
    @ok = 0
    @ng = 0
  end

  attr_reader :ok, :ng
  
  def check(boolean)
    if(boolean == true)
      puts "OK"
      @ok += 1
      return true
    else
      puts "NG"
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