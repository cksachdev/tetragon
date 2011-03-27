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
package base.util
{
	/**
	 * Color utilities.
	 */
	public class ColorUtil
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Returns a random color of the specified color array.
		 */
		public static function randomColor(colors:Array):uint
		{
			return colors[int(Math.random() * colors.length)];
		}
		
		
		/**
		 * Converts a hexadecimal color value of the format 0x000000 to an array which
		 * contains the three color channel values as a percentual value from 0.0 to 1.0.
		 * 
		 * @param rgb A hexadecimal color value, e.g. 0xFF2266.
		 * @return An array containng three values ranging from 0.0 to 1.0.
		 */
		public static function rgbToPercent(rgb:uint):Array
		{
			var a:Array = new Array(3);
			a[0] = Number((rgb >> 16) / 255);
			a[1] = Number((rgb >> 8 & 0xFF) / 255);
			a[2] = Number((rgb & 0xFF) / 255);
			return a;
		}
	}
}
