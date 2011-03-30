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
package base.core.preload
{
	import com.hexagonstar.constants.Alignment;

	import flash.display.Sprite;
	import flash.events.Event;

	
	/**
	 * A simple preloader implementation that displays a loading percent bar and
	 * a pecent number on the screen.
	 */
	public class SimplePreloader extends Sprite implements IPreloader
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * A reference to the Preloader (which wraps this preloader).
		 * @private
		 */
		protected var _preloader:Preloader;
		
		/**
		 * How many frames to wait before initiating the preloader. This is a
		 * threshold used to wait for several frames before displaying the
		 * preloader bar and text in case the SWF is already in the cache or
		 * locally loaded in which case the preloader doesn't need to appear.
		 * Setting this value to 0 will always display the preloader.
		 * @private
		 */
		protected var _skipDelay:int = 10;
		
		/**
		 * This value determines how many frames to wait before the preloader
		 * bar and text are actually starting to fade out. This is useful to make
		 * the transition between preloader and main application less abrupt.
		 * @private
		 */
		protected var _fadeOutDelay:int = 40;
		
		/** @private */
		protected var _color:uint = 0xFFFFFF;
		/** @private */
		protected var _hAlignment:String = Alignment.LEFT;
		/** @private */
		protected var _vAlignment:String = Alignment.TOP;
		/** @private */
		protected var _padding:int = 20;
		
		/** @private */
		protected var _bar:LoadProgressBar;
		
		/** @private */
		protected var _factor:Number;
		/** @private */
		protected var _percentage:Number;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new BasicPreloader instance. This class does not need
		 * to be instatiated directly. The Preloader class does this on it's own.
		 * 
		 * @param preloader A reference to the wrapping Preloader.
		 */
		public function SimplePreloader(preloader:Preloader)
		{
			super();
			_preloader = preloader;
		}

		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the preloader.
		 */
		public function start():void
		{
			_preloader.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		
		/**
		 * Disposes the object. Called automatically by the wrapping Preloader
		 * after preloading is finished.
		 */
		public function dispose():void
		{
			_preloader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_preloader = null;
		}

		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets the preloader fadeout delay. This value determines how many
		 * frames to wait before the preloader bar and text are actually
		 * starting to fade out. This is useful to make the transition between
		 * preloader and main application less abrupt.
		 */
		public function set fadeOutDelay(v:int):void
		{
			_fadeOutDelay = v;
		}
		
		/**
		 * Sets the color value used by the preloader bar and text.
		 */
		public function set color(v:uint):void
		{
			_color = v;
		}
		
		/**
		 * Determines how the preloader is positioned horizontally.
		 * 
		 * @see #com.hexagonstar.data.constants.Alignment
		 */
		public function set horizontalAlignment(v:String):void
		{
			_hAlignment = v;
		}
		
		/**
		 * Determines how the preloader is positioned vertically.
		 * 
		 * @see #com.hexagonstar.data.constants.Alignment
		 */
		public function set verticalAlignment(v:String):void
		{
			_vAlignment = v;
		}
		
		/**
		 * Determines the padding of the preloader in pixels.
		 */
		public function set padding(v:int):void
		{
			_padding = v;
		}
		
		/**
		 * If true sets the Preloader to test mode so the preloader is visible
		 * when run locally.
		 */
		public function set testMode(v:Boolean):void
		{
			if (v) _skipDelay = 0;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Event Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onEnterFrame(e:Event):void
		{
			// If _skipDelay is > 0 wait the amount of frames defined by it:
			if (_skipDelay > 0)
			{
				if (_preloader.framesLoaded == _preloader.totalFrames)
				{
					_preloader.finish();
				}
				_skipDelay -= 1;
			}
			// If _skipDelay is 0, draw bar and text instantly and set to -1:
			else if (_skipDelay == 0)
			{
				draw();
				_skipDelay = -1;
			}
			// If _skipDelay == -1 execute this:
			else
			{
				// If all is loaded:
				if (_preloader.framesLoaded == _preloader.totalFrames)
				{
					// If _fadeOutDelay > 0 wait the frame amount defined by it:
					if (_fadeOutDelay > 0)
					{
						_percentage = 100;
						updateDisplay();
						_fadeOutDelay--;
					}
					// If _fadeOutDelay reached 0:
					else
					{
						// If alpha > 0 fade it out:
						if (alpha > 0)
						{
							alpha -= 0.05;
						}
						// If alpha reached 0:
						else
						{
							alpha = 0.0;
							_preloader.finish();
						}
					}
				}
				// While loading:
				else
				{
					_percentage = (_preloader.loaderInfo.bytesLoaded
						/ _preloader.loaderInfo.bytesTotal * 100);
					updateDisplay();
				}
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Updates the loader bar and info text.
		 * @private
		 */
		protected function updateDisplay():void
		{
			_bar.bar.width = _percentage * _factor;
		}
		
		
		/**
		 * Draws the visual preloader assets on the stage.
		 * @private
		 */
		protected function draw():void
		{
			_bar = new LoadProgressBar();
			_factor = _bar.bar.width / 100;
			_bar.bar.width = 1;
			addChild(_bar);
			
			if (_hAlignment == Alignment.LEFT)
			{
				x = _padding;
			}
			else if (_hAlignment == Alignment.RIGHT)
			{
				x = _preloader.stage.stageWidth - width - _padding;
			}
			else
			{
				x = Math.floor((_preloader.stage.stageWidth / 2) - (width / 2));
			}
			
			if (_vAlignment == Alignment.TOP)
			{
				y = _padding;
			}
			else if (_vAlignment == Alignment.BOTTOM)
			{
				y = _preloader.stage.stageHeight - height - _padding;
			}
			else
			{
				y = Math.floor((_preloader.stage.stageHeight / 2) - (height / 2));
			}
		}
	}
}
