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

File     : wishart_h_a_alpha_classifierSPPC2_mult.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Unsupervised maximum likelihood classification of a
polarimetric image from the Wishart PDF of its coherency
matrices

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
/* Parameters */
#define Alpha  0
#define H  1
#define A  2

/* CONSTANTS  */
#define Nprm  3  /* nb of parameter files */
#define lim_al1 55.  /* H and alpha decision boundaries */
#define lim_al2 50.
#define lim_al3 48.
#define lim_al4 42.
#define lim_al5 40.
#define lim_H1  0.9
#define lim_H2  0.5

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

#define NPolType 2
/* LOCAL VARIABLES */
  FILE *prm_file_H, *prm_file_al, *prm_file_A;
  FILE *w_H_alpha_file, *w_H_A_alpha_file, *TMPCluster;
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "C2"};
  char file_name[FilePathLength];
  char file_entropy[FilePathLength], file_anisotropy[FilePathLength], file_alpha[FilePathLength];
  char ColorMapWishart8[FilePathLength], ColorMapWishart16[FilePathLength];
  char TMPClusterCenter8[FilePathLength], TMPClusterCenter16[FilePathLength];

/* Internal variables */
  int ii, lig, col, k, l;
  int Npp, Nligg, ligg;
  int ligDone = 0;

  int Bmp_flag;
  float Pct_switch_min;
  int Nit_max;
  int Flag_stop, Nit;

  int zone, area, Narea;

  float a1, a2, a3, a4, a5, h1, h2;
  float r1, r2, r3, r4, r5, r6, r7, r8, r9;
  float Modif, dist_min;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float ***M;
  float ***coh;
  float ***coh_m1;
  float *coh_area[2][2][2];
  float *coh_area_m1[2][2][2];
  float *det_area[2];
  float *det;

  float **Class_im;
  float **M_prm_H;
  float **M_prm_al;
  float **M_prm_A;
  float cpt_area[100];
  float distance[100];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_h_a_alpha_classifierSPPC2_mult.exe\n");
strcat(UsageHelp,"\nParameters:\n");
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
strcat(UsageHelp," (string)	-hf  	input entropy file\n");
strcat(UsageHelp," (string)	-af  	input anisotropy file\n");
strcat(UsageHelp," (string)	-alf 	input alpha file\n");
strcat(UsageHelp," (int)   	-nit 	maximum interation number\n");
strcat(UsageHelp," (float) 	-pct 	maximum of pixel switching classes\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (0/1)\n");
strcat(UsageHelp," (string)	-co8 	input colormap8 file (valid if BMP flag = 1)\n");
strcat(UsageHelp," (string)	-co16	input colormap16 file (valid if BMP flag = 1)\n");
strcat(UsageHelp," (string)	-tmp8	TMP 8 clusters file\n");
strcat(UsageHelp," (string)	-tmp16	TMP 16 clusters file\n");
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

