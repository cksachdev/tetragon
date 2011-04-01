/* *      _________  __      __ *    _/        / / /____ / /________ ____ ____  ___ *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \ *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/ *                                   /___/ *  * tetragon : Engine for Flash-based web and desktop games. * Licensed under the MIT License. *  * Permission is hereby granted, free of charge, to any person obtaining a copy of * this software and associated documentation files (the "Software"), to deal in * the Software without restriction, including without limitation the rights to * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of * the Software, and to permit persons to whom the Software is furnished to do so, * subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in all * copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */package base.setup{	import base.Main;	import base.command.env.ExitApplicationCommand;	import base.core.desktop.WindowBoundsManager;	import base.data.Registry;	import flash.desktop.NativeApplication;	import flash.display.NativeWindow;	import flash.events.Event;	import flash.events.FullScreenEvent;	import flash.events.NativeWindowBoundsEvent;	/**	 * AIRDesktopHelper	 */	public class AIRDesktopHelper	{		//-----------------------------------------------------------------------------------------		// Properties		//-----------------------------------------------------------------------------------------				private var _main:Main;
		private var _defaultFramerate:Number;						//-----------------------------------------------------------------------------------------		// Constructor		//-----------------------------------------------------------------------------------------				/**		 * Creates a new instance of the class.		 */		public function AIRDesktopHelper(main:Main)		{			_main = main;			setup();		}						//-----------------------------------------------------------------------------------------		// Public Methods		//-----------------------------------------------------------------------------------------						//-----------------------------------------------------------------------------------------		// Getters & Setters		//-----------------------------------------------------------------------------------------						//-----------------------------------------------------------------------------------------		// Callback Handlers		//-----------------------------------------------------------------------------------------				/**		 * @private		 */		private function onApplicationClosing(e:Event):void		{			e.preventDefault();			/* We have to refer main to this command via it's constructor since			 * this command here isn't executed by the CommandMangere! */			new ExitApplicationCommand(_main).execute();		}						/**		 * @private		 */		private function onApplicationClose(e:Event):void		{			NativeApplication.nativeApplication.exit();		}						/**		 * @private		 */		private function onWindowBoundsChanged(e:NativeWindowBoundsEvent):void 		{			/* Store window bounds if window was moved or resized */			// TODO Not good like this! The event is dispatched continuosly!			//WindowBoundsManager.instance.storeWindowBounds();		}						/**		 * @private		 */		private function onFullScreen(e:FullScreenEvent):void		{			if (!e.fullScreen)			{				WindowBoundsManager.instance.recallWindowBounds(_main.baseWindow, "base");								/* In case user hit ESC to exit fullscreen, set correct state! */				// TODO To be changed! Fullscreen state should not be stored in app.ini				// but in user settings file!				//_main.config.useFullscreen = false;								WindowBoundsManager.instance.storeWindowBounds(_main.baseWindow, "base");			}		}						/**		 * @private		 */		private function onDeactivate(e:Event):void 		{			_main.view.stage.frameRate = Registry.config.backgroundFrameRate;		}						/**		 * @private		 */		private function onActivate(e:Event):void 		{			_main.view.stage.frameRate = _defaultFramerate;		}						//-----------------------------------------------------------------------------------------		// Private Methods		//-----------------------------------------------------------------------------------------				/**		 * @private		 */		private function setup():void		{			/* We listen to CLOSING from both the stage and the UI. If the user closes the			 * app through the taskbar, Event.CLOSING is emitted from the stage. Otherwise,			 * it could be emitted from TitleBarConrols. */			_main.view.addEventListener(Event.CLOSING, onApplicationClosing);						if (NativeWindow.isSupported)			{				_main.view.stage.nativeWindow.addEventListener(Event.CLOSING, onApplicationClosing);				_main.view.stage.nativeWindow.addEventListener(Event.CLOSE, onApplicationClose);				_main.view.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE,					onWindowBoundsChanged);				_main.view.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,					onWindowBoundsChanged);				_main.view.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);			}						/* Check if application should use framerate throttling while the app			 * is unfocussed or minimized. */			if (Registry.config.backgroundFrameRate > -1)			{				_defaultFramerate = _main.view.stage.frameRate;				var na:NativeApplication = NativeApplication.nativeApplication;				na.addEventListener(Event.DEACTIVATE, onDeactivate);				na.addEventListener(Event.ACTIVATE, onActivate);			}		}	}}