#!/bin/sh -e

dir=screenfetch-split
script=screenfetch-dev

rm -rf $dir
mkdir -p $dir
cd $dir

# split ASCII arts from the actual script
csplit -s ../$script '/@ASCII_ARTS_/' '{*}'
mv xx00 ${script}_part1
echo '#@ASCII_ARTS_BEGIN@' >> ${script}_part1
mv xx01 aa
mv xx02 ${script}_part2

# split ASCII arts into individual files
sed -i '/#@ASCII_ARTS_BEGIN@/d; s/^[ \t]*$//; /^$/d' aa
csplit -s -z aa '/;;$/'1 '{*}' && rm aa

# rename files
for f in xx* ; do
	name=$(head -n1 $f | cut -d '"' -f2 | sed 's/ /_/g; s/\//_/g')
	mv $f aa_$name
	echo "" >> aa_$name
done


# merge.sh
cat << EOF > merge.sh
#!/bin/sh -e

script=screenfetch-dev

cp \${script}_part1 \${script}
# use "cat \`ls aa_*\`" instead of "cat aa_*" to ignore case pattern
cat \`ls aa_*\` \${script}_part2 >> \${script}
chmod a+x \${script}
EOF
chmod a+x merge.sh


# source.sh
cat << EOF > source.sh
#!/bin/sh -e

if [ x"\${1}" = x ]; then
    prefix=/usr/share/screenfetch
else
    prefix="\${1}"
fi

script=screenfetch-dev

cp \${script}_part1 \${script}
sed -i "s@asciiText () {@asciiText () {\n\tprefix=\"\${prefix}\"@" \${script}

for f in \`ls aa_*\`; do
	printf "\t\t" >> \${script}
    head -n1 \${f} | sed 's/^[ \t]*//' >> \${script}
    echo "\t\t\tsource \"\\\${prefix}/\${f}\" ;;" >> \${script}
    tail -n+2 \${f} | head -n-2 > \${f}.new
    rm \${f} && mv \${f}.new \${f}
done

cat \${script}_part2 >> \${script}
sed -i '/@ASCII_ARTS_/d' \${script}
chmod a+x \${script}
EOF
chmod a+x source.sh
