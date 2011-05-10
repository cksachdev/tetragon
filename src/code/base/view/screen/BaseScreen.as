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
package base.view.screen
{
	import base.event.ResourceEvent;
	import base.io.resource.Resource;
	import base.view.display.Display;

	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.display.StageReference;

	import flash.display.DisplayObject;
	import flash.events.Event;

	
	/**
	 * BaseScreen Class
	 */
	public class BaseScreen extends Display
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Keeps a list of IDs for resources that need to be loaded for this screen.
		 * @private
		 */
		private var _resourceIDs:Array;
		
		/**
		 * Stores all child displays of this screen.
		 * @private
		 */
		private var _displays:Vector.<Display>;
		
		/** @private */
		private var _loaded:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is broadcasted when the screen has load progress.
		 * @private
		 */
		public var progressSignal:Signal;
		
		/**
		 * Signal that is broadcasted when the screen's resources have been loaded.
		 * @private
		 */
		public var loadedSignal:Signal;
		
		/**
		 * Signal that is broadcasted when the screen has been created and is ready for use.
		 * @private
		 */
		public var createdSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AbstractScreen instance.
		 */
		public function BaseScreen()
		{
			progressSignal = new Signal();
			loadedSignal = new Signal();
			createdSignal = new Signal();
			
			createChildren();
			registerResources();
			registerDisplays();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Loads all resources that the screen requires. This method gets called
		 * automatically by the screen manager.
		 */
		public function load():void
		{
			/* If there are no resources to load for this screen, we have to move
			 * onwards here or the screen would never fire the loaded signal! */
			if (!_resourceIDs || _resourceIDs.length < 1)
			{
				onResourceLoadComplete();
				return;
			}
			resourceManager.load(_resourceIDs, onResourceLoadComplete, onResourceLoaded,
				onResourceLoadError, onResourceProgress);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			callOnRegisteredDisplays("start");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			callOnRegisteredDisplays("stop");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			callOnRegisteredDisplays("reset");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			callOnRegisteredDisplays("update");
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			stop();
			callOnRegisteredDisplays("dispose");
			removeListeners();
			disposeSignals();
			unload();
		}
		
		
		/**
		 * Disposes all signals used by the screen.
		 */
		public function disposeSignals():void
		{
			if (progressSignal)
			{
				progressSignal.removeAll();
				progressSignal = null;
			}
			if (loadedSignal)
			{
				loadedSignal.removeAll();
				loadedSignal = null;
			}
			if (createdSignal)
			{
				createdSignal.removeAll();
				createdSignal = null;
			}
		}
		
		
		/**
		 * Used to initialize the screen. Called by the screen manager after all of the
		 * screen resources have been loaded. Do not call manually!
		 * 
		 * @private
		 */
		override public function init():void
		{
			callOnRegisteredDisplays("init");
			addChildren();
			addListeners();
			
			/* All done! Time to show the screen on the next frame. */
			addEventListener(Event.ENTER_FRAME, onFramePassed);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines whether this screen shows a load progress display while it's resources
		 * are loaded. The default is true. You can override this getter and set it to false
		 * for screen where you don't want to show the load progress display.
		 */
		public function get showLoadProgress():Boolean
		{
			return true;
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
		 * @inheritDoc
		 */
		override public function set enabled(v:Boolean):void
		{
			super.enabled = v;
			callOnRegisteredDisplays("enabled", v);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set paused(v:Boolean):void
		{
			super.paused = v;
			callOnRegisteredDisplays("paused", v);
		}
		
		
		/**
		 * The displays of the screen.
		 */
		protected function get displays():Vector.<Display>
		{
			return _displays;
		}
		
		
		/**
		 * A reference to the screen manager for use in sub-classes.
		 */
		protected function get screenManager():ScreenManager
		{
			return main.screenManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Invoked after a resource has been loaded for this screen.
		 * @private
		 */
		public function onResourceLoaded(resource:Resource):void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Invoked if a resource for this screen has failed to loaded.
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
		 * Invoked after all resource loading for this screen has been completed.
		 * @private
		 */
		public function onResourceLoadComplete():void
		{
			loaded = true;
			if (loadedSignal) loadedSignal.dispatch(this);
			init();
		}
		
		
		/**
		 * Used to wait exatcly one frame after the display has been created and before
		 * the loaded event is broadcasted. This is to prevent abrupt blend-ins.
		 * @private
		 */
		private function onFramePassed(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onFramePassed);
			if (createdSignal) createdSignal.dispatch();
			disposeSignals();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Registers required resources for loading. Override this method in your sub-screen
		 * class and add as many resources as you need for the screen and it's display children.
		 * The resources are being preloaded before the screen is opened by the screen manager.
		 * 
		 * @private
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
		 * Registers displays for use with the screen. Override this method in your sub-screen
		 * class and register the displays by using the <code>registerDisplay()</code> method.
		 * Displays that are registered with the screen have most of their methods called
		 * automatically when these methods are called on the screen. These methods are:
		 * <code>init()</code>, <code>start()</code>, <code>stop()</code>, <code>reset()</code>,
		 * <code>update()</code>, <code>dispose()</code>, <code>enabled</code> and
		 * <code>paused</code>.
		 * 
		 * @private
		 * @example
		 * <pre>
		 *    registerDisplay("display1");
		 *    registerDisplay("display2");
		 * </pre>
		 */
		protected function registerDisplays():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * @private
		 */
		override protected function addChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Registers a resource that is going to be loaded for the screen. All resources
		 * that are registered with their ID are being loaded before the screen is being
		 * opened.
		 * 
		 * @private
		 */
		protected function registerResource(resourceID:String):void
		{
			if (!_resourceIDs) _resourceIDs = [];
			_resourceIDs.push(resourceID);
		}
		
		
		/**
		 * Registers a Display for use with the screen. This doesn't add the display to
		 * the display list but 'registers' it for use with the screen. Displays that are
		 * registered with the screen have several methods and setters automatically
		 * called if these methods are called on the screen.
		 * 
		 * @private
		 */
		protected function registerDisplay(display:Display):void
		{
			if (!_displays) _displays = new Vector.<Display>();
			display.screen = this;
			_displays.push(display);
		}
		
		
		/**
		 * Used to unload any resources that have been loaded for the screen.
		 * @private
		 */
		protected function unload():void
		{
			if (!_resourceIDs || _resourceIDs.length < 1) return;
			resourceManager.unload(_resourceIDs);
		}
		
		
		/**
		 * Calls a method on all registered displays of the screen.
		 * @private
		 * 
		 * @param func Function that should be called on the display.
		 * @param value Optional value used when calling setters.
		 */
		private function callOnRegisteredDisplays(func:String, value:* = null):void
		{
			if (!_displays) return;
			var len:uint = _displays.length;
			for (var i:uint = 0; i < len; i++)
			{
				switch (func)
				{
					case "init":
						_displays[i].init();
						break;
					case "start":
						_displays[i].start();
						break;
					case "stop":
						_displays[i].stop();
						break;
					case "reset":
						_displays[i].reset();
						break;
					case "update":
						_displays[i].update();
						break;
					case "dispose":
						_displays[i].dispose();
						break;
					case "enabled":
						_displays[i].enabled = value;
						break;
					case "paused":
						_displays[i].paused = value;
						break;
				}
			}
		}
		
		
		/**
		 * Calculates and returns the horizontal center of the specified display object in
		 * regard to the application stage.
		 * 
		 * @private
		 * @param d The display object for which to calculate the horizontal center.
		 * @return The horizontal center of d.
		 */
		protected static function getHorizontalCenter(d:DisplayObject):int
		{
			return Math.round(StageReference.hCenter - (d.width * 0.5));
		}
		
		
		/**
		 * Calculates and returns the vertical center of the specified display object in
		 * regard to the application stage.
		 * 
		 * @private
		 * @param d The display object for which to calculate the vertical center.
		 * @return The vertical center of d.
		 */
		protected static function getVerticalCenter(d:DisplayObject):int
		{
			return Math.round(StageReference.vCenter - (d.height * 0.5));
		}
	}
}
