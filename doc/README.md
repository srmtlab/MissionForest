# Tips
- MissionForestを開発するためのTipsです

## For developer
```
# create and launch development environment
git clone https://github.com/srmtlab/MissionForest.git
cd MissionForest
docker-compose up -d

# If you want to know about environment variable, you should access https://github.com/srmtlab/MissionForest/wiki/Deploy
mv rails/.env.template rails/.env

docker-compose exec rails foreman run bundle exec rake db:create
docker-compose exec rails foreman run bundle exec rake db:migrate
docker-compose exec rails foreman start -f ./Procfile.development

# launch development environment
docker-compose up -d
docker-compose exec rails foreman start -f ./Procfile.development

# railsコンテナに入る
docker-compose exec rails sh

# MySqlコンテナに入る
docker-compose exec mysql sh
```

### generate Controller
コントローラーを作成して，ルーティング（/config/routes.rb）を編集すれば使えるようになります．
```
# railsコンテナに入る
docker-compose exec rails sh

foreman run bundle exec rails generate controller コントローラ名
# 例
foreman run bundle exec rails generate controller Home
```

### make Model
```
# railsコンテナに入る
docker-compose exec rails sh

# モデルを作成する
# モデルが作成された際に、マイグレーションファイル（DBの設計図のようなもの）も作成されます
foreman run bundle exec rails generate model モデル名

# 例 : Avatorモデルの作成
foreman run bundle exec rails generate model Avator

# migrate（MySQLにマイグレーションファイルの内容を適応する）
foreman run bundle exec rake db:migrate

-----------------------------
# カラムを追加する
foreman run bundle exec rails generate migration Addカラム名Toテーブル名
# 例 : Userモデルにnameカラムを追加
foreman run bundle exec rails generate migration AddNameToUsers
# 例 : Userモデルに複数のカラムを追加
foreman run bundle exec rails generate migration AddBasicInfoToUsers


# migrate（MySQLにマイグレーションファイルの内容を適応する）
foreman run bundle exec rails db:migrate
```

### seedデータ（初期データ）の作り方
```
docker-compose exec rails sh

# db/seeds.rbを編集 : 参考にすること
foreman run bundle exec rails db:seed
```

#### 参考
- [コントローラの作成と命名規則(命名規約)](https://www.javadrive.jp/rails/controller/index1.html)
- [Rails generate の使い方とコントローラーやモデルの命名規則](https://qiita.com/higeaaa/items/96c708d01a3dbb161f20)

# Authors
- Akira Kamiya