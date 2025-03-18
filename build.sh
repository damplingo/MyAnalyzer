mkdir -p out &&
bison --defines=out/expr.tab.h --output=out/expr.c --report='all' --report-file=out/report.txt ./files/expr.y &&
flex --outfile=out/lex.c ./files/expr.l &&
gcc -c ./files/ExceptInfo.c -g -o ./out/ExceptInfo.o &&
cp ./files/ExceptInfo.h ./out/ExceptInfo.h &&
gcc ./out/expr.c ./out/lex.c ./out/ExceptInfo.o -o ./out/exep -lm &&
echo "Run with: ./out/exep"
