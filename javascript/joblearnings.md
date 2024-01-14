## how learning things about javascript

how to serach in an array:
arr.indexOf()
if using objects insted of numbers

remove things from array at particula location
arr.splice(index, 1)]

javascript objects have a prototype property, which is either null or references another object. if we try to read a property in an object is its not present it the object it tries to read it from it's prototype.

we can set the prototype of an object by
```javascript
let p = {
	//come object
}
a.__proto__ = p
```