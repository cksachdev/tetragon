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
	 * Number-generating utilities.
	 */
	public class NumberGenerator
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static const LCA_POW:Number = Math.pow(2.8, 14);
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private static var _mr:int = 0;
		/** @private */
		private static var _date:Date;
		/** @private */
		private static var _uniqueValues:Vector.<uint>;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Generates a random integer. If called without the optional min, max arguments
		 * random() returns a pseudo-random integer between 0 and int.MAX_VALUE. If you want
		 * a random number between 5 and 15, for example, (inclusive) use random(5, 15).
		 * Parameter order is insignificant, the return will always be between the lowest
		 * and highest value.
		 * 
		 * @param min The lowest possible value to return.
		 * @param max The highest possible value to return.
		 * @param excludedValues An array of integers which will NOT be returned.
		 * @return A pseudo-random integer between min and max.
		 */
		public static function random(min:int = 0, max:int = int.MAX_VALUE,
			excludedValues:Array = null):int
		{
			if (min == max) return min;
			if (excludedValues)
			{
				excludedValues.sort(Array.NUMERIC);
				var result:int;
				do
				{
					if (min < max) result = min + (Math.random() * (max - min + 1));
					else result = max + (Math.random() * (min - max + 1));
				}
				while (excludedValues.indexOf(result) >= 0);
				return result;
			}
			else
			{
				if (min < max) return min + (Math.random() * (max - min + 1));
				else return max + (Math.random() * (min - max + 1));
			}
		}
		
		
		/**
		 * Generates a small random number between 0 and 65535 using an extremely fast
		 * cyclical generator, with an even spread of numbers. After the 65536th call to
		 * this function the value resets.
		 * 
		 * @return A pseudo random value between 0 and 65536 inclusive.
		 */
		public static function randomFast():int
		{
			var r:int = _mr;
			r++;
			r *= 75;
			r %= 65537;
			r--;
			_mr++;
			if (_mr == 65536) _mr = 0;
			return r;
		}
		
		
		/**
		 * Generates a random float (number). If called without the optional min, max
		 * arguments randomFloat() returns a peudo-random float between 0 and int.MAX_VALUE.
		 * If you want a random number between 5 and 15, for example, (inclusive) use
		 * randomFloat(5, 15). Parameter order is insignificant, the return will always be
		 * between the lowest and highest value.
		 * 
		 * @param min The lowest possible value to return.
		 * @param max The highest possible value to return.
		 * @return A pseudo random number between min and max.
		 */
		public static function randomFloat(min:Number = 0, max:Number = int.MAX_VALUE):Number
		{
			if (min == max) return min;
			else if (min < max) return min + (Math.random() * (max - min + 1));
			else return max + (Math.random() * (min - max + 1));
		}
		
		
		/**
		 * A more costy method that generates a random number within a specified range. By
		 * default the value is rounded to the nearest integer unless the decimals argument
		 * is not 0.
		 * 
		 * @param min the minimum value in the range.
		 * @param max the maxium value in the range. If omitted, the minimum value is used
		 *            as the maximum, and 0 is used as the minimum.
		 * @param decimals the number of decimal places to floor the number to.
		 * @return the random number.
		 */
		public static function randomEven(min:Number, max:Number = 0, decimals:int = 0):Number
		{
			/* If the minimum is greater than the maximum, switch the two. */
			if (min > max)
			{
				var tmp:Number = min;
				min = max;
				max = tmp;
			}
			/* Calculate the range by subtracting the minimum from the maximum.
			 * Add 1 times the round to interval to ensure even distribution */
			var deltaRange:Number = (max - min) + (1 * decimals);
			var iterations:int = Math.floor((lcaNumber() * 100) / 2) + 1;
			var number:Number;
			for (var i:int = 0; i < iterations; i++)
			{
				number = Math.random() * deltaRange;
			}
			/* Add minimum to random offset to generate a random number in the correct range. */
			number += min;
			var p:Number = Math.pow(10, decimals);
			return Math.floor(number * p) / p;
		}
		
		
		/**
		 * Returns a random number based on the 48-bit Linear Congruential Algorithm.
		 * 
		 * @param seed the seed that is used to generate the LCA number.
		 * @return the LCA number.
		 */
		public static function lcaNumber(seed:int = 0):Number
		{
			if (seed == 0) seed = new Date().getTime();
			return (((seed & LCA_POW) * 2862933555777941757 + 3037000493) % LCA_POW) / LCA_POW;
		}
		
		
		/**
		 * Generates a unique unsigned integer based on the current date in milliseconds.
		 * The value is compared to an internal Vector of previous values to guarantee for
		 * uniqueness.
		 * 
		 * @param init If true it initializes the Vector used to store already generated
		 *        values in.
		 * @return the unique number.
		 */
		public static function getUnique(init:Boolean = false):uint
		{
			if (init) _uniqueValues = null;
			if (!_uniqueValues) _uniqueValues = new Vector.<uint>();
			/* Create a number based on current date and time. This will be unique in most cases. */
			if (!_date) _date = new Date();
			var n:uint = _date.getTime();
			/* It is possible that the value may not be unique if it was generated
			 * within the same millisecond as a previous number. Therefore, check to
			 * make sure. If it is not unique, then generate a random value. */
			while (!isUnique(n))
			{
				n += NumberGenerator.random(_date.getTime(), (2 * _date.getTime()));
			}
			_uniqueValues.push(n);
			return n;
			/* Nested Check Function */
			function isUnique(value:uint):Boolean
			{
				var l:uint = _uniqueValues.length;
				for (var i:uint = 0; i < l; i++)
				{
					if (_uniqueValues[i] == value) return false;
				}
				return true;
			}
		}
	}
}