if(argc < 35) {
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
  get_commandline_prm(argc,argv,"-hf",str_cmd_prm,file_entropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-af",str_cmd_prm,file_anisotropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-alf",str_cmd_prm,file_alpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nit",int_cmd_prm,&Nit_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pct",flt_cmd_prm,&Pct_switch_min,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&Bmp_flag,1,UsageHelp);
  if (Bmp_flag == 1) {
  get_commandline_prm(argc,argv,"-co8",str_cmd_prm,ColorMapWishart8,1,UsageHelp);
  get_commandline_prm(argc,argv,"-co16",str_cmd_prm,ColorMapWishart16,1,UsageHelp);
  }
  get_commandline_prm(argc,argv,"-tmp8",str_cmd_prm,TMPClusterCenter8,1,UsageHelp);
  get_commandline_prm(argc,argv,"-tmp16",str_cmd_prm,TMPClusterCenter16,1,UsageHelp);

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
  check_file(ColorMapWishart8);
  check_file(ColorMapWishart16);
  check_file(file_entropy);
  check_file(file_anisotropy);
  check_file(file_alpha);
  if (FlagValid == 1) check_file(file_valid);
  check_file(TMPClusterCenter8);
  check_file(TMPClusterCenter16);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  Pct_switch_min = Pct_switch_min / 100.;
  if (Bmp_flag != 0) Bmp_flag = 1;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  
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

  if ((prm_file_al = fopen(file_alpha, "rb")) == NULL)
    edit_error("Could not open input file : ", file_alpha);
  if ((prm_file_H = fopen(file_entropy, "rb")) == NULL)
    edit_error("Could not open input file : ", file_entropy);
  if ((prm_file_A = fopen(file_anisotropy, "rb")) == NULL)
    edit_error("Could not open input file : ", file_anisotropy);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s%dx%d%s", out_dir, "wishart_H_alpha_class_", NwinL, NwinC, ".bin");
  if ((w_H_alpha_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  sprintf(file_name, "%s%s%dx%d%s", out_dir, "wishart_H_A_alpha_class_", NwinL, NwinC, ".bin");
  if ((w_H_A_alpha_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

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

  /* MprmH = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* Mprmal = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MprmA = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* ClassIm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
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
  Class_im = matrix_float(Sub_Nlig, Sub_Ncol);
  M_prm_H = matrix_float(NligBlock[0], Ncol);
  M_prm_al = matrix_float(NligBlock[0], Ncol);
  M_prm_A = matrix_float(NligBlock[0], Ncol);
  
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

/*Training class matrix memory allocation */
  Narea = 20;
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) Npp = 2;

  det = vector_float(2);
  coh = matrix3d_float(Npp, Npp, 2);
  for (k = 0; k < Npp; k++) {
  for (l = 0; l < Npp; l++) {
    coh_area[k][l][0] = vector_float(Narea);
    coh_area[k][l][1] = vector_float(Narea);
    coh_area_m1[k][l][0] = vector_float(Narea);
    coh_area_m1[k][l][1] = vector_float(Narea);
    }
  }
  det_area[0] = vector_float(Narea);
  det_area[1] = vector_float(Narea);

  for (area = 1; area <= Narea; area++) cpt_area[area] = 0.;

/****************************************************/
/****************************************************/
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_matrix_float(prm_file_H, M_prm_H, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(prm_file_al, M_prm_al, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

area = 0;
a1 = a2 = a3 = a4 = a5 = h1 = h2 = 0.;
r1 = r2 = r3 = r4 = r5 = r6 = r7 = r8 = r9 = 0.;
#pragma omp parallel for private(col, k, l, M_avg, M) firstprivate(ligg, area, a1, a2, a3, a4, a5, h1, h2, r1, r2, r3, r4, r5, r6, r7, r8, r9) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        /* Average complex coherency matrix determination*/
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[3][col];
        M[1][1][1] = 0.;
    
        a1 = (M_prm_al[lig][col] <= lim_al1);
        a2 = (M_prm_al[lig][col] <= lim_al2);
        a3 = (M_prm_al[lig][col] <= lim_al3);
        a4 = (M_prm_al[lig][col] <= lim_al4);
        a5 = (M_prm_al[lig][col] <= lim_al5);

        h1 = (M_prm_H[lig][col] <= lim_H1);
        h2 = (M_prm_H[lig][col] <= lim_H2);

        /* ZONE 1 (top right)*/
        r1 = !a1 * !h1;
        /* ZONE 2 (center right)*/
        r2 = a1 * !a5 * !h1;
        /* ZONE 3 (bottom right)*/
        r3 = a5 * !h1;
        /* ZONE 4 (top center)*/
        r4 = !a2 * h1 * !h2;
        /* ZONE 5 (center center)*/
        r5 = a2 * !a5 * h1 * !h2;
        /* ZONE 6 (bottom center)*/
        r6 = a5 * h1 * !h2;
        /* ZONE 7 (top left)*/
        r7 = !a3 * h2;
        /* ZONE 8 (center left)*/
        r8 = a3 * !a4 * h2;
        /* ZONE 9 (bottom right)*/
        r9 = a4 * h2;

        /* segment values ranging from 1 to 9 */
        area = (int) (r1 + 2 * r2 + 3 * r3 + 4 * r4 + 5 * r5 + 6 * r6 + 7 * r7 + 8 * r8 + 9 * r9);

        /* Class center coherency matrices are initialized
        according to the H_alpha classification results*/
        for (k = 0; k < Npp; k++)
          for (l = 0; l < Npp; l++) {
            coh_area[k][l][0][area] = coh_area[k][l][0][area] + M[k][l][0];
            coh_area[k][l][1][area] = coh_area[k][l][1][area] + M[k][l][1];
            }
        cpt_area[area] = cpt_area[area] + 1.;
        Class_im[ligg][col] = (float) area;
        } /*valid*/
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  Narea = 8;
  for (area = 1; area <= Narea; area++)
  if (cpt_area[area] != 0.) {
    for (k = 0; k < Npp; k++)
    for (l = 0; l < Npp; l++) {
      coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
      coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
      }
    }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
  if (cpt_area[area] != 0.) {
  for (k = 0; k < Npp; k++) {
    for (l = 0; l < Npp; l++) {
    coh[k][l][0] = coh_area[k][l][0][area];
    coh[k][l][1] = coh_area[k][l][1][area];
    }
    }
  InverseHermitianMatrix2(coh, coh_m1);
  DeterminantHermitianMatrix2(coh, det);
  for (k = 0; k < Npp; k++) {
    for (l = 0; l < Npp; l++) {
    coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
    coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
    }
    }
  det_area[0][area] = det[0];
  det_area[1][area] = det[1];
  }
  }
  
  free_matrix3d_float(coh_m1, Npp, Npp);

/****************************************************
//START OF THE WISHART H-ALPHA CLASSIFICATION
*****************************************************/

Flag_stop = 0;
Nit = 0;

while (Flag_stop == 0) {
  Nit++;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

zone = 0;
dist_min = INIT_MINMAX; 
#pragma omp parallel for private(col, area, k, l, M_avg, M, coh_m1) firstprivate(ligg, distance, dist_min, zone, Modif) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        /* Average complex coherency matrix determination*/
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[3][col];
        M[1][1][1] = 0.;

        /*Seeking for the closest cluster center */
        for (area = 1; area <= Narea; area++) {
        if (cpt_area[area] != 0.) {
          for (k = 0; k < Npp; k++) {
            for (l = 0; l < Npp; l++) {
              coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
              coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
              }
            }
          distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
          distance[area] = distance[area] + Trace2_HM1xHM2(coh_m1,M);
          }
          }
        dist_min = INIT_MINMAX;
        for (area = 1; area <= Narea; area++) {
        if (cpt_area[area] != 0.) {
          if (dist_min > distance[area]) {
            dist_min = distance[area];
            zone = area;
            }
          }
          }
        if (zone != (int) Class_im[ligg][col]) Modif = Modif + 1.;
        Class_im[ligg][col] = (float) zone;
        } /*valid*/
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  Flag_stop = 0;
  if (Modif < Pct_switch_min * (float) (Sub_Nlig * Sub_Ncol)) Flag_stop = 1;
  if (Nit == Nit_max) Flag_stop = 1;

  printf("%f\r", 100. * Nit / Nit_max);fflush(stdout);

  if (Flag_stop == 0) {
    /*Calcul des nouveaux centres de classe*/
    for (area = 1; area <= Narea; area++) {
      cpt_area[area] = 0.;
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = 0.;
          coh_area[k][l][1][area] = 0.;
          }
      }

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

area = 0;
#pragma omp parallel for private(col, k, l, M_avg, M) firstprivate(ligg, area) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        /* Average complex coherency matrix determination*/
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[3][col];
        M[1][1][1] = 0.;

        area = (int) Class_im[ligg][col];

        for (k = 0; k < Npp; k++)
          for (l = 0; l < Npp; l++) {
            coh_area[k][l][0][area] = coh_area[k][l][0][area] + M[k][l][0];
            coh_area[k][l][1][area] = coh_area[k][l][1][area] + M[k][l][1];
            }
        cpt_area[area] = cpt_area[area] + 1.;
        } /*valid*/
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  for (area = 1; area <= Narea; area++)
    if (cpt_area[area] != 0.) {
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
          coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
          }
      }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
  if (cpt_area[area] != 0.) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
      
    InverseHermitianMatrix2(coh, coh_m1);
    DeterminantHermitianMatrix2(coh, det);

    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }
    }

    free_matrix3d_float(coh_m1, Npp, Npp);

