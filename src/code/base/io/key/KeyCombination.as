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
package base.io.key
{
	/**
	 * Represents a combination of keys that are being pressed or held down at the
	 * same time.
	 */
	public final class KeyCombination implements IKeyAssignment
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _id:String;
		private var _keys:Vector.<Key>;
		private var _callback:Function;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyCombination(keys:Array)
		{
			_id = "";
			_keys = new Vector.<Key>();
			var len:uint = keys.length;
			for (var i:uint = 0; i < len; i++)
			{
				var key:Key = keys[i];
				_id += key.id + (i < len - 1 ? "_" : "");
				_keys.push(key);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get id():String
		{
			return _id;
		}
		
		
		public function get code():uint
		{
			return 0;
		}
		
		
		public function get keys():Vector.<Key>
		{
			return _keys;
		}
		
		
		/**
		 * The length of the key combination, i.e. how many keys are in it.
		 */
		public function get length():uint
		{
			return _keys.length;
		}
		
		
		public function get callback():Function
		{
			return _callback;
		}
		public function set callback(v:Function):void
		{
			_callback = v;
		}
	}
}
