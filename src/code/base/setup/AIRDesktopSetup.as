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
	import base.core.cli.CLICommandRegistryDesktop;
	import base.core.desktop.WindowBoundsManager;
	import base.core.update.UpdateManager;
	import base.data.Registry;
	import base.event.UpdateManagerEvent;

	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	
	
	/**
	 * AIRDesktopSetup contains setup instructions exclusively for desktop-based applications.
	 */
	public class AIRDesktopSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _updateManager:UpdateManager;
		
		
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
			
			/* recall app window bounds */
			WindowBoundsManager.instance.recallWindowBounds(_main.baseWindow, "base");
			
			// TODO To be changed! Fullscreen state should not be stored in app.ini
			// but in user settings file!
			//_main.config.useFullscreen = WindowBoundsManager.instance.fullscreen;
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
		override public function postUISetup():void
		{
			/* Only create new setup helper if it's not already existing! */
			if (!_main.setupHelper) _main.setupHelper = new AIRDesktopHelper(_main);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function finalSetup():void
		{
			if (NativeWindow.isSupported)
			{
				/* Make application visible. */
				_main.contextView.stage.nativeWindow.visible = true;
				_main.contextView.stage.nativeWindow.activate();
			}
			
			/* Register desktop-specific CLI commands if we have the Console available. */
			if (_main.console && _main.console.cli)
			{
				new CLICommandRegistryDesktop(_main);
			}
			
			if (Registry.config.updateEnabled)
			{
				/* TODO UpdateManager disabled until we build a custom update manager! */
				//_updateManager = new UpdateManager();
				//_updateManager.addEventListener(UpdateManagerEvent.FINISHED, onUpdateManagerFinished);
				//_updateManager.initialize();
			}
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
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onUpdateManagerFinished(e:UpdateManagerEvent):void 
		{
			_updateManager.removeEventListener(UpdateManagerEvent.FINISHED, onUpdateManagerFinished);
			_updateManager.dispose();
			_updateManager = null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function mapInjectors():void
		{
		}
	}
}
