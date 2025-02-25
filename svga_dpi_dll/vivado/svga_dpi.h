/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2020 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


/* NOTE: DO NOT EDIT. AUTOMATICALLY GENERATED FILE. CHANGES WILL BE LOST. */

#ifndef DPI_H
#define DPI_H
#ifdef __cplusplus
#define DPI_LINKER_DECL  extern "C" 
#else
#define DPI_LINKER_DECL
#endif

#include "svdpi.h"



/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_init(
	int n);


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_get_param_int(
	int n ,
	int param_index);


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_set_param_int(
	int n ,
	int param_index ,
	int param_value);


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_set_current_tick(
	int n ,
	svLogic cnt_high ,
	svLogic cnt_low);


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_ready_for_start(
	int n);


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_destroy(
	int n);


#endif
