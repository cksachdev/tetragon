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
package base.core.console
{
	import base.Main;
	import base.data.Registry;

	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	
	public class FPSMonitor extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		private const MIN:Function = Math.min;
		private const SQRT:Function = Math.sqrt;
		
		private const _width:int = 68;
		private const _height:int = 100;
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _graphHeight:int;
		
		private var _main:Main;
		private var _container:DisplayObjectContainer;
		private var _stage:Stage;
		private var _graph:BitmapData;
		private var _rectangle:Rectangle;
		private var _tf:TextField;
		
		private var _colorBg:uint;
		private var _colorFps:uint;
		private var _colorMs:uint;
		private var _colorMem:uint;
		private var _colorMax:uint;
		
		private var _timer:uint;
		private var _fps:int;
		private var _ms:uint;
		private var _msPrev:uint;
		private var _mem:Number;
		private var _memMax:Number;
		
		private var _fpsGraph:uint;
		private var _memGraph:uint;
		private var _memMaxGraph:uint;
		
		private var _active:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function FPSMonitor(main:Main, container:DisplayObjectContainer)
		{
			_main = main;
			_container = container;
			_stage = _main.view.stage;
			
			if (Registry.config.fpsMonitorAutoOpen)
			{
				setTimeout(toggle, 100);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Toggles the monitor on/off.
		 */
		public function toggle():void
		{
			if (!_active)
			{
				/* Set monitor up if we haven't done that yet! */
				if (_rectangle == null) setup();
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				addEventListener(MouseEvent.CLICK, onClick);
				_stage.addEventListener(Event.RESIZE, onStageResize);
				layout();
				_container.visible = true;
				_container.addChild(this);
				_active = true;
			}
			else
			{
				_container.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				removeEventListener(MouseEvent.CLICK, onClick);
				_stage.removeEventListener(Event.RESIZE, onStageResize);
				_active = false;
				
				/* Make console container invisible if it doesn't
				 * contain the console or fpsmonitor! */
				if (_container.numChildren == 0)
				{
					_container.visible = false;
				}
			}
		}
		
		
		/**
		 * togglePosition
		 */
		public function togglePosition():void
		{
			if (!_active) return;
			switch (Registry.config.fpsMonitorPosition.toLowerCase())
			{
				case "tl":
					Registry.config.fpsMonitorPosition = "TR";
					break;
				case "tr":
					Registry.config.fpsMonitorPosition = "BR";
					break;
				case "br":
					Registry.config.fpsMonitorPosition = "BL";
					break;
				case "bl":
					Registry.config.fpsMonitorPosition = "TL";
			}
			layout();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onEnterFrame(e:Event):void 
		{
			_timer = getTimer();
			
			if (_timer - 1000 > _msPrev)
			{
				_msPrev = _timer;
				_mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				_memMax = _memMax > _mem ? _memMax : _mem;
				
				_fpsGraph = MIN(_graphHeight, (_fps / _stage.frameRate) * _graphHeight);
				_memGraph = MIN(_graphHeight, SQRT(SQRT(_mem * 5000))) - 2;
				_memMaxGraph = MIN(_graphHeight, SQRT(SQRT(_memMax * 5000))) - 2;
				
				_graph.scroll(-1, 0);
				
				_graph.fillRect(_rectangle, _colorBg);
				_graph.setPixel(_width - 1, _graphHeight - _fpsGraph, _colorFps);
				_graph.setPixel(_width - 1, _graphHeight - ((_timer - _ms) >> 1), _colorMs);
				_graph.setPixel(_width - 1, _graphHeight - _memMaxGraph, _colorMax);
				_graph.setPixel(_width - 1, _graphHeight - _memGraph, _colorMem);
				
				_tf.htmlText = "<body><fps>FPS:" + _fps + "/" + _stage.frameRate
					+ "</fps><ms> MS:" + (_timer - _ms)
					+ "</ms><mem>MEM:" + _mem + "</mem><max>MAX:"
					+ _memMax + "</max></body>";
				
				_fps = -1;
			}
			
			_fps++;
			_ms = _timer;
		}
		
		
		/**
		 * @private
		 */
		private function onClick(e:MouseEvent):void
		{
			(mouseY / height > .5) ? _stage.frameRate-- : _stage.frameRate++;
		}
		
		
		/**
		 * @private
		 */
		private function onStageResize(e:Event):void
		{
			layout();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			Font.registerFont(TerminalstatsFont);
			
			focusRect = false;
			_memMax = 0;
			
			var a:Array = Registry.config.fpsMonitorColors;
			_colorBg = uint("0x" + a[0]);
			_colorFps = uint("0x" + a[1]);
			_colorMs = uint("0x" + a[2]);
			_colorMem = uint("0x" + a[3]);
			_colorMax = uint("0x" + a[4]);
			
			graphics.beginFill(_colorBg);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			_rectangle = new Rectangle(_width - 1, 0, 1, _height - 50);
			
			var s:StyleSheet = new StyleSheet();
			s.setStyle("body", {fontSize: 8, fontFamily: "Terminalstats", leading: 2});
			s.setStyle("fps", {color: hex2css(_colorFps)});
			s.setStyle("ms", {color: hex2css(_colorMs)});
			s.setStyle("mem", {color: hex2css(_colorMem)});
			s.setStyle("max", {color: hex2css(_colorMax)});
			
			_tf = new TextField();
			_tf.x = _tf.y = 2;
			_tf.width = _width - 4;
			_tf.height = 42;
			_tf.styleSheet = s;
			_tf.selectable = false;
			_tf.mouseEnabled = false;
			_tf.embedFonts = true;
			_tf.antiAliasType = AntiAliasType.NORMAL;
			_tf.gridFitType = GridFitType.PIXEL;
			addChild(_tf);
			
			_graphHeight = _height - 50;
			_graph = new BitmapData(_width, _graphHeight, false, _colorBg);
			graphics.beginBitmapFill(_graph); // , new Matrix(1, 0, 0, 1, 0, 50)
			graphics.drawRect(0, 50, _width, _height - 50);
		}
		
		
		/**
		 * Positions the FPSMonitor according to the config variable 'fpsMonitorPosition'.
		 * @private
		 */
		private function layout():void
		{
			switch (Registry.config.fpsMonitorPosition.toLowerCase())
			{
				case "tl":
					x = 4;
					y = 4;
					break;
				case "bl":
					x = 4;
					y = _stage.stageHeight - _height - 4;
					break;
				case "br":
					x = _stage.stageWidth - _width - 4;
					y = _stage.stageHeight - _height - 4;
					break;
				default:
					x = _stage.stageWidth - _width - 4;
					y = 4;
			}
		}
		
		
		/**
		 * @private
		 */
		private function hex2css(color:uint):String
		{
			return "#" + color.toString(16);
		}
	}
}
