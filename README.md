
## major work in progress:   

This is an attempt to make a dedicated interpreter for my hobby programming language [project dysnomia](https://github.com/return5/Project-Dysnomia)  
That project was using a simple text replacer which would simply replace dysnomaia code with equivalent lua code which would then get run through lua's interpreter.   
This is an attempt to create a standalone interpreter for it and to also further develop the language.  

## Language documentation:

[Dysnomia](https://en.wikipedia.org/wiki/Dysnomia_(moon)): adding syntax and features on top of Lua 5.4

- The stated goal of this project is to build on top of Lua 5.4 with new syntax, features, and enhancements.  
## requirements
- Lua >= 5.4
## features, syntax changed, and enhancements
- update operators [(please see update Ops section)](#UpdateOps)
    - ```+=```
    - ```-=```
    - ```/=```
    - ```*=```
- by default, all vars are local and const.
- ```var``` keyword. declares a variable.
    - ``var myVariable``
- ```global``` keyword. declares a variable, Record, or function to not be local
    - ```var myVar <global> = 5```
    - ``global function myFunc() return 5 end``
    - ``global Record myRecord``
- ```mutable``` keyword. declares a variable is mutable.
    - ```var myVar <mutable> = 6```
- ```class``` keyword. declares a class. [(please see class section)](#class)
    - ```class myClass(var1,var12,var3) endCLass```
- ```:>``` used to declare inheritance of class. [(please see class section)](#class)
    - ```class childClass() :> parentClass endClass```
- ```super()``` calls parent constructor inside of class. [(please see class section)](#class)
    - ``super(var1,var2)``
- ``record`` immutable collection for holding data. [(please see records section)](#records)
    - ```record MyRecord(a,b,c,d) endRec```
- ``lambdas`` shorthand syntax for declaring an anonymous function. [(please see lambda section)](#lambda)
    - ``a -> a + 5``

## UpdateOps
assigns the value of the right hand expression, the math operator in front of the equals sign, and the variable on the left to the variable.  
```i += 1```
- equivalent to:
  ```i = i + 1```

can assign to more than one var at a time: ```i,j += 1,2```
- equivalent to ```i = i + 1; j = j + 2```

if there are more variables on the left hand side than on the right hand side, then the last variable on the right hand side is repeated:
```i,j,k += 1```
- is equivalent to: ```i = i + 1; j = j + 1; k = k + 1```

if the repeated value on the right hand side is a function call, then it will be called only once, assigned to a variable, then that variable is used in its place.  
```i,j,k += returnFive()```
- is equivalent to: ```local __temp1 <const> = returnFive(); i = i + __temp1; j = j + __temp1; k = k + __temp1```


## class
offers class declaration inspired by java records.  
basic syntax is: class keyword followed by class name.  
then include any parameters to pass into constructor and a parent class if it is a child class.  
finally, close with ``endClass``:    
```class MyChildClass(param1,param2) :> MyParentClass endClass```
- if no constructor is provided, then one will be created automatically.
- ``constructor`` declares a class constructor.
    - ```constructor(param1,param2) end```
- ``super`` calls the parent constructor. needs to be included if you include a constructor and class has a parent class.
    - ``super(param1)``
- you may declare class methods inside the class:
    - ```method myMethod(a,b) end```
- ``static`` declares a method to be static rather than an instance method.
    - ```static method myMethod()```
- to access class variables you use the ```self``` keyword
    - ```self.myVar = 6```
- ```self``` is not needed when accessing class methods
    - ```myMethod(5,6)```
        - translates to: ```self:myMethod(5,6)```
- ```:>``` used in class declaration to declare a parent class.
- new objects can be instantiated from class by calling the ``new`` function on the class.
    - ```var myObj = MyClass:new(var1,var2)```
- ``local`` declares a function to be local.
    - ```local function myFun(a,b) end```
- ``global`` declares that a function is global in scope.
    - ``global function myFunc(a,b) end``
- ``metamethod`` declares a metamethod on the class
    - the metamethods are the standard metamethods for lua objects.
    - ``metamethod add(c1,c1) return c1.a + c2.a end``

## records
An immutable object for storing data. declare the number and names of the parameters. call it like a function to generate objects from it.
````  
record MyRecord(a,b) endRec
var rec = MyRecord(5,6)
````
- by default records are local.
- unlike classes, they do not have to be declared inside their own file.
- like classes, they can have methods,metamethods, and constructors.
    - unlike classes, record constructors take in no parameters. they use the parameters used in the record declaration.
        - ```constructor() self.a = a end```
- records can be declared global
    - ``global record MyRec(c,d) endRec``

## lambda
A shorthand syntax for declaring an anonymous function.
- a single parameter, single statement can be declared as:
    - ```a -> a+5```
    - this is, a function which takes in one input 'a' and returns 'a' + 5.  equivalent to the lua code:
        - ``function(a) return a + 5 end``
    - for single input, no parenthesis are needed.
    - for single statement body, no brackets are used nor is 'return' used.


- a no parameter lambda can be declared as:
    - ```() -> 5```
    - this, a function which takes no input and returns the number 5.
    - for zero inputs, parenthesis must be used.


- multiple input lambda can be declared as:
    - ``(a,b) -> a+b``
    - that is, a function which takes two inputs and returns their values added together.
    - for multiple inputs, parenthesis must be used.


- multiple statement lambdas:
    - ```(a,b) -> { if a < 5 then return b end return a}```
    - a function which takes in two inputs, if the first is less than 5 then return second input, otherwise return the first argument.
    - for multi-statement lambdas, curly brackets and 'return' statement must be used.
