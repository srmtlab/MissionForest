MissionForest
====
MissionForest is the system for sharing collaborative activities.  
MissionForest has been developed as successor system since 2016 in order to overcome the technical issues of [GoalShare](https://github.com/srmtlab/GoalShare).  

## Requirement
- [MeCab](http://taku910.github.io/mecab/)
- ruby 2.6.3
    - rails 5.2.3
- Web server (Nginx, apache, ...)
    - to serve static content and proxy
- [Virtuoso](https://virtuoso.openlinksw.com/rdf/) (Optional)


## How to start
1. download source code 
```bash
git clone https://github.com/srmtlab/MissionForest.git
cd MissionForest
```

2. set environment variable
```bash
mv .env.template .env
```
Open .env and modify variable

3. Install library 
```bash
bundle install --path vendor/bundle
```

4. make database and migrate
```bash
bundle exec rake db:create
bundle exec rake db:migrate
```

### run server
```bash
gem install foreman
foreman start
```

# for developer
locate database Setting file (database.yml) in **/config**

# Authors
- Akira Kamiya
  - 2019-3~
- Masaru Watanabe
  - 2017-03~2019-03
- Yasuaki Goto
  - 2016-03~2017-03
  
# LICENCE
- The MIT LICENCE (MIT)