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
# Visual Tcl v8.6.0.5 Project
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
        .gif -
	.png	{return photo}
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

        {{[file join . GUI Images RADARSATRCM.gif]} {user image} user {}}
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
    set base .top468
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.cpd79
    set site_5_0 [$site_3_0.cpd97 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd92
    set site_4_0 [$base.cpd71 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_4_0 [$base.cpd72 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_4_0 [$base.tit66 getframe]
    set site_4_0 $site_4_0
    set site_3_0 $base.fra73
    set site_4_0 $site_3_0.fra44
    set site_4_0 $site_3_0.fra47
    set site_5_0 $site_4_0.cpd48
    set site_5_0 $site_4_0.fra53
    set site_6_0 $site_5_0.fra54
    set site_7_0 $site_6_0.cpd56
    set site_7_0 $site_6_0.cpd58
    set site_6_0 $site_5_0.cpd59
    set site_7_0 $site_6_0.cpd56
    set site_7_0 $site_6_0.cpd58
    set site_3_0 $base.cpd77
    set site_5_0 [$site_3_0.cpd98 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd91
    set site_5_0 [$site_3_0.cpd116 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd91
    set site_5_0 [$site_3_0.cpd117 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd91
    set site_5_0 [$site_3_0.cpd118 getframe]
    set site_5_0 $site_5_0
    set site_6_0 $site_5_0.cpd91
    set site_3_0 $base.fra76
    set site_3_0 $base.fra71
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top468
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
    wm geometry $top 200x200+26+26; update
    wm maxsize $top 1924 1061
    wm minsize $top 120 1
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

proc vTclWindow.top468 {base} {
    if {$base == ""} {
        set base .top468
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
    wm geometry $top 500x647+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "RADARSATRCM Input Data File"
    vTcl:DefineAlias "$top" "Toplevel468" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
		\
		-image [vTcl:image:get_image [file join . GUI Images RADARSATRCM.gif]] \
		-text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel468" 1
    frame $top.cpd79 \
		-height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel468" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
		-ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel468" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable RADARSATRCMDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel468" 1
    frame $site_5_0.cpd92 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
		\
		-image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
		-pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$top.cpd71" "TitleFrame468" vTcl:WidgetProc "Toplevel468" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} \
		-textvariable RADARSATRCMDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry468" vTcl:WidgetProc "Toplevel468" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel468" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global DirName DataDir RADARSATRCMDirOutput
global VarWarning WarningMessage WarningMessage2

set RADARSATRCMOutputDirTmp $RADARSATRCMDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set RADARSATRCMDirOutput $DirName
        } else {
        set RADARSATRCMDirOutput $RADARSATRCMOutputDirTmp
        }
    } else {
    set RADARSATRCMDirOutput $RADARSATRCMOutputDirTmp
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button468" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$top.cpd72" "TitleFrame220" vTcl:WidgetProc "Toplevel468" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable RADARSATRCMProductFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry220" vTcl:WidgetProc "Toplevel468" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame30" vTcl:WidgetProc "Toplevel468" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global FileName RADARSATRCMDirInput RADARSATRCMProductFile

set types {
    {{XML Files}        {.xml}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile "$RADARSATRCMDirInput/metadata" $types "SAR PRODUCT FILE"
set RADARSATRCMProductFile $FileName} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button220" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$top.tit66" "TitleFrame1" vTcl:WidgetProc "Toplevel468" 1
    bind $top.tit66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit66 getframe]
    radiobutton $site_4_0.cpd68 \
		-text Beta-Nought -value beta -variable RADARSATRCMLut 
    vTcl:DefineAlias "$site_4_0.cpd68" "Radiobutton2" vTcl:WidgetProc "Toplevel468" 1
    radiobutton $site_4_0.cpd69 \
		-text Gamma-Nought -value gamma -variable RADARSATRCMLut 
    vTcl:DefineAlias "$site_4_0.cpd69" "Radiobutton3" vTcl:WidgetProc "Toplevel468" 1
    radiobutton $site_4_0.rad67 \
		-text Sigma-Nought -value sigma -variable RADARSATRCMLut 
    vTcl:DefineAlias "$site_4_0.rad67" "Radiobutton1" vTcl:WidgetProc "Toplevel468" 1
    pack $site_4_0.cpd68 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad67 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra73 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel468" 1
    set site_3_0 $top.fra73
    frame $site_3_0.fra44 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra44" "Frame2" vTcl:WidgetProc "Toplevel468" 1
    set site_4_0 $site_3_0.fra44
    button $site_4_0.cpd45 \
		-background {#ffff00} \
		-command {global RADARSATRCMDirInput RADARSATRCMDirOutput RADARSATRCMFileInputFlag
global RADARSATRCMDataFormat RADARSATRCMDataLevel RADARSATRCMProductFile
global RADARSATRCMLut RADARSATRCMLutFile1 RADARSATRCMLutFile2 RADARSATRCMLutFile3 RADARSATRCMLutFile4
global RADARSATRCMProductId RADARSATRCMSatellite RADARSATRCMBeams RADARSATRCMLevelData
global RADARSATRCMAntenna RADARSATRCMPass RADARSATRCMDataType RADARSATRCMAntennaPass
global RADARSATRCMResRg RADARSATRCMResAz RADARSATRCMNLig RADARSATRCMNcol RADARSATRCMIncAngNear RADARSATRCMIncAngFar
global FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPRadarsatRCMConfig TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

set datalevelerror 0
#####################################################################
#Create Directory
set RADARSATRCMDirOutput [PSPCreateDirectoryMask $RADARSATRCMDirOutput $RADARSATRCMDirOutput $RADARSATRCMDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPRadarsatRCMConfig
DeleteFile $TMPGoogle

if [file exists $RADARSATRCMProductFile] {
    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_header.txt"
    set Sensor "radarsatrcm"
    ReadXML $RADARSATRCMProductFile $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
    WaitUntilCreated $TMPRadarsatRCMConfig
    if [file exists $TMPRadarsatRCMConfig] {
        set f [open $TMPRadarsatRCMConfig r]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        gets $f RADARSATRCMLevelDataTmp
        gets $f tmp
        gets $f tmp
        gets $f RADARSATRCMDataType
        close $f
        if {$RADARSATRCMDataType == "Complex" } {

            set RADARSATRCMDataLevel "quad"; set PolarType "full"
            if {$RADARSATRCMLevelDataTmp == "HH HV" } { set RADARSATRCMDataLevel "dual"; set PolarType "pp1" }
            if {$RADARSATRCMLevelDataTmp == "HV HH" } { set RADARSATRCMDataLevel "dual"; set PolarType "pp1" }
            if {$RADARSATRCMLevelDataTmp == "VH VV" } { set RADARSATRCMDataLevel "dual"; set PolarType "pp2" }
            if {$RADARSATRCMLevelDataTmp == "VV VH" } { set RADARSATRCMDataLevel "dual"; set PolarType "pp2" }
            if {$RADARSATRCMLevelDataTmp == "HH VV" } { set RADARSATRCMDataLevel "dual"; set PolarType "pp3" }
            if {$RADARSATRCMLevelDataTmp == "VV HH" } { set RADARSATRCMDataLevel "dual"; set PolarType "pp3" }
            if {$RADARSATRCMLevelDataTmp == "CH CV" } { set RADARSATRCMDataLevel "compact"; set PolarType "pp1" }

            if {$RADARSATRCMDataFormat == $RADARSATRCMDataLevel } {

                set f [open $TMPRadarsatRCMConfig r]
                gets $f RADARSATRCMProductId
                gets $f RADARSATRCMSatellite
                gets $f RADARSATRCMBeams
                gets $f RADARSATRCMLevelData
                gets $f RADARSATRCMAntenna
                gets $f RADARSATRCMPass
                gets $f RADARSATRCMDataType
                gets $f RADARSATRCMResRg
                gets $f RADARSATRCMResAz
                gets $f RADARSATRCMNLig
                gets $f RADARSATRCMNcol
                gets $f RADARSATRCMIncAngNear
                gets $f RADARSATRCMIncAngFar
                close $f

                set RADARSATRCMResRg [expr round($RADARSATRCMResRg * 1000.0) / 1000.0]
                set RADARSATRCMResAz [expr round($RADARSATRCMResAz * 1000.0) / 1000.0]
                set RADARSATRCMIncAngNear [expr round($RADARSATRCMIncAngNear * 1000.0) / 1000.0]
                set RADARSATRCMIncAngFar [expr round($RADARSATRCMIncAngFar * 1000.0) / 1000.0]

                $widget(Label468_10) configure -state normal; $widget(Entry468_10) configure -disabledbackground #FFFFFF
                $widget(Label468_11) configure -state normal; $widget(Entry468_11) configure -disabledbackground #FFFFFF
                $widget(Label468_12) configure -state normal; $widget(Entry468_12) configure -disabledbackground #FFFFFF
                $widget(Label468_13) configure -state normal; $widget(Entry468_13) configure -disabledbackground #FFFFFF
                $widget(Label468_14) configure -state normal; $widget(Entry468_14) configure -disabledbackground #FFFFFF
                $widget(Label468_15) configure -state normal; $widget(Entry468_15) configure -disabledbackground #FFFFFF
                $widget(Label468_16) configure -state normal; $widget(Entry468_16) configure -disabledbackground #FFFFFF

                if {$RADARSATRCMPass == "Ascending" } { set RADARSATRCMAntennaPass "A" } else { set RADARSATRCMAntennaPass "D" }
                if {$RADARSATRCMAntenna == "Right" } { append RADARSATRCMAntennaPass "R" } else { append RADARSATRCMAntennaPass "L" }
                set f [open "$RADARSATRCMDirOutput/config_acquisition.txt" w]
                puts $f $RADARSATRCMAntennaPass
                puts $f [expr ($RADARSATRCMIncAngNear + $RADARSATRCMIncAngFar) / 2 ]
                puts $f $RADARSATRCMResRg
                puts $f $RADARSATRCMResAz
                close $f

                set FileInputData "$RADARSATRCMDirInput/imagery/"; append FileInputData $RADARSATRCMProductId
                set FileInputLut "$RADARSATRCMDirInput/metadata/calibration/"
                if {$RADARSATRCMLut == "beta"} { append FileInputLut "lutBeta" }
                if {$RADARSATRCMLut == "gamma"} { append FileInputLut "lutGamma" }
                if {$RADARSATRCMLut == "sigma"} { append FileInputLut "lutSigma" }
                $widget(Label468_10) configure -state normal; $widget(Entry468_10) configure -disabledbackground #FFFFFF
                if {$RADARSATRCMDataLevel == "quad" } {
                    $widget(Entry468_1) configure -disabledbackground #FFFFFF; $widget(Button468_1) configure -state normal
                    $widget(TitleFrame468_1) configure -text "Input Data File (s11)"
                    set FileInput $FileInputData; append FileInput "_HH.tif"
                    if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                    DeleteFile $TMPRadarsatRCMConfig
                    set RADARSATRCMLutFile1 $FileInputLut; append RADARSATRCMLutFile1 "_HH.xml"
                    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_HH.txt"
                    set Sensor "radarsatrcm"
                    ReadXML $RADARSATRCMLutFile1 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                    $widget(Entry468_2) configure -disabledbackground #FFFFFF; $widget(Button468_2) configure -state normal
                    $widget(TitleFrame468_2) configure -text "Input Data File (s12)"
                    set FileInput $FileInputData; append FileInput "_HV.tif"
                    if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                    DeleteFile $TMPRadarsatRCMConfig
                    set RADARSATRCMLutFile2 $FileInputLut; append RADARSATRCMLutFile2 "_HV.xml"
                    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_HV.txt"
                    set Sensor "radarsatrcm"
                    ReadXML $RADARSATRCMLutFile2 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                    $widget(Entry468_3) configure -disabledbackground #FFFFFF; $widget(Button468_3) configure -state normal
                    $widget(TitleFrame468_3) configure -text "Input Data File (s21)"
                    set FileInput $FileInputData; append FileInput "_VH.tif"
                    if [file exists $FileInput] {set FileInput3 $FileInput } else { set FileInput3 "" }
                    DeleteFile $TMPRadarsatRCMConfig
                    set RADARSATRCMLutFile3 $FileInputLut; append RADARSATRCMLutFile3 "_VH.xml"
                    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_VH.txt"
                    set Sensor "radarsatrcm"
                    ReadXML $RADARSATRCMLutFile3 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                    $widget(Entry468_4) configure -disabledbackground #FFFFFF; $widget(Button468_4) configure -state normal
                    $widget(TitleFrame468_4) configure -text "Input Data File (s22)"
                    set FileInput $FileInputData; append FileInput "_VV.tif"
                    if [file exists $FileInput] {set FileInput4 $FileInput } else { set FileInput4 "" }
                    DeleteFile $TMPRadarsatRCMConfig
                    set RADARSATRCMLutFile4 $FileInputLut; append RADARSATRCMLutFile4 "_VV.xml"
                    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_VV.txt"
                    set Sensor "radarsatrcm"
                    ReadXML $RADARSATRCMLutFile4 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                    }
                if {$RADARSATRCMDataLevel == "dual" } {
                    if {$PolarType == "pp1" } { set channel1 "Channel1 = HH"; set channel2 "Channel2 = HV"}
                    if {$PolarType == "pp2" } { set channel1 "Channel1 = VV"; set channel2 "Channel2 = VH"}
                    if {$PolarType == "pp3" } { set channel1 "Channel1 = HH"; set channel2 "Channel2 = VV"}
                    $widget(Entry468_1) configure -disabledbackground #FFFFFF; $widget(Button468_1) configure -state normal
                    $widget(TitleFrame468_1) configure -text "Input Data File ($channel1)"
                    $widget(Entry468_2) configure -disabledbackground #FFFFFF; $widget(Button468_2) configure -state normal
                    $widget(TitleFrame468_2) configure -text "Input Data File ($channel2)"
                    $widget(Entry468_3) configure -disabledbackground $PSPBackgroundColor; $widget(Button468_3) configure -state disable
                    $widget(TitleFrame468_3) configure -text ""
                    $widget(Entry468_4) configure -disabledbackground $PSPBackgroundColor; $widget(Button468_4) configure -state disable
                    $widget(TitleFrame468_4) configure -text ""
                    if {$PolarType == "pp1" } {
                        set FileInput $FileInputData; append FileInput "_HH.tif"
                        if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                        DeleteFile $TMPRadarsatRCMConfig
                        set RADARSATRCMLutFile1 $FileInputLut; append RADARSATRCMLutFile1 "_HH.xml"
                        set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_HH.txt"
                        set Sensor "radarsatrcm"
                        ReadXML $RADARSATRCMLutFile1 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                        set FileInput $FileInputData; append FileInput "_HV.tif"
                        if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                        DeleteFile $TMPRadarsatRCMConfig
                        set RADARSATRCMLutFile2 $FileInputLut; append RADARSATRCMLutFile2 "_HV.xml"
                        set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_HV.txt"
                        set Sensor "radarsatrcm"
                        ReadXML $RADARSATRCMLutFile2 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                        }                        
                    if {$PolarType == "pp2" } {
                        set FileInput $FileInputData; append FileInput "_VV.tif"
                        if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                        DeleteFile $TMPRadarsatRCMConfig
                        set RADARSATRCMLutFile1 $FileInputLut; append RADARSATRCMLutFile1 "_VV.xml"
                        set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_VV.txt"
                        set Sensor "radarsatrcm"
                        ReadXML $RADARSATRCMLutFile1 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                        set FileInput $FileInputData; append FileInput "_VH.tif"
                        if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                        DeleteFile $TMPRadarsatRCMConfig
                        set RADARSATRCMLutFile2 $FileInputLut; append RADARSATRCMLutFile2 "_VH.xml"
                        set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_VH.txt"
                        set Sensor "radarsatrcm"
                        ReadXML $RADARSATRCMLutFile2 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                        }                        
                    if {$PolarType == "pp3" } {
                        set FileInput $FileInputData; append FileInput "_HH.tif"
                        if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                        DeleteFile $TMPRadarsatRCMConfig
                        set RADARSATRCMLutFile1 $FileInputLut; append RADARSATRCMLutFile1 "_HH.xml"
                        set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_HH.txt"
                        set Sensor "radarsatrcm"
                        ReadXML $RADARSATRCMLutFile1 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                        set FileInput $FileInputData; append FileInput "_VV.tif"
                        if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                        DeleteFile $TMPRadarsatRCMConfig
                        set RADARSATRCMLutFile2 $FileInputLut; append RADARSATRCMLutFile2 "_VV.xml"
                        set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_VV.txt"
                        set Sensor "radarsatrcm"
                        ReadXML $RADARSATRCMLutFile2 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                        }                        
                    }
                if {$RADARSATRCMDataLevel == "compact" } {
                    set channel1 "Channel1 = CH"; set channel2 "Channel2 = CV"
                    $widget(Entry468_1) configure -disabledbackground #FFFFFF; $widget(Button468_1) configure -state normal
                    $widget(TitleFrame468_1) configure -text "Input Data File ($channel1)"
                    $widget(Entry468_2) configure -disabledbackground #FFFFFF; $widget(Button468_2) configure -state normal
                    $widget(TitleFrame468_2) configure -text "Input Data File ($channel2)"
                    $widget(Entry468_3) configure -disabledbackground $PSPBackgroundColor; $widget(Button468_3) configure -state disable
                    $widget(TitleFrame468_3) configure -text ""
                    $widget(Entry468_4) configure -disabledbackground $PSPBackgroundColor; $widget(Button468_4) configure -state disable
                    $widget(TitleFrame468_4) configure -text ""
                    set FileInput $FileInputData; append FileInput "_CH.tif"
                    if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "" }
                    DeleteFile $TMPRadarsatRCMConfig
                    set RADARSATRCMLutFile1 $FileInputLut; append RADARSATRCMLutFile1 "_CH.xml"
                    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_CH.txt"
                    set Sensor "radarsatrcm"
                    ReadXML $RADARSATRCMLutFile1 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                    set FileInput $FileInputData; append FileInput "_CV.tif"
                    if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "" }
                    DeleteFile $TMPRadarsatRCMConfig
                    set RADARSATRCMLutFile2 $FileInputLut; append RADARSATRCMLutFile2 "_CV.xml"
                    set RADARSATRCMFile "$RADARSATRCMDirOutput/product_lut_CV.txt"
                    set Sensor "radarsatrcm"
                    ReadXML $RADARSATRCMLutFile2 $RADARSATRCMFile $TMPRadarsatRCMConfig $Sensor
                    }
                $widget(Button468_6) configure -state normal
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_google.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -of \x22$TMPGoogle\x22" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_google.exe -id \x22$RADARSATRCMDirOutput\x22 -of \x22$TMPGoogle\x22" r]
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
                $widget(Button468_7) configure -state normal
                } else {
                set ErrorMessage "ERROR IN THE RADARSAT-RCM DATA FORMAT (DUAL - COMPACT - QUAD)"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set RADARSATRCMDataLevel ""; set RADARSATRCMProductFile ""; set RADARSATRCMFileInputFlag 0
                set datalevelerror 1
                }
            } else {
            set ErrorMessage "ERROR IN THE RADARSAT-RCM DATA TYPE (SLC - Complex)"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set RADARSATRCMDataLevel ""; set RADARSATRCMProductFile ""; set RADARSATRCMFileInputFlag 0
            set datalevelerror 2
            }
        } else {
        set ErrorMessage "PRODUCT FILE IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set RADARSATRCMDataLevel ""; set RADARSATRCMProductFile ""
        }
        #TMPRADARSATRCMConfig Exists
    } else {
    set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RADARSATRCMDataLevel ""; set RADARSATRCMProductFile ""; set RADARSATRCMFileInputFlag 0
    }
    #ProductFile Exists

if {$datalevelerror == 1 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    if {$RADARSATRCMDataFormat == "quad" } { 
        TextEditorRunTrace "Close EO-SI" "b"
        set RADARSATRCMDataFormat "dual" 
        } else {
        TextEditorRunTrace "Close EO-SI Dual Pol" "b"
        set RADARSATRCMDataFormat "quad"
        }
    Window hide $widget(Toplevel468); TextEditorRunTrace "Close Window RADARSATRCM Input File" "b"
    }
if {$datalevelerror == 2 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    Window hide $widget(Toplevel468); TextEditorRunTrace "Close Window RADARSATRCM Input File" "b"
    }
}
#VarWarning
}
#OpenDirFile} \
		-padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_4_0.cpd45" "Button2" vTcl:WidgetProc "Toplevel468" 1
    button $site_4_0.cpd46 \
		\
		-command {global FileName VarError ErrorMessage RADARSATRCMDirInput

set RADARSATRCMFile "$RADARSATRCMDirInput/GEARTH_POLY.kml"
if [file exists $RADARSATRCMFile] {
    GoogleEarth $RADARSATRCMFile
    }} \
		-image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
		-padx 4 -pady 2 -text Google 
    vTcl:DefineAlias "$site_4_0.cpd46" "Button468_7" vTcl:WidgetProc "Toplevel468" 1
    bindtags $site_4_0.cpd46 "$site_4_0.cpd46 Button $top all _vTclBalloon"
    bind $site_4_0.cpd46 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_4_0.cpd45 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    frame $site_3_0.fra47 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra47" "Frame7" vTcl:WidgetProc "Toplevel468" 1
    set site_4_0 $site_3_0.fra47
    frame $site_4_0.cpd48 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd48" "Frame8" vTcl:WidgetProc "Toplevel468" 1
    set site_5_0 $site_4_0.cpd48
    label $site_5_0.cpd49 \
		-text Satellite 
    vTcl:DefineAlias "$site_5_0.cpd49" "Label468_10" vTcl:WidgetProc "Toplevel468" 1
    entry $site_5_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMSatellite -width 7 
    vTcl:DefineAlias "$site_5_0.cpd50" "Entry468_10" vTcl:WidgetProc "Toplevel468" 1
    label $site_5_0.cpd51 \
		-text Beams 
    vTcl:DefineAlias "$site_5_0.cpd51" "Label468_11" vTcl:WidgetProc "Toplevel468" 1
    entry $site_5_0.cpd52 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMBeams -width 7 
    vTcl:DefineAlias "$site_5_0.cpd52" "Entry468_11" vTcl:WidgetProc "Toplevel468" 1
    label $site_5_0.lab82 \
		-text {Polar. Mode} 
    vTcl:DefineAlias "$site_5_0.lab82" "Label468_12" vTcl:WidgetProc "Toplevel468" 1
    entry $site_5_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMLevelData -width 15 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry468_12" vTcl:WidgetProc "Toplevel468" 1
    pack $site_5_0.cpd49 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd50 \
		-in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.cpd51 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd52 \
		-in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_5_0.lab82 \
		-in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent83 \
		-in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $site_4_0.fra53 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra53" "Frame6" vTcl:WidgetProc "Toplevel468" 1
    set site_5_0 $site_4_0.fra53
    frame $site_5_0.fra54 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra54" "Frame9" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.fra54
    frame $site_6_0.cpd56 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd56" "Frame12" vTcl:WidgetProc "Toplevel468" 1
    set site_7_0 $site_6_0.cpd56
    label $site_7_0.cpd49 \
		-text {Sampled Pixel Spacing} 
    vTcl:DefineAlias "$site_7_0.cpd49" "Label468_13" vTcl:WidgetProc "Toplevel468" 1
    entry $site_7_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMResRg -width 7 
    vTcl:DefineAlias "$site_7_0.cpd50" "Entry468_13" vTcl:WidgetProc "Toplevel468" 1
    pack $site_7_0.cpd49 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd50 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $site_6_0.cpd58 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd58" "Frame13" vTcl:WidgetProc "Toplevel468" 1
    set site_7_0 $site_6_0.cpd58
    label $site_7_0.cpd49 \
		-text {Sampled Line Spacing} 
    vTcl:DefineAlias "$site_7_0.cpd49" "Label468_14" vTcl:WidgetProc "Toplevel468" 1
    entry $site_7_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMResAz -width 7 
    vTcl:DefineAlias "$site_7_0.cpd50" "Entry468_14" vTcl:WidgetProc "Toplevel468" 1
    pack $site_7_0.cpd49 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd50 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_6_0.cpd56 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd58 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.cpd59 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd59" "Frame14" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.cpd59
    frame $site_6_0.cpd56 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd56" "Frame15" vTcl:WidgetProc "Toplevel468" 1
    set site_7_0 $site_6_0.cpd56
    label $site_7_0.cpd49 \
		-text {Inc Angle Near Range} 
    vTcl:DefineAlias "$site_7_0.cpd49" "Label468_15" vTcl:WidgetProc "Toplevel468" 1
    entry $site_7_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMIncAngNear -width 7 
    vTcl:DefineAlias "$site_7_0.cpd50" "Entry468_15" vTcl:WidgetProc "Toplevel468" 1
    pack $site_7_0.cpd49 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd50 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    frame $site_6_0.cpd58 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd58" "Frame16" vTcl:WidgetProc "Toplevel468" 1
    set site_7_0 $site_6_0.cpd58
    label $site_7_0.cpd49 \
		-text {Inc Angle Far Range} 
    vTcl:DefineAlias "$site_7_0.cpd49" "Label468_16" vTcl:WidgetProc "Toplevel468" 1
    entry $site_7_0.cpd50 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable RADARSATRCMIncAngFar -width 7 
    vTcl:DefineAlias "$site_7_0.cpd50" "Entry468_16" vTcl:WidgetProc "Toplevel468" 1
    pack $site_7_0.cpd49 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd50 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_6_0.cpd56 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd58 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra54 \
		-in $site_5_0 -anchor center -expand 1 -fill none -padx 1 -side left 
    pack $site_5_0.cpd59 \
		-in $site_5_0 -anchor center -expand 0 -fill none -padx 1 -side top 
    pack $site_4_0.cpd48 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.fra53 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra44 \
		-in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.fra47 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd77 \
		-height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel468" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd98 \
		-ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame468_1" vTcl:WidgetProc "Toplevel468" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry468_1" vTcl:WidgetProc "Toplevel468" 1
    frame $site_5_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd119 \
		\
		-command {global FileName RADARSATRCMDirInput RADARSATRCMDataFormat FileInput1

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSATRCMDataFormat == "quad"} {OpenFile $RADARSATRCMDirInput $types "HH INPUT FILE (s11)"}
if {$RADARSATRCMDataFormat == "dual"} {OpenFile $RADARSATRCMDirInput $types "INPUT FILE (Channel 1)"}
if {$RADARSATRCMDataFormat == "compact"} {OpenFile $RADARSATRCMDirInput $types "INPUT FILE (Channel 1)"}
set FileInput1 $FileName} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button468_1" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame468_2" vTcl:WidgetProc "Toplevel468" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry468_2" vTcl:WidgetProc "Toplevel468" 1
    frame $site_5_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
		\
		-command {global FileName RADARSATRCMDirInput RADARSATRCMDataFormat FileInput2

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSATRCMDataFormat == "quad"} {OpenFile $RADARSATRCMDirInput $types "HV INPUT FILE (s12)"}
if {$RADARSATRCMDataFormat == "dual"} {OpenFile $RADARSATRCMDirInput $types "INPUT FILE (Channel 2)"}
if {$RADARSATRCMDataFormat == "compact"} {OpenFile $RADARSATRCMDirInput $types "INPUT FILE (Channel 2)"}
set FileInput2 $FileName} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button468_2" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame468_3" vTcl:WidgetProc "Toplevel468" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry468_3" vTcl:WidgetProc "Toplevel468" 1
    frame $site_5_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
		\
		-command {global FileName RADARSATRCMDirInput RADARSATRCMDataFormat FileInput3

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSATRCMDataFormat == "quad"} {OpenFile $RADARSATRCMDirInput $types "VH INPUT FILE (s21)"}
set FileInput3 $FileName} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button468_3" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame468_4" vTcl:WidgetProc "Toplevel468" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry468_4" vTcl:WidgetProc "Toplevel468" 1
    frame $site_5_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame28" vTcl:WidgetProc "Toplevel468" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd122 \
		\
		-command {global FileName RADARSATRCMDirInput RADARSATRCMDataFormat FileInput4

set types {
    {{All Files}        *        }
    }
set FileName ""
if {$RADARSATRCMDataFormat == "quad"} {OpenFile $RADARSATRCMDirInput $types "VV INPUT FILE (s22)"}
set FileInput4 $FileName} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd122" "Button468_4" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$top.fra76" "Frame5" vTcl:WidgetProc "Toplevel468" 1
    set site_3_0 $top.fra76
    label $site_3_0.lab77 \
		-text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_3_0.lab77" "Label468_1" vTcl:WidgetProc "Toplevel468" 1
    entry $site_3_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligFullSize -width 5 
    vTcl:DefineAlias "$site_3_0.ent78" "Entry468_5" vTcl:WidgetProc "Toplevel468" 1
    label $site_3_0.lab79 \
		-text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_3_0.lab79" "Label468_2" vTcl:WidgetProc "Toplevel468" 1
    entry $site_3_0.ent80 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolFullSize -width 5 
    vTcl:DefineAlias "$site_3_0.ent80" "Entry468_6" vTcl:WidgetProc "Toplevel468" 1
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
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel468" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
		-background {#ffff00} \
		-command {global RADARSATRCMDirOutput RADARSATRCMFileInputFlag RADARSATRCMDataFormat
global OpenDirFile TMPRadarsatRCMConfig RADARSATRCMLutFile1 RADARSATRCMLutFile2 RADARSATRCMLutFile3 RADARSATRCMLutFile4
global IEEEFormat FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError PolarType
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set RADARSATRCMFileInputFlag 0
if {$RADARSATRCMDataFormat == "quad"} {
    set RADARSATRCMFileFlag 0
    if {$FileInput1 != ""} {incr RADARSATRCMFileFlag}
    if {$FileInput2 != ""} {incr RADARSATRCMFileFlag}
    if {$FileInput3 != ""} {incr RADARSATRCMFileFlag}
    if {$FileInput4 != ""} {incr RADARSATRCMFileFlag}
    if {$RADARSATRCMFileFlag == 4} {set RADARSATRCMFileInputFlag 1}
    }
if {$RADARSATRCMDataFormat == "dual"} {
    set RADARSATRCMFileFlag 0
    if {$FileInput1 != ""} {incr RADARSATRCMFileFlag}
    if {$FileInput2 != ""} {incr RADARSATRCMFileFlag}
    if {$RADARSATRCMFileFlag == 2} {set RADARSATRCMFileInputFlag 1}
    }
if {$RADARSATRCMDataFormat == "compact"} {
    set RADARSATRCMFileFlag 0
    if {$FileInput1 != ""} {incr RADARSATRCMFileFlag}
    if {$FileInput2 != ""} {incr RADARSATRCMFileFlag}
    if {$RADARSATRCMFileFlag == 2} {set RADARSATRCMFileInputFlag 1}
    }
if {$RADARSATRCMFileInputFlag == 1} {

    DeleteFile $TMPRadarsatRCMConfig

    TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsat2_header.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInput1\x22 -of \x22$TMPRadarsatRCMConfig\x22" "k"
    set f [ open "| Soft/bin/data_import/radarsat2_header.exe -if \x22$FileInput1\x22 -of \x22$TMPRadarsatRCMConfig\x22" r]
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
    set ConfigFile $TMPRadarsatRCMConfig
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
        $widget(Entry468_5) configure -disabledbackground #FFFFFF; $widget(Label468_1) configure -state normal
        $widget(Entry468_6) configure -disabledbackground #FFFFFF; $widget(Label468_2) configure -state normal
        set NligInit 1
        set NligEnd $NligFullSize
        set NcolInit 1
        set NcolEnd $NcolFullSize
        set NligFullSizeInput $NligFullSize
        set NcolFullSizeInput $NcolFullSize

        if {$RADARSATRCMDataFormat == "compact"} {
            TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch CH -nc $NcolFullSize" "k"
            set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch CH -nc $NcolFullSize" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set RADARSATRCMLutFile1 "$RADARSATRCMDirOutput/product_lut_CH.bin"
            TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch CV -nc $NcolFullSize" "k"
            set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch CV -nc $NcolFullSize" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set RADARSATRCMLutFile2 "$RADARSATRCMDirOutput/product_lut_CV.bin"
            }
        if {$RADARSATRCMDataFormat == "dual"} {
            if {$PolarType == "pp1" } {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch HH -nc $NcolFullSize" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch HH -nc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set RADARSATRCMLutFile1 "$RADARSATRCMDirOutput/product_lut_HH.bin"
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch HV -nc $NcolFullSize" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch HV -nc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set RADARSATRCMLutFile2 "$RADARSATRCMDirOutput/product_lut_HV.bin"
                }
            if {$PolarType == "pp2" } {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch VV -nc $NcolFullSize" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch VV -nc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set RADARSATRCMLutFile1 "$RADARSATRCMDirOutput/product_lut_VV.bin"
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch VH -nc $NcolFullSize" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch VH -nc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set RADARSATRCMLutFile2 "$RADARSATRCMDirOutput/product_lut_VH.bin"
                }
            if {$PolarType == "pp3" } {
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch HH -nc $NcolFullSize" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch HH -nc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set RADARSATRCMLutFile1 "$RADARSATRCMDirOutput/product_lut_HH.bin"
                TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch VV -nc $NcolFullSize" "k"
                set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch VV -nc $NcolFullSize" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                set RADARSATRCMLutFile2 "$RADARSATRCMDirOutput/product_lut_VV.bin"
                }
            }
        if {$RADARSATRCMDataFormat == "quad"} {
            TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch HH -nc $NcolFullSize" "k"
            set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch HH -nc $NcolFullSize" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set RADARSATRCMLutFile1 "$RADARSATRCMDirOutput/product_lut_HH.bin"
            TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch HV -nc $NcolFullSize" "k"
            set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch HV -nc $NcolFullSize" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set RADARSATRCMLutFile2 "$RADARSATRCMDirOutput/product_lut_HV.bin"
            TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch VH -nc $NcolFullSize" "k"
            set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch VH -nc $NcolFullSize" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set RADARSATRCMLutFile3 "$RADARSATRCMDirOutput/product_lut_VH.bin"
            TextEditorRunTrace "Process The Function Soft/bin/data_import/radarsatrcm_lut.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RADARSATRCMDirOutput\x22 -ch VV -nc $NcolFullSize" "k"
            set f [ open "| Soft/bin/data_import/radarsatrcm_lut.exe -id \x22$RADARSATRCMDirOutput\x22 -ch VV -nc $NcolFullSize" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set RADARSATRCMLutFile4 "$RADARSATRCMDirOutput/product_lut_VV.bin"
            }

        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel468); TextEditorRunTrace "Close Window RADARSAT-RCM Input File" "b"
        } else {
        set ErrorMessage "ROWS / COLS EXTRACTION ERROR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        Window hide $widget(Toplevel468); TextEditorRunTrace "Close Window RADARSAT-RCM Input File" "b"
        }
    } else {
    set RADARSATRCMFileInputFlag 0
    set ErrorMessage "ENTER THE RADARSAT-RCM DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
		-padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button468_6" vTcl:WidgetProc "Toplevel468" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/RADARSATRCM_Input_File.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel468" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
		-background {#ffff00} \
		-command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel468); TextEditorRunTrace "Close Window RADARSATRCM Input File" "b"
}} \
		-padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel468" 1
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
Window show .top468

main $argc $argv
