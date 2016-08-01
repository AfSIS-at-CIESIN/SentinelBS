export FILE='test'
export COMMAND='wc -l'
cat $FILE | ${COMMAND}
cat $FILE | sh -c '$COMMAND'
