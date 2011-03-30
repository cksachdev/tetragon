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
 *   __| ___  __  __   __| ___  __  __  ___  
 *  (__|(__/_(___(__(_(__|(__/_|  )(___(__/__
 *  tile scrolling engine
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
package extra.game.render.tile
{
	import com.hexagonstar.util.display.StageReference;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	
	/**
	 * Main class of the Tile scrolling Engine.
	 */
	public class TileScroller extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const EDGE_MODE_OFF:int		= 0;
		public static const EDGE_MODE_HALT:int		= 1;
		public static const EDGE_MODE_WRAP:int		= 2;
		public static const EDGE_MODE_BOUNCE:int	= 3;
		
		private static const BOUNDINGBOX_COLORS:Array =
		[
			0xFF0000, 0x00FF00, 0x0000FF, 0xFF8800, 0x00FFFF, 0xFFFF00
		];
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _bitmap:Bitmap;
		private var _buffer:BitmapData;
		private var _bufferMatrix:Matrix;
		private var _bufferRectangle:Rectangle;
		private var _container:Sprite;
		private var _debugContainer:Sprite;
		private var _tilemap:TileMap;
		private var _areaGrid:Sprite;
		private var _timer:Timer;
		private var _tileAnimTimer:Timer;
		
		private var _fps:int;
		private var _ms:int;
		private var _mss:int;
		private var _msPrev:int;
		private var _time:int;
		private var _frameCount:int;
		
		private var _xPos:Number;
		private var _yPos:Number;
		private var _xPosOld:Number;
		private var _yPosOld:Number;
		private var _xVelocity:Number;
		private var _yVelocity:Number;
		private var _decel:Number;
		
		private var _speed:int;
		private var _speedScaled:int;
		private var _speedH:int;
		private var _speedHScaled:int;
		private var _speedV:int;
		private var _speedVScaled:int;
		private var _speedAvr:Number;
		private var _frameRate:int;
		private var _tileAnimFrameRate:int;
		private var _width:int;
		private var _height:int;
		private var _areaX:int;
		private var _areaY:int;
		private var _oldAreaX:int;
		private var _oldAreaY:int;
		private var _visibleObjectCount:int;
		private var _visibleAnimTileCount:int;
		private var _cachedObjectCount:int;
		private var _bgColor:uint;
		private var _opa:int;
		private var _edgeMode:int;
		private var _scale:Number;
		
		private var _mapWidth:int;
		private var _mapHeight:int;
		private var _mapMargin:int;
		private var _mapBoundaryLeft:int;
		private var _mapBoundaryRight:int;
		private var _mapBoundaryTop:int;
		private var _mapBoundaryBottom:int;
		private var _mapBoundaryLeftW:int;
		private var _mapBoundaryRightW:int;
		private var _mapBoundaryTopW:int;
		private var _mapBoundaryBottomW:int;
		
		private var _groups:Vector.<TileGroup>;
		private var _areas:Object;
		private var _flaggedGroupIDs:Object;
		private var _visibleGroupIDs:Object;
		private var _visibleAnimTiles:Object;
		
		private var _onFrame:Function;
		
		private var _allowHScroll:Boolean;
		private var _allowVScroll:Boolean;
		private var _autoScrollH:Boolean;
		private var _autoScrollV:Boolean;
		private var _reachedHEdge:Boolean;
		private var _reachedVEdge:Boolean;
		private var _scrollLeft:Boolean;
		private var _scrollRight:Boolean;
		private var _scrollUp:Boolean;
		private var _scrollDown:Boolean;
		
		private var _started:Boolean;
		private var _paused:Boolean;
		private var _useTimer:Boolean;
		private var _autoPurge:Boolean;
		private var _cacheObjects:Boolean;
		private var _wrap:Boolean;
		
		private var _showBuffer:Boolean;
		private var _showAreas:Boolean;
		private var _showMapBoundaries:Boolean;
		private var _showBoundingBoxes:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function TileScroller(width:int = 0, height:int = 0)
		{
			super();
			setup();
			setViewportSize(width, height);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * setSize
		 */
		public function setViewportSize(width:int, height:int):void
		{
			if (width > 0) _width = width;
			else _width = StageReference.stageWidth;
			
			if (height > 0) _height = height;
			else _height = StageReference.stageHeight;
			
			setupView();
			
			/* If size was changed after we gave a tilemap, we need to to re-setup the map. */
			if (_tilemap) setupTilemap();
			
			/* Redraw areagrid if it was active. */
			if (_showAreas)
			{
				showAreas = false;
				setTimeout(function():void { showAreas = true; }, _ms);
			}
			
			forceRedraw();
		}
		
		
		/**
		 * Starts the TileScroller.
		 */
		public function start():void
		{
			if (_started) return;
			_started = true;
			_frameCount = 0;
			
			if (_useTimer)
			{
				_timer.delay = calculateTimerDelay();
				_timer.addEventListener(TimerEvent.TIMER, onEnterFrame);
				_timer.start();
			}
			else
			{
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
			_tileAnimTimer.start();
		}
		
		
		/**
		 * Stops the TileScroller.
		 */
		public function stop():void
		{
			if (!_started) return;
			_tileAnimTimer.stop();
			if (_useTimer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onEnterFrame);
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			_started = false;
		}
		
		
		/**
		 * Resets the TileScroller.
		 */
		public function reset():void
		{
			/* These two could be messed up if we reset manually, so disabled! */
			//_visibleObjectCount = 0;
			//_cachedObjectCount = 0;
			
			_fps = 0;
			_areaX = 0;
			_areaY = 0;
			_oldAreaX = -1;
			_oldAreaY = -1;
			_xPos = 0;
			_yPos = 0;
			_xPosOld = NaN;
			_yPosOld = NaN;
			_xVelocity = 0;
			_yVelocity = 0;
			
			_paused = false;
			_scrollLeft = false;
			_scrollRight = false;
			_scrollUp = false;
			_scrollDown = false;
			_reachedHEdge = false;
			_reachedVEdge = false;
			
			if (_container)
			{
				_container.x = 0;
				_container.y = 0;
			}
		}
		
		
		/**
		 * Scrolls the tilescroller into the specified direction.
		 */
		public function scroll(direction:String):void
		{
			if (direction == "l")
			{
				_scrollRight = false;
				_scrollLeft = true;
			}
			else if (direction == "r")
			{
				_scrollLeft = false;
				_scrollRight = true;
			}
			else if (direction == "u")
			{
				_scrollDown = false;
				_scrollUp = true;
			}
			else if (direction == "d")
			{
				_scrollUp = false;
				_scrollDown = true;
			}
		}
		
		
		/**
		 * Stops scrolling in the specified direction.
		 */
		public function stopScroll(direction:String):void
		{
			if (direction == "l") _scrollLeft = false;
			else if (direction == "r") _scrollRight = false;
			else if (direction == "u") _scrollUp = false;
			else if (direction == "d") _scrollDown = false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The tilemap that is currently used by the TileScroller.
		 */
		public function get tilemap():TileMap
		{
			return _tilemap;
		}
		public function set tilemap(v:TileMap):void
		{
			var oldStarted:Boolean = _started;
			var oldShowBuffer:Boolean = _showBuffer;
			var oldShowAreas:Boolean = _showAreas;
			var oldShowMapBoundaries:Boolean = _showMapBoundaries;
			if (oldStarted)
			{
				stop();
				showBuffer = false;
				showAreas = false;
				showMapBoundaries = false;
				_container.graphics.clear();
				while (_container.numChildren > 0)
				{
					_container.removeChildAt(0);
				}
				for each (var a:AnimTile in _visibleAnimTiles)
				{
					delete _visibleAnimTiles[a.id];
				}
				_visibleAnimTiles = {};
				_visibleObjectCount = 0;
				_visibleAnimTileCount = 0;
				_cachedObjectCount = 0;
				reset();
			}
			
			if (_tilemap) _tilemap.dispose();
			
			_tilemap = v;
			setupTilemap();
			
			if (oldStarted)
			{
				showMapBoundaries = oldShowMapBoundaries;
				showAreas = oldShowAreas;
				showBuffer = oldShowBuffer;
				start();
			}
		}
		
		
		/**
		 * Determines whether the tilescroller is paused or not.
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused) return;
			_paused = v;
		}
		
		
		/**
		 * The width of the scroll viewport.
		 */
		public function get viewportWidth():int
		{
			return _width;
		}
		public function set viewportWidth(v:int):void
		{
			if (v == _width) return;
			_width = v;
			setViewportSize(_width, _height);
		}
		
		
		/**
		 * The height of the scroll viewport.
		 */
		public function get viewportHeight():int
		{
			return _height;
		}
		public function set viewportHeight(v:int):void
		{
			if (v == _height) return;
			_height = v;
			setViewportSize(_width, _height);
		}
		
		
		/**
		 * The speed of the tile scroller. This is a value that determines by how many
		 * pixels the tilemap is shifted when scrolling. The default is 10. setting this
		 * to 0 stops the ability of scrolling. Setting this value to a negative value will
		 * invert the scroll direction. This property set both horizontal and vertical
		 * speed to the same value.
		 */
		public function get speed():int
		{
			return _speed;
		}
		public function set speed(v:int):void
		{
			_speed = _speedH = _speedV = _speedAvr = v;
			_speedScaled = _speedHScaled = _speedVScaled = roundSpeed(_speed / _scale);
		}
		
		
		/**
		 * The horizontal scroll speed.
		 */
		public function get speedH():int
		{
			return _speedH;
		}
		public function set speedH(v:int):void
		{
			_speedH = v;
			_speedHScaled = roundSpeed(_speedH / _scale);
			_speedAvr = (_speedH + _speedV) * .5;
		}
		
		
		/**
		 * The vertical scroll speed.
		 */
		public function get speedV():int
		{
			return _speedV;
		}
		public function set speedV(v:int):void
		{
			_speedV = v;
			_speedVScaled = roundSpeed(_speedV / _scale);
			_speedAvr = (_speedH + _speedV) * .5;
		}
		
		
		/**
		 * The deceleration factor that applies to the scroll velocity after scrolling
		 * is stopped. Valid values are from 0 (instant stop) to 0.99 (max. easing).
		 * The default value is 0.9.
		 */
		public function get deceleration():Number
		{
			return _decel;
		}
		public function set deceleration(v:Number):void
		{
			_decel = (v < 0) ? 0 : (v > 0.99) ? 0.99 : v;
		}
		
		
		/**
		 * The framerate with that the tilescroller runs. Only used when useTimer is true.
		 */
		public function get frameRate():int
		{
			return _frameRate;
		}
		public function set frameRate(v:int):void
		{
			if (v == _frameRate) return;
			_frameRate = v;
			if (_useTimer) _timer.delay = calculateTimerDelay();
		}
		
		
		/**
		 * The framerate at that animated tiles are playing. The default is 12.
		 */
		public function get tileAnimFrameRate():int
		{
			return _tileAnimFrameRate;
		}
		public function set tileAnimFrameRate(v:int):void
		{
			if (v == _tileAnimFrameRate || v < 1) return;
			var delay:Number = 1000 / v;
			if (delay < 16.6) return;
			_tileAnimFrameRate = v;
			_tileAnimTimer.delay = delay;
		}
		
		
		/**
		 * The actual framerate at that the tilescroller runs currently. This value can be
		 * used to monitor the scrolling performance.
		 */
		public function get fps():int
		{
			return _fps;
		}
		
		
		/**
		 * The time in milliseconds that it took the tilescroller to render one frame.
		 */
		public function get ms():int
		{
			return _ms;
		}
		
		
		/**
		 * The current x position on the tilemap.
		 */
		public function get xPos():int
		{
			return _xPos;
		}
		
		
		/**
		 * The current y position on the tilemap.
		 */
		public function get yPos():int
		{
			return _yPos;
		}
		
		
		/**
		 * A String that can be used to identify the tile area which currently has
		 * it's top-left corner visible on the scroll area. The format of the returned
		 * string is X:Y where X and Y are not pixel coordinates but serial values in
		 * x and y order on which tile areas are placed.
		 */
		public function get currentArea():String
		{
			return "x" + _areaX + " y" + _areaY;
		}
		
		
		/**
		 * A string with IDs of all currently visible areas. Only used for debugging!
		 */
		public function get currentAreas():String
		{
			return "" + _areaX + ":" + _areaY + ""
				+ "  " + (_areaX + 1) + ":" + _areaY + ""
				+ "\n" + _areaX + ":" + (_areaY + 1) + ""
				+ "  " + (_areaX + 1) + ":" + (_areaY + 1) + "";
		}
		
		
		/**
		 * Determines if the tilescroller automatically scrolls horizontally. Speed and
		 * direction can be changed with the speed property.
		 */
		public function get autoScrollH():Boolean
		{
			return _autoScrollH;
		}
		public function set autoScrollH(v:Boolean):void
		{
			if (v == _autoScrollH) return;
			_autoScrollH = v;
		}
		
		
		/**
		 * Determines if the tilescroller automatically scrolls vertically. Speed and
		 * direction can be changed with the speed property.
		 */
		public function get autoScrollV():Boolean
		{
			return _autoScrollV;
		}
		public function set autoScrollV(v:Boolean):void
		{
			if (v == _autoScrollV) return;
			_autoScrollV = v;
		}
		
		
		/**
		 * Determines the behavior of the scrolling when an edge (incl. margin) of the
		 * tilemap is reached. The following choices are available: halt, wrap and bounce.
		 * Bounce only has an effect with autoscrolling turned on.
		 */
		public function get edgeMode():int
		{
			return _edgeMode;
		}
		public function set edgeMode(v:int):void
		{
			reset();
			_tilemap.edgeMode = v;
			setupTilemap();
		}
		
		
		public function get scale():Number
		{
			return _scale;
		}
		public function set scale(v:Number):void
		{
			/* No down-scaling supported yet, onlu up-scaling! */
			if (v == _scale || v < 1.0 || v > 10) return;
			_scale = v;
			if (_bufferMatrix)
			{
				_bufferMatrix.a = _bufferMatrix.d = _scale;
				_mapBoundaryRight = _mapWidth + _mapMargin - (_width / _scale);
				_mapBoundaryBottom = _mapHeight + _mapMargin - (_height / _scale);
				_speedScaled = roundSpeed(_speed / _scale);
				_speedHScaled = roundSpeed(_speedH / _scale);
				_speedVScaled = roundSpeed(_speedV / _scale);
				forceRedraw();
			}
		}
		
		
		/**
		 * Determines whether the tilegroup buffer is rendered or not. This is only
		 * useful for debugging and should best be left turned off (false). In practice
		 * what the tilescroller does if showBuffer is set to true is that it not only
		 * displays the render buffer but also the underlying tilegroup container which
		 * normally isn't on the display list.
		 */
		public function get showBuffer():Boolean
		{
			return _showBuffer;
		}
		public function set showBuffer(v:Boolean):void
		{
			if (v == _showBuffer) return;
			_showBuffer = v;
			if (_showBuffer)
			{
				_debugContainer = new Sprite();
				_debugContainer.alpha = 0.3;
				_debugContainer.addChild(_container);
				if (_areaGrid) _debugContainer.addChild(_areaGrid);
				addChildAt(_debugContainer, 0);
			}
			else
			{
				if (_debugContainer)
				{
					_debugContainer.removeChild(_container);
					if (_areaGrid) _debugContainer.removeChild(_areaGrid);
					removeChild(_debugContainer);
					_debugContainer = null;
				}
			}
		}
		
		
		/**
		 * If set to true the tilescroller renders the boundaries of the currently
		 * used tilemap. This property works only after a tilemap has been supplied
		 * to the tilescroller. Only works after a tilemap has been provided to the scroller.
		 */
		public function get showMapBoundaries():Boolean
		{
			return _showMapBoundaries;
		}
		public function set showMapBoundaries(v:Boolean):void
		{
			if (!_container || !_tilemap) return;
			if (v == _showMapBoundaries) return;
			_showMapBoundaries = v;
			if (_showMapBoundaries)
			{
				_container.graphics.lineStyle(5, 0xFF0000, .85, true, LineScaleMode.NORMAL,
					CapsStyle.SQUARE, JointStyle.MITER);
				_container.graphics.drawRect(-2, -2, _mapWidth + 3, _mapHeight + 3);
				if (_mapMargin > 0)
				{
					_container.graphics.lineStyle(1, 0xFF5500, .65, true, LineScaleMode.NORMAL,
						CapsStyle.SQUARE, JointStyle.MITER);
					_container.graphics.drawRect(_mapBoundaryLeft, _mapBoundaryTop,
						_mapWidth + (_mapMargin * 2) - 1, _mapHeight + (_mapMargin * 2) - 1);
				}
			}
			else
			{
				_container.graphics.clear();
			}
			forceRedraw();
		}
		
		
		/**
		 * Determines if tile area boundaries are rendered. Useful for debugging.
		 * Only works after a tilemap has been provided to the scroller.
		 */
		public function get showAreas():Boolean
		{
			return _showAreas;
		}
		public function set showAreas(v:Boolean):void
		{
			if (!_container || !_tilemap) return;
			if (v == _showAreas) return;
			_showAreas = v;
			if (_showAreas)
			{
				_areaGrid = new Sprite();
				_areaGrid.name = "areagrid";
				_areaGrid.graphics.lineStyle(2, 0xFF00FF, 1.0, true, LineScaleMode.NORMAL,
					CapsStyle.NONE, JointStyle.MITER);
				var areasX:int = _tilemap.maxAreaX + 1;
				var areasY:int = _tilemap.maxAreaY + 1;
				var totalW:int = areasX * _width;
				var totalH:int = areasY * _height;
				var c:int = -_width;
				var i:int;
				for (i = -1; i <= areasX; i++)
				{
					_areaGrid.graphics.moveTo(c, -_height);
					_areaGrid.graphics.lineTo(c, totalH);
					c += _width;
				}
				c = -_height;
				for (i = -1; i <= areasY; i++)
				{
					_areaGrid.graphics.moveTo(-_width, c);
					_areaGrid.graphics.lineTo(totalW, c);
					c += _height;
				}
				
				/* Add text labels for areas. Only for temporary debugging! */
				var f:TextFormat = new TextFormat("Terminalscope", 16, 0xFFFFFF);
				c = 0;
				for (var y:int = -1; y < areasY; y++)
				{
					for (var x:int = -1; x < areasX; x++)
					{
						var t:TextField = new TextField();
						t.background = true;
						t.backgroundColor = 0xFF00FF;
						t.selectable = false;
						t.embedFonts = true;
						t.defaultTextFormat = f;
						t.width = 74;
						t.height = 17;
						t.text = c + " " + x + ":" + y;
						t.x = 1 + x * _width;
						t.y = 1 + y * _height;
						t.cacheAsBitmap = true;
						_areaGrid.addChild(t);
						c++;
					}
				}
				
				if (_debugContainer) _debugContainer.addChild(_areaGrid);
			}
			else
			{
				if (_areaGrid)
				{
					if (_debugContainer && _debugContainer.getChildByName("areagrid"))
						_debugContainer.removeChild(_areaGrid);
					_areaGrid = null;
				}
			}
			forceRedraw();
		}
		
		
		/**
		 * Determines if tilegroup bounding boxes are rendered. Useful for debugging.
		 */
		public function get showBoundingBoxes():Boolean
		{
			return _showBoundingBoxes;
		}
		public function set showBoundingBoxes(v:Boolean):void
		{
			if (v == _showBoundingBoxes) return;
			_showBoundingBoxes = v;
			for each (var g:TileGroup in _groups)
			{
				if (_showBoundingBoxes)
				{
					if (!g.boundingBox) createBBox(g);
					if (g.symbol) g.symbol.addChild(g.boundingBox);
				}
				else
				{
					if (g.boundingBox)
					{
						if (g.symbol) g.symbol.removeChild(g.boundingBox);
						g.boundingBox = null;
					}
				}
				
				/* Need to re-add the objects that are already placed if caching
				 * is disabled or enabled. */
				if (g.placed)
				{
					_container.removeChild(_container.getChildByName("" + g.id));
					g.placed = false;
					g.dispose();
					_visibleObjectCount--;
					/* No cache count decrease if caching is disabled! */
					if (_cacheObjects) _cachedObjectCount--;
				}
			}
			forceRedraw();
		}
		
		
		/**
		 * Allows to disable/enable automatic object purge calculation. By default this
		 * option is active (true) and can be left as that. If disabled you have to set
		 * <code>objectPurgeAmount</code> manually.
		 */
		public function get autoPurge():Boolean
		{
			return _autoPurge;
		}
		public function set autoPurge(v:Boolean):void
		{
			_autoPurge = v;
		}
		
		
		/**
		 * Can be used to disable/enable object (tilegroup) caching. By default any tile
		 * group that is created is cached and re-used later.  You don't need to disable
		 * this unless memory consumption is more critical than CPU cycles for you.
		 */
		public function get cacheObjects():Boolean
		{
			return _cacheObjects;
		}
		public function set cacheObjects(v:Boolean):void
		{
			if (v == _cacheObjects) return;
			_cacheObjects = v;
			/* If caching was disabled, purge all cached objects. */
			if (!_cacheObjects)
			{
				if (_groups)
				{
					for each (var g:TileGroup in _groups)
					{
						/* Don't dispose if currently on-screen! */
						if (g.placed) continue;
						g.dispose();
					}
					_cachedObjectCount = 0;
				}
			}
		}
		
		
		/**
		 * A value that determines how many off-screen objects (tilegroups) are removed
		 * at once per loop. By default the tilescroler calculates this value automatically
		 * by measuring the visible object count and the current scroll speed. If you want
		 * to set this value manually yuo first have to set <code>autoPurge</code> to false.
		 * <br/>
		 * Setting the optimal value for this depends on the tilegroup amount of the used
		 * tilemap, the scrolling speed and the viewport size. As a general rule of thumb
		 * the more objects are drawn to the screen and the faster the scrolling, the
		 * higher this value needs to be set.
		 * <br/>
		 * If set to 0 the tile engine will remove all off-screen objects on every loop
		 * which might reduce performance.
		 */
		public function get objectPurgeAmount():int
		{
			return _opa;
		}
		public function set objectPurgeAmount(v:int):void
		{
			if (v < 0) v = 0;
			_opa = v;
		}
		
		
		/**
		 * The number of objects (tile groups) that are currently visible on the scroll area.
		 */
		public function get visibleObjectCount():int
		{
			return _visibleObjectCount;
		}
		
		
		/**
		 * The number of animated tiles that are currently visible on the scroll area.
		 */
		public function get visibleAnimTileCount():int
		{
			return _visibleAnimTileCount;
		}
		
		
		/**
		 * The number of objects (tile groups) that are currently cached. Used for debugging.
		 */
		public function get cachedObjectCount():int
		{
			return _cachedObjectCount;
		}
		
		
		/**
		 * Determines whether a Timer is used to trigger the scroller (true) or the scroller
		 * is triggered by the application framerate (false).
		 */
		public function get useTimer():Boolean
		{
			return _useTimer;
		}
		public function set useTimer(v:Boolean):void
		{
			if (v == _useTimer) return;
			_useTimer = v;
			if (_useTimer)
			{
				_timer = new Timer(calculateTimerDelay(), 0);
				if (_started)
				{
					_timer.addEventListener(TimerEvent.TIMER, onEnterFrame);
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					_frameCount = 0;
					_timer.start();
				}
			}
			else
			{
				if (_started)
				{
					_timer.stop();
					_timer.removeEventListener(TimerEvent.TIMER, onEnterFrame);
					_frameCount = 0;
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
				}
				_timer = null;
			}
		}
		
		
		/**
		 * Callback function that is called after every time a frame is rendered. The callback
		 * function receives one argument which is a reference to this tilescroller.
		 */
		public function get onFrame():Function
		{
			return _onFrame;
		}
		public function set onFrame(v:Function):void
		{
			_onFrame = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onEnterFrame(e:Event):void
		{
			if (!_paused)
			{
				updatePosition();
				draw();
			}
			
			if (_onFrame != null) _onFrame(this);
			
			/* Measure current FPS and the time it took to process a frame. */
			_time = getTimer();
			if (_time - 1000 > _msPrev)
			{
				_msPrev = _time;
				_ms = _time - _mss;
				_fps = _frameCount;
				_frameCount = -1;
			}
			_frameCount++;
			_mss = _time;
			
			/* Magic sauce for when using a timer. */
			if (_useTimer) TimerEvent(e).updateAfterEvent();
		}
		
		
		/**
		 * @private
		 */
		private function onTileAnimTimer(e:TimerEvent):void
		{
			if (_paused) return;
			if (_visibleAnimTileCount < 1) return;
			for each (var a:AnimTile in _visibleAnimTiles)
			{
				a.nextFrame();
			}
			_xPosOld = NaN;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets up the object instance. This method may only contain instructions that
		 * should be executed exactly once during object lifetime, usually right after
		 * the object has been instatiated.
		 * 
		 * @private
		 */
		private function setup():void
		{
			_frameRate = StageReference.stage.frameRate;
			_tileAnimFrameRate = 12;
			_speed = _speedH = _speedV = _speedAvr = 10;
			_scale = 1.0;
			_speedScaled = _speedHScaled = _speedVScaled = roundSpeed(_speed / _scale);
			_decel = 0.9;
			_opa = 0;
			_visibleObjectCount = 0;
			_visibleAnimTileCount = 0;
			_cachedObjectCount = 0;
			_edgeMode = TileScroller.EDGE_MODE_HALT;
			
			_started = false;
			_useTimer = false;
			_autoScrollV = false;
			_autoScrollH = false;
			_showBuffer = false;
			_showMapBoundaries = false;
			_showBoundingBoxes = false;
			_showAreas = false;
			_wrap = false;
			
			_autoPurge = true;
			_cacheObjects = true;
			
			_visibleAnimTiles = {};
			_container = new Sprite();
			
			_tileAnimTimer = new Timer(1000 / _tileAnimFrameRate);
			_tileAnimTimer.addEventListener(TimerEvent.TIMER, onTileAnimTimer);
			
			_bufferMatrix = new Matrix();
			_bitmap = new Bitmap(null, PixelSnapping.ALWAYS, false);
			addChild(_bitmap);
			
			reset();
		}
		
		
		/**
		 * Sets up the view part of the scroller. this is called anytime a new tilemap
		 * is provided to the scroller.
		 * 
		 * @private
		 */
		private function setupView():void
		{
			if (_buffer) _buffer.dispose();
			_buffer = new BitmapData(_width, _height, true, _bgColor);
			_bufferRectangle = new Rectangle(0, 0, _width, _height);
			_bitmap.bitmapData = _buffer;
		}
		
		
		/**
		 * @private
		 */
		private function setupTilemap():void
		{
			_tilemap.prepare(_width, _height);
			_areas = _tilemap.areas;
			_groups = _tilemap.groups;
			_mapWidth = _tilemap.width;
			_mapHeight = _tilemap.height;
			_mapMargin = _tilemap.margin;
			_bgColor = _tilemap.backgroundColor;
			_edgeMode = _tilemap.edgeMode;
			_wrap = _tilemap.wrap;
			_mapBoundaryLeft = 0 - _mapMargin;
			_mapBoundaryTop = 0 - _mapMargin;
			_mapBoundaryRight = _mapWidth + _mapMargin - (_width / _scale);
			_mapBoundaryBottom = _mapHeight + _mapMargin - (_height / _scale);
			_mapBoundaryLeftW = 0 - _width;
			_mapBoundaryRightW = _mapWidth - _width;
			_mapBoundaryTopW = 0 - _height;
			_mapBoundaryBottomW = _mapHeight - _height;
			
			_allowHScroll = _mapWidth + (_mapMargin * 2) > _width;
			_allowVScroll = _mapHeight + (_mapMargin * 2) > _height;
		}
		
		
		/**
		 * Updates the scroll position.
		 * 
		 * @private
		 */
		private function updatePosition():void
		{
			if (_allowHScroll)
			{
				/* Check manual h-scrolling. */
				if (_scrollLeft)
				{
					_xVelocity = -_speedHScaled;
				}
				else if (_scrollRight)
				{
					_xVelocity = _speedHScaled;
				}
				else
				{
					/* Deaccelerate to a halt in x */
					if (_xVelocity < -.0001 || _xVelocity > .0001) _xVelocity *= _decel;
					else _xVelocity = 0;
				}
				/* Check automatic h-scrolling. */
				if (_autoScrollH)
				{
					if (_reachedHEdge && _reachedVEdge)
					{
						_reachedHEdge = _reachedVEdge = false;
						/* Could be that we disabled bounce mode in between, so check. */
						if (_edgeMode == TileScroller.EDGE_MODE_BOUNCE)
						{
							_speedHScaled = -_speedHScaled;
						}
					}
					_xPos += _speedHScaled;
				}
			}
			
			if (_allowVScroll)
			{
				/* Check manual v-scrolling. */
				if (_scrollUp)
				{
					_yVelocity = -_speedVScaled;
				}
				else if (_scrollDown)
				{
					_yVelocity = _speedVScaled;
				}
				else
				{
					/* Deaccelerate to a halt in y */
					if (_yVelocity < -.0001 || _yVelocity > .0001) _yVelocity *= _decel;
					else _yVelocity = 0;
				}
				/* Check automatic v-scrolling. */
				if (_autoScrollV)
				{
					if (_reachedVEdge && _reachedHEdge)
					{
						_reachedHEdge = _reachedVEdge = false;
						/* Could be that we disabled bounce mode in between, so check. */
						if (_edgeMode == TileScroller.EDGE_MODE_BOUNCE)
						{
							_speedVScaled = -_speedVScaled;
						}
					}
					_yPos += _speedVScaled;
				}
			}
			
			/* Add velocity to temporary coord vars for boundary check. */
			var xp:Number = _xPos + _xVelocity;
			var yp:Number = _yPos + _yVelocity;
			
			switch (_edgeMode)
			{
				/* --- Edge Mode: Halt ------------------------------------------------------- */
				case TileScroller.EDGE_MODE_HALT:
					if (xp <= _mapBoundaryLeft) xp = _mapBoundaryLeft;
					else if (xp >= _mapBoundaryRight) xp = _mapBoundaryRight;
					if (yp <= _mapBoundaryTop) yp = _mapBoundaryTop;
					else if (yp >= _mapBoundaryBottom) yp = _mapBoundaryBottom;
					break;
				/* --- Edge Mode: Wrap ------------------------------------------------------- */
				case TileScroller.EDGE_MODE_WRAP:
					/* As soon as we would scroll beyond the left wrap area ... */
					if (xp < _mapBoundaryLeftW)
					{
						/* ... re-position onto the right-most area. */
						xp = _mapBoundaryRightW;
					}
					/* As soon as we would scroll beyond the right-most area ... */
					else if (xp > _mapBoundaryRightW)
					{
						/* ... re-position onto the left wrap area. */
						xp = _mapBoundaryLeftW;
					}
					/* As soon as we would scroll beyond the top wrap area ... */
					if (yp < _mapBoundaryTopW)
					{
						/* ... re-position onto the bottom-most area. */
						yp = _mapBoundaryBottomW;
					}
					/* As soon as we would scroll beyond the bottom-most area ... */
					else if (yp > _mapBoundaryBottomW)
					{
						/* ... re-position onto the top wrap area. */
						yp = _mapBoundaryTopW;
					}
					break;
				/* --- Edge Mode: Bounce ----------------------------------------------------- */
				case TileScroller.EDGE_MODE_BOUNCE:
					if (xp <= _mapBoundaryLeft)
					{
						xp = _mapBoundaryLeft;
						_reachedHEdge = true;
					}
					else if (xp >= _mapBoundaryRight)
					{
						xp = _mapBoundaryRight;
						_reachedHEdge = true;
					}
					if (yp <= _mapBoundaryTop)
					{
						yp = _mapBoundaryTop;
						_reachedVEdge = true;
					}
					else if (yp >= _mapBoundaryBottom)
					{
						yp = _mapBoundaryBottom;
						_reachedVEdge = true;
					}
			}
			
			/* Finally set current map coords from temporary vars. */
			_xPos = xp;
			_yPos = yp;
		}
		
		
		/**
		 * @private
		 */
		private function draw():void
		{
			var xp:int = _xPos;
			var yp:int = _yPos;
			var ax:int = xp / _width;
			var ay:int = yp / _height;
			var sx:int = xp + _width;	// Screen right edge x coord.
			var sy:int = yp + _height;	// Screen bottom edge y coord.
			var g:TileGroup;
			var s:String;
			
			/* Correct negative area coords. */
			if (xp < 0) ax += -1;
			if (yp < 0) ay += -1;
			
			/* If no new area, we use the time to delete old tile groups no longer visible. */
			if (ax == _oldAreaX && ay == _oldAreaY)
			{
				var removeCount:int = 0;
				for (var i:int = 0; i < _visibleObjectCount; i++)
				{
					var d:DisplayObject = _container.getChildAt(i);
					if (!_visibleGroupIDs[d.name])
					{
						_container.removeChild(d);
						g = _groups[int(d.name)];
						g.placed = false;
						if (!_cacheObjects) g.dispose();
						_visibleObjectCount--;
						_visibleAnimTileCount -= g.animTileCount;
						for each (var a:AnimTile in g.animTiles)
						{
							delete _visibleAnimTiles[a.id];
						}
						removeCount++;
						/* Only break after x counts. */
						if (removeCount == _opa) break;
					}
				}
			}
			/* If we have entered a new area, calculate list of tile groups to check. */
			else
			{
				/* Calculate automatic object purge-per-loop amount. */
				if (_autoPurge)
				{
					_opa = (_visibleObjectCount * _speedAvr * .005) + 1;
					/* Funky Math.abs for negative speed! */
					if (_speedAvr < 0) _opa = (_opa < 1 ? -_opa : _opa) + 1;
				}
				
				/* Set new area to current area */
				_oldAreaX = ax;
				_oldAreaY = ay;
				
				/* Create new list for IDs of tile groups which MAY be visible. */
				_flaggedGroupIDs = {};
				
				/* Loop through the areas in top left, top right, bottom left and bottom right
				 * corners respectively and set any group to visible if it is in those areas. */
				if (!_wrap)
				{
					var ta:TileArea = _areas["area" + ax + "" + ay];
					if (ta) for (s in ta.flags) _flaggedGroupIDs[s] = true;
					if ((ta = _areas["area" + (ax + 1) + "" + ay]))
						for (s in ta.flags) _flaggedGroupIDs[s] = true;
					if ((ta = _areas["area" + ax + "" + (ay + 1)]))
						for (s in ta.flags) _flaggedGroupIDs[s] = true;
					if ((ta = _areas["area" + (ax + 1) + "" + (ay + 1)]))
						for (s in ta.flags) _flaggedGroupIDs[s] = true;
				}
				else
				{
					flagVisibleTileGroupsWrap(ax, ay);
					flagVisibleTileGroupsWrap(ax + 1, ay);
					flagVisibleTileGroupsWrap(ax, ay + 1);
					flagVisibleTileGroupsWrap(ax + 1, ay + 1);
				}
			}
			
			/* Scroll the tiles container. */
			_container.x = 0 - xp;
			_container.y = 0 - yp;
			
			if (_showAreas)
			{
				_areaGrid.x = 0 - xp;
				_areaGrid.y = 0 - yp;
			}
			
			_visibleGroupIDs = {};
			
			for (s in _flaggedGroupIDs)
			{
				g = _groups[s];
				
				/* For every group in the visible areas... */
				if (g.right > xp)
				{
					/* ...check if it's on screen in the x-dimension... */
					if (g.x < sx)
					{
						/* (faster to write each test as a separate if-statement) */
						if (g.bottom > yp)
						{
							/* ...and that it's on screen in the y-dimension */
							if (g.y < sy)
							{
								/* Set current group as VISIBLE */
								_visibleGroupIDs[s] = true;
								
								/* If the object sprite doesn't exist... */
								if (!g.placed)
								{
									/* ...create and place it in the container */
									placeTileGroup(g);
								}
							}
						}
					}
				}
			}
			
			/* Draw to bitmap buffer only if there is change. */
			if (_xPos != _xPosOld || _yPos != _yPosOld)
			{
				_bufferMatrix.translate(0 - (xp * _scale), 0 - (yp * _scale));
				_buffer.fillRect(_bufferRectangle, _bgColor);
				_buffer.draw(_container, _bufferMatrix);
				if (_showAreas) _buffer.draw(_areaGrid, _bufferMatrix);
				
				/* Reset matrix translation. */
				_bufferMatrix.tx = _bufferMatrix.ty = 0;
			}
			
			_areaX = ax;
			_areaY = ay;
			_xPosOld = _xPos;
			_yPosOld = _yPos;
		}
		
		
		/**
		 * @private
		 */
		private function flagVisibleTileGroupsWrap(areaX:int, areaY:int):void
		{
			var a:TileArea = _areas["area" + areaX + "" + areaY];
			if (!a) return;
			
			var f:Object;
			var n:String;
			var g:TileGroup;
			
			/* If we hit a wrapper area (coords x -1 and/or y -1) it has a wrapped area
			 * referenced so move all tilegroups from that area to the wrapper area. */
			if (a.wrapFlags)
			{
				f = a.wrapFlags;
				var oh:int = a.offsetH;
				var ov:int = a.offsetV;
				for (n in f)
				{
					_flaggedGroupIDs[n] = true;
					g = _groups[int(n)];
					/* If group is already wrapped, reset it first. */
					if (g.wrapped)
					{
						g.x -= g.offsetH;
						g.y -= g.offsetV;
						g.right -= g.offsetH;
						g.bottom -= g.offsetV;
						g.wrapped = false;
					}
					g.offsetH = oh;
					g.offsetV = ov;
					g.x += oh;
					g.y += ov;
					g.right += oh;
					g.bottom += ov;
					if (g.symbol)
					{
						g.symbol.x = g.x;
						g.symbol.y = g.y;
					}
					g.wrapped = true;
				}
				return;
			}
			
			f = a.flags;
			for (n in f)
			{
				_flaggedGroupIDs[n] = true;
				g = _groups[int(n)];
				if (g.wrapped)
				{
					g.x -= g.offsetH;
					g.y -= g.offsetV;
					g.right -= g.offsetH;
					g.bottom -= g.offsetV;
					if (g.symbol)
					{
						g.symbol.x = g.x;
						g.symbol.y = g.y;
					}
					g.wrapped = false;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function placeTileGroup(g:TileGroup):void
		{
			/* If tilegroup is already cached only add it to display list and we're done! */
			if (g.symbol)
			{
				g.placed = true;
				_container.addChild(g.symbol);
				_visibleObjectCount++;
				_visibleAnimTileCount += g.animTileCount;
				for each (var a:AnimTile in g.animTiles)
				{
					_visibleAnimTiles[a.id] = a;
				}
				return;
			}
			
			/* If the group's symbol wasn't created yet, create (and cache) it. */
			var i:int = g.tileCount;
			var s:Sprite = new Sprite();
			s.name = "" + g.id;
			s.x = g.x;
			s.y = g.y;
			
			/* Loop through and create all sub-tiles from the end to the first tile. */
			while (i--)
			{
				var t:Tile = g.tiles[i];
				if (!t.bitmap)
				{
					t.bitmap = new Bitmap(t.bitmapData, PixelSnapping.ALWAYS, false);
					
					if (t is AnimTile)
					{
						t.bitmap.scrollRect = new Rectangle(0, 0, t.width, t.height);
						t.bitmapData = AnimTile(t).frames.clone();
						t.bitmap.bitmapData = t.bitmapData;
					}
					
					t.bitmap.x = t.x;
					t.bitmap.y = t.y;
				}
				s.addChild(t.bitmap);
			}
			
			if (_showBoundingBoxes)
			{
				if (!g.boundingBox) createBBox(g);
				s.addChild(g.boundingBox);
			}
			
			if (_cacheObjects)
			{
				g.symbol = s;
				_cachedObjectCount++;
			}
			
			g.placed = true;
			_container.addChild(s);
			_visibleObjectCount++;
			_visibleAnimTileCount += g.animTileCount;
			for each (var a2:AnimTile in g.animTiles)
			{
				_visibleAnimTiles[a2.id] = a2;
			}
		}
		
		
		/**
		 * @private
		 */
		private function createBBox(g:TileGroup):void
		{
			g.boundingBox = new Shape();
			g.boundingBox.graphics.lineStyle(3, BOUNDINGBOX_COLORS[int(g.id) % 6],
				0.5, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			g.boundingBox.graphics.drawRect(0, 0, g.width - 1, g.height - 1);
		}
		
		
		/**
		 * Forces a redraw of the scroller view on the next frame.
		 * @private
		 */
		private function forceRedraw():void
		{
			setTimeout(function():void
			{
				_xPosOld = NaN;
				/* Hopefully we never reach an area of int.MIN_VALUE! However in that
				 * case it would simply not redraw all tilegroups immediately if we'd
				 * resize the viewport. */
				_oldAreaX = int.MIN_VALUE;
			}, _ms);
		}
		
		
		/**
		 * @private
		 */
		private function calculateTimerDelay():Number
		{
			var delay:Number = 1000 / _frameRate;
			if (delay < 16.6) delay = 16.6;
			return delay;
		}
		
		
		/**
		 * @private
		 */
		private function roundSpeed(v:Number):int
		{
			if (v > 0) return Math.ceil(v);
			if (v < 0) return Math.floor(v);
			return 0;
		}
	}
}
