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
	import base.core.debug.Log;

	import flash.utils.Dictionary;
	
	
	/**
	 * KeyManager class
	 */
	public class KeyManager
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const KEY_COMBINATION_DELIMITER:String = "+";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _assignmentsDown:Dictionary;
		private var _assignmentsUp:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyManager()
		{
			_assignmentsDown = new Dictionary();
			_assignmentsUp = new Dictionary();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Assigns a key or key combination to a callback function.
		 * 
		 * @param keyCodes
		 * @param callback
		 * @param mode
		 */
		public function assign(keyCodes:*, callback:Function, mode:String):Boolean
		{
			var c:KeyCombination;
			if (keyCodes is String)
			{
				var codes:Array = getKeyCodes(keyCodes);
				if (codes != null)
				{
					c = new KeyCombination(codes);
				}
				else
				{
					fail("Could not extract keycodes values from keyCode string: \"" + keyCodes + "\".");
					return false;
				}
			}
			else if (keyCodes is int)
			{
				c = new KeyCombination([keyCodes]);
			}
			else if (keyCodes is Array)
			{
				c = new KeyCombination(keyCodes);
			}
			else if (keyCodes is KeyCombination)
			{
				c = keyCodes;
			}
			else
			{
				fail("Could not assign keycode that is not of type String, uint, Array or KeyCombination.");
				return false;
			}
			
			if (mode == KeyMode.DOWN)
			{
				_assignmentsDown[c] = callback;
			}
			else if (mode == KeyMode.UP)
			{
				_assignmentsUp[c] = callback;
			}
			else
			{
				fail("Could not assign keycode. Mode \"" + mode + "\" not recognized. Use KeyMode.DOWN or KeyMode.UP constants instead.");
				return false;
			}
			
			Log.debug("Assigned key codes " + keyCodes + " to callback " + callback, this);
			return true;
		}
		
		
		/**
		 * Returns an array of key code values that are created from the specified
		 * keyString. The keyString can contain one or more key names combined by the key
		 * combination delimiter (+), e.g. CTRL+SHIFT+A or just CTRL. If no valid key
		 * names or key combination was found it returns <code>null</code>.
		 * 
		 * @param keyString the string of keys to provide key codes from.
		 * @return an array comprising of the key codes or <code>null</code>.
		 */
		public static function getKeyCodes(keyString:String):Array
		{
			var a:Array = [];
			var keys:Array = keyString.split(KEY_COMBINATION_DELIMITER);
			for (var i:int = 0; i < keys.length; i++)
			{
				var c:int = KeyCodes.getKeyCode(keys[i]);
				if (c > -1) a.push(c);
			}
			if (a.length > 0) return a;
			return null;
		}
		
		
		/**
		 * @private
		 */
		public function checkKeyCode():void
		{
//			var code:uint = keyCodes[i];
//			if ("0123456789".indexOf(code.toString()) == -1)
//			{
//				throw new DataStructureException("A KeyCombination may only be"
//					+ " defined with number values.");
//				return;
//			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "KeyManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
