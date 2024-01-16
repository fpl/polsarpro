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

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

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
    set base .top368
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra28 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra28
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra67
    namespace eval ::widgets::$site_5_0.lab69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent70 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.but68 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.ent34 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd79
    namespace eval ::widgets::$site_7_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd80
    namespace eval ::widgets::$site_7_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.ent34 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.ent37 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd77 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra90
    namespace eval ::widgets::$site_4_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra91
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra92 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra92
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.but78 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra93
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m102 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top368
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
    wm geometry $top 200x200+25+25; update
    wm maxsize $top 3360 1028
    wm minsize $top 116 1
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

proc vTclWindow.top368 {base} {
    if {$base == ""} {
        set base .top368
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
    wm geometry $top 500x320+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Fuzzy C - Means  H / Alpha Classification"
    vTcl:DefineAlias "$top" "Toplevel368" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel368" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel368" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FCMDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel368" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button42" vTcl:WidgetProc "Toplevel368" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel368" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable FCMOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel368" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel368" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FCMOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel368" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd80 \
        \
        -command {global DirName DataDir FCMOutputDir

set FCMDirOutputTmp $FCMOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set FCMOutputDir $DirName
    } else {
    set FCMOutputDir $FCMDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Button $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra28 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel368" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel368" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel368" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel368" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel368" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel368" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel368" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel368" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel368" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit66 \
        -ipad 0 -text {Fuzzyfication Process} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame2" vTcl:WidgetProc "Toplevel368" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    frame $site_4_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra67" "Frame1" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.fra67
    label $site_5_0.lab69 \
        -text {Crispness Factor} 
    vTcl:DefineAlias "$site_5_0.lab69" "Label1" vTcl:WidgetProc "Toplevel368" 1
    entry $site_5_0.ent70 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable FCMCrisp -width 5 
    vTcl:DefineAlias "$site_5_0.ent70" "Entry1" vTcl:WidgetProc "Toplevel368" 1
    pack $site_5_0.lab69 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.ent70 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    button $site_4_0.but68 \
        -background #ffff00 \
        -command {global FCMDirInput FCMDirOutput FCMOutputDir FCMOutputSubDir
global FCMCrisp
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set FCMDirOutput $FCMOutputDir
if {$FCMOutputSubDir != ""} {append FCMDirOutput "/$FCMOutputSubDir"}

    #####################################################################
    #Create Directory
    set FCMDirOutput [PSPCreateDirectoryMask $FCMDirOutput $FCMOutputDir $FCMDirInput]
    #####################################################################       
    
if {"$VarWarning"=="ok"} {

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Crispness Factor"; set TestVarType(4) "float"; set TestVarValue(4) $FCMCrisp; set TestVarMin(4) "0"; set TestVarMax(4) "100"
    TestVar 5
    if {$TestVarError == "ok"} {

    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set config "true"
    if [file exists "$FCMDirInput/entropy.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Entropy DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/alpha.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Alpha DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {"$config"=="true"} {
        set Fonction "Creation of all the Binary Data Files"
        set Fonction2 "of the H / Alpha Fuzzyfication"
        set MaskCmd ""
        set MaskFile "$FCMDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_alpha_fuzzy_membership.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$FCMDirInput\x22 -od \x22$FCMDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sig $FCMCrisp $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/h_alpha_fuzzy_membership.exe -id \x22$FCMDirInput\x22 -od \x22$FCMDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -sig $FCMCrisp $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set conf "true"
        if [file exists "$FCMDirOutput/Mu_Z1.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z1.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z2.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z2.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z3.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z3.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z4.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z4.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z5.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z5.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z6.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z6.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z7.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z7.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if [file exists "$FCMDirOutput/Mu_Z8.bin"] { EnviWriteConfig "$FCMDirOutput/Mu_Z8.bin" $FinalNlig $FinalNcol 4 } else { set conf "false" }
        if {"$conf"=="true"} { 
            set BMPDirInput $FCMDirOutput
            set BMPFileInput "$FCMDirOutput/Mu_Z1.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z1.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z2.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z2.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z3.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z3.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z4.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z4.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z5.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z5.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z6.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z6.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z7.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z7.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$FCMDirOutput/Mu_Z8.bin"
            set BMPFileOutput "$FCMDirOutput/Mu_Z8.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            $widget(Button368_1) configure -state normal
            }
        } 
    }      
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel368); TextEditorRunTrace "Close Window FCM - H Alpha Classification" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_4_0.but68" "Button1" vTcl:WidgetProc "Toplevel368" 1
    pack $site_4_0.fra67 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 55 -pady 4 \
        -side left 
    pack $site_4_0.but68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit81 \
        -ipad 0 -text {Fuzzy Classification} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel368" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame53" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame50" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab33 \
        -padx 1 -text {% of Pixels Switching Class} 
    vTcl:DefineAlias "$site_6_0.lab33" "Label36" vTcl:WidgetProc "Toplevel368" 1
    label $site_6_0.lab34 \
        -padx 1 -text {Maximum Number of Iterations} 
    vTcl:DefineAlias "$site_6_0.lab34" "Label37" vTcl:WidgetProc "Toplevel368" 1
    pack $site_6_0.lab33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame51" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.fra40
    entry $site_6_0.ent34 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable FCMPourcentage -width 5 
    vTcl:DefineAlias "$site_6_0.ent34" "Entry24" vTcl:WidgetProc "Toplevel368" 1
    entry $site_6_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable FCMIteration -width 5 
    vTcl:DefineAlias "$site_6_0.ent36" "Entry23" vTcl:WidgetProc "Toplevel368" 1
    pack $site_6_0.ent34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.ent36 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    checkbutton $site_4_0.cpd83 \
        -text BMP -variable BMPFCM 
    vTcl:DefineAlias "$site_4_0.cpd83" "Checkbutton59" vTcl:WidgetProc "Toplevel368" 1
    frame $site_4_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd67" "Frame54" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.cpd67
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame52" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab33 \
        -padx 1 -text {Weighting Exponent} 
    vTcl:DefineAlias "$site_6_0.lab33" "Label39" vTcl:WidgetProc "Toplevel368" 1
    frame $site_6_0.cpd79 \
        -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.cpd79" "Frame56" vTcl:WidgetProc "Toplevel368" 1
    set site_7_0 $site_6_0.cpd79
    label $site_7_0.lab35 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_7_0.lab35" "Label43" vTcl:WidgetProc "Toplevel368" 1
    pack $site_7_0.lab35 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd80 \
        -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.cpd80" "Frame57" vTcl:WidgetProc "Toplevel368" 1
    set site_7_0 $site_6_0.cpd80
    label $site_7_0.lab35 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_7_0.lab35" "Label44" vTcl:WidgetProc "Toplevel368" 1
    pack $site_7_0.lab35 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame55" vTcl:WidgetProc "Toplevel368" 1
    set site_6_0 $site_5_0.fra40
    entry $site_6_0.ent34 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable FCMWei -width 5 
    vTcl:DefineAlias "$site_6_0.ent34" "Entry26" vTcl:WidgetProc "Toplevel368" 1
    entry $site_6_0.ent37 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable FCMNwinL -width 5 
    vTcl:DefineAlias "$site_6_0.ent37" "Entry28" vTcl:WidgetProc "Toplevel368" 1
    entry $site_6_0.cpd77 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable FCMNwinC -width 5 
    vTcl:DefineAlias "$site_6_0.cpd77" "Entry29" vTcl:WidgetProc "Toplevel368" 1
    pack $site_6_0.ent34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.ent37 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side right 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    frame $top.cpd66
    set site_3_0 $top.cpd66
    frame $site_3_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra90" "Frame7" vTcl:WidgetProc "Toplevel368" 1
    set site_4_0 $site_3_0.fra90
    frame $site_4_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra91" "Frame8" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.fra91
    label $site_5_0.cpd94 \
        -text {ColorMap 8} 
    vTcl:DefineAlias "$site_5_0.cpd94" "Label125" vTcl:WidgetProc "Toplevel368" 1
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.fra92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra92" "Frame10" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.fra92
    button $site_5_0.cpd98 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_5_0.cpd98 {global ColorMapFCM8 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 8
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapFCM8] {
    set f [open $ColorMapFCM8 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur
   
.top38.fra35.but38 configure -state normal

set VarColorMap ""
set ColorMapIn $ColorMapFCM8
set ColorMapOut $ColorMapFCM8
WidgetShowFromWidget $widget(Toplevel368) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapFCM8 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_5_0.cpd98" "Button41" vTcl:WidgetProc "Toplevel368" 1
    bindtags $site_5_0.cpd98 "$site_5_0.cpd98 Button $top all _vTclBalloon"
    bind $site_5_0.cpd98 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame11" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.cpd77
    button $site_5_0.but78 \
        \
        -command {global FileName FCMDirInput ColorMapFCM8

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$FCMDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapFCM8 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but78" "Button2" vTcl:WidgetProc "Toplevel368" 1
    bindtags $site_5_0.but78 "$site_5_0.but78 Button $top all _vTclBalloon"
    bind $site_5_0.but78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.but78 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    frame $site_4_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra93" "Frame12" vTcl:WidgetProc "Toplevel368" 1
    set site_5_0 $site_4_0.fra93
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapFCM8 -width 40 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry53" vTcl:WidgetProc "Toplevel368" 1
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra91 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side left 
    pack $site_4_0.fra92 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    pack $site_4_0.fra93 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_3_0.fra90 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel368" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global FCMDirInput FCMDirOutput FCMOutputDir FCMOutputSubDir
global FCMNwinL FCMNwinC FCMPourcentage FCMIteration FCMWei BMPFCM
global FCMHAlphaClassifFonction ColorMapFCM8 TMPMemoryAllocError
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set FCMDirOutput $FCMOutputDir
if {$FCMOutputSubDir != ""} {append FCMDirOutput "/$FCMOutputSubDir"}

    #####################################################################
    #Create Directory
    set FCMDirOutput [PSPCreateDirectoryMask $FCMDirOutput $FCMOutputDir $FCMDirInput]
    #####################################################################       
    
if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $FCMNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Pourcentage"; set TestVarType(5) "float"; set TestVarValue(5) $FCMPourcentage; set TestVarMin(5) "0"; set TestVarMax(5) "100"
    set TestVarName(6) "Iteration"; set TestVarType(6) "int"; set TestVarValue(6) $FCMIteration; set TestVarMin(6) "1"; set TestVarMax(6) "100"
    set TestVarName(7) "Weighting Factor"; set TestVarType(7) "float"; set TestVarValue(7) $FCMWei; set TestVarMin(7) "0"; set TestVarMax(7) "100"
    set TestVarName(8) "ColorMap8"; set TestVarType(8) "file"; set TestVarValue(8) $ColorMapFCM8; set TestVarMin(8) ""; set TestVarMax(8) ""
    set TestVarName(9) "Window Size Col"; set TestVarType(9) "int"; set TestVarValue(9) $FCMNwinC; set TestVarMin(9) "1"; set TestVarMax(9) "1000"
    TestVar 10
    if {$TestVarError == "ok"} {

    set config "true"
    if [file exists "$FCMDirInput/Mu_Z1.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z1 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z2.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z2 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z3.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z3 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z4.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z4 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z5.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z5 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z6.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z6 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z7.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z7 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$FCMDirInput/Mu_Z8.bin"] {
        } else {
        set config "false"
        set VarError ""
        set ErrorMessage "THE FILE Mu_Z8 DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {"$config"=="true"} {
        set Fonction "Creation of all the Binary Data and BMP Files"
        set Fonction2 "of the Fuzzy - H / Alpha Classification"
        set MaskCmd ""
        set MaskFile "$FCMDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        set FCMHAlphaClassifF $FCMHAlphaClassifFonction
        if {$FCMHAlphaClassifFonction == "S2m"} { set FCMHAlphaClassifF "S2" }
        if {$FCMHAlphaClassifFonction == "S2b"} { set FCMHAlphaClassifF "S2" }
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_alpha_fcm_classifier.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$FCMDirInput\x22 -od \x22$FCMDirOutput\x22 -iodf $FCMHAlphaClassifF -nwr $FCMNwinL -nwc $FCMNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -wei $FCMWei -wem $FCMWei -dV $FCMPourcentage -nit $FCMIteration -bmp $BMPFCM -clm \x22$ColorMapFCM8\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/h_alpha_fcm_classifier.exe -id \x22$FCMDirInput\x22 -od \x22$FCMDirOutput\x22 -iodf $FCMHAlphaClassifF -nwr $FCMNwinL -nwc $FCMNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -wei $FCMWei -wem $FCMWei -dV $FCMPourcentage -nit $FCMIteration -bmp $BMPFCM -clm \x22$ColorMapFCM8\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        set ClassificationFile "$FCMDirOutput/fcm_H_alpha_class_"
        append ClassificationFile $FCMWei; append ClassificationFile "_"; append ClassificationFile $FCMNwinL; append ClassificationFile "x"; append ClassificationFile $FCMNwinC
        set ClassificationInputFile "$ClassificationFile.bin"
        if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapFCM8 8}
        } 
    }      
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel368); TextEditorRunTrace "Close Window FCM - H Alpha Classification" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button368_1" vTcl:WidgetProc "Toplevel368" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/FCMHAlphaClassification.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel368" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel368); TextEditorRunTrace "Close Window FCM - H Alpha Classification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel368" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m102 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra28 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra42 \
        -in $top -anchor center -expand 1 -fill x -side top 

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
Window show .top368

main $argc $argv
