# Notes for SQL

`id = null` (wrong) : `id is null` (correct)



making sqlite3 db
```sql
sqlite3
.open mydatabase.db
CREATE TABLE Book (
    BookID INTEGER PRIMARY KEY AUTOINCREMENT,
    Title TEXT,
    Author TEXT,
    PublicationYear INTEGER
);
INSERT INTO Book (Title, Author, PublicationYear) VALUES
('Sample Book 1', 'Author 1', 2020),
('Sample Book 2', 'Author 2', 2018),
('Sample Book 3', 'Author 3', 2022);

.exit
```

```python
    # Use parameterized query to prevent SQL injection
    addBookQuery = 'INSERT INTO Book (Title, Author, Section) VALUES (?, ?, ?)'
    cursor.execute(addBookQuery, (bookTitle, bookAuthor, bookSection))
```