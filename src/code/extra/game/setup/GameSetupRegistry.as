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
	import base.setup.ISetupRegistry;
	import base.setup.SetupRegistry;

	import extra.game.data.parsers.*;
	import extra.game.entity.components.*;
	import extra.game.entity.systems.*;
	import extra.game.view.screen.*;
	
	
	/**
	 * base setup registry class.
	 */
	public class GameSetupRegistry extends SetupRegistry implements ISetupRegistry
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function registerScreens():void
		{
			registerScreen("gameMenuScreen", GameMenuScreen);
			registerScreen("gameOptionsScreen", GameOptionsScreen);
			registerScreen("gamePlayScreen", GamePlayScreen);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerDataTypes():void
		{
			registerDataType("WorldSpace", WorldspaceDataParser);
			registerDataType("Cell", CellDataParser);
			registerDataType("TileSet", TileSetDataParser);
			registerDataType("TileMap", TileMapDataParser);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerEntitySystems():void
		{
			registerEntitySystem(GameLoopSystem);
			registerEntitySystem(ParticleEmitterSystem);
			registerEntitySystem(Physics2DSystem);
			registerEntitySystem(BasicRenderSystem);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function registerEntityComponents():void
		{
			registerEntityComponent("graphicsComponent", GraphicsComponent);
			registerEntityComponent("gravityComponent", GravityComponent);
			registerEntityComponent("particleEmitterComponent", ParticleEmitterComponent);
			registerEntityComponent("physics2DComponent", Physics2DComponent);
			registerEntityComponent("spacial2DComponent", Spacial2DComponent);
		}
	}
}
