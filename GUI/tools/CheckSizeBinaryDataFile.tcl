#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join . GUI Images smiley_transparent.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top438
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd78 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd75 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {-borderwidth 1}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra57 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra57
    namespace eval ::widgets::$site_3_0.tit90 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit90 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-image 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top438
            CheckBin1OFF
            CheckBin2OFF
            CheckBin3OFF
            CheckBin4OFF
            CheckBin1ON
            CheckBin2ON
            CheckBin3ON
            CheckBin4ON
            CheckBinRAZ
            CheckTerrasarDualSSC
            CheckTerrasarDualnoSSC
            CheckTerrasarQuadSSC
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
## This will clean up and call exit properly on Windows.
#vTcl:WindowsCleanup
}
#############################################################################
## Procedure:  CheckBin1OFF

proc ::CheckBin1OFF {} {
global PSPBackgroundColor
global CheckSize1 CheckHeader1 CheckRow1 CheckCol1

set CheckSize1 ""; set CheckHeader1 ""; set CheckRow1 ""; set CheckCol1 ""

.top438.cpd78 configure -state disable
.top438.cpd78.f.cpd69.lab83 configure -state disable
.top438.cpd78.f.cpd69.ent84 configure -state disable
.top438.cpd78.f.cpd69.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd78.f.cpd70.lab83 configure -state disable
.top438.cpd78.f.cpd70.ent84 configure -state disable
.top438.cpd78.f.cpd70.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd78.f.cpd71.lab83 configure -state disable
.top438.cpd78.f.cpd71.ent84 configure -state disable
.top438.cpd78.f.cpd71.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd78.f.cpd72.lab83 configure -state disable
.top438.cpd78.f.cpd72.ent84 configure -state disable
.top438.cpd78.f.cpd72.ent84 configure -disabledbackground $PSPBackgroundColor
}
#############################################################################
## Procedure:  CheckBin2OFF

proc ::CheckBin2OFF {} {
global PSPBackgroundColor
global CheckSize2 CheckHeader2 CheckRow2 CheckCol2

set CheckSize2 ""; set CheckHeader2 ""; set CheckRow2 ""; set CheckCol2 ""

.top438.cpd73 configure -state disable
.top438.cpd73.f.cpd69.lab83 configure -state disable
.top438.cpd73.f.cpd69.ent84 configure -state disable
.top438.cpd73.f.cpd69.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd73.f.cpd70.lab83 configure -state disable
.top438.cpd73.f.cpd70.ent84 configure -state disable
.top438.cpd73.f.cpd70.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd73.f.cpd71.lab83 configure -state disable
.top438.cpd73.f.cpd71.ent84 configure -state disable
.top438.cpd73.f.cpd71.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd73.f.cpd72.lab83 configure -state disable
.top438.cpd73.f.cpd72.ent84 configure -state disable
.top438.cpd73.f.cpd72.ent84 configure -disabledbackground $PSPBackgroundColor
}
#############################################################################
## Procedure:  CheckBin3OFF

proc ::CheckBin3OFF {} {
global PSPBackgroundColor
global CheckSize3 CheckHeader3 CheckRow3 CheckCol3

set CheckSize3 ""; set CheckHeader3 ""; set CheckRow3 ""; set CheckCol3 ""

.top438.cpd74 configure -state disable
.top438.cpd74.f.cpd69.lab83 configure -state disable
.top438.cpd74.f.cpd69.ent84 configure -state disable
.top438.cpd74.f.cpd69.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd74.f.cpd70.lab83 configure -state disable
.top438.cpd74.f.cpd70.ent84 configure -state disable
.top438.cpd74.f.cpd70.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd74.f.cpd71.lab83 configure -state disable
.top438.cpd74.f.cpd71.ent84 configure -state disable
.top438.cpd74.f.cpd71.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd74.f.cpd72.lab83 configure -state disable
.top438.cpd74.f.cpd72.ent84 configure -state disable
.top438.cpd74.f.cpd72.ent84 configure -disabledbackground $PSPBackgroundColor
}
#############################################################################
## Procedure:  CheckBin4OFF

