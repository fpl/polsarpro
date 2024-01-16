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

        {{[file join . GUI Images ESAR.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}

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
    set base .top226a
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
    set site_4_0 [$base.cpd67 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_4_0 [$base.cpd69 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_4_0 [$base.cpd70 getframe]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.cpd91
    set site_3_0 $base.fra73
    set site_4_0 $site_3_0.cpd45
    set site_3_0 $base.fra71
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top226a
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
    wm geometry $top 200x200+130+130; update
    wm maxsize $top 3844 1061
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

proc vTclWindow.top226a {base} {
    if {$base == ""} {
        set base .top226a
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-menu "$top.m88" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x410+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "ESAR Input Data File"
    vTcl:DefineAlias "$top" "Toplevel226a" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
		-image [vTcl:image:get_image [file join . GUI Images ESAR.gif]] \
		-text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel226a" 1
    frame $top.cpd79 \
		-height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel226a" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
		-ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel226a" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable ESARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel226a" 1
    frame $site_5_0.cpd92 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel226a" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
		\
		-image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
		-pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel226a" 1
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
    vTcl:DefineAlias "$top.cpd71" "TitleFrame226a" vTcl:WidgetProc "Toplevel226a" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} \
		-textvariable ESARDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry226a" vTcl:WidgetProc "Toplevel226a" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel226a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global DirName DataDir ESARDirOutput
global VarWarning WarningMessage WarningMessage2

set ESAROutputDirTmp $ESARDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set ESARDirOutput $DirName
        } else {
        set ESARDirOutput $ESAROutputDirTmp
        }
    } else {
    set ESARDirOutput $ESAROutputDirTmp
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button226a" vTcl:WidgetProc "Toplevel226a" 1
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
    TitleFrame $top.cpd67 \
		-ipad 0 -text {E-SAR RGI Directory} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame432" vTcl:WidgetProc "Toplevel226a" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable ESARRGIDir 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry433" vTcl:WidgetProc "Toplevel226a" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame42" vTcl:WidgetProc "Toplevel226a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global DirName ESARDirInput ESARRGIDir ESARProductFile
global VarWarning WarningMessage WarningMessage2 PSPBackgroundColor
global ESARProductFile1 ESARProductFile2
global FileInput1 FileInput2 NligFullSize NcolFullSize
global ErrorMessage VarError

set ESARRGIDir ""
set ESARProductFile1 ""
set ESARProductFile2 ""
set FileInput1 ""; set FileInput2 ""
set NligFullSize ""; set NcolFullSize ""

$widget(Button226a_00) configure -state disable
$widget(Label226a_1) configure -state disable
$widget(Entry226a_7) configure -disabledbackground $PSPBackgroundColor
$widget(Label226a_2) configure -state disable
$widget(Entry226a_8) configure -disabledbackground $PSPBackgroundColor

set ESARRGIDir ""
$widget(TitleFrame226a_01) configure -state disable
$widget(Entry226a_01) configure -disabledbackground $PSPBackgroundColor
$widget(Button226a_01) configure -state disable
$widget(TitleFrame226a_02) configure -state disable
$widget(Entry226a_02) configure -disabledbackground $PSPBackgroundColor
$widget(Button226a_02) configure -state disable

OpenDir $ESARDirInput "E-SAR RGI DIRECTORY"
if {$DirName != "" } {
    set config "false"
    if [file isdirectory "$DirName/RGI-QL"] {
        if [file isdirectory "$DirName/RGI-RDP"] {
            if [file isdirectory "$DirName/RGI-SR"] {
                if [file isdirectory "$DirName/RGI-TRACK"] {
                    set config "true"
                    }
                }
            }
        }
    if {$config == "true"} {
        set ESARRGIDir $DirName
        $widget(TitleFrame226a_01) configure -state normal
        $widget(Entry226a_01) configure -disabledbackground #FFFFFF
        $widget(Button226a_01) configure -state normal
        $widget(TitleFrame226a_02) configure -state normal
        $widget(Entry226a_02) configure -disabledbackground #FFFFFF
        $widget(Button226a_02) configure -state normal
        } else { 
        set ErrorMessage "THE DIRECTORY IS NOT A E-SAR RGI DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }    
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button433" vTcl:WidgetProc "Toplevel226a" 1
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
    TitleFrame $top.cpd69 \
		-ipad 0 -text {E-SAR Processing Parameters File - Channel 1} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame226a_01" vTcl:WidgetProc "Toplevel226a" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable ESARProductFile1 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry226a_01" vTcl:WidgetProc "Toplevel226a" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame44" vTcl:WidgetProc "Toplevel226a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global FileName ESARRGIDir ESARProductFile1 ESARProductFile2

set types {
    {{TXT Files}        {.txt}        }
    }
set FileName ""
OpenFile "$ESARRGIDir/RGI-RDP" $types "E-SAR PROCESSING PARAMETERS FILE Channel 1"
if {$FileName != ""} {
    set ESARProductFile1 $FileName
    if {$ESARProductFile1 != ""} {
        if {$ESARProductFile2 != ""} {
            $widget(Button226a_00) configure -state normal
            }
        }
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button226a_01" vTcl:WidgetProc "Toplevel226a" 1
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
    TitleFrame $top.cpd70 \
		-ipad 0 -text {E-SAR Processing Parameters File - Channel 2} 
    vTcl:DefineAlias "$top.cpd70" "TitleFrame226a_02" vTcl:WidgetProc "Toplevel226a" 1
    bind $top.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd70 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable ESARProductFile2 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry226a_02" vTcl:WidgetProc "Toplevel226a" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame45" vTcl:WidgetProc "Toplevel226a" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global FileName ESARRGIDir ESARProductFile1 ESARProductFile2

set types {
    {{TXT Files}        {.txt}        }
    }
set FileName ""
OpenFile "$ESARRGIDir/RGI-RDP" $types "E-SAR PROCESSING PARAMETERS FILE Channel 2"
if {$FileName != ""} {
    set ESARProductFile2 $FileName
    if {$ESARProductFile1 != ""} {
        if {$ESARProductFile2 != ""} {
            $widget(Button226a_00) configure -state normal
            }
        }
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button226a_02" vTcl:WidgetProc "Toplevel226a" 1
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
    frame $top.fra73 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel226a" 1
    set site_3_0 $top.fra73
    button $site_3_0.but74 \
		-background {#ffff00} \
		-command {global ESARDirInput ESARDirOutput ESARFileInputFlag
global ESARDataFormat ESARProductFile ESARRGIDir ESARHeader
global FileInput1 FileInput2 ESARProductFile1 ESARProductFile2 ESARpolarType
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPEsarConfig OpenDirFile PolarType
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set datalevelerror 0
#####################################################################
#Create Directory
set ESARDirOutput [PSPCreateDirectoryMask $ESARDirOutput $ESARDirOutput $ESARDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPEsarConfig

set ConfigProductFile "true"
set ESARpolar1 ""
if [file exists $ESARProductFile1] {
    set f [open $ESARProductFile1 r]
    while { ![eof $f] } {
        gets $f tmp
        if { [string first "0.17" $tmp] == 0} {
            if { [string first "HH" $tmp] != -1} { set ESARpolar1 "HH"}
            if { [string first "HV" $tmp] != -1} { set ESARpolar1 "HV"}
            if { [string first "VH" $tmp] != -1} { set ESARpolar1 "VH"}
            if { [string first "VV" $tmp] != -1} { set ESARpolar1 "VV"}
            }
        }
    close $f
    if {$ESARpolar1 == ""} {
        set ErrorMessage "FILE 1 IS NOT A PP FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set ESARProductFile1 ""
        set ConfigProductFile "false"
        }
    } else {
    set ErrorMessage "ENTER THE PP FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ESARProductFile1 ""; set ESARFileInputFlag 0
    set ConfigProductFile "false"
    }
    #ProductFile Exists

set ESARpolar2 ""
if [file exists $ESARProductFile2] {
    set f [open $ESARProductFile2 r]
    while { ![eof $f] } {
        gets $f tmp
        if { [string first "0.17" $tmp] == 0} {
            if { [string first "HH" $tmp] != -1} { set ESARpolar2 "HH"}
            if { [string first "HV" $tmp] != -1} { set ESARpolar2 "HV"}
            if { [string first "VH" $tmp] != -1} { set ESARpolar2 "VH"}
            if { [string first "VV" $tmp] != -1} { set ESARpolar2 "VV"}
            }
        }
    close $f
    if {$ESARpolar2 == ""} {
        set ErrorMessage "FILE 2 IS NOT A PP FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set ESARProductFile2 ""
        set ConfigProductFile "false"
        }
    } else {
    set ErrorMessage "ENTER THE PP FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set ESARProductFile2 ""; set ESARFileInputFlag 0
    set ConfigProductFile "false"
    }
    #ProductFile Exists

if {$ConfigProductFile == "true"} {
    set ConfigPolar "false"
    if {$ESARpolar1 != $ESARpolar2} {
        set ConfigPolar "true"
        }
    if {$ConfigPolar == "false"} {
        set ErrorMessage "SAME POLAR CHANNELS"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {$ConfigPolar == "true"} {
        if {$ESARpolar1 == "HH" & $ESARpolar2 == "HV"} { set ESARpolarType "pp1"}
        if {$ESARpolar1 == "HH" & $ESARpolar2 == "VH"} { set ESARpolarType "pp1"}
        if {$ESARpolar1 == "HV" & $ESARpolar2 == "HH"} { set ESARpolarType "pp1"}
        if {$ESARpolar1 == "VH" & $ESARpolar2 == "HH"} { set ESARpolarType "pp1"}

        if {$ESARpolar1 == "VV" & $ESARpolar2 == "HV"} { set ESARpolarType "pp2"}
        if {$ESARpolar1 == "VV" & $ESARpolar2 == "VH"} { set ESARpolarType "pp2"}
        if {$ESARpolar1 == "HV" & $ESARpolar2 == "VV"} { set ESARpolarType "pp2"}
        if {$ESARpolar1 == "VH" & $ESARpolar2 == "VV"} { set ESARpolarType "pp2"}

        if {$ESARpolar1 == "HH" & $ESARpolar2 == "VV"} { set ESARpolarType "pp3"}
        if {$ESARpolar1 == "VV" & $ESARpolar2 == "HH"} { set ESARpolarType "pp3"}

        set ESARFile1 [file rootname [file tail $ESARProductFile1]]
        set ESARFile1 [string replace $ESARFile1 0 0 "i"]
        set ESARFile2 [file rootname [file tail $ESARProductFile2]]
        set ESARFile2 [string replace $ESARFile2 0 0 "i"]

        if {$ESARpolarType == "pp1"} {
            if {$ESARpolar1 == "HH"} {
                set FileInput1 "$ESARRGIDir/RGI-SR/"; append FileInput1 $ESARFile1; append FileInput1 "_slc.dat"
                set FileInput2 "$ESARRGIDir/RGI-SR/"; append FileInput2 $ESARFile2; append FileInput2 "_slc.dat"
                } else {
                set FileInput1 "$ESARRGIDir/RGI-SR/"; append FileInput1 $ESARFile2; append FileInput1 "_slc.dat"
                set FileInput2 "$ESARRGIDir/RGI-SR/"; append FileInput2 $ESARFile1; append FileInput2 "_slc.dat"
                }
            }
        if {$ESARpolarType == "pp2"} {
            if {$ESARpolar1 == "VV"} {
                set FileInput1 "$ESARRGIDir/RGI-SR/"; append FileInput1 $ESARFile1; append FileInput1 "_slc.dat"
                set FileInput2 "$ESARRGIDir/RGI-SR/"; append FileInput2 $ESARFile2; append FileInput2 "_slc.dat"
                } else {
                set FileInput1 "$ESARRGIDir/RGI-SR/"; append FileInput1 $ESARFile2; append FileInput1 "_slc.dat"
                set FileInput2 "$ESARRGIDir/RGI-SR/"; append FileInput2 $ESARFile1; append FileInput2 "_slc.dat"
                }
            }
        if {$ESARpolarType == "pp3"} {
            if {$ESARpolar1 == "HH"} {
                set FileInput1 "$ESARRGIDir/RGI-SR/"; append FileInput1 $ESARFile1; append FileInput1 "_slc.dat"
                set FileInput2 "$ESARRGIDir/RGI-SR/"; append FileInput2 $ESARFile2; append FileInput2 "_slc.dat"
                } else {
                set FileInput1 "$ESARRGIDir/RGI-SR/"; append FileInput1 $ESARFile2; append FileInput1 "_slc.dat"
                set FileInput2 "$ESARRGIDir/RGI-SR/"; append FileInput2 $ESARFile1; append FileInput2 "_slc.dat"
                }
            }

        set ConfigFile1 "false"
        if [file exists $FileInput1] {
            set ConfigFile1 "true"
            }
        set ConfigFile2 "false"
        if [file exists $FileInput2] {
            set ConfigFile2 "true"
            }
        set ConfigFileTotal "false"
        if {$ConfigFile1 == "true"} {
        if {$ConfigFile2 == "true"} {
            set ConfigFileTotal "true"
            } }

        if {$ConfigFileTotal == "true"} {
            TextEditorRunTrace "Process The Function Soft/bin/data_import/esar_header.exe" "k"
            TextEditorRunTrace "Arguments: -if \x22$FileInput1\x22 -iee 1 -of \x22$TMPEsarConfig\x22" "k"
            set f [ open "| Soft/bin/data_import/esar_header.exe -if \x22$FileInput1\x22 -iee 1 -of \x22$TMPEsarConfig\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
    
            set NligFullSize ""
            set NcolFullSize ""
            set NligInit 0
            set NligEnd 0
            set NcolInit 0
            set NcolEnd 0
            set NligFullSizeInput 0
            set NcolFullSizeInput 0
            WaitUntilCreated $TMPEsarConfig
            set ErrorMessage ""
            if [file exists $TMPEsarConfig] {
                $widget(Label226a_1) configure -state normal
                $widget(Entry226a_7) configure -disabledbackground #FFFFFF
                $widget(Label226a_2) configure -state normal
                $widget(Entry226a_8) configure -disabledbackground #FFFFFF
                set f [open $TMPEsarConfig r]
                gets $f tmp
                gets $f NligFullSize
                gets $f tmp
                gets $f tmp
                gets $f NcolFullSize
                close $f
                set NligInit 1
                set NligEnd $NligFullSize
                set NcolInit 1
                set NcolEnd $NcolFullSize
                set NligFullSizeInput $NligFullSize
                set NcolFullSizeInput $NcolFullSize
                set ErrorMessage ""
                } else {
                set ErrorMessage "NO CONFIG FILE !"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
            #ConfigFileTotal
        }
        #ConfigTotal
    }
    #ConfigProductFile
}
#VarWarning
}
#OpenDirFile} \
		-padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but74" "Button226a_00" vTcl:WidgetProc "Toplevel226a" 1
    frame $site_3_0.cpd45 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd45" "Frame8" vTcl:WidgetProc "Toplevel226a" 1
    set site_4_0 $site_3_0.cpd45
    label $site_4_0.lab77 \
		-text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_4_0.lab77" "Label226a_1" vTcl:WidgetProc "Toplevel226a" 1
    entry $site_4_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligFullSize -width 7 
    vTcl:DefineAlias "$site_4_0.ent78" "Entry226a_7" vTcl:WidgetProc "Toplevel226a" 1
    label $site_4_0.lab79 \
		-text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_4_0.lab79" "Label226a_2" vTcl:WidgetProc "Toplevel226a" 1
    entry $site_4_0.ent80 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolFullSize -width 7 
    vTcl:DefineAlias "$site_4_0.ent80" "Entry226a_8" vTcl:WidgetProc "Toplevel226a" 1
    pack $site_4_0.lab77 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent78 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.lab79 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent80 \
		-in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.but74 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd45 \
		-in $site_3_0 -anchor center -expand 1 -fill y -side left 
    frame $top.fra71 \
		-relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel226a" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
		-background {#ffff00} \
		-command {global ESARDirOutput ESARFileInputFlag ESARDataFormat
global OpenDirFile 
global FileInput1 FileInput2
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {

set ESARFileInputFlag 0
if {$ESARDataFormat == "dual"} {
    set ESARFileFlag 0
    if {$FileInput1 != ""} {incr ESARFileFlag}
    if {$FileInput2 != ""} {incr ESARFileFlag}
    if {$ESARFileFlag == 2} {set ESARFileInputFlag 1}
    }
if {$ESARFileInputFlag == 1} {
    set ErrorMessage ""
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel226a); TextEditorRunTrace "Close Window ESAR Dual Input File" "b"
    } else {
    set ESARFileInputFlag 0
    set ErrorMessage "ENTER THE ESAR DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
		-padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button226a_9" vTcl:WidgetProc "Toplevel226a" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/ESAR_Input_File.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel226a" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
		-background {#ffff00} \
		-command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel226a); TextEditorRunTrace "Close Window ESAR Dual Input File" "b"
}} \
		-padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel226a" 1
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
    menu $top.m88 \
		-activeborderwidth 1 -borderwidth 1 -cursor {} 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab66 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd79 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
		-in $top -anchor center -expand 0 -fill x -pady 2 -side top 
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
Window show .top226a

main $argc $argv
