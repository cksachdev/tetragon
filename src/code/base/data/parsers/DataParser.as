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
package base.data.parsers
{
	import com.hexagonstar.util.string.createStringVector;
	import com.hexagonstar.util.string.unwrapString;

	import flash.events.EventDispatcher;
	import flash.system.System;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Abstract base class for data resource parsers.
	 */
	public class DataParser extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected var _xml:XML;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			CONFIG::IS_AIR_BUILD
			{
				System.disposeXML(_xml);
			}
			_xml = null;
		}
		
		
		/**
		 * Returns a string representation of the object.
		 * 
		 * @return A string representation of the object.
		 */
		override public function toString():String
		{
			return "[" + getQualifiedClassName(this).match("[^:]*$")[0] + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Extracts the value that is stored under an XML node name or XML attribute name
		 * specified with the xml and name arguments. The xml parameter can be an object
		 * of type XML or XMLList.
		 * 
		 * @private
		 * 
		 * @param xml The XML or XMLList on that to find 'name'.
		 * @param name The node or attribute name on the specified XML.
		 * @return The extracted value.
		 */
		protected static function extractString(xml:*, name:String = null):String
		{
			if (name != null)
			{
				var v:String = xml[name];
				if (v && v.length > 0) return v;
				return null;
			}
			return String(xml);
		}
		
		
		/**
		 * Extracts and unwraps text from an XML.
		 * @private
		 */
		protected static function extractText(xml:*, name:String = null):String
		{
			return unwrapString(extractString(xml, name));
		}
		
		
		/**
		 * @private
		 */
		protected static function extractNumber(xml:*, name:String):Number
		{
			return Number(extractString(xml, name));
		}
		
		
		/**
		 * @private
		 */
		protected static function extractBoolean(xml:*, name:String):Boolean
		{
			return parseBoolean(extractString(xml, name));
		}
		
		
		/**
		 * @private
		 */
		protected static function extractColorValue(xml:*, name:String):uint
		{
			return parseColorValue(extractString(xml, name));
		}
		
		
		/**
		 * Parses a string made of IDs into a String Vector. The IDs in the string must
		 * be separated by commata.
		 * 
		 * @private
		 * 
		 * @param string The string to parse ID values from.
		 * @return A Vector with string values.
		 */
		protected static function parseIDString(string:String):Vector.<String>
		{
			if (string == null || string.length == 0) return null;
			string = string.split(" ").join("");
			return createStringVector(string.split(","));
		}
		
		
		/**
		 * Parses a boolean string. If the specified string is 'true' the method
		 * returns true or if the string is 'false' or any other value it returns
		 * false. The string can be lowercase, uppercase or mixed case.
		 * 
		 * @private
		 * 
		 * @param string The string to convert into a boolean.
		 * @return either true or false.
		 */
		protected static function parseBoolean(string:String):Boolean
		{
			if (string == null) return false;
			if (string.toLowerCase() == "true") return true;
			return false;
		}
		
		
		/**
		 * Parses a string color value. The specified string needs to contain
		 * a hexadecimal color value either starting with a '#' or only consist
		 * of a hexadecimal value.
		 * 
		 * @private
		 * 
		 * @param string A String with a hexadecimal color value, e.g. #FF00FF.
		 * @return The color value as a uint typed number.
		 */
		protected static function parseColorValue(string:String):uint
		{
			if (string == null) return 0;
			if (string.substr(0, 1) == "#")
				string = string.substr(1, string.length - 1);
			else if (string.substr(0, 2).toLocaleLowerCase() == "0x")
				string = string.substr(2, string.length - 1);
			var r:uint = uint("0x" + string);
			return r;
		}
	}
}
