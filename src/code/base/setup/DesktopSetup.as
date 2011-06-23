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
package base.setup
{
	import base.command.env.CreateUserDataFoldersCommand;
	import base.command.env.ToggleFullscreenCommand;
	import base.core.desktop.WindowBoundsManager;
	import base.data.Registry;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	
	
	/**
	 * DesktopSetup contains setup instructions exclusively for desktop-based applications.
	 */
	public class DesktopSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function initialSetup():void
		{
			/* set this to false, when we close the application we first do an update. */
			NativeApplication.nativeApplication.autoExit = false;
			
			main.commandManager.execute(new CreateUserDataFoldersCommand());
			
			// TODO To be changed! Fullscreen state should not be stored in app.ini
			// but in user settings file!
			//main.config.useFullscreen = WindowBoundsManager.instance.fullscreen;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function postConfigSetup():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function postSettingsSetup():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function finalSetup():void
		{
			var stage:Stage = main.contextView.stage;
			
			/* Correct stage dimensions which might be wrong due to system chrome. */
			windowBoundsManager.calculateWindowChromeExtra();
			
			/* Recall app window bounds. */
			windowBoundsManager.recallWindowBounds(main.baseWindow, "base");
			
			/* Check if we want to start in fullscreen mode. */
			if (Registry.config.startWithFullscreen && !main.isFullscreen)
			{
				main.commandManager.execute(new ToggleFullscreenCommand());
			}
			
			/* Make application visible. */
			if (NativeWindow.isSupported)
			{
				stage.nativeWindow.visible = true;
				stage.nativeWindow.activate();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registrySetup():void
		{
			new DesktopSetupRegistry().execute();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "desktop";
		}
		
		
		protected function get windowBoundsManager():WindowBoundsManager
		{
			return WindowBoundsManager.instance;
		}
	}
}
