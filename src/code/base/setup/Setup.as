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
	import base.data.parsers.DataTypeParserFactory;

	import org.swiftsuspenders.Injector;
	
	
	/**
	 * Abstract Setup class, used as super class for any other setup classes.
	 */
	public class Setup
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		protected var _main:Main;
		protected var _injector:Injector;
		protected var _dataTypeParserFactory:DataTypeParserFactory;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initlializes the setup with a reference to Main.
		 */
		public function init(main:Main):void
		{
			_main = main;
			_injector = _main.injector;
			mapInjectors();
		}
		
		
		/**
		 * Executes initial setup steps.
		 */
		public function initialSetup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Executes setup tasks that need to be done after the config has been loaded but
		 * before the application UI is created.
		 */
		public function postConfigSetup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Executes setup tasks that need to be done after the application UI is created.
		 */
		public function postUISetup():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Executes setup tasks that need to be done after the application init process
		 * has finished but before the application grants user interaction or executes
		 * any further logic that happens after the app initialization.
		 */
		public function finalSetup():void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The name of the setup.
		 */
		public function get name():String
		{
			/* Abstract method! */
			return "setup";
		}
		
		
		/**
		 * A reference to Main.
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * A reference to the main IoC injector.
		 */
		protected function get injector():Injector
		{
			return _injector;
		}
		
		
		/**
		 * A reference to the datatype parser factory.
		 */
		protected function get dataTypeParserFactory():DataTypeParserFactory
		{
			return DataTypeParserFactory.instance;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Does the IoC injection mappings for this setup.
		 * This happens before any other setup step.
		 * 
		 * @private
		 */
		protected function mapInjectors():void
		{
			/* Abstract method! */
		}
	}
}
