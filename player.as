// "NetStream.Play.Stop" = Playback has stopped.
// "NetStream.Play.Start" = Playback has started.
// "NetStream.Buffer.Empty" = Flash Player is not receiving data quickly enough to fill the buffer. Data flow is interrupted until the buffer refills, at which time a NetStream.Buffer.Full message is sent and the stream begins playing again."
// "NetStream.Buffer.Flush" = Data has finished streaming, and the remaining buffer is emptied. Note: Not supported in AIR 3.0 for iOS.
// "NetStream.Buffer.Full" = The buffer is full and the stream begins playing
package {
    import flash.display.Sprite;
    import flash.net.NetConnection;
    import flash.net.NetStream;  
    import flash.media.Video;
    import flash.text.*;
    import flash.events.*;
		import flash.utils.Timer;
    
    public class player extends Sprite {  
					
					private var nc:NetConnection;
					private var ns:NetStream;
					private var vid:Video;
					private var client:Object;
					
					public function player () {
						var timeMS:uint = 0;
						var rebuff_t:uint = 0;
						var rebuff_c:int = 0;
						var init_t:uint = 0;
						var state:int = 1;	// 1 = the first buffering, 2 = the second buffering, 3 = the stream is finished
						
						// Initialize net stream
						nc = new NetConnection();
						nc.connect (null);
						ns = new NetStream(nc);
			
						// Add video to stage
						vid = new Video(320,240);
						addChild (vid);
						vid.x = 0;
						vid.y = 0;  
						
						// Add Text Field
						var tf:TextField = new TextField();
						addChild(tf);
						tf.width = 320;
						tf.x = 0;
						tf.y = 240;
						
						// Add Text Field - Debug
						var debug_tf:TextField = new TextField();
						addChild(debug_tf);
						debug_tf.width = 320;
						debug_tf.height = 50;
						debug_tf.x = 0;
						debug_tf.y = 300;
						debug_tf.border = true;
						debug_tf.multiline = true;
						
						// Timer of 20/1000 second
						var t20:Timer = new Timer(20);
						t20.addEventListener(TimerEvent.TIMER, timerHandler2);
						
						// Count another 20 ms.
						function timerHandler2(event:TimerEvent):void{
							timeMS = timeMS+20;
						}

	
	          // Add callback method for listening on
	          // NetStream meta data
	          client = new Object();
	          ns.client = client;
	          
	          // Listen to event
	          ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler); 
	          
	          // Play video
	          vid.attachNetStream ( ns );
	          //ns.bufferTime = 1;
	          ns.play('http://www.mediacollege.com/video-gallery/testclips/20051210-w50s.flv');
	          //ns.play ( 'http://192.168.1.6/video.flv' );
	          
	          // Handle events
						function statusHandler(event:NetStatusEvent):void { 
							
							debug_tf.appendText(event.info.code+"\n");
							
							
							switch(state){
								case 1: 
									//The first buffering
									{
										switch( event.info.code ){ 
											case "NetStream.Play.Start": 
												//start video
												t20.reset();
												timeMS = 0;
												t20.start();
												break;
											case "NetStream.Buffer.Full": 
												//initial buffering is finished
												t20.stop();
												init_t = timeMS;
												t20.reset();
												timeMS = 0;
												state = 2;
												debug_tf.appendText("Entering state "+state+"\n");
												break;     
			                default: 
			                	debug_tf.appendText("Unknow event in state "+state+"\n"); 
										}
									}
									break; 
								case 2: 
									//The second buffering
									{
										switch( event.info.code ){ 
											case "NetStream.Buffer.Empty": 
												//buffer is under threshold
												t20.start();
												rebuff_c++;
												break;
											case "NetStream.Buffer.Full": 
												//buffer is full
												t20.stop();
												break;
											case "NetStream.Buffer.Flush": 
												//The stream is finished
												t20.stop();
												state=3;
												rebuff_t = timeMS;									
												debug_tf.appendText("Entering state "+state+"\n");
												break; 										     
			                default: 
			                	debug_tf.appendText("Unknow event in state "+state+"\n"); 
										}
									}
									break;
								default: 
									debug_tf.appendText("Unknow state: "+state+"\n");
		          } 
						}
						
						// Timer of 100ms
						var t:Timer = new Timer(100);
						t.addEventListener(TimerEvent.TIMER, timerHandler);
						t.start();
						
						// Update text field
						function timerHandler(event:TimerEvent):void{
							tf.text = "";
							tf.appendText("init. buff: " + init_t + " ms. \n");
							tf.appendText("re-buff freq: "+ rebuff_c + " times  ");
							if(state==2){
								tf.appendText("["+timeMS+" ms]\n");
							}else{
								tf.appendText("["+rebuff_t+" ms]\n");
								//tf.appendText("re-buff time: " + rebuff_t + " ms\n");
							}
							if(rebuff_c!=0){
								tf.appendText("mean re-buff time: " + (rebuff_t/rebuff_c) + " ms\n")
							}else{
								tf.appendText("mean re-buff time: " + 0 + "\n")
							}
						}
    			}
		}
}