proc ::CheckBin4OFF {} {
global PSPBackgroundColor
global CheckSize4 CheckHeader4 CheckRow4 CheckCol4

set CheckSize4 ""; set CheckHeader4 ""; set CheckRow4 ""; set CheckCol4 ""

.top438.cpd75 configure -state disable
.top438.cpd75.f.cpd69.lab83 configure -state disable
.top438.cpd75.f.cpd69.ent84 configure -state disable
.top438.cpd75.f.cpd69.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd75.f.cpd70.lab83 configure -state disable
.top438.cpd75.f.cpd70.ent84 configure -state disable
.top438.cpd75.f.cpd70.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd75.f.cpd71.lab83 configure -state disable
.top438.cpd75.f.cpd71.ent84 configure -state disable
.top438.cpd75.f.cpd71.ent84 configure -disabledbackground $PSPBackgroundColor
.top438.cpd75.f.cpd72.lab83 configure -state disable
.top438.cpd75.f.cpd72.ent84 configure -state disable
.top438.cpd75.f.cpd72.ent84 configure -disabledbackground $PSPBackgroundColor
}
#############################################################################
## Procedure:  CheckBin1ON

proc ::CheckBin1ON {} {
global CheckSize1 CheckHeader1 CheckRow1 CheckCol1

set CheckSize1 ""; set CheckHeader1 ""; set CheckRow1 ""; set CheckCol1 ""

.top438.cpd78 configure -state normal
.top438.cpd78.f.cpd69.lab83 configure -state normal
.top438.cpd78.f.cpd69.ent84 configure -state normal
.top438.cpd78.f.cpd69.ent84 configure -disabledbackground #FFFFFF
.top438.cpd78.f.cpd70.lab83 configure -state normal
.top438.cpd78.f.cpd70.ent84 configure -state normal
.top438.cpd78.f.cpd70.ent84 configure -disabledbackground #FFFFFF
.top438.cpd78.f.cpd71.lab83 configure -state normal
.top438.cpd78.f.cpd71.ent84 configure -state normal
.top438.cpd78.f.cpd71.ent84 configure -disabledbackground #FFFFFF
.top438.cpd78.f.cpd72.lab83 configure -state normal
.top438.cpd78.f.cpd72.ent84 configure -state normal
.top438.cpd78.f.cpd72.ent84 configure -disabledbackground #FFFFFF
}
#############################################################################
## Procedure:  CheckBin2ON

proc ::CheckBin2ON {} {
global CheckSize2 CheckHeader2 CheckRow2 CheckCol2

set CheckSize2 ""; set CheckHeader2 ""; set CheckRow2 ""; set CheckCol2 ""

.top438.cpd73 configure -state normal
.top438.cpd73.f.cpd69.lab83 configure -state normal
.top438.cpd73.f.cpd69.ent84 configure -state normal
.top438.cpd73.f.cpd69.ent84 configure -disabledbackground #FFFFFF
.top438.cpd73.f.cpd70.lab83 configure -state normal
.top438.cpd73.f.cpd70.ent84 configure -state normal
.top438.cpd73.f.cpd70.ent84 configure -disabledbackground #FFFFFF
.top438.cpd73.f.cpd71.lab83 configure -state normal
.top438.cpd73.f.cpd71.ent84 configure -state normal
.top438.cpd73.f.cpd71.ent84 configure -disabledbackground #FFFFFF
.top438.cpd73.f.cpd72.lab83 configure -state normal
.top438.cpd73.f.cpd72.ent84 configure -state normal
.top438.cpd73.f.cpd72.ent84 configure -disabledbackground #FFFFFF
}
#############################################################################
## Procedure:  CheckBin3ON

proc ::CheckBin3ON {} {
global CheckSize3 CheckHeader3 CheckRow3 CheckCol3

set CheckSize3 ""; set CheckHeader3 ""; set CheckRow3 ""; set CheckCol3 ""

.top438.cpd74 configure -state normal
.top438.cpd74.f.cpd69.lab83 configure -state normal
.top438.cpd74.f.cpd69.ent84 configure -state normal
.top438.cpd74.f.cpd69.ent84 configure -disabledbackground #FFFFFF
.top438.cpd74.f.cpd70.lab83 configure -state normal
.top438.cpd74.f.cpd70.ent84 configure -state normal
.top438.cpd74.f.cpd70.ent84 configure -disabledbackground #FFFFFF
.top438.cpd74.f.cpd71.lab83 configure -state normal
.top438.cpd74.f.cpd71.ent84 configure -state normal
.top438.cpd74.f.cpd71.ent84 configure -disabledbackground #FFFFFF
.top438.cpd74.f.cpd72.lab83 configure -state normal
.top438.cpd74.f.cpd72.ent84 configure -state normal
.top438.cpd74.f.cpd72.ent84 configure -disabledbackground #FFFFFF
}
#############################################################################
## Procedure:  CheckBin4ON

