jpshp2db
========

国土地理院の公開しているshpファイルを使いやすい構造のDBへ

*require*  
オブジェクト指向スクリプト言語 Ruby <http://www.ruby-lang.org/ja/>  
PostGIS : Home <http://postgis.refractions.net/>  
Sequel: The Database Toolkit for Ruby <http://sequel.rubyforge.org/>  

国土数値情報　行政区域データの詳細    
<http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03.html>  

*使い方*
1.各都道府県のshpファイルをDBに取り込む
2.geo_db.rbを実行
    ruby geo_db.rb db_user_name db_password