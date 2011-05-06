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
package base.view.display
{
	import base.Main;
	import base.io.resource.ResourceManager;
	import base.view.screen.BaseScreen;

	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	
	/**
	 * The abstract base class for all display classes, inclusive screens.
	 * 
	 * A Display is a container that can contain any kind and number of other display
	 * objects (Sprites, MovieClips, Shapes, Bitmaps etc.) and which is placed for
	 * display in a screen.
	 */
	public class Display extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _main:Main;
		/** @private */
		private var _screen:BaseScreen;
		/** @private */
		private var _resourceManager:ResourceManager;
		
		/** @private */
		private var _enabled:Boolean = true;
		/** @private */
		private var _started:Boolean = false;
		/** @private */
		private var _paused:Boolean = false;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new Display instance.
		 */
		public function Display()
		{
			_main = Main.instance;
			_resourceManager = _main.resourceManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Can be called to start the display in case the display has any child objects that
		 * need to be started. For example a display might contain animated display children
		 * that should not start playing right after the display has been opened but only
		 * after this method has been called.<br><br>
		 * 
		 * <p>For displays that are children of a Screen <code>start</code> gets called
		 * automatically by the screen if the start method of the screen has been called by
		 * the ScreenManager.</p>
		 * 
		 * <p>When overriding this method make sure to call super.start() at the beginning of
		 * your start method!</p>
		 */
		public function start():void
		{
			if (_started) return;
			_started = true;
		}
		
		
		/**
		 * Can be called to stop the display and it's child objects after it has been started
		 * by calling the start method.
		 * 
		 * <p>When overriding this method make sure to call super.stop() at the beginning of
		 * your stop method!</p>
		 */
		public function stop():void
		{
			if (!_started) return;
			_started = false;
		}
		
		
		/**
		 * Used to put the display into it's initial state as it was right after the display
		 * has been instantiated for the first time. This method can be called to reset
		 * properties and child objects in case the display should be re-used without the need
		 * to re-instantiate it.
		 */
		public function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Updates the display. This method can be called if child objects of the display
		 * need to be updated, e.g. after localization has been changed or if the display
		 * children need to be re-layouted.
		 * 
		 * <p>For displays that are children of a Screen <code>update</code> gets called
		 * automatically by the screen if the update method of the screen has been called by
		 * the ScreenManager.</p>
		 * 
		 * <p>When overriding this method make sure to call super.update() at the end of
		 * your update method!</p>
		 */
		public function update():void
		{
			updateDisplayText();
			layoutChildren();
		}
		
		
		/**
		 * Disposes the display to clean up resources that are no longer needed. A call to
		 * this method stops the display, removes it's listeners and then unloads it.
		 * 
		 * <p>When overriding this method make sure to call super.dispose() at the start of
		 * your dispose method!</p>
		 */
		public function dispose():void
		{
			stop();
			removeListeners();
		}
		
		
		/**
		 * Used to initialize the display. Called by it's parent screen after the screen
		 * is ready. Don't call manually!
		 * 
		 * @private
		 */
		public function init():void
		{
			createChildren();
			addChildren();
			addListeners();
		}
		
		
		/**
		 * Returns a String representation of the object.
		 * 
		 * @return A String representation of the object.
		 */
		override public function toString():String
		{
			return "[" + getQualifiedClassName(this).match("[^:]*$")[0] + "]";
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the display is enabled or disabled. On a disabled display any
		 * display children are disabled so that no user interaction may occur until the
		 * display is enabled again. Set this property to either <code>true</code> (enabled)
		 * or <code>false</code> (disabled).
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			if (v == _enabled) return;
			_enabled = v;
			if (_enabled) enableChildren();
			else disableChildren();
		}
		
		
		/**
		 * Determines if the display has been started, i.e. if it's start method has been
		 * called. Returns <code>true<code> if the display has been started or
		 * <code>false<code> if the display has either been stopped by calling
		 * <code>stop()</code> or has not yet been started.
		 */
		public function get started():Boolean
		{
			return _started;
		}
		
		
		/**
		 * Determines whether the display is in paused state or not. If paused any child
		 * objects are being paused too, if possible. This property should be used if the
		 * display needs to be pausable, for example if it contains any animation that should
		 * not play while the application is in a paused state.
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		public function set paused(v:Boolean):void
		{
			if (v == _paused) return;
			_paused = v;
			if (_paused) pauseChildren();
			else unpauseChildren();
		}
		
		
		/**
		 * A reference to the display's parent screen, for use in sub-classes.
		 * This property is set automatically by the display's parent screen when the
		 * display is registered with the screen by using registerDisplay().
		 */
		public function get screen():BaseScreen
		{
			return _screen;
		}
		public function set screen(v:BaseScreen):void
		{
			_screen = v;
		}
		
		
		/**
		 * A reference to Main for use in sub-classes.
		 */
		protected function get main():Main
		{
			return _main;
		}
		
		
		/**
		 * A reference to the resource manager for use in sub-classes.
		 */
		protected function get resourceManager():ResourceManager
		{
			return _resourceManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to create any display children (and other objects) that the display
		 * might need. Note that child display objects should not be added to the display
		 * list here. Instead they are added in the <code>addChildren()</code> method.
		 * 
		 * @private
		 */
		protected function createChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add display objects to the display list that were created in the
		 * <code>createChildren()</code> method.
		 * 
		 * @private
		 */
		protected function addChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add any required event/signal listeners to the display and/or it's children.
		 * @private
		 */
		protected function addListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to remove any event/signal listeners that have been added with
		 * <code>addListeners()</code>. This method is automatically called by the
		 * <code>dispose()</code> method.
		 * 
		 * @private
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to enable all child objects.
		 * @private
		 */
		protected function enableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to disable all child objects.
		 * @private
		 */
		protected function disableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to pause all child objects.
		 * @private
		 */
		protected function pauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to unpause all child objects.
		 * @private
		 */
		protected function unpauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to update any display text of the display if it contains any children that
		 * are used to display text. Typically any textfield text should be set here with
		 * strings from the application's currently used text resources.
		 * 
		 * @private
		 */
		protected function updateDisplayText():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to layout the display children of the display. This method is called
		 * initially to set the position and size of any child objects and is called
		 * whenever the children need to update their position or size because the layout
		 * has changed, for example after the application window has been resized.
		 * 
		 * @private
		 */
		protected function layoutChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Helper method to get a resource's content from the resource index. The type
		 * depends on the content type of the resource.
		 * 
		 * @private
		 */
		protected function getResource(id:String):*
		{
			return resourceManager.resourceIndex.getResourceContent(id);
		}
		
		
		/**
		 * Helper method to get a string from the string index.
		 * @private
		 */
		protected function getString(id:String):String
		{
			return resourceManager.stringIndex.get(id);
		}
	}
}
