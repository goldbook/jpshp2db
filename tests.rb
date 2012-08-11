puts "*** start test.rb ***"

require 'sequel'

class Result
  @ok
  @ng
  
  def initialize
    @ok = 0
    @ng = 0
  end

  attr_reader :ok, :ng
  
  def check(boolean, explain="")
    begin
      if(boolean == true)
        puts "#{explain}: OK"
        @ok += 1
        return true
      else
        puts "#{explain}: NG"
        @ng += 1
        return false
      end
    rescue
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

puts ARGV
puts "Time.now: #{Time.now}"

begin  
  result = Result.new
  db = Sequel.connect(
    :adapter=>'postgres', 
    :host=>'localhost', 
    :database=>'geo', 
    :user=>ARGV[0], 
    :password=>ARGV[1]
  )

  # 生成されるべきテーブルの存在チェック
  table_symbols = [:n03_001, :n03_002, :n03_003, :n03_004, :n03_007]
  table_symbols.each do |e|
    result.check(db.table_exists?(e), "db.table_exists?(#{e})")
  end
  # 存在チェックここまで
  
  # 都道府県テーブルの内容チェック
  result.check(db[:n03_001].all.count == 47, "db[:n03_001].all.count == 47")
  result.check(db[:n03_001].where(:name => "北海道").one?,"exist hokkaido?")
  result.check(db[:n03_001].where(:name => "沖縄県").one?,"exist okinawa?")

  # 支庁テーブルの内容チェック
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
  
  # 郡テーブルの内容チェック
  result.check(db[:n03_003].all.count > 0, "exit row in n03_003 ?") #内容存在チェック
  result.check(db[:n03_003].select(:name).distinct.all.count > 1, "n03_003 has many values ?")
  # 郡までの結合チェック
  result.check(
    db[:n03_003].join(:n03_002, :parent_id=>:n03_002__id)
      .join(:n03_001, :parent_id=>:n03_001__id).where, 
    "join pref to gun?"
  )
 
  #全テーブルの結合
  all_join_sql = "SELECT pref.name, sub_pref.name, seirei.name, muni.name, code.name FROM public.n03_001 pref, public.n03_002 sub_pref, public.n03_004 muni, public.n03_007 code, public.n03_003 seirei WHERE pref.id = sub_pref.parent_id AND sub_pref.id = seirei.parent_id AND muni.parent_id = seirei.id AND code.parent_id = muni.id;" 
  result.check(db.execute(all_join_sql).all.count > 0, "can join all tbl ?")
ensure
  p result
end

puts "*** finish test.rb ***"