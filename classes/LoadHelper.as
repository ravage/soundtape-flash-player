﻿package {
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	
	public class LoadHelper extends Sprite {
		
		private var path:String;
		private var completeAction:Function;
		private var progressAction:Function;
		private var smooth:Boolean;
		private var loader:Loader;

		private var xml:Boolean;
		private var image:Boolean;
		private var swf:Boolean;
		private var mp3:Boolean;
		
		public function LoadHelper(_path:String, _progressAction:Function, _completeAction:Function) {
			path = _path;
			completeAction = _completeAction;
			progressAction = _progressAction;
			smooth = true;
			xml = false;
			image = false;
			swf = false;
			mp3 = false;
		}
		
		public function LoadXML():void {
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, CompleteHandle);
			xmlLoader.addEventListener(ProgressEvent.PROGRESS, ProgressHandle);
			smooth= false;
			xml = true;
			xmlLoader.load(new URLRequest(path));
		}
		
		public function LoadSWF():void {
			swf = true;
			LoadGraphics();
		}
		
		function LoadImage() {
			image = true;
			LoadGraphics();
		}
		
		function LoadMP3() {
			mp3 = true;
			LoadXML();
		}
		
		private function LoadGraphics() {
			var req:URLRequest = new URLRequest(path);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, CompleteHandle);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, ProgressHandle);
			loader.load(req);
		}
		
		private function CompleteHandle(e:Event):void {
			if(image) {
				var image:Bitmap = e.currentTarget.content;
				
				if(smooth) {
					image.smoothing = true;
				}
				completeAction.call(this, image);
			}
			else if(xml) {
				completeAction.call(this, e.currentTarget.data);
			}
			else if(mp3) {
				completeAction.call(this, e);
			}
			else if(swf) {
				completeAction.call(this, loader);
			}
		}
		
		private function ProgressHandle(e:ProgressEvent) {
			progressAction.call(this, Math.round(e.bytesLoaded * 100 / e.bytesTotal));
		}
		
		public function SetPath(value:String) {
			path = value;
		}
		
	}	
}