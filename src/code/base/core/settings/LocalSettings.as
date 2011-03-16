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
package base.core.settings
{
	/**
	 * A data storage object for use with the LocalSettingsManager in that key-value
	 * pairs are stored that meant to be stored persistenly to harddisk.
	 * 
	 * @see #LocalSettingsManager
	 */
	public class LocalSettings
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _data:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new LocalSettings instance.
		 */
		public function LocalSettings()
		{
			_data = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Stores the specified value in the local settings object mapped under
		 * the specified key.
		 * 
		 * @example
		 * <p><pre>
		 *	var ls:LocalSettings = new LocalSettings();
		 *	ls.put("windowPosX", 200);
		 *	ls.put("windowPosY", 150);
		 *	ls.put("dataPath", "c:/user/documents/test/");
		 * </pre>
		 * 
		 * @param key The key under which to store the value.
		 * @param value The value to store.
		 */
		public function put(key:String, value:Object):void
		{
			_data[key] = value;
		}
		
		
		/**
		 * Returns the settings value that is mapped with the specified key or
		 * null if the key was not found in the settings.
		 * 
		 * @param key The key under that the value is stored.
		 * @return The settings value or undefined.
		 */
		public function getValue(key:String):Object
		{
			if (_data[key]) return _data[key];
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The data object in that setting key-value pairs are stored. Normally you don't
		 * need to use this prooperty. It is used internally by the LocalSettingsManager.
		 */
		public function get data():Object
		{
			return _data;
		}
	}
}