/*****************************************************/

  } /* Flag Stop */

  } /* while */

/********************************************************************
********************************************************************/
/* Saving wishart_H_alpha classification results bin and bitmap*/
  Class_im[0][0] = 1.; Class_im[1][1] = 8.;

  write_block_matrix_float(w_H_alpha_file, Class_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

  if (Bmp_flag == 1) {
    sprintf(file_name, "%s%s%dx%d", out_dir, "wishart_H_alpha_class_",NwinL,NwinC);
    bmp_wishart(Class_im, Sub_Nlig, Sub_Ncol, file_name, ColorMapWishart8);
    }

  if ((TMPCluster = fopen(TMPClusterCenter8, "wb")) == NULL)
  edit_error("Could not open output file : ", TMPClusterCenter8);
  for (area = 1; area <= Narea; area++) {
    fwrite(&cpt_area[area], sizeof(float), 1, TMPCluster);
    for (k = 0; k < Npp; k++)
      for (l = 0; l < Npp; l++) {
        fwrite(&coh_area[k][l][0][area], sizeof(float), 1, TMPCluster);
        fwrite(&coh_area[k][l][1][area], sizeof(float), 1, TMPCluster);
        }
    }
  fclose(TMPCluster);

/********************************************************************
//END OF THE WISHART H-ALPHA CLASSIFICATION
********************************************************************/

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  
  Narea = 20;
  for (area = 1; area <= Narea; area++) {
    cpt_area[area] = 0.;
    for (k = 0; k < Npp; k++)
      for (l = 0; l < Npp; l++) {
        coh_area[k][l][0][area] = 0.;
        coh_area[k][l][1][area] = 0.;
        }
    }

Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_matrix_float(prm_file_A, M_prm_A, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

area = 0;
#pragma omp parallel for private(col, k, l, M_avg, M) firstprivate(ligg, area) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        /* Average complex coherency matrix determination*/
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[3][col];
        M[1][1][1] = 0.;

        area = (int) Class_im[ligg][col];
        if (M_prm_A[lig][col] > 0.5) area = area + 8;

        /* Class center coherency matrices are initialized
        according to the H_alpha classification results*/
        for (k = 0; k < Npp; k++)
          for (l = 0; l < Npp; l++) {
            coh_area[k][l][0][area] = coh_area[k][l][0][area] + M[k][l][0];
            coh_area[k][l][1][area] = coh_area[k][l][1][area] + M[k][l][1];
            }
        cpt_area[area] = cpt_area[area] + 1.;
        Class_im[ligg][col] = (float) area;
        } /*valid*/
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  Narea = 16;
  for (area = 1; area <= Narea; area++)
  if (cpt_area[area] != 0.) {
    for (k = 0; k < Npp; k++)
      for (l = 0; l < Npp; l++) {
        coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
        coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
        }
    }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
  if (cpt_area[area] != 0.) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }

    InverseHermitianMatrix2(coh, coh_m1);
    DeterminantHermitianMatrix2(coh, det);

    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }
    }

  free_matrix3d_float(coh_m1, Npp, Npp);

