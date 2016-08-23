A1=(1 2 3)
A2=(4 5 6)

for a in ${A1[@]}
do
	for b in ${A2[@]}
	do
		echo $a$b
	done
done

