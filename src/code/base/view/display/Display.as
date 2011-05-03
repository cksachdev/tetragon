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
package base.view.display
{
	import base.Main;
	import base.event.ResourceEvent;
	import base.io.resource.Resource;
	import base.io.resource.ResourceIndex;
	import base.io.resource.StringIndex;
	import base.view.screen.BaseScreen;

	import com.hexagonstar.signals.Signal;

	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * Abstract base class for all display classes.
	 */
	public class Display extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A reference to Main.
		 * @private
		 */
		private var _main:Main;
		
		/**
		 * @private
		 */
		private var _screen:BaseScreen;
		
		/**
		 * A reference to the resource index.
		 * @private
		 */
		private var _resourceIndex:ResourceIndex;
		
		/**
		 * A reference to the string index.
		 * @private
		 */
		private var _stringIndex:StringIndex;
		
		/**
		 * Keeps a list of IDs for resources that need to be loaded for this display.
		 * @private
		 */
		private var _resourceIDs:Array;
		
		protected var _enabled:Boolean = true;
		protected var _loaded:Boolean = false;
		protected var _started:Boolean = false;
		protected var _paused:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is broadcasted when the display has been loaded.
		 * @private
		 */
		public var loadedSignal:Signal;
		
		/**
		 * Signal that is broadcasted when the display has load progress.
		 * @private
		 */
		public var progressSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Display instance.
		 */
		public function Display()
		{
			_main = Main.instance;
			loadedSignal = new Signal();
			progressSignal = new Signal();
			
			addResources();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to Initialize the display. For displays which are child objects of a
		 * <code>Screen</code> this method gets called automatically after the display has
		 * been loaded. For screens <code>init</code> is being called by the
		 * <code>ScreenManager</code> right after the screen has been created.
		 */
		public function init():void
		{
		}
		
		
		/**
		 * Loads any resources that the display might require. For displays which are child
		 * objects in a <code>Screen</code> this method gets called automatically by the
		 * screen before the screen is being opened.
		 */
		public function load():void
		{
			/* If there are no resources to load for this display, we have to call
			 * setup() here or the display would never fire the LOADED event! */
			if (!_resourceIDs || _resourceIDs.length < 1)
			{
				onResourceLoadComplete();
				return;
			}
			
			main.resourceManager.load(_resourceIDs, onResourceLoadComplete, onResourceLoaded,
				onResourceLoadError, onResourceProgress);
		}
		
		
		/**
		 * Can be called to start the display in case the display has any child objects that
		 * need to be started. For example a display might contain animated display children
		 * that should not start playing right after the display has been opened but only
		 * after this method has been called.<br><br>
		 * 
		 * For displays that are children of a Screen <code>start</code> gets called
		 * automatically by the screen once the start method of the screen has been called by
		 * the ScreenManager.
		 */
		public function start():void
		{
			if (_started) return;
			_started = true;
		}
		
		
		/**
		 * Can be called to stop the display and it's child objects after it has been started
		 * by calling the start method.
		 */
		public function stop():void
		{
			if (!_started) return;
			_started = false;
		}
		
		
		/**
		 * Used to put the display into it's initial state like it was right after the display
		 * has been instantiated for the first time. This method can be called to reset
		 * properties and child objects in case the display should be re-used without the need
		 * to re-instantiate it.
		 */
		public function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Updates the display. This method can be called if child objects of the display
		 * need to be updated, e.g. after localization has been changed or if the display
		 * children need to be re-layouted.
		 */
		public function update():void
		{
			updateDisplayText();
			layoutChildren();
		}
		
		
		/**
		 * Disposes the display to clean up resources that are no longer in use. A call to
		 * this method stops the display, removes it's event listeners and then unloads it.
		 */
		public function dispose():void
		{
			stop();
			removeListeners();
			disposeSignals();
			unload();
		}
		
		
		/**
		 * Disposes all signals used by the instance.
		 */
		public function disposeSignals():void
		{
			if (loadedSignal)
			{
				loadedSignal.removeAll();
				loadedSignal = null;
			}
			if (progressSignal)
			{
				progressSignal.removeAll();
				progressSignal = null;
			}
		}
		
		
		/**
		 * Returns a string representation of the display.
		 * 
		 * @return A string representation of the display.
		 */
		override public function toString():String
		{
			return "[" + getQualifiedClassName(this).match("[^:]*$")[0] + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the display is enabled or disabled. On a disabled display any
		 * display children are disabled so that no user interaction may occur until the
		 * display is enabled again. Set this property to either <code>true</code> (enabled)
		 * or <code>false</code> (disabled).
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			if (v == _enabled) return;
			_enabled = v;
			if (_enabled) enableChildren();
			else disableChildren();
		}
		
		
		/**
		 * Determines if the display has been started, i.e. if it's start method has been
		 * called. Returns true if the display has been started or false if the display
		 * has either been stopped or has not yet been started.
		 */
		public function get started():Boolean
		{
			return _started;
		}
		
		
		/**
		 * Determines whether all required resources for the display have been loaded.
		 */
		public function get loaded():Boolean
		{
			return _loaded;
		}
		public function set loaded(v:Boolean):void
		{
			_loaded = v;
		}
		
		
		/**
		 * Determines whether the display is in paused state or not. If paused any child
		 * objects are being paused too, if possible. This property should be used if the
		 * display needs to be pausable, for example if it contains any animation that should
		 * not play while the application is in a paused state.
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused) return;
			_paused = v;
			if (_paused) pauseChildren();
			else unpauseChildren();
		}
		
		
		/**
		 * Used to set a reference to <code>Main</code> for displays. Screens receive this
		 * reference automatically from the <code>ScreenManager</code> and displays that are
		 * child objects of a <code>Screen</code> receive the reference automatically from the
		 * screen. In most cases you don't need to touch this setter.
		 * 
		 * @private
		 */
		public function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * A reference to the display's parent screen.
		 * @private
		 */
		public function get screen():BaseScreen
		{
			return _screen;
		}
		public function set screen(v:BaseScreen):void
		{
			_screen = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a resource has been loaded for this display.
		 * @private
		 */
		public function onResourceLoaded(resource:Resource):void
		{
		}
		
		
		/**
		 * Invoked if a resource for this display has failed to loaded.
		 * @private
		 */
		public function onResourceLoadError(resource:Resource):void
		{
		}
		
		
		/**
		 * @private
		 */
		public function onResourceProgress(e:ResourceEvent):void
		{
			progressSignal.dispatch(e);
		}
		
		
		/**
		 * Invoked after a all resource loading has been completed.
		 * @private
		 */
		public function onResourceLoadComplete():void
		{
			setup();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds resources for loading. Override this method in your concrete display
		 * class and add as many resources as you need for this display. The resources
		 * will be loaded before the display's parent screen is opened by the screen
		 * manager.
		 * 
		 * @private
		 */
		protected function addResources():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		protected function addResource(resourceID:String):void
		{
			if (!_resourceIDs)
			{
				_resourceIDs = [];
				_resourceIndex = main.resourceManager.resourceIndex;
				_stringIndex = main.resourceManager.stringIndex;
			}
			_resourceIDs.push(resourceID);
		}
		
		
		/**
		 * Sets up the display. This method is called after all resources for this
		 * display have been loaded.
		 * 
		 * @private
		 */
		protected function setup():void
		{
			createChildren();
			addListeners();
			loadedSignal.dispatch(this);
		}
		
		
		/**
		 * Used to create any display children (and other objects) that the display
		 * contains.
		 * 
		 * @private
		 */
		protected function createChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		protected function enableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		protected function disableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		protected function pauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		protected function unpauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Should be used to add any required event/signal listeners to the display and/or it's
		 * children.
		 * 
		 * @private
		 */
		protected function addListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to remove any event/signal listeners that has been added with addEventListeners().
		 * This method is automatically called by the dispose() method.
		 * 
		 * @private
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to update any display text of the display if it contains any children that
		 * are used to display text. Typically any text displays should be updated here with
		 * text strings from the application's locale object.
		 * 
		 * @private
		 */
		protected function updateDisplayText():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to lay out the display children of the display. This method is called
		 * initially to set the position and size of any child objects and is called
		 * whenever the children need to update their position or size because the layout
		 * has changed, for instance after the application window has been resized.
		 * 
		 * @private
		 */
		protected function layoutChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Should be used to unload any assets that have been loaded for the display.
		 * 
		 * @private
		 */
		protected function unload():void
		{
			if (_resourceIDs.length < 1) return;
			main.resourceManager.unload(_resourceIDs);
		}
		
		
		/**
		 * @private
		 */
		protected function getResource(id:String):*
		{
			return _resourceIndex.getResourceContent(id);
		}
		
		
		/**
		 * @private
		 */
		protected function getString(id:String):String
		{
			return _stringIndex.get(id);
		}
	}
}
