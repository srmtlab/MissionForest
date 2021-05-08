How to deploy the MissionForest Using docker-compose
===
## Install dependencies
- Git
- Docker
- Docker Compose

If you publish data as LOD, you should set this app.
- [Virtuoso](https://virtuoso.openlinksw.com/rdf/) (Optional)

## Requirement
- Gmail Account
    - This app uses Gmail

## Build the app
You need to clone the repository:
```bash
git clone https://github.com/srmtlab/MissionForest.git
cd MissionForest
```

Set the environment variables in `.envs/.production/` properly. If you want to deploy this app externally, you should change the following variables.
```
# .envs/.production/.mysql
MYSQL_ROOT_PASSWORD=  # mysql root password
MYSQL_PASSWORD= # mysql password

# .envs/.production/.rails
G_MAIL_USERNAME= # Gmail account
G_MAIL_PASSWORD= # password for Gmail account 
SITE_URL= # site url, host to MissionForest (used by the mailer)
SITE_PORT= # site port, host to MissionForest (used by the mailer)
```

Build the container and set `credentials.yml.enc`
```bash
docker-compose -f docker-compose.prod.yml build

# Generate a config/credentials.yml.enc
docker-compose -f docker-compose.prod.yml run -e EDITOR=vi rails bundle exec rails credentials:edit
```

Run MissionForest:
```bash
docker-compose -f docker-compose.prod.yml up
```
Go to http://localhost


View MissionForest logs:
```bash
docker-compose -f docker-compose.prod.yml exec rails tail -f log/production.log
```