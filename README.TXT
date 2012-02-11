A YouTube video downloader in Objective-c for downloading multiple YT videos on iOS. 
Currently, it supports the following features:
1.the app can instantly begin downloading the video. 
2. It can add select videos in the download queue. 
3.It can navigate bad and forth on youtube site
4. Pause or restart all the videos in the download queue
5.Pause and/or restart the download for selective videos being downloaded
6.View the status of download for videos placed in the download queue.
7.Post download, play the videos.
8.Delete the video from the download queue while it's being downloaded or placed in the download queue.
9.Delete the downloaded videos
10.Restore the last view state of the youtube page whenever you start your application.
11.View the downloaded list of videos as well as log files on http://<Device IP>:12345 on your desktop browser when your desktop and device are in the same/public network.
12.Download videos from your device on your desktop.
13.Create a downloadable zip on request from browser. 
14.Go forward for webview.

Following things remain to be done:

//TODO:  
1.	Create an adhoc network using gamekit over bluetooth -Done	
	When a user connects to you, load a navigation controller with "Movies" 	Send a list of all MP4 files.Let the user select an MP4 and play MP4 on his device.  
3.	Upload the zip file or the .attrib file to have export/import feature.  
4.	Live stream of videos.  
5.	App settings.  
6.	YouTube sections like YouTube App.    
8.	Share video download link over email.   
9.	Create WiFi hotspot, http live stream to other devices over browser.
10.	Option to user to re-download (if for some reason the last download was not done 	correctly) from the Successful/failed/paused/All states. Take user's choice what 	he/she wants to do (whether to start from the beginning or re-start download from 	last aged point).If user chooses to start from beginning, recalculate the file 		size and other headers.