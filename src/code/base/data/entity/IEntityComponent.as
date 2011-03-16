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
package base.data.entity
{
	/**
	 * A component in tetragon is used to define specific pieces of functionality for game
	 * entities. Several components can be added to a single entity to give the entity
	 * complex behavior while keeping the different functionalities separate from each
	 * other.
	 * 
	 * <p>A full featured implementation of this interface is included (EntityComponent).
	 * It should be adequate for almost every situation, and therefore, custom components
	 * should derive from it rather than implementing this interface directly.</p>
	 * 
	 * <p>There are several reasons why tetragon is set up this way: <bl> <li>Entities
	 * have only the data they need and nothing more.</li> <li>Components can be reused on
	 * several different types of entities.</li> <li>Programmers can focus on specific
	 * pieces of functionality when writing code.</li> </bl> </p>
	 * 
	 * @see IEntity
	 * @see EntityComponent
	 */
	public interface IEntityComponent
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Registers the component with an entity. This should only ever be called by an
		 * IEntity from the addComponent method.
		 * 
		 * @param owner The entity to register the component with.
		 * @param id The ID to assign to the component.
		 */
		function register(owner:IEntity, id:String):void;
		
		
		/**
		 * Unregisters the component from an entity. This should only ever be called by an
		 * entity class from the removeComponent method.
		 */
		function unregister():void;
		
		
		/**
		 * This is called by an entity on all of its components any time a component is
		 * added or removed. In this method, any references to properties on the owner
		 * entity should be purged and re-looked up.
		 */
		function reset():void;
		
		
		/**
		 * Returns a String Representation of the object.
		 * 
		 * @return A String Representation of the object.
		 */
		function toString():String;
		
		
		// -----------------------------------------------------------------------------------------
		// Getters & Setters
		// -----------------------------------------------------------------------------------------
		
		/**
		 * The unique ID of the entity component.
		 */
		function get id():String;
		
		
		/**
		 * A reference to the entity that this component currently belongs to. If the
		 * component has not been added to an entity, this will be null. This value should
		 * only be set by the owning IEntity
		 * 
		 * <p>This value should be equivalent to the first parameter passed to the
		 * register method.</p>
		 * 
		 * @see #register()
		 */
		function get owner():IEntity;
		function set owner(v:IEntity):void;
		
		
		/**
		 * Determines whether or not the component is currently registered with an entity.
		 */
		function get registered():Boolean;
	}
}
