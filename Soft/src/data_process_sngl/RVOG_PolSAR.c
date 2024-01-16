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

File  : RVOG_PolSAR.c
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

Description :  RVOG PolSAR Estimation from a polarimetric matrix

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
  FILE *out_ms, *out_md, *out_mv, *out_mu, *out_al;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  float Phi, F, mmax;
  float TT11, TT22, TT33, TT12r, TT12i, TT12;
  int ligDone = 0;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **Mms_out;
  float **Mmd_out;
  float **Mmv_out;
  float **Mmu_out;
  float **Mal_out;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nRVOG_PolSAR.exe\n");
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

if(argc < 19) {
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
  if (strcmp(PolType,"C3")==0) strcpy(PolType,"C3T3");

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
  sprintf(file_name, "%s%s", out_dir, "RVOG_PolSAR_ms.bin");
  if ((out_ms = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RVOG_PolSAR_md.bin");
  if ((out_md = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RVOG_PolSAR_mv.bin");
  if ((out_mv = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RVOG_PolSAR_mu.bin");
  if ((out_mu = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "RVOG_PolSAR_alpha.bin");
  if ((out_al = fopen(file_name, "wb")) == NULL)
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

  /* Mms = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmu = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mal = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  
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

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  Mms_out = matrix_float(NligBlock[0], Sub_Ncol);
  Mmd_out = matrix_float(NligBlock[0], Sub_Ncol);
  Mmv_out = matrix_float(NligBlock[0], Sub_Ncol);
  Mmu_out = matrix_float(NligBlock[0], Sub_Ncol);
  Mal_out = matrix_float(NligBlock[0], Sub_Ncol);

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

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

Phi = F = mmax = TT11 = TT22 = TT33 = TT12r = TT12i = TT12 = 0.;
#pragma omp parallel for private(col, M_avg) firstprivate(Phi, F, mmax, TT11, TT22, TT33, TT12r, TT12i, TT12) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      Mms_out[lig][col] = 0.;
      Mmd_out[lig][col] = 0.;
      Mmv_out[lig][col] = 0.;
      Mmu_out[lig][col] = 0.;
      Mal_out[lig][col] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {

        Phi = -0.25 * atan(2.*M_avg[T323_re][col]/(M_avg[T322][col] - M_avg[T333][col]));

        /* Real Rotation Phi */
        TT11 = M_avg[T311][col];
        TT22 = M_avg[T322][col] * cos(2 * Phi) * cos(2 * Phi) + M_avg[T333][col] * sin(2 * Phi) * sin(2 * Phi);
        TT33 = M_avg[T322][col] * sin(2 * Phi) * sin(2 * Phi) + M_avg[T333][col] * cos(2 * Phi) * cos(2 * Phi);
        TT12r = M_avg[T312_re][col] * cos(2 * Phi);
        TT12i = M_avg[T312_im][col] * cos(2 * Phi);
        TT12 = TT12r * TT12r + TT12i * TT12i;

        F = (TT11 / TT33) - (TT12 / (TT33*(TT22-TT33)));
        
        Mmv_out[lig][col] = TT33;
        Mmd_out[lig][col] = 0.5 * (TT11 + TT22 - (F+1)*TT33 + sqrt((TT11 - TT22 - (F-1)*TT33)*(TT11 - TT22 - (F-1)*TT33) + 4.*TT12));
        Mms_out[lig][col] = 0.5 * (TT11 + TT22 - (F+1)*TT33 - sqrt((TT11 - TT22 - (F-1)*TT33)*(TT11 - TT22 - (F-1)*TT33) + 4.*TT12));
        mmax = Mms_out[lig][col];
        if (Mmd_out[lig][col] > Mms_out[lig][col]) mmax = Mmd_out[lig][col];
        Mal_out[lig][col] = acos(1./sqrt(1 + (TT12 /((TT22-TT33-mmax)*(TT22-TT33-mmax)))));
        Mmu_out[lig][col] = mmax * (sin(Mal_out[lig][col])*sin(Mal_out[lig][col]) + (1./F)*cos(Mal_out[lig][col])*cos(Mal_out[lig][col])) / Mmv_out[lig][col];
        Mal_out[lig][col] *= 180. / pi;
        } /*valid_pixel*/
      }
    free_matrix_float(M_avg,NpolarOut);
    }


  write_block_matrix_float(out_ms, Mms_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_md, Mmd_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mv, Mmv_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mu, Mmu_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_al, Mal_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(Mms_out, NligBlock[0]);
  free_matrix_float(Mmd_out, NligBlock[0]);
  free_matrix_float(Mmv_out, NligBlock[0]);
  free_matrix_float(Mmu_out, NligBlock[0]);
  free_matrix_float(Mal_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_ms); fclose(out_md); fclose(out_mv);
  fclose(out_mu); fclose(out_al);
  
/********************************************************************
********************************************************************/

  return 1;
}


