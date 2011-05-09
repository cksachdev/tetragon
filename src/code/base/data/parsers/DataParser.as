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
	import base.core.debug.Log;

	import com.hexagonstar.util.reflection.getClassName;
	import com.hexagonstar.util.string.createStringVector;
	import com.hexagonstar.util.string.unwrapString;

	import flash.system.System;
	
	
	/**
	 * Abstract base class for data resource parsers.
	 */
	public class DataParser
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected var _xml:XML;
		
		/**
		 * @private
		 */
		protected var _referencedIDs:Object;
		
		
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
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * If the parsed data contains any referenced IDs they will be mapped into
		 * this object for using them with referenced resource loading.
		 */
		public function get referencedIDs():Object
		{
			return _referencedIDs;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Checks if the given key is a referenced resource ID and if necessary
		 * modifies the key and stores the referenced ID in the referencedIDs map.
		 * 
		 * @private
		 * 
		 * @param key The resource ID property key to check.
		 * @param value The resource property's value.
		 * @return The modified or unmodified key.
		 */
		protected function checkReferencedID(key:String, value:String):String
		{
			var s:String = key.substr(-3);
			var sid:String = null;
			switch (s)
			{
				case "TID":
				case "DID":
				case "LID":
					sid = s.toLowerCase();
					key = key.substr(0, key.length - 3) + "ID";
			}
			
			if (value == null || value == "")
			{
				return key;
			}
			
			if (sid)
			{
				if (!_referencedIDs) _referencedIDs = {};
				_referencedIDs[value] = sid;
			}
			
			return key;
		}
		
		
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
		
		
		/**
		 * Trims whitespace from the start and end of the specified string.
		 * @private
		 */
		protected static function trim(s:String):String
		{
			return s.replace(/^[ \t]+|[ \t]+$/g, "");
		}
		
		
		/**
		 * Parses a parameter string for a complex data type.
		 * @private
		 */
		protected static function parseComplexTypeParams(type:Object, params:String):Object
		{
			var len:int = params.length;
			var quotesCount:int = 0;
			var isInsideQuotes:Boolean = false;
			var current:String;
			var segment:String = "";
			var segments:Array = [];
			
			for (var i:int = 0; i < len; i++)
			{
				current = params.charAt(i);
				
				/* Check if we're inside quotes. */
				if (current == "\"")
				{
					quotesCount++;
					if (quotesCount == 1)
					{
						isInsideQuotes = true;
					}
					else if (quotesCount == 2)
					{
						quotesCount = 0;
						isInsideQuotes = false;
					}
				}
				
				/* Remove all whitespace unless we're inside quotes. */
				if (isInsideQuotes || current != " ")
				{
					segment += current;
				}
				
				/* Split the string where comma occurs, but not inside quotes. */
				if (!isInsideQuotes && current == ",")
				{
					/* Remove last char from segment which must be a comma. */
					segment = segment.substr(0, segment.length - 1);
					segments.push(segment);
					segment = "";
				}
				
				/* Last segment needs to be added extra. */
				if (i == len - 1)
				{
					segments.push(segment);
				}
			}
			
			/* Parse Array objects. */
			if (type is Array)
			{
				for each (segment in segments)
				{
					(type as Array).push(segment);
				}
			}
			/* Parse any other objects that must be made up of key-value pairs. */
			else
			{
				/* Loop through segments and split them into property and value. */
				for each (segment in segments)
				{
					var a:Array = segment.split(":");
					var p:String = a[0];
					var v:String = a[1];
					
					/* If value is wrapped into quotes we need to remove these. */
					if (v.charAt(0) == "\"" && v.charAt(v.length - 1) == "\"")
					{
						v = v.substr(1, v.length - 2);
					}
					
					if (type.hasOwnProperty(p))
					{
						if (v == "") type[p] = null;
						else type[p] = v;
					}
					else
					{
						Log.warn("DataParser: Tried to set a non-existing property <"
							+ p + "> in complex type " + type + ".");
					}
				}
			}
			
			return type;
		}
	}
}
