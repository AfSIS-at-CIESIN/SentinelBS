export INPUT_FILE=product_list

export DOWNLOAD=' while : ; do
	if [[ -s $ZIP/${3}".zip" ]]; then
		echo "Product ${3} already downloaded, skip"
		break
	fi

	echo "Downloading product ${3} from link ${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/\$value"; 
        ${WC} ${AUTH} -nc  --progress=dot -e dotbytes=10M -c --output-file=./$LOGS/log.${3}.log -O $ZIP/${3}".zip" "${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/\$value";
	test=$?;
	if [ $test -eq 0 ]; then
		echo "Product ${3} successfully downloaded at " `tail -2 ./$LOGS/log.${3}.log | head -1 | awk -F"(" '\''{print $2}'\'' | awk -F")" '\''{print $1}'\''`;
		remoteMD5=$( ${WC} -qO- ${AUTH} -c "${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/Checksum/Value/$value" | awk -F">" '\''{print $3}'\'' | awk -F"<" '\''{print $1}'\'');
		# openssl: crytograph toolkit
		localMD5=$( openssl md5 $ZIP/${3}".zip" | awk '\''{print $2}'\'');
		localMD5Uppercase=$(echo "$localMD5" | tr '\''[:lower:]'\'' '\''[:upper:]'\'');
		#localMD5Uppercase=1;
		if [ "$remoteMD5" == "$localMD5Uppercase" ]; then
			echo "Product ${3} successfully MD5 checked";
		else
		echo "Checksum for product ${3} failed";
		echo "${0} ${1} ${2} ${3}" >> .failed.control.now.txt;
		if [ ! -z $save_products_failed ];then  
		      rm $ZIP/${3}".zip"
		fi
		fi; 
        break;
	else
		echo "Product ${3} timeout during download, try again after ${SLEEPTIME} s."
		# failed file must be removed
		rm -f $ZIP/${3}."zip"
		sleep $SLEEPTIME
	fi;
done '

cat ${INPUT_FILE} | xargs -n 4 -P ${THREAD_NUMBER} sh -c $DOWNLOAD

# MD5 check
CHECK_VAR=true

if [ ! -z $check_save_failed ]; then
    if [ -f .failed.control.now.txt ];then
    	mv .failed.control.now.txt $FAILED
    else 
    if [ ! -f .failed.control.now.txt ] && [ $CHECK_VAR == true ] && [ ! ISSELECTEDEXIT ];then
    	echo "All downloaded products have successfully passed MD5 integrity check"
