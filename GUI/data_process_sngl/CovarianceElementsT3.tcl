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
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top42
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd86 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd86
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd88 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd86
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra43 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra43
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
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
    namespace eval ::widgets::$base.fra45 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra45
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra46 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra46
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra47 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra47
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra52 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra52
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra54 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra54
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra58 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra58
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra78
    namespace eval ::widgets::$site_3_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra60 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra60
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
            vTclWindow.top42
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top42 {base} {
    if {$base == ""} {
        set base .top42
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
    wm geometry $top 500x370+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Coherency Elements T3"
    vTcl:DefineAlias "$top" "Toplevel42" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd86 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd86" "Frame3" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.cpd86
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel42" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CohDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel42" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel42" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button38" vTcl:WidgetProc "Toplevel42" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel42" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable CohOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel42" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel42" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd89 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd89" "Label14" vTcl:WidgetProc "Toplevel42" 1
    entry $site_6_0.cpd88 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CohOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd88" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel42" 1
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd88 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd86" "Frame15" vTcl:WidgetProc "Toplevel42" 1
    set site_6_0 $site_5_0.cpd86
    button $site_6_0.cpd97 \
        \
        -command {global DirName DataDir CohOutputDir

set CohDirOutputTmp $CohOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set CohOutputDir $DirName
    } else {
    set CohOutputDir $CohDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd97" "Button62" vTcl:WidgetProc "Toplevel42" 1
    bindtags $site_6_0.cpd97 "$site_6_0.cpd97 Button $top all _vTclBalloon"
    bind $site_6_0.cpd97 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra43 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra43" "Frame9" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra43
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel42" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel42" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel42" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel42" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel42" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel42" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel42" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel42" 1
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
    frame $top.fra45 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra45" "Frame24" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra45
    label $site_3_0.lab47 \
        -text T11 
    vTcl:DefineAlias "$site_3_0.lab47" "Label26" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_1) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable T3toT11 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton4" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_1) configure -state normal} \
        -text 10log(Modulus) -value db -variable T3toT11 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton5" vTcl:WidgetProc "Toplevel42" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPT3toT11 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_1" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra46 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra46" "Frame25" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra46
    label $site_3_0.lab47 \
        -text T12 
    vTcl:DefineAlias "$site_3_0.lab47" "Label27" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_2) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable T3toT12 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton7" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_2) configure -state normal} \
        -text 10log(Modulus) -value db -variable T3toT12 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton8" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton42_2) configure -state normal} -padx 1 \
        -text Phase -value pha -variable T3toT12 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton9" vTcl:WidgetProc "Toplevel42" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPT3toT12 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_2" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra47 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra47" "Frame27" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra47
    label $site_3_0.lab47 \
        -text T13 
    vTcl:DefineAlias "$site_3_0.lab47" "Label29" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_3) configure -state normal} \
        -text Modulus -value mod -variable T3toT13 
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_3) configure -state normal} \
        -text 10log(Modulus) -value db -variable T3toT13 
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton42_3) configure -state normal} -padx 1 \
        -text Phase -value pha -variable T3toT13 
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPT3toT13 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_3" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra51 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame28" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra51
    label $site_3_0.lab47 \
        -text T22 
    vTcl:DefineAlias "$site_3_0.lab47" "Label30" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_4) configure -state normal} \
        -text Modulus -value mod -variable T3toT22 
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_4) configure -state normal} -padx 1 \
        -text 10log(Modulus) -value db -variable T3toT22 
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPT3toT22 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_4" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra52 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra52" "Frame29" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra52
    label $site_3_0.lab47 \
        -text T23 
    vTcl:DefineAlias "$site_3_0.lab47" "Label31" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_5) configure -state normal} \
        -text Modulus -value mod -variable T3toT23 
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_5) configure -state normal} \
        -text 10log(Modulus) -value db -variable T3toT23 
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton42_5) configure -state normal} -padx 1 \
        -text Phase -value pha -variable T3toT23 
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPT3toT23 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_5" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra54 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra54" "Frame30" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra54
    label $site_3_0.lab47 \
        -text T33 
    vTcl:DefineAlias "$site_3_0.lab47" "Label32" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_6) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable T3toT33 
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_6) configure -state normal} -padx 1 \
        -text 10log(Modulus) -value db -variable T3toT33 
    checkbutton $site_3_0.che51 \
        -command {} -padx 1 -text BMP -variable BMPT3toT33 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_6" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra58 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra58" "Frame32" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra58
    label $site_3_0.lab47 \
        -text Span 
    vTcl:DefineAlias "$site_3_0.lab47" "Label33" vTcl:WidgetProc "Toplevel42" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton42_7) configure -state normal} -padx 1 \
        -text Linear -value lin -variable T3toSpan 
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton42_7) configure -state normal} -padx 1 \
        -text {DeciBel = 10log(Span)} -value db -variable T3toSpan 
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPT3toSpan 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton42_7" vTcl:WidgetProc "Toplevel42" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 25 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra78" "Frame1" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra78
    button $site_3_0.cpd79 \
        -background #ffff00 \
        -command {set T3toT11 "db"
set T3toT12 "db"
set T3toT13 "db"
set T3toT22 "db"
set T3toT23 "db"
set T3toT33 "db"
set T3toSpan "db"
set BMPT3toT11 "1"
set BMPT3toT12 "1"
set BMPT3toT13 "1"
set BMPT3toT22 "1"
set BMPT3toT23 "1"
set BMPT3toT33 "1"
set BMPT3toSpan "1"
$widget(Checkbutton42_1) configure -state normal
$widget(Checkbutton42_2) configure -state normal
$widget(Checkbutton42_3) configure -state normal
$widget(Checkbutton42_4) configure -state normal
$widget(Checkbutton42_5) configure -state normal
$widget(Checkbutton42_6) configure -state normal
$widget(Checkbutton42_7) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    bindtags $site_3_0.cpd79 "$site_3_0.cpd79 Button $top all _vTclBalloon"
    bind $site_3_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd80 \
        -background #ffff00 \
        -command {set T3toT11 " "
set T3toT12 " "
set T3toT13 " "
set T3toT22 " "
set T3toT23 " "
set T3toT33 " "
set T3toSpan " "
set BMPT3toT11 " "
set BMPT3toT12 " "
set BMPT3toT13 " "
set BMPT3toT22 " "
set BMPT3toT23 " "
set BMPT3toT33 " "
set BMPT3toSpan " "
$widget(Checkbutton42_1) configure -state disable
$widget(Checkbutton42_2) configure -state disable
$widget(Checkbutton42_3) configure -state disable
$widget(Checkbutton42_4) configure -state disable
$widget(Checkbutton42_5) configure -state disable
$widget(Checkbutton42_6) configure -state disable
$widget(Checkbutton42_7) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    bindtags $site_3_0.cpd80 "$site_3_0.cpd80 Button $top all _vTclBalloon"
    bind $site_3_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.cpd79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra60 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra60" "Frame20" vTcl:WidgetProc "Toplevel42" 1
    set site_3_0 $top.fra60
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global CohDirInput CohDirOutput CohOutputDir CohOutputSubDir
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global BMPDirInput OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set CohDirOutput $CohOutputDir
if {$CohOutputSubDir != ""} {append CohDirOutput "/$CohOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set CohDirOutput [PSPCreateDirectoryMask $CohDirOutput $CohOutputDir $CohDirInput]
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
    TestVar 4
    if {$TestVarError == "ok"} {

    if {"$T3toT11"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CohDirOutput/T11_$T3toT11.bin"
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 11 -fmt $T3toT11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_elements.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 11 -fmt $T3toT11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CohDirOutput/T11_$T3toT11.bin" $FinalNlig $FinalNcol 4
        if {"$BMPT3toT11"=="1"} {
            if {"$T3toT11"=="mod"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T11_mod.bin"
                set BMPFileOutput "$CohDirOutput/T11_mod.bmp"
                }
            if {"$T3toT11"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T11_db.bin"
                set BMPFileOutput "$CohDirOutput/T11_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$T3toT12"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CohDirOutput/T12_$T3toT12.bin"
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 12 -fmt $T3toT12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_elements.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 12 -fmt $T3toT12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CohDirOutput/T12_$T3toT12.bin" $FinalNlig $FinalNcol 4
        if {"$BMPT3toT12"=="1"} {
            if {"$T3toT12"=="mod"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T12_mod.bin"
                set BMPFileOutput "$CohDirOutput/T12_mod.bmp"
                }
            if {"$T3toT12"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T12_db.bin"
                set BMPFileOutput "$CohDirOutput/T12_db.bmp"
                }
            if {"$T3toT12"=="pha"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T12_pha.bin"
                set BMPFileOutput "$CohDirOutput/T12_pha.bmp"
                }
            if {"$T3toT12"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
        
    if {"$T3toT13"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CohDirOutput/T13_$T3toT13.bin"
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 13 -fmt $T3toT13 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_elements.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 13 -fmt $T3toT13 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CohDirOutput/T13_$T3toT13.bin" $FinalNlig $FinalNcol 4
        if {"$BMPT3toT13"=="1"} {
            if {"$T3toT13"=="mod"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T13_mod.bin"
                set BMPFileOutput "$CohDirOutput/T13_mod.bmp"
                }
            if {"$T3toT13"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T13_db.bin"
                set BMPFileOutput "$CohDirOutput/T13_db.bmp"
                }
            if {"$T3toT13"=="pha"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T13_pha.bin"
                set BMPFileOutput "$CohDirOutput/T13_pha.bmp"
                }
            if {"$T3toT13"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
        
    if {"$T3toT22"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CohDirOutput/T22_$T3toT22.bin"
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 22 -fmt $T3toT22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_elements.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 22 -fmt $T3toT22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CohDirOutput/T22_$T3toT22.bin" $FinalNlig $FinalNcol 4
        if {"$BMPT3toT22"=="1"} {
            if {"$T3toT22"=="mod"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T22_mod.bin"
                set BMPFileOutput "$CohDirOutput/T22_mod.bmp"
                }
            if {"$T3toT22"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T22_db.bin"
                set BMPFileOutput "$CohDirOutput/T22_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$T3toT23"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CohDirOutput/T23_$T3toT23.bin"
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 23 -fmt $T3toT23 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_elements.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 23 -fmt $T3toT23 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CohDirOutput/T23_$T3toT23.bin" $FinalNlig $FinalNcol 4
        if {"$BMPT3toT23"=="1"} {
            if {"$T3toT23"=="mod"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T23_mod.bin"
                set BMPFileOutput "$CohDirOutput/T23_mod.bmp"
                }
            if {"$T3toT23"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T23_db.bin"
                set BMPFileOutput "$CohDirOutput/T23_db.bmp"
                }
            if {"$T3toT23"=="pha"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T23_pha.bin"
                set BMPFileOutput "$CohDirOutput/T23_pha.bmp"
                }
            if {"$T3toT23"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0  $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }

    if {"$T3toT33"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CohDirOutput/T33_$T3toT33.bin"
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 33 -fmt $T3toT33 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_elements.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -elt 33 -fmt $T3toT33 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CohDirOutput/T33_$T3toT33.bin" $FinalNlig $FinalNcol 4
        if {"$BMPT3toT33"=="1"} {
            if {"$T3toT33"=="mod"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T33_mod.bin"
                set BMPFileOutput "$CohDirOutput/T33_mod.bmp"
                }
            if {"$T3toT33"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/T33_db.bin"
                set BMPFileOutput "$CohDirOutput/T33_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$T3toSpan"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$T3toSpan"=="lin"} {
            set Fonction2 "$CohDirOutput/span.bin"
            }
        if {"$T3toSpan"=="db"} {
            set Fonction2 "$CohDirOutput/span_db.bin"
            }
        set MaskCmd ""
        set MaskFile "$CohDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -fmt $T3toSpan -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/process_span.exe -id \x22$CohDirInput\x22 -od \x22$CohDirOutput\x22 -iodf T3 -fmt $T3toSpan -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$T3toSpan" == "lin"} {EnviWriteConfig "$CohDirOutput/span.bin" $FinalNlig $FinalNcol 4}
        if {"$T3toSpan" == "db"} {EnviWriteConfig "$CohDirOutput/span_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPT3toSpan"=="1"} {
            if {"$T3toSpan"=="lin"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/span.bin"
                set BMPFileOutput "$CohDirOutput/span.bmp"
                }
            if {"$T3toSpan"=="db"} {
                set BMPDirInput $CohDirOutput
                set BMPFileInput "$CohDirOutput/span_db.bin"
                set BMPFileOutput "$CohDirOutput/span_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel42); TextEditorRunTrace "Close Window Covariance Elements T3" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel42" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CovarianceElementsT3.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel42" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel42); TextEditorRunTrace "Close Window Covariance Elements T3" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel42" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit  the Function}
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
    pack $top.cpd86 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra43 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra45 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra46 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra47 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra51 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra52 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra54 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra58 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra78 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra60 \
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
Window show .top42

main $argc $argv
