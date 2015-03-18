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
	 * Provides access to a PlankDrawingDockTheme and PlankDockPrefereces
	 */
	public class DockThemeManager : Object
	{
		static DockThemeManager? instance = null;

		public static unowned DockThemeManager get_default ()
		{
			if (instance == null)
				instance = new DockThemeManager ();

			return instance;
		}

		Plank.DockPreferences? dock_settings = null;
		Plank.Drawing.DockTheme? dock_theme = null;

		public signal void dock_theme_changed (Plank.Drawing.DockTheme? old_theme,
			Plank.Drawing.DockTheme new_theme);

		DockThemeManager ()
		{
			var file = Environment.get_user_config_dir () + "/plank/dock1/settings";

			dock_settings = new Plank.DockPreferences.with_filename (file);
			dock_settings.notify["Theme"].connect (load_dock_theme);
		}

		public Plank.Drawing.DockTheme get_dock_theme ()
		{
			if (dock_theme == null)
				load_dock_theme ();

			return dock_theme;
		}

		public Plank.DockPreferences get_dock_settings ()
		{
			return dock_settings;
		}

		void load_dock_theme ()
		{
			var new_theme = new Plank.Drawing.DockTheme (dock_settings.Theme);
			new_theme.load ("dock");
			dock_theme_changed (dock_theme, new_theme);
			dock_theme = new_theme;
		}
	}
}
