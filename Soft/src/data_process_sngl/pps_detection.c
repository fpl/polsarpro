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

File  : pps_detection.c
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

Description :  Polarised Point Scatterer detection from the 
               Cloude-Pottier eigenvector/eigenvalue based
               decomposition

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

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *out_file;
  int Config;
  char *PolTypeConf[NPolType] = {"S2","C3", "C4", "T3", "T4"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k;
  int ligDone = 0;

  float alpha[4], p[4];
  float p1_threshold, alp1_threshold;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_out;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\npps_detection.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-a1  	alpha1 threshold\n");
strcat(UsageHelp," (float) 	-p1  	p1 threshold\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-a1",flt_cmd_prm,&alp1_threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-p1",flt_cmd_prm,&p1_threshold,1,UsageHelp);

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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"S2")==0) {
    if (strcmp(PolarCase,"monostatic") == 0) strcpy(PolType, "S2T3");
    if (strcmp(PolarCase,"bistatic") == 0) strcpy(PolType, "S2T4");
    }
  if (strcmp(PolType,"C3")==0) strcpy(PolType, "C3T3");
  if (strcmp(PolType,"C4")==0) strcpy(PolType, "C4T4");

  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "pps_detection.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

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

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);
  
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
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
 
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T4(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

#pragma omp parallel for private(col, k, M, V, lambda, M_avg) firstprivate(alpha, p) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    if (strcmp(PolTypeOut,"T3")==0) {
      M = matrix3d_float(3, 3, 2);
      V = matrix3d_float(3, 3, 2);
      lambda = vector_float(3);
      }
    if (strcmp(PolTypeOut,"T4")==0) {
      M = matrix3d_float(4, 4, 2);
      V = matrix3d_float(4, 4, 2);
      lambda = vector_float(4);
      }
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        if (strcmp(PolTypeOut,"T3")==0) {
          M[0][0][0] = eps + M_avg[0][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][col];
          M[0][1][1] = eps + M_avg[2][col];
          M[0][2][0] = eps + M_avg[3][col];
          M[0][2][1] = eps + M_avg[4][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[5][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[6][col];
          M[1][2][1] = eps + M_avg[7][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[8][col];
          M[2][2][1] = 0.;

          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(3, M, V, lambda);
  
          for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 3; k++)  {
            alpha[k] = (acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1])))*180. / pi;
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }
          }
        if (strcmp(PolTypeOut,"T4")==0) {
          M[0][0][0] = eps + M_avg[0][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][col];
          M[0][1][1] = eps + M_avg[2][col];
          M[0][2][0] = eps + M_avg[3][col];
          M[0][2][1] = eps + M_avg[4][col];
          M[0][3][0] = eps + M_avg[5][col];
          M[0][3][1] = eps + M_avg[6][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[7][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[8][col];
          M[1][2][1] = eps + M_avg[9][col];
          M[1][3][0] = eps + M_avg[10][col];
          M[1][3][1] = eps + M_avg[11][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[12][col];
          M[2][2][1] = 0.;
          M[2][3][0] = eps + M_avg[13][col];
          M[2][3][1] = eps + M_avg[14][col];
          M[3][0][0] =  M[0][3][0];
          M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0];
          M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0];
          M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + M_avg[15][col];
          M[3][3][1] = 0.;

          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(4, M, V, lambda);
  
          for (k = 0; k < 4; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 4; k++)  {
            alpha[k] = (acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]))) * 180. / pi;
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2] + lambda[3]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }
          }
    
        M_out[lig][col] = 0;
        if ((p[0] > p1_threshold)&&(alpha[0] > alp1_threshold)) M_out[lig][col] = 1.;
        } else {
        M_out[lig][col] = 0;
        }
      }
    if (strcmp(PolTypeOut,"T3")==0) {
      free_matrix3d_float(M, 3, 3);
      free_matrix3d_float(V, 3, 3);
      }
    if (strcmp(PolTypeOut,"T4")==0) {
      free_matrix3d_float(M, 4, 4);
      free_matrix3d_float(V, 4, 4);
      }
    free_vector_float(lambda);
    free_matrix_float(M_avg,NpolarOut);
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


