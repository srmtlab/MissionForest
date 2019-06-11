MissionForest
====
Web application to share collaborative activities

## Description
MissionForest is the system for sharing collaborative activities.  
MissionForest has been developed as successor system since 2016 in order to overcome the technical issues of [GoalShare](https://github.com/srmtlab/GoalShare).  

## Online demo
- Under Construction

## Requirement
- ruby 2.6.3
    - rails 5.2.3
- Web server (Nginx, apache, ...)
    - to serve static content and proxy
- Redis
- [Virtuoso](https://virtuoso.openlinksw.com/rdf/) (Optional)


## How to start
1. download source code 
```bash
git clone https://github.com/srmtlab/MissionForest.git
cd MissionForest
```

2. set environment variable and generate a Rails Secret Key  
generate a Rails Secret Key and copy this value to SECRET_KEY_BASE in .env file

```bash
bundle exec rake secret
mv .env.template .env
```
Open .env and modify variable

3. Install library 
```bash
bundle install --path vendor/bundle --without test development
```

4. make database and migrate
```bash
bundle exec rake db:create RAILS_ENV=production
bundle exec rake db:migrate RAILS_ENV=production
```

### run server
```bash
gem install foreman
foreman start -f ./Procfile.production
```

# for developer
locate database Setting file (database.yml) in **/config**

1. Install library 
```bash
bundle install --path vendor/bundle --without test production
```

2. make database and migrate
```bash
bundle exec rake db:create RAILS_ENV=development
bundle exec rake db:migrate RAILS_ENV=development
```

### run server
```bash
gem install foreman
foreman start -f ./Procfile.development
```

# Authors
- Akira Kamiya
  - 2019-03 - now
- Masaru Watanabe
  - 2017-03 - 2019-03
- Yasuaki Goto
  - 2016-03 - 2017-03
  
# LICENCE
- The MIT LICENCE (MIT)