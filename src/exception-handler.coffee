fs				= require 'fs'
# CoffeeScript is lazy loaded, so it's only a requirement if you actually use it yourself
coffee			= null

# ANSI color madness
# http://en.wikipedia.org/wiki/ANSI_escape_code
ansi			= (args...) -> "\x1B[" + args.join(';') + "m"

reset			= ansi 0
bright			= ansi 1, 1
normal			= ansi 1, 22

red				= ansi 1, 31
green			= ansi 1, 32
yellow			= ansi 1, 33
blue			= ansi 1, 34
magenta			= ansi 1, 35
cyan			= ansi 1, 36
white			= ansi 1, 37

darkRed			= red		+ normal
darkGreen		= green		+ normal
darkYellow		= yellow	+ normal
darkBlue		= blue		+ normal
darkMagenta		= magenta	+ normal
darkCyan		= cyan		+ normal
darkWhite		= white		+ normal

brightRed		= red		+ bright
brightGreen		= green		+ bright
brightYellow	= yellow	+ bright
brightBlue		= blue		+ bright
brightMagenta	= magenta	+ bright
brightCyan		= cyan		+ bright
brightWhite		= white		+ bright

# Configuration
baseColor		= brightWhite
extraLines		= 2
delayExit		= 1000

# Two formats for the stack trace:
# at <context> (<path>:<line>:<column>)
format1 = /^\s*at (.*) \(([^\)]+):(\d+):(\d+)\)$/
# at <path>:<line>:<column>
format2 = /^\s*at ()([^\)]+):(\d+):(\d+)$/
# The exception handler

exports = module.exports = (callback) ->
	if callback instanceof Error
		exports.handler callback
	else
		process.on 'uncaughtException', exports.handler
		process.nextTick callback

exports.handler = (exception) ->
	
	# Start off with how the app was started in the first place
	console.log "\n#{baseColor}      ,-- $ #{brightCyan}#{process.argv.join ' '}#{reset}"
	
	# Split the stack into lines
	stack = exception.stack.split "\n"
	
	# Collect the lines with the error message
	messageLines = []
	for entry in stack
		break if entry.match(format1) or entry.match(format2)
		messageLines.push entry
	
	# Remove the message lines from the stack
	stack.splice 0, messageLines.length
	
	# Print the stack chronologically
	for entry in stack.reverse()
		# Try to recognize the format
		if entry.match(format1) or entry.match(format2)
			# Crashing exception handlers suck, right?
			try
				# Context, File, Line, Column
				logStackEntry RegExp.$1, RegExp.$2, RegExp.$3, RegExp.$4
			catch err
				console.log "Error while printing offending stack entry:"
				console.log err.stack
		# Just dump the line if we don't recognize it
		else
			console.log "#{baseColor}      `-> #{entry}#{reset}"
	
	errorStyle = "#{darkRed}|#{brightWhite} "

	console.log "#{baseColor}      v#{reset}"
	console.log "#{darkRed},---------------------------------------------------------------------------#{reset}"
	console.log "#{errorStyle}" + messageLines.join "\n#{errorStyle}"
	console.log "#{darkRed}`---------------------------------------------------------------------------#{reset}"
	
	# Delay exiting when an exception occurs so console.log calls that occured
	# just before the error are also printed by nodemon, supervisor, etc.
	setTimeout ->
		process.exit 1
	, delayExit

logStackEntry = (context, file, lineNumber, columnNumber) ->
	# Working directory
	cwd = process.cwd()
	# Regular expression to recoginize the current working directory
	cwdPattern = new RegExp escapeRegExp(cwd)+'[\\/\\\\]'
	
	# Use different colors for the file and offending line depending on the code location
	[darkColor, brightColor] = if file.slice(0, cwd.length) isnt cwd
		# Node.js internal or global library
		[darkMagenta, brightMagenta]
	else if file.slice(cwd.length + 1, cwd.length + 13) is 'node_modules'
		# Local library
		[darkYellow, brightYellow]
	else
		# Own code
		[darkGreen, brightGreen]
	
	# Make the file name brighter than the rest of the path
	coloredFile = darkColor + file.replace(cwdPattern, '').replace(/([^\/\\]+)$/, brightColor + '$1')
	# The context isn't always defined
	wrappedContext = if context then " (#{context})" else ''
	
	# Print the stack entry
	console.log "#{baseColor}      `-> #{coloredFile}#{baseColor}#{wrappedContext}#{reset}"

	# Try to read the code
	try
		code = fs.readFileSync(file, "ascii")
	catch err
		# Just skip to the next stack entry if the source isn't found
		return if err.code == 'ENOENT'
		throw err
	
	# Compile CoffeeScript so the line number makes sense
	coffee ?= require 'coffee-script'
	code = coffee.compile code if file.match /\.coffee$/
	# Split the code into lines
	lines = code.split "\n"
	# Turn line into an index
	lineIndex = lineNumber - 1
	
	# Read two lines before and after the offending one
	for i in [(lineIndex-extraLines)..(lineIndex+extraLines)]
		continue if i < 0
		break if i >= lines.length
		
		numColor = darkWhite
		num = padLeft(i+1, ' ', 5)
		line = lines[i]
		
		if i < lineIndex
			sep = '   '
		else if i is lineIndex
			sep = ',--'
			numColor = brightRed
			line = darkColor + line.slice(0, columnNumber-1) + brightColor + line.slice(columnNumber-1) + reset
		else if i > lineIndex
			sep = '|  '
		
		console.log "#{numColor}#{num} #{baseColor}#{sep}#{reset} #{line}#{reset}"

# Make a string safe to be used in a regular expression
# http://simonwillison.net/2006/Jan/20/escape/#p-6
escapeRegExp = (text) ->
    text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")

# '****123' is padLeft('123', '*', 7)
padLeft = (string, fill, length) ->
	string = String(string)
	string = fill + string while string.length < length
	return string

