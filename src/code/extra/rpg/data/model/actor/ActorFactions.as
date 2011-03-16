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
package extra.rpg.data.model.actor
{
	/**
	 * Actor Factions Class
	 */
	public class ActorFactions
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _map:Object;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Factions instance.
		 */
		public function ActorFactions()
		{
			_map = {};
		}
		
		
		/**
		 * Sets a faction rank for the associated actor. If the actor is not yet a member
		 * of the faction specified by factionID, he is added to that faction, otherwise
		 * only the faction rank is set.
		 */
		public function setFaction(factionID:String, rank:int):void
		{
			_map[factionID] = rank;
		}
		
		
		/**
		 * Returns the rank number of the associated actor in the faction specified by
		 * factionID. If the actor is not a member of that faction -1 is returned.
		 */
		public function getRank(factionID:String):int
		{
			if (_map[factionID] == null) return -1;
			return _map[factionID];
		}
		
		
		/**
		 * Removes the associated actor from the faction specified by factionID. Any
		 * rank the actor had in that faction is reset as well.
		 */
		public function remove(factionID:String):void
		{
			delete _map[factionID];
		}
	}
}
