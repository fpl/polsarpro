/********************************************************************
PolSARpro v6.0.4 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File     : SNAP_google_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 02/2012
Update   :
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

Description :  Create a Google Kml File

********************************************************************/

/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

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
/*                                                                            */
{

/* LOCAL VARIABLES */
  FILE *filename, *fdata;
  char FileMetaData[FilePathLength], FileHdr[FilePathLength];
  char SNAPDir[FilePathLength], file_name[FilePathLength];
  char Buf[FilePathLength];
  
  float Lon00,Lat00,LonN0,LatN0,LonNN,LatNN,Lon0N,Lat0N;
  double LonCenter,LatCenter; 
  float f1, f2;
  double f3,f4,f5,f6;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nSNAP_google_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-od  	output SNAP dir\n");
strcat(UsageHelp," (string)	-ifm 	input metadata file\n");
strcat(UsageHelp," (string)	-ifh 	input hdr file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 7) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,SNAPDir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifm",str_cmd_prm,FileMetaData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,FileHdr,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileMetaData);
  check_file(FileHdr);
  check_dir(SNAPDir);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  if ((fdata = fopen(FileMetaData, "r")) == NULL)
    edit_error("Could not open input file : ", FileMetaData);

  while( !feof(fdata) ) {
    fgets(&Buf[0], 1024, fdata); 
    if (strstr(Buf,"first_near_lat") != NULL) {
      sscanf(Buf, "    <attrib name=\"first_near_lat\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&Lat00);
      }
    if (strstr(Buf,"first_near_long") != NULL) {
      sscanf(Buf, "    <attrib name=\"first_near_long\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&Lon00);
      }
    if (strstr(Buf,"first_far_lat") != NULL) {
      sscanf(Buf, "    <attrib name=\"first_far_lat\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&Lat0N);
      }
    if (strstr(Buf,"first_far_long") != NULL) {
      sscanf(Buf, "    <attrib name=\"first_far_long\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&Lon0N);
      }
    if (strstr(Buf,"last_near_lat") != NULL) {
      sscanf(Buf, "    <attrib name=\"last_near_lat\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&LatN0);
      }
    if (strstr(Buf,"last_near_long") != NULL) {
      sscanf(Buf, "    <attrib name=\"last_near_long\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&LonN0);
      }
    if (strstr(Buf,"last_far_lat") != NULL) {
      sscanf(Buf, "    <attrib name=\"last_far_lat\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&LatNN);
      }
    if (strstr(Buf,"last_far_long") != NULL) {
      sscanf(Buf, "    <attrib name=\"last_far_long\" value=\"%f\" type=\"31\" unit=\"deg\" desc=\"\" />",&LonNN);
      }
    }

  fclose(fdata);
  
/*******************************************************************/
/*******************************************************************/

  if ((fdata = fopen(FileHdr, "r")) == NULL)
    edit_error("Could not open input file : ", FileHdr);

  while( !feof(fdata) ) {
    fgets(&Buf[0], 1024, fdata); 
    if (strstr(Buf,"map info") != NULL) {
      sscanf(Buf, "map info = {Geographic Lat/Lon,%f,%f,%lf,%lf,%le,%le,WGS-84, units=Degrees}",&f1,&f2,&f3,&f4,&f5,&f6);
      }
    }
  
  fclose(fdata);
  
/*******************************************************************/
/*******************************************************************/

  LonCenter = f3;
  LatCenter = f4;

  sprintf(file_name, "%sGEARTH_POLY.kml", SNAPDir);
  if ((filename = fopen(file_name, "w")) == NULL)
    edit_error("Could not open configuration file : ", file_name);

  fprintf(filename,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
  fprintf(filename,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<name>\n");
  fprintf(filename, "Image\n");
  fprintf(filename,"</name>\n");
  fprintf(filename,"<LookAt>\n");
  fprintf(filename,"<longitude>\n");
  fprintf(filename, "%lf\n", LonCenter);
  fprintf(filename,"</longitude>\n");
  fprintf(filename,"<latitude>\n");
  fprintf(filename, "%lf\n", LatCenter);
  fprintf(filename,"</latitude>\n");
  fprintf(filename,"<range>\n");
  fprintf(filename,"250000.0\n");
  fprintf(filename,"</range>\n");
  fprintf(filename,"<tilt>0</tilt>\n");
  fprintf(filename,"<heading>0</heading>\n");
  fprintf(filename,"</LookAt>\n");
  fprintf(filename,"<Style>\n");
  fprintf(filename,"<LineStyle>\n");
  fprintf(filename,"<color>ff0000ff</color>\n");
  fprintf(filename,"<width>4</width>\n");
  fprintf(filename,"</LineStyle>\n");
  fprintf(filename,"</Style>\n");
  fprintf(filename,"<LineString>\n");
  fprintf(filename,"<coordinates>\n");
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename, "%f,%f,8000.0\n", LonN0,LatN0);
  fprintf(filename, "%f,%f,8000.0\n", LonNN,LatNN);
  fprintf(filename, "%f,%f,8000.0\n", Lon0N,Lat0N);
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename,"</coordinates>\n");
  fprintf(filename,"</LineString>\n");
  fprintf(filename,"</Placemark>\n");
  fprintf(filename,"</kml>\n");

  fclose(filename);
    
  return 1;
}