/****************************************************
//START OF THE WISHART H-A-ALPHA CLASSIFICATION
*****************************************************/

Flag_stop = 0;
Nit = 0;

while (Flag_stop == 0) {
  Nit++;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

zone = 0;
dist_min = INIT_MINMAX; 
#pragma omp parallel for private(col, area, k, l, M_avg, M, coh_m1) firstprivate(ligg, distance, dist_min, zone, Modif) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        /* Average complex coherency matrix determination*/
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[3][col];
        M[1][1][1] = 0.;

        /*Seeking for the closest cluster center */
        for (area = 1; area <= Narea; area++) {
        if (cpt_area[area] != 0.) {
          for (k = 0; k < Npp; k++) {
            for (l = 0; l < Npp; l++) {
              coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
              coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
              }
            }
          distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
          distance[area] = distance[area] + Trace2_HM1xHM2(coh_m1,M);
          }
          }
        dist_min = INIT_MINMAX;
        for (area = 1; area <= Narea; area++) {
          if (cpt_area[area] != 0.) {
          if (dist_min > distance[area]) {
            dist_min = distance[area];
            zone = area;
            }
          }
          }
        if (zone != (int) Class_im[ligg][col]) Modif = Modif + 1.;
        Class_im[ligg][col] = (float) zone;
        } /*valid*/
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  Flag_stop = 0;
  if (Modif < Pct_switch_min * (float) (Sub_Nlig * Sub_Ncol)) Flag_stop = 1;
  if (Nit == Nit_max) Flag_stop = 1;

  printf("%f\r", 100. * Nit / Nit_max);fflush(stdout);

