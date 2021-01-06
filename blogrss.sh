#!/bin/bash

DIRECTORY="pages/blog"

FILES=`ls $DIRECTORY/*.md -1 | sort`

RETURNDATE=""

# date is read from the 3rd %ed line of the document or from the git commit date
function getdate {

	FILEDATE=`grep "^%" $1 | sed '3q;d' | cut -d ' ' -f 2-`
	
	if [ $? -eq 0 ]; then
	FTIME=`date -u --date="$FILEDATE" "+%s"`
	else
		RETURNDATE=0
		return 1
	fi

	if [ $? -eq 0 ]; then
		RETURNDATE=$FTIME
		return 0
	else
		RETURNDATE=0
		return 0
	fi
}

echo -n > blogdates.txt
for f in $FILES; do
	getdate $f
	printf "%d\t%s\n" $RETURNDATE $f >> blogdates.txt
done

# resort by last git commit time
FILES=`cat blogdates.txt | sort -nr | cut -f 2-`

cat << RSSHEADER
<?xml version="1.0" encoding=\"UTF-8\" ?>
<rss version="2.0">
<channel>
<title>rnd's blog</title>
<link>https://rnd.neocities.org/blog</link>
<description>The RSS feed of articles published on the blog thingy</description>
RSSHEADER

for f in $FILES; do

	getdate $f
	MTIME=$RETURNDATE

	TITLE=`head -n 1 $f`
	TITLE=${TITLE#"% "}

	OUTPAGE=${f%.md}.html
	OUTPAGE=/${OUTPAGE#pages/}


	echo "<item>"
	echo "<title>$TITLE</title>"
	echo "<link>$OUTPAGE</link>"
	
	if [ $MTIME -gt 0 ]; then
		echo "<pubdate>`date -R -u -d \"@$MTIME\"`</pubdate>"
	fi
	echo "</item>"
done

cat << RSSFOOTER
</channel>
RSSFOOTER
