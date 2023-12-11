#Core Java

if running using interpredted mode $java FileName.java , the class containing psvm should be at the top or it will say psvm not found

if you dont want to handle the error or you want to funciton to throw a excepton, add "throws WhaeverException" in the funciton heading; otherwise it wont compile if it knows that the function is throwing an error.

if you dont override the "toString" method of child class, when printed e, format is "Packagename.ExceptionName: exception message pass to super(msg)" 
do better in core java