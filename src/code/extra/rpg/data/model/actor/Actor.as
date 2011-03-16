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
	import base.data.DataObject;

	import extra.rpg.data.model.Dispositions;
	import extra.rpg.data.model.Inventory;
	import extra.rpg.data.model.ai.AI;
	
	
	/**
	 * Actors is the class of objects that run AI routines. They move in the world,
	 * can engage in combat, and can interact with other objects such as doors.
	 * 
	 * There are two types of actors, creatures and characters. A lot of the data for
	 * the two types is identical. However, there are significant differences.
	 */
	public class Actor extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		public var scriptID:String;
		public var name:String;
		
		public var stats:ActorStats;
		public var factions:ActorFactions;
		public var dispositions:Dispositions;
		public var inventory:Inventory;
		public var deathItems:Inventory;
		public var ai:AI;
		
		/* Flags */
		public var essential:Boolean;
		public var questRelated:Boolean;
		public var lowLevelProcessing:Boolean;
		public var respawn:Boolean;
		public var canCorpseCheck:Boolean;
		public var noDoorOpen:Boolean;
		public var noCellTravel:Boolean;
		public var invulnerable:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function Actor()
		{
			stats = new ActorStats();
			factions = new ActorFactions();
			dispositions = new Dispositions();
			inventory = new Inventory();
			deathItems = new Inventory();
			ai = new AI();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
