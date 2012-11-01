#
# Cookbook Name:: gis
# Recipe:: default
#
# Copyright 2012, doronawa studio
#
# All rights reserved - Do Not Redistribute
#

# rubyとgem
package "ruby"
required_gem = [:sequel, :pry]

required_gem.each do |gem|
  command "gem install #{gem.to_s}"
end

# postgis
package "postgis"

# TODO posogisの設定

# TODO issues #3 shpデータのインポート
# ダウンロードはサイトへ負荷がかかるので手動前提でいいかも
# 全部チェック入れた状態でサイト開けばOK？

