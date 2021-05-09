How to set up the MissionForest development environment
===
## Install dependencies
- ruby 2.6.3
    - recommend installing ruby using [rbenv](https://github.com/rbenv/rbenv)
- Web server (Nginx, Apache, ...)
    - to serve static content and proxy
- Node.js v14
    - recommend installing Node.js using [nodenv](https://github.com/nodenv/nodenv)
- Redis
- MySQL5.x

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

# For Ubuntu
sudo apt install libmysqlclient-dev shared-mime-info tzdata

bundle install --path vendor/bundle
```

generate `.env.production.local` and `credentials.yml.enc`
```bash
# Read https://github.com/bkeepers/dotenv#what-other-env-files-can-i-use
cp .env.development.local.template .env.development.local

# Generate a config/credentials.yml.enc
EDITOR=vi bundle exec rails credentials:edit
```

Open `.env.development.local` and modify below variable

below variable is about MySQL, Redis
- MYSQL_HOST : MySQL Host (default 127.0.0.1)
- MYSQL_PORT : MySQL PORT (default 3306)
- MYSQL_USER : MySQL User
- MYSQL_PASSWORD : MySQL Password
- MYSQL_DATABASE : MySQL Database Name
- REDIS_HOST : Redis host (default 127.0.0.1)
- REDIS_PORT : Redis port (default 6379)

below variable is about mail setting
- G_MAIL_USERNAME : Gmail Account
- G_MAIL_PASSWORD : Gmail Account password
- SITE_URL : Web site URL where MissionForest can serve
- SITE_PORT : Web site PORT where MissionForest can serve

If you publish data in MissionForest as Linked Open Data, you should set below variable
- LOD : true
- MF_RESOURCE : MissionForest concept namespace to append app's element ID (Mission, Task, ...). This variable needs trailing slash at the end.
- MF_GRAPH_URI : URI to identify RDF graph in MissionForest
- VIRTUOSO_ENDPOINT : endpoint to get LOD data in MissionForest and Tag system
- VIRTUOSO_USER : user which has the permission to edit Virtuoso RDF store
- VIRTUOSO_PASSWORD : password for VIRTUOSO_USER
- VIRTUOSO_UPDATE_ENDPOINT : endpoint to renew RDF store

### Migrate database
```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

## run the app
```bash
bundle exec rails server 
```

If you run the app in background
```bash
bundle exec rails server -d
```
