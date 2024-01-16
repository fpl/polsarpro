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

File   : complex_coherence_opt_NR_PP.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Marco LAVALLE, Jacek STRZELCZYK
Modified : Marco Lavalle
Version  : 3.0
Creation : 1/2008
Update  : 8/2012, 7/2015
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

Description :  Interferometric Complex Coherence determination

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
#define nparam_out 2

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
  int Config;
  char *PolTypeConf[NPolType] = {"SPPT4", "T4"};
  FILE *out_file1, *out_file2;
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l, p;
  float epstheta, trace_re, trace_im;  
  float theta1, thetahigh, thetalow;  
  
/* Matrix arrays */
  cplx **T;
  cplx **TT11,**TT12,**TT22, **A, **H;
  cplx **Tmp11,**Tmp12, **Tmp22, **Tmp;
  cplx **V1, **hV1, **iV1;
  float *L;
  float *theta, *theta0, *mod0;

/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float *Mean;
  float **M_out1;
  float **M_out2;
  float *Buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncomplex_coherence_opt_NR_PP.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = SPPT4\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T4\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-teth	Theta High\n");
strcat(UsageHelp," (float) 	-tetl	Theta Low\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
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
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "SPPT4") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T4") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-teth",flt_cmd_prm,&thetahigh,1,UsageHelp);
  get_commandline_prm(argc,argv,"-tetl",flt_cmd_prm,&thetalow,1,UsageHelp);

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

