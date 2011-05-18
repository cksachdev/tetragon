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
package extra.rpg.data.parsers
{
	import base.data.parsers.DataParser;
	import base.data.parsers.IDataParser;
	import base.io.resource.ResourceIndex;
	import base.io.resource.loaders.XMLResourceLoader;
	import extra.rpg.data.constants.Gender;
	import extra.rpg.data.model.Disposition;
	import extra.rpg.data.model.actor.Character;
	import extra.rpg.data.model.vo.ProfessionVO;



	
	/**
	 * CharacterDataParser
	 */
	public class CharacterDataParser extends DataParser implements IDataParser
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function parse(resourceFile:XMLResourceLoader, model:*):void
		{
			_xml = resourceFile.xml;
			var index:ResourceIndex = model;
			
			for each (var x:XML in _xml.characters.character)
			{
				var c:Character = new Character();
				var i:XML;
				
				c.id = x.@id;
				c.scriptID = x.@scriptID;
				// TODO
				//c.name = rm.stringIndex.get(x.@nameID);
				
				/* Parse character traits. */
				var g:String = x.traits.@gender;
				c.traits.gender = (g == "m") ? Gender.MALE : (g == "f") ? Gender.FEMALE : Gender.NONE;
				c.traits.age = x.traits.@age;
				c.traits.height = x.traits.@height;
				c.traits.weight = x.traits.@weight;
				c.traits.alignmentID = x.traits.@alignmentID;
				c.traits.raceID = x.traits.@raceID;
				c.traits.biographyID = x.traits.@biographyID;
				
				/* Parse character stats. */
				c.stats.level.value = x.stats.level.@value;
				c.stats.level.autoLevel = parseBoolean(x.stats.level.@autoLevel);
				c.stats.level.autoLevelMin = x.stats.level.@autoLevelMin;
				c.stats.level.autoLevelMax = x.stats.level.@autoLevelMax;
				for each (i in x.stats.attributes.attribute)
				{
					c.stats.setAttribute(i.@id, i.@value);
				}
				c.stats.health.maximum = x.stats.damagePools.health.@maximum;
				c.stats.health.value = x.stats.damagePools.health.@value;
				c.stats.health.wounds = x.stats.damagePools.health.@wounds;
				c.stats.health.incapThreshold = x.stats.damagePools.health.@incapThreshold;
				c.stats.action.maximum = x.stats.damagePools.action.@maximum;
				c.stats.action.value = x.stats.damagePools.action.@value;
				c.stats.action.wounds = x.stats.damagePools.action.@wounds;
				c.stats.action.incapThreshold = x.stats.damagePools.action.@incapThreshold;
				c.stats.mind.maximum = x.stats.damagePools.mind.@maximum;
				c.stats.mind.value = x.stats.damagePools.mind.@value;
				c.stats.mind.wounds = x.stats.damagePools.mind.@wounds;
				c.stats.mind.incapThreshold = x.stats.damagePools.mind.@incapThreshold;
				c.stats.fatigue = x.stats.fatigue.@value;
				
				/* Parse character professions. */
				for each (i in x.professions.profession)
				{
					var id:String = i.@id;
					var vo:ProfessionVO = new ProfessionVO();
					vo.xpBase = i.@xpBase;
					vo.xpBranch1 = i.@xpBranch1;
					vo.xpBranch2 = i.@xpBranch2;
					vo.xpBranch3 = i.@xpBranch3;
					vo.xpBranch4 = i.@xpBranch4;
					vo.xpMaster = i.@xpMaster;
					c.addProfession(id, vo);
				}
				
				/* Parse character skills. */
				for each (i in x.skills.skill)
				{
					c.addSkill(i.@id, i.@value);
				}
				
				/* Parse character factions. */
				for each (i in x.factions.faction)
				{
					c.factions.setFaction(i.@id, i.@rank);
				}
				
				/* Parse character dispositions. */
				for each (i in x.dispositions.disposition)
				{
					c.dispositions.addDisposition(new Disposition(i.@targetID, i.@modifier));
				}
				
				/* Parse character appearance. */
				// TODO
				
				/* Parse character equipment slots. */
				c.equipment.head = x.inventory.slots.head.@id;
				c.equipment.eyes = x.inventory.slots.eyes.@id;
				c.equipment.face = x.inventory.slots.face.@id;
				c.equipment.neck = x.inventory.slots.neck.@id;
				c.equipment.torso = x.inventory.slots.torso.@id;
				c.equipment.hands = x.inventory.slots.hands.@id;
				c.equipment.legs = x.inventory.slots.legs.@id;
				c.equipment.feet = x.inventory.slots.feet.@id;
				c.equipment.belt = x.inventory.slots.belt.@id;
				c.equipment.cloak = x.inventory.slots.cloak.@id;
				c.equipment.wristLeft = x.inventory.slots.wristLeft.@id;
				c.equipment.wristRight = x.inventory.slots.wristRight.@id;
				c.equipment.ringLeft = x.inventory.slots.ringLeft.@id;
				c.equipment.ringRight = x.inventory.slots.ringRight.@id;
				c.equipment.carryingLeft = x.inventory.slots.carryingLeft.@id;
				c.equipment.carryingRight = x.inventory.slots.carryingRight.@id;
				
				/* Parse character inventory. */
				for each (i in x.inventory.items.item)
				{
					c.inventory.addItem(i.@id, i.@count);
				}
				
				/* Parse character death items. */
				for each (i in x.inventory.deathItems.item)
				{
					c.deathItems.addItem(i.@id, i.@count);
				}
				
				/* Parse character AI. */
				c.ai.combatStyleID = x.ai.@combatStyleID;
				c.ai.aggressionLevel = x.ai.@aggressionLevel;
				c.ai.assistanceLevel = x.ai.@assistanceLevel;
				c.ai.confidenceLevel = x.ai.@confidenceLevel;
				c.ai.energy = x.ai.@energy;
				c.ai.responsibility = x.ai.@responsibility;
				c.ai.aggroRadius = x.ai.@aggroRadius;
				for each (i in XML(x.ai.packages).child("package"))
				{
					c.ai.addPackage(i.@id);
				}
				
				
				/* Parse character flags. */
				c.essential = parseBoolean(x.flags.@essential);
				c.questRelated = parseBoolean(x.flags.@questRelated);
				c.lowLevelProcessing = parseBoolean(x.flags.@lowLevelProcessing);
				c.respawn = parseBoolean(x.flags.@respawn);
				c.canCorpseCheck = parseBoolean(x.flags.@canCorpseCheck);
				c.noPersuasion = parseBoolean(x.flags.@noPersuasion);
				c.noDoorOpen = parseBoolean(x.flags.@noDoorOpen);
				c.noCellTravel = parseBoolean(x.flags.@noCellTravel);
				c.invulnerable = parseBoolean(x.flags.@invulnerable);
				
				index.addDataResource(c);
			}
			
			dispose();
		}
	}
}
