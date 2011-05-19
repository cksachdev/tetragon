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
	import base.Main;
	import base.core.debug.Log;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
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
		
		private var _stage:Stage;
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
			_stage = Main.instance.stage;
			_assignmentsDown = new Dictionary();
			_assignmentsUp = new Dictionary();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function activate():void
		{
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		}
		
		
		public function deactivate():void
		{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
		}
		
		
		/**
		 * Assigns a keyboard key or key combination to a callback function.
		 * 
		 * @param value The key value to assign. This can be one of the following
		 *        object types: String, int, Array or KeyCombination.
		 * @param callback The method that is called when the key or key combination
		 *        is triggered.
		 * @param mode The mode of the key assignment, either <code>KeyMode.DOWN</code> or
		 *        <code>KeyMode.UP</code>.
		 * @return true or false.
		 */
		public function assign(value:*, callback:Function, mode:String = KeyMode.DOWN):Boolean
		{
			var kc:KeyCombination = createKeyCombination(value);
			if (!kc) return false;
			if (mode == KeyMode.DOWN)
			{
				_assignmentsDown[kc] = callback;
			}
			else if (mode == KeyMode.UP)
			{
				_assignmentsUp[kc] = callback;
			}
			else
			{
				fail("Could not assign keycode. Mode \"" + mode + "\" not recognized. Use KeyMode.DOWN or KeyMode.UP constants instead.");
				return false;
			}
			Log.debug("Assigned key codes <" + value + "> (mode: " + mode + ").", this);
			return true;
		}
		
		
		/**
		 * Removes a keyboard key or key combination from the key manager. Note that
		 * if they key or key combination is assigned to more than one callback it
		 * will be removed from all callbacks it is assigned to.
		 * 
		 * @param keyCodes key codes that the key combination consists of.
		 */
		public function remove(value:*, callback:Function):Boolean
		{
			var kc1:KeyCombination = createKeyCombination(value);
			if (kc1) return false;
			for each (var kc2:KeyCombination in _assignmentsDown)
			{
				if (equals(kc1, kc2))
				{
					var cb:Function = _assignmentsDown[kc2];
					if (cb == callback)
					{
						delete _assignmentsDown[kc2];
						return true;
					}
				}
			}
			return false;
		}
		
		
		/**
		 * Clears all key assignments from the Key manager.
		 */
		public function clearAssignments():void
		{
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
		
		private function onKeyDown(e:KeyboardEvent):void
		{
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
		}
		
		
		private function onDeactivate(e:Event):void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the KeyCombination specified in the kc parameter is equal
		 * to this KeyCombination.
		 * 
		 * @param kc The KeyCombination class to compare to this class.
		 * @return true if the two KeyCombinations contain the same key codes in the
		 *          same order; otherwise false.
		 */
		private function equals(kc1:KeyCombination, kc2:KeyCombination):Boolean
		{
			if (kc1 == kc2) return true;
			var codes1:Vector.<uint> = kc1.keyCodes;
			var codes2:Vector.<uint> = kc2.keyCodes;
			var l:uint = codes1.length;
			if (l != codes2.length) return false;
			while (l--)
			{
				if (codes1[l] != codes2[l]) return false;
			}
			return true;
		}
		
		
		/**
		 * @private
		 */
		private function createKeyCombination(value:*):KeyCombination
		{
			if (value is String)
			{
				var codes:Array = getKeyCodes(value);
				if (codes != null)
				{
					return new KeyCombination(codes);
				}
				else
				{
					fail("Could not extract keycodes values from keyCode string: \"" + value + "\".");
					return null;
				}
			}
			else if (value is int)
			{
				return new KeyCombination([value]);
			}
			else if (value is Array)
			{
				new KeyCombination(value);
			}
			else if (value is KeyCombination)
			{
				return value;
			}
			else
			{
				fail("Could not assign keycode that is not of type String, uint, Array or KeyCombination.");
				return null;
			}
			return null;
		}
		
		
		/**
		 * @private
		 */
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
