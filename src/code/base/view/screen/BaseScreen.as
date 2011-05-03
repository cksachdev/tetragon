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
		 * Signal that is broadcasted when the screen has been created.
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
			prepare();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function load():void
		{
			if (_displays.length < 1)
			{
				setup();
				return;
			}
			for (var i:int = 0; i < _displays.length; i++)
			{
				_displays[i].loaded = false;
				_displays[i].load();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function start():void
		{
			super.start();
			callOnAllDisplays("start");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			callOnAllDisplays("stop");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void
		{
			callOnAllDisplays("reset");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			callOnAllDisplays("update");
			super.update();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			stop();
			callOnAllDisplays("dispose");
			removeListeners();
			disposeSignals();
			unload();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function disposeSignals():void
		{
			if (createdSignal)
			{
				createdSignal.removeAll();
				createdSignal = null;
			}
			super.disposeSignals();
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
		 * @inheritDoc
		 */
		override public function set enabled(v:Boolean):void
		{
			super.enabled = v;
			callOnAllDisplays("enabled", v);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set paused(v:Boolean):void
		{
			super.paused = v;
			callOnAllDisplays("paused", v);
		}
		
		
		/**
		 * The displays of the screen.
		 */
		protected function get displays():Vector.<Display>
		{
			return _displays;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onDisplayProgress(e:ResourceEvent):void
		{
			progressSignal.dispatch(e);
		}
		
		
		/**
		 * @private
		 */
		protected function onDisplayLoaded(display:Display):void
		{
			display.init();
			display.loaded = true;
			
			for (var i:int = 0; i < _displays.length; i++)
			{
				var d:Display = _displays[i];
				
				/* Check if any unloaded display is left. */
				if (!d.loaded) return;
				
				/* If we reach this point, all displays have been loaded.
				 * Remove signal listeners from displays. */
				 d.disposeSignals();
			}
			
			setup();
		}
		
		
		/**
		 * Used to wait exatcly one frame after the display has been created and before
		 * the loaded event is broadcasted. This is to prevent abrupt blend-ins.
		 * @private
		 */
		private function onFramePassed(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onFramePassed);
			createdSignal.dispatch();
			disposeSignals();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function prepare():void
		{
			_displays = new Vector.<Display>();
			progressSignal = new Signal();
			createdSignal = new Signal();
			
			createChildren();
		}
		
		
		/**
		 * @private
		 */
		protected function addLoadDisplay(display:Display):void
		{
			display.screen = this;
			display.progressSignal.add(onDisplayProgress);
			display.loadedSignal.add(onDisplayLoaded);
			_displays.push(display);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function setup():void
		{
			addChildren();
			addListeners();
			
			/* All done! Time to show the screen */
			addEventListener(Event.ENTER_FRAME, onFramePassed);
		}
		
		
		/**
		 * @private
		 */
		protected function addChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Calls a method on all display objects of the screen.
		 * @private
		 */
		private function callOnAllDisplays(op:String, v:* = null):void
		{
			var len:uint = _displays.length;
			for (var i:uint = 0; i < len; i++)
			{
				switch (op)
				{
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
						_displays[i].enabled = v;
						break;
					case "paused":
						_displays[i].paused = v;
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
