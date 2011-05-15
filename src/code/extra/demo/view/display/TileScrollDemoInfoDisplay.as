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
package extra.demo.view.display
{
	import base.view.Display;

	import extra.game.render.tile.TileScroller;

	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	public class TileScrollDemoInfoDisplay extends Display
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _tileScroller:TileScroller;
		private var _infoTF:TextField;
		private var _helpTF:TextField;
		private var _format:TextFormat;
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		public function set tileScroller(v:TileScroller):void
		{
			_tileScroller = v;
			_tileScroller.onFrame = onTileScrollerFrame;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onTileScrollerFrame(ts:TileScroller):void
		{
			var edgeMode:String = _tileScroller.edgeMode == TileScroller.EDGE_MODE_OFF ? "off"
				: _tileScroller.edgeMode == TileScroller.EDGE_MODE_HALT ? "halt"
				: _tileScroller.edgeMode == TileScroller.EDGE_MODE_WRAP ? "wrap"
				: "bounce";
			
			var s:String = ""
				+ "View Size: " + _tileScroller.viewportWidth + " x " + _tileScroller.viewportHeight
				+ "\nMap Size: " + _tileScroller.tilemap.width + " x " + _tileScroller.tilemap.height
				+ "\nPos:  x" + _tileScroller.xPos + " y" + _tileScroller.yPos
				+ "\nArea: " + _tileScroller.currentArea
				+ "\nAreas #" + _tileScroller.tilemap.areaCount
				+ "\n"
				+ "\nFPS:   " + _tileScroller.fps + " (t:" + _tileScroller.frameRate + " s:" + stage.frameRate + ")"
				+ "\nMS:    " + _tileScroller.ms
				+ "\n"
				+ "\nObj.Total:     " + _tileScroller.tilemap.groupCount
				+ "\nObj.Visible:   " + _tileScroller.visibleObjectCount
				+ "\nObj.Cached:    " + _tileScroller.cachedObjectCount
				+ "\nPurge Count:   " + _tileScroller.objectPurgeAmount
				+ "\nAnims Visible: " + _tileScroller.visibleAnimTileCount
				+ "\nAnim FPS:      " + _tileScroller.tileAnimFrameRate
				+ "\n"
				+ "\nSpeed H: " + _tileScroller.speedH
				+ "\nSpeed V: " + _tileScroller.speedV
				+ "\nDecel:   " + _tileScroller.deceleration
				+ "\nScale:   " + _tileScroller.scale
				+ "\nEdge Mode: " + edgeMode
				+ "\nUse Timer: " + _tileScroller.useTimer
				+ "\n" + (_tileScroller.paused ? "PAUSED" : "")
				+ "";
			_infoTF.text = s;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		override protected function createChildren():void
		{
			_format = new TextFormat();
			_format.font = "Terminalscope";
			_format.size = 16;
			_format.color = 0xFFFFFF;
			
			_infoTF = new TextField();
			_infoTF.multiline = true;
			_infoTF.selectable = false;
			_infoTF.embedFonts = true;
			_infoTF.defaultTextFormat = _format;
			
			_helpTF = new TextField();
			_helpTF.multiline = true;
			_helpTF.selectable = false;
			_helpTF.embedFonts = true;
			_helpTF.defaultTextFormat = _format;
			_helpTF.text = ""
				+ "[cursor/wasd] scroll"
				+ "\n[1,2,3,4] generate map"
				+ "\n[f] fullscreen"
				+ "\n[p] pause"
				+ "\n[g] areagrid"
				+ "\n[m] map boundaries"
				+ "\n[b] bounding boxes"
				+ "\n[r] render buffer"
				+ "\n[c] caching on/off"
				+ "\n[e] switch edge mode"
				+ "\n[t] switch timer mode"
				+ "\n[-+] scroll speed"
				+ "\n[kl] viewport size"
				+ "\n[()] viewport scale"
				+ "\n[hv] h/v autoscroll"
				+ "\n[,.] dec/inc scroll FPS"
				+ "\n[;'] dec/inc stage FPS"
				+ "\n[/] reset scroller"
				+ "";
			
			graphics.beginFill(0x4F449D, 1.0);
			graphics.drawRect(0, 0, 192, main.stage.stageHeight);
			graphics.endFill();
		}
		
		
		override protected function addChildren():void
		{
			addChild(_infoTF);
			addChild(_helpTF);
		}
		
		
		override protected function layoutChildren():void
		{
			_infoTF.x = 5;
			_infoTF.y = 5;
			_infoTF.width = 182;
			_infoTF.height = 330;
			_helpTF.x = _infoTF.x;
			_helpTF.y = _infoTF.y + _infoTF.height + 10;
			_helpTF.width = _infoTF.width;
			_helpTF.height = main.stage.stageHeight - _infoTF.x - _infoTF.height - 15;
		}
	}
}
