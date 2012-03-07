A YouTube video downloader in Objective-c for downloading multiple YT videos on iOS. 
Currently, it supports the following features:
1.the app can instantly begin downloading the video. 
2. It can add selected videos in the download queue. 
3.It can navigate back and forth on youtube site
4. Pause or restart all the videos in the download queue
5.Pause and/or restart the download for selective videos being downloaded
6.View the status of download for videos placed in the download queue.
7.Post download, play the videos.
8.Delete the video from the download queue while it's being downloaded or placed in the download queue.
9.Delete the downloaded videos
10.Restore the last view state of the youtube page whenever you start your application.
11.View the downloaded list of videos as well as log files on http://<Device IP>:12345 on your desktop browser when your desktop and device are in the same/public network.
12.Download videos from your device on your desktop.
13.Create a downloadable zip on request from desktop browser. 
14.Go forward for webview.
15. Supports export/import feature. Upload mp4 videos. Upload video properties file (.attrib) for later download on iPhone
16. You can force re-download by downloading the zip file of previously downloaded video attributes and then uploading the .attrib files for videos you want to re-download.
17. Move your downloaded videos into separate categorized folders.
18. Have a voice/Video call over bluetooth/WiFi with your friends in vicinity.
19. share your iPhone screen/Camera with your friends over bluetooth/WiFi when having voice/video call. You can also annotate over your screen being shared and show them what you wanted them to focus upon.

Following things remain to be done:

//TODO:  
1.	Create an adhoc network using gamekit over bluetooth/Wifi -Done	
	When a user connects to you, load a navigation controller with "Movies".
	Send a list of all MP4 files.Let the user select an MP4 and play MP4 
	on his device.  
2.	Live stream of videos.  
3.	App settings.  
4.	YouTube sections like YouTube App.    
5.	Share video download link over email.   
6.	Create WiFi hotspot, http live stream to other devices over browser.

A sample .attrib would look like this: File name : TereBina.attrib

Title= TereBina 
URL=http://o-o.preferred.bom03s03.v13.lscache5.c.youtube.com/videoplayback?el=profile&begin=0&yms=iu2X2usx_r0&dnc=1&itag=18&ip=49.0.0.0&app=youtube_mobile&signature=34B4C3AF725A90A1515CEB528F541C6CC0865373.81D5D8A58F3862FF07C85C5A41EACB4D3367DE28&sparams=begin,cp,id,ip,ipbits,itag,len,ratebypass,source,expire&len=224000&ratebypass=yes&source=youtube&expire=1330827800&sver=3&key=yt1&ipbits=8&cp=U0hSRVhNVV9FSkNOMl9QR1lJOmVyM1cweXFhX244&id=2f36601b68633499
ExpectedBytes= 12984018
BytesReceived=0.00
