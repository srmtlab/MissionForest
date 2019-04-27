MissionForest
====
MissionForest is the system for sharing collaborative activities.  
MissionForest has been developed as successor system since 2016 in order to overcome the technical issues of [GoalShare](https://github.com/srmtlab/GoalShare).  

## How to start
1. locate database Setting file (database.yml) in ./config/

2. Install library 
```bash
bundle install
```
3. make database and migrate
```bash
bundle rake db:create
bundle rake db:migrate
```
### run server
```bash
foreman start
```

# Authors
- Akira Kamiya
  - 2019-3~
- Masaru Watanabe
  - 2017-03~2019-03
- Yasuaki Goto
  - 2016-03~2017-03
  
# LICENCE
- The MIT LICENCE (MIT)
