ANSInception
============

Colorful exception handler for Node.js with CoffeeScript support and improved nodemon/supervisor compatibility

![Screenshot](https://github.com/DennisKehrig/ANSInception/raw/master/screenshot.png)

Features
--------

* Quits after a delay to prevent nodemon, supervisor, etc. from eating console.log output sent shortly before the exception was thrown
* Shows up to five lines of code from each entry in the stack trace
* Color codes the offending part of the code (based on the column number)
* Compiles CoffeeScript to show the actual offending code (otherwise the line numbers don't make sense)
* Highlights the file name in stack trace paths
* Uses different colors depending on the location of the code
  (<span style="background-color:black;color:#0f0">green:</span> your code, <span style="background-color:black;color:#ff0">yellow:</span> local module, <span style="background-color:black;color:#f0f">pink:</span> global module/node.js internals)

Unfortunately registering with 'uncaughtException' has no effect until the next tick.
So in order to benefit from the exception handler right away, you need to postpone execution of your code.
You can either do this manually or use the convenience version (see below)

Usage with CoffeeScript
-----------------------

__Short version:__

	require('ansinception') ->
		# Your code

__Long version:__

	process.on 'uncaughtException', require 'ansinception'
	process.nextTick ->
		# Your code

Usage with JavaScript
---------------------

__Short version:__

	require('ansinception')(function() {
		// Your code
	});

__Long version:__

	process.on('uncaughtException', require('ansinception'));
	process.nextTick(function() {
		// Your code
	});
