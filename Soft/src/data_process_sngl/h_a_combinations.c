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

File  : h_a_combinations.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Calculate the combinations between Entropy and 
               Anisotropy from the Cloude-Pottier eigenvector / 
               eigenvalue based decomposition of a coherency matrix

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
  FILE *fileH, *fileA;
  FILE *fileHA, *fileH1mA, *file1mHA, *file1mH1mA;
  char filename[FilePathLength];
  
/* Internal variables */
  int lig, col, k;

  int Flag[4];

/* Matrix arrays */
  float **MH_in;
  float **MA_in;
  float **MHA_out;
  float **MH1mA_out;
  float **M1mHA_out;
  float **M1mH1mA_out;

  for (k = 0; k < 4; k++)  Flag[k] = 0;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_a_combinations.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-ha  	Flag combination HA\n");
strcat(UsageHelp," (int)   	-h1a 	Flag combination H(1-A)\n");
strcat(UsageHelp," (int)   	-1ha 	Flag combination (1-H)A\n");
strcat(UsageHelp," (int)   	-1h1a	Flag combination (1-H)(1-A)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ha",int_cmd_prm,&Flag[0],1,UsageHelp);
  get_commandline_prm(argc,argv,"-h1a",int_cmd_prm,&Flag[1],1,UsageHelp);
  get_commandline_prm(argc,argv,"-1ha",int_cmd_prm,&Flag[2],1,UsageHelp);
  get_commandline_prm(argc,argv,"-1h1a",int_cmd_prm,&Flag[3],1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT FILE OPENING*/
  sprintf(filename, "%sentropy.bin", in_dir);
  if ((fileH = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sanisotropy.bin", in_dir);
  if ((fileA = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if (Flag[0] == 1) {
    sprintf(filename, "%scombination_HA.bin.bin", out_dir);
    if ((fileHA = fopen(filename, "wb")) == NULL)
      edit_error("Could not open input file : ", filename);
    }
  if (Flag[1] == 1) {
    sprintf(filename, "%scombination_H1mA.bin.bin", out_dir);
    if ((fileH1mA = fopen(filename, "wb")) == NULL)
      edit_error("Could not open input file : ", filename);
    }
  if (Flag[2] == 1) {
    sprintf(filename, "%scombination_1mHA.bin.bin", out_dir);
    if ((file1mHA = fopen(filename, "wb")) == NULL)
      edit_error("Could not open input file : ", filename);
    }
  if (Flag[3] == 1) {
    sprintf(filename, "%scombination_1mH1mA.bin.bin", out_dir);
    if ((file1mH1mA = fopen(filename, "wb")) == NULL)
      edit_error("Could not open input file : ", filename);
    }

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* MHin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MAin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  
  /* MHAout = Nlig*Sub_Ncol */
  if (Flag[0] == 1) NBlockA += Sub_Ncol; NBlockB += 0;
  /* MH1mAout = Nlig*Sub_Ncol */
  if (Flag[1] == 1) NBlockA += Sub_Ncol; NBlockB += 0;
  /* M1mHAout = Nlig*Sub_Ncol */
  if (Flag[2] == 1) NBlockA += Sub_Ncol; NBlockB += 0;
  /* M1mH1mAout = Nlig*Sub_Ncol */
  if (Flag[3] == 1) NBlockA += Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  MH_in = matrix_float(NligBlock[0], Sub_Ncol);
  MA_in = matrix_float(NligBlock[0], Sub_Ncol);
  if (Flag[0] == 1) MHA_out = matrix_float(NligBlock[0], Sub_Ncol);
  if (Flag[1] == 1) MH1mA_out = matrix_float(NligBlock[0], Sub_Ncol);
  if (Flag[2] == 1) M1mHA_out = matrix_float(NligBlock[0], Sub_Ncol);
  if (Flag[3] == 1) M1mH1mA_out = matrix_float(NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileH, MH_in, Nb, NbBlock, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileA, MA_in, Nb, NbBlock, Sub_Nlig, Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (Flag[0] == 1) MHA_out[lig][col] = MH_in[lig][col]*MA_in[lig][col];
        if (Flag[1] == 1) MH1mA_out[lig][col] = MH_in[lig][col]*(1. - MA_in[lig][col]);
        if (Flag[2] == 1) M1mHA_out[lig][col] = (1. - MH_in[lig][col])*MA_in[lig][col];
        if (Flag[3] == 1) M1mH1mA_out[lig][col] = (1. - MH_in[lig][col])*(1. - MA_in[lig][col]);
        } else {
        if (Flag[0] == 1) MHA_out[lig][col] = 0.;
        if (Flag[1] == 1) MH1mA_out[lig][col] = 0.;
        if (Flag[2] == 1) M1mHA_out[lig][col] = 0.;
        if (Flag[3] == 1) M1mH1mA_out[lig][col] = 0.;
        }
      }
    }

  if (Flag[0] == 1) write_block_matrix_float(fileHA, MHA_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  if (Flag[1] == 1) write_block_matrix_float(fileH1mA, MH1mA_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  if (Flag[2] == 1) write_block_matrix_float(file1mHA, M1mHA_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  if (Flag[3] == 1) write_block_matrix_float(file1mH1mA, M1mH1mA_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(MH_in, NligBlock[0]);
  free_matrix_float(MA_in, NligBlock[0]);
  if (Flag[0] == 1) free_matrix_float(MHA_out, NligBlock[0]);
  if (Flag[1] == 1) free_matrix_float(MH1mA_out, NligBlock[0]);
  if (Flag[2] == 1) free_matrix_float(M1mHA_out, NligBlock[0]);
  if (Flag[3] == 1) free_matrix_float(M1mH1mA_out, NligBlock[0]);

*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  if (Flag[0] == 1) fclose(fileHA);
  if (Flag[1] == 1) fclose(fileH1mA);
  if (Flag[2] == 1) fclose(file1mHA);
  if (Flag[3] == 1) fclose(file1mH1mA);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(fileH);
  fclose(fileA);

/********************************************************************
********************************************************************/

  return 1;
}


