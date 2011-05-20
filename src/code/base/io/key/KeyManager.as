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
	import base.data.Registry;

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
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stage:Stage;
		private var _assignments:Object;
		private var _keysDown:Object;
		private var _keysTyped:Vector.<uint>;
		private var _combinationsDown:Vector.<KeyCombination>;
		private var _longestCombination:int;
		
		private var _consoleKeyCombination:KeyCombination;
		private var _consoleFocussed:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyManager()
		{
			_stage = Main.instance.stage;
			_assignments = {};
			_keysDown = {};
			_keysTyped = new Vector.<uint>();
			_combinationsDown = new Vector.<KeyCombination>();
			_longestCombination = 0;
			_consoleFocussed = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function init():void
		{
			clearAssignments();
			if (Registry.config.consoleEnabled)
			{
				_consoleKeyCombination = assign(Registry.config.consoleKey, Main.instance.console.toggle);
			}
			
			if (Registry.config.fpsMonitorEnabled)
			{
				assign(Registry.config.fpsMonitorKey, Main.instance.fpsMonitor.toggle);
				assign(Registry.config.fpsMonitorPositionKey, Main.instance.fpsMonitor.togglePosition);
			}
		}
		
		
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
		 *        object types: String, Number, Array, Key or KeyCombination.
		 * @param callback The method that is called when the key or key combination
		 *        is triggered.
		 * @param mode The mode of the key assignment, either <code>KeyMode.DOWN</code> or
		 *        <code>KeyMode.UP</code>.
		 * @return true if the assignment succeeded, otherwise false.
		 */
		public function assign(value:*, callback:Function, params:Array = null, mode:String = KeyMode.DOWN):KeyCombination
		{
			var combination:KeyCombination;
			
			if (value is String)
			{
				var s:String = value;
				if (s.length > 0) combination = createKeyCombination(s);
			}
			else if (value is Number)
			{
				combination = createKeyCombination(Number(value).toString());
			}
			else if (value is Array)
			{
				var a:Array = value;
				if (a.length > 0) {}// TODO
			}
			else if (value is Key || value is KeyCombination)
			{
				combination = value;
			}
			
			if (!combination)
			{
				fail("Could not assign key combination for value: \"" + value + "\".");
				return null;
			}
			
			combination.mode = mode;
			combination.callback = callback;
			if (params && params.length > 0) combination.params = params;
			_assignments[combination.id] = combination;
			_longestCombination = Math.max(_longestCombination, combination.length);
			Log.debug("Assigned key codes <" + value + "> (mode: " + mode + ").", this);
			return combination;
		}
		
		
		/**
		 * Clears all key assignments from the Key manager.
		 */
		public function clearAssignments():void
		{
			// TODO
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
			var t:TabularText = new TabularText(5, true, "  ", null, "  ", 80,
				["KEY(S)", "CODE(S)", "LENGTH", "MODE", "ID"]);
			for each (var kc:KeyCombination in _assignments)
			{
				var s:String;
				var string:String = "";
				var code:String = "";
				var codes:Vector.<uint> = kc.codes;
				var kl:uint = codes.length;
				for (var i:uint = 0; i < kl; i++)
				{
					var c:uint = codes[i];
					s = KeyCodes.getKeyString(c);
					if (s) string += s.toUpperCase() + (i < kl - 1 ? "+" : "");
					code += c + (i < kl - 1 ? "," : "");
				}
				t.add([string, code, kc.length, kc.mode, kc.id]);
			}
			return toString() + ": Key Assignments\n" + t;
		}
		
		
		/**
		 * Creates a key-combination object from a string that defines multiple keys.
		 * 
		 * @see base.io.key.KeyCodes
		 * @param multiKeyString A string that defines a multiple keys, separated by the
		 *            <code>KeyManager.KEY_COMBINATION_DELIMITER</code> (+), e.g. CTRL+C.
		 * @return A KeyCombination object or <code>null</code>.
		 */
		public static function createKeyCombination(keyString:String):KeyCombination
		{
			if (keyString == null || keyString.length < 1) return null;
			var keys:Array = [];
			var a:Array = keyString.split(KEY_COMBINATION_DELIMITER);
			for (var i:uint = 0; i < a.length; i++)
			{
				var ks:String = String(a[i]).toLowerCase();
				var code:int = KeyCodes.getKeyCode(ks);
				if (code == -1) return null;
				var location:uint = KeyLocation.STANDARD;
				if (ks == "lshift" || ks == "lctrl" || ks == "lcontrol" || ks == "lalt")
					location = KeyLocation.LEFT;
				else if (ks == "rshift" || ks == "rctrl" || ks == "rcontrol" || ks == "ralt")
					location = KeyLocation.RIGHT;
				keys.push(code);
			}
			if (keys.length == 0) return null;
			return new KeyCombination(keys);
		}
		
		
		/**
		 * Creates a single-key object from a string that defines a single key.
		 * 
		 * @see base.io.key.KeyCodes
		 * @param singleKeyString A string that defines a single key.
		 * @return A Key object or <code>null</code>.
		 */
		//public static function createKey(singleKeyString:String):Key
		//{
		//	if (singleKeyString == null || singleKeyString.length < 1) return null;
		//	var ks:String = singleKeyString.toLowerCase();
		//	var code:int = KeyCodes.getKeyCode(ks);
		//	if (code == -1) return null;
		//	var location:uint = KeyLocation.STANDARD;
		//	if (ks == "lshift" || ks == "lctrl" || ks == "lcontrol" || ks == "lalt")
		//		location = KeyLocation.LEFT;
		//	else if (ks == "rshift" || ks == "rctrl" || ks == "rcontrol" || ks == "ralt")
		//		location = KeyLocation.RIGHT;
		//	return new Key(code, location);
		//}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get consoleFocussed():Boolean
		{
			return _consoleFocussed;
		}
		public function set consoleFocussed(v:Boolean):void
		{
			_consoleFocussed = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (_consoleFocussed) return;
			
			var alreadyDown:Boolean = _keysDown[e.keyCode];
			_keysDown[e.keyCode] = true;
			_keysTyped.push(e.keyCode);
			
			if (_keysTyped.length > _longestCombination)
			{
				_keysTyped.splice(0, 1);
			}
			
			for each (var kc:KeyCombination in _assignments)
			{
				checkTypedKeys(kc);
				if (!alreadyDown) checkDownKeys(kc);
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			var i:int = _combinationsDown.length;
			while (i--)
			{
				if (_combinationsDown[i].mode == KeyMode.UP)
				{
					var cb:Function = _combinationsDown[i].callback;
					if (cb != null) cb();
				}
				if (_combinationsDown[i].codes.indexOf(e.keyCode) != -1)
				{
					_combinationsDown.splice(i, 1);
				}
			}
			delete _keysDown[e.keyCode];
		}
		
		
		private function onDeactivate(e:Event):void
		{
			_combinationsDown = new Vector.<KeyCombination>();
			_keysDown = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function checkTypedKeys(kc:KeyCombination):void
		{
			var c1:Vector.<uint> = kc.codes;
			var i:int = c1.length;
			var c2:Vector.<uint> = _keysTyped.slice(-i);
			if (i != c2.length) return;
			var isEqual:Boolean = true;
			while (i--)
			{
				if (c1[i] != c2[i]) isEqual = false;
			}
			
			if (isEqual) return;
			//dispatchEvent(new KeyCombinationEvent(KeyCombinationEvent.SEQUENCE, kc));
		}
		
		
		private function checkDownKeys(kc:KeyCombination):void
		{
			var uniqueCombination:Vector.<uint> = kc.codes.filter(duplicatesFilter);
			var i:int = uniqueCombination.length;
			while (i--)
			{
				if (!_keysDown[uniqueCombination[i]]) return;
			}
			_combinationsDown.push(kc);
			for (i = 0; i < _combinationsDown.length; i++)
			{
				if (_combinationsDown[i].mode == KeyMode.DOWN)
				{
					var cb:Function = _combinationsDown[i].callback;
					if (cb != null)
					{
						var p:Array = _combinationsDown[i].params;
						if (p) cb.apply(null, p);
						else cb();
					}
				}
			}
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
		
		
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
