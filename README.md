ANSInception
============

Colorful exception handler for Node.js with CoffeeScript support and improved nodemon/supervisor compatibility

* Quits after a delay to prevent nodemon, supervisor, etc. from eating console.log output
* Show up to five lines of code from each entry in the stack trace
* Color codes the offending part of the code (based on the column number)
* Compiles CoffeeScript to show the actual offending code (otherwise the line numbers don't make sense)
* Highlights the file name in stack trace paths

Usage
-----

__CoffeeScript:__

	process.on 'uncaughtException', require 'ansinception'

__JavaScript:__

	process.on('uncaughtException', require('ansinception'));
