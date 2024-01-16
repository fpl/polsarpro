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
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images GIMPshortcut.gif]} {user image} user {}}

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
    set base .top74
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd81
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
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd82 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra76
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
    namespace eval ::widgets::$base.cpd72 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-foreground 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.lab80 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-foreground 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd75
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.che38 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra82
    namespace eval ::widgets::$site_3_0.fra24 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra24
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd81
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but25 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but71 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
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
            vTclWindow.top74
            HAAlphaDecomposition
            HAAlphaDecompositionBMP
            HAAlphaClassification
            RGBHAAlphaBMP
            RGBHACombBMP
            RGBTuoTuoBMP
            HAlphaLambdaClassification
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
## Procedure:  HAAlphaDecomposition

proc ::HAAlphaDecomposition {} {
global HAAlpDirInput HAAlpDirOutput HAAlphaClassifFonction
global OffsetLig OffsetCol FinalNlig FinalNcol 
global NwinHAAlpL NwinHAAlpC entropy alpha anisotropy lambda CombHA CombH1mA Comb1mHA Comb1mH1mA
global ProgressLine TMPMemoryAllocError

set MaskCmd ""
set MaskFile "$HAAlpDirInput/mask_valid_pixels.bin"
if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
if {$HAAlphaClassifFonction == "S2m"} { set HAAlphaClassifF "S2T3" } 
if {$HAAlphaClassifFonction == "S2b"} { set HAAlphaClassifF "S2T4" }
if {$HAAlphaClassifFonction == "SPP"} { set HAAlphaClassifF "SPPC2" }
if {$HAAlphaClassifFonction == "T3"} { set HAAlphaClassifF "T3" }
if {$HAAlphaClassifFonction == "C2"} { set HAAlphaClassifF "C2" }
if {$HAAlphaClassifFonction == "C3"} { set HAAlphaClassifF "C3T3" }
if {$HAAlphaClassifFonction == "T4"} { set HAAlphaClassifF "T4" }
if {$HAAlphaClassifFonction == "C4"} { set HAAlphaClassifF "C4T4" }
TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
TextEditorRunTrace "Arguments: -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaClassifF -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 $lambda -fl3 $alpha -fl4 $entropy -fl5 $anisotropy -fl6 $CombHA -fl7 $CombH1mA -fl8 $Comb1mHA -fl9 $Comb1mH1mA  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$HAAlpDirInput\x22 -od \x22$HAAlpDirOutput\x22 -iodf $HAAlphaClassifF -nwr $NwinHAAlpL -nwc $NwinHAAlpC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 $lambda -fl3 $alpha -fl4 $entropy -fl5 $anisotropy -fl6 $CombHA -fl7 $CombH1mA -fl8 $Comb1mHA -fl9 $Comb1mH1mA  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

if [file exists "$HAAlpDirOutput/alpha.bin"] {EnviWriteConfig "$HAAlpDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/entropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/anisotropy.bin"] {EnviWriteConfig "$HAAlpDirOutput/anisotropy.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/lambda.bin"] {EnviWriteConfig "$HAAlpDirOutput/lambda.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/combination_HA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_HA.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_H1mA.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/combination_1mHA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_1mHA.bin" $FinalNlig $FinalNcol 4}
if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {EnviWriteConfig "$HAAlpDirOutput/combination_1mH1mA.bin" $FinalNlig $FinalNcol 4}
}
#############################################################################
## Procedure:  HAAlphaDecompositionBMP

proc ::HAAlphaDecompositionBMP {} {
global HAAlpDirOutput BMPDirInput
global OffsetLig OffsetCol FinalNlig FinalNcol 
global Fonction Fonction2 VarFunction VarError ErrorMessage ProgressLine
global entropy anisotropy alpha lambda CombHA CombH1mA Comb1mHA Comb1mH1mA

if {$alpha == 1} {
  if [file exists "$HAAlpDirOutput/alpha.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/alpha.bin"
    set BMPFileOutput "$HAAlpDirOutput/alpha.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 90
    }
  }
if {$entropy == 1} {
  if [file exists "$HAAlpDirOutput/entropy.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/entropy.bin"
    set BMPFileOutput "$HAAlpDirOutput/entropy.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
    }
  }
if {$anisotropy == 1} {
  if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/anisotropy.bin"
    set BMPFileOutput "$HAAlpDirOutput/anisotropy.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
    }
  }
if {$lambda == 1} {
  if [file exists "$HAAlpDirOutput/lambda.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/lambda.bin"
    set BMPFileOutput "$HAAlpDirOutput/lambda_db.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
    }
  }
if {$CombHA == 1} {
  if [file exists "$HAAlpDirOutput/combination_HA.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/combination_HA.bin"
    set BMPFileOutput "$HAAlpDirOutput/combination_HA.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
    }
  }
if {$CombH1mA == 1} {
  if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/combination_H1mA.bin"
    set BMPFileOutput "$HAAlpDirOutput/combination_H1mA.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
    }
  }
