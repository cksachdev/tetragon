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
	import base.data.IDataObject;
	
	
	/**
	 * Game objects in tetragon are referred to as entities. This interface defines the
	 * behavior for an entity. A full featured implementation of this interface is
	 * included, but is hidden so as to force using IEntity when storing references to
	 * entities. To create a new entity, use allocateEntity.
	 * 
	 * <p>An entity by itself is a very light weight object. All it needs to store is its
	 * ID and a list of components. Custom functionality is added by creating components
	 * and attaching them to entities.</p>
	 * 
	 * <p>An event with type "entityDisposed" will be fired when the entity is destroyed
	 * via the dispose() method. This event is fired before any cleanup is done.</p>
	 * 
	 * @see IEntityComponent
	 * @see base.data.entity.allocateEntity()
	 */
	public interface IEntity extends IDataObject
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Adds a component to the entity.
		 * 
		 * <p>When a component is added, it will have its register() method called (or
		 * onAdd if it is derived from EntityComponent). Also, reset() will be called on
		 * all components currently attached to the entity (or onReset if it is derived
		 * from EntityComponent).</p>
		 * 
		 * @param component The component to add.
		 * @param componentID The ID to set for the component. This is the value to use in
		 *            lookupComponentByName to get a reference to the component. The ID
		 *            must be unique across all components on this entity.
		 * @return true if the component was added successfully to the entity, false if
		 *         not.
		 */
		function addComponent(component:IEntityComponent, componentID:String):Boolean;
		
		
		/**
		 * Removes a component from the entity.
		 * 
		 * <p>When a component is removed, it will have its unregister method called (or
		 * onRemove if it is derived from EntityComponent). Also, reset will be called on
		 * all components currently attached to the entity (or onReset if it is derived
		 * from EntityComponent).</p>
		 * 
		 * @param component The component to remove.
		 */
		function removeComponent(component:IEntityComponent):void;
	}
}
