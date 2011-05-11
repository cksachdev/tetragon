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
	import base.Main;
	import base.event.ResourceEvent;
	import base.io.resource.Resource;
	import base.io.resource.ResourceManager;

	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * Abstract base class for state classes.
	 */
	public class State
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Keeps a list of IDs for resources that need to be loaded for this state.
		 * @private
		 */
		private var _resourceIDs:Array;
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _resourceManager:ResourceManager;
		/** @private */
		private var _loaded:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is broadcasted after the state has been loaded and entered.
		 * @private
		 */
		public var enteredSignal:Signal;
		
		/**
		 * Signal that is broadcasted while resorces for the state are being loaded.
		 * @private
		 */
		public var progressSignal:Signal;
		
		/**
		 * Signal that is broadcasted after the state has been unloaded and exited.
		 * @private
		 */
		public var exitedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function State()
		{
			_main = Main.instance;
			_resourceManager = _main.resourceManager;
			
			enteredSignal = new Signal();
			progressSignal = new Signal();
			exitedSignal = new Signal();
			
			registerResources();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Enters the state. You normally don't call this method manually. Instead
		 * the state manager calls it when the state is requested to be entered.
		 */
		public function enter():void
		{
			load();
		}
		
		
		/**
		 * Starts the state.
		 */
		public function start():void
		{
		}
		
		
		/**
		 * Updates the state.
		 */
		public function update():void
		{
		}
		
		
		/**
		 * Stops the state.
		 */
		public function stop():void
		{
		}
		
		
		/**
		 * Exits the state. You normally don't call this method manually. Instead
		 * the state manager calls it when the state is requested to be exited.
		 */
		public function exit():void
		{
			stop();
			removeListeners();
			unload();
			dispose();
			exitedSignal.dispatch();
		}
		
		
		/**
		 * Returns a String representation of the object.
		 * 
		 * @return A String representation of the object.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether the state will arrange to show a load progress display while
		 * it's resources are being loaded. The default is <code>true</code>. You can override
		 * this getter and set it to false for states where you don't want to show the load
		 * progress display.
		 */
		public function get showLoadProgress():Boolean
		{
			return true;
		}
		
		
		/**
		 * Determines whether the state has been fully loaded, i.e  whether all of it's
		 * registered resources have been loaded.
		 */
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		
		/**
		 * A reference to Main for use in sub-classes.
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * A reference to the resource manager for use in sub-classes.
		 */
		protected function get resourceManager():ResourceManager
		{
			return _resourceManager;
		}
		
		
		/**
		 * A reference to the state manager for use in sub-classes.
		 */
		protected function get stateManager():StateManager
		{
			return _main.stateManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a resource has been loaded for this state.
		 * @private
		 */
		public function onResourceLoaded(resource:Resource):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked if a resource for this state has failed to loaded.
		 * @private
		 */
		public function onResourceLoadError(resource:Resource):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		public function onResourceProgress(e:ResourceEvent):void
		{
			if (progressSignal) progressSignal.dispatch(e);
		}
		
		
		/**
		 * Invoked after all resource loading for this state has been completed.
		 * @private
		 */
		public function onResourceLoadComplete():void
		{
			setup();
			addListeners();
			_loaded = true;
			enteredSignal.dispatch();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers required resources for loading. Override this method in your sub-state
		 * class and add as many resources as you need for the state. The resources are being
		 * preloaded before the state is entered by the state manager.
		 * 
		 * @private
		 * 
		 * @example
		 * <pre>
		 *    registerResource("resource1");
		 *    registerResource("resource2");
		 * </pre>
		 */
		protected function registerResources():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Registers a resource that is going to be loaded for the state. All resources
		 * that are registered with their ID are being loaded before the state is being
		 * entered.
		 * 
		 * @private
		 */
		protected function registerResource(resourceID:String):void
		{
			if (!_resourceIDs) _resourceIDs = [];
			_resourceIDs.push(resourceID);
		}
		
		
		/**
		 * Loads all resources that the state requires.
		 * 
		 * @private
		 */
		protected function load():void
		{
			/* If there are no resources to load for this state, we have to move
			 * onwards here or the state would never fire the loaded signal! */
			if (!_resourceIDs || _resourceIDs.length < 1)
			{
				onResourceLoadComplete();
				return;
			}
			resourceManager.load(_resourceIDs, onResourceLoadComplete, onResourceLoaded,
				onResourceLoadError, onResourceProgress);
		}
		
		
		/**
		 * Sets up the state. Override this method in your state sub-class and place
		 * any code in it that creates objects needed by the state. Setup is automatically
		 * called after the state has been loaded.
		 * 
		 * @private
		 */
		protected function setup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add any event or signal listeners to child objects of the state that
		 * were created in <code>setup()</code>. Override this method and add any listeners
		 * to objects that require event/signal listening. Called automatically after the
		 * state has been set up.
		 * 
		 * @private
		 * @see removeListeners
		 */
		protected function addListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to remove any event or signal listeners from child objects that were added
		 * inside the <code>addListeners()</code> method. Override this method and remove
		 * any event/signal listeners here that were added in <code>addListeners()</code>.
		 * Called automatically when the state is being exited.
		 * 
		 * @private
		 * @see addListeners
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to unload any resources that have been loaded for the state.
		 * Called automatically after a state has been exited.
		 * 
		 * @private
		 */
		protected function unload():void
		{
			if (!_resourceIDs || _resourceIDs.length < 1) return;
			resourceManager.unload(_resourceIDs);
		}
		
		
		/**
		 * Disposes the state. Called automatically after a state has been exited
		 * and unloaded. Override this method in your state sub-class and dispose
		 * any objects that require to be disposed.
		 * 
		 * @private
		 */
		protected function dispose():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Quick helper method that can be used to enter another state from within
		 * this state.
		 * 
		 * @private
		 * @param stateID The ID of the state to enter.
		 */
		protected function enterState(stateID:String):void
		{
			stateManager.enterState(stateID);
		}
	}
}
