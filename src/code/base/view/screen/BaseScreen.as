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
		 * Stores all child displays of this screen.
		 * @private
		 */
		private var _displays:Vector.<Display>;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is broadcasted when the screen has been opened and is ready for use.
		 * @private
		 */
		public var openedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new AbstractScreen instance.
		 */
		public function BaseScreen()
		{
			openedSignal = new Signal();
			
			createChildren();
			registerDisplays();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Opens the screen. You normally don't call this method manually. Instead
		 * the screen manager calls it when the screen is requested to be opened.
		 */
		public function open():void
		{
			callOnRegisteredDisplays("init");
			addChildren();
			addListeners();
			/* Wait one frame before showing the screen. */
			addEventListener(Event.ENTER_FRAME, onFramePassed);
		}
		
		
		/**
		 * Starts the screen
		 */
		override public function start():void
		{
			super.start();
			callOnRegisteredDisplays("start");
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
		override public function reset():void
		{
			callOnRegisteredDisplays("reset");
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
		 * @private
		 */
		public function close():void
		{
			stop();
			removeListeners();
			callOnRegisteredDisplays("dispose");
			dispose();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
		}
		
		
		/**
		 * Used to initialize the screen. Called by the screen manager after all of the
		 * screen resources have been loaded. Do not call manually!
		 * 
		 * @private
		 */
		override public function init():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
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
		 * Used to wait exatcly one frame after the display has been created and before
		 * the loaded event is broadcasted. This is to prevent abrupt blend-ins.
		 * @private
		 */
		private function onFramePassed(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onFramePassed);
			openedSignal.dispatch();
			openedSignal.removeAll();
			openedSignal = null;
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
