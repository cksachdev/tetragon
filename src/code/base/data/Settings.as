/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package base.data
{
	import com.hexagonstar.util.string.TabularText;
	
	
	/**
	 * A class that acts as the map for the application's settings.
	 */
	public final class Settings
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const USER_DATA_DIR:String			= "userDataDir";
		public static const USER_SAVEGAMES_DIR:String		= "userSaveGamesDir";
		public static const USER_SCREENSHOTS_DIR:String		= "userScreenshotsDir";
		public static const USER_SETTINGS_DIR:String		= "userSettingsDir";
		public static const USER_LOGS_DIR:String			= "userLogsDir";
		public static const USER_PLUGINS_DIR:String			= "userPluginsDir";
		
		public static const USER_CONFIG_FILE:String			= "userConfigFile";
		public static const USER_KEYBINDINGS_FILE:String	= "userKeyBindingsFile";
		public static const USER_SETTINGS_FILE:String		= "userSettingsFile";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _map:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Settings()
		{
			_map = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a settings key-value pair to the settings map. If a setting is already
		 * mapped with the given key it will be overwritten.
		 * 
		 * @param key
		 * @param value
		 */
		public function addSettings(key:String, value:Object):void
		{
			//Log.debug("Added settings key=" + key + ", value=" + value, this);
			_map[key] = value;
		}
		
		
		/**
		 * Gets a mapped setting.
		 */
		public function getSettings(key:String):*
		{
			return _map[key];
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "Settings";
		}
		
		
		/**
		 * Returns a string dump of the settings list.
		 */
		public function dump():String
		{
			var t:TabularText = new TabularText(2, true, "  ", null, "  ", 0, ["KEY", "VALUE"]);
			for (var key:String in _map)
			{
				t.add([key, _map[key]]);
			}
			return toString() + "\n" + t;
		}
	}
}
