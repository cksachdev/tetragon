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
	import base.core.cli.CLICommandRegistryMobile;

	import flash.desktop.NativeApplication;
	
	
	/**
	 * AIRIOSSetup contains setup instructions exclusively for iOS-based applications.
	 */
	public class AIRIOSSetup extends Setup
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
			
			super.initialSetup();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function postConfigSetup():void
		{
			super.postConfigSetup();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function postUISetup():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function finalSetup():void
		{
			/* Register mobile-specific CLI commands if we have the Console available. */
			if (main.console && main.console.cli)
			{
				new CLICommandRegistryMobile(main);
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
			return "ios";
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
		
		
		/**
		 * @inheritDoc
		 */
		override protected function mapDataTypes():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerScreens():void
		{
		}
	}
}
