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
      result.check(db[:n03_001].where(:name => "北海道").one?,"exist hokkaido?")
      result.check(db[:n03_001].where(:name => "沖縄県").one?,"exist okinawa?")
    end
    
    result.check(db.table_exists?(:n03_002), "db.table_exists?(:n03_002)")
    result.check(db.table_exists?(:n03_003), "db.table_exists?(:n03_003)")
    result.check(db.table_exists?(:n03_004), "db.table_exists?(:n03_004)")
    result.check(db.table_exists?(:n03_007), "db.table_exists?(:n03_007)")

    result.check(
      db[:n03_002].where(:name.like('%支庁%'), 'parent_id IS NOT NULL').all.count > 0, 
      "exist sityou?"
    )
    # 北海道以外は支庁名を含まない
    # "支庁名	当該都道府県が「北海道」の場合、該当する支庁の名称。	文字列型"
    # http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03.html
    hokkaido_id = db[:n03_001].select(:id).where(:name => "北海道").first[:id]
    count_valid_row = db[:n03_002].where(:name.like('%支庁%'), :parent_id=>hokkaido_id).count
    result.check(count_valid_row > 0, "count valid row")
  rescue
    p result
    system("watchr watchr.rb #{ARGV[1]} #{ARGV[2]}")
  ensure
    p result
  end
end

