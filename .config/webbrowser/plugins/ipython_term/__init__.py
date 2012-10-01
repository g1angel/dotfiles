# A gtk.ScrolledWindow that embeds a textview ipython console.
# Copyright (C) 2010 Josiah Gordon <josiahg@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

""" A scrolled window embeding an ipython_view in it.

"""

import gtk
import pango

from ipython_view import *

class IPythonTerm(gtk.ScrolledWindow):
    """ IPythonTerm -> Create a scrolled window so the ipython terminal
    can be scrolled back.  Also provide some other methods for use by the
    browsers tab window.

    """

    def __init__(self):
        """ Initialize the scrolled window and ipython view.

        """

        super(IPythonTerm, self).__init__()

        # Set the icon and title.
        self._icon = gtk.Image()
        self._icon.set_from_icon_name('system-run', gtk.ICON_SIZE_MENU)
        self._title = "IPython Terminal"

        # Make the scrollbars visibility automatic.
        self.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)

        # Create and setup an IPythonView.
        self._ipython_view = IPythonView()
        self._font = ''
        self._ipython_view.modify_font(pango.FontDescription(self._font))
        self._ipython_view.set_wrap_mode(gtk.WRAP_CHAR)
        self.update_namespace = self._ipython_view.updateNamespace

        self.add(self._ipython_view)
        self.show_all()

    def close(self):
        """ close -> Returns false so the tab will not close unless forced.

        """

        return False

    def get_title(self):
        """ get_title -> Returns the title.

        """

        return self._title

    def get_icon(self):
        """ get_icon -> Returns the tabs icon.

        """

        return self._icon
