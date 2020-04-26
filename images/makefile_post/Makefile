CC = gcc
CFlags = -g -Wall -Werror
CUnit = -lcunit

# Main
main: addition.o multiplication.o
	$(CC) $(CFlags) -o $@ $^

%.o: %.c %.h
	$(CC) $(CFlags) -c $<

# Tests
test: UnitTest.o addition.o multiplication.o
	$(CC) -o test $^ $(CUnit)
	./test
	make clean

# Checks
CppCheckMake: *.c *.h
	cppcheck --enable=all --inconclusive $^ 2> cppcheck.json

ValgrindMake: main.c
	valgrind --xml=yes --xml-file="valgrind.xml" --leak-check=yes --track-origins=yes ./main

allChecks:
	make main
	make CppCheckMake
	make ValgrindMake

# Cleaning
clean:
	rm main *.o
	rm -f *.xml  # Utile pour les fichier générer par valgrind et cppcheck
	# rm ...