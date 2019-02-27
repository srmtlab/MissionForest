# MissionForest

## 開発環境構築手順
1. config/database.yml にデータベース接続用の設定ファイルを配置。  
2. "bundle install"でライブラリをインストール  
3. "gem install foreman"でforemanをインストール  
4. "rake db:create"でデータベース作成  
5. "rake db:migrate"でマイグレーション  
6. "foreman start"でMissionForest起動  