if (Flag_stop == 0) {
  /*Calcul des nouveaux centres de classe*/
  for (area = 1; area <= Narea; area++) {
    cpt_area[area] = 0.;
    for (k = 0; k < Npp; k++)
    for (l = 0; l < Npp; l++) {
      coh_area[k][l][0][area] = 0.;
      coh_area[k][l][1][area] = 0.;
      }
    }

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

area = 0;
#pragma omp parallel for private(col, k, l, M_avg, M) firstprivate(ligg, area) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        /* Average complex coherency matrix determination*/
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[3][col];
        M[1][1][1] = 0.;

        area = (int) Class_im[ligg][col];
  
        for (k = 0; k < Npp; k++)
          for (l = 0; l < Npp; l++) {
            coh_area[k][l][0][area] = coh_area[k][l][0][area] + M[k][l][0];
            coh_area[k][l][1][area] = coh_area[k][l][1][area] + M[k][l][1];
            }
        cpt_area[area] = cpt_area[area] + 1.;
        } /*valid*/
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  for (area = 1; area <= Narea; area++) {
    if (cpt_area[area] != 0.) {
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
          coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
          }
      }
    }

  coh_m1 = matrix3d_float(Npp, Npp, 2);
 
/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
  if (cpt_area[area] != 0.) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }

    InverseHermitianMatrix2(coh, coh_m1);
    DeterminantHermitianMatrix2(coh, det);

    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }
    }

  free_matrix3d_float(coh_m1, Npp, Npp);

/*****************************************************/

  } /* Flag Stop */

  } /* while */

/********************************************************************
********************************************************************/
/* Saving wishart_H_A_alpha classification results bin and bitmap*/
  Class_im[0][0] = 1.; Class_im[1][1] = 16.;

  write_block_matrix_float(w_H_A_alpha_file, Class_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

  if (Bmp_flag == 1) {
    sprintf(file_name, "%s%s%dx%d", out_dir, "wishart_H_A_alpha_class_",NwinL,NwinC);
    bmp_wishart(Class_im, Sub_Nlig, Sub_Ncol, file_name, ColorMapWishart16);
    }

  if ((TMPCluster = fopen(TMPClusterCenter16, "wb")) == NULL)
  edit_error("Could not open output file : ", TMPClusterCenter16);
  for (area = 1; area <= Narea; area++) {
    fwrite(&cpt_area[area], sizeof(float), 1, TMPCluster);
    for (k = 0; k < Npp; k++)
      for (l = 0; l < Npp; l++) {
        fwrite(&coh_area[k][l][0][area], sizeof(float), 1, TMPCluster);
        fwrite(&coh_area[k][l][1][area], sizeof(float), 1, TMPCluster);
        }
    }
  fclose(TMPCluster);

/********************************************************************
//END OF THE WISHART H-A-ALPHA CLASSIFICATION
********************************************************************/

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(Class_im, Sub_Nlig);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);
  
/********************************************************************
********************************************************************/

  return 1;
}
