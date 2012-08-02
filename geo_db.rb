require 'sequel'
require 'pry'

puts ARGV

unless ARGV.size == 2
  puts "need username, password"
  puts "user: ARGV[0] ,password: ARGV[1]"
  exit
end

TABLE_NAME_PREFIX = "n03%" #大文字小文字区別する
DB_NAME = "geo"
TODOFUKEN_NUM = 47 # 都道府県の数

conn = Sequel.connect(
  :adapter=>'postgres', 
  :host=>'localhost', 
  :database=>DB_NAME, 
  :user=>ARGV[0], 
  :password=>ARGV[1]
)

puts conn

# shpテーブルと作成予定テーブルは頭が被るので消しておく
conn.drop_table?(:n03_001, :n03_002, :n03_003, :n03_004, :n03_007)

# postgres向け。pg_stat_user_tablesテーブルから既存テーブル名を取得
relnames = conn[:pg_stat_user_tables].select(:relname).
  filter(:relname.like(TABLE_NAME_PREFIX)).order(:relname).all
unless relnames.count > 0
  puts "no shp tables"
  return 0
end

puts "relnames.count: #{relnames.count.to_s}" 

# 各テーブルの都道府県名をテーブルへ入れていく
conn.transaction do
  relnames.each_with_index do |column, i|
    if(i == 0)
      puts "create table"
      # 都道府県名テーブル
      conn.create_table!(:n03_001) do
        primary_key :id
        String :name
      end

      table_symbol_ary = [:n03_002, :n03_003, :n03_004, :n03_007]      
      table_symbol_ary.each do |symbol|
        # 親を持つ各要素のテーブル
        conn.create_table!(symbol) do
          primary_key :id
          integer :parent_id
          String :name
        end
      end
    end
    
    escaped_name = "\"#{column[:relname]}\""
    insert_pref_sql = "select n03_001 as name from #{escaped_name} "
    insert_pref_sql += "where n03_001 is not null limit 1"
    insert_sityou_sql = "select distinct n03_001.id as parent_id, n03_002 as name from #{escaped_name} "
    insert_sityou_sql += " left join n03_001 on n03_001.name = #{escaped_name}.n03_002 where n03_002 is not null"

    # 都道府県名挿入
    conn.fetch(insert_pref_sql) do |row|
      conn[:n03_001].insert(:name => row[:name])
    end
    
    # 支庁名挿入
    conn.fetch(insert_sityou_sql) do |row|
      puts row.to_s
      conn[:n03_002].insert(:parent_id => 1, :name => row[:name])
    end
  end
end

__END__
N03-12_43_120331.shp
N03-12_44_120331.shp
N03-12_45_120331.shp
N03-12_46_120331.shp
N03-12_47_120331.shp
N03-12_01_120331.shp
N03-12_02_120331.shp
N03-12_03_120331.shp
N03-12_04_120331.shp
N03-12_05_120331.shp
N03-12_06_120331.shp
N03-12_07_120331.shp
N03-12_08_120331.shp
N03-12_09_120331.shp
N03-12_10_120331.shp
N03-12_11_120331.shp
N03-12_12_120331.shp
N03-12_13_120331.shp
N03-12_14_120331.shp
N03-12_15_120331.shp
N03-12_16_120331.shp
N03-12_17_120331.shp
N03-12_18_120331.shp
N03-12_19_120331.shp
N03-12_20_120331.shp
N03-12_21_120331.shp
N03-12_22_120331.shp
N03-12_23_120331.shp
N03-12_24_120331.shp
N03-12_25_120331.shp
N03-12_26_120331.shp
N03-12_27_120331.shp
N03-12_28_120331.shp
N03-12_29_120331.shp
N03-12_30_120331.shp
N03-12_31_120331.shp
N03-12_32_120331.shp
N03-12_33_120331.shp
N03-12_34_120331.shp
N03-12_35_120331.shp
N03-12_36_120331.shp
N03-12_37_120331.shp
N03-12_38_120331.shp
N03-12_39_120331.shp
N03-12_40_120331.shp
N03-12_41_120331.shp
N03-12_42_120331.shp