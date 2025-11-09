Perfect — let's build a **compact but complete primer** on **Linux shell scripting** (specifically **Bash**, since it's the most common).
This will cover **everything you need to start writing real scripts** — variables, loops, conditionals, functions, I/O, and more — like a programmer approaching Bash.

---

# 🐧 **Linux Shell Scripting Basics**

## 1️⃣ What is a Shell Script?

A **shell script** is simply a **text file** containing Linux commands executed in order by a shell (like `bash`).

Example:

```bash
#!/bin/bash
echo "Hello, World!"
```

> The first line `#!/bin/bash` is called a **shebang** — it tells the system to use Bash to run the script.

---

## 2️⃣ Variables

Variables in Bash **don’t require type declarations**.

### 🧠 Defining & Using Variables

```bash
name="Whatever"
age=25
echo "My name is $name and I am $age years old."
```

> ⚠️ **No spaces** around `=` in assignment (`name = "Whatever"` ❌).

### 🔒 Read-only Variables

```bash
readonly pi=3.14
```

### 🧩 Command Substitution

```bash
today=$(date)
echo "Today is $today"
```

---

## 3️⃣ Input and Output

### 🖊️ Read Input

```bash
read -p "Enter your name: " user
echo "Hi $user!"
```

### 🧾 Output

```bash
echo "This is an output"
echo -e "Line1\nLine2"   # -e enables escape sequences
```

---

## 4️⃣ Conditionals

### ⚙️ if-else structure

```bash
if [ $age -ge 18 ]; then
    echo "Adult"
elif [ $age -ge 13 ]; then
    echo "Teen"
else
    echo "Child"
fi
```

### ✅ Comparison Operators

| Type    | Operator | Meaning               |
| ------- | -------- | --------------------- |
| Numeric | `-eq`    | equals                |
|         | `-ne`    | not equals            |
|         | `-lt`    | less than             |
|         | `-le`    | less than or equal    |
|         | `-gt`    | greater than          |
|         | `-ge`    | greater than or equal |
| String  | `=`      | equals                |
|         | `!=`     | not equals            |
| File    | `-e`     | exists                |
|         | `-d`     | is directory          |
|         | `-f`     | is regular file       |

Example:

```bash
if [ -f "/etc/passwd" ]; then
    echo "File exists!"
fi
```

---

## 5️⃣ Loops

### 🔁 For Loop

```bash
for i in 1 2 3 4 5; do
    echo "Number $i"
done
```

Using a range:

```bash
for i in {1..5}; do
    echo "Iteration $i"
done
```

Looping over files:

```bash
for file in *.txt; do
    echo "Processing $file"
done
```

---

### 🔁 While Loop

```bash
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

---

### 🔁 Until Loop

```bash
x=1
until [ $x -gt 5 ]; do
    echo "x=$x"
    ((x++))
done
```

---

## 6️⃣ Functions

### 🧮 Define and Call Functions

```bash
greet() {
    echo "Hello, $1!"
}

greet "Whatever"
```

> `$1`, `$2`, etc. are **positional parameters** (arguments passed to the function).

---

## 7️⃣ Arrays

### 📦 Declare and Access

```bash
fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"
echo "${fruits[@]}"     # all elements
echo "${#fruits[@]}"    # number of elements
```

---

## 8️⃣ Arithmetic

### ➕ Basic Arithmetic

```bash
a=5
b=3
sum=$((a + b))
echo "Sum = $sum"
```

### 🔢 Increment/Decrement

```bash
((a++))
((b--))
```

---

## 9️⃣ String Operations

```bash
str="hello world"
echo ${#str}           # length
echo ${str:0:5}        # substring
echo ${str/world/universe}   # replace
```

---

## 🔟 File Handling

```bash
echo "some data" > file.txt    # overwrite
echo "more data" >> file.txt   # append

cat file.txt                   # view
rm file.txt                    # delete
```

Loop through file lines:

```bash
while IFS= read -r line; do
    echo "Line: $line"
done < file.txt
```

---

## 1️⃣1️⃣ Exit Codes

Every command has an **exit status** (`0` = success, non-zero = failure).

```bash
if ls /etc > /dev/null; then
    echo "Command succeeded"
else
    echo "Command failed"
fi
```

Or directly:

```bash
echo $?
```

---

## 1️⃣2️⃣ Script Arguments

When you run a script like:

```bash
./myscript.sh arg1 arg2
```

You can access:

```bash
echo "First: $1"
echo "Second: $2"
echo "All: $@"
echo "Count: $#"
```

---

## 1️⃣3️⃣ Case Statements

### 🔤 Example:

```bash
read -p "Enter choice (y/n): " choice

case $choice in
    y|Y) echo "You chose yes" ;;
    n|N) echo "You chose no" ;;
    *) echo "Invalid choice" ;;
esac
```

---

## 1️⃣4️⃣ Error Handling (set options)

```bash
set -e   # Exit if any command fails
set -u   # Treat unset variables as error
set -o pipefail  # Fail if any part of pipeline fails
```

---

## 🧩 Putting It All Together

```bash
#!/bin/bash
# Simple backup script

backup_dir="/tmp/backup"
mkdir -p "$backup_dir"

for file in *.txt; do
    if [ -f "$file" ]; then
        cp "$file" "$backup_dir/"
        echo "Copied $file"
    else
        echo "No text files found!"
        exit 1
    fi
done

echo "Backup completed!"
```

---

## ⚡ Useful Extras

| Feature                  | Example                            |             |
| ------------------------ | ---------------------------------- | ----------- |
| **Command substitution** | `files=$(ls)`                      |             |
| **Subshell**             | `(cd /tmp && ls)`                  |             |
| **Pipes**                | `ls                                | grep ".sh"` |
| **Redirection**          | `command > out.txt 2> err.txt`     |             |
| **Cron jobs**            | Schedule scripts with `crontab -e` |             |

---

Would you like me to make a **ready-to-run practice sheet** (like a `.sh` file with small fill-in exercises for each concept — variables, loops, conditionals, etc.) so you or students can actually practice step-by-step?
