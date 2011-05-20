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

	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.string.TabularText;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;
	
	
	/**
	 * KeyManager class
	 */
	public final class KeyManager
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const KEY_COMBINATION_DELIMITER:String = "+";
		
		//private static const KEY_CODE_SHIFT:uint = 16;
		//private static const KEY_CODE_CTRL:uint = 17;
		//private static const KEY_CODE_ALT:uint = 18;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stage:Stage;
		private var _assignmentsDown:Object;
		private var _assignmentsUp:Object;
		private var _keysDown:Object;
		private var _keysTyped:Vector.<uint>;
		private var _combsDown:Vector.<KeyCombination>;
		private var _combs:Vector.<KeyCombination>;
		private var _longestComb:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _keyDownSignal:Signal;
		private var _keyUpSignal:Signal;
		private var _keySequenceSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyManager()
		{
			_stage = Main.instance.stage;
			_assignmentsDown = {};
			_assignmentsUp = {};
			_keysDown = {};
			_keysTyped = new Vector.<uint>();
			_combsDown = new Vector.<KeyCombination>();
			_combs = new Vector.<KeyCombination>();
			_longestComb = 0;
			
			_keyDownSignal = new Signal();
			_keyUpSignal = new Signal();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Activates the key manager.
		 */
		public function activate():void
		{
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		}
		
		
		/**
		 * Deactivates the key manager.
		 */
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
		 *        object types: String, int, Array, Key or KeyCombination.
		 * @param callback The method that is called when the key or key combination
		 *        is triggered.
		 * @param mode The mode of the key assignment, either <code>KeyMode.DOWN</code> or
		 *        <code>KeyMode.UP</code>.
		 * @return true if the assignment succeeded, otherwise false.
		 */
		public function assign(value:*, callback:Function, mode:String = KeyMode.DOWN):Boolean
		{
			var assignment:IKeyAssignment;
			
			if (value is String) assignment = createAssignmentFromString(value);
			else if (value is uint) assignment = createAssignmentFromNumber(value);
			else if (value is Array) assignment = createAssignmentFromArray(value);
			else if (value is Key || value is KeyCombination) assignment = value;
			else
			{
				fail("Cannot assign key value that is not of type String, uint, Array,"
					+ " Key or KeyCombination.");
				return false;
			}
			if (!assignment) return false;
			assignment.callback = callback;
			if (mode == KeyMode.DOWN)
			{
				_assignmentsDown[assignment.id] = assignment;
			}
			else if (mode == KeyMode.UP)
			{
				_assignmentsUp[assignment.id] = assignment;
			}
			else
			{
				fail("Could not assign keycode. Mode \"" + mode + "\" not recognized. Use"
					+ " KeyMode.DOWN or KeyMode.UP constants instead.");
				return false;
			}
			_longestComb = Math.max(_longestComb, assignment.length);
			Log.debug("Assigned key codes <" + value + "> (mode: " + mode + ").", this);
			return true;
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
		
		
		public function dump():String
		{
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 80,
				["KEY(S)", "CODE(S)", "LENGTH", "ID"]);
			for each (var a:IKeyAssignment in _assignmentsDown)
			{
				var l:uint = a.length;
				var s:String;
				var string:String = "";
				var code:String = "";
				if (l == 1)
				{
					s = KeyCodes.getKeyString(a.code);
					if (s) string = s.toUpperCase();
					code = "" + a.code;
				}
				else
				{
					var kc:KeyCombination = KeyCombination(a);
					var keys:Vector.<Key> = kc.keys;
					var kl:uint = keys.length;
					for (var i:uint = 0; i < kl; i++)
					{
						var key:Key = keys[i];
						s = KeyCodes.getKeyString(key.code);
						if (s) string += s.toUpperCase() + (i < kl - 1 ? "+" : "");
						code += key.code  + (i < kl - 1 ? "," : "");
					}
					
				}
				t.add([string, code, l, a.id]);
			}
			return toString() + ": Key Assignments\n" + t;
		}
		
		
		/**
		 * Creates a single-key object from a string that defines a single key.
		 * 
		 * @see base.io.key.KeyCodes
		 * @param singleKeyString A string that defines a single key.
		 * @return A Key object or <code>null</code>.
		 */
		public static function createKey(singleKeyString:String):Key
		{
			if (singleKeyString == null || singleKeyString.length < 1) return null;
			var ks:String = singleKeyString.toLowerCase();
			var code:int = KeyCodes.getKeyCode(ks);
			if (code == -1) return null;
			var location:uint = KeyLocation.STANDARD;
			if (ks == "lshift" || ks == "lctrl" || ks == "lcontrol" || ks == "lalt")
				location = KeyLocation.LEFT;
			else if (ks == "rshift" || ks == "rctrl" || ks == "rcontrol" || ks == "ralt")
				location = KeyLocation.RIGHT;
			return new Key(code, location);
		}
		
		
		/**
		 * Creates a key-combination object from a string that defines multiple keys.
		 * 
		 * @see base.io.key.KeyCodes
		 * @param multiKeyString A string that defines a multiple keys, separated by the
		 *            <code>KeyManager.KEY_COMBINATION_DELIMITER</code> (+), e.g. CTRL+C.
		 * @return A KeyCombination object or <code>null</code>.
		 */
		public static function createKeyCombination(multiKeyString:String):KeyCombination
		{
			if (multiKeyString == null || multiKeyString.length < 1) return null;
			var keys:Array = [];
			var a:Array = multiKeyString.split(KEY_COMBINATION_DELIMITER);
			for (var i:uint = 0; i < a.length; i++)
			{
				var key:Key = createKey(a[i]);
				if (key) keys.push(key);
			}
			if (keys.length == 0) return null;
			return new KeyCombination(keys);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get keyDownSignal():Signal
		{
			return _keyDownSignal;
		}
		
		
		public function get keyUpSignal():Signal
		{
			return _keyUpSignal;
		}
		
		
		public function get keySequenceSignal():Signal
		{
			if (!_keySequenceSignal) _keySequenceSignal = new Signal();
			return _keySequenceSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			var keyID:String = "" + e.keyCode;
			var alreadyDown:Boolean = _keysDown[keyID];
			var l:uint = _combs.length;
			
			_keysDown[keyID] = true;
			_keysTyped.push(keyID);
			
			if (_keysTyped.length > _longestComb)
			{
				_keysTyped.splice(0, 1);
			}
			
			while (l--)
			{
				//checkTypedKeys(_combs[l]);
				//if (!alreadyDown) checkDownKeys(_combs[l]);
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			var keyID:String = "" + e.keyCode;
			var l:uint = _combsDown.length;
			
			while (l--)
			{
				//if (_combsDown[l].codes.indexOf(keyID) != -1)
				//{
				//	_keyUpSignal.dispatch();
				//	_combsDown.splice(l, 1);
				//}
			}
			delete _keysDown[keyID];
		}
		
		
		private function onDeactivate(e:Event):void
		{
			_keyUpSignal.dispatch();
			_combsDown = new Vector.<KeyCombination>();
			_keysDown = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function createAssignmentFromString(s:String):IKeyAssignment
		{
			if (s.length < 1)
			{
				fail("Cannot extract keycode values from an empty string.");
				return null;
			}
			if (s.indexOf("+") == -1)
			{
				var key:Key = createKey(s);
				if (!key)
				{
					fail("Could not create key object from key code string: \"" + s + "\".");
					return null;
				}
				return key;
			}
			else
			{
				var kc:KeyCombination = createKeyCombination(s);
				if (!kc)
				{
					fail("Could not create key combination object from key code string: \"" + s + "\".");
					return null;
				}
				return kc;
			}
		}
		
		
		private function createAssignmentFromNumber(n:Number):IKeyAssignment
		{
			var key:Key = createKey(n.toString());
			if (!key)
			{
				fail("Could not create key object from key code: \"" + n + "\".");
				return null;
			}
			return key;
		}
		
		
		private function createAssignmentFromArray(a:Array):IKeyAssignment
		{
			if (a.length < 1)
			{
				fail("Cannot extract keycode values from an empty array.");
				return null;
			}
			if (a.length == 1)
			{
			}
			else
			{
			}
			return null;
		}
		
		
		/**
		 * Returns a unique ID for the specified key code and key location.
		 * 
		 * @param keyCode
		 * @param keyLocation
		 * @return A unique key ID.
		 */
		//private function getKeyID(keyCode:uint, keyLocation:uint):String
		//{
		//	return keyCode + "_" + keyLocation;
		//}
		
		
		/**
		 * Determines if the KeyCombination specified in the kc parameter is equal
		 * to this KeyCombination.
		 * 
		 * @param kc The KeyCombination class to compare to this class.
		 * @return true if the two KeyCombinations contain the same key codes in the
		 *          same order; otherwise false.
		 */
//		private function equals(kc1:KeyCombination, kc2:KeyCombination):Boolean
//		{
//			if (kc1 == kc2) return true;
//			var codes1:Vector.<uint> = kc1.codes;
//			var codes2:Vector.<uint> = kc2.codes;
//			var l:uint = codes1.length;
//			if (l != codes2.length) return false;
//			while (l--)
//			{
//				if (codes1[l] != codes2[l]) return false;
//			}
//			return true;
//		}
		
		
		private function checkTypedKeys(kc:KeyCombination):void
		{
//			var c1:Vector.<uint> = kc.codes;
//			var l:uint = c1.length;
//			var c2:Vector.<uint> = _keysTyped.slice(-l);
//			var isEqual:Boolean = true;
//			if (l != c2.length)
//			{
//				isEqual = false;
//			}
//			else
//			{
//				while (l--)
//				{
//					if (c1[l] != c2[l]) isEqual = false;
//				}
//			}
//			
//			if (!isEqual) return;
//			if (_keySequenceSignal) _keySequenceSignal.dispatch();
		}
		
		
		private function checkDownKeys(kc:KeyCombination):void
		{
//			var uniqueCombination:Vector.<uint> = kc.codes.filter(duplicatesFilter);
//			var i:int = uniqueCombination.length;
//			while (i--)
//			{
//				if (!_keysDown[uniqueCombination[i]]) return;
//			}
//			_keyDownSignal.dispatch();
//			_combsDown.push(kc);
		}
		
		
		/**
		 * Used as filter function for removeDuplicates method.
		 * 
		 * @param e Item
		 * @param i Index
		 * @param v Vector
		 */
		private function duplicatesFilter(e:uint, i:int, v:Vector.<uint>):Boolean
		{
			return (i == 0) ? true : v.lastIndexOf(e, i - 1) == -1;
		}
		
		
		/**
		 * @private
		 */
		private function fail(message:String):Boolean
		{
			Log.error(message, this);
			return false;
		}
	}
}
