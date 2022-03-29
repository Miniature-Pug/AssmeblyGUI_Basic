STILL EDITING THE README............





.386 :Enables assembly of non privileged instructions for the 80386 processor (32-bit micro processor: made in 1985 and using this header file enables instructions set of every processor after this).


model :the type of memory model that we will use. There are multiple types of model like flat, tiny, huge, compact, etc. We will use flat because 32-bit memory is flat.
Definition of flat: it is a model that is linear in design and memory appears to be a single continuous address space. 


std :call the standard 32-bit calling convention. 


option casemap:none :We want our varibles to be case insensitive 

.inc files are to assembly language what .h files are to C language. They contain function prototypes and structure defs. This is how the assembler and the linker know what arguments to take.


/lib files are used to link the binary to libraries and DLLs. Examples: Import descriptor tables, strings and other binary data that is needed to glue our code to the system APIs.
There are two types of library files. Static and dynamic. The libraries mentioned and imported here are dynamic. Basically, the functions and sorces are compiled into a .dll file and a separate .lib file is created
