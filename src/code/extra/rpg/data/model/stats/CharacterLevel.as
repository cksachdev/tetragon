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
package extra.rpg.data.model.stats
{
	/**
	 * Character Level class.
	 */
	public class CharacterLevel
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The level cap. A character level cannot raise higher than this value.
		 */
		public static var CAP:int = 80;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the actor that is associated with this level object is a leveled actor.
		 * Leveled actors have a level that is dynamically calculated as an offset from the PC
		 * level. If this value is true the level value serves as a multiplier for the PC level
		 * to determine the actor's level. For example if the value is 3 and the player character's
		 * level is 8 (8 * 3 = 24) result in the associated actor to be of level 24.
		 */
		public var autoLevel:Boolean = false;
		
		/** @private */
		private var _autoLevelMin:int = 1;
		/** @private */
		private var _autoLevelMax:int = 0;
		/** @private */
		private var _value:Number = 1;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines the current value of the character level.
		 * The value cannot be smaller than 1 and not be larger than the level cap.
		 */
		public function get value():Number
		{
			return Math.round(_value);
		}
		public function set value(v:Number):void
		{
			_value = (v < 1) ? 1 : (v > CharacterLevel.CAP) ? CharacterLevel.CAP : v;
		}
		
		
		/**
		 * If the autoLevel property is true this field serves as a minimum limit that the
		 * calculated level may be. For example if leveledMin is 8, the autoLevel mult is 3
		 * and the PC's level is 2 (2 x 3 = 6) which would be 6, the autoLeveled value is still
		 * 8 because it is set as a minimum. The minimum value for this property is 1.
		 */
		public function get autoLevelMin():int
		{
			return _autoLevelMin;
		}
		public function set autoLevelMin(v:int):void
		{
			_autoLevelMin = (v < 1) ? 1 : v;
		}
		
		
		/**
		 * If the autoLevel property is true this field serves as a maximum limit that the
		 * calculated level may be. For example if leveledMax is 30, the autoLevel mult is 2
		 * and the PC's level is 20 (20 x 2 = 40) which would be 40, the autoLeveled value is still
		 * 30 because it is set as a maximum. The minimum value for this property is 0 which
		 * means that the leveledMax value can be infinite.
		 */
		public function get autoLevelMax():int
		{
			return _autoLevelMax;
		}
		public function set autoLevelMax(v:int):void
		{
			_autoLevelMax = (v < 0) ? 0 : v;;
		}
	}
}
