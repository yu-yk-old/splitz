#script ResizeWindowScript
#    
#    on resizeWindow(x1, y1, x2, y2)
#        tell application "System Events"
#            set frontmostApplication to name of the first process whose frontmost is true
#        end tell
#        
#        tell application "System Events" to tell process frontmostApplication
#            set position of the first window to {x1, y1}
#            set size of the first window to {x2, y2}
#        end tell
#        
#        tell application frontmostApplication
#            set bounds of the first window to {x1, y1, x2, y2}
#        end tell
#        
#        try
#            repeat with x from 1 to (count windows)
#                get properties of window x
#                set position of window x to {625, 21}
#                set size of window x to {1250, 2560}
#            end repeat
#        end try
#        
#    end resizeWindow
#end script
