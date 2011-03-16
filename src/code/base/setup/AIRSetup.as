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
	import base.Main;
	import base.core.cli.CLICommandRegisterAIR;
	import base.core.desktop.WindowBoundsManager;
	import base.data.Registry;
	import base.event.UpdateManagerEvent;

	import flash.desktop.NativeApplication;


	
	/**
	 * AIRSetup contains setup instructions exclusively for desktop-based applications.
	 */
	public class AIRSetup implements ISetup
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		//private var _updateManager:UpdateManager;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructs a new AIRSetup instance.
		 */
		public function AIRSetup(main:Main)
		{
			_main = main;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function initialSetup():void
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
		public function postConfigSetup():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function postUISetup():void
		{
			/* Only create new AIR extras if it's not already existing! */
			if (!_main.airExtras) _main.airExtras = new AIRHelper(_main);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function finalSetup():void
		{
			/* Make application visible. */
			_main.view.stage.nativeWindow.visible = true;
			_main.view.stage.nativeWindow.activate();
			
			// TODO Updates disabled temporarily! We need to place the update
			// process to another time since it interferes with the initial UI
			// execution and the crappy AIR UpdateUI has no means to listen for
			// user interaction!
			
			/* Only create update manager if updates are enabled */
			if (Registry.config.updateEnabled)
			{
				//_updateManager = new UpdateManager(_main.config);
				//_updateManager.addEventListener(UpdateManagerEvent.FINISHED,
				//	onUpdateManagerFinished);
				//_updateManager.initialize();
			}
			else
			{
			}
			
			/* Register AIR-specific CLI commands if we have the Console available. */
			if (_main.console && _main.console.cli)
			{
				new CLICommandRegisterAIR(_main);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get name():String
		{
			return "air";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onUpdateManagerFinished(e:UpdateManagerEvent):void 
		{
			/* All setup done! Signal that setup is finished! */
			//_updateManager.removeEventListener(UpdateManagerEvent.FINISHED,
			//	onUpdateManagerFinished);
		}
	}
}
