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
package base.core.update
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	
	/**
	 * UpdateDialog class
	 */
	public class UpdateDialog extends NativeWindow
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------		
		
		public static var EVENT_CHECK_UPDATE:String = "checkUpdate";
		public static var EVENT_INSTALL_UPDATE:String = "installUpdate";
		public static var EVENT_DOWNLOAD_UPDATE:String = "downloadUpdate";
		public static var EVENT_CANCEL_UPDATE:String = "cancelUpdate";
		public static var EVENT_INSTALL_LATER:String = "installLater";
		
		public static var UPDATE_DOWNLOADING:String = "updateDownloading";
		public static var INSTALL_UPDATE:String = "installUpdate";
		public static var UPDATE_AVAILABLE:String = "updateAvailable";
		public static var NO_UPDATE:String = "noUpdate";
		public static var CHECK_UPDATE:String = "checkUpdate";
		public static var UPDATE_ERROR:String = "updateError";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _isFirstRun:Boolean;
		private var _installedVersion:String;
		private var _updateVersion:String;
		private var _updateDescription:String;
		private var _applicationName:String;
		private var _updateState:String;
		private var _errorText:String = "There was an error checking for updates.";
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function UpdateDialog()
		{
			var wo:NativeWindowInitOptions = new NativeWindowInitOptions();
			wo.systemChrome = NativeWindowSystemChrome.STANDARD;
			wo.type = NativeWindowType.NORMAL;
			
			super(wo);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			bounds = new Rectangle(100, 100, 800, 800);
			activate();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function open():void
		{
		}
		
		
		public function updateDownloadProgress(percent:Number):void
		{
		}
		
		
		public function dispose():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set isFirstRun(v:Boolean):void
		{
			_isFirstRun = v;
		}
		public function set installedVersion(v:String):void
		{
			_installedVersion = v;
		}
		public function set upateVersion(v:String):void
		{
			_updateVersion = v;
		}
		public function set updateState(v:String):void
		{
			_updateState = v;
		}
		public function set applicationName(v:String):void
		{
			_applicationName = v;
		}
		public function set description(v:String):void
		{
			_updateDescription = v;
		}
		public function set errorText(v:String):void
		{
			_errorText = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
	}
}
