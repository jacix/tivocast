import inspect
from datetime import datetime
import os
from pathlib import Path

# some variables and constants
PODCAST_DIR = '~jason/tivocast'
VIDEO_DIR = PODCAST_DIR + '/video'

class Episode:
    def __init__(self, episode_title, episode_description, episode_url, episode_length, episode_pubdate):
        self.episode_title = episode_title
        self.episode_description = episode_description
        self.episode_url = episode_url
        self.episode_length = episode_length
        self.episode_pubdate = episode_pubdate

class TVShow:
    def __init__(self, show_title, show_shortname):
        self.show_title = show_title
        self.show_description = f"Jason's Podcast Of {show_title}"
        self.link = "https://podcast.jasons.us"
        self.show_shortname = show_shortname
        self.pubdate = datetime.now().strftime("%a, %d %b %Y %H:%M:%S EST")
        self.docs = "http://blogs.law.harvard.edu/tech/rss"
        self.webMaster = "podcasts@jasons.us (Podcast Master)"
        self.image_url = f"https://podcast.jasons.us/images/{show_shortname}.jpg"
        self.image_title = show_title
        self.image_link = "https://podcast.jasons.us"
        self.episodes: [Episode] = []

    def print_show_details():
        print("testing")
        print(self.__dict__)

    def write_show_file():
        with open(PODCAST_DIR + self.show_shortname + 'xml', 'w') as file:
#            file.write()
            for episode in self.episodes:
                print("not done yet")
                # write episode data as xml

def parse_tivo_metadata_file(videofile):
    print("code this, please!")

if __name__ == '__main__':
    shows: [TVShow] = []
#    print(type(shows))
#    inspect(shows)
#    print("hi")
    # once the objects are working, remove the hard-coded show/episode data and use this to parse the tivo metadata files:
    # for video_file in Path(VIDEO_DIR).glob('*mp4'):
    #   if re.search('The_Daily_Show.*', videofile):
    #       show_shortname = "dailyshow"
    #   elif re.search('The_Good_Place.*', videofile):
    #       show_shortname = "goodplace"    
    #   episode_title, episode_description, episode_url, episode_length, episode_pubdate = parse_tivo_metadata_file(str(videofile))
    #
    # for now, hard-code an episode's details.  Once this is working, have it parse this from a text file.  
    show_title = "The Daily Show With Trevor Noah"
    show_shortname = "dailyshow"
    episode_title = "The Daily Show With Trevor Noah - April 11, 2022 ep2774 Mon Apr 11 BlackBolt"
    episode_description = "Trevor Noah and The Daily Show correspondents tackle the biggest stories in news, politics and pop culture."
    episode_url = "https://podcast.jasons.us/video/The_Daily_Show_With_Trevor_Noah_-_April_11,_2022_ep2774_Mon_Apr_11_BlackBolt.mp4"
    episode_length = 102897483
    episode_pubdate = "Mon, 11 Apr 2022 04:00:00 EDT"
    if show_shortname not in [s.show_shortname for s in shows]:
        shows.append(TVShow(show_title, show_shortname))


    # find the show's index in list "shows"
    for index, item in enumerate(shows):
        if item.show_shortname == show_shortname:
            break
        else:
            raise Exception("You shouldn't get here.")

    shows[index].episodes.append(Episode(episode_title, episode_description, episode_url, episode_length, episode_pubdate))
    
    for obj in shows:
#        print(obj.__dict__)
        obj.print_show_details
    #    print(obj.show_title)
    #    print(obj.episodes)