# ciesin
Data processing & analysis tools in ciesin

## Sentinel 1 Streaming & Processing Tools

Batch scripts for streaming & processing sentinel data (currently for sentinel 1 only). Each repo has own README file for user guidance.

## Repo

dsen/: Batch Downloading scripts

psen/: Sentinel data processing scripts

tasks/: storage of tasks (each in one script) that uses programs written in dsen & psen for automatic data flow

run\_tasks.sh: unfied script calls every script under tasks/ folder with postfix ".sh"

log: log repo for running scripts under tasks/ folder called by run\_tasks.sh

todo.txt: dev log
