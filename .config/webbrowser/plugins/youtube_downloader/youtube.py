# This file is part of youtube_downloader, and contains the base class for 
# searching and retrieving video uris on youtube.
#
# Copyright (C) 2009-2010  Josiah Gordon <josiahg@gmail.com>
#
# youtube_downloader is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


import re

import gdata.youtube
import gdata.youtube.service

class Video(object):

    def __init__(self):

        self.service = gdata.youtube.service.YouTubeService()
        self.service.ssl = False
        self.vid = None
        self.id = None

    def search(self, search_string, orderby='relevance'):
        """ Searches for search_string and returns search feed """

        query = gdata.youtube.service.YouTubeVideoQuery()
        query.vq = search_string
        query.orderby = orderby
        query.racy = 'exclude'
        return self.service.YouTubeQuery(query)

    def next_page(self, feed):
        return self.service.GetNext(feed)

    def get_playlist_feed(self, uri=None, id=None):
        if uri:
            id = uri.split('=')[1]
        return self.service.GetYouTubePlaylistVideoFeed(playlist_id=id)

    def set_vid(self, uri=None, id=None):
        if uri:
            id = uri.split('=')[1]
        self.id = id
        self.vid = self.service.GetYouTubeVideoEntry(video_id=id)

    def get_flv_author(self, uri=None, id=None):
        if uri:
            id = uri.split('=')[1]
        if id != self.id:
            self.set_vid(id=id)
        return self.vid.author[0].name.text

    def get_flv_name(self, uri=None, id=None):
        if uri:
            id = uri.split('=')[1]
        if id != self.id:
            self.set_vid(id=id)
        return self.vid.title.text

    def get_flv_uri(self, uri=None, video_id=None, vidquality=0):

        if video_id:
            uri = 'http://www.youtube.com/watch?v=%s' % video_id
        if uri:
            uri = uri.split('&')[0]
            video_id = uri.split('=')[1]
        else:
            return None
        
        import urllib2
        data = urllib2.urlopen(uri).read()
        #data = self.service.GetMedia(uri, std_headers).file_handle.read()
        regexp = re.compile(r', "t": "([^"]+)"')
        match = regexp.search(data)
        if match:
            video_name = match.group(1)

        if vidquality == 3:
            flv_uri = 'http://www.youtube.com/get_video?fmt=22&video_id=%s&t=%s&asv=3' \
                    % (video_id, video_name)
        elif vidquality == 2:
            flv_uri = 'http://www.youtube.com/get_video?fmt=35&video_id=%s&t=%s&asv=3' \
                    % (video_id, video_name)
        elif vidquality == 1:
            flv_uri = 'http://www.youtube.com/get_video?fmt=18&video_id=%s&t=%s&asv=3' \
                    % (video_id, video_name)
        else:
            flv_uri = 'http://www.youtube.com/get_video?video_id=%s&t=%s&asv=3' \
                    % (video_id, video_name)

        return flv_uri

if __name__ == '__main__':
    ytv = Video()
    print ytv.get_flv_name(uri='http://www.youtube.com/watch?v=hvbXfiSu1w8')
    print ytv.get_flv_uri(id='hvbXfiSu1w8')