proc ::CheckBin4ON {} {
global CheckSize4 CheckHeader4 CheckRow4 CheckCol4

set CheckSize4 ""; set CheckHeader4 ""; set CheckRow4 ""; set CheckCol4 ""

.top438.cpd75 configure -state normal
.top438.cpd75.f.cpd69.lab83 configure -state normal
.top438.cpd75.f.cpd69.ent84 configure -state normal
.top438.cpd75.f.cpd69.ent84 configure -disabledbackground #FFFFFF
.top438.cpd75.f.cpd70.lab83 configure -state normal
.top438.cpd75.f.cpd70.ent84 configure -state normal
.top438.cpd75.f.cpd70.ent84 configure -disabledbackground #FFFFFF
.top438.cpd75.f.cpd71.lab83 configure -state normal
.top438.cpd75.f.cpd71.ent84 configure -state normal
.top438.cpd75.f.cpd71.ent84 configure -disabledbackground #FFFFFF
.top438.cpd75.f.cpd72.lab83 configure -state normal
.top438.cpd75.f.cpd72.ent84 configure -state normal
.top438.cpd75.f.cpd72.ent84 configure -disabledbackground #FFFFFF
}
#############################################################################
## Procedure:  CheckBinRAZ

proc ::CheckBinRAZ {} {
global OpenDirFile
global TMPCompareBinaryData

if {$OpenDirFile == 0} {

DeleteFile "$TMPCompareBinaryData.txt"

CheckBin1OFF
CheckBin2OFF
CheckBin3OFF
CheckBin4OFF

catch {package require Img}
image create photo ImageConfig
ImageConfig blank
.top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
image delete ImageConfig
image create photo ImageConfig -file "GUI/Images/smiley_transparent.gif"
.top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig

}
}
#############################################################################
## Procedure:  CheckTerrasarDualSSC

