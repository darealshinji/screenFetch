#!/bin/sh

dir=screenfetch-split
script=screenfetch-dev

rm -f $script

csplit -s ../$script '/@ASCII_ARTS_END@/' '{*}'
mv xx00 $script

for f in *.txt ; do
	distro="$(echo $f | sed 's/\.txt//g; s/_/ /g')"
	printf "\t\t\"$distro\")\n" >> $script
	cat $f | sed '/^$/d' >> $script
	printf "\t\t;;\n\n" >> $script
done

cat xx01 >> $script && rm xx01
chmod a+x $script

