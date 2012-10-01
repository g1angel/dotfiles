# A plugin for browser that provides an ipython console to manipulate the 
# browser.
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

""" Provides an IPython console to manipulate the browser.

"""

import gtk

from ipython_term import IPythonTerm

class IPythonConsole(object):
    """ IPython console plugin class using the ipython_view module.

    """

    def __init__(self, browser):
        """ Basic initialization.

        """

        # Add an interactive ipython shell.
        self._browser = browser
        self._ipython_term = None

    def run(self):
        """ run -> Create the ipython terminal, and add it to the browsers
        bottom panel.

        """

        print("Loading interactive ipython shell...")
        self._ipython_term = IPythonTerm()
        self._ipython_term.update_namespace({'browser':self._browser})
        self._browser._term_book.new_tab(self._ipython_term, True)
        self._browser._term_book.reorder_child(self._ipython_term, 1)
        keyval, modifier = gtk.accelerator_parse('<Control><Shift>i')
        self._browser._accels.connect_group(keyval, modifier, 
                gtk.ACCEL_VISIBLE, self._toggle_terminal_key_pressed)

    def exit(self):
        """ exit -> Disconnect and destroy the ipython console.

        """

        try:
            self._browser._accels.disconnect_by_func(self._toggle_terminal_key_pressed)
            self._browser._term_book.close_tab(self._ipython_term, force=True)
        except Exception as err:
            print(err)
        finally:
            self._ipython_term = None

    def _toggle_terminal_key_pressed(self, accels=None, window=None, 
            keyval=None, flags=None):
        """ _toggle_terminal_key_pressed() -> Toggle visibility of terminal
        tab box. 

        """

        if self._browser._term_book.get_property('visible'):
            index = self._browser._term_book.page_num(self._ipython_term)
            self._browser._term_book.set_current_page(index)
        else:
            self._browser._term_book.toggle_visible(self._ipython_term)
        self._ipython_term._ipython_view.grab_focus()

Plugin = IPythonConsole
