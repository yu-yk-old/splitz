script ResizeWindowScriptObj
    property parent: class "NSObject"
    property demoProp: "default property value"
    
    on demoHandler()
        tell me to log my demoProp
    end demoHandler
    
    on resizeWindow()
        tell application "Finder"
            set bounds of the first window to {0, 0, 300, 300}
        end tell
    end resizeWindow
end script

#script ResizeWindow
#    property parent: class "NSObject"
#    property demoProp: "default property value"
#
#    on resizeWindow(x1, y1, x2, y2)
#        tell application "Finder"
#            activate
#            display dialog message buttons {"OK"} default button "OK"
#        end tell
#
#        #        tell application "System Events"
#        #            set frontmostApplication to name of the first process whose frontmost is true
#        #        end tell
#        #
#        #        tell application frontmostApplication
#        #            set bounds of the first window to {x1, y1, x2, y2}
#        #        end tell
#    end resizeWindow
#
#    on demoHandler()
#        tell me to log my demoProp
#    end demoHandler
#
#    on getCurrentPlaying()
#        set currentlyPlayingTrack to getCurrentlyPlayingTrack()
#        displayTrackName(currentlyPlayingTrack)
#        return currentlyPlayingTrack
#    end getCurrentPlaying
#
#    on getCurrentlyPlayingTrack()
#        tell application "Spotify"
#            set currentArtist to artist of current track as string
#            set currentTrack to name of current track as string
#            set currentPlay to currentTrack
#            return currentArtist & " - " & currentTrack
#        end tell
#    end getCurrentlyPlayingTrack
#
#    on displayTrackName(trackName)
#        display notification "Currently playing " & trackName
#    end displayTrackName
#
#end script
