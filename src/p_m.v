/*
	MERA-400 P-M unit (microinstructions)

	document:	12-006368-01-8A
	unit:			P-M3-2
	pages:		2-11..2-28
	sheets:		19
*/

module p_m(
	// sheet 1
	input start__,
	input pon,
	input work,
	input hlt_n,
	input stop,
	input clo,
	input hlt,
	input cycle,
	input irq,
	output start,
	output _wait,
	output run,
	// sheet 2
	input ekc_1,
	input ekc_i,
	input ekc_2,
	input got,
	input ekc_fp,
	input clm,
	input strob2,
	output sp0,
	output przerw,
	output si1,
	output sp1,
	// sheet 3
	input k2,
	input store,
	input fetch,
	input load,
	input bin,
	input rdt11,
	input k1,
	output laduj,
	output k2_bin_store,
	output w_rbc__,
	output w_rba__,
	output w_rbb__,
	// sheet 4
	input p0,
	input rdt9,
	output ep0,
	output stp0,
	output ek2,
	output ek1,
	// sheet 5
	input js,
	input bcoc__,
	input zs,
	input p2,
	input ssp__,
	input sc__,
	input md,
	input xi,
	output p,
	output mc_3,
	output mc,
	output xi__,
	// sheet 6
	input p4,
	input b0,
	input na,
	input c0,
	input ka2,
	input ka1,
	// sheet 7
	input p3,
	input p1,
	input nef,
	input p5,
	input i2,
	output pp,
	output ep5,
	output ep4,
	output ep3,
	output ep1,
	output ep2,
	output icp1,
	// sheet 8
	input strob1,
	input exl,
	input lipsp__,
	input gr__,
	input wx,
	input shc,
	// sheet 9
	input read_fp,
	input ir7,
	input inou__,
	input rok,
	output arp1,
	output lg_3,
	output lg_0,
	// sheet 10
	input rsc,
	input ir10,
	input lpb,
	input ir11,
	input rsb,
	input ir12,
	input rsa,
	input lpa,
	input rlp_fp,
	output rc,
	output rb,
	output ra,
	// sheet 11
	input bod,
	input ir15,
	input ir14,
	input ir13,
	input ir9,
	input ir8,
	output lk,
	// sheet 12
	input rj,
	input uj__,
	input lwt__,
	input sr__,
	input lac__,
	input lrcb__,
	input rpc,
	input rc__,
	input ng__,
	input ls,
	input oc__,
	input wa,
	input wm,
	input wz,
	input ww,
	input wr,
	input wp,
	output wls,
	// sheet 13
	input ri,
	input war,
	input wre,
	input i3,
	input s_fp,
	input sar__,
	input lar__,
	input in,
	input bs,
	input zb__,
	output w_r,
	// sheet 14
	input wic,
	input i4,
	input wac,
	input i1,
	output w_ic,
	output w_ac,
	output w_ar,
	// sheet 15
	input wrz,
	input wrs,
	input mb,
	input im,
	input lj,
	input lwrs,
	input jkrb,
	output lrz,
	output w_bar,
	output w_rm,
	// sheet 16
	input we,
	input ib,
	input ir6,
	input cb,
	input i5,
	input rb__,
	input w__,
	input i3_ex_prz,
	output baa,
	output bab,
	output bac,
	output aa,
	output ab,
	// sheet 17
	input at15,
	input srez__,
	input rz,
	input wir,
	input blw_pw,
	output wpb,
	output bwb,
	output bwa,
	output kia,
	output kib,
	output w_ir,
	// sheet 18
	input ki,
	input dt_w,
	input f13,
	input wkb,
	output mwa,
	output mwb,
	output mwc
);

	// sheet 1, page 2-11
	//  * ff: START, WAIT, CYCLE

	// sheet 2
	//  * ff: PR (pobranie rozkazu - instruction fetch)
	//  * ff: PP (przyjęcie przerwania - interrupt receive)
	//  * univib: KC (koniec cyklu - cycle end)
	//  * univib: PC (początek cyklu - cycle start)

	// sheet 3, page 2-12
	//  * ff: FETCH, STORE, LOAD, BIN (bootstrap)

	// sheet 4, page 2-13
	//  * control panel state transitions
	//  * transition to P0 state

	// sheet 5, page 2-14
	//  * P - wskaźnik przeskoku (branch flag)
	//  * MC - premodification counter

	// sheet 6, page 2-15
	//  * WPI - wskaźnik premodyfikacji (premodification indicator)
	//  * WBI - wskaźnik B-modyfikacji (B-modification indicator)

	// sheet 7, page 2-16
	//  * main loop state transition signals

	// sheet 8, page 2-17

	// sheet 9, page 2-18
	//  * group counter (licznik grupowy)

	// sheet 10, page 2-19
	//  * general register selectors

	// sheet 11, page 2-20
	//  * step counter (licznik kroków)

	// sheet 12, page 2-21

	// sheet 13, page 2-22
	//  * W bus to Rx microoperation

	// sheet 14, page 2-23
	//  * W bus to IC, AC, AR microoperations

	// sheet 15, page 2-24
	//  * W bus to block number (NB) and interrupt mask (RM)

	// sheet 16, page 2-25
	//  * A bus control signals

	// sheet 17, page 2-26
	//  * W bus control signals
	//  * KI bus control signals
	//  * left/right byte selection signals

	// sheet 18, page 2-27
	//  * W bus control signals

endmodule

// vim: tabstop=2 shiftwidth=2 autoindent noexpandtab
