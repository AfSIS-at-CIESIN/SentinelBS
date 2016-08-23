#! /bin/sh

/opt/S1TBX/jre/bin/java \
	-Xms512M -Xmx180555M \
    -Xverify:none -XX:+AggressiveOpts -XX:+UseFastAccessorMethods \
    -XX:+UseParallelGC -XX:+UseNUMA -XX:+UseLoopPredicate \
    -Dceres.context=s1tbx \
    "-Ds1tbx.mainClass=org.esa.beam.framework.gpf.main.GPT" \
    "-Ds1tbx.home=/opt/S1TBX" \
	"-Ds1tbx.debug=false" \
    "-Dncsa.hdf.hdflib.HDFLibrary.hdflib=/opt/S1TBX/libjhdf.so" \
    "-Dncsa.hdf.hdf5lib.H5.hdf5lib=/opt/S1TBX/libjhdf5.so" \
    -jar "/opt/S1TBX/bin/snap-launcher.jar" "$@"

exit $?