if {$Comb1mHA == 1} {
  if [file exists "$HAAlpDirOutput/combination_1mHA.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/combination_1mHA.bin"
    set BMPFileOutput "$HAAlpDirOutput/combination_1mHA.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
    }
  }
if {$Comb1mH1mA == 1} {
  if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {
    set BMPDirInput $HAAlpDirOutput
    set BMPFileInput "$HAAlpDirOutput/combination_1mH1mA.bin"
    set BMPFileOutput "$HAAlpDirOutput/combination_1mH1mA.bmp"
    PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
    }
  }
}
#############################################################################
## Procedure:  HAAlphaClassification

proc ::HAAlphaClassification {} {
global HAAlpDirOutput ColorMapPlanes9 TMPMemoryAllocError
global Halpha_plane HA_plane Aalpha_plane HAAlphaClassifFonction
global OffsetLig OffsetCol FinalNlig FinalNcol 
global Fonction Fonction2 VarError ErrorMessage ProgressLine

set conf "true"
if {"$Halpha_plane"=="1"} {
    if [file exists "$HAAlpDirOutput/entropy.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if [file exists "$HAAlpDirOutput/alpha.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE alpha DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    } 
if {"$HA_plane"=="1"} {
    if [file exists "$HAAlpDirOutput/entropy.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE anisotropy DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    } 
if {"$Aalpha_plane"=="1"} {
    if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE anisotropy DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if [file exists "$HAAlpDirOutput/alpha.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE alpha DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    } 

if {"$conf"=="true"} {
    set Fonction "H/A/Alpha PLANES & CLASSIFICATION"
    set Fonction2 "and the associated BMP files"
    set MaskCmd ""
    set MaskFile "$HAAlpDirOutput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    set ProcessFunction "Soft/bin/data_process_sngl/h_a_alpha_planes_classifier.exe"
    if {$HAAlphaClassifFonction == "C2"} {set ProcessFunction "Soft/bin/data_process_sngl/h_a_alpha_planes_classifier_dualpol.exe"}
    if {$HAAlphaClassifFonction == "SPP"} {set ProcessFunction "Soft/bin/data_process_sngl/h_a_alpha_planes_classifier_dualpol.exe"}
    TextEditorRunTrace "Process The Function $ProcessFunction" "k"
    TextEditorRunTrace "Arguments: -id \x22$HAAlpDirOutput\x22 -od \x22$HAAlpDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hal $Halpha_plane -anal $Aalpha_plane -han $HA_plane -clm \x22$ColorMapPlanes9\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| $ProcessFunction -id \x22$HAAlpDirOutput\x22 -od \x22$HAAlpDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -hal $Halpha_plane -anal $Aalpha_plane -han $HA_plane -clm \x22$ColorMapPlanes9\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    if {"$Halpha_plane"=="1"} {
      if [file exists "$HAAlpDirOutput/H_alpha_class.bin"] { 
        EnviWriteConfigClassif "$HAAlpDirOutput/H_alpha_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes9 9
        set BMPFileInput "$HAAlpDirOutput/H_alpha_class.bin"
        set BMPFileOutput "$HAAlpDirOutput/H_alpha_class.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real $ColorMapPlanes9 $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 255
        set Bord "HAlpha"
        if {$HAAlphaClassifFonction == "C2" || $HAAlphaClassifFonction == "SPP"} {set Bord "HAlphaDual"}
        PsPScatterPlot "$HAAlpDirOutput/entropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$HAAlpDirOutput/alpha.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane" 1 .top74
        PsPScatterPlotColor "$HAAlpDirOutput/entropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$HAAlpDirOutput/alpha.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane" 1 .top74
        }
      }
    if {"$Aalpha_plane"=="1"} {
      if [file exists "$HAAlpDirOutput/A_alpha_class.bin"] { 
        EnviWriteConfigClassif "$HAAlpDirOutput/A_alpha_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes9 9 
        set BMPFileInput "$HAAlpDirOutput/A_alpha_class.bin"
        set BMPFileOutput "$HAAlpDirOutput/A_alpha_class.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real $ColorMapPlanes9 $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 255
        set Bord "AAlpha"
        PsPScatterPlot "$HAAlpDirOutput/anisotropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$HAAlpDirOutput/alpha.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Anisotropy" "Alpha (deg)" "A - Alpha Plane" 2 .top74
        PsPScatterPlotColor "$HAAlpDirOutput/anisotropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$HAAlpDirOutput/alpha.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Anisotropy" "Alpha (deg)" "A - Alpha Plane" 2 .top74
        }
      }
    if {"$HA_plane"=="1"} {
      if [file exists "$HAAlpDirOutput/H_A_class.bin"] { 
        EnviWriteConfigClassif "$HAAlpDirOutput/H_A_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes9 9
        set BMPFileInput "$HAAlpDirOutput/H_A_class.bin"
        set BMPFileOutput "$HAAlpDirOutput/H_A_class.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real $ColorMapPlanes9 $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 255
        set Bord "HA"
        PsPScatterPlot "$HAAlpDirOutput/entropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$HAAlpDirOutput/anisotropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Anisotropy" "H - A Plane" 3 .top74
        PsPScatterPlotColor "$HAAlpDirOutput/entropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 "$HAAlpDirOutput/anisotropy.bin" "$HAAlpDirOutput/mask_valid_pixels.bin" float real 0 0 1 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Anisotropy" "H - A Plane" 3 .top74
        }
      }
    }
}
#############################################################################
## Procedure:  RGBHAAlphaBMP

proc ::RGBHAAlphaBMP {} {
global HAAlpDirOutput BMPDirInput TMPMemoryAllocError
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize
global Fonction Fonction2 VarError ErrorMessage ProgressLine PSPViewGimpBMP

set conf "true"
if [file exists "$HAAlpDirOutput/entropy.bin"] {
    set FileInputGreen "$HAAlpDirOutput/entropy.bin"
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if [file exists "$HAAlpDirOutput/alpha.bin"] {
    set FileInputBlue "$HAAlpDirOutput/alpha.bin"
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE alpha DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
    set FileInputRed "$HAAlpDirOutput/anisotropy.bin"
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE anisotropy DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } 

if {$conf == "true"} {
    set RGBFileOutput "$HAAlpDirOutput/HAAlpha_RGB.bmp"
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set MaskCmd ""
    set MaskDir [file dirname $FileInputBlue]
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    set BMPDirInput $HAAlpDirOutput
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGBHACombBMP

proc ::RGBHACombBMP {} {
global HAAlpDirOutput BMPDirInput TMPMemoryAllocError
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize
global Fonction Fonction2 VarError ErrorMessage ProgressLine PSPViewGimpBMP

set conf "true"
if [file exists "$HAAlpDirOutput/combination_H1mA.bin"] {
    set FileInputGreen "$HAAlpDirOutput/combination_H1mA.bin"
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE combination_H1mA DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

if [file exists "$HAAlpDirOutput/combination_1mH1mA.bin"] {
    set FileInputBlue "$HAAlpDirOutput/combination_1mH1mA.bin"
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE combination_1mH1mA DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if [file exists "$HAAlpDirOutput/anisotropy.bin"] {
    set FileInputRed "$HAAlpDirOutput/anisotropy.bin"
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE anisotropy DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }

if {$conf == "true"} {
    set RGBFileOutput "$HAAlpDirOutput/HAcombinations_RGB.bmp"
    set Fonction "Creation of the RGB BMP File :"
    set Fonction2 "$RGBFileOutput"    
    set MaskCmd ""
    set MaskDir [file dirname $FileInputBlue]
    set MaskFile "$MaskDir/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_rgb_file.exe" "k"
    TextEditorRunTrace "Arguments: -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bin/bmp_process/create_rgb_file.exe -ifb \x22$FileInputBlue\x22 -ifg \x22$FileInputGreen\x22 -ifr \x22$FileInputRed\x22 -of \x22$RGBFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -auto 1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    set BMPDirInput $HAAlpDirOutput
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $RGBFileOutput }
    }
}
#############################################################################
## Procedure:  RGBTuoTuoBMP

proc ::RGBTuoTuoBMP {} {
global HAAlpDirOutput BMPDirInput TMPMemoryAllocError
global OffsetLig OffsetCol FinalNlig FinalNcol NcolFullSize
global Fonction Fonction2 VarError ErrorMessage ProgressLine PSPViewGimpBMP

set conf "true"
if [file exists "$HAAlpDirOutput/entropy.bin"] {
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if [file exists "$HAAlpDirOutput/alpha.bin"] {
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE alpha DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if [file exists "$HAAlpDirOutput/lambda.bin"] {
    } else {
    set conf "false"
    set VarError ""
    set ErrorMessage "THE FILE lambda DOES NOT EXIST" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } 

if {$conf == "true"} {
    set HSVFileOutput "$HAAlpDirOutput/HAlphaLambda_RGB.bmp"
    set Fonction "Creation of the HSV BMP File :"
    set Fonction2 "$HSVFileOutput"    
    set MaskCmd ""
    set MaskFile "$HAAlpDirOutput/mask_valid_pixels.bin"
    if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    TextEditorRunTrace "Process The Function Soft/bin/bmp_process/create_polar0_hsv_file.exe" "k"
    TextEditorRunTrace "Arguments: -id \x22$HAAlpDirOutput\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| Soft/bin/bmp_process/create_polar0_hsv_file.exe -id \x22$HAAlpDirOutput\x22 -of \x22$HSVFileOutput\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    set BMPDirInput $HAAlpDirOutput
    if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $HSVFileOutput }
    }
}
#############################################################################
## Procedure:  HAlphaLambdaClassification

proc ::HAlphaLambdaClassification {} {
global HAAlpDirOutput ColorMapPlanes27 TMPMemoryAllocError
global HalphaLambda_plane HAAlphaClassifFonction PSPViewGimpBMP
global OffsetLig OffsetCol FinalNlig FinalNcol 
global Fonction Fonction2 VarError ErrorMessage ProgressLine

set conf "true"
if {"$HalphaLambda_plane"=="1"} {
    if [file exists "$HAAlpDirOutput/entropy.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if [file exists "$HAAlpDirOutput/alpha.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE alpha DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if [file exists "$HAAlpDirOutput/lambda.bin"] {
        } else {
        set conf "false"
        set VarError ""
        set ErrorMessage "THE FILE lambda DOES NOT EXIST" 
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    } 

if {"$conf"=="true"} {
    set Fonction "H/Alpha/Lambda PLANES & CLASSIFICATION"
    set Fonction2 "and the associated BMP files"
    set MaskCmd ""
    set MaskFile "$HAAlpDirOutput/mask_valid_pixels.bin"
    if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    set ProcessFunction "Soft/bin/data_process_sngl/h_alpha_lambda_planes_classifier.exe"
    if {$HAAlphaClassifFonction == "C2"} {set ProcessFunction "Soft/bin/data_process_sngl/h_alpha_lambda_planes_classifier_dualpol.exe"}
    if {$HAAlphaClassifFonction == "SPP"} {set ProcessFunction "Soft/bin/data_process_sngl/h_alpha_lambda_planes_classifier_dualpol.exe"}
    TextEditorRunTrace "Process The Function $ProcessFunction" "k"
    TextEditorRunTrace "Arguments: -id \x22$HAAlpDirOutput\x22 -od \x22$HAAlpDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -clm \x22$ColorMapPlanes27\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
    set f [ open "| $ProcessFunction -id \x22$HAAlpDirOutput\x22 -od \x22$HAAlpDirOutput\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -clm \x22$ColorMapPlanes27\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    if {$HAAlphaClassifFonction == "C2" || $HAAlphaClassifFonction == "SPP"} {set Bord "HAlphaDual"}
    if [file exists "$HAAlpDirOutput/H_alpha_lambda_class.bin"] {
        EnviWriteConfigClassif "$HAAlpDirOutput/H_alpha_lambda_class.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes27 27
        set BMPFileInput "$HAAlpDirOutput/H_alpha_lambda_class.bin"
        set BMPFileOutput "$HAAlpDirOutput/H_alpha_lambda_class.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real $ColorMapPlanes27 $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 255
        }
    if [file exists "$HAAlpDirOutput/H_alpha_lambda_class1.bin"] {
        EnviWriteConfigClassif "$HAAlpDirOutput/H_alpha_lambda_class1.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes27 27
        set BMPFileInput "$HAAlpDirOutput/H_alpha_lambda_class1.bin"
        set BMPFileOutput "$HAAlpDirOutput/H_alpha_lambda_class1.bmp"
        set MaskCmd ""
        set MaskFile "$HAAlpDirOutput/mask_low_lambda.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        set ProcessFunction "Soft/bin/bmp_process/create_bmp_file.exe"
        TextEditorRunTrace "Process The Function $ProcessFunction" "k"
        TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm \x22$ColorMapPlanes27\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm 0 -min 0 -max 255 -mcol black  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| $ProcessFunction -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm \x22$ColorMapPlanes27\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm 0 -min 0 -max 255 -mcol black  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
        set Bord "HAlpha"
        PsPScatterPlot "$HAAlpDirOutput/entropy_low_lambda.bin" "$HAAlpDirOutput/mask_low_lambda.bin" float real 0 0 1 "$HAAlpDirOutput/alpha_low_lambda.bin" "$HAAlpDirOutput/mask_low_lambda.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane (Low Lambda)" 4 .top74
        set Bord "HAlpha1"
        PsPScatterPlotColor "$HAAlpDirOutput/entropy_low_lambda.bin" "$HAAlpDirOutput/mask_low_lambda.bin" float real 0 0 1 "$HAAlpDirOutput/alpha_low_lambda.bin" "$HAAlpDirOutput/mask_low_lambda.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane (Low Lambda)" 4 .top74
        }
    if [file exists "$HAAlpDirOutput/H_alpha_lambda_class2.bin"] {
        EnviWriteConfigClassif "$HAAlpDirOutput/H_alpha_lambda_class2.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes27 27
        set BMPFileInput "$HAAlpDirOutput/H_alpha_lambda_class2.bin"
        set BMPFileOutput "$HAAlpDirOutput/H_alpha_lambda_class2.bmp"
        set MaskCmd ""
        set MaskFile "$HAAlpDirOutput/mask_medium_lambda.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        set ProcessFunction "Soft/bin/bmp_process/create_bmp_file.exe"
        TextEditorRunTrace "Process The Function $ProcessFunction" "k"
        TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm \x22$ColorMapPlanes27\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm 0 -min 0 -max 255 -mcol black  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| $ProcessFunction -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm \x22$ColorMapPlanes27\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm 0 -min 0 -max 255 -mcol black  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
        set Bord "HAlpha"
        PsPScatterPlot "$HAAlpDirOutput/entropy_medium_lambda.bin" "$HAAlpDirOutput/mask_medium_lambda.bin" float real 0 0 1 "$HAAlpDirOutput/alpha_medium_lambda.bin" "$HAAlpDirOutput/mask_medium_lambda.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane (Medium Lambda)" 5 .top74
        set Bord "HAlpha2"
        PsPScatterPlotColor "$HAAlpDirOutput/entropy_medium_lambda.bin" "$HAAlpDirOutput/mask_medium_lambda.bin" float real 0 0 1 "$HAAlpDirOutput/alpha_medium_lambda.bin" "$HAAlpDirOutput/mask_medium_lambda.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane (Medium Lambda)" 5 .top74
        }
    if [file exists "$HAAlpDirOutput/H_alpha_lambda_class3.bin"] {
        EnviWriteConfigClassif "$HAAlpDirOutput/H_alpha_lambda_class3.bin" $FinalNlig $FinalNcol 4 $ColorMapPlanes27 27
        set BMPFileInput "$HAAlpDirOutput/H_alpha_lambda_class3.bin"
        set BMPFileOutput "$HAAlpDirOutput/H_alpha_lambda_class3.bmp"
        set MaskCmd ""
        set MaskFile "$HAAlpDirOutput/mask_high_lambda.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        set ProcessFunction "Soft/bin/bmp_process/create_bmp_file.exe"
        TextEditorRunTrace "Process The Function $ProcessFunction" "k"
        TextEditorRunTrace "Arguments: -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm \x22$ColorMapPlanes27\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm 0 -min 0 -max 255 -mcol black  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| $ProcessFunction -if \x22$BMPFileInput\x22 -of \x22$BMPFileOutput\x22 -ift float -oft real -clm \x22$ColorMapPlanes27\x22 -nc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mm 0 -min 0 -max 255 -mcol black  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP != 0} { GimpMapAlgebra $BMPFileOutput }
        set Bord "HAlpha"
        PsPScatterPlot "$HAAlpDirOutput/entropy_high_lambda.bin" "$HAAlpDirOutput/mask_high_lambda.bin" float real 0 0 1 "$HAAlpDirOutput/alpha_high_lambda.bin" "$HAAlpDirOutput/mask_high_lambda.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane (High Lambda)" 6 .top74
        set Bord "HAlpha3"
        PsPScatterPlotColor "$HAAlpDirOutput/entropy_high_lambda.bin" "$HAAlpDirOutput/mask_high_lambda.bin" float real 0 0 1 "$HAAlpDirOutput/alpha_high_lambda.bin" "$HAAlpDirOutput/mask_high_lambda.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol $Bord "Entropy" "Alpha (deg)" "H - Alpha Plane (High Lambda)" 6 .top74
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
    wm geometry $top 200x200+182+182; update
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

proc vTclWindow.top74 {base} {
    if {$base == ""} {
        set base .top74
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
    wm geometry $top 500x460+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: H / A / Alpha Classification"
    vTcl:DefineAlias "$top" "Toplevel74" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd81" "Frame4" vTcl:WidgetProc "Toplevel74" 1
    set site_3_0 $top.cpd81
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel74" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HAAlpDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel74" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel74" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel74" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel74" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HAAlpOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel74" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel74" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd75 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd75" "Label14" vTcl:WidgetProc "Toplevel74" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HAAlpOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel74" 1
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel74" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd82 \
        \
        -command {global DirName DataDir HAAlpOutputDir

set HAAlpDirOutputTmp $HAAlpOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set HAAlpOutputDir $DirName
    } else {
    set HAAlpOutputDir $HAAlpDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd82" "Button535" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_6_0.cpd82 "$site_6_0.cpd82 Button $top all _vTclBalloon"
    bind $site_6_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame9" vTcl:WidgetProc "Toplevel74" 1
    set site_3_0 $top.fra76
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel74" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel74" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel74" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel74" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel74" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel74" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel74" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel74" 1
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
    TitleFrame $top.cpd72 \
        -text Representation 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame2" vTcl:WidgetProc "Toplevel74" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    frame $site_4_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame50" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd77
    checkbutton $site_5_0.che38 \
        -foreground #ff0000 -text Anisotropy -variable RGBHAAlpha 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton31" vTcl:WidgetProc "Toplevel74" 1
    label $site_5_0.lab80 \
        -foreground #009900 -text Entropy 
    vTcl:DefineAlias "$site_5_0.lab80" "Label1" vTcl:WidgetProc "Toplevel74" 1
    label $site_5_0.cpd81 \
        -foreground #0000ff -text Alpha 
    vTcl:DefineAlias "$site_5_0.cpd81" "Label2" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_5_0.lab80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    frame $site_4_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame51" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd78
    checkbutton $site_5_0.che38 \
        -foreground #ff0000 -text {H A  +  (1 - H) A} -variable RGBCombHA 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton33" vTcl:WidgetProc "Toplevel74" 1
    label $site_5_0.cpd82 \
        -foreground #009900 -text {H (1 - A)} 
    vTcl:DefineAlias "$site_5_0.cpd82" "Label3" vTcl:WidgetProc "Toplevel74" 1
    label $site_5_0.cpd83 \
        -foreground #0000ff -text {(1 - H) (1 - A)} 
    vTcl:DefineAlias "$site_5_0.cpd83" "Label4" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    frame $site_4_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame52" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd79
    checkbutton $site_5_0.che38 \
        -command {} -text {Alpha (Hue) / Entropy (Sat) / Lambda (Light)} \
        -variable RGBTuoTuo 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton34" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit71 \
        -text {H / A / Alpha Classification} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel74" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame45" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd73
    checkbutton $site_5_0.che38 \
        -text {Entropy / Alpha Planes (BMP) + Classifier (Bin + BMP)} \
        -variable Halpha_plane 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton30" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame49" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd74
    checkbutton $site_5_0.che38 \
        -text {Entropy / Anisotropy Planes (BMP) + Classifier (Bin + BMP)} \
        -variable HA_plane 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton32" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    frame $site_4_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd75" "Frame46" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd75
    checkbutton $site_5_0.che38 \
        -command {} -padx 1 \
        -text {Alpha / Anisotropy Planes (BMP) + Classifier (Bin + BMP)} \
        -variable Aalpha_plane 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton35" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd71 \
        -text {Tuo-Tuo ( H / Alpha / Lambda ) Classification} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame3" vTcl:WidgetProc "Toplevel74" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame53" vTcl:WidgetProc "Toplevel74" 1
    set site_5_0 $site_4_0.cpd73
    checkbutton $site_5_0.che38 \
        \
        -text {Entropy / Alpha / Lambda Planes (BMP) + Classifier (Bin + BMP)} \
        -variable HalphaLambda_plane 
    vTcl:DefineAlias "$site_5_0.che38" "Checkbutton36" vTcl:WidgetProc "Toplevel74" 1
    pack $site_5_0.che38 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 20 -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra82 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$top.fra82" "Frame47" vTcl:WidgetProc "Toplevel74" 1
    set site_3_0 $top.fra82
    frame $site_3_0.fra24 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra24" "Frame48" vTcl:WidgetProc "Toplevel74" 1
    set site_4_0 $site_3_0.fra24
    label $site_4_0.lab57 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label34" vTcl:WidgetProc "Toplevel74" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinHAAlpL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry22" vTcl:WidgetProc "Toplevel74" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd81 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd81" "Frame54" vTcl:WidgetProc "Toplevel74" 1
    set site_4_0 $site_3_0.cpd81
    label $site_4_0.lab57 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label35" vTcl:WidgetProc "Toplevel74" 1
    entry $site_4_0.ent58 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NwinHAAlpC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry23" vTcl:WidgetProc "Toplevel74" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd66 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set Halpha_plane "1"
set HA_plane "1"
set Aalpha_plane "1"
set entropy "1"
set anisotropy "1"
set alpha "1"
set lambda "1"
set CombHA "1"
set CombH1mA "1"
set Comb1mHA "1"
set Comb1mH1mA "1"
set RGBHAAlpha "1"
set RGBCombHA "1"
set RGBTuoTuo "1"
set HalphaLambda_plane "1"} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd66" "Button104" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_3_0.cpd66 "$site_3_0.cpd66 Button $top all _vTclBalloon"
    bind $site_3_0.cpd66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.but25 \
        -background #ffff00 \
        -command {set NwinHAAlpL "?"; set NwinHAAlpC "?"
set Halpha_plane "0"
set HA_plane "0"
set Aalpha_plane "0"
set entropy "0"
set anisotropy "0"
set alpha "0"
set lambda "0"
set CombHA "0"
set CombH1mA "0"
set Comb1mHA "0"
set Comb1mH1mA "0"
set RGBHAAlpha "0"
set RGBCombHA "0"
set RGBTuoTuo "0"
set HalphaLambda_plane "0"} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.but25" "Button103" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_3_0.but25 "$site_3_0.but25 Button $top all _vTclBalloon"
    bind $site_3_0.but25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 50 -side left 
    pack $site_3_0.but25 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel74" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global HAAlpha HAAlpDirInput HAAlpDirOutput HAAlpOutputDir HAAlpOutputSubDir HAAlphaClassifFonction
global entropy anisotropy alpha lambda CombHA CombH1mA Comb1mHA Comb1mH1mA NwinHAAlpL NwinHAAlpC
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global BMPDirInput OpenDirFile ColorMapPlanes9 ColorMapPlanes27
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

Window hide .top401; Window hide .top402; Window hide .top419
Window hide .top420; Window hide .top421; Window hide .top422
Window hide .top423; Window hide .top424; Window hide .top425

$widget(Button74_1) configure -state disable
$widget(Button74_2) configure -state disable

set entropy "0"
set anisotropy "0"
set alpha "0"
set lambda "0"
set CombHA "0"
set CombH1mA "0"
set Comb1mHA "0"
set Comb1mH1mA "0"

set HAAlpDirOutput $HAAlpOutputDir
if {$HAAlpOutputSubDir != ""} {append HAAlpDirOutput "/$HAAlpOutputSubDir"}

    #####################################################################
    #Create Directory
    set HAAlpDirOutput [PSPCreateDirectoryMask $HAAlpDirOutput $HAAlpOutputDir $HAAlpDirInput]
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
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinHAAlpL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "ColorMap9"; set TestVarType(5) "file"; set TestVarValue(5) $ColorMapPlanes9; set TestVarMin(5) ""; set TestVarMax(5) ""
        set TestVarName(6) "ColorMap27"; set TestVarType(6) "file"; set TestVarValue(6) $ColorMapPlanes27; set TestVarMin(6) ""; set TestVarMax(6) ""
        set TestVarName(7) "Window Size Col"; set TestVarType(7) "int"; set TestVarValue(7) $NwinHAAlpC; set TestVarMin(7) "1"; set TestVarMax(7) "1000"
        TestVar 8
        if {$TestVarError == "ok"} {
            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the H / A / Alpha Decomposition"
    
            if {$RGBHAAlpha=="1"} { 
                set entropy "1"; set anisotropy "1"; set alpha "1"
                }
            if {$RGBCombHA=="1"} {
                set anisotropy "1"; set CombHA "1"; set CombH1mA "1"; set Comb1mHA "1"; set Comb1mH1mA "1"
                }
            if {$RGBTuoTuo=="1"} {
                set entropy "1"; set lambda "1"; set alpha "1"
                }
            if {$Halpha_plane =="1"} { 
                set entropy "1"; set alpha "1"
                }
            if {$HA_plane =="1"} { 
                set entropy "1"; set anisotropy "1"
                }
            if {$Aalpha_plane =="1"} { 
                set anisotropy "1"; set alpha "1"
                }
            if {$HalphaLambda_plane =="1"} { 
                set entropy "1"; set alpha "1"; set lambda "1"
                }
                
            HAAlphaDecomposition
            HAAlphaDecompositionBMP
    
            if {"$RGBHAAlpha"=="1"} { RGBHAAlphaBMP }
            if {"$RGBCombHA"=="1"} { RGBHACombBMP }
            if {"$RGBTuoTuo"=="1"} { RGBTuoTuoBMP }
    
            set config "false"
            if {$Halpha_plane =="1"} { set config "true" }
            if {$HA_plane =="1"} { set config "true" }
            if {$Aalpha_plane =="1"} { set config "true" }
            if {"$config"=="true"} { 
                HAAlphaClassification
                $widget(Button74_1) configure -state normal
                $widget(Button74_2) configure -state normal
                }
    
            if {$HalphaLambda_plane =="1"} {
                HAlphaLambdaClassification
                $widget(Button74_1) configure -state normal
                $widget(Button74_2) configure -state normal
                }
            }
        } else {
        if {"$VarWarning"=="no"} {
            Window hide $widget(Toplevel74); TextEditorRunTrace "Close Window H A Alpha Classification" "b"
            }
        } 
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.cpd66 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput HAAlpDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1 SaveDisplayOutputFile2 SaveDisplayOutputFile3 SaveDisplayOutputFileNum
global SaveDisplayOutputFile4 SaveDisplayOutputFile5 SaveDisplayOutputFile6
global Halpha_plane HA_plane Aalpha_plane HalphaLambda_plane

#BMP_PROCESS
global Load_SaveDisplay1num Load_SaveDisplay3a Load_SaveDisplay3b PSPTopLevel

set conf ""
if {"$Halpha_plane"=="1"} { append conf "1"} 
if {"$HA_plane"=="1"} { append conf "2"} 
if {"$Aalpha_plane"=="1"} { append conf "3"} 
if {$conf == "123"} {
    if {$Load_SaveDisplay3a == 0} {
        source "GUI/bmp_process/SaveDisplay3a.tcl"
        set Load_SaveDisplay3a 1
        WmTransient $widget(Toplevel458) $PSPTopLevel
        }
    set SaveDisplayDirOutput $HAAlpDirOutput
    set SaveDisplayOutputFile1 "H_alpha_plane"
    set SaveDisplayOutputFile2 "A_alpha_plane"
    set SaveDisplayOutputFile3 "H_A_plane"
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel74) $widget(Toplevel458); TextEditorRunTrace "Open Window Save Display 3" "b"
    tkwait variable VarSaveGnuPlotFile
    } else {
    if {$Load_SaveDisplay1num == 0} {
        source "GUI/bmp_process/SaveDisplay1num.tcl"
        set Load_SaveDisplay1num 1
        WmTransient $widget(Toplevel460) $PSPTopLevel
        }
    set SaveDisplayDirOutput $HAAlpDirOutput
    if {"$Halpha_plane"=="1"} {
        set SaveDisplayOutputFile1 "H_alpha_plane"
        set SaveDisplayOutputFileNum 1
        set VarSaveGnuPlotFile ""
        WidgetShowFromWidget $widget(Toplevel74) $widget(Toplevel460); TextEditorRunTrace "Open Window Save Display 1" "b"
        tkwait variable VarSaveGnuPlotFile
        } 
    if {"$HA_plane"=="1"} {
        set SaveDisplayOutputFile1 "H_A_plane"
        set SaveDisplayOutputFileNum 3
        set VarSaveGnuPlotFile ""
        WidgetShowFromWidget $widget(Toplevel74) $widget(Toplevel460); TextEditorRunTrace "Open Window Save Display 1" "b"
        tkwait variable VarSaveGnuPlotFile
        } 
    if {"$Aalpha_plane"=="1"} {
        set SaveDisplayOutputFile1 "A_alpha_plane"
        set SaveDisplayOutputFileNum 2
        set VarSaveGnuPlotFile ""
        WidgetShowFromWidget $widget(Toplevel74) $widget(Toplevel460); TextEditorRunTrace "Open Window Save Display 1" "b"
        tkwait variable VarSaveGnuPlotFile
        }
    }
if {"$HalphaLambda_plane"=="1"} {
    if {$Load_SaveDisplay3b == 0} {
        source "GUI/bmp_process/SaveDisplay3b.tcl"
        set Load_SaveDisplay3b 1
        WmTransient $widget(Toplevel459) $PSPTopLevel
        }
    set SaveDisplayDirOutput $HAAlpDirOutput
    set SaveDisplayOutputFile4 "H_alpha_Low_plane"
    set SaveDisplayOutputFile5 "H_alpha_Medium_plane"
    set SaveDisplayOutputFile6 "H_alpha_High_plane"
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel74) $widget(Toplevel459); TextEditorRunTrace "Open Window Save Display 3" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.cpd66" "Button74_1" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_3_0.cpd66 "$site_3_0.cpd66 Button $top all _vTclBalloon"
    bind $site_3_0.cpd66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reference}
    }
    button $site_3_0.but71 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1 TMPGnuPlotTk2 TMPGnuPlotTk3 
global TMPGnuPlotTk4 TMPGnuPlotTk5 TMPGnuPlotTk6 
global TMPGnuPlotTk11 TMPGnuPlotTk12 TMPGnuPlotTk13 
global TMPGnuPlotTk14 TMPGnuPlotTk15 TMPGnuPlotTk16 
global Halpha_plane HA_plane Aalpha_plane HalphaLambda_plane

if {"$Halpha_plane"=="1"} { Gimp $TMPGnuPlotTk1; Gimp $TMPGnuPlotTk11 } 
if {"$HA_plane"=="1"} { Gimp $TMPGnuPlotTk3; Gimp $TMPGnuPlotTk13 } 
if {"$Aalpha_plane"=="1"} { Gimp $TMPGnuPlotTk2; Gimp $TMPGnuPlotTk12 } 
if {"$HalphaLambda_plane"=="1"} {
    Gimp $TMPGnuPlotTk4; Gimp $TMPGnuPlotTk14
    Gimp $TMPGnuPlotTk5; Gimp $TMPGnuPlotTk15
    Gimp $TMPGnuPlotTk6; Gimp $TMPGnuPlotTk16 
    }} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but71" "Button74_2" vTcl:WidgetProc "Toplevel74" 1
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/HAAlphaClassification.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
global Load_SaveDisplay1num Load_SaveDisplay3a Load_SaveDisplay3b

if {$OpenDirFile == 0} {
    if {$Load_SaveDisplay1num == 1} {Window hide $widget(Toplevel460); TextEditorRunTrace "Close Window Save Display 1" "b"}
    if {$Load_SaveDisplay3a == 1} {Window hide $widget(Toplevel458); TextEditorRunTrace "Close Window Save Display 3" "b"}
    if {$Load_SaveDisplay3b == 1} {Window hide $widget(Toplevel459); TextEditorRunTrace "Close Window Save Display 3" "b"}
    Window hide .top401; Window hide .top402; Window hide .top419
    Window hide .top420; Window hide .top421; Window hide .top422
    Window hide .top423; Window hide .top424; Window hide .top425
    Window hide $widget(Toplevel74); TextEditorRunTrace "Close Window H A Alpha Classification" "b"
    }} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel74" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra82 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra83 \
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
Window show .top74

main $argc $argv
