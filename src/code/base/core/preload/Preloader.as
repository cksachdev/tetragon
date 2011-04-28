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
	import base.data.Params;
	import base.data.Registry;

	import mx.core.*;

	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	
	/**
	 * Preloader acts as the FactoryClass in an AS3 preloader structure. When
	 * implementing the Main class with the <code>[Frame(factoryClass="com.
	 * hexagonstar.app.preload.Preloader")]</code> tag this class becomes the
	 * actual Document class and will be located in frame 1 of the SWF movie
	 * while the Main class and all its linked assets are placed on frame 2.
	 * After the preloader is finished it jumps to frame 2 and instanciates
	 * the Main class.<p>
	 * 
	 * For optimal use this class should be extended by a custom preloader
	 * class and the application class and preloader parameters should be
	 * set by use of super().
	 * 
	 * @example
	 * <p>The following class is an example of a custom Preloader class. Note
	 * the package used as the first super argument. If the application class
	 * resides in a package, also the package name needs to be specified
	 * otherwise the Flash Player throws a Reference Error.
	 * <p><pre>
	 * // examples.preloader.CustomPreloader.as:
	 *	package examples.preloader {
	 *		import com.hexagonstar.app.preload.Preloader;
	 *		
	 *		public class CustomPreloader extends Preloader {
	 *			public function CustomPreloader() {
	 *				super("examples.preloader.PreloaderExample");
	 *				super.setFadeOutDelay(60);
	 *				super.setColor(0xEEEEEE);
	 *				super.start();
	 *			}
	 *		}
	 *	}
	 * </pre>
	 * <p>Whereas the application class could be written like this ...
	 * <p><pre>
	 * // examples.preloader.PreloaderExample.as:
	 *	package examples.preloader {
	 *		import flash.display.Sprite;
	 *		
	 *		[Frame(factoryClass="examples.preloader.CustomPreloader")]
	 *		public class PreloaderExample extends Sprite {
	 *			// Stores a reference to the Preloader which becomes
	 *			// root so that root later can still be accessed.
	 *			private var _root:CustomPreloader;
	 *			
	 *			public function PreloaderExample(root:CustomPreloader) {
	 *				_root = root;
	 *				init();
	 *			}
	 *			
	 *			public function init():void {
	 *				trace("Application starts here!");
	 *			}
	 *		}
	 *	}
	 * </pre>
	 */
	public class Preloader extends MovieClip
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		protected var _appClass:String;
		/** @private */
		protected var _wrappedPreloader:IPreloader;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Constructs a new Preloader instance.
		 * 
		 * @param appClass The application class (incl. package) that
		 *         should be started once the preloader is finished.
		 */
		public function Preloader(appClass:String = "App")
		{
			super();
			stop();
			
			_appClass = appClass;
			
			/* Fetch Flashvars */
			Registry.params = new Params();
			Registry.params.parseFlashVars(LoaderInfo(root.loaderInfo).parameters);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Starts the preloader.
		 */
		public function start():void
		{
			if (Registry.params.skipPreloader)
			{
				_wrappedPreloader = new BasicPreloader(this);
			}
			if (!_wrappedPreloader)
			{
				_wrappedPreloader = new TetragonPreloader(this);
			}
			if (_wrappedPreloader is DisplayObject)
			{
				addChild(DisplayObject(_wrappedPreloader));
			}
			
			_wrappedPreloader.start();
		}
		
		
		/**
		 * This method is called by the underlying preloader class after
		 * it finished preloading the application. You don't need to call this
		 * method manually.
		 */
		public function finish():void
		{
			if (_wrappedPreloader is DisplayObject)
			{
				removeChild(DisplayObject(_wrappedPreloader));
			}
			_wrappedPreloader.dispose();
			_wrappedPreloader = null;
			
			var link1:SpriteAsset;
			CONFIG::USE_EMBEDDED_RESOURCES
			{
				/* Forces inclusion of Flex asset classes if we use embedded resources. */
				var link2:ByteArrayAsset;
				var link3:BitmapAsset;
				var link4:MovieClipAsset;
				var link5:MovieClipLoaderAsset;
				var link6:FontAsset;
				var link7:SoundAsset;
			}
			
			gotoAndStop(2);
			
			var AppClass:Class = Class(getDefinitionByName(_appClass));
			if (AppClass)
			{
				var app:IPreloadable = new AppClass();
				app.onApplicationPreloaded(this);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The wrapped preloader object.
		 */
		public function get preloader():IPreloader
		{
			return _wrappedPreloader;
		}
		public function set preloader(v:IPreloader):void
		{
			_wrappedPreloader = v;
		}
	}
}
