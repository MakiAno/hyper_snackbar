#!/bin/bash 

echo  "Running Flutter tests..." 

if [ " $1 " = "--coverage" ]; then
     flutter test --coverage 
    echo  "Deleting excluded files..."
     lcov -r coverage/lcov.info "lib/**.g.dart" -o coverage/lcov.info 
    echo  "Generating html file..."
     genhtml coverage/lcov.info -o coverage/html 
else
     flutter test 
fi