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
	import base.io.resource.Resource;
	import base.io.resource.ResourceManager;
	import base.signals.DisplaySignal;
	import base.view.Display;
	import base.view.Screen;
	import base.view.ScreenManager;
	import base.view.loadprogressbar.BasicLoadProgressDisplay;
	import base.view.loadprogressbar.LoadProgressDisplay;

	import com.hexagonstar.file.BulkProgress;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.getClassName;

	import flash.utils.describeType;
	
	
	/**
	 * Abstract base class for state classes.
	 * 
	 * <p>States are used to organize the execution of the application into several
	 * 'abstract' areas. For example in a game the intro, main menu, gameplay and hi-score
	 * display could be categorized as states. A state often represents a screen but it is
	 * not a requirement that a state represents a single screen. A state could also span
	 * over several screens or could not be related to any screen at all. On the other
	 * hand several states could also share the same screen.</p>
	 */
	public class State
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Keeps a list of IDs for resources that need to be loaded for this state.
		 */
		private var _resourceIDs:Array;
		
		private var _main:Main;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is broadcasted after the state has been entered.
		 */
		public var enteredSignal:Signal;
		
		/**
		 * Signal that is broadcasted while resorces for the state are being loaded.
		 */
		public var progressSignal:Signal;
		
		/**
		 * Signal that is broadcasted after the state has been unloaded and exited.
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
			loadResources();
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
			unloadResources();
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
		 * Creates and returns a new load progress display for use with the state.
		 */
		public function get loadProgressDisplay():LoadProgressDisplay
		{
			return new BasicLoadProgressDisplay();
		}
		
		
		/**
		 * Determines whether the state will unload all it's loaded resources once it is
		 * closed. You can override this getter and return false for states where you don't
		 * want resources to be unloaded, .e.g. for a dedicated resource preload state.
		 * 
		 * @default true
		 */
		protected function get unload():Boolean
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
		
		
		/**
		 * The number of resources that the state has registered for loading.
		 */
		public function get resourceCount():uint
		{
			if (!_resourceIDs) return 0;
			return _resourceIDs.length;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a resource has been loaded for this state.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
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
		 */
		protected function onResourceLoadError(resource:Resource):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked while a resource for this state is being loaded.
		 */
		protected function onResourceProgress(progress:BulkProgress):void
		{
			if (progressSignal) progressSignal.dispatch(progress);
		}
		
		
		/**
		 * Invoked after all resource loading for this state has been completed.
		 */
		protected function onResourceLoadComplete():void
		{
			setup();
			// TODO Where is addListeners() best placed?
			//addListeners();
			enteredSignal.dispatch();
		}
		
		
		/**
		 * Signal handler that is called after a screen has been initialized.
		 * 
		 * @param screen The screen that has been opened.
		 */
		protected function onScreenInit(screen:Screen):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Signal handler that is called when a screen is being opened. This adds
		 * signal listeners to any displays in the screen that have display signals.
		 * 
		 * You can the override the onDisplaySignal method in your state class and
		 * check for any of the dispatched signals by their type and arguments.
		 * 
		 * @param screen The screen that is opening.
		 */
		protected function onScreenOpen(screen:Screen):void
		{
			addDisplayListeners(screen);
		}
		
		
		/**
		 * Signal handler that is called if a screen has been opened after using the
		 * <code>openScreen()</code> helper method.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
		 * 
		 * @param screen The screen that has been opened.
		 */
		protected function onScreenOpened(screen:Screen):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Signal handler that is called when a screen is being closed. This removes
		 * signal listeners from any displays in the screen that have display signals.
		 * 
		 * @param screen The screen that is opening.
		 */
		protected function onScreenClose(screen:Screen):void
		{
			removeDisplayListeners(screen);
		}
		
		
		/**
		 * Signal handler that is called if a screen has been closed after opening
		 * another screen by using the <code>openScreen()</code> helper method.
		 * 
		 * <p>This is an abstract method. You need to override this method in your state
		 * sub-class to use it.</p>
		 * 
		 * @param screen The screen that has been closed.
		 */
		protected function onScreenClosed(screen:Screen):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Can be used to handle signal disptaches from displays that are used by this
		 * state.
		 */
		protected function onDisplaySignal(type:String, args:Array):void
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
		 * @see registerResource
		 * 
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
		 * @see registerResources
		 */
		protected function loadResources():void
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
		 * @see addListeners
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Adds signal listeners to all displays that are part of the currently opened
		 * screen and have a public DisplaySignal variable or accessor defined.
		 */
		protected function addDisplayListeners(screen:Screen):void
		{
			iterateDisplaySignals(screen, true);
		}
		
		
		/**
		 * Removes signal listeners from all displays that are part of the currently opened
		 * screen and have a public DisplaySignal variable or accessor defined.
		 */
		protected function removeDisplayListeners(screen:Screen):void
		{
			iterateDisplaySignals(screen, false);
		}
		
		
		/**
		 * @private
		 */
		protected function iterateDisplaySignals(screen:Screen, add:Boolean):void
		{
			if (!screen.displays) return;
			for (var i:uint = 0; i < screen.displays.length; i++)
			{
				var d:Display = screen.displays[i];
				var xml:XML = describeType(d);
				var x:XML;
				var s:DisplaySignal;
				/* TODO Any better solution to check variables AND accessors in the same loop? */
				for each (x in xml.variable.(@type == "base.signals::DisplaySignal"))
				{
					s = d[xml.variable.@name];
					if (s)
					{
						if (add) s.add(onDisplaySignal);
						else s.remove(onDisplaySignal);
					}
				}
				for each (x in xml.accessor.(@type == "base.signals::DisplaySignal"))
				{
					s = d[xml.variable.@name];
					if (s)
					{
						if (add) s.add(onDisplaySignal);
						else s.remove(onDisplaySignal);
					}
				}
			}
		}
		
		
		/**
		 * Used to unload any resources that have been loaded for the state. Called
		 * automatically after a state has been exited.
		 */
		protected function unloadResources():void
		{
			if (!unload || !_resourceIDs || _resourceIDs.length < 1) return;
			resourceManager.unload(_resourceIDs);
		}
		
		
		/**
		 * Disposes the state. Called automatically after a state has been exited and
		 * unloaded.
		 * 
		 * <p>This is an abstract method. Override this method in your state sub-class and
		 * dispose any objects that require to be disposed.</p>
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
		 * @param stateID The ID of the state to enter.
		 */
		protected function enterState(stateID:String):void
		{
			stateManager.enterState(stateID);
		}
		
		
		/**
		 * Helper method that can be used to open a screen.
		 * 
		 * @param screenID The ID of the screen to open.
		 * @param fastTransition Whether the screen transition should be fast or not.
		 */
		protected function openScreen(screenID:String, fastTransition:Boolean = false):void
		{
			screenManager.screenInitSignal.addOnce(onScreenInit);
			screenManager.screenOpenSignal.addOnce(onScreenOpen);
			screenManager.screenOpenedSignal.addOnce(onScreenOpened);
			screenManager.screenCloseSignal.addOnce(onScreenClose);
			screenManager.screenClosedSignal.addOnce(onScreenClosed);
			screenManager.openScreen(screenID, true, fastTransition);
		}
		
		
		/**
		 * Helper method to get a resource's content from the resource index. The type
		 * depends on the content type of the resource.
		 * 
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
		 * @param stringID The ID of the string.
		 * @return The requested string.
		 */
		protected function getString(stringID:String):String
		{
			return resourceManager.stringIndex.get(stringID);
		}
	}
}
