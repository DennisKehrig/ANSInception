process.on 'uncaughtException', require 'ansinception'
process.nextTick ->
	upper = require './lib'
	console.log upper("I like turtles")
	console.log upper()
