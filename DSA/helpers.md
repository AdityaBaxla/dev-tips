using key with lambda
```py
        operation_map = {
            '+':lambda x, y: x+y, 
            '-':lambda x, y: x-y, 
            '*':lambda x, y: x*y, 
            '/':lambda x, y: int(x/y)
            }
```

```py
        assorted = sorted([(x,y) for x,y in zip(position, speed)], key=lambda x: x[0], reverse=True)
    sorted(zip(position, speed), key=lambda x: x[0], reverse = True)
```