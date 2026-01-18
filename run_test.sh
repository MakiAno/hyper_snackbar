#!/bin/bash 

echo  "Flutterテスト実行中..." 

if [ " $1 " = "--coverage" ]; then
     flutter test --coverage 
    echo  "除外されたファイルを削除..."
     lcov -r coverage/lcov.info "lib/**.g.dart" -o coverage/lcov.info 
    echo  "htmlファイルを生成しています..."
     genhtml coverage/lcov.info -o coverage/html 
else
     flutter test 
fi