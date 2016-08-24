#!/bin/bash

run: psen.sh singleprocess.sh batchprocess.sh config.sh
	time ./psen.sh 1> log/out.dat 2> log/err.dat &

clean: clean.sh
	./clean.sh
