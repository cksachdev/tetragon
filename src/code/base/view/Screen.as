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
package base.view
{
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.display.StageReference;

	import flash.display.DisplayObject;
	import flash.events.Event;
	
	
	/**
	 * Abstract base class for screens.
	 * 
	 * <p>A screen is a display object that acts as a container for other display objects.
	 * It represents the whole area of the Flash display stage and contains objects of
	 * type <code>Display</code> which are placed inside the screen.</p>
	 * 
	 * <p>Screens are normally not used directly. Instead you use the ScreenManager class
	 * to open and close screens by specifying the ID with that the screen has been
	 * registered during the application init phase.</p>
	 * 
	 * <p>There is ever only one screen opened at a time. If a new screen is being opened
	 * with the screen manager, the currently opened screen is being closed.</p>
	 * 
	 * <p>To create new screen classes you extend this class and then override any
	 * abstract methods that might be used in your screen class.</p>
	 * 
	 * @see base.view.display.Display
	 * @see base.view.screen.ScreenManager
	 */
	public class Screen extends Display
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Stores all child displays of this screen.
		 */
		private var _displays:Vector.<Display>;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal that is broadcasted when the screen has been opened and is ready for use.
		 */
		public var openedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Screen instance.
		 */
		public function Screen()
		{
			super();
			openedSignal = new Signal();
			createChildren();
			registerDisplays();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the screen after it has been opened. You normally don't call this method
		 * manually. Instead the screen manager calls it automatically when the screen is
		 * being requested to start.
		 * 
		 * <p>You don't need to override this method unless you have any custom objects in
		 * your screen that need starting. All registered displays of the screen are
		 * started automatically when the screen is started.</p>
		 * 
		 * <p>If you override this method make sure to call <code>super.start()</code> at
		 * either the beginning or the end of your overriden method, otherwise registered
		 * displays will not be started.</p>
		 */
		override public function start():void
		{
			executeOnDisplays("start");
		}
		
		
		/**
		 * Updates the screen. This method is called automatically by the screen manager
		 * before the screen is started and whenever the updateScreen() method is called
		 * in the screen manager. A call to this method updates all registered child
		 * displays.
		 * 
		 * <p>If you override this method make sure to call <code>super.update()</code> at
		 * the beginning of your overriden method, otherwise registered displays will not
		 * be updated.</p>
		 */
		override public function update():void
		{
			executeOnDisplays("update");
			layoutChildren();
		}
		
		
		/**
		 * Resets the screen anmd all of it's registered child displays. Can be used to
		 * reset any display objects into their initial state, position, size etc.
		 * 
		 * <p>If you override this method make sure to call <code>super.reset()</code> at
		 * the beginning of your overriden method, otherwise registered displays will not
		 * be reset.</p>
		 */
		override public function reset():void
		{
			executeOnDisplays("reset");
		}
		
		
		/**
		 * Stops the screen if it has been started. You normally don't call this method
		 * manually. Instead it is called automatically before the screen is
		 * being closed by the screen manager.
		 * 
		 * <p>If you override this method make sure to call <code>super.stop()</code> at
		 * the beginning of your overriden method, otherwise registered displays will not
		 * be stopped.</p>
		 */
		override public function stop():void
		{
			executeOnDisplays("stop");
		}
		
		
		/**
		 * Disposes the screen and all it's registered child displays to clean up
		 * resources that are no longer needed. A call to this method removes any
		 * event/signal listeners.
		 * 
		 * <p>You normally don't call this method manually. Instead it is called
		 * automatically when the screen is being closed by the screen manager.</p>
		 * 
		 * <p>If you want to override this method make sure to call
		 * <code>super.dispose()</code> at the start of your overriden dispose method.</p>
		 */
		override public function dispose():void
		{
			executeOnDisplays("dispose");
			removeListeners();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function set enabled(v:Boolean):void
		{
			executeOnDisplays("enabled", v);
			super.enabled = v;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set paused(v:Boolean):void
		{
			executeOnDisplays("paused", v);
			super.paused = v;
		}
		
		
		/**
		 * A vector containing all child displays that are registered in the screen.
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
		// Internal Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The init method is not used by screen classes!
		 */
		override internal final function init():void
		{
		}
		
		
		/**
		 * Opens the screen. You never have to call this method manually. Instead
		 * the screen manager calls it when the screen is requested to be opened.
		 */
		internal function open():void
		{
			executeOnDisplays("init");
			addChildren();
			addListeners();
			/* Wait one frame before showing the screen. */
			addEventListener(Event.ENTER_FRAME, onFramePassed);
		}
		
		
		/**
		 * Closes the screen. You never have to call this method manually. Instead
		 * the screen manager calls it when the screen is requested to be closed.
		 */
		internal function close():void
		{
			stop();
			dispose();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to wait exatcly one frame after the display has been created and before
		 * the loaded event is broadcasted. This is to prevent abrupt blend-ins.
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
		 * Used to create all display children that are part of the screen. Called
		 * right after the screen has been created.
		 * 
		 * <p>This is an abstract method. Override it in your sub-screen class and
		 * instanciate any display child objects here that are part of the screen.</p>
		 */
		override protected function createChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Registers displays for use with the screen.
		 * 
		 * <p>This is an abstract method. Override this method in your sub-screen class and
		 * register the displays by using the <code>registerDisplay()</code> method.
		 * Displays that are registered with the screen have most of their methods called
		 * automatically when these methods are called on the screen. These methods are:
		 * <code>init()</code>, <code>start()</code>, <code>stop()</code>,
		 * <code>reset()</code>, <code>update()</code>, <code>dispose()</code>,
		 * <code>enabled</code> and <code>paused</code>.</p>
		 * 
		 * @see base.view.display.Display
		 * 
		 * @example
		 * <pre>
		 *     registerDisplay("display1");
		 *     registerDisplay("display2");
		 * </pre>
		 */
		protected function registerDisplays():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add all display children to the display list of the screen. By default
		 * this method will automatically add all registered displays to the display list
		 * in the same order they were registered. You can override this method if you
		 * want to add the display children manually.
		 */
		override protected function addChildren():void
		{
			if (_displays)
			{
				var len:uint = _displays.length;
				for (var i:uint = 0; i < len; i++)
				{
					addChild(_displays[i]);
				}
			}
		}
		
		
		/**
		 * Registers a Display for use with the screen. This doesn't add the display to
		 * the display list but 'registers' it for use with the screen. Displays that are
		 * registered with the screen have several methods and setters automatically
		 * called if these methods are called on the screen.
		 * 
		 * @param display The display instance to register.
		 */
		protected final function registerDisplay(display:Display):void
		{
			if (!_displays) _displays = new Vector.<Display>();
			display.screen = this;
			_displays.push(display);
		}
		
		
		/**
		 * updateDisplayText is never used for screen classes! Put any display text
		 * into child displays that are registered with the screen.
		 */
		override protected final function updateDisplayText():void
		{
		}
		
		
		/**
		 * Calls a method on all registered displays of the screen. Used by many
		 * default methods of the screen to delegate execution to child displays.
		 * Execution is always delegated to child displays in the same order in
		 * that they were registered in <code>registerDisplays()</code>.
		 * 
		 * @param func The function that should be called on the display.
		 * @param value An optional value used when calling setters.
		 */
		private final function executeOnDisplays(func:String, value:* = null):void
		{
			if (!_displays) return;
			var len:uint = _displays.length;
			for (var i:uint = 0; i < len; i++)
			{
				switch (func)
				{
					case "init":	_displays[i].init(); break;
					case "start":	_displays[i].start(); break;
					case "update":	_displays[i].update(); break;
					case "reset":	_displays[i].reset(); break;
					case "stop":	_displays[i].stop(); break;
					case "dispose":	_displays[i].dispose(); break;
					case "enabled":	_displays[i].enabled = value; break;
					case "paused":	_displays[i].paused = value; break;
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Helper Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Calculates and returns the horizontal center of the specified display object in
		 * regard to the application stage.
		 * 
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
		 * @param d The display object for which to calculate the vertical center.
		 * @return The vertical center of d.
		 */
		protected static function getVerticalCenter(d:DisplayObject):int
		{
			return Math.round(StageReference.vCenter - (d.height * 0.5));
		}
	}
}
