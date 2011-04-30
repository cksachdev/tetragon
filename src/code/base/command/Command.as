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
package base.command
{
	import base.Main;
	
	
	/**
	 * Abstract Command class.
	 */
	public class Command extends BaseCommand
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------

		/**
		 * Every command has a reference to main by default.
		 * @private
		 */
		private var _main:Main;
		
		
		// -----------------------------------------------------------------------------------------
		// Getters & Setters
		// -----------------------------------------------------------------------------------------

		/**
		 * A reference to main, used by the CLI when executing commands.
		 * @private
		 */
		public function get main():Main
		{
			return _main;
		}
		public function set main(v:Main):void
		{
			_main = v;
		}


		/**
		 * The signature of the CLI command. The signature is defined by an Array
		 * containing Strings that are used by the CLI to understand which arguments
		 * the command accepts. Any such String needs to reflect an existing setter
		 * in this class and should optimally have a type specified.
		 */
		public function get signature():Array
		{
			/* Abstract method! */
			return null;
		}


		/**
		 * The command's help text. This is used by the CLI help command.
		 */
		public function get helpText():String
		{
			/* Abstract method! */
			return null;
		}


		/**
		 * A usage example of the command, used by the CLI help command.
		 */
		public function get example():String
		{
			/* Abstract method! */
			return null;
		}


		/**
		 * Determines whether the command input echo's in the Console output or not.
		 */
		public function get suppressEcho():Boolean
		{
			return false;
		}
	}
}
