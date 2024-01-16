/*******************************************************************************
PolSARpro v4.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File     : tiff_tag_viewer.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 01/2020
Update   :

*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
Description :  Display tags and values from a TIFF file

*******************************************************************************/
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
void read_tiff_strip(char FileInput[FilePathLength]);

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
	FILE *fileinput;
    char FileTiff[1024];
	
	char buffer[4];
	int IEEE;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

    if (argc < 2) {
	printf("TYPE: tiff_tag_viewer FileTiff\n");
	exit(1);
    } else {
	strcpy(FileTiff, argv[1]);
    }

    check_file(FileTiff);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/******************************************************************************/

    if ((fileinput = fopen(FileTiff, "r")) == NULL)
	edit_error("Could not open configuration file : ", FileTiff);
	fread(buffer, 1, 4, fileinput);
	fclose(fileinput);
	
	IEEE = 2;
	if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEE = 0;
	if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEE = 1;

	if (IEEE != 2) {
	  //Read_tiff_header
      read_tiff_strip(FileTiff);
      } else {
      edit_error(FileTiff, " is not a TIFF file");
      }
    return 1;
}	


/********************************************************************
*********************************************************************
*********************************************************************
********************************************************************/

void read_tiff_strip (char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i;
  long unsigned int offset;
  long unsigned int offset_bitpersample;
  long unsigned int offset_xresol;
  long unsigned int offset_yresol;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  long unsigned int offset_34264;
  long unsigned int offset_34735;
  long unsigned int offset_34736;
  long unsigned int offset_34737;
  short unsigned int Ndir, Flag, Type;
  int Nstrip, Count, Value, IEEEFormat;
  double ValueFloat;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);
/* Tiff File Header */

  /* Little / Big endian & TIFF identifier */
  IEEEFormat = 2;
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEEFormat = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEEFormat = 1;
  printf("IEEEFormat %i\n",IEEEFormat);
  
  /* Offset = adresse IFD */
  if (IEEEFormat == 0) fread(&offset, sizeof(int), 1, fileinput);
  printf("Offset = @NFID %lu\n",offset);

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  /* Ndir = Nbre de IFD Entries */
  if (IEEEFormat == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  printf("Nbre de IFD Entries %i\n",Ndir);

  /* Loop on the Ndir IFD : each IFD entry = tag + data type + data number + value or data adress */
  /* Data Type = 1 = unsigned integer */
  /* Data Type = 2 = ASCII */
  /* Data Type = 3 = short 16-bit */
  /* Data Type = 4 = long 32-bits */
  /* Data Type = 5 = rational = 2 x 32-bits unsigned integers */
  /* Data Type = 6 = sbyte 8-bit signed integer */
  /* Data Type = 7 = undefine 8-bit byte */
  /* Data Type = 8 = sshort 16-bit signed integer */
  /* Data Type = 9 = slong 32-bit signed integer */
  /* Data Type = 10 = srational = 2 x 32-bit signed integers */
  /* Data Type = 11 = 4-bit single precision IEEE float value */
  /* Data Type = 12 = 8-bit double precision IEEE float value */
  
  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    fread(&Flag, sizeof(short int), 1, fileinput);
    fread(&Type, sizeof(short int), 1, fileinput);
    fread(&Count, sizeof(int), 1, fileinput);
    fread(&Value, sizeof(int), 1, fileinput);
	// TIFF Tags
    if (Flag == 258) offset_bitpersample = Value;
    if (Flag == 273) Nstrip = Count;
    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;
    if (Flag == 282) offset_xresol = Value;
    if (Flag == 283) offset_yresol = Value; 
	// GEOTIFF Tags
    if (Flag == 34264) offset_34264 = Value;
    if (Flag == 34735) offset_34735 = Value;
    if (Flag == 34736) offset_34736 = Value;
    if (Flag == 34737) offset_34737 = Value;
    printf("Entry %i : Flag %i Type %i Count %i Value %i\n",i,Flag,Type,Count,Value);
    }

printf("\nSTRIP OFFSET\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    fread(&Value, sizeof(int), 1, fileinput);
    printf("Strip_Offset[%i] = %i\n",i,Value);
  }

printf("\nSTRIP BYTES\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    fread(&Value, sizeof(int), 1, fileinput);
    printf("Strip_Bytes[%i] = %i\n",i,Value);
  }

printf("\nBITS PER SAMPLE\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_bitpersample, SEEK_SET);
  fread(&Value, sizeof(short int), 1, fileinput);
  printf("Bits Per Sample 1 = %i\n",Value);
  fread(&Value, sizeof(short int), 1, fileinput);
  printf("Bits Per Sample 2 = %i\n",Value);
  fread(&Value, sizeof(short int), 1, fileinput);
  printf("Bits Per Sample 3 = %i\n",Value);
  fread(&Value, sizeof(short int), 1, fileinput);
  printf("Bits Per Sample 4 = %i\n",Value);

printf("\nSTRIP X-Y RESOLUTION\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_xresol, SEEK_SET);
  fread(&Value, sizeof(int), 1, fileinput);
  printf("X - Resolution 1 = %i\n",Value);
  fread(&Value, sizeof(int), 1, fileinput);
  printf("X - Resolution 2 = %i\n",Value);
  rewind(fileinput);
  fseek(fileinput, offset_yresol, SEEK_SET);
  fread(&Value, sizeof(int), 1, fileinput);
  printf("Y - Resolution 1 = %i\n",Value);
  fread(&Value, sizeof(int), 1, fileinput);
  printf("Y - Resolution 2 = %i\n",Value);

printf("\nGEOTIFF 34264\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_34264, SEEK_SET);
  for (i=0; i<16; i++) {
    fread(&ValueFloat, sizeof(double), 1, fileinput);
    printf("Geotiff 34264[%i] = %f\n",i,ValueFloat);
  }

printf("\nGEOTIFF 34735\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_34735, SEEK_SET);
  for (i=0; i<36; i++) {
    fread(&Value, sizeof(short int), 1, fileinput);
    printf("Geotiff 34735[%i] = %i\n",i,Value);
  }

printf("\nGEOTIFF 34736\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_34736, SEEK_SET);
  for (i=0; i<4; i++) {
    fread(&ValueFloat, sizeof(double), 1, fileinput);
    printf("Geotiff 34736[%i] = %f\n",i,ValueFloat);
  }

printf("\nGEOTIFF 34737\n");
getchar();
  rewind(fileinput);
  fseek(fileinput, offset_34737, SEEK_SET);
  for (i=0; i<20; i++) {
    fread(&Value, sizeof(char), 1, fileinput);
    printf("Geotiff 34737[%i] = %c\n",i,(char) Value);
  }

  fclose(fileinput);
}


