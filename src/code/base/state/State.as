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
	import base.view.screen.BaseScreen;
	import base.view.screen.ScreenManager;

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
			enteredSignal = new Signal();
			progressSignal = new Signal();
			exitedSignal = new Signal();
			registerResources();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Enters the state. This method initiates loading of any resources that are
		 * registered in the <code>registerResources()</code> method of the state.
		 * 
		 * <p>You normally don't call this method manually. Instead the state manager
		 * calls it automatically when the state is requested to be entered.</p>
		 */
		public function enter():void
		{
			load();
		}
		
		
		/**
		 * Starts the state after it has been entered. You normally don't call this method
		 * manually. Instead the state manager calls it automatically after the state has
		 * been loaded and opened.
		 * 
		 * <p>This is an abstract method. Override this method in your state sub-class and
		 * place any instructions into it that need to be done after the state has been
		 * started, for example opening a screen with the screen manager.</p>
		 */
		public function start():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Updates the state. You normally don't call this method manually. Instead the
		 * state manager calls it automatically on the current state when the
		 * <code>updateState()</code> method in the screen manager is called.
		 * 
		 * <p>This is an abstract method. You can override this method in your state
		 * sub-class if your state class requires the updating of any child objects.</p>
		 */
		public function update():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Stops the state if it has been started. You normally don't call this method
		 * manually. Instead the state manager calls it automatically when the state is
		 * being exited.
		 * 
		 * <p>This is an abstract method. You can override this method in your state
		 * sub-class and place any instructions into it that need to be done to stop the
		 * state, for example stopping a timer.</p>
		 */
		public function stop():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Exits the state. This method will stop the state if it's started, then removes
		 * any listeners, unloads it's resources if necessary and disposes the state
		 * afterwards. You normally don't call this method manually. Instead the state
		 * manager calls it automatically when the state is requested to be exited.
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
		 * Returns a String representation of the state.
		 * 
		 * @return A String representation of the state.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
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
			return _main.resourceManager;
		}
		
		
		/**
		 * A reference to the state manager for use in sub-classes.
		 */
		protected function get stateManager():StateManager
		{
			return _main.stateManager;
		}
		
		
		/**
		 * A reference to the screen manager for use in sub-classes.
		 */
		protected function get screenManager():ScreenManager
		{
			return _main.screenManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a resource has been loaded for this state.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
		 * 
		 * @private
		 */
		protected function onResourceLoaded(resource:Resource):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked if a resource for this state has failed to load.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
		 * 
		 * @private
		 */
		protected function onResourceLoadError(resource:Resource):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked while a resource for this state is being loaded.
		 * 
		 * @private
		 */
		protected function onResourceProgress(e:ResourceEvent):void
		{
			if (progressSignal) progressSignal.dispatch(e);
		}
		
		
		/**
		 * Invoked after all resource loading for this state has been completed.
		 * 
		 * @private
		 */
		protected function onResourceLoadComplete():void
		{
			setup();
			// TODO Where is addListeners() best placed?
			addListeners();
			enteredSignal.dispatch();
		}
		
		
		/**
		 * Signal handler that is called if a screen has been opened after using the
		 * <code>openScreen()<code> helper method.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
		 * 
		 * @private
		 * @param screen The screen that has been opened.
		 */
		protected function onScreenOpened(screen:BaseScreen):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Signal handler that is called if a screen has been closed after opening
		 * another screen by using the <code>openScreen()<code> helper method.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
		 * 
		 * @private
		 * @param screen The screen that has been closed.
		 */
		protected function onScreenClosed(screen:BaseScreen):void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers resources for loading that are required for the state.
		 * 
		 * <p>This is an abstract method. Override this method in your state sub-class and
		 * register as many resources as you need for the state. The resources are being
		 * preloaded before the state is entered by the state manager.</p>
		 * 
		 * @private
		 * @see registerResource
		 * @example
		 * <pre>
		 *     registerResource("resource1");
		 *     registerResource("resource2");
		 * </pre>
		 */
		protected function registerResources():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Registers a resource that is going to be loaded for the state. All resources
		 * that are registered with their ID are being loaded before the state is being
		 * entered. Call this method inside the overriden <code>registerResources()</code>
		 * method.
		 * 
		 * @private
		 * @see registerResources
		 */
		protected function registerResource(resourceID:String):void
		{
			if (!_resourceIDs) _resourceIDs = [];
			_resourceIDs.push(resourceID);
		}
		
		
		/**
		 * Loads all resources that are registered in the state for loading.
		 * 
		 * @private
		 * @see registerResources
		 */
		protected function load():void
		{
			if (!_resourceIDs || _resourceIDs.length < 1)
			{
				onResourceLoadComplete();
				return;
			}
			resourceManager.load(_resourceIDs, onResourceLoadComplete, onResourceLoaded,
				onResourceLoadError, onResourceProgress);
		}
		
		
		/**
		 * Sets up the state. You use this method to instanciate any child objects that
		 * are needed by the state or to assign initial property values etc.
		 * 
		 * <p>This is an abstract method. Override it in your state sub-class and place
		 * any code inside it that creates objects needed by the state. setup is
		 * automatically called after the state has been loaded.</p>
		 * 
		 * @private
		 */
		protected function setup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add any event or signal listeners to child objects of the state that
		 * were created in <code>setup()</code>. Called automatically after the state has
		 * been set up.
		 * 
		 * <p>This is an abstract method. Override this method and add any listeners to
		 * objects that require event/signal listening.</p>
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
		 * inside the <code>addListeners()</code> method. Called automatically when the
		 * state is being exited.
		 * 
		 * <p>This is an abstract method. Override this method and remove any event/signal
		 * listeners here that were added in <code>addListeners()</code>.</p>
		 * 
		 * @private
		 * @see addListeners
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to unload any resources that have been loaded for the state. Called
		 * automatically after a state has been exited.
		 * 
		 * @private
		 */
		protected function unload():void
		{
			if (!_resourceIDs || _resourceIDs.length < 1) return;
			resourceManager.unload(_resourceIDs);
		}
		
		
		/**
		 * Disposes the state. Called automatically after a state has been exited and
		 * unloaded.
		 * 
		 * <p>This is an abstract method. Override this method in your state sub-class and
		 * dispose any objects that require to be disposed.</p>
		 * 
		 * @private
		 */
		protected function dispose():void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Helper Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Helper method that can be used to enter another state from within this state.
		 * 
		 * @private
		 * @param stateID The ID of the state to enter.
		 */
		protected function enterState(stateID:String):void
		{
			stateManager.enterState(stateID);
		}
		
		
		/**
		 * Helper method that can be used to open a screen.
		 * 
		 * @private
		 * @param screenID The ID of the screen to open.
		 * @param fastTransition Whether the screen transition should be fast or not.
		 */
		protected function openScreen(screenID:String, fastTransition:Boolean = false):void
		{
			screenManager.screenOpenedSignal.addOnce(onScreenOpened);
			screenManager.screenClosedSignal.addOnce(onScreenClosed);
			screenManager.openScreen(screenID, true, fastTransition);
		}
		
		
		/**
		 * Helper method to get a resource's content from the resource index. The type
		 * depends on the content type of the resource.
		 * 
		 * @private
		 * @param resourceID The ID of the resource.
		 * @return The resource content or <code>null</code>.
		 */
		protected function getResource(resourceID:String):*
		{
			return resourceManager.resourceIndex.getResourceContent(resourceID);
		}
		
		
		/**
		 * Helper method to get a string from the string index.
		 * 
		 * @private
		 * @param stringID The ID of the string.
		 * @return The requested string.
		 */
		protected function getString(stringID:String):String
		{
			return resourceManager.stringIndex.get(stringID);
		}
	}
}
