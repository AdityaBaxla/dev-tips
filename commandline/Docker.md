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

## Interactive shell in docker

```bash
docker exec -it new_postgres_db bash
```

# makind a pg server tables and data with the pg dump inside docker

It looks like the `.sql` file is not inside the container. You need to first copy the file into the container before running the command. Here’s how to fix it:

---

### **1️⃣ Copy the SQL File into the Container**
From your **host machine**, run:
```sh
docker cp mentorship.sql new_postgres_db:/mentorship.sql
```
This will copy `mentorship.sql` into the root directory (`/`) of the `new_postgres_db` container.

---

### **2️⃣ Verify the File is Inside the Container**
Run an interactive shell inside the container:
```sh
docker exec -it new_postgres_db bash
```
Then inside the container, check if the file exists:
```sh
ls -l /
```
If it’s not in `/`, you may need to check inside another directory like `/var/lib/postgresql/`.

---

### **3️⃣ Run the SQL File Inside the Container**
Once confirmed, execute the `.sql` file using:
```sh
docker exec -i new_postgres_db psql -U newuser -d mentorship-dump -f /mentorship.sql
```

---

### **4️⃣ Alternative: Directly Load from Your Host**
If you don’t want to copy the file, you can also run:
```sh
cat mentorship.sql | docker exec -i new_postgres_db psql -U newuser -d mentorship-dump
```

---

### **5️⃣ Verify That the Database is Created**
After execution, connect to your database and check:
```sh
psql -h localhost -p 5433 -U newuser -d mentorship-dump
```
Then list tables:
```sql
\dt
```

Great! Since you can see the `mentorship.sql` file inside the container, you should be able to execute it with `psql`.  

### **Run the SQL File**
Inside your host machine (not inside the container), execute:  
```sh
docker exec -i new_postgres_db psql -U newuser -d mentorship-dump -f /mentorship.sql
```
This will run the `.sql` file and create the necessary database objects.

---

### **Alternative: Run from Inside the Container**
If you're already inside the container (using `docker exec -it new_postgres_db bash`), you can run:  
```sh
psql -U newuser -d mentorship-dump -f /mentorship.sql
```

---

### **Verify Database Import**
Once the command runs successfully, check if the tables were created by connecting to the database:  
```sh
psql -U newuser -d mentorship-dump
```
Then list the tables:  
```sql
\dt
```

If you get any errors, let me know! 🚀

### Load data
```bash
docker exec -it new_postgres_db psql -U newuser -d postgres -c "CREATE DATABASE \"mentorship-dump\" OWNER newuser;"
```

### start a container
```bash
docker start new_postgres_db

```