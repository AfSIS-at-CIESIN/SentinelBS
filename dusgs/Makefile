#!/bin/bash

run: dusgs.sh config.sh
	time ./dusgs.sh 1> log/out.dat 2> log/err.dat &

clean: clean_test.sh
	time ./clean_test.sh

runtest: dusgs.sh config.sh clean_test.sh
	./clean_test.sh
	time ./dusgs.sh
