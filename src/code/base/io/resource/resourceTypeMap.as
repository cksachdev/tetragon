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
package base.io.resource
{
	import base.io.resource.wrappers.*;
	
	
	/**
	 * Maps resource type identifiers to resource type classes. This is used
	 * by the resource index parser and by the embedded resource provider to
	 * determine what resource class is used for what resource.
	 */
	public var resourceTypeMap:Object =
	{
		"image":				ImageResourceWrapper,
		"image-opaque":			ImageResourceWrapper,
		"image-transparent":	Image32ResourceWrapper,
		"image-vector":			Image32ResourceWrapper,
		"swf":					SWFResourceWrapper,
		"shader":				BinaryResourceWrapper,
		"binary":				BinaryResourceWrapper,
		"audio-stream":			SoundResourceWrapper,
		"audio-module":			null,
		"data":					XMLResourceWrapper,
		"text":					XMLResourceWrapper
	};
}
