How to deploy the MissionForest on-premise
===
## Install dependencies
- ruby 2.6.3
    - recommend installing ruby using [rbenv](https://github.com/rbenv/rbenv)
- Web server (Nginx, Apache, ...)
    - to serve static content and proxy
- Node.js v14
    - recommend installing node using [nodenv](https://github.com/nodenv/nodenv)
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

bundle install --path vendor/bundle --without test development
```

generate `.env.production.local` and `credentials.yml.enc`
```bash
cp .env.production.local.template .env.production.local

# Generate a config/credentials.yml.enc
EDITOR=vi bundle exec rails credentials:edit
```

Open `.env.production.local` and modify below variable

below variable is about mail setting
- G_MAIL_USERNAME : Gmail Account
- G_MAIL_PASSWORD : Gmail Account password
- SITE_URL : Web site URL where MissionForest can serve
- SITE_PORT : Web site PORT where MissionForest can serve

below variable is about MySQL, Redis
- MYSQL_HOST : MySQL Host (default 127.0.0.1)
- MYSQL_PORT : MySQL PORT (default 3306)
- MYSQL_USER : MySQL User
- MYSQL_PASSWORD : MySQL Password
- MYSQL_DATABASE : MySQL Database Name
- REDIS_HOST : Redis host (default 127.0.0.1)
- REDIS_PORT : Redis port (default 6379)

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
bundle exec rails db:create RAILS_ENV=production
bundle exec rails db:migrate RAILS_ENV=production
```

### Precompile assets
```bash
bundle exec rails assets:precompile RAILS_ENV=production
```

### Set up the proxy server
You have to set up the proxy server to be told to proxy traffic to the running Puma instances. 
In this section I write the proxy server setting about Nginx.  
```bash
cd /etc/nginx/sites-available
sudo touch MissionForest
```
Open `MissionForest` and modify below setting, 
```
# this setting is about MissionForest

upstream MissionForest {
    server localhost:8000;
}

map $http_upgrade $connection_upgrade {
    default Upgrade;
    ''      close;
}

server {
        listen 80;
        listen [::]:80;

        server_name mf.com;

        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Port $server_port;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://MissionForest;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_read_timeout 900s;
        }
        
        location /assets/ {
            # MissionForest's Asset files - amend as required
            # default MissionForest_ROOT/public/assets/
            alias /path/to/your/MissionForest/ASSETS_ROOT/;
        }
}
```
Symlink to this file from /etc/nginx/sites-enabled so nginx can see it, and Restart nginx:
```bash
sudo ln -s /etc/nginx/sites-available/MissionForest /etc/nginx/sites-enabled/MissionForest
sudo nginx -s reload
```

## run the app
```bash
bundle exec rails server -p 8000 -e production
```

If you run the app in background
```bash
bundle exec rails server -p 8000 -e production -d
```