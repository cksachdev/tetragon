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
package base.io.file.loaders
{
	import base.core.debug.Log;
	import base.data.Config;
	import base.data.Registry;

	import com.hexagonstar.file.FileIOEvent;
	import com.hexagonstar.file.types.TextFile;

	import flash.events.Event;
	
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	
	/**
	 * A class that loads the application configuration/ini file and parses the loaded
	 * properties into the config model. The manager/config model supports simple string and
	 * numeric values, objects, and arrays.
	 * 
	 * The Config model should contain all properties that are also found in the config file.
	 * See the Config class for more info.
	 */
	public class ConfigLoader extends FileLoader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _config:Config;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function ConfigLoader()
		{
			_config = Registry.config;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function addFile(filePath:String, fileID:String = null):void
		{
			if (_loader.loading) return;
			_loader.addFile(new TextFile(filePath, fileID));
		}
		
		
		/**
		 * Starts the load process.
		 */
		override public function load():void
		{
			_loader.load();
		}
		
		
		/**
		 * Disposes the class.
		 */
		override public function dispose():void
		{
			super.dispose();
			_config = null;
		}
		
		
		/**
		 * Returns a string representation of ConfigLoader.
		 * 
		 * @return A string representation of ConfigLoader.
		 */
		override public function toString():String
		{
			return "[ConfigLoader]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initiates parsing of the loaded ini file into the model object.
		 * @private
		 */
		override public function onAllFilesComplete(e:FileIOEvent):void
		{
			super.onAllFilesComplete(e);
			
			if (e.file.valid)
			{
				parse(TextFile(e.file));
			}
			else
			{
				notifyError("File invalid or not found <" + e.file.toString() + "> ("
					+ e.file.status + ")");
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Parses text from a text-based ini file.
		 * @private
		 */
		protected function parse(file:TextFile):void
		{
			var text:String = file.contentAsString;
			var lines:Array = text.match(/^.+$/gm);
			var key:String;
			var val:String;
			
			for each (var l:String in lines)
			{
				var firstChar:String = trim(l).substr(0, 1);
				
				/* Ignore lines that are comments or headers */
				if (firstChar != "#" && firstChar != "[")
				{
					var pos:int = l.indexOf("=");
					key = trim(l.substring(0, pos));
					val = trim(l.substring(pos + 1, l.length));
					parseProperty(key, val);
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/**
		 * Tries to parse the specified key and value pair into the Config Model.
		 * @private
		 */
		protected function parseProperty(key:String, val:String):void
		{
			var keyExists:Boolean = true;
			var p:*;
			
			/* Check if the key found in the config file is defined in the Config Model */
			try
			{
				p = _config[key];
			}
			catch (e:Error)
			{
				Log.warn("Error parsing config property \"" + key + "\" (" + e.message + ")", this);
				keyExists = false;
			}
			
			if (keyExists)
			{
				if (p is Number)
					_config[key] = val;
				else if (p is String)
					_config[key] = val;
				else if (p is Boolean)
					_config[key] = (val.toLowerCase() == "true") ? true : false;
				else if (p is Array)
					_config[key] = parseArray(val);
				else if (p is Object)
					_config[key] = parseObject(val);
			}
		}
		
		
		/**
		 * Parses a string into an array. The string must have the format [val1, val2, val3]
		 * and so on. Note that string type values in the array string should not be wrapped
		 * by any kind of quotation marks; internally all values are treated as Strings!
		 * 
		 * @private
		 * @param string The string to parse into an array.
		 * @return the array with values from the string or null if the string could not be
		 *         parsed into an array.
		 */
		private function parseArray(string:String):Array
		{
			/* String must start mit [ and end with ] */
			if (string.match("^\\[.*?\\]\\z"))
			{
				string = string.substr(1, string.length - 2);
				if (string.length > 0)
				{
					var a:Array = string.split(",");
					for (var i:String in a)
					{
						a[i] = trim(a[i]);
					}
					return a;
				}
				return null;
			}
			else
			{
				Log.warn("Error parsing config! Malformed syntax in Array property: " + string, this);
				return null;
			}
		}
		
		
		/**
		 * Parses a string into an object. The string must have the format {key1: val1,
		 * key2: val2, key3: val3} and so on. Note that string type values in the object
		 * string should not be wrapped by any kind of quotation marks; internally all
		 * values are treated as Strings!
		 * 
		 * @private
		 * @param string The string to parse into an object.
		 * @return the object with the key/value pairs from the string or null if the string
		 *         could not be parsed into an object.
		 */
		private function parseObject(string:String):Object
		{
			/* String must start with {, end with }, contain at least one : and
			 * may not contain any {} in it's contents */
			if (string.match("^\\{.[^\\{\\}]*?[:]+.[^\\{\\}]*?\\}\\z"))
			{
				string = string.substr(1, string.length - 2);
				var a:Array = string.split(",");
				var o:Object = {};
				
				for (var i:String in a)
				{
					var d:Array = (a[i] as String).split(":");
					var p:RegExp = new RegExp("[ \n\t\r]", "g");
					var key:String = (d[0] as String).replace(p, "");
					var val:String = (d[1] as String).replace(p, "");
					o[key] = val;
				}
				return o;
			}
			else
			{
				Log.warn("Error parsing config! Malformed syntax in Object property: " + string, this);
				return null;
			}
		}
	}
}
