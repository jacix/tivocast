#!/usr/bin/env bash
#
# $Id: build.podcasts.local.sh,v 1.18 2019/10/18 05:05:11 jason Exp $
# $Log: build.podcasts.local.sh,v $
# Revision 1.18  2019/10/18 05:05:11  jason
# Added mule
#
# Revision 1.17  2019/01/10 03:11:21  jason
# added CBS Sunday Morning
#
# Revision 1.16  2018/11/20 13:46:53  jason
# replaced Live With Katy Tur, with This Is Us
#
# Revision 1.15  2018/10/30 03:12:31  jason
# Fixed typo in test to see if xml files had changed ('==' needed to be '!=')
#
# Revision 1.14  2018/10/29 21:24:20  jason
# Added RCS log tag; detect sr71 or jumpman and set OS-specific variables; reformat date in logs; if running
# on sr71, copy files to jumpman
#
#
# Jason's podcast builder.  It writes podcasts for whatever it finds in $VIDEODIR
# To add another feed add a mp4 file match and xml/jpf file name to the case statement.
# Anything that doesn't match gets podcasted as adhoc.xml
# $BINDIR - where this script lives.
# $PODCASTDIR - where the xml files end up.
# $PODCASTDIR/images - Directory for the the RSS channel icons
# $VIDEODIR - source for the incoming mp4 and mp4.txt and workbench for new xml files
# Verify XML files with http://validator.w3.org/feed/
# ffprobe ./Up_W_Steve_Kornacki_Sun_Apr_19.mp4 3>&1 1>&2 2>&3 | grep Duration 

#set -x
# Determine where I'm running and set a few options:
#	Base of the podcast directory
#	date command
#	Whether to scp files to jumpman at the end
case $(uname -n) in
	sr71*)
		PODCASTDIR=/home/jason/Dropbox/Public
		DATECMD=/bin/date
		MOVE_FILES_AT_END=1
	;;
	mule*|jumpman*)
		PODCASTDIR=/usr/local/www/data/podcast
		DATECMD=/usr/local/bin/gdate
		unset MOVE_FILES_AT_END
	;;
	*)
		echo "I don't know what to do on $(uname -n). Exiting."
		exit 1
	;;
esac	

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:'

LOG=/home/jason/logs/podcast.log
ERRFILE=~/logs/$(basename $0).err.log

BINDIR='/home/jason/bin'
VIDEODIR="${PODCASTDIR}/video"
#URL='http://dl.dropbox.com/u/26177001'
URL=https://podcast.jasons.us
DEFLENGTH="60"

# You shouldn't have to change anything below this line other than the case statement for the shows

function write.channel () {
# Parameters: 
# $1 - Description/title
# $2 - jpg/xml file name

# Check to see if this channel has been written yet.  If not, erase the existing file,
# write the channel, add the filename to the array
for e in "${PODCASTS[@]}"; do
        [[ $e == $2 ]] &&  return
done

#rm ${PODCASTDIR}/$2.xml > /dev/null 2>&1
PODCASTS[$XMLFILES]=$2
let "XMLFILES++"

cat <<!
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    
   <channel>
   <title>${1}</title>
      <description>Jason's Podcast Of ${1}</description>
      <link>${URL}</link>
      <atom:link href="${URL}/${2}.xml" rel="self" type="application/rss+xml" />
      <language>en-us</language>
      <copyright>Copyright 2007</copyright>
      <lastBuildDate>Tue, 27 Sep 2011 02:50:00 -0500</lastBuildDate>
      <pubDate>$(${DATECMD} +"%a, %d %b %Y %H:%M:%S EST")</pubDate>
      <docs>http://blogs.law.harvard.edu/tech/rss</docs>
      <webMaster>podcasts@jasons.us (Podcast Master) </webMaster>
      <image>
         <url>${URL}/images/${2}.jpg</url>
         <title>${1}</title>
         <link>${URL}</link>
      </image>
!
}

function write.item () {
# Parameters:
# $1 - title
# $2 - link
# $3 - filename
# $4 - description
# $5 - size
# $6 - pub date
cat <<!
      <item>
         <title>${1}</title>
         <link>${URL}/${2}.xml</link>
         <guid isPermaLink="true">${URL}/video/${3}</guid>
         <description>${4}</description>
         <enclosure url="${URL}/video/${3}" length="${5}" type="video/mpeg" />
         <category>Podcasts</category>
         <pubDate>${6}</pubDate>
      </item> 

!
}

function write.footers () {
# Parameter: array containing the names of new xml files.
   for output; do
      {
      echo "   </channel>"
      echo "</rss>" 
      } >> $VIDEODIR/$output.xml
      shift
   done
}

function cleanexit () {
	echo "$(${DATECMD} +%Y%m%d.%H%M.%S-%A): build finished" >> $LOG
	exit
}

