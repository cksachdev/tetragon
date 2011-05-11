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
	import base.core.debug.Log;
	import base.data.Registry;
	import base.event.ResourceEvent;
	import base.view.display.LoadProgressDisplay;

	import com.greensock.TweenLite;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.display.StageReference;
	import com.hexagonstar.util.string.TabularText;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
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
		private var _screenContainer:Sprite;
		/** @private */
		private var _loadProgressDisplay:LoadProgressDisplay;
		/** @private */
		private var _screenClasses:Object;
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
		/** @private */
		private var _showLoadProgress:Boolean = false;
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		public var screenOpenedSignal:Signal;
		/** @private */
		public var screenClosedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new ScreenManager instance.
		 * 
		 */
		public function ScreenManager()
		{
			super();
			
			_screenClasses = {};
			_backupDuration = _tweenDuration;
			_backupOpenDelay = _screenOpenDelay;
			_backupCloseDelay = _screenCloseDelay;
			
			_screenContainer = new Sprite();
			Main.instance.contextView.addChild(_screenContainer);
			
			screenOpenedSignal = new Signal();
			screenClosedSignal = new Signal();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers a screen class for use with the screen manager.
		 * 
		 * @param screenID Unique ID of the screen.
		 * @param screenClass The screen's class.
		 */
		public function registerScreen(screenID:String, screenClass:Class):void
		{
			_screenClasses[screenID] = screenClass;
		}
		
		
		/**
		 * Starts the screen manager by automatically opening the splash screen screen or
		 * the initial screen in case the splash screen should not be shown (as set in config).
		 */
		public function start():void
		{
			var showSplashScreen:Boolean = Registry.settings.getSettings("showSplashScreen");
			var splashScreenID:String = Registry.settings.getSettings("splashScreenID");
			var initialScreenID:String = Registry.settings.getSettings("initialScreenID");
			
			if (showSplashScreen && splashScreenID != null && splashScreenID.length > 0)
			{
				openScreen(splashScreenID, true);
			}
			else if (initialScreenID != null && initialScreenID.length > 0)
			{
				openScreen(initialScreenID, true);
			}
			else
			{
				Log.fatal("Cannot open initial screen! No initial screen ID defined.", this);
			}
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
				var bs:BaseScreen = BaseScreen(screen);
				
				_isLoading = true;
				_isAutoStart = autoStart;
				_openScreenClass = screenClass;
				_showLoadProgress = bs.showLoadProgress;
				_nextScreen = bs;
				
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
				
				_screenContainer.addChild(_nextScreen);
				closeLastScreen();
			}
			else
			{
				Log.fatal("Tried to open a screen that is not of type BaseScreen (" + screenClass
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
			var initialScreenID:String = Registry.settings.getSettings("initialScreenID");
			var t:TabularText = new TabularText(4, true, "  ", null, "  ", 100, ["ID", "CLASS", "OPEN", "INITIAL"]);
			for (var id:String in _screenClasses)
			{
				var clazz:Class = _screenClasses[id];
				var open:String = _screen is clazz ? "true" : "";
				var initial:String = id == initialScreenID ? "true" : "";
				t.add([id, clazz, open, initial]);
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
			return "ScreenManager";
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
		private function onScreenProgress(e:ResourceEvent):void
		{
			if (!_loadProgressDisplay) return;
			
			/* If we got more than four resources use file count rather than bytes. Not really
			 * a good indicator but does the job for now, besides bytesLoaded is still buggy. */
			if (e.totalCount > 3) _loadProgressDisplay.update(e.currentCount, e.totalCount);
			else _loadProgressDisplay.update(e.bytesLoaded, e.bytesTotal);
		}
		
		
		/**
		 * @private
		 */
		private function onScreenLoaded():void
		{
			if (!_screen)
			{
				/* this should not happen unless you quickly repeat app init in the CLI! */
				Log.warn("onScreenLoaded: screen is null.", this);
				return;
			}
			
			/* Disable screen display objects while fading in. */
			_screen.enabled = false;
			
			/* Screen is loaded and child objects have been created, time to lay out
			 * children and update the screen text. */
			_screen.update();
			
			_isLoading = false;
			
			removeLoadProgressDisplay();
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
			screenOpenedSignal.dispatch(_screen);
			
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
			_screenContainer.removeChild(_screen);
			_screen.dispose();
			_screen = null;
			_openScreenClass = null;
			screenClosedSignal.dispatch(oldScreen);
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
				addLoadProgressDisplay();
				setTimeout(function():void
				{
					_screen = BaseScreen(_nextScreen);
					_screen.progressSignal.add(onScreenProgress);
					_screen.createdSignal.add(onScreenLoaded);
					_screen.load();
				}, _screenOpenDelay * 1000);
			}
		}
		
		
		/**
		 * @private
		 */
		private function addLoadProgressDisplay():void
		{
			if (!_showLoadProgress) return;
			_loadProgressDisplay = new LoadProgressDisplay();
			_loadProgressDisplay.x = StageReference.hCenter - (_loadProgressDisplay.width * 0.5);
			_loadProgressDisplay.y = StageReference.vCenter - (_loadProgressDisplay.height * 0.5);
			_loadProgressDisplay.alpha = 0;
			_screenContainer.addChild(_loadProgressDisplay);
			TweenLite.to(_loadProgressDisplay, 0.6, {alpha: 1.0});
		}
		
		
		/**
		 * @private
		 */
		private function removeLoadProgressDisplay():void
		{
			if (!_loadProgressDisplay) return;
			_screenContainer.swapChildren(_screen, _loadProgressDisplay);
			TweenLite.to(_loadProgressDisplay, 1.0, {alpha: 0.0, onComplete: function():void
			{
				_screenContainer.removeChild(_loadProgressDisplay);
				_loadProgressDisplay = null;
			}});
		}
	}
}
