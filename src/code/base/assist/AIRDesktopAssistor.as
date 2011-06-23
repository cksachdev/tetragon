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
package base.assist
{
	import base.command.env.ExitApplicationCommand;
	import base.core.desktop.WindowBoundsManager;
	import base.data.Registry;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.NativeWindowBoundsEvent;
	
	
	/**
	 * Persistent assist class for AIR desktop builds.
	 */
	public class AIRDesktopAssistor extends Assistor
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _defaultFramerate:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		override public function setup():void
		{
			/* We listen to CLOSING from both the stage and the UI. If the user closes the
			 * app through the taskbar, Event.CLOSING is emitted from the stage. Otherwise,
			 * it could be emitted from TitleBarConrols. */
			main.contextView.addEventListener(Event.CLOSING, onApplicationClosing);
			
			if (NativeWindow.isSupported)
			{
				stage.nativeWindow.addEventListener(Event.CLOSING, onApplicationClosing);
				stage.nativeWindow.addEventListener(Event.CLOSE, onApplicationClose);
				stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onWindowBoundsChanged);
				stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowBoundsChanged);
				stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
			}
			
			/* Check if application should use framerate throttling while the app
			 * is unfocussed or minimized. */
			if (Registry.config.backgroundFrameRate > -1)
			{
				_defaultFramerate = stage.frameRate;
				var na:NativeApplication = NativeApplication.nativeApplication;
				na.addEventListener(Event.DEACTIVATE, onDeactivate);
				na.addEventListener(Event.ACTIVATE, onActivate);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onApplicationClosing(e:Event):void
		{
			e.preventDefault();
			main.commandManager.execute(new ExitApplicationCommand());
		}
		
		
		private function onApplicationClose(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function onWindowBoundsChanged(e:NativeWindowBoundsEvent):void 
		{
			/* Store window bounds if window was moved or resized */
			// TODO Not good like this! The event is dispatched continously while dragging!
			//WindowBoundsManager.instance.storeWindowBounds();
		}
		
		
		private function onFullScreen(e:FullScreenEvent):void
		{
			if (!e.fullScreen)
			{
				WindowBoundsManager.instance.recallWindowBounds(main.baseWindow, "base");
				/* In case user hit ESC to exit fullscreen, set correct state! */
				// TODO To be changed! Fullscreen state should not be stored in app.ini
				// but in user settings file!
				//_main.config.useFullscreen = false;
				WindowBoundsManager.instance.storeWindowBounds(main.baseWindow, "base");
			}
		}
		
		
		private function onDeactivate(e:Event):void 
		{
			stage.frameRate = Registry.config.backgroundFrameRate;
		}
		
		
		private function onActivate(e:Event):void 
		{
			stage.frameRate = _defaultFramerate;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		override public function get id():String
		{
			return "airDesktopAssistor";
		}
	}
}
