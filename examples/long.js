process.on('uncaughtException', require('ansinception'));
process.nextTick(function() {
	upper = require('./lib');
	console.log(upper("I like turtles"));
	console.log(upper());
});