# main
if [[ $# == "0" ]]; then
   INPUT=""
elif [[ $1 == "-h" ]]; then
cat <<!
   Usage:
     $0 with no parameters builds all xml files.
     $0 -h = this help.
     $0 with any parameters, other than '-h', builds xml for ls *${PARAMETERS}*mp4
   Exiting
!
   exit
else
   INPUT="$@"
fi

echo "$(${DATECMD} +%Y%m%d.%H%M.%S-%A): build start" >> $LOG
cd $VIDEODIR
rm -f $VIDEODIR/*xml
XMLFILES=0
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Commented out since this is now only called when the generator host copies files here.
# Check to see if I have anything new to do
#NEWESTVID=$(ls -tr ${VIDEODIR}/*${INPUT}*.mp4 | tail -1)
#NEWESTXML=$(ls -tr ${PODCASTDIR}/*${INPUT}*.xml | tail -1)
#if test ${NEWESTXML} -nt ${NEWESTVID}; then
#	echo " XML files are newer than videos. No work to do. Exiting." >> ${LOG}
#	cleanexit
#fi 

for file in *${INPUT}*.mp4;  do
#   DESCRIPTION=`grep description $file.txt | awk -F\: '{print $2}' | sed s///`
#   DESCRIPTION=`grep description $file.txt | awk -F: '{ sub(//, ""); print $2}'`
#   SERIESTITLE=`grep seriesTitle $file.txt | awk -F'\: ' '{print $2}' | sed s///`
#   SERIESTITLE=`grep seriesTitle $file.txt | awk -F': ' '{sub(//, ""); print $2}'`
#   TITLE=`echo $file | awk -F. '{print $1}' | tr '_' ' '`
#   TITLE=`echo $file | awk -F. '{gsub(/_/, " "); print $1}'`
   DESCRIPTION=$(awk -F' : ' '/^description : / { sub(//, ""); print $2}' ${file}.txt)
   SERIESTITLE=$(awk -F' : ' '/^seriesTitle : / {sub(//, ""); print $2}' ${file}.txt)
   TITLE=`awk -F. '{gsub(/_/, " "); print $1}' <<< $file`
   SIZE=`ls -l $file | awk '{print $5}'`
#BSD#  AIR_DATE=`date -j -f '%Y-%m-%dT%H:%M:%SZ' ${RAW_AIR_DATE:=2010-05-10T00:00:00Z} +"%a, %d %b %Y %H:%M:%S EST"`      
#   RAW_AIR_DATE=`grep originalAirDate $file.txt | awk '{sub (//, ""); print $3}'`
   RAW_AIR_DATE=$(awk '/^originalAirDate : / {sub (/Z/, ""); sub (/T/, "H"); print $NF}' $file.txt)
   test "${RAW_AIR_DATE}" || RAW_AIR_DATE=$(awk '/^time : / {sub (/Z/, ""); sub (/T/, "H"); print $NF}' $file.txt)
   AIR_DATE=$(${DATECMD} --date ${RAW_AIR_DATE:=2010-05-10H00:00:00} +"%a, %d %b %Y %T %Z")
   test "${DESCRIPTION}" || DESCRIPTION=${AIR_DATE}

   case $file in 
	The_Daily_Show*)
		LINK="dailyshow"
		LENGTH=30
	;;
	The_Rachel_Maddow_Show*)
		LINK="rachelmaddow"
      ;;
	The_Last_Word_With*)
		LINK="lastword"
      ;;
	All_In_With_Chris_Hayes*)
		LINK="allin"
	;;
	This_Is_Us*)
		LINK="parents"
	;;
	60_Minutes*|CBS_Sunday_Morning*)
		LINK="60minutes"
		SERIESTITLE="Weekly news shows."
	;;
      Strip_the_City*|Mythbusters*|Build_It_Bigger*|Cosmos*)
		LINK="geekery"
		SERIESTITLE="Science, technology, engineering and math"
	;;
	*)
		LINK="adhoc"
		SERIESTITLE="Random Stuff"
		LENGTH=0
	;;
   esac
   write.channel "${SERIESTITLE}" "${LINK}" >> $VIDEODIR/${LINK}.xml
   write.item "${TITLE}" "${LINK}" "${file}" "${DESCRIPTION}" "${SIZE}" "${AIR_DATE}" >> $VIDEODIR/${LINK}.xml
done
write.footers "${PODCASTS[@]}"
for file in $(ls $VIDEODIR/*xml); do
# Changing xml files while a download was running seemed to cause problems with the download so now only replace
# the xml if there's a substantive change. Dates and such change so diff and wc don't help.
# Checksum on all of the mp4 lines in the two files works nicely.
#	test $(diff $file ${PODCASTDIR}/${file##/*} > /dev/null 2>&1 ) || { mv $file ${PODCASTDIR}; echo "moved $file"; }
#	test $(diff $file ${PODCASTDIR}/${file##/*} > /dev/null 2>&1 ) 
#	test $(diff $file ${PODCASTDIR}/${file##/*} | wc -c ) -gt 0 && { mv $file ${PODCASTDIR}; echo "moved $file"; }
#	echo $file
#	echo ${file##*/}
#	test "$(wc -c $file | awk '{print $1}')" == "$(wc -c ${PODCASTDIR}/${file##*/} | awk '{print $1}')" || { mv $file ${PODCASTDIR}; }
#	test "$(sum <(grep mp4 $file) | awk '{print $1}')" == "$(sum <(grep mp4 ${PODCASTDIR}/${file##*/}) | awk '{print $1}')" || { mv $file ${PODCASTDIR}; }
	if test "$(sum <(grep mp4 $file) | awk '{print $1}')" != "$(sum <(grep mp4 ${PODCASTDIR}/${file##*/}) | awk '{print $1}')"; then
		mv $file ${PODCASTDIR}
		COPIED_FILES="${COPIED_FILES:+${COPIED_FILES} }${file##*/}"
	fi
	#mv $file ${PODCASTDIR};
done
#mv $VIDEODIR/*xml $PODCASTDIR
IFS=$SAVEIFS
if test "${MOVE_FILES_AT_END}"; then
# Move to jumpman
	#rsync -av  ${PODCASTDIR}/* jason@jumpman:podcast >> ${LOG}
	rsync -av  ${PODCASTDIR}/* jason@podcast.jasons.us:podcast >> ${LOG} 2>> ${ERRFILE}
fi

echo " wrote ${XMLFILES} files: ${COPIED_FILES}" >> $LOG
cleanexit
