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

File     : bmp_2_tiff.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2020
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Waves and Signal department
SHINE Team 

UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Convert a 8/24-bits BMP image to a TIFF image

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

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* GLOBAL ARRAYS */
char *buffercolor;
char *bmpimage;
char **bmpfinal;

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
  FILE *fileinput, *fileoutput;

  char FileInput[FilePathLength], FileOutput[FilePathLength];
  char FileInputHdr[FilePathLength];
  
  int k, lig, col;
  int Nbit, Nlig, Ncol, ExtraCol;
  int FidAdd, NFid, NFidAdd;
  int Tag, Type, Count, Value;
  int red[256], green[256], blue[256];

  char Buf[65536];
  char Tmp[65536];
  char *p1;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nbmp_2_tiff.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input BMP file\n");
strcat(UsageHelp," (string)	-of 	output TIFF file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 5) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* INPUT HEADER FILE */
/*******************************************************************/

  sprintf(FileInputHdr, "%s.hdr", FileInput);
  check_file(FileInputHdr);
  if ((fileinput = fopen(FileInputHdr, "r")) == NULL)
    edit_error("Could not open input file : ", FileInputHdr);
  rewind(fileinput);
  while( !feof(fileinput) ) {
    fgets(&Buf[0], 1024, fileinput); 
    if (strstr(Buf,"samples") != NULL) {
      p1 = strstr(Buf," = ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      Ncol = atoi(Tmp);
      }
    if (strstr(Buf,"lines") != NULL) {
      p1 = strstr(Buf," = ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      Nlig = atoi(Tmp);
      }
    if (strstr(Buf,"color") != NULL) {
      if (strstr(Buf,"8") != NULL) Nbit = 8; 
      if (strstr(Buf,"24") != NULL) Nbit = 24; 
      }
    }
  fclose(fileinput);

/*******************************************************************/
/* OUTPUT TIFF FILE : WRITE HEADER */
/*******************************************************************/

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

  k = 18761;
  fwrite(&k, sizeof(short int), 1, fileoutput);
  k = 42;
  fwrite(&k, sizeof(short int), 1, fileoutput);
  FidAdd = Nlig * Ncol * 4 + 8;
  fwrite(&FidAdd, sizeof(int), 1, fileoutput);
  
/*******************************************************************/
/* INPUT BMP FILE : READ COLORMAP */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInput);
  /* Reading BMP file header */
  rewind(fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);

  buffercolor = vector_char(2000);
  if (Nbit == 8) {
    fread(&buffercolor[0], sizeof(char), 1024, fileinput);
    for (col = 0; col < 256; col++) {
      red[col] = buffercolor[4 * col + 2];
      if (red[col] < 0) red[col] = red[col] + 256;
      green[col] = buffercolor[4 * col + 1];
      if (green[col] < 0) green[col] = green[col] + 256;
      blue[col] = buffercolor[4 * col];
      if (blue[col] < 0) blue[col] = blue[col] + 256;
      }
    ExtraCol = (int) fmod(4 - (int) fmod(Ncol, 4), 4);
    }

  if (Nbit == 24) {
    ExtraCol = (int) fmod(4 - (int) fmod(3*Ncol, 4), 4);
    }

/*******************************************************************/
/* READ BMP DATA & WRITE TIFF DATA */
/*******************************************************************/

  bmpfinal = matrix_char(Nlig, 4 * Ncol);
  if (Nbit == 8) bmpimage = vector_char(Ncol + ExtraCol);
  if (Nbit == 24) bmpimage = vector_char(3*Ncol + ExtraCol);

  for (lig = 0; lig < Nlig; lig++) {
    if (Nbit == 8) {
      fread(&bmpimage[0], sizeof(char), Ncol + ExtraCol, fileinput);
      for (col = 0; col < Ncol; col++) {
        k = bmpimage[col]; if (k < 0) k = k + 256;
        bmpfinal[Nlig-1-lig][4*col] = (char) red[k];
        bmpfinal[Nlig-1-lig][4*col+1] = (char) green[k];
        bmpfinal[Nlig-1-lig][4*col+2] = (char) blue[k];
        bmpfinal[Nlig-1-lig][4*col+3] = (char) 255;
        }
	  }  
    if (Nbit == 24) {
      fread(&bmpimage[0], sizeof(char), 3*Ncol + ExtraCol, fileinput);
      for (col = 0; col < Ncol; col++) {
        bmpfinal[Nlig-1-lig][4*col] = bmpimage[3*col+2];
        bmpfinal[Nlig-1-lig][4*col+1] = bmpimage[3*col+1];
        bmpfinal[Nlig-1-lig][4*col+2] = bmpimage[3*col];
        bmpfinal[Nlig-1-lig][4*col+3] = (char) 255;
        }
	  }
    }
  for (lig = 0; lig < Nlig; lig++) {
    fwrite(&bmpfinal[lig][0], sizeof(char), 4 * Ncol, fileoutput);
    }

/*******************************************************************/
/* OUTPUT TIFF FILE : WRITE FOOTER (FID) */
/*******************************************************************/

  /* The number of directory entries */
  NFid = 16; // = 20 if GEOTIFF
  fwrite(&NFid, sizeof(short int), 1, fileoutput);

  NFidAdd = FidAdd + 2 + 12 * NFid + 4;

  /* 1-Data Type */
  Tag = 254; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 4; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 0; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 2-Width */
  Tag = 256; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = Ncol; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 3-Length */
  Tag = 257; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = Nlig; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 4-Bits per sample */
  Tag = 258; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 4; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = NFidAdd; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 5-Compression Flag */
  Tag = 259; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 1; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 6-Photometric Interpolation */
  Tag = 262; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 2; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 7-Strip Offset */
  Tag = 273; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 4; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = Nlig; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = NFidAdd + 24; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 8-Orientation Flag */
  Tag = 274; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 1; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 9-Sample per pixel */
  Tag = 277; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 4; fwrite(&Value, sizeof(int), 1, fileoutput);
 
  /* 10-Rows per Strip */
  Tag = 278; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 1; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 11-Strip Byte Count */
  Tag = 279; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 4; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = Nlig; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = NFidAdd + 24 + 4 * Nlig; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 12-X Resolution */
  Tag = 282; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 5; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = NFidAdd + 8; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 13-Y Resolution */
  Tag = 283; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 5; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = NFidAdd + 16; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 14-Planar Configuration */
  Tag = 284; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 1; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 15-Resolution Unit */
  Tag = 296; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 2; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 16-Resolution Unit */
  Tag = 338; fwrite(&Tag, sizeof(short int), 1, fileoutput);
  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
  Count = 1; fwrite(&Count, sizeof(int), 1, fileoutput);
  Value = 2; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* 17-GEOTIFF 1 */
//  Tag = 34735; fwrite(&Tag, sizeof(short int), 1, fileoutput);
//  Type = 3; fwrite(&Type, sizeof(short int), 1, fileoutput);
//  Count = 36; fwrite(&Count, sizeof(int), 1, fileoutput);
//  Value = NFidAdd + 24 + 2 * (4 * Nlig); fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 18-GEOTIFF 2 */
//  Tag = 34736; fwrite(&Tag, sizeof(short int), 1, fileoutput);
//  Type = 12; fwrite(&Type, sizeof(short int), 1, fileoutput);
//  Count = 4; fwrite(&Count, sizeof(int), 1, fileoutput);
//  Value = NFidAdd + 24 + 2 * (4 * Nlig) + 36 * 2; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 19-GEOTIFF 3 */
//  Tag = 34737; fwrite(&Tag, sizeof(short int), 1, fileoutput);
//  Type = 2; fwrite(&Type, sizeof(short int), 1, fileoutput);
//  Count = 20; fwrite(&Count, sizeof(int), 1, fileoutput);
//  Value = NFidAdd + 24 + 2 * (4 * Nlig) + 36 * 2 + 4 * (2 * 4); fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* 20-GEOTIFF 4 */
//  Tag = 34264; fwrite(&Tag, sizeof(short int), 1, fileoutput);
//  Type = 12; fwrite(&Type, sizeof(short int), 1, fileoutput);
//  Count = 16; fwrite(&Count, sizeof(int), 1, fileoutput);
//  Value = NFidAdd + 24 + 2 * (4 * Nlig) + 36 * 2 + 4 * (2 * 4) + 20; fwrite(&Value, sizeof(int), 1, fileoutput);
  
  /* End of the directory entry */
  Tag = 0; fwrite(&Tag, sizeof(int), 1, fileoutput);
  
/*******************************************************************/
  /* Bits per sample */
  Value = 8; fwrite(&Value, sizeof(short int), 1, fileoutput);
  Value = 8; fwrite(&Value, sizeof(short int), 1, fileoutput);
  Value = 8; fwrite(&Value, sizeof(short int), 1, fileoutput);
  Value = 8; fwrite(&Value, sizeof(short int), 1, fileoutput);

  /* X Resolution */
  Value = 100; fwrite(&Value, sizeof(int), 1, fileoutput);
  Value = 1; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* Y Resolution */
  Value = 100; fwrite(&Value, sizeof(int), 1, fileoutput);
  Value = 1; fwrite(&Value, sizeof(int), 1, fileoutput);

  /* Strip Offset */
  for (lig = 0; lig < Nlig; lig++) {
    Value = 8 + lig * 4 * Ncol; fwrite(&Value, sizeof(int), 1, fileoutput);
    }
  
  /* Strip Byte Count */
  for (lig = 0; lig < Nlig; lig++) {
    Value = 4 * Ncol; fwrite(&Value, sizeof(int), 1, fileoutput);
    }

  /* GEOTIFF 1 */
  
  /* GEOTIFF 2 */
  
  /* GEOTIFF 3 */
  
  /* GEOTIFF 4 */
  
  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  fclose(fileinput);
  fclose(fileoutput);

/********************************************************************
********************************************************************/

  return 1;
}
