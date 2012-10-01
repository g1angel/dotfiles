# This file is part of browser.  This is a youtube downloader plugin.
#
# Copyright (C) 2009-2010  Josiah Gordon <josiahg@gmail.com>
#
# browser is free software: you can redistribute it and/or modify
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

""" Provides a youtube downloader tab for the browser.

"""

import os
import warnings

import gtk

# Save the warnings when importing gdata.
with warnings.catch_warnings(record=True) as warning_list:
    warnings.simplefilter('always')
    from youtube_downloader import *

class YoutubeDownloader(object):
    """ Plugin class

    """

    def __init__(self, browser):
        """ Plugin

        """

        self._browser = browser
        self._youtube_downloader = None

    def run(self):
        self._youtube_downloader = \
                YouTubeDownloader(orientation=gtk.ORIENTATION_HORIZONTAL)
        self._youtube_downloader.show_all()
        self._browser._term_book.new_tab(self._youtube_downloader, True)

    def exit(self):
        self._youtube_downloader.stop_all()
        self._browser._term_book.close_tab(self._youtube_downloader, force=True)
        self._youtube_downloader = None

Plugin = YoutubeDownloader
