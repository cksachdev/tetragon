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
package extra.rpg.data.constants
{
	import com.hexagonstar.data.types.EEnum;
	
	
	/**
	 * AgeGroup EEnum
	 */
	public class AgeGroup extends EEnum
	{
		/* Static Constructor */
		{init(AgeGroup);}
		
		//-----------------------------------------------------------------------------------------
		// Enum Properties
		//-----------------------------------------------------------------------------------------
		
		public static const CHILD:AgeGroup = new AgeGroup();
		public static const TEEN:AgeGroup = new AgeGroup();
		public static const YOUNG_ADULT:AgeGroup = new AgeGroup();
		public static const ADULT:AgeGroup = new AgeGroup();
		public static const ELDER:AgeGroup = new AgeGroup();
		public static const VENERABLE:AgeGroup = new AgeGroup();
	}
}
