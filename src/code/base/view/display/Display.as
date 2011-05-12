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

	import com.hexagonstar.util.reflection.getClassName;

	import flash.display.Sprite;
	
	
	/**
	 * The abstract base class for all display classes, inclusive screens.
	 * 
	 * A Display is a container that can contain any kind and number of other display
	 * objects (Sprites, MovieClips, Shapes, Bitmaps etc.) and which is added for
	 * display on a screen.
	 */
	public class Display extends Sprite
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _main:Main;
		private var _screen:BaseScreen;
		private var _enabled:Boolean = true;
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
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to initialize the display.
		 * 
		 * <p>You normally don't call this method manually. Instead the parent screen
		 * calls it automatically when the screen is being opened.</p>
		 */
		public function init():void
		{
			createChildren();
			addChildren();
			addListeners();
		}
		
		
		/**
		 * Starts the display after it has been initialized. You normally don't call this
		 * method manually. Instead the parent screen calls it automatically when the
		 * screen is being started.
		 * 
		 * <p>This is an abstract method. Override this method in your state sub-class and
		 * place any instructions into it that need to be done when the state is being
		 * started, for example a display might contain animated display children that
		 * should start playing after this method has been called.</p>
		 */
		public function start():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Updates the display. This method is called automatically by the parent screen
		 * before it is being started. It updates any display text that the display might
		 * contain and lays out it's display children.
		 * 
		 * <p>This method can be called if child objects of the display need to be
		 * updated, e.g. after localization has been changed or if the display children
		 * need to be re-layouted.</p>
		 */
		public function update():void
		{
			updateDisplayText();
			layoutChildren();
		}
		
		
		/**
		 * Used to put the display into it's initial state as it was right after the
		 * display has been instantiated for the first time. This method can be called to
		 * reset properties and child objects in case the display should be re-used
		 * without the need to re-instantiate it.
		 * 
		 * <p>This is an abstract method. You can override this method in your display
		 * sub-class and place any instructions into it that need to be done to reset the
		 * display.</p>
		 */
		public function reset():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Stops the display if it has been started. You normally don't call this method
		 * manually. Instead the parent screen calls it automatically when the screen is
		 * being stopped.
		 * 
		 * <p>This is an abstract method. You can override this method in your display
		 * sub-class and place any instructions into it that need to be done to stop the
		 * display, for example stopping an animation.</p>
		 */
		public function stop():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Disposes the display to clean up resources that are no longer needed. A call to
		 * this method stops the display and removes any event/signal listeners. You
		 * normally don't call this method manually. Instead the parent screen calls it
		 * automatically when the screen is being disposed.
		 * 
		 * <p>If you want to override this method make sure to call super.dispose() at the
		 * start of your overriden dispose method.</p>
		 */
		public function dispose():void
		{
			stop();
			removeListeners();
		}
		
		
		/**
		 * Returns a String representation of the display.
		 * 
		 * @return A String representation of the display.
		 */
		override public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Getters & Setters
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Determines if the display is enabled or disabled. On a disabled display any
		 * display children are disabled so that no user interaction may occur until the
		 * display is enabled again. Set this property to either <code>true</code>
		 * (enabled) or <code>false</code> (disabled).
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
		 * Determines whether the display is in paused state or not. If paused, any child
		 * objects of the display are being paused too, if possible. This property should
		 * be used if the display needs to be pausable, for example if it contains any
		 * animation that should not play while the application is in a paused state.
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
		 * A reference to the display's parent screen, for use in sub-classes. This
		 * property is set automatically by the display's parent screen when the display
		 * is registered with the screen by using <code>registerDisplay()</code>.
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
			return _main.resourceManager;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Used to create any display children (and other objects) that the display might
		 * contain. Note that child display objects should not be added to the display
		 * list here. Instead they are added in the <code>addChildren()</code> method.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and create
		 * any display child objects here that are part of the display.</p>
		 */
		protected function createChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add child display objects to the display list that were created in the
		 * <code>createChildren()</code> method.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and add
		 * any display children to the display list here that are part of the display.</p>
		 */
		protected function addChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to add any event or signal listeners to child objects of the display.
		 * 
		 * <p>This is an abstract method. Override this method and add any listeners to
		 * objects that require event/signal listening.</p>
		 * 
		 * @see removeListeners
		 */
		protected function addListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to remove any event or signal listeners from child objects that were added
		 * inside the <code>addListeners()</code> method. Called automatically when the
		 * display is being disposed.
		 * 
		 * <p>This is an abstract method. Override this method and remove any event/signal
		 * listeners here that were added in <code>addListeners()</code>.</p>
		 * 
		 * @see addListeners
		 */
		protected function removeListeners():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to update any display text that the display might contain. Typically any
		 * textfield text should be set here with strings from the application's currently
		 * used text resources. Called whenever the display's <code>update()</code> method
		 * is called.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and set
		 * strings from text resources to any text displays if they require it.</p>
		 */
		protected function updateDisplayText():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to layout the display children of the display. This method is called
		 * initially to set the position and size of any child objects and should be
		 * called whenever the children need to update their position or size because the
		 * layout has changed, for example after the application window has been resized.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and set
		 * the position and size of all child display objects here.</p>
		 */
		protected function layoutChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to enable any child display objects. Called whenever the
		 * <code>enabled</code> property of the display is set to <code>true</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and enable
		 * any child display objects here that should be enabled when the display is being
		 * enabled.</p>
		 * 
		 * @see enabled
		 * @see disableChildren
		 */
		protected function enableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to disable any child display objects. Called whenever the
		 * <code>enabled</code> property of the display is set to <code>false</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and disable
		 * any child display objects here that should be disabled when the display is being
		 * disabled.</p>
		 * 
		 * @see enabled
		 * @see enableChildren
		 */
		protected function disableChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to pause any child display objects. Called whenever the
		 * <code>paused</code> property of the display is set to <code>true</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and pause
		 * any child display objects here that should be paused when the display is being
		 * put into paused mode.</p>
		 * 
		 * @see paused
		 * @see unpauseChildren
		 */
		protected function pauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		/**
		 * Used to unpause any child display objects that were paused. Called whenever the
		 * <code>paused</code> property of the display is set to <code>false</code>.
		 * 
		 * <p>This is an abstract method. Override it in your sub-display class and unpause
		 * any child display objects here that should be unpaused when the display is being
		 * put into unpaused mode.</p>
		 * 
		 * @see paused
		 * @see pauseChildren
		 */
		protected function unpauseChildren():void
		{
			/* Abstract method! */
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Helper Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Helper method to get a resource's content from the resource index. The type
		 * depends on the content type of the resource.
		 * 
		 * @param resourceID The ID of the resource.
		 * @return The resource content or <code>null</code>.
		 */
		protected static function getResource(resourceID:String):*
		{
			return Main.instance.resourceManager.resourceIndex.getResourceContent(resourceID);
		}
		
		
		/**
		 * Helper method to get a string from the string index.
		 * 
		 * @param stringID The ID of the string.
		 * @return The requested string.
		 */
		protected static function getString(stringID:String):String
		{
			return Main.instance.resourceManager.stringIndex.get(stringID);
		}
	}
}
