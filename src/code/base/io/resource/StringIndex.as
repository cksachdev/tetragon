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
package base.io.resource
{
	import com.hexagonstar.display.text.ColumnText;

	
	/**
	 * A Hashmap that stores strings.
	 */
	public class StringIndex
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _strings:Object;
		private var _size:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function StringIndex()
		{
			clear();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a string to the index.
		 */
		public function add(id:String, string:String, resource:Resource):void
		{
			if (_strings[id] == null) _size++;
			else delete _strings[id];
			_strings[id] = string;
			
			if (resource.content == null) resource.setContent([]);
			(resource.content as Array).push(id);
		}
		
		
		/**
		 * @private
		 */
		public function contains(stringID:String):Boolean
		{
			return _strings[stringID] != null;
		}
		
		
		/**
		 * getString
		 */
		public function get(stringID:String):String
		{
			return _strings[stringID];
		}
		
		
		/**
		 * remove
		 */
		public function remove(stringID:String):void
		{
			if (_strings[stringID])
			{
				_strings[stringID] = null;
				delete _strings[stringID];
				_size--;
			}
		}
		
		
		/**
		 * Removes all strings from the string index that are stored by any of the IDs
		 * in the specified array. Used by the resource manager to unload strings when
		 * a text resource is unloaded.
		 */
		public function removeStrings(stringIDs:Array):void
		{
			for each (var id:String in stringIDs)
			{
				remove(id);
			}
		}
		
		
		/**
		 * removeAll
		 */
		public function removeAll():void
		{
			for (var id:String in _strings)
			{
				remove(id);
			}
		}
		
		
		/**
		 * clear
		 */
		public function clear():void
		{
			_strings = {};
			_size = 0;
		}
		
		
		/**
		 * dump
		 */
		public function dump():String
		{
			var t:ColumnText = new ColumnText(2, true, "  ", null, "  ", 100, ["ID", "STRING"]);
			for (var s:String in _strings)
			{
				t.add([s, _strings[s]]);
			}
			return toString() + "\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "[StringIndex, size=" + _size + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function get size():int
		{
			return _size;
		}
	}
}
