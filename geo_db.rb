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
);
puts conn

# postgres向け。pg_stat_user_tablesテーブルから既存テーブル名を取得
relnames = conn[:pg_stat_user_tables].select(:relname).filter(:relname.like(TABLE_NAME_PREFIX)).order(:relname).all
unless relnames.count > 0
  puts "no shp tables"
  return 0
end
puts "relnames.count: #{relnames.count.to_s}" 

# 各テーブルの都道府県名をテーブルへ入れていく
conn.transaction do
  relnames.each_with_index do |column, i|
    if(i == 0)
      conn.create_table(:n03_001) do
        primary_key :id
        String :name
      end
    end
    
    sql = "select n03_001 from \"#{column[:relname]}\" where n03_001 is not null limit 1"
    shp_pref_col = conn.run(sql)
    new_pref_table = conn[:n03_001]
    # shp_pref_col = conn.run("select ")
      # .select(:n03_001).filter~{:n03_001 => nil}.first
    # new_pref_table.insert(:name, pref_name_col[:n03_001])
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