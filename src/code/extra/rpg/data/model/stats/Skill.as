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
	 * Defines a skill that a character can possess. A skill has a value that is used
	 * in dice rolls to determine the outcome of an action done by the character, for
	 * example trying to open a locked door, shooting at an enemy or trying to persuade
	 * an NPC. The higher the skill value is, the better the character is in the skill.
	 * 
	 * A skill can have up to two character attributes associated which are benefitical
	 * for using the skill.
	 */
	public class Skill
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The skill value cap. A skill value cannot raise higher than this value.
		 */
		public static var CAP:int = 1000;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The ID of the skill.
		 */
		public var id:String;
		
		/**
		 * The name of the skill.
		 */
		public var name:String;
		
		/**
		 * The ID of the description text for the skill.
		 */
		public var descriptionID:String;
		
		/**
		 * The ID of the primary key attribute for this skill. The higher this attribute is,
		 * the more benefitical it is for this skill.
		 */
		public var keyAttribute1ID:String;
		
		/**
		 * The ID of the secondary key attribute for this skill. The higher this attribute is,
		 * the more benefitical it is for this skill.
		 */
		public var keyAttribute2ID:String;
		
		/**
		 * @private
		 */
		private var _value:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The value of the skill. A skill value cannot be lower than 0 or higher
		 * than Skill.CAP.
		 */
		public function get value():int
		{
			return _value;
		}
		public function set value(v:int):void
		{
			_value = (v < 0) ? 0 : (v > Skill.CAP) ? Skill.CAP : v;
		}
	}
}
