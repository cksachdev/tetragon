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
package base.command.env
{
	import base.command.CLICommand;
	import base.core.desktop.*;

	import flash.display.StageDisplayState;

	
	/**
	 * CLI command to toggle fullscreen mode.
	 */
	public class ToggleFullscreenCommand extends CLICommand
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function execute():void
		{
			var state:String = main.contextView.stage.displayState;
			var interactive:String = StageDisplayState["FULL_SCREEN_INTERACTIVE"];
			
			/* We have fs interactive support! */
			if (interactive != null)
			{
				if (state == StageDisplayState["FULL_SCREEN_INTERACTIVE"]
					|| state == StageDisplayState.FULL_SCREEN)
				{
					state = StageDisplayState.NORMAL;
					// TODO To be changed! Fullscreen state should not be stored in app.ini
					// but in user settings file!
					//_main.config.useFullscreen = false;
				}
				else
				{
					CONFIG::IS_DESKTOP_BUILD
					{
						WindowBoundsManager.instance.storeWindowBounds(main.baseWindow, "base");
					}
					state = StageDisplayState["FULL_SCREEN_INTERACTIVE"];
					// TODO To be changed! Fullscreen state should not be stored in app.ini
					// but in user settings file!
					//_main.config.useFullscreen = true;
				}
			}
			else
			{
				if (state == StageDisplayState.FULL_SCREEN)
				{
					state = StageDisplayState.NORMAL;
					// TODO To be changed! Fullscreen state should not be stored in app.ini
					// but in user settings file!
					//_main.config.useFullscreen = false;
				}
				else
				{
					state = StageDisplayState.FULL_SCREEN;
					// TODO To be changed! Fullscreen state should not be stored in app.ini
					// but in user settings file!
					//_main.config.useFullscreen = true;
				}
			}
			
			main.contextView.stage.displayState = state;
			complete();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String 
		{
			return "toggleFullscreen";
		}
	}
}
