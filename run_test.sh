#!/bin/bash

java -Xmx500M -cp "/usr/local/lib/antlr-4.9.3-complete.jar:$CLASSPATH" org.antlr.v4.Tool -Dlanguage=Python3 NewShLexer.g4
java -Xmx500M -cp "/usr/local/lib/antlr-4.9.3-complete.jar:$CLASSPATH" org.antlr.v4.Tool -Dlanguage=Python3 NewShParser.g4

python3 test.py foo.sh foo_bash.sh