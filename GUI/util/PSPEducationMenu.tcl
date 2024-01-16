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

        {{[file join . GUI Images EducationMenu.gif]} {user image} user {}}

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
    set base .top710
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.fra26
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top1
            vTclWindow.top710
            vTclWindow.top2
            vTclWindow.top5
            vTclWindow.top4
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

proc vTclWindow.top710 {base} {
    if {$base == ""} {
        set base .top710
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-menu "$top.m44" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 150x210+10+150; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Education"
    vTcl:DefineAlias "$top" "Toplevel710" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab53 \
		\
		-image [vTcl:image:get_image [file join . GUI Images EducationMenu.gif]] \
		-relief ridge -text label 
    vTcl:DefineAlias "$top.lab53" "Label171" vTcl:WidgetProc "Toplevel710" 1
    bindtags $top.lab53 "$top.lab53 Label $top all _vTclBalloon"
    bind $top.lab53 <<SetBalloon>> {
        set ::vTcl::balloon::%W {PSP 1.4}
    }
    button $top.but44 \
		\
		-command {global PlatForm

set URL "https://ietr-lab.univ-rennes1.fr/polsarpro-bio/education/lecturenotes/"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-padx 7 -pady 2 -text {Lecture Notes} 
    vTcl:DefineAlias "$top.but44" "Button1" vTcl:WidgetProc "Toplevel710" 1
    menubutton $top.men45 \
		-menu "$top.men45.m" -padx 7 -pady 5 -relief raised -text Practical 
    vTcl:DefineAlias "$top.men45" "Menubutton1" vTcl:WidgetProc "Toplevel710" 1
    menu $top.men45.m \
		-activeborderwidth 1 -borderwidth 1 -font {{Segoe UI} 9} -tearoff 0 
    $top.men45.m add command \
		\
		-command {global PlatForm

set URL "https://ietr-lab.univ-rennes1.fr/polsarpro-bio/education/practical/"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {Do It Yourself} 
    $top.men45.m add separator \
		
    $top.men45.m add command \
		\
		-command {global PolSARapShortcut

if {$PolSARapShortcut == 0} {
    set PolSARapShortcut 1
    Window show $widget(Toplevel530); TextEditorRunTrace "Open Window PolSARap Showcase : Menu" "b"
    } else {
    set PolSARapShortcut 0
    Window hide $widget(Toplevel530); TextEditorRunTrace "Close Window PolSARap Showcase : Menu" "b"
    }} \
		-label {ESA PolSAR-Apps project : showcases} 
    button $top.cpd46 \
		\
		-command {global PlatForm

set URL "https://ietr-lab.univ-rennes1.fr/polsarpro-bio/education/tutorial/"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-padx 7 -pady 2 -text Tutorial 
    vTcl:DefineAlias "$top.cpd46" "Button3" vTcl:WidgetProc "Toplevel710" 1
    menubutton $top.men44 \
		-menu "$top.men44.m" -padx 7 -pady 5 -relief raised \
		-text {Online Education} 
    vTcl:DefineAlias "$top.men44" "Menubutton2" vTcl:WidgetProc "Toplevel710" 1
    menu $top.men44.m \
		-activeborderwidth 1 -borderwidth 1 -font {{Segoe UI} 9} -tearoff 0 
    $top.men44.m add command \
		\
		-command {global PlatForm

set URL "https://earth.esa.int/web/guest/eo-education-and-training"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {ESA - EO Education and Training} 
    $top.men44.m add command \
		\
		-command {global PlatForm

set URL "https://earth.esa.int/web/guest/eo-education-and-trainingweb/eo-edu/education-for-schools"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {ESA - EO Education for Schools} 
    $top.men44.m add command \
		\
		-command {global PlatForm

set URL "https://earth.esa.int/web/guest/eo-education-and-trainingweb/eo-edu/pis-advanced-training"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {ESA - Advanced EO Training for PIs} 
    $top.men44.m add command \
		\
		-command {global PlatForm

set URL "https://earth.esa.int/web/guest/eo-education-and-training/university-undergraduate-level"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {ESA - Other EO Training} 
    $top.men44.m add separator \
		
    $top.men44.m add command \
		\
		-command {global PlatForm

set URL "https://eo-college.org/landingpage/"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {EO College} 
    $top.men44.m add command \
		\
		-command {global PlatForm

set URL "https://rus-training.eu/"
if {$PlatForm == "windows"} {
    eval exec [auto_execok start] $URL
    } else {
    exec xdg-open $URL
    }} \
		-label {EU - RUS Training} 
    frame $top.fra26 \
		-borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra26" "Frame413" vTcl:WidgetProc "Toplevel710" 1
    set site_3_0 $top.fra26
    button $site_3_0.but27 \
		-background {#ffff00} \
		-command {global OpenDirFile
global Load_PSPEducationMenu 

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel710); TextEditorRunTrace "Close Window PolSARpro-Bio Education Menu" "b"
}} \
		-padx 4 -pady 2 -text Exit -width 4 
    vTcl:DefineAlias "$site_3_0.but27" "Button35" vTcl:WidgetProc "Toplevel710" 1
    bindtags $site_3_0.but27 "$site_3_0.but27 Button $top all _vTclBalloon"
    bind $site_3_0.but27 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit Tools}
    }
    pack $site_3_0.but27 \
		-in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m44 \
		-activeborderwidth 1 -borderwidth 1 -cursor {} -font {{Segoe UI} 9} 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab53 \
		-in $top -anchor center -expand 0 -fill none -side top 
    pack $top.but44 \
		-in $top -anchor center -expand 1 -fill x -ipady 1 -pady 1 -side top 
    pack $top.men45 \
		-in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd46 \
		-in $top -anchor center -expand 1 -fill x -ipady 1 -pady 1 -side top 
    pack $top.men44 \
		-in $top -anchor center -expand 1 -fill x -ipady 1 -side top 
    pack $top.fra26 \
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
Window show .top710

main $argc $argv