/***********************************************************************
***********************************************************************/

  check_dir(in_dir1);
  if (strcmp(PolType, "SPPT4") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) file_name_in2 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) init_file_name(PolTypeIn, in_dir2, file_name_in2);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0))
    for (Np = 0; Np < NpolarIn; Np++)
      if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
        edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%scmplx_coh_Opt_NR1.bin", out_dir);
  if ((out_file1 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%scmplx_coh_Opt_NR2.bin", out_dir);
  if ((out_file2 = fopen(file_name, "wb")) == NULL)
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

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 2*NpolarIn*2*(Ncol+NwinC); NBlockB += 2*NpolarIn*NwinL*2*(Ncol+NwinC);
    }

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mout = Nlig*2*Sub_Ncol : 1 to 4*/
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  /* Buffer = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
  /* Mean = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
  
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

/* MATRIX ALLOCATION */
  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    }

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out1 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_out2 = matrix_float(NligBlock[0], 2*Sub_Ncol);

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

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile1, S_in1, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_SPP_noavg(in_datafile2, S_in2, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    SPP_to_T4(S_in1, S_in2, M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    } else {
    /* Case of T4 */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

trace_re = trace_im = epstheta = theta1 = 0.;
p=0; Nvalid = 0.;
#pragma omp parallel for private(col, Np, k, l, Mean, Buffer, theta, theta0, mod0, T, TT11, TT12, TT22, Tmp11, Tmp12, Tmp22, Tmp, V1, hV1, iV1, L, A, H) firstprivate(Nvalid, trace_re, trace_im, epstheta, theta1, p)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    Mean = vector_float(NpolarOut);
    Buffer = vector_float(NpolarOut);
    theta  = vector_float(nparam_out);
    theta0 = vector_float(nparam_out);
    mod0  = vector_float(nparam_out);
    T  = cplx_matrix(2,2);
    TT11  = cplx_matrix(2,2);
    TT12  = cplx_matrix(2,2);
    TT22  = cplx_matrix(2,2);
    Tmp11  = cplx_matrix(2,2);
    Tmp12  = cplx_matrix(2,2);
    Tmp22  = cplx_matrix(2,2);
    Tmp  = cplx_matrix(2,2);
    V1  = cplx_matrix(2,2);
    iV1  = cplx_matrix(2,2);
    hV1  = cplx_matrix(2,2);
    L  = vector_float(2);
    A  = cplx_matrix(2,2);
    H  = cplx_matrix(2,2);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out1[lig][2*col] = 0.; M_out1[lig][2*col+1] = 0.;
      M_out2[lig][2*col] = 0.; M_out2[lig][2*col+1] = 0.;
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) Buffer[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++)
              Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            Buffer[Np] = Buffer[Np] - M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }      
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) Mean[Np] = Buffer[Np]/Nvalid;

    if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
      TT11[0][0].re = Mean[0];  TT11[0][0].im = 0;
      TT11[0][1].re = Mean[1];  TT11[0][1].im = Mean[2];
      TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
      TT11[1][1].re = Mean[7]; TT11[1][1].im = 0;

      TT22[0][0].re = Mean[12]; TT22[0][0].im = 0;
      TT22[0][1].re = Mean[13]; TT22[0][1].im = Mean[14];
      TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
      TT22[1][1].re = Mean[15]; TT22[1][1].im = 0;
    
      TT12[0][0].re = Mean[3];  TT12[0][0].im = Mean[4];
      TT12[0][1].re = Mean[5];  TT12[0][1].im = Mean[6];
      TT12[1][0].re = Mean[8]; TT12[1][0].im = Mean[9];
      TT12[1][1].re = Mean[10]; TT12[1][1].im = Mean[11];
  
      /* Computing Local NR */
      for(k=0; k<2; k++) { 
        for(l=0; l<2; l++) {
          T[k][l].re = (TT11[k][l].re + TT22[k][l].re) / 2.;
          T[k][l].im = (TT11[k][l].im + TT22[k][l].im) / 2.;
          }
        }
      
      cplx_diag_mat2(T,V1,L);
    
      for(k=0; k<2; k++) {
        for(l=0; l<2; l++) {
          Tmp11[k][l].re = 0.;
          Tmp11[k][l].im = 0.;
          }
        Tmp11[k][k].re = sqrt(L[k]);
        Tmp11[k][k].im = 0.;
        }

      cplx_htransp_mat(V1,iV1,2,2);
      cplx_mul_mat(V1,Tmp11,Tmp22,2,2);
      cplx_mul_mat(Tmp22,iV1,Tmp,2,2);
      cplx_inv_mat2(Tmp,Tmp11);

      cplx_mul_mat(Tmp11,TT12,Tmp12,2,2);
      cplx_mul_mat(Tmp12,Tmp11,A,2,2);

      trace_re = 0.;
      trace_im = 0.;
      for(k=0; k<2; k++) {
        trace_re = trace_re + A[k][k].re;
        trace_im = trace_im + A[k][k].im;
        }

      theta[0] = thetalow*pi/180.;
      theta[1] = atan2(trace_im, trace_re);
      theta[2] = thetahigh*pi/180.;

      for (Np=0; Np<nparam_out; Np++) {
        theta0[Np] = -theta[Np];
        epstheta = 2*pi;
        p=0;
        while (epstheta>0.01 && p<20) {
          theta1 = -theta0[Np];
          for(k=0; k<2; k++) { 
            for(l=0; l<2; l++) {
              Tmp22[k][l].re = 0.;
              Tmp22[k][l].im = 0.;
              }
            Tmp22[k][k].re = cos(theta1);
            Tmp22[k][k].im = sin(theta1);
            }
          cplx_mul_mat(A,Tmp22,Tmp11,2,2);
          cplx_htransp_mat(Tmp11,Tmp,2,2);
          for(k=0; k<2; k++) 
            for(l=0; l<2; l++) {
              H[k][l].re = (Tmp11[k][l].re + Tmp[k][l].re) / 2.;
              H[k][l].im = (Tmp11[k][l].im + Tmp[k][l].im) / 2.;
              }
          cplx_diag_mat2(H,V1,L);
          cplx_htransp_mat(V1,hV1,2,2);
          cplx_mul_mat(A,V1,Tmp,2,2);
          cplx_mul_mat(hV1,Tmp,Tmp12,2,2);
          cplx_mul_mat(T,V1,Tmp,2,2);
          cplx_mul_mat(hV1,Tmp,Tmp11,2,2);
          theta0[Np] = atan2(Tmp12[0][0].im, Tmp12[0][0].re);
          mod0[Np] = sqrt(Tmp12[0][0].re * Tmp12[0][0].re + Tmp12[0][0].im * Tmp12[0][0].im);
          epstheta = sqrt((theta1 - theta0[Np])*(theta1 - theta0[Np]));
          p++;
          }
        }

      M_out1[lig][2*col] = mod0[0]*cos(theta0[0]);
      M_out1[lig][2*col+1] = mod0[0]*sin(theta0[0]);
      if(isnan(M_out1[lig][2*col])+isnan(M_out1[lig][2*col+1])) {
        M_out1[lig][2*col]=1.; M_out1[lig][2*col+1]=0.;
        }
      M_out2[lig][2*col] = mod0[1]*cos(theta0[1]);
      M_out2[lig][2*col+1] = mod0[1]*sin(theta0[1]);
      if(isnan(M_out2[lig][2*col])+isnan(M_out2[lig][2*col+1])) {
        M_out2[lig][2*col]=1.; M_out2[lig][2*col+1]=0.;
        }
        }        
      }    /*col */
    free_vector_float(Mean);
    free_vector_float(Buffer);
    free_vector_float(theta);
    free_vector_float(theta0);
    free_vector_float(mod0);
    cplx_free_matrix(T,2);
    cplx_free_matrix(TT11,2);
    cplx_free_matrix(TT12,2);
    cplx_free_matrix(TT22,2);
    cplx_free_matrix(Tmp11,2);
    cplx_free_matrix(Tmp12,2);
    cplx_free_matrix(Tmp22,2);
    cplx_free_matrix(Tmp,2);
    cplx_free_matrix(V1,2);
    cplx_free_matrix(iV1,2);
    cplx_free_matrix(hV1,2);
    free_vector_float(L);
    cplx_free_matrix(A,2);
    cplx_free_matrix(H,2);
    }

  write_block_matrix_float(out_file1, M_out1, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);
  write_block_matrix_float(out_file2, M_out2, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + NwinL);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + NwinL);
    }

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix_float(M_out1, NligBlock[0]);
  free_matrix_float(M_out2, NligBlock[0]);
  free_matrix_float(M_out3, NligBlock[0]);
  free_vector_float(Mean);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file1); fclose(out_file2); 

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0))
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}




