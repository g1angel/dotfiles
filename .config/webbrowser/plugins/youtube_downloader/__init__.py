# This file is part of youtube_downloader, and contains the main interface 
# to use the youtube class to search for and download youtube videos.
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

import os
import threading, thread
import urllib
from math import ceil

import gtk
import glib
import gobject

import youtube
from download_classes import Download, BarProgress, DownloadCanceled, URLOpenerResume

class YouTubeDownloader(gtk.Alignment):

    def __init__(self, halign=0.5, valign=0.5, hstretch=1, vstretch=1, search_string=None, orientation=gtk.ORIENTATION_VERTICAL):
        super(YouTubeDownloader, self).__init__(halign, valign, hstretch, vstretch)

        self._title = 'YouTube Downloader'

        self._icon = gtk.Image()
        self.set_icon('applications-multimedia')

        self._is_searching = False
        self._selected_dict = {}
        self._item_list = []
        self._download_thread_dict = {}
        self._current_folder = os.getenv('HOME')

        self._video_quality = 0
        self._stop_search = True

        self.add(self._setup_controls(orientation))
        self._menu = self._build_popup()

        self._clipboard = ProcessClipboard(self._get_clipboard)

        if search_string:
            self._search_entry.set_text(search_string)
            self._search_button_clicked(self._search_button)

        self._search_entry.grab_focus()

    def _setup_controls(self, orientation=gtk.ORIENTATION_VERTICAL):
        vbox = gtk.VBox(homogeneous=False, spacing=12)

        folder_quality_hbox = gtk.HBox(homogeneous=False, spacing=6)

        folder_frame = self._make_frame('<b>Output Folder</b>')

        folder_align = gtk.Alignment(.5, .5, 1, 0)
        folder_align.set_padding(0, 0, 12, 0)
        self._folder_button = gtk.FileChooserButton('Select a Folder')
        self._folder_button.set_action(gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER)
        self._folder_button.connect('selection-changed', self._folder_button_selection_changed)
        self._folder_button.set_current_folder(self._current_folder)

        folder_align.add(self._folder_button)
        folder_frame.add(folder_align)
        folder_quality_hbox.pack_start(folder_frame, True, True)

        quality_frame = self._make_frame('<b>Video Quality</b>')

        quality_align = gtk.Alignment(.5, .5, 1, 0)
        quality_align.set_padding(0, 0, 12, 0)

        self._quality_combo = self._build_quality_combo()

        quality_align.add(self._quality_combo)
        quality_frame.add(quality_align)
        folder_quality_hbox.pack_start(quality_frame, False, False)

        folder_quality_align = gtk.Alignment(0.5, 0, 1, 0)
        folder_quality_align.add(folder_quality_hbox)

        vbox.pack_start(folder_quality_align, False, False)

        search_frame = self._make_frame('<b>Search</b>')

        search_align = gtk.Alignment(0.5, 0.5, 1, 0)
        search_align.set_padding(0, 0, 12, 0)

        self._search_entry = gtk.Entry()
        self._search_entry.set_icon_from_icon_name(0, 'gtk-find')
        self._search_entry.set_icon_from_icon_name(1, 'gtk-clear')
        self._search_entry.connect('activate', self._search_button_clicked) 
        self._search_entry.connect('icon-release', self._search_entry_icon_release)

        self._search_button = gtk.Button('gtk-find')
        self._search_button.set_use_stock(True)
        self._search_button.connect('clicked', self._search_button_clicked) 

        search_button_hbox = gtk.HBox(homogeneous=False, spacing=6)

        search_hbox = gtk.HBox(homogeneous=False, spacing=6)
        search_hbox.pack_start(self._search_entry, True, True)
        search_hbox.pack_start(self._search_button, False, False)
        search_align.add(search_hbox)
        search_frame.add(search_align)

        search_frame_align = gtk.Alignment(0.5, 0, 1, 0)
        search_frame_align.add(search_frame)

        vbox.pack_start(search_frame_align, False, False)

        list_frame = self._make_frame('<b>Video List</b>')

        list_align = gtk.Alignment(0.5, 0.5, 1, 1)
        list_align.set_padding(0, 0, 12, 0)

        scroll_window = gtk.ScrolledWindow()
        scroll_window.set_policy('automatic', 'automatic')
        scroll_window.set_shadow_type(gtk.SHADOW_IN)

        self._video_list_view, self._video_list_store = self._build_video_list_view()
        scroll_window.add(self._video_list_view)

        list_align.add(scroll_window)
        list_frame.add(list_align)

        vbox.pack_start(list_frame, True, True)
        vbox.set_orientation(orientation)

        return vbox

    def _make_frame(self, label_text):
        frame_label = gtk.Label(label_text)
        frame_label.set_use_markup(True)
        frame = gtk.Frame()
        frame.set_shadow_type(gtk.SHADOW_NONE)
        frame.set_label_widget(frame_label)

        return frame

    def _build_quality_combo(self):
        quality_model = gtk.ListStore(gtk.gdk.Pixbuf, gobject.TYPE_STRING)
        quality_combo = gtk.ComboBox(quality_model)
       
        renderer_tup = (
                (gtk.CellRendererPixbuf(), False, 'pixbuf'),
                (gtk.CellRendererText(), True, 'text'),
                )

        for tup in renderer_tup:
            renderer, expand, value_name = tup
            quality_combo.pack_start(renderer, expand)
            quality_combo.add_attribute(renderer, value_name, renderer_tup.index(tup))

        icontheme = gtk.icon_theme_get_default()
        icon = icontheme.load_icon('applications-multimedia', 16, gtk.ICON_LOOKUP_USE_BUILTIN)
        
        for name in ('flv', 'mp4', 'hd flv', 'hd mp4'):
            quality_model.append([icon, name])

        quality_combo.set_active(0)

        quality_combo.connect('changed', self._quality_combo_changed)

        return quality_combo

    def _build_video_list_view(self):
        video_list_store = gtk.ListStore(gtk.ProgressBarStyle, str, str, str)
        video_list_view = gtk.TreeView(video_list_store)

        column_tup = (
                ('Progress', gtk.CellRendererProgress(), {'value':0}, False),
                ('Title', gtk.CellRendererText(), {'text':1}, True),
                ('Author', gtk.CellRendererText(), {'text':2}, True)
                )

        for (title, renderer, value, resizable) in column_tup:
            column = gtk.TreeViewColumn(title, renderer, **value)
            column.set_resizable(resizable)
            video_list_view.append_column(column)

        video_list_view.connect('cursor-changed', self._video_list_view_cursor_changed)
        video_list_view.connect('button-release-event', self._video_list_view_button_released)

        return video_list_view, video_list_store

    def _build_popup(self):
        menu = gtk.Menu()

        item_tup = (
                ('_cancel_item', ('gtk-stop', '_Cancel', False, self._cancel_button_released)),
                ('_download_item', ('emblem-downloads', '_Download', False, self._download_button_released)),
                ('_clear_item', ('gtk-clear', 'Clear _List', False, self._clear_button_released)),
                )

        for item_name, (icon_name, label_text, is_sensitive, clicked_callback) in item_tup:
            icon = gtk.Image()
            icon.set_from_icon_name(icon_name, gtk.ICON_SIZE_MENU)
            item = gtk.ImageMenuItem()
            item.set_image(icon)
            item.set_label(label_text)
            item.set_use_underline(True)
            item.set_sensitive(is_sensitive)
            item.connect('button-release-event', clicked_callback)
            menu.add(item)
            self.__setattr__(item_name, item)
            
        menu.show_all()

        return menu

    def _search_entry_icon_release(self, search_entry, position, event):
        if position == gtk.ENTRY_ICON_SECONDARY:
            search_entry.set_text('')

    def _search_button_clicked(self, search_button):
        if self._is_searching:
            self._is_searching = False
            self._search_button.set_label('gtk-find')
            self._search_entry.set_sensitive(True)
            self._search_entry.grab_focus()
        else:
            self._is_searching = True
            self._search_button.set_label('gtk-stop')
            self._search_entry.set_sensitive(False)

            search_term = self._search_entry.get_text()
            
            youtube_video = youtube.Video()
            search_feed = youtube_video.search(search_term)
            search_thread = threading.Thread(target=self._process_feed, args=(youtube_video, search_feed))
            search_thread.start()

    def _quality_combo_changed(self, quality_combo):
        self._video_quality = quality_combo.get_active()

    def _download_video(self):
        if self._video_quality == 0 or self._video_quality == 2:
            video_ext = 'flv'
        else:
            video_ext = 'mp4'

        iter = self._selected_dict.get('iter')
        name = self._selected_dict.get('name')
        uri = self._selected_dict.get('uri')

        filename = "%s.%s" % (name, video_ext)
        filename = filename.replace('/', ':')
        
        youtube_video = youtube.Video()
        download_uri = youtube_video.get_flv_uri(uri=uri, vidquality=self._video_quality)
        progress_bar = BarProgress(self._set_progress, iter) 
        download_thread = Download(download_uri, '%s/%s' % (self._current_folder, filename), progress_bar)
        download_thread.start()
        self._download_thread_dict[uri] = download_thread

    def _process_feed(self, youtube_video, feed):
        total_results = int(feed.total_results.text)
        per_page = int(feed.items_per_page.text)
        if total_results > per_page:
            pages = int(ceil(float(total_results) / float(per_page)))
        else:
            pages = 1
        for i in range(pages):
            if feed:
                for video in feed.entry:
                    if not self._is_searching:
                        thread.exit()
                    video_uri = video.link[0].href
                    flv_name = video.title.text
                    author = video.author[0].name.text
                    glib.idle_add(self._add_item, flv_name, author, video_uri)
                feed = youtube_video.next_page(feed)

        self._is_searching = False
        glib.idle_add(self._search_button.set_label, 'gtk-find')
        glib.idle_add(self._search_entry.set_sensitive, True)
        glib.idle_add(self._search_entry.grab_focus)

    def _add_item(self, name, author, uri):
        item = (name, author, uri)
        if item not in self._item_list:
            self._item_list.append(item)
            iter = self._video_list_store.append((0, name, author, uri))

    def _cancel(self, remove=False):
        name = self._selected_dict.get('name')
        author = self._selected_dict.get('author')
        uri = self._selected_dict.get('uri')

        if remove:
            self._item_list.remove((name, author, uri))

        download_thread = self._download_thread_dict.pop(uri, None)
        if download_thread:
            download_thread.stop()
            while download_thread.is_alive():
                pass

    def _set_progress(self, progress, iter):
        glib.idle_add(self._video_list_store.set_value, iter, 0, int(progress))

    def _get_clipboard(self, clipboard, text, user_data):
        if text:
            self.add_uri(text)

    def _video_list_view_cursor_changed(self, video_list_view):
        row, col = video_list_view.get_cursor()
        iter = self._video_list_store.get_iter(row)

        self._update_selected(iter)

    def _update_selected(self, iter):
        name = self._video_list_store.get_value(iter, 1)
        author = self._video_list_store.get_value(iter, 2)
        uri = self._video_list_store.get_value(iter, 3)

        self._selected_dict = {'iter':iter, 'name':name, 'author':author, 'uri':uri}

        download_thread = self._download_thread_dict.get(uri, None)

        if download_thread:
            self._cancel_item.set_sensitive(download_thread.is_alive())
            self._download_item.set_sensitive(not download_thread.is_alive())
        else:
            self._cancel_item.set_sensitive(False)
            self._download_item.set_sensitive(True)

    def _video_list_view_button_released(self, video_list_view, event):
        path = video_list_view.get_path_at_pos(int(event.x), int(event.y))
        if path:
            row = path[0]
            iter = self._video_list_store.get_iter(row)
            self._update_selected(iter)
        else:
            self._cancel_item.set_sensitive(False)
            self._download_item.set_sensitive(False)

        if event.button == 3:
            self._clear_item.set_sensitive(len(self._video_list_store) > 0)
            self._menu.popup(None, None, None, event.button, event.time, None)
        elif event.button == 2:
            self._update_selected(iter)

            self._remove_item(iter)

        return True

    def _folder_button_selection_changed(self, folder_button):
        self._current_folder = folder_button.get_filename()

    def _clear_button_released(self, clear_item, event):
        for row in self._video_list_store:
            iter = row.iter
            self._remove_item(iter, clear_running=False)

    def _remove_item(self, iter, clear_running=True):
        name = self._video_list_store.get_value(iter, 1)
        author = self._video_list_store.get_value(iter, 2)
        uri = self._video_list_store.get_value(iter, 3)
        item = (name, author, uri)
        download_thread = self._download_thread_dict.get(uri, None)
        if download_thread:
            if download_thread.is_alive():
                if not clear_running:
                    return
                download_thread.stop()
                while download_thread.is_alive(): 
                    pass
        self._video_list_store.remove(iter)
        self._item_list.remove(item)

    def _remove_selected(self):
        iter = self._selected_dict.get('iter')
        self._remove_item(iter)

    def _cancel_button_released(self, cancel_item, event):
        uri = self._selected_dict.get('uri')
        download_thread = self._download_thread_dict.get(uri, None)
        if download_thread:
            download_thread.stop()

    def _download_button_released(self, download_item, event):
        self._download_video()

    def set_icon(self, icon_name):
        """ set_icon(icon_name) -> Set the icon from icon_name.

        """

        self._icon.set_from_icon_name(icon_name, gtk.ICON_SIZE_MENU)

    def get_icon(self):
        """ get_icon() -> Return the icon.

        """

        return self._icon

    def get_title(self):
        return self._title

    def close(self):
        return False

    def stop_all(self):
        self._is_searching = False

        for download_thread in self._download_thread_dict.values():
            download_thread.stop()
            while download_thread.is_alive():
                pass

    def stop_search(self):
        if self._is_searching:
            self._search_button_clicked(self._search_button)

    def add_uri(self, uri):
        if 'youtube.com' in uri:
            try:
                if 'view_play_list' in uri:
                    youtube_video =  youtube.Video()
                    playlist_feed = youtube_video.get_playlist_feed(uri=uri)
                    self._is_searching = True
                    threading.Thread(target=self._process_feed, args=(youtube_video, playlist_feed)).start()
                else:
                    youtube_video = youtube.Video()
                    flv_name = youtube_video.get_flv_name(uri=uri)
                    author = youtube_video.get_flv_author(uri=uri)
                    self._add_item(flv_name, author, uri)
            except:
                return False

class ProcessClipboard(object):
    """ Process Clipboard """

    def __init__(self, callback, user_data=None, run=False, selection_type='CLIPBOARD'):
        """ ProcessClipboard(callback) Call callback when owner changes """

        self._clipboard = gtk.clipboard_get(selection=selection_type)
        self._clipboard.connect('owner-change', self._owner_change, callback, 
                user_data)
        if run:
            self._clipboard.request_text(callback, user_data)

    def _owner_change(self, clipboard, event, callback, user_data):
        """ Handler owner change event """

        clipboard.request_text(callback, user_data)
