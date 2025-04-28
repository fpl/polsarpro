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

File     : arii_nned_3components_reconstruction.c
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

Description :  Arri - VanZyl 3 components Reconstruction
               NNED : Non Negative Eigenvalue Decomposition

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

#define NPolType 3
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  
/* Internal variables */
  int ii, lig, col;
  int ligDone = 0;

  float Span, SpanMin, SpanMax;
  float ALPre, ALPim, BETre, BETim;
  float OMEGA1, OMEGA2, OMEGAodd, OMEGAdbl;
  float x1, x2, xmax;
  float fv, a, b, z, delta;
  float lambda1, lambda2;
  float gamma, epsilon, rho_re, rho_im, nhu;
  float gamma_veg, epsilon_veg, rho_re_veg, rho_im_veg, nhu_veg;
  float hh1_re, hh1_im, vv1_re, vv1_im, hh2_re, hh2_im;
  float A0A0, B0pB;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float ***M_odd;
  float ***M_dbl;
  float ***M_vol;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\narii_nned_3components_reconstruction.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od1 	output directory - ground\n");
strcat(UsageHelp," (string)	-od2 	output directory - double\n");
strcat(UsageHelp," (string)	-od3 	output directory - volume\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
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
  get_commandline_prm(argc,argv,"-od1",str_cmd_prm,out_dir1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od2",str_cmd_prm,out_dir2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od3",str_cmd_prm,out_dir3,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir1);
  check_dir(out_dir2);
  check_dir(out_dir3);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out1 = matrix_char(NpolarOut,1024); 
  file_name_out2 = matrix_char(NpolarOut,1024); 
  file_name_out3 = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir1, file_name_out1);
  init_file_name(PolTypeOut, out_dir2, file_name_out2);
  init_file_name(PolTypeOut, out_dir3, file_name_out3);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
  if ((out_datafile1[Np] = fopen(file_name_out1[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out1[Np]);
  
  for (Np = 0; Np < NpolarOut; Np++)
  if ((out_datafile2[Np] = fopen(file_name_out2[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out2[Np]);
  
  for (Np = 0; Np < NpolarOut; Np++)
  if ((out_datafile3[Np] = fopen(file_name_out3[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out3[Np]);
  
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

  /* Modd = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
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
  //M_avg = matrix_float(NpolarOut, Sub_Ncol);
  M_odd = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_dbl = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_vol = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);

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
/* SPANMIN / SPANMAX DETERMINATION */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Span = 0.;
SpanMin = INIT_MINMAX;
SpanMax = -INIT_MINMAX;
  
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
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

#pragma omp parallel for private(col, M_avg) firstprivate(Span) shared(ligDone, SpanMin, SpanMax)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Span = M_avg[C311][col]+M_avg[C322][col]+M_avg[C333][col];
        if (Span >= SpanMax) SpanMax = Span;
        if (Span <= SpanMin) SpanMin = Span;
        }       
      }
    free_matrix_float(M_avg,NpolarOut);
    }
  } // NbBlock

  if (SpanMin < eps) SpanMin = eps;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

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
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

ALPre = ALPim = BETre = BETim = OMEGA1 = OMEGA2 = OMEGAodd = OMEGAdbl = 0.;
x1 = x2 = xmax = fv = a = b = z = delta = lambda1 = lambda2 = 0.;
gamma = epsilon = rho_re = rho_im = nhu = gamma_veg = epsilon_veg = rho_re_veg = rho_im_veg = nhu_veg = 0.;
hh1_re = hh1_im = vv1_re = vv1_im = hh2_re = hh2_im = A0A0 = B0pB = 0.;
#pragma omp parallel for private(col, Np, M_avg) firstprivate(ALPre, ALPim, BETre, BETim, OMEGA1, OMEGA2, OMEGAodd, OMEGAdbl, x1, x2, xmax, fv, a, b, z, delta, lambda1, lambda2, gamma, epsilon, rho_re, rho_im, nhu, gamma_veg, epsilon_veg, rho_re_veg, rho_im_veg, nhu_veg, hh1_re, hh1_im, vv1_re, vv1_im, hh2_re, hh2_im, A0A0, B0pB) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) M_odd[Np][lig][col] = 0.;
      for (Np = 0; Np < NpolarOut; Np++) M_dbl[Np][lig][col] = 0.;
      for (Np = 0; Np < NpolarOut; Np++) M_vol[Np][lig][col] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        epsilon = M_avg[C311][col];
        rho_re = M_avg[C313_re][col];
        rho_im = M_avg[C313_im][col];
        nhu = M_avg[C322][col];
        gamma = M_avg[C333][col];
        
        fv = 3.*nhu/2.;
        
        epsilon_veg = fv;
        rho_re_veg = fv/3.;
        rho_im_veg = 0.;
        nhu_veg = 2.*fv/3.;
        gamma_veg = fv;

        z = epsilon*gamma_veg + epsilon_veg*gamma - 2.*rho_re*rho_re_veg;
        a = epsilon_veg*gamma_veg - rho_re_veg*rho_re_veg;
        b = epsilon*gamma - rho_re*rho_re - rho_im*rho_im;
        
        x1 = nhu / nhu_veg;
        if (a == 0.) {
          x2 = b / z;
          } else {
          x2 = (z - sqrt(z*z - 4.*a*b)) / (2.*a);
          }
        if (x1 <= x2) xmax = x1;
        else xmax = x2;

        /* C reminder */
        epsilon = epsilon - xmax*epsilon_veg;
        rho_re = rho_re - xmax*rho_re_veg;
        rho_im = rho_im - xmax*rho_im_veg;
        nhu = nhu - xmax*nhu_veg;
        gamma = gamma - xmax*gamma_veg;

        /*Van Zyl algorithm*/
        delta = (epsilon - gamma)*(epsilon - gamma) + 4.*(rho_re*rho_re + rho_im*rho_im);

        lambda1 = 0.5*(epsilon + gamma + sqrt(delta));
        lambda2 = 0.5*(epsilon + gamma - sqrt(delta));
        
        OMEGA1 = lambda1*(gamma - epsilon + sqrt(delta))*(gamma - epsilon + sqrt(delta));
        OMEGA1 = OMEGA1 / ((gamma - epsilon + sqrt(delta))*(gamma - epsilon + sqrt(delta)) + 4.*(rho_re*rho_re + rho_im*rho_im));

        OMEGA2 = lambda2*(gamma - epsilon - sqrt(delta))*(gamma - epsilon - sqrt(delta));
        OMEGA2 = OMEGA2 / ((gamma - epsilon - sqrt(delta))*(gamma - epsilon - sqrt(delta)) + 4.*(rho_re*rho_re + rho_im*rho_im));

        hh1_re = 2.*rho_re / (gamma - epsilon + sqrt(delta));
        hh1_im = 2.*rho_im / (gamma - epsilon + sqrt(delta));
        vv1_re = 1.; vv1_im = 0.;

        hh2_re = 2.*rho_re / (gamma - epsilon - sqrt(delta));
        hh2_im = 2.*rho_im / (gamma - epsilon - sqrt(delta));

        A0A0 = (hh1_re+vv1_re)*(hh1_re+vv1_re) + (hh1_im+vv1_im)*(hh1_im+vv1_im);
        B0pB = (hh1_re-vv1_re)*(hh1_re-vv1_re) + (hh1_im-vv1_im)*(hh1_im-vv1_im);
        
        if (A0A0 > B0pB) {
          ALPre = hh1_re; ALPim = hh1_im; OMEGAodd = OMEGA1;
          BETre = hh2_re; BETim = hh2_im; OMEGAdbl = OMEGA2;  
          } else {
          ALPre = hh2_re; ALPim = hh2_im; OMEGAodd = OMEGA2;
          BETre = hh1_re; BETim = hh1_im; OMEGAdbl = OMEGA1;  
          }

        M_odd[C311][lig][col] = OMEGAodd * (ALPre * ALPre + ALPim * ALPim);
        M_odd[C312_re][lig][col] = 0.; M_odd[C312_im][lig][col] = 0.;
        M_odd[C313_re][lig][col] = OMEGAodd * ALPre; M_odd[C313_im][lig][col] = OMEGAodd * ALPim;
        M_odd[C322][lig][col] = 0.;
        M_odd[C323_re][lig][col] = 0.; M_odd[C323_im][lig][col] = 0.;
        M_odd[C333][lig][col] = OMEGAodd;

        M_dbl[C311][lig][col] = OMEGAdbl * (BETre * BETre + BETim * BETim);
        M_dbl[C312_re][lig][col] = 0.; M_dbl[C312_im][lig][col] = 0.;
        M_dbl[C313_re][lig][col] = OMEGAdbl * BETre; M_dbl[C313_im][lig][col] = OMEGAdbl * BETim;
        M_dbl[C322][lig][col] = 0.;
        M_dbl[C323_re][lig][col] = 0.; M_dbl[C323_im][lig][col] = 0.;
        M_dbl[C333][lig][col] = OMEGAdbl;

        M_vol[C311][lig][col] = xmax * epsilon_veg;
        M_vol[C312_re][lig][col] = 0.; M_vol[C312_im][lig][col] = 0.;
        M_vol[C313_re][lig][col] = xmax * rho_re_veg; M_vol[C313_im][lig][col] = 0.;
        M_vol[C322][lig][col] = xmax * nhu_veg;
        M_vol[C323_re][lig][col] = 0.; M_vol[C323_im][lig][col] = 0.;
        M_vol[C333][lig][col] = xmax * gamma_veg;

        for (Np = 0; Np < NpolarOut; Np++) {
          if (M_odd[Np][lig][col] < SpanMin) M_odd[Np][lig][col] = SpanMin;
          if (M_odd[Np][lig][col] > SpanMax) M_odd[Np][lig][col] = SpanMax;
          if (M_dbl[Np][lig][col] < SpanMin) M_dbl[Np][lig][col] = SpanMin;
          if (M_dbl[Np][lig][col] > SpanMax) M_dbl[Np][lig][col] = SpanMax;
          if (M_vol[Np][lig][col] < SpanMin) M_vol[Np][lig][col] = SpanMin;
          if (M_vol[Np][lig][col] > SpanMax) M_vol[Np][lig][col] = SpanMax;
          }
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }

  if (strcmp(PolTypeOut,"T3")==0) {
    C3_to_T3(M_odd, NligBlock[Nb], Sub_Ncol, 0, 0);
    C3_to_T3(M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0);
    C3_to_T3(M_vol, NligBlock[Nb], Sub_Ncol, 0, 0);
    }

  write_block_matrix3d_float(out_datafile1, NpolarOut, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix3d_float(out_datafile2, NpolarOut, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix3d_float(out_datafile3, NpolarOut, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_odd, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_dbl, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_vol, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile1[Np]);
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile2[Np]);
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile3[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}


