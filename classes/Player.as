﻿package {	import flash.events.*;	import flash.display.*;	import flash.net.*;	import flash.display.Sprite;	import flash.media.*;	import flash.utils.*;	import flash.text.TextField;	public class Player extends Sprite {		private var params:Object;		private var path:String;		private var xml:XML;		private static var instance:Player;		private var track:Sound;		private var trackLength:uint;		private var channel:SoundChannel;		public function Player() {			if(instance) throw new Error("...");			instance = this;						var flashVars:Object = LoaderInfo(this.root.loaderInfo).parameters;			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.addEventListener(Event.RESIZE, OnResize);			stage.dispatchEvent(new Event(Event.RESIZE));			mcScrollbar.BindTo(mcPlaylist.mcTracks, mcPlaylist.mcMask);			mcControls.btnPause.visible = false;			mcControls.mcVolume.VolumeControl = 10;			var peakTimer:Timer = new Timer(50);			peakTimer.addEventListener(TimerEvent.TIMER, OnTimerEvent);			peakTimer.start();			//mcPlaylist.LoadXSPF(flashVars.uri);			mcPlaylist.LoadXSPF('http://www.soundtape.net/api/get_tracks/random.xspf');					}				public function Volume(value:Number) {			if(channel != null) {				var volume:SoundTransform = new SoundTransform();				volume.volume = value;   				channel.soundTransform = volume;			}		}				private function OnTimerEvent(e:Event) {			/*if(channel != null) {				leftPeak.height = channel.leftPeak * 50;				rightPeak.height = channel.rightPeak * 50;			}*/						if(mcPlaylist.Playing != null && (track.bytesLoaded == track.bytesTotal)) {				mcPlaying.mcTrackProgressBar.width = Math.round(channel.position * (mcPlaying.mcBackground.width - 2) / track.length);			}		}				public static function GetInstance():Player {			if(!instance) {				return new Player();			}			return instance;		}				public static function GetPlaylist():Playlist {			return Player.GetInstance().mcPlaylist;		}				function OnResize(e:Event):void		{			mcPlaylist.mcBackground.width = stage.stageWidth - (mcPlaylist.x + 19);			mcPlaylist.mcBackground.height = stage.stageHeight - (mcPlaylist.y + 4);			mcPlaylist.mcMask.width = stage.stageWidth - (mcPlaylist.x + 23);			mcPlaylist.mcMask.height = stage.stageHeight - (mcPlaylist.y + 8);			mcPlaylist.mcTracks.mcBackground.width = stage.stageWidth - (mcPlaylist.x + 29);			mcPlaylist.mcTracks.mcBackground.height = stage.stageHeight - (mcPlaylist.y + 8);						mcControls.mcVolume.x = stage.stageWidth - (mcControls.mcVolume.width + 5);			mcPlaying.mcBackground.width = stage.stageWidth - (mcPlaying.x + 35);			mcPlaying.mcInside.width = stage.stageWidth - (mcPlaying.x + 37);			mcPlaying.mcMask.width = mcPlaying.mcBackground.width			mcPlaying.txtPlaying.autoSize = 'left';			mcControls.mcBackground.width = stage.stageWidth - mcControls.x;						mcScrollbar.mcBackground.height = stage.stageHeight - (mcScrollbar.y + 3);			mcScrollbar.x = stage.stageWidth - (mcScrollbar.width + 3);						mcBackground.width = stage.stageWidth;			mcBackground.height = stage.stageHeight;						if(mcPlaying.mcBufferProgressBar.width > 1 && (track.bytesLoaded == track.bytesTotal)) {				mcPlaying.mcBufferProgressBar.width = stage.stageWidth - (mcPlaying.x + 32);			}						if(mcPlaying.txtPlaying.width > mcPlaying.mcMask.width) {				mcPlaying.txtPlaying.addEventListener(Event.ENTER_FRAME, scrollText);			} else {				mcPlaying.txtPlaying.removeEventListener(Event.ENTER_FRAME, scrollText);				mcPlaying.txtPlaying.x = 0;			}		}				public function Play() {			mcPlaying.mcTrackProgressBar.width = 0;			if(mcPlaylist.Playing == null) {				mcPlaylist.PlayFirst();			}			else if(mcPlaylist.Playing != null && mcPlaylist.Playing.Paused) {				channel = track.play(channel.position);				mcPlaylist.Playing.Paused = false;			}			else {				if(channel != null && (track.bytesLoaded < track.bytesTotal)) {					channel.stop();					try {						track.removeEventListener(ProgressEvent.PROGRESS, BufferProgress);						track.removeEventListener(Event.COMPLETE, BufferComplete);						track.close();					} catch (error:Error) {						track = null;					}				}								mcCover.LoadCover(mcPlaylist.Playing);				track = new Sound(new URLRequest(mcPlaylist.Playing.TrackInfo.Location));				track.addEventListener(ProgressEvent.PROGRESS, BufferProgress);				track.addEventListener(Event.COMPLETE, BufferComplete);								channel = track.play();				channel.addEventListener(Event.SOUND_COMPLETE, TrackComplete);							mcControls.btnPlay.visible = false;				mcControls.btnPause.x = mcControls.btnPlay.x;				mcControls.btnPause.y = mcControls.btnPlay.y;				mcControls.btnPause.visible = true;			}			Volume(mcControls.mcVolume.VolumeControl);		}				public function Stop() {			if(channel != null) {				channel.stop();				if(track.bytesLoaded != track.bytesTotal) {					track.close();				}				mcControls.btnPlay.visible = true;				mcControls.btnPause.visible = false;			}		}				public function Next() {			var index:int = mcPlaylist.Tracks.indexOf(mcPlaylist.Playing);			mcPlaylist.Tracks[++index % mcPlaylist.Tracks.length].dispatchEvent(new Event(MouseEvent.CLICK));		}				public function Previous() {			var index:int = mcPlaylist.Tracks.indexOf(mcPlaylist.Playing);			if(index > 0) {				mcPlaylist.Tracks[--index].dispatchEvent(new Event(MouseEvent.CLICK));			}			else {				mcPlaylist.Tracks[mcPlaylist.Tracks.length - 1].dispatchEvent(new Event(MouseEvent.CLICK));			}		}				public function Pause() {			mcPlaylist.Playing.Paused = true;			channel.stop();		}				private function BufferProgress(e:ProgressEvent) {			trackLength = e.bytesTotal;			var total = Math.round(e.bytesLoaded * 100 / e.bytesTotal);			mcPlaying.txtPlaying.text = 'Buffering: ' + total +'%';			mcPlaying.mcBufferProgressBar.width = Math.round(e.bytesLoaded * (mcPlaying.mcBackground.width - 2) / e.bytesTotal);		}				function BufferComplete(e:Event) {			var trackInfo = mcPlaylist.Playing.TrackInfo;			mcPlaying.txtPlaying.text = trackInfo.TrackNum + '. ' + trackInfo.Album + ' - ' + trackInfo.Title;			mcPlaylist.Playing.IsLoaded = true;		}				function TrackComplete(e:Event) {			Next();		}				function scrollText(event:Event):void {			event.target.x -= 6;			if (event.target.x + event.target.width < 0){				event.target.x = mcPlaying.mcMask.width;			}		}	}}