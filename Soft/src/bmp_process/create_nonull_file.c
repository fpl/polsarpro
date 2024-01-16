/********************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : create_nonull_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2016
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Waves and Signal department
SHINE Team 


UNIVERSITY OF RENNES I
B�t. 11D - Campus de Beaulieu
263 Avenue G�n�ral Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Create a file of values 

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */
  FILE *fileoutput;
  char FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col;
  char SlantRangeAxis[10];
  float NearRangeValue, FarRangeValue;

/* Matrix arrays */
  float *bufferdata;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_null_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-of  	output null file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-axe 	Slant-range direction (col / row)\n");
strcat(UsageHelp," (float) 	-min 	Near-range value\n");
strcat(UsageHelp," (float) 	-max 	Far-range value\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-axe",str_cmd_prm,SlantRangeAxis,1,UsageHelp);
  get_commandline_prm(argc,argv,"-min",flt_cmd_prm,&NearRangeValue,1,UsageHelp);
  get_commandline_prm(argc,argv,"-max",flt_cmd_prm,&FarRangeValue,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  NwinL = 1; NwinC = 1;

/* OUTPUT FILE OPENING */
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open output file : ", FileOutput);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bufferdata = vector_float(Sub_Ncol);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

if (strcmp(SlantRangeAxis, "col") == 0) {
  for (col = 0; col < Sub_Ncol; col++) bufferdata[col] = NearRangeValue + (float)col*(FarRangeValue - NearRangeValue)/(Sub_Ncol - 1);
  for (lig = 0; lig < Sub_Nlig; lig++) {
    if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
    fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
    } /*lig*/
  }
  
if (strcmp(SlantRangeAxis, "row") == 0) {
  for (lig = 0; lig < Sub_Nlig; lig++) {
    for (col = 0; col < Sub_Ncol; col++) bufferdata[col] = NearRangeValue + (float)lig*(FarRangeValue - NearRangeValue)/(Sub_Nlig - 1);
    if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
    fwrite(&bufferdata[0], sizeof(float), Sub_Ncol, fileoutput);
    } /*lig*/
  }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(bufferdata);
*/
/********************************************************************
********************************************************************/

/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/********************************************************************
********************************************************************/

  return 1;
}


