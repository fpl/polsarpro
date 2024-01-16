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

        {{[file join . GUI Images help.gif]} {user image} user {}}
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
    set base .top359
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.cpd72 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit67 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.tit68 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd79 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.tit68 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-text 1}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra36 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra36
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m66 {
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
            vTclWindow.top359
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

proc vTclWindow.top359 {base} {
    if {$base == ""} {
        set base .top359
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m66" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x250+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Read GEARTH_POLY File"
    vTcl:DefineAlias "$top" "Toplevel359" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame2" vTcl:WidgetProc "Toplevel359" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input  GEARTH_POLY File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel359" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable GoogleInputFile 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel359" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel359" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd72 \
        \
        -command {global DataDir FileName BMPDirInput GoogleInputFile OpenDirFile
global VarError ErrorMessage

if {$OpenDirFile == 0} {

set GoogleInputFile ""
$widget(Button359_1) configure -state disable

if {"$BMPDirInput"==""} { set BMPDirInput $DataDir }
set types {
    {{KML Files}        {.kml}        }
    }
set FileName ""
OpenFile $BMPDirInput $types "INPUT KML FILE"

if {$FileName != ""} {
    set GoogleInputFile [file tail $FileName]
    if {$GoogleInputFile != "GEARTH_POLY.kml"} {
        $widget(Button359_1) configure -state disable
        set VarError ""
        set ErrorMessage "INVALID INPUT GEARTH_POLY FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set GoogleInputFile ""
        } else {
        set GoogleInputFile $FileName
        $widget(Button359_1) configure -state normal
        }
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd72 "$site_6_0.cpd72 Button $top all _vTclBalloon"
    bind $site_6_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    button $top.cpd80 \
        -background #ffff00 \
        -command {global OpenDirFile GoogleInputFile TMPGoogle
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN

if {$OpenDirFile == 0} {

DeleteFile $TMPGoogle

if {$GoogleInputFile != ""} {
    TextEditorRunTrace "Process The Function Soft/bin/data_import/read_gearth_poly.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$GoogleInputFile\x22 -of \x22$TMPGoogle\x22" "k"
    set f [ open "| Soft/bin/data_import/read_gearth_poly.exe -if \x22$GoogleInputFile\x22 -of \x22$TMPGoogle\x22" r]
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
    }
}} \
        -padx 4 -pady 2 -text Extract 
    vTcl:DefineAlias "$top.cpd80" "Button359_1" vTcl:WidgetProc "Toplevel359" 1
    bindtags $top.cpd80 "$top.cpd80 Button $top all _vTclBalloon"
    bind $top.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read GEARTH_POLY File}
    }
    TitleFrame $top.tit67 \
        -text {Latitude ( deg )} 
    vTcl:DefineAlias "$top.tit67" "TitleFrame1" vTcl:WidgetProc "Toplevel359" 1
    bind $top.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit67 getframe]
    TitleFrame $site_4_0.tit68 \
        -text Center 
    vTcl:DefineAlias "$site_4_0.tit68" "TitleFrame2" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLatCenter -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry1" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd74 \
        -text Top-Left 
    vTcl:DefineAlias "$site_4_0.cpd74" "TitleFrame3" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLat00 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry2" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd75 \
        -text Top-Right 
    vTcl:DefineAlias "$site_4_0.cpd75" "TitleFrame4" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLat0N -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry3" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd76 \
        -text Bottom-Left 
    vTcl:DefineAlias "$site_4_0.cpd76" "TitleFrame7" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLatN0 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry4" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd77 \
        -text Bottom-Right 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame8" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLatNN -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry5" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.tit68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd79 \
        -text {Longitude ( deg )} 
    vTcl:DefineAlias "$top.cpd79" "TitleFrame9" vTcl:WidgetProc "Toplevel359" 1
    bind $top.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd79 getframe]
    TitleFrame $site_4_0.tit68 \
        -text Center 
    vTcl:DefineAlias "$site_4_0.tit68" "TitleFrame10" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.tit68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.tit68 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLongCenter -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry10" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd74 \
        -text Top-Left 
    vTcl:DefineAlias "$site_4_0.cpd74" "TitleFrame11" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLong00 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry11" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd75 \
        -text Top-Right 
    vTcl:DefineAlias "$site_4_0.cpd75" "TitleFrame12" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd75 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLong0N -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry12" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd76 \
        -text Bottom-Left 
    vTcl:DefineAlias "$site_4_0.cpd76" "TitleFrame13" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd76 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLongN0 -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry13" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd77 \
        -text Bottom-Right 
    vTcl:DefineAlias "$site_4_0.cpd77" "TitleFrame14" vTcl:WidgetProc "Toplevel359" 1
    bind $site_4_0.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd77 getframe]
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable GoogleLongNN -width 10 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry14" vTcl:WidgetProc "Toplevel359" 1
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.tit68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra36 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra36" "Frame20" vTcl:WidgetProc "Toplevel359" 1
    set site_3_0 $top.fra36
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel359); TextEditorRunTrace "Close Window Read GEARTH_POLY File" "b"
}} \
        -cursor {} -padx 4 -pady 2 -text {Save & Exit} 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel359" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ReadGEARTH_POLY.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel359" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN GoogleInputFile

if {$OpenDirFile == 0} {
set GoogleLatCenter "?"
set GoogleLongCenter "?"
set GoogleLat00 "?"
set GoogleLong00 "?"
set GoogleLat0N "?"
set GoogleLong0N "?"
set GoogleLatN0 "?"
set GoogleLongN0 "?"
set GoogleLatNN "?"
set GoogleLongNN "?"
set GoogleInputFile ""
Window hide $widget(Toplevel359); TextEditorRunTrace "Close Window Read GEARTH_POLY File" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel359" 1
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
    menu $top.m66 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.tit67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra36 \
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
Window show .top359

main $argc $argv
