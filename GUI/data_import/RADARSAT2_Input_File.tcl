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

        {{[file join . GUI Images RADARSAT2.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}

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
    set base .top219
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab66 {
        array set save {-image 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit66 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad67 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but66 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra81 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra81
    namespace eval ::widgets::$site_4_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
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
            vTclWindow.top219
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

proc vTclWindow.top219 {base} {
    if {$base == ""} {
        set base .top219
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
    wm geometry $top 500x560+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "RADARSAT2 Input Data File"
    vTcl:DefineAlias "$top" "Toplevel219" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images RADARSAT2.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel219" 1
    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel219" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel219" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RADARSAT2DirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel219" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel219" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel219" 1
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame219" vTcl:WidgetProc "Toplevel219" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RADARSAT2DirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry219" vTcl:WidgetProc "Toplevel219" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel219" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir RADARSAT2DirOutput
global VarWarning WarningMessage WarningMessage2

set RADARSAT2OutputDirTmp $RADARSAT2DirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set RADARSAT2DirOutput $DirName
        } else {
        set RADARSAT2DirOutput $RADARSAT2OutputDirTmp
        }
    } else {
    set RADARSAT2DirOutput $RADARSAT2OutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button219" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Product File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame220" vTcl:WidgetProc "Toplevel219" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RADARSAT2ProductFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry220" vTcl:WidgetProc "Toplevel219" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame30" vTcl:WidgetProc "Toplevel219" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName RADARSAT2DirInput RADARSAT2ProductFile

set types {
    {{XML Files}        {.xml}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $RADARSAT2DirInput $types "SAR PRODUCT FILE"
set RADARSAT2ProductFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button220" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.tit66 \
        -text {Output Scaling Look-Up-Table ( LUT )} 
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel219" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.cpd68 \
        -text Beta-Nought -value beta -variable RADARSAT2Lut 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel219" 1
    radiobutton $site_4_0.cpd69 \
        -text Gamma-Nought -value gamma -variable RADARSAT2Lut 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel219" 1
    radiobutton $site_4_0.rad67 \
        -text Sigma-Nought -value sigma -variable RADARSAT2Lut 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel219" 1
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel219" 1
    set site_3_0 $top.fra73
    button $site_3_0.but74 \
        -background #ffff00 \
        -command {global RADARSAT2DirInput RADARSAT2DirOutput RADARSAT2FileInputFlag
global RADARSAT2DataFormat RADARSAT2DataLevel RADARSAT2ProductFile
global RADARSAT2Lut RADARSAT2LutFile RADARSAT2Antenna RADARSAT2Pass RADARSAT2AntennaPass
global FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPRadarsat2Config TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

set datalevelerror 0
#####################################################################
#Create Directory
set RADARSAT2DirOutput [PSPCreateDirectoryMask $RADARSAT2DirOutput $RADARSAT2DirOutput $RADARSAT2DirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

set RADARSAT2LutFile [file dirname $RADARSAT2ProductFile]
if {$RADARSAT2Lut == "beta"} { append RADARSAT2LutFile "/lutBeta.xml" }
if {$RADARSAT2Lut == "gamma"} { append RADARSAT2LutFile "/lutGamma.xml" }
if {$RADARSAT2Lut == "sigma"} { append RADARSAT2LutFile "/lutSigma.xml" }

DeleteFile  $TMPRadarsat2Config

if [file exists $RADARSAT2LutFile] {
    set RADARSAT2File "$RADARSAT2DirOutput/product_lut.txt"
    set Sensor "radarsat"
    ReadXML $RADARSAT2LutFile $RADARSAT2File $TMPRadarsat2Config $Sensor
    }

DeleteFile $TMPRadarsat2Config
DeleteFile $TMPGoogle

if [file exists $RADARSAT2ProductFile] {
    set RADARSAT2File "$RADARSAT2DirOutput/product_header.txt"
    set Sensor "radarsat"
    ReadXML $RADARSAT2ProductFile $RADARSAT2File $TMPRadarsat2Config $Sensor
    WaitUntilCreated $TMPRadarsat2Config
    if [file exists $TMPRadarsat2Config] {
        set f [open $TMPRadarsat2Config r]
        gets $f RADARSAT2DataLevel
        gets $f RADARSAT2Antenna
        gets $f RADARSAT2Pass
        gets $f RADARSAT2IncAngNear
        gets $f RADARSAT2IncAngFar
        gets $f RADARSAT2DataType
        gets $f RADARSAT2ResRg
        gets $f RADARSAT2ResAz
        close $f
        if {$RADARSAT2DataType == "Complex" } {

            set WarningMessage "PolSARpro WILL TAKE INTO ACCOUNT THE"
            set WarningMessage2 "RADARSAT-2 ENGINEER CONVENTION FOR THE"
            set WarningMessage3 "DEFINITION OF THE POLARIMETRIC CHANNELS"
            set WarningMessage4 "WITH : s12 = VH and s21 = HV"
            set VarAdvice ""
            Window show $widget(Toplevel377); TextEditorRunTrace "Open Window Advice" "b"
            tkwait variable VarAdvice

            if {$RADARSAT2DataLevel == "HH VV HV VH" } { set RADARSAT2DataLevel "quad"; set PolarType "full" }
            if {$RADARSAT2DataLevel == "HH HV" } { set RADARSAT2DataLevel "dual"; set PolarType "pp1" }
            if {$RADARSAT2DataLevel == "HV HH" } { set RADARSAT2DataLevel "dual"; set PolarType "pp1" }
            if {$RADARSAT2DataLevel == "VH VV" } { set RADARSAT2DataLevel "dual"; set PolarType "pp2" }
            if {$RADARSAT2DataLevel == "VV VH" } { set RADARSAT2DataLevel "dual"; set PolarType "pp2" }
            if {$RADARSAT2DataLevel == "HH VV" } { set RADARSAT2DataLevel "dual"; set PolarType "pp3" }
            if {$RADARSAT2DataLevel == "VV HH" } { set RADARSAT2DataLevel "dual"; set PolarType "pp3" }

            if {$RADARSAT2Pass == "Ascending" } { set RADARSAT2AntennaPass "A" } else { set RADARSAT2AntennaPass "D" }
            if {$RADARSAT2Antenna == "Right" } { append RADARSAT2AntennaPass "R" } else { append RADARSAT2AntennaPass "L" }

            set f [open "$RADARSAT2DirOutput/config_acquisition.txt" w]
            puts $f $RADARSAT2AntennaPass
            puts $f [expr ($RADARSAT2IncAngNear + $RADARSAT2IncAngFar) / 2 ]
            puts $f $RADARSAT2ResRg
            puts $f $RADARSAT2ResAz
            close $f

            if {$RADARSAT2DataFormat == $RADARSAT2DataLevel } {
                $widget(Button219_5) configure -state normal; 
                $widget(Label219_10) configure -state normal; $widget(Entry219_10) configure -disabledbackground #FFFFFF
                if {$PolarType == "full" } {
                    $widget(Entry219_1) configure -disabledbackground #FFFFFF; $widget(Button219_1) configure -state normal
                    $widget(TitleFrame219_1) configure -text "Input Data File (s11)"
                    set FileInput "$RADARSAT2DirInput/imagery_HH.tif"
                    if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                    $widget(Entry219_2) configure -disabledbackground #FFFFFF; $widget(Button219_2) configure -state normal
                    $widget(TitleFrame219_2) configure -text "Input Data File (s12)"
                    set FileInput "$RADARSAT2DirInput/imagery_VH.tif"
                    if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                    $widget(Entry219_3) configure -disabledbackground #FFFFFF; $widget(Button219_3) configure -state normal
                    $widget(TitleFrame219_3) configure -text "Input Data File (s21)"
                    set FileInput "$RADARSAT2DirInput/imagery_HV.tif"
                    if [file exists $FileInput] {set FileInput3 $FileInput } else { set FileInput3 "" }
                    $widget(Entry219_4) configure -disabledbackground #FFFFFF; $widget(Button219_4) configure -state normal
                    $widget(TitleFrame219_4) configure -text "Input Data File (s22)"
                    set FileInput "$RADARSAT2DirInput/imagery_VV.tif"
                    if [file exists $FileInput] {set FileInput4 $FileInput } else { set FileInput4 "" }
                    } else {
                    if {$PolarType == "pp1" } { set channel1 "Channel1 = HH"; set channel2 "Channel2 = HV"}
                    if {$PolarType == "pp2" } { set channel1 "Channel1 = VV"; set channel2 "Channel2 = VH"}
                    if {$PolarType == "pp3" } { set channel1 "Channel1 = HH"; set channel2 "Channel2 = VV"}
                    $widget(Entry219_1) configure -disabledbackground #FFFFFF; $widget(Button219_1) configure -state normal
                    $widget(TitleFrame219_1) configure -text "Input Data File ($channel1)"
                    $widget(Entry219_2) configure -disabledbackground #FFFFFF; $widget(Button219_2) configure -state normal
                    $widget(TitleFrame219_2) configure -text "Input Data File ($channel2)"
                    $widget(Entry219_3) configure -disabledbackground $PSPBackgroundColor; $widget(Button219_3) configure -state disable
                    $widget(TitleFrame219_3) configure -text ""
                    $widget(Entry219_4) configure -disabledbackground $PSPBackgroundColor; $widget(Button219_4) configure -state disable
                    $widget(TitleFrame219_4) configure -text ""
                    if {$PolarType == "pp1" } {
                        set FileInput "$RADARSAT2DirInput/imagery_HH.tif"
                        if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                        set FileInput "$RADARSAT2DirInput/imagery_HV.tif"
                        if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                        }                        
                    if {$PolarType == "pp2" } {
                        set FileInput "$RADARSAT2DirInput/imagery_VV.tif"
                        if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                        set FileInput "$RADARSAT2DirInput/imagery_VH.tif"
                        if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                        }                        
                    if {$PolarType == "pp3" } {
                        set FileInput "$RADARSAT2DirInput/imagery_HH.tif"
                        if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                        set FileInput "$RADARSAT2DirInput/imagery_VV.tif"
                        if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                        }                        
                    }
                $widget(Button219_6) configure -state normal
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsat2_google.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSAT2DirOutput\x22 -of \x22$TMPGoogle\x22" "k"
                set f [ open "| Soft/bin/data_import/radarsat2_google.exe -id \x22$RADARSAT2DirOutput\x22 -of \x22$TMPGoogle\x22" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WaitUntilCreated $TMPGoogle
                if [file exists $TMPGoogle] {
                    set f [open $TMPGoogle r]
                    gets $f GoogleLatCenter
                    gets $f GoogleLongCenter
                    gets $f GoogleLat00
                    gets $f GoogleLong00
                    gets $f GoogleLat0N
                    gets $f GoogleLong0N
                    gets $f GoogleLatN0
                    gets $f GoogleLongN0
                    gets $f GoogleLatNN
                    gets $f GoogleLongNN
                    close $f
                    }
                $widget(Button219_7) configure -state normal
                } else {
                set ErrorMessage "ERROR IN THE RADARSAT-2 DATA FORMAT (DUAL - QUAD)"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set RADARSAT2DataLevel ""; set RADARSAT2ProductFile ""; set RADARSAT2FileInputFlag 0
                set datalevelerror 1
                }
            } else {
            set ErrorMessage "ERROR IN THE RADARSAT-2 DATA TYPE (SLC - Complex)"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set RADARSAT2DataLevel ""; set RADARSAT2ProductFile ""; set RADARSAT2FileInputFlag 0
            set datalevelerror 2
            }
        } else {
        set ErrorMessage "PRODUCT FILE IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set RADARSAT2DataLevel ""; set RADARSAT2ProductFile ""
        }
        #TMPRADARSAT2Config Exists
    } else {
    set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RADARSAT2DataLevel ""; set RADARSAT2ProductFile ""; set RADARSAT2FileInputFlag 0
    }
    #ProductFile Exists

if {$datalevelerror == 1 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    if {$RADARSAT2DataFormat == "quad" } { 
        TextEditorRunTrace "Close EO-SI" "b"
        set RADARSAT2DataFormat "dual" 
        } else {
        TextEditorRunTrace "Close EO-SI Dual Pol" "b"
        set RADARSAT2DataFormat "quad"
        }
    Window hide $widget(Toplevel219); TextEditorRunTrace "Close Window RADARSAT2 Input File" "b"
    }
if {$datalevelerror == 2 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    Window hide $widget(Toplevel219); TextEditorRunTrace "Close Window RADARSAT2 Input File" "b"
    }
}
#VarWarning
}
#OpenDirFile} \
        -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but74" "Button1" vTcl:WidgetProc "Toplevel219" 1
    button $site_3_0.but75 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage RADARSAT2DirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set RADARSAT2File "$RADARSAT2DirOutput/product_header.txt"
if [file exists $RADARSAT2File] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top219 $RADARSAT2File
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.but75" "Button219_5" vTcl:WidgetProc "Toplevel219" 1
    button $site_3_0.but66 \
        \
        -command {global FileName VarError ErrorMessage RADARSAT2DirInput

set RADARSAT2File "$RADARSAT2DirInput/GEARTH_POLY.kml"
if [file exists $RADARSAT2File] {
    GoogleEarth $RADARSAT2File
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -text Google 
    vTcl:DefineAlias "$site_3_0.but66" "Button219_7" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_3_0.but66 "$site_3_0.but66 Button $top all _vTclBalloon"
    bind $site_3_0.but66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    frame $site_3_0.fra81 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra81" "Frame6" vTcl:WidgetProc "Toplevel219" 1
    set site_4_0 $site_3_0.fra81
    label $site_4_0.lab82 \
        -text {Polarisation Mode} 
    vTcl:DefineAlias "$site_4_0.lab82" "Label219_10" vTcl:WidgetProc "Toplevel219" 1
    entry $site_4_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable PolarType -width 5 
    vTcl:DefineAlias "$site_4_0.ent83" "Entry219_10" vTcl:WidgetProc "Toplevel219" 1
    pack $site_4_0.lab82 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
        -side top 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra81 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel219" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame219_1" vTcl:WidgetProc "Toplevel219" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry219_1" vTcl:WidgetProc "Toplevel219" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel219" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd119 \
        \
        -command {global FileName RADARSAT2DirInput RADARSAT2DataFormat FileInput1

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSAT2DataFormat == "quad"} {OpenFile $RADARSAT2DirInput $types "HH INPUT FILE (s11)"}
if {$RADARSAT2DataFormat == "dual"} {OpenFile $RADARSAT2DirInput $types "INPUT FILE (Channel 1)"}
set FileInput1 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button219_1" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_6_0.cpd119 "$site_6_0.cpd119 Button $top all _vTclBalloon"
    bind $site_6_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd119 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd116 \
        -ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame219_2" vTcl:WidgetProc "Toplevel219" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry219_2" vTcl:WidgetProc "Toplevel219" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel219" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName RADARSAT2DirInput RADARSAT2DataFormat FileInput2

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSAT2DataFormat == "quad"} {OpenFile $RADARSAT2DirInput $types "HV INPUT FILE (s12)"}
if {$RADARSAT2DataFormat == "dual"} {OpenFile $RADARSAT2DirInput $types "INPUT FILE (Channel 2)"}
set FileInput2 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button219_2" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_6_0.cpd120 "$site_6_0.cpd120 Button $top all _vTclBalloon"
    bind $site_6_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd120 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd117 \
        -ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame219_3" vTcl:WidgetProc "Toplevel219" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry219_3" vTcl:WidgetProc "Toplevel219" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel219" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName RADARSAT2DirInput RADARSAT2DataFormat FileInput3

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSAT2DataFormat == "quad"} {OpenFile $RADARSAT2DirInput $types "VH INPUT FILE (s21)"}
set FileInput3 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button219_3" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_6_0.cpd121 "$site_6_0.cpd121 Button $top all _vTclBalloon"
    bind $site_6_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd121 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame219_4" vTcl:WidgetProc "Toplevel219" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry219_4" vTcl:WidgetProc "Toplevel219" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame28" vTcl:WidgetProc "Toplevel219" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd122 \
        \
        -command {global FileName RADARSAT2DirInput RADARSAT2DataFormat FileInput4

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSAT2DataFormat == "quad"} {OpenFile $RADARSAT2DirInput $types "VV INPUT FILE (s22)"}
set FileInput4 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd122" "Button219_4" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_6_0.cpd122 "$site_6_0.cpd122 Button $top all _vTclBalloon"
    bind $site_6_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd122 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd117 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame5" vTcl:WidgetProc "Toplevel219" 1
    set site_3_0 $top.fra76
    label $site_3_0.lab77 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_3_0.lab77" "Label219_1" vTcl:WidgetProc "Toplevel219" 1
    entry $site_3_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_3_0.ent78" "Entry219_5" vTcl:WidgetProc "Toplevel219" 1
    label $site_3_0.lab79 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_3_0.lab79" "Label219_2" vTcl:WidgetProc "Toplevel219" 1
    entry $site_3_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_3_0.ent80" "Entry219_6" vTcl:WidgetProc "Toplevel219" 1
    pack $site_3_0.lab77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.lab79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel219" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global RADARSAT2DirOutput RADARSAT2FileInputFlag RADARSAT2DataFormat
global OpenDirFile TMPRadarsat2Config RADARSAT2LutFile
global IEEEFormat FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set RADARSAT2FileInputFlag 0
if {$RADARSAT2DataFormat == "quad"} {
    set RADARSAT2FileFlag 0
    if {$FileInput1 != ""} {incr RADARSAT2FileFlag}
    if {$FileInput2 != ""} {incr RADARSAT2FileFlag}
    if {$FileInput3 != ""} {incr RADARSAT2FileFlag}
    if {$FileInput4 != ""} {incr RADARSAT2FileFlag}
    if {$RADARSAT2FileFlag == 4} {set RADARSAT2FileInputFlag 1}
    }
if {$RADARSAT2DataFormat == "dual"} {
    set RADARSAT2FileFlag 0
    if {$FileInput1 != ""} {incr RADARSAT2FileFlag}
    if {$FileInput2 != ""} {incr RADARSAT2FileFlag}
    if {$RADARSAT2FileFlag == 2} {set RADARSAT2FileInputFlag 1}
    }
if {$RADARSAT2FileInputFlag == 1} {

    DeleteFile $TMPRadarsat2Config

    TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsat2_header.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInput1\x22 -of \x22$TMPRadarsat2Config\x22" "k"
    set f [ open "| Soft/bin/data_import/radarsat2_header.exe -if \x22$FileInput1\x22 -of \x22$TMPRadarsat2Config\x22" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    
    set NligFullSize 0
    set NcolFullSize 0
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NligFullSizeInput 0
    set NcolFullSizeInput 0
    set ConfigFile $TMPRadarsat2Config
    set ErrorMessage ""
    WaitUntilCreated $ConfigFile
    if [file exists $ConfigFile] {
        set f [open $ConfigFile r]
        gets $f tmp
        gets $f NligFullSize
        gets $f tmp
        gets $f tmp
        gets $f NcolFullSize
        gets $f tmp
        gets $f tmp
        gets $f IEEEFormat
        close $f
        $widget(Entry219_5) configure -disabledbackground #FFFFFF; $widget(Label219_1) configure -state normal
        $widget(Entry219_6) configure -disabledbackground #FFFFFF; $widget(Label219_2) configure -state normal
        set NligInit 1
        set NligEnd $NligFullSize
        set NcolInit 1
        set NcolEnd $NcolFullSize
        set NligFullSizeInput $NligFullSize
        set NcolFullSizeInput $NcolFullSize

        TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsat2_lut.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$RADARSAT2DirOutput\x22 -nc $NcolFullSize" "k"
        set f [ open "| Soft/bin/data_import/radarsat2_lut.exe -id \x22$RADARSAT2DirOutput\x22 -nc $NcolFullSize" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set RADARSAT2LutFile "$RADARSAT2DirOutput/product_lut.bin"

        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel219); TextEditorRunTrace "Close Window RADARSAT2 Input File" "b"
        } else {
        set ErrorMessage "ROWS / COLS EXTRACTION ERROR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        Window hide $widget(Toplevel219); TextEditorRunTrace "Close Window RADARSAT2 Input File" "b"
        }
    } else {
    set RADARSAT2FileInputFlag 0
    set ErrorMessage "ENTER THE RADARSAT2 DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button219_6" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/RADARSAT2_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel219); TextEditorRunTrace "Close Window RADARSAT2 Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel219" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.fra71 \
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
Window show .top219

main $argc $argv
