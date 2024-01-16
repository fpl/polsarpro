#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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
    set base .top76
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra35 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra35
    namespace eval ::widgets::$site_3_0.but37 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but38 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but39 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but40 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but41 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but42 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but43 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but44 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but45 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but46 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but47 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but48 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but49 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but50 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but51 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but70 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but72 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but73 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but76 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but77 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but78 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but79 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but80 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but83 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but84 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but85 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but86 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but87 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but36 {
        array set save {-background 1 -command 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top76
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
    wm geometry $top 200x200+176+176; update
    wm maxsize $top 1604 1185
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

proc vTclWindow.top76 {base} {
    if {$base == ""} {
        set base .top76
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
    wm geometry $top 515x35+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "ColorMap32"
    vTcl:DefineAlias "$top" "Toplevel76" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra35 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra35" "Frame396" vTcl:WidgetProc "Toplevel76" 1
    set site_3_0 $top.fra35
    button $site_3_0.but37 \
        -background #840000 \
        -command {

UpdateColorMap .top76.fra35.but37 2} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but37" "Button558" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but38 \
        -background #880000 \
        -command {

UpdateColorMap .top76.fra35.but38 3} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but38" "Button559" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but39 \
        -background #8c0000 \
        -command {

UpdateColorMap .top76.fra35.but39 4} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but39" "Button560" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but40 \
        -background #900000 \
        -command {

UpdateColorMap .top76.fra35.but40 5} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but40" "Button561" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but41 \
        -background #940000 \
        -command {

UpdateColorMap .top76.fra35.but41 6} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but41" "Button562" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but42 \
        -background #980000 \
        -command {

UpdateColorMap .top76.fra35.but42 7} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but42" "Button563" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but43 \
        -background #9c0000 \
        -command {

UpdateColorMap .top76.fra35.but43 8} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but43" "Button564" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but44 \
        -background #a00000 \
        -command {

UpdateColorMap .top76.fra35.but44 9} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but44" "Button565" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but45 \
        -background #a40000 \
        -command {

UpdateColorMap .top76.fra35.but45 10} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but45" "Button566" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but46 \
        -background #a80000 \
        -command {

UpdateColorMap .top76.fra35.but46 11} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but46" "Button567" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but47 \
        -background #ac0000 \
        -command {

UpdateColorMap .top76.fra35.but47 12} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but47" "Button568" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but48 \
        -background #b00000 \
        -command {

UpdateColorMap .top76.fra35.but48 13} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but48" "Button569" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but49 \
        -background #b40000 \
        -command {

UpdateColorMap .top76.fra35.but49 14} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but49" "Button570" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but50 \
        -background #b80000 \
        -command {

UpdateColorMap .top76.fra35.but50 15} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but50" "Button571" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but51 \
        -background #bc0000 \
        -command {

UpdateColorMap .top76.fra35.but51 16} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but51" "Button572" vTcl:WidgetProc "Toplevel76" 1
    button $site_3_0.but70 \
        -background #c00000 \
        -command {

UpdateColorMap .top76.fra35.but70 17} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but71 \
        -background #c40000 \
        -command {

UpdateColorMap .top76.fra35.but71 18} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but72 \
        -background #c80000 \
        -command {

UpdateColorMap .top76.fra35.but72 19} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but73 \
        -background #cc0000 \
        -command {

UpdateColorMap .top76.fra35.but73 20} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but74 \
        -background #d00000 \
        -command {

UpdateColorMap .top76.fra35.but74 21} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but75 \
        -background #d40000 \
        -command {

UpdateColorMap .top76.fra35.but75 22} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but76 \
        -background #d80000 \
        -command {

UpdateColorMap .top76.fra35.but76 23} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but77 \
        -background #dc0000 \
        -command {

UpdateColorMap .top76.fra35.but77 24} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but78 \
        -background #e00000 \
        -command {

UpdateColorMap .top76.fra35.but78 25} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but79 \
        -background #e40000 \
        -command {

UpdateColorMap .top76.fra35.but79 26} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but80 \
        -background #e80000 \
        -command {

UpdateColorMap .top76.fra35.but80 27} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but83 \
        -background #ec0000 \
        -command {

UpdateColorMap .top76.fra35.but83 28} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but84 \
        -background #f00000 \
        -command {

UpdateColorMap .top76.fra35.but84 29} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but85 \
        -background #f40000 \
        -command {

UpdateColorMap .top76.fra35.but85 30} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but86 \
        -background #f80000 \
        -command {

UpdateColorMap .top76.fra35.but86 31} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but87 \
        -background #fc0000 \
        -command {

UpdateColorMap .top76.fra35.but87 32} \
        -padx 0 -pady 0 -text {  } 
    button $site_3_0.but36 \
        -background #800000 \
        -command {

UpdateColorMap .top76.fra35.but36 33} \
        -padx 0 -pady 0 -text {  } 
    vTcl:DefineAlias "$site_3_0.but36" "Button557" vTcl:WidgetProc "Toplevel76" 1
    pack $site_3_0.but37 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but38 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but39 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but40 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but41 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but42 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but43 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but44 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but45 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but46 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but47 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but48 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but49 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but50 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but51 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but83 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but84 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but85 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but87 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but36 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra35 \
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
Window show .top76

main $argc $argv
