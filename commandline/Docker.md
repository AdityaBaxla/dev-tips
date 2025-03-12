How to get postgress data from pg running on docker

You can find the container name, username, and database name using the following methods:

### **1. Get the Container Name**
Run this command to list all running Docker containers:
```bash
docker ps
```
You'll see an output similar to this:
```
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         NAMES
a1b2c3d4e5f6   postgres    "docker-entrypoint.s…"   10 minutes ago Up 10 minutes  my_postgres_container
```
The last column (`NAMES`) is your container name (`my_postgres_container` in this example).

---

### **2. Get the Database Name and Username**
Once you have the container name, you can check the environment variables inside the container:

```bash
docker exec -it <container_name> env | grep POSTGRES
```
Example:
```bash
docker exec -it my_postgres_container env | grep POSTGRES
```
You'll see something like:
```
POSTGRES_DB=my_database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secret_password
```
- **POSTGRES_DB** → Database name (`my_database`)
- **POSTGRES_USER** → Username (`postgres`)

---

### **3. Check Inside the Container**
If the environment variables are not set explicitly, you can enter the container and check manually:

```bash
docker exec -it my_postgres_container bash
```
Then access `psql` with the default PostgreSQL user:
```bash
psql -U postgres
```
Once inside, list all databases:
```sql
\l
```
And list all users:
```sql
\du
```


You can check your PostgreSQL database table values without using pgAdmin by using the following methods:

### 1. **Use `psql` inside the Docker container**
Run the following command to access the PostgreSQL container:

```bash
docker exec -it <container_name> psql -U <username> -d <database_name>
```
Example:
```bash
docker exec -it my_postgres_container psql -U postgres -d my_database
```

Once inside the `psql` shell, you can run:
```sql
\dt   -- List all tables
SELECT * FROM <table_name>;  -- View table contents
```

### 2. **Use `docker exec` with SQL query**
You can directly execute SQL queries from your terminal:

```bash
docker exec -it <container_name> psql -U <username> -d <database_name> -c "SELECT * FROM <table_name>;"
```
Example:
```bash
docker exec -it my_postgres_container psql -U postgres -d my_database -c "SELECT * FROM users;"
```

### 3. **Use `pgcli` (Optional)**
If you prefer a better CLI experience with auto-completion and syntax highlighting, install `pgcli`:

```bash
pip install pgcli
pgcli -h localhost -p 5432 -U postgres -d my_database
```

# create a new Postgres container inside docker

```bash
docker run --name new_postgres_db \
  -e POSTGRES_USER=newuser \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=db_name \
  -d -p 5433:5434 postgres
```
change the names and ports and necessary