proc ::CheckTerrasarDualSSC {} {
global OpenDirFile TMPCompareBinaryData NcolFullSize
global FileInput1 FileInput2
global CheckSize1 CheckHeader1 CheckRow1 CheckCol1
global CheckSize2 CheckHeader2 CheckRow2 CheckCol2

if {$OpenDirFile == 0} {

DeleteFile "$TMPCompareBinaryData.txt"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/bin/tools/check_binary_data_file.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$FileInput1\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" "k"
set f [ open "| Soft/bin/tools/check_binary_data_file.exe -if \x22$FileInput1\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
WaitUntilCreated "$TMPCompareBinaryData.txt"
if [file exists "$TMPCompareBinaryData.txt"] {
    CheckBin1ON
    set f [open "$TMPCompareBinaryData.txt" "r"]
    gets $f CheckSize1
    gets $f CheckHeader1
    gets $f CheckRow1
    gets $f CheckCol1
    close $f
    }

DeleteFile "$TMPCompareBinaryData.txt"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/bin/tools/check_binary_data_file.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$FileInput2\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" "k"
set f [ open "| Soft/bin/tools/check_binary_data_file.exe -if \x22$FileInput2\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
WaitUntilCreated "$TMPCompareBinaryData.txt"
if [file exists "$TMPCompareBinaryData.txt"] {
    CheckBin2ON
    set f [open "$TMPCompareBinaryData.txt" "r"]
    gets $f CheckSize2
    gets $f CheckHeader2
    gets $f CheckRow2
    gets $f CheckCol2
    close $f
    }
    
set config "true"
if {$CheckSize1 != $CheckSize2} { set config "false" }

catch {package require Img}
image create photo ImageConfig
ImageConfig blank
.top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
image delete ImageConfig

if {$config == "true"} {
    image create photo ImageConfig -file "GUI/Images/smiley_ok.gif"
    .top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
    } else {
    image create photo ImageConfig -file "GUI/Images/smiley_ko.gif"
    .top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
    }

} 
}
#############################################################################
## Procedure:  CheckTerrasarDualnoSSC

proc ::CheckTerrasarDualnoSSC {} {
global OpenDirFile TMPCompareBinaryData NcolFullSize
global FileInput1 FileInput2
global CheckSize1 CheckHeader1 CheckRow1 CheckCol1
global CheckSize2 CheckHeader2 CheckRow2 CheckCol2

if {$OpenDirFile == 0} {

}
}
#############################################################################
## Procedure:  CheckTerrasarQuadSSC

proc ::CheckTerrasarQuadSSC {} {
global OpenDirFile TMPCompareBinaryData NcolFullSize
global FileInput1 FileInput2 FileInput3 FileInput4
global CheckSize1 CheckHeader1 CheckRow1 CheckCol1
global CheckSize2 CheckHeader2 CheckRow2 CheckCol2
global CheckSize3 CheckHeader3 CheckRow3 CheckCol3
global CheckSize4 CheckHeader4 CheckRow4 CheckCol4

if {$OpenDirFile == 0} {

DeleteFile "$TMPCompareBinaryData.txt"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/bin/tools/check_binary_data_file.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$FileInput1\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" "k"
set f [ open "| Soft/bin/tools/check_binary_data_file.exe -if \x22$FileInput1\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
WaitUntilCreated "$TMPCompareBinaryData.txt"
if [file exists "$TMPCompareBinaryData.txt"] {
    CheckBin1ON
    set f [open "$TMPCompareBinaryData.txt" "r"]
    gets $f CheckSize1
    gets $f CheckHeader1
    gets $f CheckRow1
    gets $f CheckCol1
    close $f
    }

DeleteFile "$TMPCompareBinaryData.txt"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/bin/tools/check_binary_data_file.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$FileInput2\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" "k"
set f [ open "| Soft/bin/tools/check_binary_data_file.exe -if \x22$FileInput2\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
WaitUntilCreated "$TMPCompareBinaryData.txt"
if [file exists "$TMPCompareBinaryData.txt"] {
    CheckBin2ON
    set f [open "$TMPCompareBinaryData.txt" "r"]
    gets $f CheckSize2
    gets $f CheckHeader2
    gets $f CheckRow2
    gets $f CheckCol2
    close $f
    }
    
DeleteFile "$TMPCompareBinaryData.txt"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/bin/tools/check_binary_data_file.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$FileInput3\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" "k"
set f [ open "| Soft/bin/tools/check_binary_data_file.exe -if \x22$FileInput3\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
WaitUntilCreated "$TMPCompareBinaryData.txt"
if [file exists "$TMPCompareBinaryData.txt"] {
    CheckBin3ON
    set f [open "$TMPCompareBinaryData.txt" "r"]
    gets $f CheckSize3
    gets $f CheckHeader3
    gets $f CheckRow3
    gets $f CheckCol3
    close $f
    }

DeleteFile "$TMPCompareBinaryData.txt"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
set ProgressLine "0"
update
TextEditorRunTrace "Process The Function Soft/bin/tools/check_binary_data_file.exe" "k"
TextEditorRunTrace "Arguments: -if \x22$FileInput4\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" "k"
set f [ open "| Soft/bin/tools/check_binary_data_file.exe -if \x22$FileInput4\x22 -ss terrasarx_ssc -inc $NcolFullSize -of \x22$TMPCompareBinaryData\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
WaitUntilCreated "$TMPCompareBinaryData.txt"
if [file exists "$TMPCompareBinaryData.txt"] {
    CheckBin4ON
    set f [open "$TMPCompareBinaryData.txt" "r"]
    gets $f CheckSize4
    gets $f CheckHeader4
    gets $f CheckRow4
    gets $f CheckCol4
    close $f
    }

set config "true"
if {$CheckSize1 != $CheckSize2} { set config "false" }
if {$CheckSize1 != $CheckSize3} { set config "false" }
if {$CheckSize1 != $CheckSize4} { set config "false" }

catch {package require Img}
image create photo ImageConfig
ImageConfig blank
.top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
image delete ImageConfig

if {$config == "true"} {
    image create photo ImageConfig -file "GUI/Images/smiley_ok.gif"
    .top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
    } else {
    image create photo ImageConfig -file "GUI/Images/smiley_ko.gif"
    .top438.fra57.tit90.f.cpd91 configure -anchor nw -image ImageConfig
    }

} 
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global tk_strictMotif MouseInitX MouseInitY MouseEndX MouseEndY BMPMouseX BMPMouseY

catch {package require unsafe}
set tk_strictMotif 1
global TrainingAreaTool; 
global x;
global y;

set TrainingAreaTool rect
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 200x200+22+22; update
    wm maxsize $top 1284 785
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top438 {base} {
    if {$base == ""} {
        set base .top438
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x230+160+100; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Check Size Binary Data File"
    vTcl:DefineAlias "$top" "Toplevel438" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd78 \
        -ipad 0 -text {Binary File 1} 
    vTcl:DefineAlias "$top.cpd78" "TitleFrame6" vTcl:WidgetProc "Toplevel438" 1
    bind $top.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd78 getframe]
    frame $site_4_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame23" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.lab83 \
        -text Size 
    vTcl:DefineAlias "$site_5_0.lab83" "Label6" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckSize1 -width 15 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry15" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame24" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab83 \
        -text Header 
    vTcl:DefineAlias "$site_5_0.lab83" "Label15" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckHeader1 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry16" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame25" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab83 \
        -text {Expected Rows} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label16" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckRow1 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry17" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame26" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab83 \
        -text {Expected Cols} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label17" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckCol1 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry18" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd73 \
        -ipad 0 -text {Binary File 2} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame7" vTcl:WidgetProc "Toplevel438" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    frame $site_4_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame27" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.lab83 \
        -text Size 
    vTcl:DefineAlias "$site_5_0.lab83" "Label7" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckSize2 -width 15 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry19" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame28" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab83 \
        -text Header 
    vTcl:DefineAlias "$site_5_0.lab83" "Label18" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckHeader2 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry20" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame29" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab83 \
        -text {Expected Rows} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label19" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckRow2 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry21" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame30" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab83 \
        -text {Expected Cols} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label20" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckCol2 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry22" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd74 \
        -ipad 0 -text {Binary File 3} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame8" vTcl:WidgetProc "Toplevel438" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    frame $site_4_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame31" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.lab83 \
        -text Size 
    vTcl:DefineAlias "$site_5_0.lab83" "Label8" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckSize3 -width 15 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry23" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame32" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab83 \
        -text Header 
    vTcl:DefineAlias "$site_5_0.lab83" "Label21" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckHeader3 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry24" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame33" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab83 \
        -text {Expected Rows} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label22" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckRow3 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry25" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame34" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab83 \
        -text {Expected Cols} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label23" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckCol3 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry26" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $top.cpd75 \
        -ipad 0 -text {Binary File 4} 
    vTcl:DefineAlias "$top.cpd75" "TitleFrame9" vTcl:WidgetProc "Toplevel438" 1
    bind $top.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd75 getframe]
    frame $site_4_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame35" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd69
    label $site_5_0.lab83 \
        -text Size 
    vTcl:DefineAlias "$site_5_0.lab83" "Label9" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckSize4 -width 15 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry27" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd70 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame36" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd70
    label $site_5_0.lab83 \
        -text Header 
    vTcl:DefineAlias "$site_5_0.lab83" "Label24" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckHeader4 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry28" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame37" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd71
    label $site_5_0.lab83 \
        -text {Expected Rows} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label25" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckRow4 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry29" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame38" vTcl:WidgetProc "Toplevel438" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab83 \
        -text {Expected Cols} 
    vTcl:DefineAlias "$site_5_0.lab83" "Label26" vTcl:WidgetProc "Toplevel438" 1
    entry $site_5_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckCol4 -width 7 
    vTcl:DefineAlias "$site_5_0.ent84" "Entry30" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.lab83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.ent84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra57 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra57" "Frame20" vTcl:WidgetProc "Toplevel438" 1
    set site_3_0 $top.fra57
    TitleFrame $site_3_0.tit90 \
        -ipad 0 -text Result 
    vTcl:DefineAlias "$site_3_0.tit90" "TitleFrame1" vTcl:WidgetProc "Toplevel438" 1
    bind $site_3_0.tit90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit90 getframe]
    label $site_5_0.cpd91 \
        \
        -image [vTcl:image:get_image [file join . GUI Images smiley_transparent.gif]] 
    vTcl:DefineAlias "$site_5_0.cpd91" "Label438_2" vTcl:WidgetProc "Toplevel438" 1
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel438); TextEditorRunTrace "Close Window Check Binary Data Files" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel438" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.tit90 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 1 -fill x -pady 3 -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
}

Window show .
Window show .top438

main $argc $argv
