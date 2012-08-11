require 'sequel'
require 'pry'

puts "*** start geo_db.rb ***"
puts ARGV.to_s

unless ARGV.size == 2
  puts "need username, password"
  exit
end

USER = ARGV[0]
PASSWORD = ARGV[1]

TABLE_NAME_PREFIX = "n03%" #大文字小文字区別する
DB_NAME = "geo"
TODOFUKEN_NUM = 47 # 都道府県の数

conn = Sequel.connect(
  :adapter=>'postgres', 
  :host=>'localhost', 
  :database=>DB_NAME, 
  :user=>USER, 
  :password=>PASSWORD
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
          integer :parent_id, :null=>false
          String :name
        end
      end
    end

    escaped_name = "\"#{column[:relname]}\""
    select_pref_sql = "select n03_001 as name from #{escaped_name} "
    select_pref_sql += "where n03_001 is not null limit 1"
    select_sityou_sql = "SELECT distinct prefs.id AS parent_id, shp.n03_002 AS name FROM public.#{escaped_name} shp, public.n03_001 prefs WHERE prefs.name = shp.n03_001"
    select_gun_sql = "SELECT distinct pref.id AS parent_id, shp.n03_003 AS name "
    select_gun_sql += " FROM public.#{escaped_name} shp, public.n03_001 pref WHERE shp.n03_001 = pref.name;"

    # 都道府県名挿入
    conn.fetch(select_pref_sql) do |row|
      conn[:n03_001].insert(:name => row[:name])
    end
    
    # 支庁名挿入。北海道以外ではn03_002がnull埋めなのでループに入る事がない
    conn.fetch(select_sityou_sql) do |row|
      conn[:n03_002].insert(:parent_id => 1, :name => row[:name])
    end

    # 郡名挿入
    conn.fetch(select_gun_sql) do |row|
      conn[:n03_003].insert(row)
    end
  end
end

puts "*** finish geo_db.rb ***"

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