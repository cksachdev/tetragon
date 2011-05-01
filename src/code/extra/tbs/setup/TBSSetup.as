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
package extra.tbs.setup
{
	import base.setup.Setup;

	import extra.tbs.entity.builders.TBSUnitBuilder;
	import extra.tbs.entity.components.TBSUnitPropertiesComponent;
	import extra.tbs.entity.components.TBSUnitStatsComponent;
	import extra.tbs.view.screen.TBSTestScreen;
	
	
	/**
	 * Setup class specific for TBS (Turn-based Strategy) Add-On.
	 */
	public class TBSSetup extends Setup
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function initialSetup():void
		{
			super.initialSetup();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function postConfigSetup():void
		{
			super.postConfigSetup();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function postUISetup():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function finalSetup():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function get name():String
		{
			return "tbs";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function mapInjectors():void
		{
			var propertiesComponent:TBSUnitPropertiesComponent = new TBSUnitPropertiesComponent();
			var statsComponent:TBSUnitStatsComponent = new TBSUnitStatsComponent();
			
			injector.mapValue(TBSUnitPropertiesComponent, propertiesComponent);
			injector.mapValue(TBSUnitStatsComponent, statsComponent);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function mapDataTypes():void
		{
			//dataTypeParserFactory.addDataType("Attribute", AttributeDataParser);
			//dataTypeParserFactory.addDataType("Character", CharacterDataParser);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerEntityBuilders():void
		{
			main.entityFactory.registerBuilder(TBSUnitBuilder);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function registerScreens():void
		{
			main.screenManager.registerScreen("tbsTestScreen", TBSTestScreen);
		}
	}
}
