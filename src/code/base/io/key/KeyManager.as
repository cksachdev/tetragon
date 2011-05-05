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
	import base.event.KeyCombinationEvent;

	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	
	/**
	 * Manages Keyboard Input.
	 */
	public class KeyManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _key:Key;
		/** @private */
		private var _assignmentsDown:Dictionary;
		/** @private */
		private var _assignmentsRelease:Dictionary;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function KeyManager()
		{
			// TODO There is still a bug with KeyCombination when more than 3 keys are used!
			
			_assignmentsDown = new Dictionary();
			_assignmentsRelease = new Dictionary();
			
			_key = Key.instance;
			_key.addEventListener(KeyCombinationEvent.DOWN, onCombinationDown);
			_key.addEventListener(KeyCombinationEvent.RELEASE, onCombinationRelease);
			_key.addEventListener(KeyCombinationEvent.SEQUENCE, onCombinationTyped);
			_key.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_key.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Assigns a new Key Combination to the KeyManager.
		 * 
		 * @param keyCodes key codes that the key combination consists of.
		 * @param callback the function that should be called when the combination is entered.
		 * @param isRelease true if key comb is triggered when pressed keys are released.
		 */
		public function assignKeyCombination(keyCodes:Array,
											  callback:Function,
											  isRelease:Boolean = false):void
		{
			var c:KeyCombination = new KeyCombination(keyCodes);
			if (isRelease)
			{
				_assignmentsRelease[c] = callback;
			}
			else
			{
				_assignmentsDown[c] = callback;
			}
			_key.addKeyCombination(c);
		}
		
		
		/**
		 * Removes a Key Combination from the KeyManager.
		 * 
		 * @param keyCodes key codes that the key combination consists of.
		 */
		public function removeKeyCombination(keyCodes:Array):void
		{
			var c:KeyCombination = new KeyCombination(keyCodes);
			_assignmentsRelease[c] = null;
			_assignmentsDown[c] = null;
			delete _assignmentsRelease[c];
			delete _assignmentsDown[c];
			
			_key.removeKeyCombination(c);
		}
		
		
		/**
		 * Clears all key assignments from the Key manager.
		 */
		public function clearAssignments():void
		{
			for (var c1:Object in _assignmentsDown)
			{
				if (c1 is KeyCombination)
				{
					_key.removeKeyCombination(KeyCombination(c1));
				}
			}
			_assignmentsDown = new Dictionary();
			
			for (var c2:Object in _assignmentsRelease)
			{
				if (c2 is KeyCombination)
				{
					_key.removeKeyCombination(KeyCombination(c2));
				}
			}
			_assignmentsRelease = new Dictionary();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onCombinationDown(e:KeyCombinationEvent):void
		{
			for (var c:Object in _assignmentsDown)
			{
				if (c is KeyCombination)
				{
					if (e.keyCombination.equals(KeyCombination(c)))
					{
						var callback:Function = _assignmentsDown[c];
						callback.apply(null);
						break;
					}
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function onCombinationRelease(e:KeyCombinationEvent):void
		{
			for (var c:Object in _assignmentsRelease)
			{
				if (c is KeyCombination)
				{
					if (e.keyCombination.equals(KeyCombination(c)))
					{
						var callback:Function = _assignmentsRelease[c];
						callback.apply(null);
						break;
					}
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function onCombinationTyped(e:KeyCombinationEvent):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onKeyDown(e:KeyboardEvent):void
		{
		}
		
		
		/**
		 * @private
		 */
		private function onKeyUp(e:KeyboardEvent):void
		{
		}
	}
}
