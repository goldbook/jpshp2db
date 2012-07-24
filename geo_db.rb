require 'pg'
require 'pry'

unless ARGV.size == 2
  puts "need username, password"
  puts "user: ARGV[0] ,password: ARGV[1]"
  exit
end

TABLE_NAME_PREFIX = "n03%" #大文字小文字区別する
DB_NAME = "geo"
TODOFUKEN_NUM = 47

conn = PG.connect(dbname: DB_NAME, user: ARGV[0] ,password: ARGV[1]);
puts conn
sql = "select relname from pg_stat_user_tables where relname like $1 order by relname"
conn.prepare("pref_tabels", sql)
conn.describe_prepared("pref_tabels")
ret = conn.exec_prepared("pref_tabels", [TABLE_NAME_PREFIX])

unless ret.count > 0
  puts "no shp tables"
  return 0
end

# 都道府県名の配列
pref_names = ret.values.map do |n|
  sql = "SELECT distinct n03_001 pref FROM \"#{n[0]}\""
  conn.exec(sql).select{|n| not n["pref"].nil? and not n["pref"].strip.nil?}
end

insert_pref_sql = "insert into n03_001 (id, n03_001) values ($1, $2)"

conn.prepare("insert_pref", sql)

pref_names.flatten.each_with_index do |e, i|
  if i == 0
    # ループ初回でテーブル作成
    conn.exec("create table n03_001(select '#{i}' id, #{e})")
　else
    
  end
  puts e["pref"].encode("cp932")
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