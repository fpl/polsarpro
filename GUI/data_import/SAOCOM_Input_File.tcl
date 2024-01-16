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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}
        {{[file join . GUI Images SAOCOM.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top467
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
    set site_3_0 $base.fra73
    set site_4_0 $site_3_0.fra44
    set site_6_0 [$site_4_0.cpd44 getframe]
    set site_6_0 $site_6_0
    set site_7_0 $site_6_0.fra45
    set site_4_0 $site_3_0.fra56
    set site_5_0 $site_4_0.cpd57
    set site_5_0 $site_4_0.cpd58
    set site_6_0 $site_5_0.fra48
    set site_7_0 $site_6_0.cpd50
    set site_7_0 $site_6_0.cpd51
    set site_7_0 $site_6_0.cpd52
    set site_6_0 $site_5_0.fra49
    set site_7_0 $site_6_0.cpd53
    set site_7_0 $site_6_0.cpd54
    set site_7_0 $site_6_0.cpd55
    set site_3_0 $base.cpd77
    set site_5_0 [$site_3_0.cpd98 getframe]
    set site_5_0 $site_5_0
    set site_5_0 [$site_3_0.cpd116 getframe]
    set site_5_0 $site_5_0
    set site_5_0 [$site_3_0.cpd117 getframe]
    set site_5_0 $site_5_0
    set site_5_0 [$site_3_0.cpd118 getframe]
    set site_5_0 $site_5_0
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
            vTclWindow.top467
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
    wm geometry $top 200x200+156+156; update
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

proc vTclWindow.top467 {base} {
    if {$base == ""} {
        set base .top467
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
    wm geometry $top 500x610+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "SAOCOM Input Data File"
    vTcl:DefineAlias "$top" "Toplevel467" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
		-image [vTcl:image:get_image [file join . GUI Images SAOCOM.gif]] \
		-text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel467" 1
    frame $top.cpd79 \
		-height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel467" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
		-ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel467" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable SAOCOMDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel467" 1
    frame $site_5_0.cpd92 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel467" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
		\
		-image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
		-pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel467" 1
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
    vTcl:DefineAlias "$top.cpd71" "TitleFrame467" vTcl:WidgetProc "Toplevel467" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#ff0000} -foreground {#ff0000} \
		-textvariable SAOCOMDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry467" vTcl:WidgetProc "Toplevel467" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel467" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global DirName DataDir SAOCOMDirOutput
global VarWarning WarningMessage WarningMessage2

set SAOCOMOutputDirTmp $SAOCOMDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set SAOCOMDirOutput $DirName
        } else {
        set SAOCOMDirOutput $SAOCOMOutputDirTmp
        }
    } else {
    set SAOCOMDirOutput $SAOCOMOutputDirTmp
    }} \
		-image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button467" vTcl:WidgetProc "Toplevel467" 1
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
		-ipad 0 -text {Description Metadata File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame220" vTcl:WidgetProc "Toplevel467" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable SAOCOMProductFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry220" vTcl:WidgetProc "Toplevel467" 1
    frame $site_4_0.cpd91 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame30" vTcl:WidgetProc "Toplevel467" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
		\
		-command {global FileName SAOCOMDirInput SAOCOMProductFile

set types {
    {{XML Files}        {.xemt}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $SAOCOMDirInput $types "SAOCOM METADATA FILE"
set SAOCOMProductFile $FileName} \
		-image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button220" vTcl:WidgetProc "Toplevel467" 1
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
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel467" 1
    set site_3_0 $top.fra73
    frame $site_3_0.fra44 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra44" "Frame2" vTcl:WidgetProc "Toplevel467" 1
    set site_4_0 $site_3_0.fra44
    button $site_4_0.cpd45 \
		-background {#ffff00} \
		-command {global SAOCOMDirInput SAOCOMDirOutput SAOCOMFileInputFlag
global SAOCOMDataFormat SAOCOMDataLevel SAOCOMProductFile
global SAOCOMAntenna SAOCOMPass SAOCOMAntennaPass
global SAOCOMDataType SAOCOMBeamID SAOCOMIncidenceAngle 
global SAOCOMNCol SAOCOMNRow  SAOCOMResRg SAOCOMResAz
global SAOCOMTypeData SAOCOMLevelData SAOCOMModeAcq SAOCOMIDBeam
global SAOCOMSwath SAOCOMFileData SAOCOMSwathInit SAOCOMSwathTOPSAR
global SAOCOMSwathCurrent SAOCOMCurrentSwath VarSAOCOMSwath SAOCOMCurrentSwathInd iNswath
global FileInput1 FileInput2 FileInput3 FileInput4 FileInputTmp
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPSaocomConfig TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

set datalevelerror 0
#####################################################################
#Create Directory
set SAOCOMDirOutput [PSPCreateDirectoryMask $SAOCOMDirOutput $SAOCOMDirOutput $SAOCOMDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPSaocomConfig
DeleteFile $TMPGoogle

if [file exists $SAOCOMProductFile] {
    set SAOCOMFileInputFlag 0
    set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; set FileInputTmp ""
    set NligFullSize ""; set NcolFullSize ""; set PolarType ""
    set SAOCOMDataLevel ""
    set SAOCOMAntenna ""; set SAOCOMPass ""; set SAOCOMAntennaPass ""
    set SAOCOMDataType ""; set SAOCOMBeamID ""; set SAOCOMIncidenceAngle "" 
    set SAOCOMNCol ""; set SAOCOMNRow ""; set SAOCOMResRg ""; set SAOCOMResAz ""
    set SAOCOMTypeData ""; set SAOCOMLevelData ""; set SAOCOMModeAcq ""; set SAOCOMIDBeam ""
    set VarSAOCOMSwath ""; set SAOCOMCurrentSwath ""; set SAOCOMCurrentSwathInd 1
    for {set i 0} {$i <= 50} {incr i} {
        set SAOCOMSwath($i) "x"
        set SAOCOMFileData($i) "x"
        set SAOCOMSwathInit($i) "x"
        set SAOCOMSwathTOPSAR($i) "x"
        }

    $widget(Entry467_10) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_10) configure -state disable
    $widget(Entry467_11) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_11) configure -state disable
    $widget(Entry467_12) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_12) configure -state disable
    $widget(Entry467_13) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_13) configure -state disable
    $widget(Entry467_14) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_14) configure -state disable
    $widget(Entry467_15) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_15) configure -state disable
    $widget(Entry467_16) configure -disabledbackground $PSPBackgroundColor; $widget(Label467_16) configure -state disable
    $widget(Entry467_1) configure -disabledbackground $PSPBackgroundColor
    $widget(TitleFrame467_1) configure -text " "
    $widget(Entry467_2) configure -disabledbackground $PSPBackgroundColor
    $widget(TitleFrame467_2) configure -text " "
    $widget(Entry467_3) configure -disabledbackground $PSPBackgroundColor
    $widget(TitleFrame467_3) configure -text " "
    $widget(Entry467_4) configure -disabledbackground $PSPBackgroundColor
    $widget(TitleFrame467_4) configure -text " "
    $widget(Label467_1) configure -state disable; $widget(Entry467_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Label467_2) configure -state disable; $widget(Entry467_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Button467_6) configure -state disable; 
    $widget(Button467_7) configure -state disable; 
    $widget(Entry467_100) configure -disabledbackground $PSPBackgroundColor
    $widget(TitleFrame467_100) configure -state disable; 
    $widget(Button467_100) configure -state disable; 
    $widget(Button467_101) configure -state disable; 
    $widget(Button467_102) configure -state disable; 

    set SAOCOMFile "$SAOCOMDirOutput/product_header.txt"
    set Sensor "saocom"
    ReadXML $SAOCOMProductFile $SAOCOMFile $TMPSaocomConfig $Sensor
    WaitUntilCreated $TMPSaocomConfig
    if [file exists $TMPSaocomConfig] {

        TextEditorRunTrace "Process The Function Soft/bin/data_import/saocom_google.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SAOCOMDirOutput\x22 -if \x22$TMPSaocomConfig\x22 -of \x22$TMPGoogle\x22" "k"
        set f [ open "| Soft/bin/data_import/saocom_google.exe -id \x22$SAOCOMDirOutput\x22 -if \x22$TMPSaocomConfig\x22 -of \x22$TMPGoogle\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WaitUntilCreated $TMPGoogle

        set f [open $TMPSaocomConfig r]
        gets $f SAOCOMDataType
        gets $f GoogleLat00
        gets $f GoogleLong00
        gets $f GoogleLat0N
        gets $f GoogleLong0N
        gets $f GoogleLatN0
        gets $f GoogleLongN0
        gets $f GoogleLatNN
        gets $f GoogleLongNN
        gets $f SAOCOMacqMode
        gets $f SAOCOMpolMode
        gets $f SAOCOMBeamID
        gets $f SAOCOMDataLevel
        gets $f SAOCOMAntenna
        if {$SAOCOMacqMode == "SM" } {
            if {$SAOCOMpolMode == "DP" } { set iMax 2 }
            if {$SAOCOMpolMode == "QP" } { set iMax 4 }
            if {$SAOCOMpolMode == "CP" } { set iMax 2 }
            }
        if {$SAOCOMacqMode == "TN" } {
            if {$SAOCOMpolMode == "DP" } { set iMax 6 }
            if {$SAOCOMpolMode == "QP" } { set iMax 20 }
            if {$SAOCOMpolMode == "CP" } { set iMax 6 }
            }
        if {$SAOCOMacqMode == "TW" } {
            if {$SAOCOMpolMode == "DP" } { set iMax 14 }
            if {$SAOCOMpolMode == "QP" } { set iMax 40 }
            if {$SAOCOMpolMode == "CP" } { set iMax 14 }
            }
        for {set i 1} {$i <= $iMax} {incr i} {
            gets $f SAOCOMSwath($i)
            }
        gets $f SAOCOMPass
        gets $f SAOCOMFileData(0)
        if {$SAOCOMacqMode == "SM" } {
            if {$SAOCOMpolMode == "DP" } { set iMax 2 }
            if {$SAOCOMpolMode == "QP" } { set iMax 4 }
            if {$SAOCOMpolMode == "CP" } { set iMax 2 }
            }
        if {$SAOCOMacqMode == "TN" } {
            if {$SAOCOMpolMode == "DP" } { set iMax 6 }
            if {$SAOCOMpolMode == "QP" } { set iMax 20 }
            if {$SAOCOMpolMode == "CP" } { set iMax 6 }
            }
        if {$SAOCOMacqMode == "TW" } {
            if {$SAOCOMpolMode == "DP" } { set iMax 14 }
            if {$SAOCOMpolMode == "QP" } { set iMax 40 }
            if {$SAOCOMpolMode == "CP" } { set iMax 14 }
            }
        for {set i 1} {$i <= $iMax} {incr i} {
            gets $f SAOCOMFileData($i)
            }
        close $f

        if {$SAOCOMDataType == "L1A" } {

            if {$SAOCOMacqMode == "SM" } {
                set SAOCOMSwathInfo [string tolower $SAOCOMSwath(1)]
                }

            if {$SAOCOMacqMode == "TN" } {
                set SAOCOMCurrentSwath ""
                if {$SAOCOMpolMode == "DP" } { 
                    set iNswath 3; set iSiDP 9; set iMax 6
                    set SAOCOMSwathInit(1) "S1DP"; set SAOCOMSwathInit(2) "S2DP"
                    set SAOCOMSwathInit(3) "S3DP"; set SAOCOMSwathInit(4) "S4DP"
                    set SAOCOMSwathInit(5) "S5DP"; set SAOCOMSwathInit(6) "S6DP"
                    set SAOCOMSwathInit(7) "S7DP"; set SAOCOMSwathInit(8) "S8DP"
                    set SAOCOMSwathInit(9) "S9DP"; set SAOCOMSwathInit(10) "S10DP"
                    }
                if {$SAOCOMpolMode == "QP" } {
                    set iNswath 5; set iSiDP 10; set iMax 20
                    set SAOCOMSwathInit(1) "S1QP"; set SAOCOMSwathInit(2) "S2QP"
                    set SAOCOMSwathInit(3) "S3QP"; set SAOCOMSwathInit(4) "S4QP"
                    set SAOCOMSwathInit(5) "S5QP"; set SAOCOMSwathInit(6) "S6QP"
                    set SAOCOMSwathInit(7) "S7QP"; set SAOCOMSwathInit(8) "S8QP"
                    set SAOCOMSwathInit(9) "S9QP"; set SAOCOMSwathInit(10) "S10QP"
                    }
                if {$SAOCOMpolMode == "CP" } {
                    set iNswath 3; set iSiDP 9; set iMax 6
                    set SAOCOMSwathInit(1) "S1CP"; set SAOCOMSwathInit(2) "S2CP"
                    set SAOCOMSwathInit(3) "S3CP"; set SAOCOMSwathInit(4) "S4CP"
                    set SAOCOMSwathInit(5) "S5CP"; set SAOCOMSwathInit(6) "S6CP"
                    set SAOCOMSwathInit(7) "S7CP"; set SAOCOMSwathInit(8) "S8CP"
                    set SAOCOMSwathInit(9) "S9CP"; set SAOCOMSwathInit(10) "S10CP"
                    }
                set i 1
                set stop2 0
                for {set j 1} {$j <= $iSiDP} {incr j} {
                    if {$stop2 == 0} {
                        set SAOCOMSwathCurrent $SAOCOMSwathInit($j)
                        set stop1 0 
                        for {set k 1} {$k <= $iMax} {incr k} {
                            if {$stop1 == 0} {
                                if {$SAOCOMSwath($k) == $SAOCOMSwathCurrent} {
                                    set SAOCOMSwathTOPSAR($i) $SAOCOMSwathCurrent                              
                                    set stop1 1
                                    incr i
                                    if {$i > $iNswath} { set stop2 1 }
                                    }
                                }
                            }
                        }
                    }
                set VarSAOCOMSwath ""
                set SAOCOMCurrentSwath $SAOCOMSwathTOPSAR(1)
                set SAOCOMCurrentSwathInd 1
                $widget(TitleFrame467_100) configure -state normal
                $widget(Entry467_100) configure -disabledbackground #FFFFFF
                $widget(Button467_100) configure -state normal
                $widget(Button467_101) configure -state normal
                $widget(Button467_102) configure -state normal
                tkwait variable VarSAOCOMSwath
                set SAOCOMSwathInfo [string tolower $SAOCOMCurrentSwath]
                $widget(TitleFrame467_100) configure -state disable
                $widget(Button467_100) configure -state disable
                $widget(Button467_101) configure -state disable
                $widget(Button467_102) configure -state disable
                }

            if {$SAOCOMacqMode == "TW" } {
                set SAOCOMCurrentSwath ""
                if {$SAOCOMpolMode == "DP" } { 
                    set iNswath 7; set iSiDP 9; set iMax 14
                    set SAOCOMSwathInit(1) "S1DP"; set SAOCOMSwathInit(2) "S2DP"
                    set SAOCOMSwathInit(3) "S3DP"; set SAOCOMSwathInit(4) "S4DP"
                    set SAOCOMSwathInit(5) "S5DP"; set SAOCOMSwathInit(6) "S6DP"
                    set SAOCOMSwathInit(7) "S7DP"; set SAOCOMSwathInit(8) "S8DP"
                    set SAOCOMSwathInit(9) "S9DP"; set SAOCOMSwathInit(10) "S10DP"
                    }
                if {$SAOCOMpolMode == "QP" } {
                    set iNswath 10; set iSiDP 10; set iMax 40
                    set SAOCOMSwathInit(1) "S1QP"; set SAOCOMSwathInit(2) "S2QP"
                    set SAOCOMSwathInit(3) "S3QP"; set SAOCOMSwathInit(4) "S4QP"
                    set SAOCOMSwathInit(5) "S5QP"; set SAOCOMSwathInit(6) "S6QP"
                    set SAOCOMSwathInit(7) "S7QP"; set SAOCOMSwathInit(8) "S8QP"
                    set SAOCOMSwathInit(9) "S9QP"; set SAOCOMSwathInit(10) "S10QP"
                    }
                if {$SAOCOMpolMode == "CP" } {
                    set iNswath 7; set iSiDP 9; set iMax 14
                    set SAOCOMSwathInit(1) "S1CP"; set SAOCOMSwathInit(2) "S2CP"
                    set SAOCOMSwathInit(3) "S3CP"; set SAOCOMSwathInit(4) "S4CP"
                    set SAOCOMSwathInit(5) "S5CP"; set SAOCOMSwathInit(6) "S6CP"
                    set SAOCOMSwathInit(7) "S7CP"; set SAOCOMSwathInit(8) "S8CP"
                    set SAOCOMSwathInit(9) "S9CP"; set SAOCOMSwathInit(10) "S10CP"
                    }
                set i 1
                set stop2 0
                for {set j 1} {$j <= $iSiDP} {incr j} {
                    if {$stop2 == 0} {
                        set SAOCOMSwathCurrent $SAOCOMSwathInit($j)
                        set stop1 0 
                        for {set k 1} {$k <= $iMax} {incr k} {
                            if {$stop1 == 0} {
                                if {$SAOCOMSwath($k) == $SAOCOMSwathCurrent} {
                                    set SAOCOMSwathTOPSAR($i) $SAOCOMSwathCurrent                              
                                    set stop1 1
                                    incr i
                                    if {$i > $iNswath} { set stop2 1 }
                                    }
                                }
                            }
                        }
                    }
                set VarSAOCOMSwath ""
                set SAOCOMCurrentSwath $SAOCOMSwathTOPSAR(1)
                set SAOCOMCurrentSwathInd 1
                $widget(TitleFrame467_100) configure -state normal
                $widget(Entry467_100) configure -disabledbackground #FFFFFF
                $widget(Button467_100) configure -state normal
                $widget(Button467_101) configure -state normal
                $widget(Button467_102) configure -state normal
                tkwait variable VarSAOCOMSwath
                set SAOCOMSwathInfo [string tolower $SAOCOMCurrentSwath]
                $widget(TitleFrame467_100) configure -state disable
                $widget(Button467_100) configure -state disable
                $widget(Button467_101) configure -state disable
                $widget(Button467_102) configure -state disable
                }

            DeleteFile $TMPSaocomConfig
            set SAOCOMFile "$SAOCOMDirOutput/data_header.txt"
            set Sensor "saocomdata"
            set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
            for {set i 1} {$i <= $iMax} {incr i} {
                if { [string first $SAOCOMSwathInfo $SAOCOMFileData($i)] != "-1" } { set FileInputTmpTmp $SAOCOMFileData($i) }
                } 
            append FileInputTmp $FileInputTmpTmp
            ReadXML $FileInputTmp $SAOCOMFile $TMPSaocomConfig $Sensor
            WaitUntilCreated $TMPSaocomConfig
            if [file exists $TMPSaocomConfig] {
                set f [open $TMPSaocomConfig r]
                gets $f SAOCOMNRow
                gets $f SAOCOMNCol
                gets $f Tmp
                gets $f Tmp
                gets $f Tmp
                gets $f SAOCOMResAz
                set SAOCOMResAz [expr round($SAOCOMResAz * 1000.0) / 1000.0]
                gets $f SAOCOMResRg
                set SAOCOMResRg [expr round($SAOCOMResRg * 1000.0) / 1000.0]
                close $f
                }

            set SAOCOMDataLevelTmp $SAOCOMDataLevel
            if {$SAOCOMDataLevel == "HH-HV-VH-VV" } { set SAOCOMDataLevel "quad"; set PolarType "full" }
            if {$SAOCOMDataLevel == "HH-HV" } { set SAOCOMDataLevel "dual"; set PolarType "pp1" }
            if {$SAOCOMDataLevel == "VH-VV" } { set SAOCOMDataLevel "dual"; set PolarType "pp2" }
            if {$SAOCOMDataLevel == "LeftH-LeftV" } { set SAOCOMDataLevel "dual"; set PolarType "pp1" }
            if {$SAOCOMDataLevel == "RightH-RightV" } { set SAOCOMDataLevel "dual"; set PolarType "pp1" }

            if {$SAOCOMDataFormat == $SAOCOMDataLevel } {

                if {$SAOCOMPass == "ASCENDING" } { set SAOCOMAntennaPass "A" } else { set SAOCOMAntennaPass "D" }
                if {$SAOCOMAntenna == "Right" } { append SAOCOMAntennaPass "R" } else { append SAOCOMAntennaPass "L" }

                if {$SAOCOMBeamID == "S1QP" } {
                    set SAOCOMIncidenceAngle [expr (17.6 + 19.6) / 2]
                    }
                if {$SAOCOMBeamID == "S2QP" } {
                    set SAOCOMIncidenceAngle [expr (19.5 + 21.5) / 2]
                    }
                if {$SAOCOMBeamID == "S3QP" } {
                    set SAOCOMIncidenceAngle [expr (21.4 + 23.3) / 2]
                    }
                if {$SAOCOMBeamID == "S4QP" } {
                    set SAOCOMIncidenceAngle [expr (23.2 + 25.4) / 2]
                    }
                if {$SAOCOMBeamID == "S5QP" } {
                    set SAOCOMIncidenceAngle [expr (25.3 + 27.3) / 2]
                    }
                if {$SAOCOMBeamID == "S6QP" } {
                    set SAOCOMIncidenceAngle [expr (27.2 + 29.6) / 2]
                    }
                if {$SAOCOMBeamID == "S7QP" } {
                    set SAOCOMIncidenceAngle [expr (29.6 + 31.2) / 2]
                    }
                if {$SAOCOMBeamID == "S8QP" } {
                    set SAOCOMIncidenceAngle [expr (31.2 + 33.0) / 2]
                    }
                if {$SAOCOMBeamID == "S9QP" } {
                    set SAOCOMIncidenceAngle [expr (33.0 + 34.6) / 2]
                    }
                if {$SAOCOMBeamID == "S10QP" } {
                    set SAOCOMIncidenceAngle [expr (34.6 + 35.5) / 2]
                    }
                if {$SAOCOMBeamID == "S1CP" } {
                    set SAOCOMIncidenceAngle [expr (20.7 + 25.0) / 2]
                    }
                if {$SAOCOMBeamID == "S2CP" } {
                    set SAOCOMIncidenceAngle [expr (24.9 + 29.2) / 2]
                    }
                if {$SAOCOMBeamID == "S3CP" } {
                    set SAOCOMIncidenceAngle [expr (29.1 + 33.8) / 2]
                    }
                if {$SAOCOMBeamID == "S4CP" } {
                    set SAOCOMIncidenceAngle [expr (33.7 + 38.3) / 2]
                    }
                if {$SAOCOMBeamID == "S5CP" } {
                    set SAOCOMIncidenceAngle [expr (38.2 + 41.3) / 2]
                    }
                if {$SAOCOMBeamID == "S6CP" } {
                    set SAOCOMIncidenceAngle [expr (41.3 + 44.5) / 2]
                    }
                if {$SAOCOMBeamID == "S7CP" } {
                    set SAOCOMIncidenceAngle [expr (44.6 + 47.1) / 2]
                    }
                if {$SAOCOMBeamID == "S8CP" } {
                    set SAOCOMIncidenceAngle [expr (47.2 + 48.7) / 2]
                    }
                if {$SAOCOMBeamID == "S9CP" } {
                    set SAOCOMIncidenceAngle [expr (48.8 + 50.2) / 2]
                    }
                if {$SAOCOMBeamID == "S1DP" } {
                    set SAOCOMIncidenceAngle [expr (20.7 + 25.0) / 2]
                    }
                if {$SAOCOMBeamID == "S2DP" } {
                    set SAOCOMIncidenceAngle [expr (24.9 + 29.2) / 2]
                    }
                if {$SAOCOMBeamID == "S3DP" } {
                    set SAOCOMIncidenceAngle [expr (29.1 + 33.8) / 2]
                    }
                if {$SAOCOMBeamID == "S4DP" } {
                    set SAOCOMIncidenceAngle [expr (33.7 + 38.3) / 2]
                    }
                if {$SAOCOMBeamID == "S5DP" } {
                    set SAOCOMIncidenceAngle [expr (38.2 + 41.3) / 2]
                    }
                if {$SAOCOMBeamID == "S6DP" } {
                    set SAOCOMIncidenceAngle [expr (41.3 + 44.5) / 2]
                    }
                if {$SAOCOMBeamID == "S7DP" } {
                    set SAOCOMIncidenceAngle [expr (44.6 + 47.1) / 2]
                    }
                if {$SAOCOMBeamID == "S8DP" } {
                    set SAOCOMIncidenceAngle [expr (47.2 + 48.7) / 2]
                    }
                if {$SAOCOMBeamID == "S9DP" } {
                    set SAOCOMIncidenceAngle [expr (48.8 + 50.2) / 2]
                    }

                if {$SAOCOMacqMode == "TN" } {
                    if {$SAOCOMBeamID == "TNAQP" } { set SAOCOMIncidenceAngle [expr (17.6 + 27.3) / 2] }
                    if {$SAOCOMBeamID == "TNADP" } { set SAOCOMIncidenceAngle [expr (24.9 + 38.3) / 2] }
                    if {$SAOCOMBeamID == "TNACP" } { set SAOCOMIncidenceAngle [expr (24.9 + 38.3) / 2] }
                    if {$SAOCOMBeamID == "TNBQP" } { set SAOCOMIncidenceAngle [expr (27.2 + 35.5) / 2] }
                    if {$SAOCOMBeamID == "TNBDP" } { set SAOCOMIncidenceAngle [expr (38.2 + 47.1) / 2] }
                    if {$SAOCOMBeamID == "TNBCP" } { set SAOCOMIncidenceAngle [expr (38.2 + 47.1) / 2] }
                    }
                if {$SAOCOMacqMode == "TW" } {
                    if {$SAOCOMBeamID == "TWQP" } { 
                        set SAOCOMIncidenceAngle [expr (17.6 + 35.5) / 2]
                        } else {
                        set SAOCOMIncidenceAngle [expr (24.9 + 48.7) / 2]
                        }
                    }
                set SAOCOMIncidenceAngle [expr round($SAOCOMIncidenceAngle * 1000.0) / 1000.0]

                set f [open "$SAOCOMDirOutput/config_acquisition.txt" w]
                puts $f $SAOCOMAntennaPass
                puts $f $SAOCOMIncidenceAngle
                puts $f $SAOCOMResRg
                puts $f $SAOCOMResAz
                close $f

                set SAOCOMTypeData $SAOCOMDataType
                set SAOCOMLevelData $SAOCOMDataLevelTmp
                set SAOCOMModeAcq $SAOCOMacqMode
                set SAOCOMIDBeam $SAOCOMBeamID

                $widget(Label467_10) configure -state normal; $widget(Entry467_10) configure -disabledbackground #FFFFFF
                $widget(Label467_11) configure -state normal; $widget(Entry467_11) configure -disabledbackground #FFFFFF
                $widget(Label467_12) configure -state normal; $widget(Entry467_12) configure -disabledbackground #FFFFFF
                $widget(Label467_13) configure -state normal; $widget(Entry467_13) configure -disabledbackground #FFFFFF
                $widget(Label467_14) configure -state normal; $widget(Entry467_14) configure -disabledbackground #FFFFFF
                $widget(Label467_15) configure -state normal; $widget(Entry467_15) configure -disabledbackground #FFFFFF
                $widget(Label467_16) configure -state normal; $widget(Entry467_16) configure -disabledbackground #FFFFFF

                if {$PolarType == "full" } {
                    $widget(Entry467_1) configure -disabledbackground #FFFFFF
                    $widget(TitleFrame467_1) configure -text "Input Data File (s11)"
                    set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                    for {set i 1} {$i <= $iMax} {incr i} {
                        if { [string first "$SAOCOMSwathInfo-hh.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                        } 
                    set FileInput1 ""; if [file exists $FileInputTmp] { set FileInput1 $FileInputTmp }
                    $widget(Entry467_2) configure -disabledbackground #FFFFFF
                    $widget(TitleFrame467_2) configure -text "Input Data File (s12)"
                    set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                    for {set i 1} {$i <= $iMax} {incr i} {
                        if { [string first "$SAOCOMSwathInfo-hv.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                        } 
                    set FileInput2 ""; if [file exists $FileInputTmp] { set FileInput2 $FileInputTmp }
                    $widget(Entry467_3) configure -disabledbackground #FFFFFF
                    $widget(TitleFrame467_3) configure -text "Input Data File (s21)"
                    set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                    for {set i 1} {$i <= $iMax} {incr i} {
                        if { [string first "$SAOCOMSwathInfo-vh.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                        } 
                    set FileInput3 ""; if [file exists $FileInputTmp] { set FileInput3 $FileInputTmp }
                    $widget(Entry467_4) configure -disabledbackground #FFFFFF
                    $widget(TitleFrame467_4) configure -text "Input Data File (s22)"
                    set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                    for {set i 1} {$i <= $iMax} {incr i} {
                        if { [string first "$SAOCOMSwathInfo-vv.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                        } 
                    set FileInput4 ""; if [file exists $FileInputTmp] { set FileInput4 $FileInputTmp }
                    } else {
                    if {$PolarType == "pp1" } { set channel1 "Channel1 = HH"; set channel2 "Channel2 = HV"}
                    if {$PolarType == "pp2" } { set channel1 "Channel1 = VV"; set channel2 "Channel2 = VH"}
                    $widget(Entry467_1) configure -disabledbackground #FFFFFF
                    $widget(TitleFrame467_1) configure -text "Input Data File ($channel1)"
                    $widget(Entry467_2) configure -disabledbackground #FFFFFF
                    $widget(TitleFrame467_2) configure -text "Input Data File ($channel2)"
                    $widget(Entry467_3) configure -disabledbackground $PSPBackgroundColor
                    $widget(TitleFrame467_3) configure -text ""
                    $widget(Entry467_4) configure -disabledbackground $PSPBackgroundColor
                    $widget(TitleFrame467_4) configure -text ""
                    if {$PolarType == "pp1" } {
                        set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                        for {set i 1} {$i <= $iMax} {incr i} {
                            if { [string first "$SAOCOMSwathInfo-hh.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                            } 
                        set FileInput1 ""; if [file exists $FileInputTmp] { set FileInput1 $FileInputTmp }
                        set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                        for {set i 1} {$i <= $iMax} {incr i} {
                            if { [string first "$SAOCOMSwathInfo-hv.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                            } 
                        set FileInput2 ""; if [file exists $FileInputTmp] { set FileInput2 $FileInputTmp }
                        }                        
                    if {$PolarType == "pp2" } {
                        set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                        for {set i 1} {$i <= $iMax} {incr i} {
                            if { [string first "$SAOCOMSwathInfo-vv.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                            } 
                        set FileInput1 ""; if [file exists $FileInputTmp] { set FileInput1 $FileInputTmp }
                        set FileInputTmp [file rootname $SAOCOMProductFile]; append FileInputTmp "/"
                        for {set i 1} {$i <= $iMax} {incr i} {
                            if { [string first "$SAOCOMSwathInfo-vh.xml" $SAOCOMFileData($i)] != "-1" } { append FileInputTmp [file rootname $SAOCOMFileData($i)] }
                            } 
                        set FileInput2 ""; if [file exists $FileInputTmp] { set FileInput2 $FileInputTmp }
                        }                        
                    }

                set NligFullSize $SAOCOMNRow
                set NcolFullSize $SAOCOMNCol
                $widget(Label467_1) configure -state normal; $widget(Entry467_5) configure -disabledbackground #FFFFFF
                $widget(Label467_2) configure -state normal; $widget(Entry467_6) configure -disabledbackground #FFFFFF

                #TextEditorRunTrace "Process The Function Soft/bin/data_import/saocom_google.exe" "k"
                #TextEditorRunTrace "Arguments: -id \x22$SAOCOMDirOutput\x22 -if \x22$TMPSaocomConfig\x22 -of \x22$TMPGoogle\x22" "k"
                #set f [ open "| Soft/bin/data_import/saocom_google.exe -id \x22$SAOCOMDirOutput\x22 -if \x22$TMPSaocomConfig\x22 -of \x22$TMPGoogle\x22" r]
                #PsPprogressBar $f
                #TextEditorRunTrace "Check RunTime Errors" "r"
                #CheckRunTimeError
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
                    $widget(Button467_7) configure -state normal
                    $widget(Button467_6) configure -state normal
                    }
                } else {
                set ErrorMessage "ERROR IN THE SAOCOM DATA FORMAT (DUAL / QUAD)"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set SAOCOMDataLevel ""; set SAOCOMProductFile ""; set SAOCOMFileInputFlag 0
                set datalevelerror 1
                }
            } else {
            set ErrorMessage "ERROR IN THE SAOCOM DATA TYPE (SLC - L1A)"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set SAOCOMDataLevel ""; set SAOCOMProductFile ""; set SAOCOMFileInputFlag 0
            set datalevelerror 2
            }
        } else {
        set ErrorMessage "DESCRIPTION METADATA FILE IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set SAOCOMDataLevel ""; set SAOCOMProductFile ""
        }
        #TMPSaocomConfig Exists
    } else {
    set ErrorMessage "ENTER THE XML - DESCRIPTION METADATA FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set SAOCOMDataLevel ""; set SAOCOMProductFile ""; set SAOCOMFileInputFlag 0
    }
    #ProductFile Exists


if {$datalevelerror == 1 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    if {$SAOCOMDataFormat == "quad" } { 
        TextEditorRunTrace "Close EO-SI" "b"
        set SAOCOMDataFormat "dual" 
        } else {
        TextEditorRunTrace "Close EO-SI Dual Pol" "b"
        set SAOCOMDataFormat "quad"
        }
    Window hide $widget(Toplevel467); TextEditorRunTrace "Close Window SAOCOM Input File" "b"
    }
if {$datalevelerror == 2 } {
    MenuRAZ
    ClosePSPViewer
    CloseAllWidget
    Window hide $widget(Toplevel467); TextEditorRunTrace "Close Window SAOCOM Input File" "b"
    }
}
#VarWarning
}
#OpenDirFile} \
		-padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_4_0.cpd45" "Button2" vTcl:WidgetProc "Toplevel467" 1
    TitleFrame $site_4_0.cpd44 \
		-ipad 0 -text {TOPSAR Swath} 
    vTcl:DefineAlias "$site_4_0.cpd44" "TitleFrame467_100" vTcl:WidgetProc "Toplevel467" 1
    bind $site_4_0.cpd44 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd44 getframe]
    entry $site_6_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMCurrentSwath -width 7 
    vTcl:DefineAlias "$site_6_0.cpd85" "Entry467_100" vTcl:WidgetProc "Toplevel467" 1
    frame $site_6_0.fra45 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra45" "Frame7" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.fra45
    button $site_7_0.but46 \
		\
		-command {global SAOCOMCurrentSwath SAOCOMSwathTOPSAR SAOCOMCurrentSwathInd iNswath

set SAOCOMCurrentSwathInd [expr $SAOCOMCurrentSwathInd + 1]
if {$SAOCOMCurrentSwathInd > $iNswath} { set SAOCOMCurrentSwathInd 1 }
set SAOCOMCurrentSwath $SAOCOMSwathTOPSAR($SAOCOMCurrentSwathInd)} \
		-image [vTcl:image:get_image [file join . GUI Images up.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but46" "Button467_100" vTcl:WidgetProc "Toplevel467" 1
    button $site_7_0.cpd47 \
		\
		-command {global SAOCOMCurrentSwath SAOCOMSwathTOPSAR SAOCOMCurrentSwathInd iNswath

set SAOCOMCurrentSwathInd [expr $SAOCOMCurrentSwathInd - 1]
if {$SAOCOMCurrentSwathInd == 0} { set SAOCOMCurrentSwathInd $iNswath }
set SAOCOMCurrentSwath $SAOCOMSwathTOPSAR($SAOCOMCurrentSwathInd)} \
		-image [vTcl:image:get_image [file join . GUI Images down.gif]] \
		-pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd47" "Button467_101" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.but46 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd47 \
		-in $site_7_0 -anchor center -expand 0 -fill none -side left 
    button $site_6_0.cpd48 \
		-background {#ffff00} \
		-command {global VarSAOCOMSwath
set VarSAOCOMSwath "OK"} -padx 2 \
		-pady 0 -text OK 
    vTcl:DefineAlias "$site_6_0.cpd48" "Button467_102" vTcl:WidgetProc "Toplevel467" 1
    bindtags $site_6_0.cpd48 "$site_6_0.cpd48 Button $top all _vTclBalloon"
    bind $site_6_0.cpd48 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    pack $site_6_0.cpd85 \
		-in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.fra45 \
		-in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd48 \
		-in $site_6_0 -anchor center -expand 1 -fill none -padx 4 -side left 
    button $site_4_0.cpd46 \
		\
		-command {global FileName VarError ErrorMessage SAOCOMDirInput

set SAOCOMFile "$SAOCOMDirInput/GEARTH_POLY.kml"
if [file exists $SAOCOMFile] {
    GoogleEarth $SAOCOMFile
    }} \
		-image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
		-padx 4 -pady 2 -text Google 
    vTcl:DefineAlias "$site_4_0.cpd46" "Button467_7" vTcl:WidgetProc "Toplevel467" 1
    bindtags $site_4_0.cpd46 "$site_4_0.cpd46 Button $top all _vTclBalloon"
    bind $site_4_0.cpd46 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_4_0.cpd45 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd44 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd46 \
		-in $site_4_0 -anchor center -expand 1 -fill none -side top 
    frame $site_3_0.fra56 \
		-borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra56" "Frame6" vTcl:WidgetProc "Toplevel467" 1
    set site_4_0 $site_3_0.fra56
    frame $site_4_0.cpd57 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd57" "Frame17" vTcl:WidgetProc "Toplevel467" 1
    set site_5_0 $site_4_0.cpd57
    label $site_5_0.lab82 \
		-text {Data Level} 
    vTcl:DefineAlias "$site_5_0.lab82" "Label467_10" vTcl:WidgetProc "Toplevel467" 1
    entry $site_5_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMLevelData 
    vTcl:DefineAlias "$site_5_0.ent83" "Entry467_10" vTcl:WidgetProc "Toplevel467" 1
    pack $site_5_0.lab82 \
		-in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.ent83 \
		-in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -pady 2 \
		-side right 
    frame $site_4_0.cpd58 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd58" "Frame18" vTcl:WidgetProc "Toplevel467" 1
    set site_5_0 $site_4_0.cpd58
    frame $site_5_0.fra48 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra48" "Frame19" vTcl:WidgetProc "Toplevel467" 1
    set site_6_0 $site_5_0.fra48
    frame $site_6_0.cpd50 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd50" "Frame21" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.cpd50
    label $site_7_0.lab82 \
		-text {Data Type} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label467_11" vTcl:WidgetProc "Toplevel467" 1
    entry $site_7_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMTypeData -width 7 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry467_11" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.lab82 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.ent83 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
		-side right 
    frame $site_6_0.cpd51 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd51" "Frame22" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.cpd51
    label $site_7_0.lab82 \
		-text {Acq Mode} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label467_12" vTcl:WidgetProc "Toplevel467" 1
    entry $site_7_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMModeAcq -width 7 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry467_12" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.lab82 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.ent83 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
		-side right 
    frame $site_6_0.cpd52 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd52" "Frame23" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.cpd52
    label $site_7_0.lab82 \
		-text {Beam ID} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label467_13" vTcl:WidgetProc "Toplevel467" 1
    entry $site_7_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMIDBeam -width 7 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry467_13" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.lab82 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.ent83 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
		-side right 
    pack $site_6_0.cpd50 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd51 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd52 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    frame $site_5_0.fra49 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra49" "Frame24" vTcl:WidgetProc "Toplevel467" 1
    set site_6_0 $site_5_0.fra49
    frame $site_6_0.cpd53 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd53" "Frame25" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.cpd53
    label $site_7_0.lab82 \
		-text {Inc Angle} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label467_14" vTcl:WidgetProc "Toplevel467" 1
    entry $site_7_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMIncidenceAngle -width 7 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry467_14" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.lab82 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.ent83 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
		-side right 
    frame $site_6_0.cpd54 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd54" "Frame26" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.cpd54
    label $site_7_0.lab82 \
		-text {Resol Rg} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label467_15" vTcl:WidgetProc "Toplevel467" 1
    entry $site_7_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMResRg -width 7 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry467_15" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.lab82 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.ent83 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
		-side right 
    frame $site_6_0.cpd55 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd55" "Frame27" vTcl:WidgetProc "Toplevel467" 1
    set site_7_0 $site_6_0.cpd55
    label $site_7_0.lab82 \
		-text {Resol Az} 
    vTcl:DefineAlias "$site_7_0.lab82" "Label467_16" vTcl:WidgetProc "Toplevel467" 1
    entry $site_7_0.ent83 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable SAOCOMResAz -width 7 
    vTcl:DefineAlias "$site_7_0.ent83" "Entry467_16" vTcl:WidgetProc "Toplevel467" 1
    pack $site_7_0.lab82 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_7_0.ent83 \
		-in $site_7_0 -anchor center -expand 0 -fill none -padx 10 -pady 2 \
		-side right 
    pack $site_6_0.cpd53 \
		-in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd54 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd55 \
		-in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.fra48 \
		-in $site_5_0 -anchor center -expand 0 -fill y -padx 2 -side left 
    pack $site_5_0.fra49 \
		-in $site_5_0 -anchor center -expand 0 -fill y -padx 2 -side left 
    pack $site_4_0.cpd57 \
		-in $site_4_0 -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $site_4_0.cpd58 \
		-in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra44 \
		-in $site_3_0 -anchor center -expand 1 -fill both -side left 
    pack $site_3_0.fra56 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd77 \
		-height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel467" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd98 \
		-ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame467_1" vTcl:WidgetProc "Toplevel467" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry467_1" vTcl:WidgetProc "Toplevel467" 1
    pack $site_5_0.cpd85 \
		-in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    TitleFrame $site_3_0.cpd116 \
		-ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame467_2" vTcl:WidgetProc "Toplevel467" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry467_2" vTcl:WidgetProc "Toplevel467" 1
    pack $site_5_0.cpd85 \
		-in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    TitleFrame $site_3_0.cpd117 \
		-ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame467_3" vTcl:WidgetProc "Toplevel467" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry467_3" vTcl:WidgetProc "Toplevel467" 1
    pack $site_5_0.cpd85 \
		-in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    TitleFrame $site_3_0.cpd118 \
		-ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame467_4" vTcl:WidgetProc "Toplevel467" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -state disabled \
		-textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry467_4" vTcl:WidgetProc "Toplevel467" 1
    pack $site_5_0.cpd85 \
		-in $site_5_0 -anchor center -expand 1 -fill x -padx 5 -side left 
    pack $site_3_0.cpd98 \
		-in $site_3_0 -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $site_3_0.cpd116 \
		-in $site_3_0 -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $site_3_0.cpd117 \
		-in $site_3_0 -anchor center -expand 0 -fill x -ipady 2 -side top 
    pack $site_3_0.cpd118 \
		-in $site_3_0 -anchor center -expand 0 -fill x -ipady 2 -side top 
    frame $top.fra76 \
		-borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame5" vTcl:WidgetProc "Toplevel467" 1
    set site_3_0 $top.fra76
    label $site_3_0.lab77 \
		-text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_3_0.lab77" "Label467_1" vTcl:WidgetProc "Toplevel467" 1
    entry $site_3_0.ent78 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NligFullSize -width 7 
    vTcl:DefineAlias "$site_3_0.ent78" "Entry467_5" vTcl:WidgetProc "Toplevel467" 1
    label $site_3_0.lab79 \
		-text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_3_0.lab79" "Label467_2" vTcl:WidgetProc "Toplevel467" 1
    entry $site_3_0.ent80 \
		-background white -disabledbackground {#ffffff} \
		-disabledforeground {#0000ff} -foreground {#0000ff} -justify center \
		-state disabled -textvariable NcolFullSize -width 7 
    vTcl:DefineAlias "$site_3_0.ent80" "Entry467_6" vTcl:WidgetProc "Toplevel467" 1
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
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel467" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
		-background {#ffff00} \
		-command {global SAOCOMDirOutput SAOCOMSwathInfo SAOCOMFileInputFlag SAOCOMDataFormat
global OpenDirFile
global IEEEFormat FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set SAOCOMFileInputFlag 0
if {$SAOCOMDataFormat == "quad"} {
    set SAOCOMFileFlag 0
    if {$FileInput1 != ""} {incr SAOCOMFileFlag}
    if {$FileInput2 != ""} {incr SAOCOMFileFlag}
    if {$FileInput3 != ""} {incr SAOCOMFileFlag}
    if {$FileInput4 != ""} {incr SAOCOMFileFlag}
    if {$SAOCOMFileFlag == 4} {set SAOCOMFileInputFlag 1}
    }
if {$SAOCOMDataFormat == "dual"} {
    set SAOCOMFileFlag 0
    if {$FileInput1 != ""} {incr SAOCOMFileFlag}
    if {$FileInput2 != ""} {incr SAOCOMFileFlag}
    if {$SAOCOMFileFlag == 2} {set SAOCOMFileInputFlag 1}
    }

if {$SAOCOMFileInputFlag == 1} {
    set NligInit 1
    set NligEnd $NligFullSize
    set NcolInit 1
    set NcolEnd $NcolFullSize
    set NligFullSizeInput $NligFullSize
    set NcolFullSizeInput $NcolFullSize

    set ErrorMessage ""
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel467); TextEditorRunTrace "Close Window SAOCOM Input File" "b"
    set SAOCOMSwathInfoUpper [string toupper $SAOCOMSwathInfo]
    append SAOCOMDirOutput "/$SAOCOMSwathInfoUpper"
    } else {
    set SAOCOMFileInputFlag 0
    set ErrorMessage "PROBLEM IN THE SAOCOM DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
		-padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button467_6" vTcl:WidgetProc "Toplevel467" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
		-background {#ff8000} \
		-command {HelpPdfEdit "Help/SAOCOM_Input_File.pdf"} \
		-image [vTcl:image:get_image [file join . GUI Images help.gif]] \
		-pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel467" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
		-background {#ffff00} \
		-command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel467); TextEditorRunTrace "Close Window SAOCOM Input File" "b"
}} \
		-padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel467" 1
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
Window show .top467

main $argc $argv
