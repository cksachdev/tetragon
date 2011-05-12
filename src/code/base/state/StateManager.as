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
package base.state
{
	import base.core.debug.Log;
	import base.data.Registry;

	import com.hexagonstar.util.string.TabularText;
	
	
	/**
	 * StateManager class
	 */
	public class StateManager
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _stateClasses:Object;
		private var _currentStateClass:Class;
		private var _currentState:State;
		private var _nextState:State;
		private var _isSwitching:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function StateManager()
		{
			_stateClasses = {};
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a state class for use with the state manager.
		 * 
		 * @param stateID
		 * @param stateClass
		 */
		public function registerState(stateID:String, stateClass:Class):void
		{
			_stateClasses[stateID] = stateClass;
		}
		
		
		/**
		 * Starts the state manager.
		 */
		public function start():void
		{
			var showSplashScreen:Boolean = Registry.settings.getSettings("showSplashScreen");
			var splashStateID:String = Registry.settings.getSettings("splashStateID");
			var initialStateID:String = Registry.settings.getSettings("initialStateID");
			
			if (showSplashScreen && splashStateID != null && splashStateID.length > 0)
			{
				enterState(splashStateID);
			}
			else if (initialStateID != null && initialStateID.length > 0)
			{
				enterState(initialStateID);
			}
			else
			{
				Log.fatal("Cannot open initial state! No initial state ID defined.", this);
			}
		}
		
		
		/**
		 * Enters the state with the specified stateID.
		 */
		public function enterState(stateID:String):void
		{
			var stateClass:Class = _stateClasses[stateID];
			if (stateClass == null)
			{
				Log.error("Could not enter state with ID \"" + stateID
					+ "\" because no state class with this ID has been registered.", this);
				return;
			}
			
			/* If the specified state is already open, only update it! */
			if (_currentStateClass == stateClass)
			{
				updateState();
				return;
			}
			
			var state:Object = new stateClass();
			if (state is State)
			{
				_isSwitching = true;
				_currentStateClass = stateClass;
				_nextState = State(state);
				exitLastState();
			}
			else
			{
				Log.fatal("Tried to enter a state that is not of type State (" + stateClass
					+ ").", this);
			}
		}
		
		
		/**
		 * Updates the current state.
		 */
		public function updateState():void
		{
			if (_currentState && !_isSwitching)
			{
				_currentState.update();
				Log.debug("Updated " + _currentState.toString() + ".", this);
			}
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return "StateManager";
		}
		
		
		/**
		 * Returns a list of all registered states.
		 */
		public function dumpStateList():String
		{
			var initialStateID:String = Registry.settings.getSettings("initialStateID");
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 100, ["ID", "CLASS", "CURRENT", "INITIAL"]);
			for (var id:String in _stateClasses)
			{
				var clazz:Class = _stateClasses[id];
				var current:String = _currentState is clazz ? "true" : "";
				var initial:String = id == initialStateID ? "true" : "";
				t.add([id, clazz, current, initial]);
			}
			return toString() + "\n" + t;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the currently entered state.
		 */
		public function get currentState():State
		{
			return _currentState;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onStateEntered():void
		{
			Log.debug("--- Entered " + _currentState.toString() + " ---", this);
			_currentState.start();
			_isSwitching = false;
		}
		
		
		private function onStateExited():void
		{
			Log.debug("--- Exited " + _currentState.toString() + " ---", this);
			enterNextState();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		private function exitLastState():void
		{
			if (_currentState)
			{
				Log.debug("Exiting " + _currentState.toString() + " ...", this);
				_currentState.exitedSignal.add(onStateExited);
				_currentState.exit();
			}
			else
			{
				enterNextState();
			}
		}
		
		
		private function enterNextState():void
		{
			if (_nextState)
			{
				_currentState = _nextState;
				Log.debug("Entering " + _currentState.toString() + " ...", this);
				_currentState.enteredSignal.add(onStateEntered);
				_currentState.enter();
			}
		}
	}
}
