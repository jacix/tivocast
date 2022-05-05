#!/usr/bin/env python3
#
# rewrite of Jason's tivo-to-podcast bash script

TESTING='false'

from xml.dom import minidom
import datetime
from datetime import datetime
import re
import pytz
import os
from pathlib import Path

PODCASTDIR="/usr/local/www/data/podcast"
VIDEODIR=PODCASTDIR + "/video"
VIDEOFILE=VIDEODIR + "/CBS_Sunday_Morning_-_03-27-2022_ep40224_Sun_Mar_27_BlackBolt.mp4"
URL='https://podcast.jasons.us'
pubDate=datetime.now().strftime("%a, %d %b %Y %H:%M:%S EST")

def write_channel(p_xmlfile, p_title, p_link):
    xmlfile = open(p_xmlfile, 'w')
    xmlfile.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    xmlfile.write('<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">\n')
    xmlfile.write('\n')
    xmlfile.write('   <channel>\n')
    xmlfile.write('   <title>' + p_title + '</title>\n')
    xmlfile.write('      <description>Jason\'s Podcast Of ' + p_title + '</description>\n')
    xmlfile.write('      <link>' + URL + '</link>\n')
    xmlfile.write('      <atom:link href="' + URL + '/' + p_link + '.xml" rel="self" type="application/rss+xml" />\n')
    xmlfile.write('      <language>en-us</language>\n')
    xmlfile.write('      <copyright>Copyright 2007</copyright>\n')
    xmlfile.write('      <lastBuildDate>Tue, 27 Sep 2011 02:50:00 -0500</lastBuildDate>\n')
    xmlfile.write('      <pubDate>' + pubDate + '</pubDate>\n')
    xmlfile.write('      <docs>http://blogs.law.harvard.edu/tech/rss</docs>\n')
    xmlfile.write('      <webMaster>podcasts@jasons.us (Podcast Master) </webMaster>\n')
    xmlfile.write('      <image>\n')
    xmlfile.write('         <url>' + URL + '/images/' + p_link + '.jpg</url>\n')
    xmlfile.write('         <title>' + p_title + '</title>\n')
    xmlfile.write('         <link>' + URL + '</link>\n')
    xmlfile.write('      </image>\n')
    xmlfile.close()

def write_item(p_xmlfile, p_title, p_link, p_filename, p_description, p_size, p_airdate):
    xmlfile = open(p_xmlfile, 'a')
    xmlfile.write('      <item>\n')
    xmlfile.write('         <title>' + p_title + '</title>\n')
    xmlfile.write('         <link>' + URL + '/' + p_link + '.xml</link>\n')
    xmlfile.write('         <guid isPermaLink="true">' + URL + '/video/' + p_filename + '</guid>\n')
    xmlfile.write('         <description>' + p_description + '</description>\n')
    xmlfile.write('         <enclosure url="' + URL + '/video/' + p_filename + '" length="' + str(p_size) + '" type="video/mpeg" />\n')
    xmlfile.write('         <category>Podcasts</category>\n')
    xmlfile.write('         <pubDate>' + pubDate + '</pubDate>\n')
    xmlfile.write('      </item>\n')
    xmlfile.close()

def write_footer(p_xmlfile):
    xmlfile = open(p_xmlfile, 'a')
    xmlfile.write('   </channel>\n')
    xmlfile.write('</rss>\n')

def parse_tivo_file(p_videofile):
    with open(p_videofile + '.txt', 'r',newline='\n') as txtfile:
        fileSize = os.path.getsize(p_videofile)
        episodeBasename = os.path.basename(p_videofile)
        episodeFile, episodeExt = os.path.splitext(episodeBasename)
        episodeTitle = episodeFile.replace('_', ' ')
        for line in txtfile:
            description=""
            if re.search('^description', line):
                label,description=line.split(' : ',1)
                description=description.strip()
            if re.search('^seriesTitle', line):
                label,seriesTitle=line.split(' : ',1)
                seriesTitle=seriesTitle.strip()
            if re.search('^originalAirDate', line):
                label,raworiginalAirDate=line.split(' : ',1)
                raworiginalAirDate=raworiginalAirDate.strip()
        originalAirDateUTC_dt = datetime.strptime(raworiginalAirDate,'%Y-%m-%dT%H:%M:%SZ')
        #local_timezone = pytz.timezone('UTC')
        #originalAirDateLocal = originalAirDateUTC.astimezone(local_timezone)
        format = "%a, %d %b %Y %T %Z"
        #originalAirDate_str = originalAirDateUTC_dt.strftime(format)
        originalAirDate_str = originalAirDateUTC_dt.strftime("%a, %d %b %Y %T %Z")
        if re.search('The_Daily_Show.*', p_videofile):
            link='dailyshow'
        elif re.search('.*(CBS_Sunday_Morning|60_Minutes).*', p_videofile):
            link='60minutes'
            seriesTitle="Weekly News shows."
        else:
            link='adhoc'
            seriesTitle='Random Stuff'
        xmlfile = VIDEODIR + '/' + link + '.xml'
        if TESTING == 'true':
            print('Deleting xml file' + xmlfile)
            os.remove(xmlfile)
        # If there isn't already an xml file for this show, create it and add to the list of all xml files
        if not os.path.isfile(xmlfile):
            write_channel(xmlfile, seriesTitle,link)
            allxmlfiles.append(xmlfile)
        write_item(xmlfile, episodeTitle, link, os.path.basename(p_videofile), description, fileSize, originalAirDate_str)

if __name__ == "__main__":
    """
    usage goes here
    """
    # create list for all created xml files so they can have the footer added at the end
    allxmlfiles = []

    # remove existing xml files
    for deleteme in Path(VIDEODIR).glob('*.xml'):
        print("deleting", deleteme)
        deleteme.unlink()

    # read the mp4 files and create the header (if necessary) and the items
    for videofile in Path(VIDEODIR).glob('*.mp4'):
        parse_tivo_file(str(videofile))

    # add the footer to all files
    for finalizefile in allxmlfiles:
        write_footer(finalizefile)
    print("complete at", datetime.now())
    #print("complete at UTC", datetime.utcnow())
