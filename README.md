MissionForest
====
MissionForest is the system for sharing collaborative activities.  
MissionForest has been developed as successor system since 2016 in order to overcome the technical issues of [GoalShare](https://github.com/srmtlab/GoalShare).  

## How to start
1. config/database.yml にデータベース接続用の設定ファイルを配置。  
2. "bundle install"でライブラリをインストール  
3. "gem install foreman"でforemanをインストール  
4. "rake db:create"でデータベース作成  
5. "rake db:migrate"でマイグレーション  
6. "foreman start"でMissionForest起動  

# Authors
- Akira Kamiya
  - 2019-3~
- Masaru Watanabe
  - 2017-03~2019-03
  - LOD, tag system
- Yasu Goto
  - 2016-03~2017-03
  - front engineer
  
# LICENCE
- The MIT LICENCE (MIT)
