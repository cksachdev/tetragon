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
package extra.rpg.data.model
{
	/**
	 * Defines a disposition for a specific target, usually a species, character,
	 * creature or faction. Dispositions can be used to create a fondness of one
	 * object or object group to a specific target or target group, e.g. a specific
	 * species can have a fondness or a loathing for another species.
	 * 
	 * A disposition modifier can range from -100 (most disliked) to 100 (most liked).
	 * 
	 * Disposition modifiers are not cumulative. If an actor is a member of more than
	 * one faction with a disposition modifier toward a faction the player is a member
	 * of, only the lowest disposition modifier is considered. In other words, if the
	 * actor is a member of a faction that has a +10 modifier toward the PlayerFaction,
	 * and another faction that has a -10 modifier, only the -10 modifier is applied.
	 * They do not cancel out. Presumably this holds true for disposition modifiers
	 * between non-player actors as well.
	 */
	public class Disposition
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The ID of the target for which the disposition counts. The target must
		 * implement IDispositionable.
		 */
		public var targetID:String;
		
		/** @private */
		private var _modifier:int;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Disposition(targetID:String, modifier:int = 0)
		{
			this.targetID = targetID;
			this.modifier = modifier;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The disposition modifier for the target. If this is a negative value,
		 * the owner has a disposition against the specific target (dislikes),
		 * if this is a positive value the owner has a disposition toward the
		 * target (likes).
		 * 
		 * The possible modifier range for dispositions is from -100 to 100.
		 */
		public function get modifier():int
		{
			return _modifier;
		}
		public function set modifier(v:int):void
		{
			_modifier = (v < -100) ? -100 : (v > 100) ? 100 : v;
		}
	}
}
