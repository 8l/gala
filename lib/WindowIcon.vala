//
//  Copyright (C) 2012 Tom Beckmann, Rico Tzschichholz
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Gala
{
	/**
	 * Creates a new GtkClutterTexture with an icon for the window at the given size.
	 * This is recommended way to grab an icon for a window as this method will make
	 * sure the icon is updated if it becomes available at a later point.
	 */
	public class WindowIcon : GtkClutter.Texture
	{
		static Bamf.Matcher matcher;

		static construct
		{
			matcher = Bamf.Matcher.get_default ();
		}

		public Meta.Window window { get; construct; }
		public int icon_size { get; construct; }

		/**
		 * If set to true, the SafeWindowClone will destroy itself when the connected
		 * window is unmanaged
		 */
		public bool destroy_on_unmanaged {
			get {
				return _destroy_on_unmanaged;
			}
			construct set {
				if (_destroy_on_unmanaged == value)
					return;

				_destroy_on_unmanaged = value;
				if (_destroy_on_unmanaged)
					window.unmanaged.connect (unmanaged);
				else
					window.unmanaged.disconnect (unmanaged);
			}
		}

		bool _destroy_on_unmanaged = false;
		bool loaded = false;
		uint32 xid;

		/**
		 * Creates a new WindowIcon
		 *
		 * @param window               The window for which to create the icon
		 * @param icon_size            The size of the icon in pixels
		 * @param destroy_on_unmanaged see destroy_on_unmanaged property
		 */
		public WindowIcon (Meta.Window window, int icon_size, bool destroy_on_unmanaged = false)
		{
			Object (window: window,
					icon_size: icon_size,
					destroy_on_unmanaged: destroy_on_unmanaged);
		}

		construct
		{
			width = icon_size;
			height = icon_size;
			xid = (uint32) window.get_xwindow ();

			// new windows often reach mutter earlier than bamf, that's why
			// we have to wait until the next window opens and hope that it's
			// ours so we can get a proper icon instead of the default fallback.
			var app = matcher.get_application_for_xid (xid);
			if (app == null)
				matcher.view_opened.connect (retry_load);
			else
				loaded = true;

			update_texture (true);
		}

		~WindowIcon ()
		{
			if (!loaded)
				matcher.view_opened.disconnect (retry_load);
		}

		void retry_load (Bamf.View view)
		{
			var app = matcher.get_application_for_xid (xid);

			// retry only once
			loaded = true;
			matcher.view_opened.disconnect (retry_load);

			if (app == null)
				return;

			update_texture (false);
		}

		void update_texture (bool initial)
		{
			var pixbuf = Gala.Utils.get_icon_for_xid (xid, icon_size, !initial);

			try {
				set_from_pixbuf (pixbuf);
			} catch (Error e) {}
		}

		void unmanaged (Meta.Window window)
		{
			destroy ();
		}
	}
}
