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
package base.data
{
	/**
	 * A data object that contains parameters which are being fetched from parameters
	 * from the HTML/PHP file that embeds the SWF file. only used for web-based build!
	 */
	public final class Params
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var skipPreloader:Boolean;
		public var ignoreIniFile:Boolean;
		public var ignoreKeyBindingsFile:Boolean;
		public var ignoreLocaleFile:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Params()
		{
			init();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Initializes the model data.
		 */
		public function init():void
		{
			skipPreloader = false;
			ignoreIniFile = false;
			ignoreKeyBindingsFile = false;
			ignoreLocaleFile = false;
		}
		
		
		/**
		 * parseFlashVars
		 */
		public function parseFlashVars(params:Object):void
		{
			if (params["skipPreloader"])
			{
				skipPreloader = String(params["skipPreloader"]).toLowerCase() == "true";
			}
			if (params["ignoreIniFile"])
			{
				ignoreIniFile = String(params["ignoreIniFile"]).toLowerCase() == "true";
			}
			if (params["ignoreKeyBindingsFile"])
			{
				ignoreKeyBindingsFile = String(params["ignoreKeyBindingsFile"]).toLowerCase() == "true";
			}
			if (params["ignoreLocaleFile"])
			{
				ignoreLocaleFile = String(params["ignoreLocaleFile"]).toLowerCase() == "true";
			}
		}
	}
}
