# mariaDB-teleport
MariaDB with Teleport Agent for https://goteleport.com/docs/database-access/guides/mysql-self-hosted/

# How to Use
Data Dir of mysql server /var/lib/mysql

## Use with Teleport
Create a Token for Connection with Teleport Proxy
```bash
tctl tokens add --type=db
```

### Create Config for Teleport
you will get a output with something like this
```bash
teleport db configure create \
   --token=YOUR TOKEN \
   --ca-pin=YOUR CA PIN \
   --proxy=PROXY NODE \
   --name=NAME YOUR DB \
   --protocol=mysql \
   --uri=localhost:3306 \
   --output teleport.yaml
```
Copy or Bind teleport.yaml to /etc/teleport.yaml
Bind a Data Folder for Teleport on /var/lib/teleport it will store the
- host_uuid
- proc
- log

### Create Certs for DB Connection over Teleport Proxy
Generate Certs with Teleport Agent or on Teleport Node, Certs will be valid for 3 Monthes if not less or big change --ttl
```bash
tctl auth sign --format=db --host=localhost --out=server --ttl=2190h
```

Copy or Bind a Folder with the Files to /certs/
- server.crt
- server.key
- server.cas

Start Docker Container here

### Create User or Update Existing ones
If you're creating a new user:
```sql
CREATE USER 'alice'@'%' REQUIRE SUBJECT '/CN=alice';
```

If you're updating an existing user:
```sql
ALTER USER 'alice'@'%' REQUIRE SUBJECT '/CN=alice';
```

By default, the created user may not have access to anything and won't be able to connect, so let's grant it some permissions:
```sql
GRANT ALL ON `%`.* TO 'alice'@'%';
```
