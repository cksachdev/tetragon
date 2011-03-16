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
package extra.game.setup
{
	import base.Main;
	import base.data.parsers.DataTypeParserFactory;
	import base.setup.ISetup;

	import extra.game.data.parsers.*;
	import extra.game.view.screen.*;
	
	
	/**
	 * Setup class specific for Game Add-On.
	 */
	public class GameSetup implements ISetup
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructs a new FlashSetup instance.
		 */
		public function GameSetup(main:Main)
		{
			_main = main;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function initialSetup():void
		{
			/* Map data type parse classes necessary for Game add-on. */
			DataTypeParserFactory.instance.addDataType("WorldSpace", WorldspaceDataParser);
			DataTypeParserFactory.instance.addDataType("Cell", CellDataParser);
			DataTypeParserFactory.instance.addDataType("TileSet", TileSetDataParser);
			DataTypeParserFactory.instance.addDataType("TileMap", TileMapDataParser);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function postConfigSetup():void
		{
			_main.screenManager.registerScreen("gameScreen", GameScreen);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function postUISetup():void
		{
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function finalSetup():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get name():String
		{
			return "game";
		}
	}
}
