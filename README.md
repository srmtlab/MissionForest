MissionForest
====
Web application to share collaborative activities

## Description
MissionForest is the system for sharing collaborative activities.  
MissionForest has been developed as successor system since 2016 in order to overcome the technical issues of [GoalShare](https://github.com/srmtlab/GoalShare).  

## Online demo
- [http://mf.srmt.nitech.ac.jp/](http://mf.srmt.nitech.ac.jp/)

## Install dependencies
- Git
- Docker
- Docker Compose

If you publish data as LOD, you should set this app.
- [Virtuoso](https://virtuoso.openlinksw.com/rdf/) (Optional)

## Get the code

You need to clone the repository:

```bash
git clone https://github.com/srmtlab/MissionForest.git
cd MissionForest
```

## Production
### Using docker-compose
Set the environment variables in `.envs/.production/` properly. If you want to deploy this app externally, you should change the following variables.

```bash
# .envs/.production/.mysql
MYSQL_ROOT_PASSWORD=  # mysql root password
MYSQL_PASSWORD= # mysql password

# .envs/.production/.rails
G_MAIL_USERNAME= # Gmail account
G_MAIL_PASSWORD= # password for Gmail account 
```

Run MissionForest:
```bash
docker-compose -f docker-compose.prod.yml up
```
Go to http://localhost

## Development
### Using docker-compose
Run MissionForest:
```bash
docker-compose up

# Migrate database
docker-compose exec rails bundle exec rails db:migrate
# Run MissionForest: http://localhost:3000
docker-compose exec rails bundle exec rails s
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

# References
- [研究室内外の協働を促進する (Knowledge Connector)](http://idea.linkdata.org/idea/idea1s2394i)
- [MissionForest: 組織内外における協働支援のためのタスク構造化システムの試作 (IPSJ 全国大会)](https://ipsj.ixsq.nii.ac.jp/ej/?action=repository_uri&item_id=181580)
