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
	import base.Main;
	import base.event.ScreenEvent;
	import base.util.Log;

	import com.greensock.TweenLite;
	import com.hexagonstar.display.text.ColumnText;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;

	
	/**
	 * Manages the creation, opening and closing as well as updating of screens.
	 */
	public class ScreenManager extends EventDispatcher
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _screenParent:DisplayObjectContainer;
		/** @private */
		private var _screenClasses:Object;
		/** @private */
		private var _startScreenID:String;
		/** @private */
		private var _screen:BaseScreen;
		/** @private */
		private var _nextScreen:DisplayObject;
		/** @private */
		private var _openScreenClass:Class;
		/** @private */
		private var _screenOpenDelay:Number = 0.2;
		/** @private */
		private var _screenCloseDelay:Number = 0.2;
		/** @private */
		private var _tweenDuration:Number = 0.4;
		/** @private */
		private var _fastDuration:Number = 0.14;
		/** @private */
		private var _backupDuration:Number;
		/** @private */
		private var _backupOpenDelay:Number;
		/** @private */
		private var _backupCloseDelay:Number;
		/** @private */
		private var _isLoading:Boolean = false;
		/** @private */
		private var _isAutoStart:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ScreenManager instance.
		 * 
		 * @param screenParent the parent container for all screens.
		 * @param tweenDuration Duration (in seconds) used for screen in/out tweens.
		 *         Setting this to 0 will make the ScreenManager use no tweening at all.
		 * @param screenOpenDelay A delay (in seconds) that the screen manager waits
		 *         before opening a screen.
		 * @param screenCloseDelay A delay (in seconds) that the screen manager waits
		 *         before closing an opened screen.
		 */
		public function ScreenManager(main:Main, screenParent:DisplayObjectContainer)
		{
			super();
			
			_screenClasses = {};
			_main = main;
			_screenParent = screenParent;
			_backupDuration = _tweenDuration;
			_backupOpenDelay = _screenOpenDelay;
			_backupCloseDelay = _screenCloseDelay;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a screen class for use with the screen manager.
		 * 
		 * @param screenID Unique ID of the screen.
		 * @param screenClass The screen's class.
		 * @param isStartScreen If true the specified screen class will be used as the starting
		 *        screen which is opened by default after application start.
		 */
		public function registerScreen(screenID:String, screenClass:Class,
			isStartScreen:Boolean = false):void
		{
			_screenClasses[screenID] = screenClass;
			if (isStartScreen) _startScreenID = screenID;
		}
		
		
		/**
		 * Starts the screen manager by automatically opening the starting screen.
		 */
		public function start():void
		{
			openScreen(_startScreenID, true);
		}
		
		
		/**
		 * Opens the screen of the specified ID. Any currently opened screen is closed
		 * before the new screen is opened. The screen needs to implement IScreen.
		 * 
		 * @param screenID The ID of the screen.
		 * @param autoStart Determines if the screen should automatically be started once it
		 *        has been finished opening. If this is true the screen manager
		 *        automatically calls the start() method on the screen after it has been
		 *        opened.
		 * @param fastTransition If true the screen closing/opening tween will be faster for
		 *        this time the next screen is opened. Useful for when screens should close
		 *        and open faster because of user interaction.
		 */
		public function openScreen(screenID:String, autoStart:Boolean = true,
			fastTransition:Boolean = false):void
		{
			_isAutoStart = false;
			var screenClass:Class = _screenClasses[screenID];
			
			if (screenClass == null)
			{
				Log.error("Could not open screen with ID \"" + screenID
					+ "\" because no screen class with this ID has been registered.", this);
				return;
			}
			
			/* If the specified screen is already open, only update it! */
			if (_openScreenClass == screenClass)
			{
				updateScreen();
				return;
			}
			
			var screen:DisplayObject = new screenClass();
			if (screen is BaseScreen)
			{
				_isLoading = true;
				_isAutoStart = autoStart;
				_openScreenClass = screenClass;
				_nextScreen = screen;
				BaseScreen(_nextScreen).main = _main;
				BaseScreen(_nextScreen).init();
				
				if (fastTransition)
				{
					_backupDuration = _tweenDuration;
					_backupOpenDelay = _screenOpenDelay;
					_backupCloseDelay = _screenCloseDelay;
					_tweenDuration = _fastDuration;
					_screenOpenDelay = _screenCloseDelay = 0;
				}
				
				/* Only change screen alpha if we're actually using tweens! */
				if (_tweenDuration > 0)
				{
					_nextScreen.alpha = 0;
				}
				
				_screenParent.addChild(_nextScreen);
				closeLastScreen();
			}
			else
			{
				Log.fatal("Tried to open a screen that is not of type IScreen (" + screenClass
					+ ").", this);
			}
		}
		
		
		/**
		 * Updates the currently opened screen.
		 */
		public function updateScreen():void
		{
			if (_screen && !_isLoading)
			{
				_screen.update();
				Log.debug("Updated " + _screen.toString(), this);
			}
		}
		
		
		/**
		 * Closes the currently opened screen. This is normally not necessary unless
		 * you need a situation where no screens should be on the stage.
		 * 
		 * @param noTween If true, closes the screen quickly without using a tween.
		 */
		public function closeScreen(noTween:Boolean = false):void
		{
			if (!_screen) return;
			_nextScreen = null;
			closeLastScreen(noTween);
		}
		
		
		/**
		 * Returns a list of all registered screens.
		 */
		public function dumpScreenList():String
		{
			var t:ColumnText = new ColumnText(4, true, "  ", null, "  ", 100, ["ID", "CLASS", "OPEN", "STARTSCREEN"]);
			for (var id:String in _screenClasses)
			{
				var clazz:Class = _screenClasses[id];
				var open:String = _screen is clazz ? "true" : "";
				var startScreen:String = id == _startScreenID ? "true" : "";
				t.add([id, clazz, open, startScreen]);
			}
			return toString() + "\n" + t;
		}
		
		
		/**
		 * Returns a String Representation of ScreenManager.
		 * 
		 * @return A String Representation of ScreenManager.
		 */
		override public function toString():String
		{
			return "[ScreenManager]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns the currently opened screen.
		 */
		public function get currentScreen():BaseScreen
		{
			return _screen;
		}
		
		
		/**
		 * The duration (in seconds) that the ScreenManager will use to tween in/out
		 * screens. If set to 0 the ScreenManager will completely ignore tweening.
		 */
		public function get tweenDuration():Number
		{
			return _tweenDuration;
		}
		public function set tweenDuration(v:Number):void
		{
			if (v < 0) v = 0;
			_tweenDuration = v;
		}
		
		
		/**
		 * A delay (in seconds) that the screen manager waits before opening a screen.
		 * This can be used to make transitions less abrupt.
		 */
		public function get screenOpenDelay():Number
		{
			return _screenOpenDelay;
		}
		public function set screenOpenDelay(v:Number):void
		{
			if (v < 0) v = 0;
			_screenOpenDelay = v;
		}
		
		
		/**
		 * A delay (in seconds) that the screen manager waits before closing an opened screen.
		 * This can be used to make transitions less abrupt.
		 */
		public function get screenCloseDelay():Number
		{
			return _screenCloseDelay;
		}
		public function set screenCloseDelay(v:Number):void
		{
			if (v < 0) v = 0;
			_screenCloseDelay = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onScreenLoaded(e:ScreenEvent):void
		{
			if (!_screen)
			{
				/* this should not happen unless you quickly repeat app init in the CLI! */
				Log.warn("onScreenLoaded: screen is null.", this);
				return;
			}
			
			_screen.removeEventListener(ScreenEvent.CREATED, onScreenLoaded);
			
			/* Disable screen display objects while fading in. */
			_screen.enabled = false;
			
			/* Screen is loaded and child objects have been created, time to lay out
			 * children and update the screen text. */
			_screen.update();
			
			_isLoading = false;
			
			if (_tweenDuration > 0)
			{
				TweenLite.to(_screen, _tweenDuration, {alpha: 1.0, onComplete: onTweenInComplete});
			}
			else
			{
				onTweenInComplete();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onTweenInComplete():void
		{
			_tweenDuration = _backupDuration;
			_screenOpenDelay = _backupOpenDelay;
			_screenCloseDelay = _backupCloseDelay;
			
			if (!_screen)
			{
				/* this should not happen unless you quickly repeat app init in the CLI! */
				Log.warn("onTweenInComplete: screen is null", this);
				return;
			}
			
			Log.debug("Opened " + _screen.toString(), this);
			dispatchEvent(new ScreenEvent(ScreenEvent.OPENED, _screen));
			
			/* Everythings' done, screen is faded in! Let's grant user interaction. */
			_screen.enabled = true;
			
			/* If autoStart, now is the time to call start on the screen. */
			if (_isAutoStart)
			{
				_isAutoStart = false;
				_screen.start();
			}
		}
		
		
		/**
		 * @private
		 */
		private function onTweenOutComplete():void
		{
			Log.debug("Closed " + _screen.toString(), this);
			
			var oldScreen:BaseScreen = _screen;
			_screenParent.removeChild(DisplayObject(_screen));
			_screen.dispose();
			_screen = null;
			_openScreenClass = null;
			dispatchEvent(new ScreenEvent(ScreenEvent.CLOSED, oldScreen));
			loadNextScreen();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * closeLastScreen
		 * @private
		 */
		private function closeLastScreen(noTween:Boolean = false):void
		{
			if (_screen)
			{
				_screen.enabled = false;
				
				if (noTween)
				{
					onTweenOutComplete();
					return;
				}
				
				if (_tweenDuration > 0)
				{
					TweenLite.to(_screen, _tweenDuration, {alpha: 0.0, onComplete:
						onTweenOutComplete, delay: _screenCloseDelay});
				}
				else
				{
					setTimeout(onTweenOutComplete, _screenCloseDelay * 1000);
				}
			}
			else
			{
				loadNextScreen();
			}
		}
		
		
		/**
		 * loadNextScreen
		 * @private
		 */
		private function loadNextScreen():void
		{
			if (_nextScreen)
			{
				setTimeout(function():void
				{
					_screen = BaseScreen(_nextScreen);
					_screen.addEventListener(ScreenEvent.CREATED, onScreenLoaded);
					_screen.load();
				}, _screenOpenDelay * 1000);
			}
		}
	}
}
