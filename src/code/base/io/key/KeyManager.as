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
	import base.data.Config;
	import base.data.Registry;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	
	
	/**
	 * KeyManager class
	 */
	public final class KeyManager
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A string that is used in key combinations to divide between single keys
		 * in the combination.
		 */
		public static const KEY_COMBINATION_DELIMITER:String = "+";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stage:Stage;
		private var _assignments:Object;
		private var _keysDown:Object;
		private var _combinationsDown:Object;
		private var _keysTyped:Vector.<uint>;
		private var _longestCombination:int;
		
		private var _active:Boolean;
		private var _consoleFocussed:Boolean;
		private var _consoleKC:KeyCombination;
		private var _fpsMonKC:KeyCombination;
		private var _fpsMonPosKC:KeyCombination;
		
		private var _lastShiftKeyLocation:uint;
		private var _lastCtrlKeyLocation:uint;
		private var _lastAltKeyLocation:uint;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyManager()
		{
			_stage = Main.instance.stage;
			_active = false;
			_consoleFocussed = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the key manager. This clears all key assignments if there are any and
		 * then assigns some default key combinations that are used for the engine.
		 */
		public function init():void
		{
			clearAssignments();
		}
		
		
		/**
		 * Activates the key manager.
		 */
		public function activate():void
		{
			if (_active) return;
			_active = true;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		}
		
		
		/**
		 * Deactivates the key manager.
		 */
		public function deactivate():void
		{
			if (!_active) return;
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
			_active = false;
		}
		
		
		/**
		 * Assigns a keyboard key or key combination to a callback function. The specified
		 * <code>keyValue</code> can be either a <code>String</code>, a <code>uint</code>,
		 * a <code>KeyCombination</code> object or an <code>Array</code>.
		 * 
		 * <p>By specifying a <code>String</code> you can assign a key combination which
		 * determines that the exact keys in this combination need to be pressed to
		 * trigger the callback. The String can contain one or more key identifiers which
		 * are divided by the <code>KEY_COMBINATION_DELIMITER</code> constant (a plus sign
		 * '+'), for example <code>F1</code>, <code>CTRL+A</code> or
		 * <code>SHIFT+CTRL+1</code>.</p>
		 * 
		 * <p>By specifying a <code>uint</code> you can assign one key by it's key code
		 * directly. With this you can also use the numeric contants from ActionScript's
		 * native Keyboard class.</p>
		 * 
		 * <p>By specifying a <code>KeyCombination</code> object the key manager assigns
		 * the KeyCombination object with the key codes that are already listed in the
		 * KeyCombination.</p>
		 * 
		 * <p>By specifying an Array you can assign multiple key combinations to the same
		 * callback. The Array can contain a combination of String key identifiers, uints
		 * and/or KeyCombination objects.</p>
		 * 
		 * @see base.io.key.KeyCodes
		 * 
		 * @param keyValue The key value to assign. This can be one of the following
		 *            object types: String, uint, KeyCombination or Array.
		 * @param mode The mode of the key assignment that determines when the callback is
		 *            triggered, either when the key is pressed or released. You can use
		 *            either <code>KeyMode.DOWN</code> or <code>KeyMode.UP</code> or
		 *            numbers 0 (down) or 1 (up).
		 * @param callback The method that is called when the key or key combination is
		 *            triggered.
		 * @param params A list of optional parameters that are provided as arguments to
		 *            the callback function.
		 * @return A <code>KeyCombination</code> object or <code>null</code>. If the
		 *         assignment succeeded the resulting <code>KeyCombination</code> object
		 *         is returned, if the assignment failed <code>null</code> is returned. If
		 *         the specified <code>keyValue</code> is an <code>Array</code> only the
		 *         last successful assignment from the arrays' containing key values is
		 *         returned. if all assignments from the array failed, <code>null</code>
		 *         is returned.
		 */
		public function assign(keyValue:*, mode:int, callback:Function, ...params):KeyCombination
		{
			return assign2(keyValue, mode, callback, params);
		}
		
		
		/**
		 * Removes a key assigment from the key manager.
		 */
		public function remove():void
		{
			// TODO
		}
		
		
		/**
		 * Clears all key assignments from the key manager.
		 */
		public function clearAssignments():void
		{
			var wasActive:Boolean = _active;
			deactivate();
			_assignments = {};
			_keysDown = {};
			_combinationsDown = {};
			_keysTyped = new Vector.<uint>();
			_longestCombination = 0;
			assignDefaults();
			if (wasActive) activate();
		}
		
		
		/**
		 * Generates an ID for the specified KeyCombination object.
		 */
		public static function getKeyCombinationID(kc:KeyCombination):String
		{
			var id:String = "";
			var codes:Vector.<uint> = kc.codes;
			for (var i:uint = 0; i < codes.length; i++)
			{
				id += codes[i] + "-";
			}
			return id + kc.mode;
		}
		
		
		/**
		 * Creates a key-combination object from a string that defines one or multiple
		 * keys or a key code.
		 * 
		 * @see base.io.key.KeyCodes
		 * @param keyString A string that defines a key identifier or multiple key
		 *            identifiers, separated by the
		 *            <code>KeyManager.KEY_COMBINATION_DELIMITER</code> (+), e.g. CTRL+C.
		 * @param isCode Set this to true if the specified keyString is a key code that
		 *            should be used directly.
		 * @return A KeyCombination object or <code>null</code>.
		 */
		public static function createKeyCombination(keyString:String,
			isCode:Boolean = false):KeyCombination
		{
			if (keyString == null || keyString.length < 1) return null;
			var kc:KeyCombination = new KeyCombination();
			var codes:Vector.<uint>;
			if (isCode)
			{
				codes = new Vector.<uint>(1, true);
				codes[0] = uint(keyString);
			}
			else
			{
				var a:Array = keyString.split(KEY_COMBINATION_DELIMITER);
				codes = new Vector.<uint>(a.length, true);
				for (var i:uint = 0; i < codes.length; i++)
				{
					var ks:String = String(a[i]).toLowerCase();
					var code:int = KeyCodes.getKeyCode(ks);
					if (code == -1) return null;
					if (ks == "lshift") kc.shiftKeyLocation = KeyLocation.LEFT;
					else if (ks == "rshift") kc.shiftKeyLocation = KeyLocation.RIGHT;
					else if (ks == "lctrl" || ks == "lcontrol") kc.ctrlKeyLocation = KeyLocation.LEFT;
					else if (ks == "rctrl" || ks == "rcontrol") kc.ctrlKeyLocation = KeyLocation.RIGHT;
					else if (ks == "lalt") kc.altKeyLocation = KeyLocation.LEFT;
					else if (ks == "ralt") kc.altKeyLocation = KeyLocation.RIGHT;
					codes[i] = code;
				}
			}
			kc.codes = codes;
			kc.hasShiftKey = codes.indexOf(Keyboard.SHIFT) != -1;
			kc.hasCtrlKey = codes.indexOf(Keyboard.CONTROL) != -1;
			kc.hasAltKey = codes.indexOf(Keyboard.ALTERNATE) != -1;
			return kc;
		}
		
		
		/**
		 * Returns a String representation of the class.
		 * 
		 * @return A String representation of the class.
		 */
		public function toString():String
		{
			return "KeyManager";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the console currently has focus or not. This is set
		 * automatically by the console whenever it gains or looses key focus.
		 */
		public function get consoleFocussed():Boolean
		{
			return _consoleFocussed;
		}
		public function set consoleFocussed(v:Boolean):void
		{
			_consoleFocussed = v;
		}
		
		
		/**
		 * An map that contains all assigned KeyCombination objects mapped by their ID.
		 */
		public function get assignments():Object
		{
			return _assignments;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			var isAlreadyDown:Boolean = _keysDown[e.keyCode];
			
			/* Store all keys that are currently pressed. */
			_keysDown[e.keyCode] = true;
			
			/* Store typed keys for sequence checking. */
			//_keysTyped.push(e.keyCode);
			//if (_keysTyped.length > _longestCombination)
			//{
			//	_keysTyped.splice(0, 1);
			//}
			
			if (isAlreadyDown) return;
			
			/* Store last used modifier keys if any of them are pressed. We can't use
			 * e.shiftKey etc. here and have to fallback checking key codes. */
			if (e.keyCode == 16 && _lastShiftKeyLocation == 0) _lastShiftKeyLocation = e.keyLocation;
			else if (e.keyCode == 17 && _lastCtrlKeyLocation == 0) _lastCtrlKeyLocation = e.keyLocation;
			else if (e.keyCode == 18 && _lastAltKeyLocation == 0) _lastAltKeyLocation = e.keyLocation;
			
			/* loop through all key combinations and check if any of them are pressed. */
			for each (var kc:KeyCombination in _assignments)
			{
				//checkTypedKeys(kc);
				
				/* If modifier keys are pressed we have to filter out any other keys
				 * that might have a single key code assignment but also have an
				 * assignment together with the mod key or we might end up triggering
				 * only the single code one if it's found before the multi-code one. */
				if (e.shiftKey && !kc.hasShiftKey) continue;
				if (e.ctrlKey && !kc.hasCtrlKey) continue;
				if (e.altKey && !kc.hasAltKey) continue;
				
				/* Filter any key combinations if their modifier key location matters and
				 * we don't have that key location pressed. */
				if (_lastShiftKeyLocation > 0 && kc.shiftKeyLocation != _lastShiftKeyLocation) continue;
				if (_lastCtrlKeyLocation > 0 && kc.ctrlKeyLocation != _lastCtrlKeyLocation) continue;
				if (_lastAltKeyLocation > 0 && kc.altKeyLocation != _lastAltKeyLocation) continue;
				
				/* Remove duplicate characters from entered key sequences. */
				var uniqueCodes:Vector.<uint> = kc.codes.filter(
					function (e:uint, i:int, v:Vector.<uint>):Boolean
					{return (i == 0) ? true : v.lastIndexOf(e, i - 1) == -1;});
				
				var i:int = uniqueCodes.length;
				var isUnique:Boolean = true;
				while (i--)
				{
					if (!_keysDown[uniqueCodes[i]])
					{
						isUnique = false;
						break;
					}
				}
				if (!isUnique) continue;
				
				/* While console is focussed, only allow console-related keys! */
				if (_consoleFocussed && !(kc == _consoleKC || _fpsMonKC && (kc == _fpsMonKC || kc == _fpsMonPosKC)))
				{
					continue;
				}
				
				/* Store combination in currently pressed combinations list. */
				_combinationsDown[kc.id] = kc;
				
				/* Loop through all currently pressed combinations and check if any of them
				 * still has a callback to trigger. */
				for each (var cd:KeyCombination in _combinationsDown)
				{
					//Debug.trace("down: " + cd.id);
					if (!cd.isTriggered && cd.mode < 2)
					{
						if (cd.mode == 0) cd.isTriggered = true;
						else if (cd.mode == 1) delete _keysDown[e.keyCode];
						//Debug.trace("triggered: " + cd.id);
						if (cd.params) cd.callback.apply(null, cd.params);
						else cd.callback();
					}
				}
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			/* Clear last used modifier keys if any of them is released. */
			if (e.keyCode == 16) _lastShiftKeyLocation = 0;
			else if (e.keyCode == 17) _lastCtrlKeyLocation = 0;
			else if (e.keyCode == 18) _lastAltKeyLocation = 0;
			
			for each (var kc:KeyCombination in _combinationsDown)
			{
				if (kc.codes.indexOf(e.keyCode) != -1)
				{
					if (kc.mode == 2)
					{
						if (kc.params) kc.callback.apply(null, kc.params);
						else kc.callback();
					}
					kc.isTriggered = false;
					delete _combinationsDown[kc.id];
				}
			}
			delete _keysDown[e.keyCode];
		}
		
		
		private function onDeactivate(e:Event):void
		{
			_combinationsDown = {};
			_keysDown = {};
			_lastShiftKeyLocation = _lastCtrlKeyLocation = _lastAltKeyLocation = 0;
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
			// TODO
			//dispatchEvent(new KeyCombinationEvent(KeyCombinationEvent.SEQUENCE, kc));
		}
		
		
		/**
		 * Internal assign method used by the public assign API. This method exists so that
		 * any params arrays are 'unwrapped' and don't result in arrays wrapped into arrays
		 * if we do assignments that happen by iteration due to an Array keyValue.
		 * 
		 * However by using a second method that takes the params explicitly as an Array
		 * object we can iterate the method without causing nested params arrays. On the
		 * other hand we can still use the ...rest operator on the public assign method.
		 */
		private function assign2(keyValue:*, mode:int, callback:Function, params:Array):KeyCombination
		{
			var combination:KeyCombination;
			if (keyValue is String)
				combination = createKeyCombination(keyValue);
			else if (keyValue is uint)
				combination = createKeyCombination(String(keyValue), true);
			else if (keyValue is KeyCombination)
				combination = keyValue;
			else if (keyValue is Array)
			{
				var a:Array = keyValue;
				if (a.length > 0)
				{
					var kc:KeyCombination;
					for (var i:uint = 0; i < a.length; i++)
					{
						var result:KeyCombination = assign2(a[i], mode, callback, params);
						if (result) kc = result;
					}
					return kc;
				}
			}
			
			if (!combination)
			{
				fail("Could not assign key combination for key value: \"" + keyValue + "\".");
				return null;
			}
			
			combination.mode = mode < 0 ? 0 : mode > 3 ? 3 : mode;
			combination.callback = callback;
			if (params && params.length > 0) combination.params = params;
			
			var id:String = getKeyCombinationID(combination);
			if (_assignments[id])
			{
				Log.warn("A key combination with the ID \"" + id + "\" has already been assigned."
					+ " New assignment for key value [" + keyValue + "] was ignored.", this);
				return null;
			}
			
			combination.id = id;
			_assignments[id] = combination;
			_longestCombination = Math.max(_longestCombination, combination.codes.length);
			Log.debug("Assigned key codes <" + keyValue + "> (mode: " + mode + ").", this);
			return combination;
		}
		
		
		/**
		 * Assigns several default key combinations that are used by the application to
		 * make it possible to use the debug console, fps monitor etc.
		 */
		private function assignDefaults():void
		{
			var main:Main = Main.instance;
			var cfg:Config = Registry.config;
			if (Registry.config.consoleEnabled)
			{
				_consoleKC = assign(cfg.consoleKey, KeyMode.DOWN, main.console.toggle);
			}
			
			if (Registry.config.fpsMonitorEnabled)
			{
				_fpsMonKC = assign(cfg.fpsMonitorKey, KeyMode.DOWN, main.fpsMonitor.toggle);
				_fpsMonPosKC = assign(cfg.fpsMonitorPositionKey, KeyMode.DOWN, main.fpsMonitor.togglePosition);
			}
		}
		
		
		/**
		 * Sends an error message to the logger.
		 */
		private function fail(message:String):void
		{
			Log.error(message, this);
		}
	}
}
