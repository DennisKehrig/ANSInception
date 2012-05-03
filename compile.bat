@echo off
call coffee -c src\exception-handler.coffee
move src\exception-handler.js lib