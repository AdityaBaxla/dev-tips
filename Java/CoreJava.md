#Core Java

if running using interpredted mode $java FileName.java , the class containing psvm should be at the top or it will say psvm not found

if you dont want to handle the error or you want to funciton to throw a excepton, add "throws WhaeverException" in the funciton heading; otherwise it wont compile if it knows that the function is throwing an error.

if you dont override the "toString" method of child class, when printed e, format is "Packagename.ExceptionName: exception message pass to super(msg)" 
do better in core java yes no

cloneable: a unique function in java
-can expand visibility
-can only be used in try catch block
-can only implement when implements Clonable
-should throw CloneNotSupportedException

Date obj  (dose_two.getTime() - dose_one.getTime() ) / (1000*60*60*24)
### check if java stream is empty?
```java
public boolean isEmpty(Stream<Student> st) {
        return (st.count() == 0);
    }
```

dont use == for String comparision ... use .equals

see this code before exam:
```java
try {
            i_arr[i] = v;
        }catch(ArrayIndexOutOfBoundsException e1) {
            InvalidInputEx e2 = new InvalidInputEx("invalid index input");
            e2.initCause(e1);
            throw e2;
        }
```

if implementing Comparable interface, we should override compareTO and equals method
```java
public int compareTo(T o);

```
actually after seeing the code, we just need the compareTo method

### how to actually implement comparable 
```java
 @Override
    public int compareTo(Student other) {
        return Integer.compare(this.marks, other.marks);
    }
```