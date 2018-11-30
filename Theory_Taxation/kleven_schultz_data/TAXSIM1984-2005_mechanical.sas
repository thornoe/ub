/****************************************************************************************/ 
/* This SAS-program constructs a tax simulator, which computes mechanical changes       */
/* (driven by tax law changes) in marginal tax rates and in virtual incomes in 3-year   */ 
/* intervals between 1984-2005 (i.e. 1984-1987,...,2002-2005). To obtain mechanical     */
/* changes for each 3-year interval, the programs simulates post-year marginal tax      */
/* rates and post-year virtual incomes under base-year incomes choices. For each 3-year */
/* interval, the program is organized in the following 7  steps:                        */
/* Step 1: Data input                                                                   */ 
/* Step 2: Definition of incomes for main taxpayer, spouse and household                */  
/* Step 3: Calculates tax bases for main taxpayer                                       */  
/* Step 4: Calculates tax bases for spouse                                              */  
/* Step 5: Tax liability calculations for main taxpayer                                 */           
/* Step 6: Tax liability calculations for spouse                                        */            
/* Step 7: Calculates mechanical change in marginal tax rates and virtual income        */              
/****************************************************************************************/

dm log 'clear';
dm output 'clear';
options pageno=1 pagesize=100;
goptions reset=all;

options obs=max;

/* Relevante datasæt indlæses */
libname indk 'D:\Rawdata\702487\indk';
libname fain 'D:\Rawdata\702487\fain';
libname skat 'D:\Workdata\702487\Esben\Skatteberegning';
libname idpe 'D:\Rawdata\702487\idpe';
libname udda 'D:\Rawdata\702487\udda';
libname idas 'D:\Rawdata\702487\idas';
libname bif 'D:\Workdata\702487\Esben\Skatteberegning\NYE BEREGNINGER\';
libname lign 'D:\Rawdata\702487\indk_lign';
libname indk2 'D:\Rawdata\702487\indk_ekstra';
libname sskat 'D:\Rawdata\702487\indk_skat';
libname bif2 'D:\Workdata\702487\Esben';


/********************************/
/* MECHANICAL CHANGES 1984-1987 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1984(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1984(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1984(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1984 (keep=pnr hffsp in=d)
       	lign.indk_lign1984(in=e)
		indk2.indkomst1984(in=f)
		fain.fain1986(keep=pnr kom in=h)
		sskat.skat_indk1984(keep=pnr samskat in=k);
kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1987;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1987/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

 proc sort data=samle2;
 by year;
 run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1987));
 run;


 /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1984_1987=1));
year=1987;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 qformue kskat bdagp arblhu adagp stip qovskejd 
 ceiling1 ktax ltax mtax ttax qovskvir qtilpens vederlag qhoninio qfrdpen rentbank kon qsocyd
 rentobl rentinde aktgodt aktudb afhform qkapud qoffpens befordr arbfors lonmio underhol etabhui);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       kon=c_kon
	   qsocyd=c_qsocyd
       qlontmp2=c_qlontmp2
       qformue=c_qformue 
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   stip=c_stip
	   qovskejd=c_qovskejd
       qovskvir=c_qovskvir
	   qoffpens=c_qoffpens
	   qtilpens=c_qtilpens
	   vederlag=c_vederlag
	   qhoninio=c_qhoninio
	   qfrdpen=c_qfrdpen
	   rentbank=c_rentbank
	   rentobl=c_rentobl
	   rentinde=c_rentinde
	   aktgodt=c_aktgodt
	   aktudb=c_aktudb
	   afhform=c_afhform
	   qkapud=c_qkapud
	   befordr=c_befordr
	   arbfors=c_arbfors
	   lonmio=c_lonmio
	   underhol=c_underhol
	   etabhui=c_etabhui
       ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_qformue=. then c_qformue=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_qovskvir=. then c_qovskvir=0;
if c_qoffpens=. then c_qoffpens=0;
if c_qtilpens=. then c_qtilpens=0;
if c_vederlag=. then c_vederlag=0;
if c_qhoninio=. then c_qhoninio=0;
if c_qfrdpen=. then c_qfrdpen=0;
if c_rentbank=. then c_rentbank=0;
if c_rentobl=. then c_rentobl=0;
if c_rentinde=. then c_rentinde=0;
if c_aktgodt=. then c_aktgodt=0;
if c_aktudb=. then c_aktudb=0;
if c_afhform=. then c_afhform=0;
if c_qkapud=. then c_qkapud=0;
if c_befordr=. then c_befordr=0;
if c_arbfors=. then c_arbfors=0;
if c_lonmio=. then c_lonmio=0;
if c_underhol=. then c_underhol=0;
if c_etabhui=. then c_etabhui=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(qovskvir+bdagp+qoffpens+arblhu+adagp+stip+qtilpens+vederlag+qhoninio-qfrdpen)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=(rentbank+rentobl+rentinde+qovskejd+aktgodt+aktudb+afhform-qkapud)*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=(befordr+arbfors+lonmio+underhol+etabhui)*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_qovskvir+c_bdagp+c_qoffpens+c_arblhu+c_adagp+c_stip+c_qtilpens
+c_vederlag+c_qhoninio-c_qfrdpen)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=(c_rentbank+c_rentobl+c_rentinde+c_qovskejd+c_aktgodt+c_aktudb+c_afhform-c_qkapud)*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=(c_befordr+c_arbfors+c_lonmio+c_underhol+c_etabhui)*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;


/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if gift=0 and kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
kapindk_trin1=0; 
if kapindk<=-150000 then kapindk_trin1=kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 35000 kr. (1987-sats) */
kapindk_trin2=-35000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if kapindk>=-150000 then kapindk_trin3=-0.25*(persindk+kapindk-200000);
if kapindk<-150000 then kapindk_trin3=-0.25*(persindk-150000-200000);
if kapindk_trin3>=0 then kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
negkap_kunprop=kapindk_trin1+kapindk_trin2+kapindk_trin3;
if negkap_kunprop<kapindk then negkap_kunprop=kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
negkap_prog=kapindk-negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=0 and kapindk=>0 then negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 35000 kr. (1987-sats) */
h_kapindk_trin2=-35000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if kapindk<0 and c_kapindk<0 then negkap_prog=(h_kapindk-h_negkap_kunprop)*(kapindk/h_kapindk);
if kapindk<0 and c_kapindk=>0 then negkap_prog=h_kapindk-h_negkap_kunprop;
if kapindk=>0 and c_kapindk<0 then negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=1 and h_kapindk=>0 then negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 60000 kr. (1987-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst mindre end lig 60000 kr. */
if kapindk<=60000 then kapindk_12=0; 
/* med kapitalindkomst over 60000 kr. */
if kapindk>60000 then kapindk_12=kapindk-60000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 60000 kr. i husholdning */
if h_kapindk>60000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-60000)*(kapindk/h_kapindk);
if h_kapindk>60000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>60000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-60000;

/* med kapitalindkomst under eller lig med 60000 kr. i husholdning */
if h_kapindk<=60000 then kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1987-ordning: 1/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 20000 kr. omlægges, medmindre */
/* samlet fradrag er under 20000 kr. i hvilket tilfælde alt omlægges */

lignfrad_kunprop=1/6*lignfrad;
if lignfrad_kunprop<20000 then do;
if lignfrad=>20000 then lignfrad_kunprop=20000;
if lignfrad<20000 then lignfrad_prop=lignfrad;
end; 
lignfrad_prog=lignfrad-lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3300 kr. (1987-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6+negkap_prog-lignfrad_prog-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12+negkap_prog-lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if c_gift=0 and c_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
c_kapindk_trin1=0; 
if c_kapindk<=-150000 then c_kapindk_trin1=c_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 35000 kr. (1987-sats) */
c_kapindk_trin2=-35000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if c_kapindk>=-150000 then c_kapindk_trin3=-0.25*(c_persindk+c_kapindk-200000);
if c_kapindk<-150000 then c_kapindk_trin3=-0.25*(c_persindk-150000-200000);
if c_kapindk_trin3>=0 then c_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
c_negkap_kunprop=c_kapindk_trin1+c_kapindk_trin2+c_kapindk_trin3;
if c_negkap_kunprop<c_kapindk then c_negkap_kunprop=c_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
c_negkap_prog=c_kapindk-c_negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=0 and c_kapindk=>0 then c_negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if c_gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 35000 kr. (1987-sats) */
h_kapindk_trin2=-35000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if c_kapindk<0 and kapindk<0 then c_negkap_prog=(h_kapindk-h_negkap_kunprop)*(c_kapindk/h_kapindk);
if c_kapindk<0 and kapindk=>0 then c_negkap_prog=h_kapindk-h_negkap_kunprop;
if c_kapindk=>0 and kapindk<0 then c_negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=1 and h_kapindk=>0 then c_negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 60000 kr. (1987-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst mindre end lig 60000 kr. */
if c_kapindk<=60000 then c_kapindk_12=0; 
/* med kapitalindkomst over 60000 kr. */
if c_kapindk>60000 then c_kapindk_12=c_kapindk-60000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 60000 kr. i husholdning */
if h_kapindk>60000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-60000)*(c_kapindk/h_kapindk);
if h_kapindk>60000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>60000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-60000;

/* med kapitalindkomst under eller lig med 60000 kr. i husholdning */
if h_kapindk<=60000 then c_kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1987-ordning: 1/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 20000 kr. omlægges, medmindre */
/* samlet fradrag er under 20000 kr. i hvilket tilfælde alt omlægges */

c_lignfrad_kunprop=1/6*c_lignfrad;
if c_lignfrad_kunprop<20000 then do;
if c_lignfrad=>20000 then c_lignfrad_kunprop=20000;
if c_lignfrad<20000 then c_lignfrad_prop=c_lignfrad;
end; 
c_lignfrad_prog=c_lignfrad-c_lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3300 kr. (1987-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6+c_negkap_prog-c_lignfrad_prog-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12+c_negkap_prog-c_lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* 12%-skat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;
 
/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* 12%-skat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;



%end;
%mend skat;
%skat;

data bif.skat1987_indkomst1984;
merge new1 (keep=pnr tax1 c_tax1 gift arbindk apersindk kapindk lignfrad
            c_arbindk c_apersindk c_kapindk c_lignfrad qsocyd c_qsocyd 
            bund_dummy mellem_dummy top_dummy notax_dummy x in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;
tau_akt_h=tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;
c_tau_akt_h=c_tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1985-1988 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1985(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1985(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1985(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1985 (keep=pnr hffsp in=d)
       	lign.indk_lign1985(in=e)
		indk2.indkomst1985(in=f)
		fain.fain1987(keep=pnr kom in=h)
		sskat.skat_indk1985(keep=pnr samskat in=k);
kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1988;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1988/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;


proc sort data=samle2;
 by year;
 run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1988));
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1985_1988=1));
year=1988;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 qformue kskat bdagp arblhu adagp stip qovskejd 
 ceiling1 ktax ltax mtax ttax qovskvir qtilpens vederlag qhoninio qfrdpen rentbank kon qsocyd
 rentobl rentinde aktgodt aktudb afhform qkapud qoffpens befordr arbfors lonmio underhol etabhui);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       kon=c_kon
	   qsocyd=c_qsocyd
       qlontmp2=c_qlontmp2
       qformue=c_qformue 
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   stip=c_stip
	   qovskejd=c_qovskejd
       qovskvir=c_qovskvir
	   qoffpens=c_qoffpens
	   qtilpens=c_qtilpens
	   vederlag=c_vederlag
	   qhoninio=c_qhoninio
	   qfrdpen=c_qfrdpen
	   rentbank=c_rentbank
	   rentobl=c_rentobl
	   rentinde=c_rentinde
	   aktgodt=c_aktgodt
	   aktudb=c_aktudb
	   afhform=c_afhform
	   qkapud=c_qkapud
	   befordr=c_befordr
	   arbfors=c_arbfors
	   lonmio=c_lonmio
	   underhol=c_underhol
	   etabhui=c_etabhui
       ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_qformue=. then c_qformue=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_qovskvir=. then c_qovskvir=0;
if c_qoffpens=. then c_qoffpens=0;
if c_qtilpens=. then c_qtilpens=0;
if c_vederlag=. then c_vederlag=0;
if c_qhoninio=. then c_qhoninio=0;
if c_qfrdpen=. then c_qfrdpen=0;
if c_rentbank=. then c_rentbank=0;
if c_rentobl=. then c_rentobl=0;
if c_rentinde=. then c_rentinde=0;
if c_aktgodt=. then c_aktgodt=0;
if c_aktudb=. then c_aktudb=0;
if c_afhform=. then c_afhform=0;
if c_qkapud=. then c_qkapud=0;
if c_befordr=. then c_befordr=0;
if c_arbfors=. then c_arbfors=0;
if c_lonmio=. then c_lonmio=0;
if c_underhol=. then c_underhol=0;
if c_etabhui=. then c_etabhui=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(qovskvir+bdagp+qoffpens+arblhu+adagp+stip+qtilpens+vederlag+qhoninio-qfrdpen)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=(rentbank+rentobl+rentinde+qovskejd+aktgodt+aktudb+afhform-qkapud)*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=(befordr+arbfors+lonmio+underhol+etabhui)*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_qovskvir+c_bdagp+c_qoffpens+c_arblhu+c_adagp+c_stip+c_qtilpens
+c_vederlag+c_qhoninio-c_qfrdpen)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=(c_rentbank+c_rentobl+c_rentinde+c_qovskejd+c_aktgodt+c_aktudb+c_afhform-c_qkapud)*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=(c_befordr+c_arbfors+c_lonmio+c_underhol+c_etabhui)*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;


/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;


/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if gift=0 and kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
kapindk_trin1=0; 
if kapindk<=-150000 then kapindk_trin1=kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 60000 kr. (1988-sats) */
kapindk_trin2=-60000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if kapindk>=-150000 then kapindk_trin3=-0.25*(persindk+kapindk-200000);
if kapindk<-150000 then kapindk_trin3=-0.25*(persindk-150000-200000);
if kapindk_trin3>=0 then kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
negkap_kunprop=kapindk_trin1+kapindk_trin2+kapindk_trin3;
if negkap_kunprop<kapindk then negkap_kunprop=kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
negkap_prog=kapindk-negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=0 and kapindk=>0 then negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 60000 kr. (1988-sats) */
h_kapindk_trin2=-60000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if kapindk<0 and c_kapindk<0 then negkap_prog=(h_kapindk-h_negkap_kunprop)*(kapindk/h_kapindk);
if kapindk<0 and c_kapindk=>0 then negkap_prog=h_kapindk-h_negkap_kunprop;
if kapindk=>0 and c_kapindk<0 then negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=1 and h_kapindk=>0 then negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 85000 kr. (1988-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst mindre end lig 85000 kr. */
if kapindk<=85000 then kapindk_12=0; 
/* med kapitalindkomst over 85000 kr. */
if kapindk>85000 then kapindk_12=kapindk-85000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 85000 kr. i husholdning */
if h_kapindk>85000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-85000)*(kapindk/h_kapindk);
if h_kapindk>85000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>85000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-85000;

/* med kapitalindkomst under eller lig med 85000 kr. i husholdning */
if h_kapindk<=85000 then kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1988-ordning: 2/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 40000 kr. omlægges, medmindre */
/* samlet fradrag er under 40000 kr. i hvilket tilfælde alt omlægges */

lignfrad_kunprop=2/6*lignfrad;
if lignfrad_kunprop<40000 then do;
if lignfrad=>40000 then lignfrad_kunprop=40000;
if lignfrad<40000 then lignfrad_prop=lignfrad;
end; 
lignfrad_prog=lignfrad-lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3400 kr. (1988-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6+negkap_prog-lignfrad_prog-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12+negkap_prog-lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if c_gift=0 and c_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
c_kapindk_trin1=0; 
if c_kapindk<=-150000 then c_kapindk_trin1=c_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 60000 kr. (1988-sats) */
c_kapindk_trin2=-60000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if c_kapindk>=-150000 then c_kapindk_trin3=-0.25*(c_persindk+c_kapindk-200000);
if c_kapindk<-150000 then c_kapindk_trin3=-0.25*(c_persindk-150000-200000);
if c_kapindk_trin3>=0 then c_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
c_negkap_kunprop=c_kapindk_trin1+c_kapindk_trin2+c_kapindk_trin3;
if c_negkap_kunprop<c_kapindk then c_negkap_kunprop=c_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
c_negkap_prog=c_kapindk-c_negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=0 and c_kapindk=>0 then c_negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if c_gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 60000 kr. (1988-sats) */
h_kapindk_trin2=-60000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if c_kapindk<0 and kapindk<0 then c_negkap_prog=(h_kapindk-h_negkap_kunprop)*(c_kapindk/h_kapindk);
if c_kapindk<0 and kapindk=>0 then c_negkap_prog=h_kapindk-h_negkap_kunprop;
if c_kapindk=>0 and kapindk<0 then c_negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=1 and h_kapindk=>0 then c_negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 85000 kr. (1988-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst mindre end lig 85000 kr. */
if c_kapindk<=85000 then c_kapindk_12=0; 
/* med kapitalindkomst over 85000 kr. */
if c_kapindk>85000 then c_kapindk_12=c_kapindk-85000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 85000 kr. i husholdning */
if h_kapindk>85000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-85000)*(c_kapindk/h_kapindk);
if h_kapindk>85000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>85000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-85000;

/* med kapitalindkomst under eller lig med 85000 kr. i husholdning */
if h_kapindk<=85000 then c_kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1988-ordning: 2/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 40000 kr. omlægges, medmindre */
/* samlet fradrag er under 40000 kr. i hvilket tilfælde alt omlægges */

c_lignfrad_kunprop=2/6*c_lignfrad;
if c_lignfrad_kunprop<40000 then do;
if c_lignfrad=>40000 then c_lignfrad_kunprop=40000;
if c_lignfrad<40000 then c_lignfrad_prop=c_lignfrad;
end; 
c_lignfrad_prog=c_lignfrad-c_lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3400 kr. (1988-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6+c_negkap_prog-c_lignfrad_prog-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12+c_negkap_prog-c_lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* 12%-skat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;
 
/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* 12%-skat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;



%end;
%mend skat;
%skat;

data bif.skat1988_indkomst1985;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy in=a)    
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;
tau_akt_h=tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;
c_tau_akt_h=c_tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;

/********************************/
/* MECHANICAL CHANGES 1986-1989 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1986(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1986(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1986(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1986 (keep=pnr hffsp in=d)
       	lign.indk_lign1986(in=e)
		indk2.indkomst1986(in=f)
	
		fain.fain1988(keep=pnr kom in=h)
		sskat.skat_indk1986(keep=pnr samskat in=k);
kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1989;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1989/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

 proc sort data=samle2;
 by year;
 run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1989));
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1986_1989=1));
year=1989;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 qformue kskat bdagp arblhu adagp stip qovskejd 
 ceiling1 ktax ltax mtax ttax qovskvir qtilpens vederlag qhoninio qfrdpen rentbank kon qsocyd
 rentobl rentinde aktgodt aktudb afhform qkapud qoffpens befordr arbfors lonmio underhol etabhui);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       kon=c_kon
	   qsocyd=c_qsocyd
       qlontmp2=c_qlontmp2
       qformue=c_qformue 
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   stip=c_stip
	   qovskejd=c_qovskejd
       qovskvir=c_qovskvir
	   qoffpens=c_qoffpens
	   qtilpens=c_qtilpens
	   vederlag=c_vederlag
	   qhoninio=c_qhoninio
	   qfrdpen=c_qfrdpen
	   rentbank=c_rentbank
	   rentobl=c_rentobl
	   rentinde=c_rentinde
	   aktgodt=c_aktgodt
	   aktudb=c_aktudb
	   afhform=c_afhform
	   qkapud=c_qkapud
	   befordr=c_befordr
	   arbfors=c_arbfors
	   lonmio=c_lonmio
	   underhol=c_underhol
	   etabhui=c_etabhui
       ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_qformue=. then c_qformue=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_qovskvir=. then c_qovskvir=0;
if c_qoffpens=. then c_qoffpens=0;
if c_qtilpens=. then c_qtilpens=0;
if c_vederlag=. then c_vederlag=0;
if c_qhoninio=. then c_qhoninio=0;
if c_qfrdpen=. then c_qfrdpen=0;
if c_rentbank=. then c_rentbank=0;
if c_rentobl=. then c_rentobl=0;
if c_rentinde=. then c_rentinde=0;
if c_aktgodt=. then c_aktgodt=0;
if c_aktudb=. then c_aktudb=0;
if c_afhform=. then c_afhform=0;
if c_qkapud=. then c_qkapud=0;
if c_befordr=. then c_befordr=0;
if c_arbfors=. then c_arbfors=0;
if c_lonmio=. then c_lonmio=0;
if c_underhol=. then c_underhol=0;
if c_etabhui=. then c_etabhui=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(qovskvir+bdagp+qoffpens+arblhu+adagp+stip+qtilpens+vederlag+qhoninio-qfrdpen)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=(rentbank+rentobl+rentinde+qovskejd+aktgodt+aktudb+afhform-qkapud)*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=(befordr+arbfors+lonmio+underhol+etabhui)*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_qovskvir+c_bdagp+c_qoffpens+c_arblhu+c_adagp+c_stip+c_qtilpens
+c_vederlag+c_qhoninio-c_qfrdpen)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=(c_rentbank+c_rentobl+c_rentinde+c_qovskejd+c_aktgodt+c_aktudb+c_afhform-c_qkapud)*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=(c_befordr+c_arbfors+c_lonmio+c_underhol+c_etabhui)*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;


/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;



/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if gift=0 and kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
kapindk_trin1=0; 
if kapindk<=-150000 then kapindk_trin1=kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 85000 kr. (1989-sats) */
kapindk_trin2=-85000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if kapindk>=-150000 then kapindk_trin3=-0.25*(persindk+kapindk-200000);
if kapindk<-150000 then kapindk_trin3=-0.25*(persindk-150000-200000);
if kapindk_trin3>=0 then kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
negkap_kunprop=kapindk_trin1+kapindk_trin2+kapindk_trin3;
if negkap_kunprop<kapindk then negkap_kunprop=kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
negkap_prog=kapindk-negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=0 and kapindk=>0 then negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 85000 kr. (1989-sats) */
h_kapindk_trin2=-85000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if kapindk<0 and c_kapindk<0 then negkap_prog=(h_kapindk-h_negkap_kunprop)*(kapindk/h_kapindk);
if kapindk<0 and c_kapindk=>0 then negkap_prog=h_kapindk-h_negkap_kunprop;
if kapindk=>0 and c_kapindk<0 then negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=1 and h_kapindk=>0 then negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 110000 kr. (1989-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst mindre end lig 110000 kr. */
if kapindk<=110000 then kapindk_12=0; 
/* med kapitalindkomst over 110000 kr. */
if kapindk>110000 then kapindk_12=kapindk-110000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 110000 kr. i husholdning */
if h_kapindk>110000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-110000)*(kapindk/h_kapindk);
if h_kapindk>110000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>110000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-110000;

/* med kapitalindkomst under eller lig med 110000 kr. i husholdning */
if h_kapindk<=110000 then kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1989-ordning: 3/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 60000 kr. omlægges, medmindre */
/* samlet fradrag er under 60000 kr. i hvilket tilfælde alt omlægges */

lignfrad_kunprop=3/6*lignfrad;
if lignfrad_kunprop<60000 then do;
if lignfrad=>60000 then lignfrad_kunprop=60000;
if lignfrad<60000 then lignfrad_prop=lignfrad;
end; 
lignfrad_prog=lignfrad-lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3500 kr. (1989-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6+negkap_prog-lignfrad_prog-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12+negkap_prog-lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if c_gift=0 and c_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
c_kapindk_trin1=0; 
if c_kapindk<=-150000 then c_kapindk_trin1=c_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 85000 kr. (1989-sats) */
c_kapindk_trin2=-85000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if c_kapindk>=-150000 then c_kapindk_trin3=-0.25*(c_persindk+c_kapindk-200000);
if c_kapindk<-150000 then c_kapindk_trin3=-0.25*(c_persindk-150000-200000);
if c_kapindk_trin3>=0 then c_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
c_negkap_kunprop=c_kapindk_trin1+c_kapindk_trin2+c_kapindk_trin3;
if c_negkap_kunprop<c_kapindk then c_negkap_kunprop=c_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
c_negkap_prog=c_kapindk-c_negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=0 and c_kapindk=>0 then c_negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if c_gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 85000 kr. (1989-sats) */
h_kapindk_trin2=-85000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if c_kapindk<0 and kapindk<0 then c_negkap_prog=(h_kapindk-h_negkap_kunprop)*(c_kapindk/h_kapindk);
if c_kapindk<0 and kapindk=>0 then c_negkap_prog=h_kapindk-h_negkap_kunprop;
if c_kapindk=>0 and kapindk<0 then c_negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=1 and h_kapindk=>0 then c_negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 110000 kr. (1989-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst mindre end lig 110000 kr. */
if c_kapindk<=110000 then c_kapindk_12=0; 
/* med kapitalindkomst over 110000 kr. */
if c_kapindk>110000 then c_kapindk_12=c_kapindk-110000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 110000 kr. i husholdning */
if h_kapindk>110000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-110000)*(c_kapindk/h_kapindk);
if h_kapindk>110000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>110000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-110000;

/* med kapitalindkomst under eller lig med 110000 kr. i husholdning */
if h_kapindk<=110000 then c_kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1989-ordning: 3/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 60000 kr. omlægges, medmindre */
/* samlet fradrag er under 60000 kr. i hvilket tilfælde alt omlægges */

c_lignfrad_kunprop=3/6*c_lignfrad;
if c_lignfrad_kunprop<60000 then do;
if c_lignfrad=>60000 then c_lignfrad_kunprop=60000;
if c_lignfrad<60000 then c_lignfrad_prop=c_lignfrad;
end; 
c_lignfrad_prog=c_lignfrad-c_lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3500 kr. (1989-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6+c_negkap_prog-c_lignfrad_prog-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12+c_negkap_prog-c_lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* 12%-skat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* 12%-skat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;


%end;
%mend skat;
%skat;

data bif.skat1989_indkomst1986;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy in=a)   
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;
tau_akt_h=tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;
c_tau_akt_h=c_tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;



/********************************/
/* MECHANICAL CHANGES 1987-1990 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1987(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1987(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1987(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1987 (keep=pnr hffsp in=d)
       	lign.indk_lign1987(in=e)
		indk2.indkomst1987(in=f)
		indk2.ex_indk1987(in=g)
		fain.fain1989(keep=pnr kom in=h)
		sskat.skat_indk1987(keep=pnr samskat in=k);
  kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1990;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1990/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1990));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1987_1990=1));
year=1990;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip qovskejd qsocyd
 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       	   qlontmp2=c_qlontmp2
		   qsocyd=c_qsocyd
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if gift=0 and kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
kapindk_trin1=0; 
if kapindk<=-150000 then kapindk_trin1=kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 110000 kr. (1990-sats) */
kapindk_trin2=-110000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if kapindk>=-150000 then kapindk_trin3=-0.25*(persindk+kapindk-200000);
if kapindk<-150000 then kapindk_trin3=-0.25*(persindk-150000-200000);
if kapindk_trin3>=0 then kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
negkap_kunprop=kapindk_trin1+kapindk_trin2+kapindk_trin3;
if negkap_kunprop<kapindk then negkap_kunprop=kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
negkap_prog=kapindk-negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=0 and kapindk=>0 then negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 110000 kr. (1990-sats) */
h_kapindk_trin2=-110000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if kapindk<0 and c_kapindk<0 then negkap_prog=(h_kapindk-h_negkap_kunprop)*(kapindk/h_kapindk);
if kapindk<0 and c_kapindk=>0 then negkap_prog=h_kapindk-h_negkap_kunprop;
if kapindk=>0 and c_kapindk<0 then negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if gift=1 and h_kapindk=>0 then negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 135000 kr. (1990-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst mindre end lig 135000 kr. */
if kapindk<=135000 then kapindk_12=0; 
/* med kapitalindkomst over 135000 kr. */
if kapindk>135000 then kapindk_12=kapindk-135000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 135000 kr. i husholdning */
if h_kapindk>135000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-135000)*(kapindk/h_kapindk);
if h_kapindk>135000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>135000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-135000;

/* med kapitalindkomst under eller lig med 135000 kr. i husholdning */
if h_kapindk<=135000 then kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1990-ordning: 4/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 80000 kr. omlægges, medmindre */
/* samlet fradrag er under 80000 kr. i hvilket tilfælde alt omlægges */

lignfrad_kunprop=4/6*lignfrad;
if lignfrad_kunprop<80000 then do;
if lignfrad=>80000 then lignfrad_kunprop=80000;
if lignfrad<80000 then lignfrad_prop=lignfrad;
end; 
lignfrad_prog=lignfrad-lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3600 kr. (1990-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6+negkap_prog-lignfrad_prog-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12+negkap_prog-lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*************************************************************************/
/* Gradvis omlægning af negative kapitalindkomster til kun at indgå i    */
/* grundlagene for proportional beskatning. En tre-trins ordning         */
/* ifølge hvilken kapitalindkomst tages ud af de progressive skattebaser */
/*************************************************************************/
/* For ugifte */
/* Hvis negativ kapitalindkomst */
if c_gift=0 and c_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
c_kapindk_trin1=0; 
if c_kapindk<=-150000 then c_kapindk_trin1=c_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 110000 kr. (1990-sats) */
c_kapindk_trin2=-110000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if c_kapindk>=-150000 then c_kapindk_trin3=-0.25*(c_persindk+c_kapindk-200000);
if c_kapindk<-150000 then c_kapindk_trin3=-0.25*(c_persindk-150000-200000);
if c_kapindk_trin3>=0 then c_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
c_negkap_kunprop=c_kapindk_trin1+c_kapindk_trin2+c_kapindk_trin3;
if c_negkap_kunprop<c_kapindk then c_negkap_kunprop=c_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
c_negkap_prog=c_kapindk-c_negkap_kunprop;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=0 and c_kapindk=>0 then c_negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ kapitalindkomst */
if c_gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ kapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ kapitalindkomst under 150000 kr. omlægges 110000 kr. (1990-sats) */
h_kapindk_trin2=-110000;

/* Trin 3: Af negativ kapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst - kapitalindkomst (op til 150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ kapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative kapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ kapitalindkomst til progrssiv beskatning efter omlægning */
if c_kapindk<0 and kapindk<0 then c_negkap_prog=(h_kapindk-h_negkap_kunprop)*(c_kapindk/h_kapindk);
if c_kapindk<0 and kapindk=>0 then c_negkap_prog=h_kapindk-h_negkap_kunprop;
if c_kapindk=>0 and kapindk<0 then c_negkap_prog=0;
end;

/* Hvis ikke negativ kapitalindkomst */
if c_gift=1 and h_kapindk=>0 then c_negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 135000 kr. (1990-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst mindre end lig 135000 kr. */
if c_kapindk<=135000 then c_kapindk_12=0; 
/* med kapitalindkomst over 135000 kr. */
if c_kapindk>135000 then c_kapindk_12=c_kapindk-135000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 135000 kr. i husholdning */
if h_kapindk>135000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-135000)*(c_kapindk/h_kapindk);
if h_kapindk>135000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>135000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-135000;

/* med kapitalindkomst under eller lig med 135000 kr. i husholdning */
if h_kapindk<=135000 then c_kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1990-ordning: 4/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 80000 kr. omlægges, medmindre */
/* samlet fradrag er under 80000 kr. i hvilket tilfælde alt omlægges */

c_lignfrad_kunprop=4/6*c_lignfrad;
if c_lignfrad_kunprop<80000 then do;
if c_lignfrad=>80000 then c_lignfrad_kunprop=80000;
if c_lignfrad<80000 then c_lignfrad_prop=c_lignfrad;
end; 
c_lignfrad_prog=c_lignfrad-c_lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3600 kr. (1990-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6+c_negkap_prog-c_lignfrad_prog-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12+c_negkap_prog-c_lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* 12%-skat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* 12%-skat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;



%end;
%mend skat;
%skat;

data bif.skat1990_indkomst1987;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;
tau_akt_h=tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;
c_tau_akt_h=c_tau_kap_h;
/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1988-1991 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1988(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1988(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1988(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1988 (keep=pnr hffsp in=d)
       	lign.indk_lign1988(in=e)
		indk2.indkomst1988(in=f)
		indk2.ex_indk1988(in=g)
		fain.fain1990(keep=pnr kom in=h)
		sskat.skat_indk1988(keep=pnr samskat in=k);
  kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1991;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1991/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1991));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1988_1991=1));
year=1991;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip qovskejd qsocyd
 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       	   qlontmp2=c_qlontmp2
		   qsocyd=c_qsocyd
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;
/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/********************************************************************************/
/* Gradvis omlægning af negative nettokapitalindkomster til kun at indgå i      */
/* grundlagene for proportional beskatning. En tre-trins ordning ifølge         */
/* hvilken negative nettokapitalindkomst tages ud af de progressive skattebaser */
/********************************************************************************/
/* For ugifte */
/* Hvis negativ nettokapitalindkomst */
if gift=0 and kapindk<0 then do;

/* Trin 1: Al negativ nettokapitalindkomst ud over 150000 kr. omlægges */
kapindk_trin1=0; 
if kapindk<=-150000 then kapindk_trin1=kapindk+150000;

/* Trin 2: Af negativ nettokapitalindkomst under 150000 kr. omlægges 130000 kr. (1991-sats) */
kapindk_trin2=-130000;

/* Trin 3: Af negativ nettokapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst + nettokapitalindkomst (ned til - 150000 kr.) - 200000 kr.) */ 
if kapindk>=-150000 then kapindk_trin3=-0.25*(persindk+kapindk-200000);
if kapindk<-150000 then kapindk_trin3=-0.25*(persindk-150000-200000);
if kapindk_trin3>=0 then kapindk_trin3=0;

/* Samlet negativ nettokapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative nettokapitalindkomst) */
negkap_kunprop=kapindk_trin1+kapindk_trin2+kapindk_trin3;
if negkap_kunprop<kapindk then negkap_kunprop=kapindk; 

/* Negativ nettokapitalindkomst til progrssiv beskatning efter omlægning */
negkap_prog=kapindk-negkap_kunprop;
end;

/* Hvis ikke negativ nettokapitalindkomst */
if gift=0 and kapindk=>0 then negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige */
/* hvis negativ nettokapitalindkomst */
if gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ nettokapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ nettokapitalindkomst under 150000 kr. omlægges 130000 kr. (1991-sats) */
h_kapindk_trin2=-130000;

/* Trin 3: Af negativ nettokapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst + nettokapitalindkomst (ned til -150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ nettokapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative nettokapitalindkomst */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ nettokapitalindkomst til progrssiv beskatning efter omlægning */
if kapindk<0 and c_kapindk<0 then negkap_prog=(h_kapindk-h_negkap_kunprop)*(kapindk/h_kapindk);
if kapindk<0 and c_kapindk=>0 then negkap_prog=h_kapindk-h_negkap_kunprop;
if kapindk=>0 and c_kapindk<0 then negkap_prog=0;
end;

/* Hvis ikke negativ nettokapitalindkomst */
if gift=1 and h_kapindk=>0 then negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 160000 kr. (1991-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst mindre end eller lig 160000 kr. */
if kapindk<=160000 then kapindk_12=0; 
/* med kapitalindkomst over 160000 kr. */
if kapindk>160000 then kapindk_12=kapindk-160000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;

/* med kapitalindkomst mindre end eller lig med 160000 kr. i husholdning */
if h_kapindk<=160000 then kapindk_12=0; 

/* med kapitalindkomst over 160000 kr. i husholdning */
if h_kapindk>160000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-160000)*(kapindk/h_kapindk);
if h_kapindk>160000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>160000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-160000;

end;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1991-ordning: 5/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 100000 kr. omlægges, medmindre */
/* samlet fradrag er under 100000 kr. i hvilket tilfælde alt omlægges */

lignfrad_kunprop=5/6*lignfrad;
if lignfrad_kunprop<100000 then do;
if lignfrad=>100000 then lignfrad_kunprop=100000;
if lignfrad<100000 then lignfrad_prop=lignfrad;
end; 
lignfrad_prog=lignfrad-lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3700 kr. (1991-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;
/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6+negkap_prog-lignfrad_prog-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12+negkap_prog-lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*******************************************************************************/
/* Gradvis omlægning af negative nettokapitalindkomster til kun at indgå i     */
/* grundlagene for proportional beskatning. En tre-trins ordning ifølge        */ 
/* hvilken negativ nettokapitalindkomst tages ud af de progressive skattebaser */
/*******************************************************************************/
/* For ugifte */
/* Hvis negativ nettokapitalindkomst */
if c_gift=0 and c_kapindk<0 then do;

/* Trin 1: Al negativ nettokapitalindkomst ud over 150000 kr. omlægges */
c_kapindk_trin1=0; 
if c_kapindk<=-150000 then c_kapindk_trin1=c_kapindk+150000;

/* Trin 2: Af negativ nettokapitalindkomst under 150000 kr. omlægges 130000 kr. (1991-sats) */
c_kapindk_trin2=-130000;

/* Trin 3: Af negativ nettokapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst + nettokapitalindkomst (ned til -150000 kr.) - 200000 kr.) */ 
if c_kapindk>=-150000 then c_kapindk_trin3=-0.25*(c_persindk+c_kapindk-200000);
if c_kapindk<-150000 then c_kapindk_trin3=-0.25*(c_persindk-150000-200000);
if c_kapindk_trin3>=0 then c_kapindk_trin3=0;

/* Samlet negativ nettokapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative nettokapitalindkomst */
c_negkap_kunprop=c_kapindk_trin1+c_kapindk_trin2+c_kapindk_trin3;
if c_negkap_kunprop<c_kapindk then c_negkap_kunprop=c_kapindk; 

/* Negativ nettokapitalindkomst til progrssiv beskatning efter omlægning */
c_negkap_prog=c_kapindk-c_negkap_kunprop;
end;

/* Hvis ikke negativ nettokapitalindkomst */
if c_gift=0 and c_kapindk=>0 then c_negkap_prog=0;

/* For gifte */
/* For ægtepar opgøres nettokapitalindkomsten under ét, og der gælder samme */
/* beløbsgrænser for ægtefæller som for enlige                              */
/* hvis negativ nettokapitalindkomst */
if c_gift=1 and h_kapindk<0 then do;

/* Trin 1: Al negativ nettokapitalindkomst ud over 150000 kr. omlægges */
h_kapindk_trin1=0;
if h_kapindk<=-150000 then h_kapindk_trin1=h_kapindk+150000;

/* Trin 2: Af negativ nettokapitalindkomst under 150000 kr. omlægges 130000 kr. (1991-sats) */
h_kapindk_trin2=-130000;

/* Trin 3: Af negativ nettokapitalindkomst under 150000 kr. omlægges 25% af     */
/* (personlig indkomst + nettokapitalindkomst (ned til -150000 kr.) - 200000 kr.) */ 
if h_kapindk>=-150000 then h_kapindk_trin3=-0.25*(h_persindk+h_kapindk-200000);
if h_kapindk<-150000 then h_kapindk_trin3=-0.25*(h_persindk-150000-200000);
if h_kapindk_trin3>=0 then h_kapindk_trin3=0;

/* Samlet negativ nettokapitalindkomst som omlægges, dvs. tages ud af de progressive skattebaser */
/* Beløbet kan maksimalt udgøre den faktiske negative nettokapitalindkomst) */
h_negkap_kunprop=h_kapindk_trin1+h_kapindk_trin2+h_kapindk_trin3;
if h_negkap_kunprop<h_kapindk then h_negkap_kunprop=h_kapindk; 

/* Negativ nettokapitalindkomst til progrssiv beskatning efter omlægning */
if c_kapindk<0 and kapindk<0 then c_negkap_prog=(h_kapindk-h_negkap_kunprop)*(c_kapindk/h_kapindk);
if c_kapindk<0 and kapindk=>0 then c_negkap_prog=h_kapindk-h_negkap_kunprop;
if c_kapindk=>0 and kapindk<0 then c_negkap_prog=0;
end;

/* Hvis ikke nettonegativ nettokapitalindkomst */
if c_gift=1 and h_kapindk=>0 then c_negkap_prog=0;
 
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 160000 kr. (1991-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst mindre end eller lig med 160000 kr. */
if c_kapindk<=160000 then c_kapindk_12=0; 
/* med kapitalindkomst over 160000 kr. */
if c_kapindk>160000 then c_kapindk_12=c_kapindk-160000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;

/* med kapitalindkomst mindre end eller lig med 160000 kr. i husholdning */
if h_kapindk<=160000 then c_kapindk_12=0; 
end;

/* med kapitalindkomst over 160000 kr. i husholdning */
if h_kapindk>160000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-160000)*(c_kapindk/h_kapindk);
if h_kapindk>160000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>160000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-160000;

/****************************************************/
/* Ordning for omlægning af ligningsmæssige fradrag */ 
/****************************************************/
/* Progressiv beskatning */
/* 1991-ordning: 5/6 af fradrag omlægges til alene at indgå i grundlaget for */
/* proportional beskatning. Dog skal mindst 100000 kr. omlægges, medmindre */
/* samlet fradrag er under 100000 kr. i hvilket tilfælde alt omlægges */

c_lignfrad_kunprop=5/6*c_lignfrad;
if c_lignfrad_kunprop<100000 then do;
if c_lignfrad=>100000 then c_lignfrad_kunprop=100000;
if c_lignfrad<100000 then c_lignfrad_prop=c_lignfrad;
end; 
c_lignfrad_prog=c_lignfrad-c_lignfrad_kunprop; 

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3700 kr. (1991-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6+c_negkap_prog-c_lignfrad_prog-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12+c_negkap_prog-c_lignfrad_prog-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* 12%-skat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* 12%-skat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;


%end;
%mend skat;
%skat;

data bif.skat1991_indkomst1988;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy
tau_akt_h c_tau_akt_h aktind c_aktind in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;




/********************************/
/* MECHANICAL CHANGES 1989-1992 */
/********************************/
/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1989(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1989(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1989(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1989 (keep=pnr hffsp in=d)
       	lign.indk_lign1989(in=e)
		indk2.indkomst1989(in=f)
		indk2.ex_indk1989(in=g)
		fain.fain1991(keep=pnr kom in=h)
		sskat.skat_indk1989(keep=pnr samskat in=k);
  kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1992;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1992/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1992));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1989_1992=1));
year=1992;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip qovskejd qsocyd
 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       	   qlontmp2=c_qlontmp2
		   qsocyd=c_qsocyd
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;
/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 185000 kr. (1992-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst under eller lig med 185000 kr. i husholdning */
if kapindk<=185000 then kapindk_12=0; 
/* med kapitalindkomst over 185000 kr. i husholdning */
if kapindk>185000 then kapindk_12=kapindk-185000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 185000 kr. i husholdning */
if h_kapindk>185000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-185000)*(kapindk/h_kapindk);
if h_kapindk>185000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>185000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-185000;

/* med kapitalindkomst under eller lig med 185000 kr. i husholdning */
if h_kapindk<=185000 then kapindk_12=0; 
end;

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3800 kr. (1992-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;
/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 185000 kr. (1992-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst under eller lig med 185000 kr. i husholdning */
if c_kapindk<=185000 then c_kapindk_12=0; 
/* med kapitalindkomst over 185000 kr. i husholdning */
if c_kapindk>185000 then c_kapindk_12=c_kapindk-185000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 185000 kr. i husholdning */
if h_kapindk>185000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-185000)*(c_kapindk/h_kapindk);
if h_kapindk>185000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>185000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-185000;

/* med kapitalindkomst under eller lig med 185000 kr. i husholdning */
if h_kapindk<=185000 then c_kapindk_12=0; 
end;

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3800 kr. (1992-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;

run;


%end;
%mend skat;
%skat;

data bif.skat1992_indkomst1989;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1990-1993 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1990(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1990(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1990(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1990 (keep=pnr hffsp in=d)
       	lign.indk_lign1990(in=e)
		indk2.indkomst1990(in=f)
		indk2.ex_indk1990(in=g)
		fain.fain1992(keep=pnr kom in=h)
		sskat.skat_indk1990(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1993;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1993/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser;
 set skat.skattesatser1984_2005(where=(year=1993));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1990_1993=1));
year=1993;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=sskat1; /* 22%-skat */
	mtax=sskat2; /* 6%-skat */
	ttax=sskat3; /* 12%-skat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip qovskejd qsocyd
 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       	   qlontmp2=c_qlontmp2
		   qsocyd=c_qsocyd
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_qsocyd=. then c_qsocyd=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk;

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2)*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk;

/* Nettokapitalindkomst */
c_Kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;

/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_6=0; 
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_6=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_6=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_6=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 210000 kr. (1993-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med kapitalindkomst under eller lig med 210000 kr. i husholdning */
if kapindk<=210000 then kapindk_12=0; 
/* med kapitalindkomst over 210000 kr. i husholdning */
if kapindk>210000 then kapindk_12=kapindk-210000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 210000 kr. i husholdning */
if h_kapindk>210000 and c_kapindk>0 and kapindk>0 
then kapindk_12=(h_kapindk-210000)*(kapindk/h_kapindk);
if h_kapindk>210000 and c_kapindk>0 and kapindk<=0 then kapindk_12=0;
if h_kapindk>210000 and c_kapindk<=0 and kapindk>0 then kapindk_12=h_kapindk-210000;

/* med kapitalindkomst under eller lig med 210000 kr. i husholdning */
if h_kapindk<=210000 then kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3900 kr. (1993-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
stfradrag=persindk*trefradrag;
if stfradrag>trebeloeb then stfradrag=trebeloeb;
/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
bundinc=persindk+kapindk-lignfrad-stfradrag-bfradrag2;

/* 6%-skatten */
melleminc=persindk+kapindk_6-bfradrag3;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* 12%-skatten */
topinc=persindk+kapindk_12-bfradrag4;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-stfradrag-bfradrag1;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/****************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af 6%-skat */            
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_6=0; 
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_6=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_6=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_6=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_6=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_6=0; 
end;

/*********************************************************************************************/ 
/* Positiv kapitalindkomst over 210000 kr. (1993-sats), som bruges til beregning af 12%-skat */
/*********************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med kapitalindkomst under eller lig med 210000 kr. i husholdning */
if c_kapindk<=210000 then c_kapindk_12=0; 
/* med kapitalindkomst over 210000 kr. i husholdning */
if c_kapindk>210000 then c_kapindk_12=c_kapindk-210000;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
/* Ægtefæller har samme beløbsgrænse som enlige */
if gift=1 then do;
/* med kapitalindkomst over 210000 kr. i husholdning */
if h_kapindk>210000 and kapindk>0 and c_kapindk>0 
then c_kapindk_12=(h_kapindk-210000)*(c_kapindk/h_kapindk);
if h_kapindk>210000 and kapindk>0 and c_kapindk<=0 then c_kapindk_12=0;
if h_kapindk>210000 and kapindk<=0 and c_kapindk>0 then c_kapindk_12=h_kapindk-210000;

/* med kapitalindkomst under eller lig med 210000 kr. i husholdning */
if h_kapindk<=210000 then c_kapindk_12=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/**********************************************************************/
/* Standardfradrag: udgør 3% af den personlige indkomst, dog højest   */
/* 3900 kr. (1993-sats), som fratrækkes i den skattepligtige indkomst */
/**********************************************************************/
c_stfradrag=c_persindk*trefradrag;
if c_stfradrag>trebeloeb then c_stfradrag=trebeloeb;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i grundlaget for 6%-skatten */
/************************************************************************************/
/* 22%-skatten */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag2;

/* 6%-skatten */
c_melleminc=c_persindk+c_kapindk_6-bfradrag3;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* 12%-skatten */
c_topinc=c_persindk+c_kapindk_12-bfradrag4;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-c_stfradrag-bfradrag1;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* 22%-skat */
bundt=(bundinc>0)*bundinc*ltax;

/* 6%-skat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
komt=(kominc>0)*kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* 22%-skat */
c_bundt=(c_bundinc>0)*c_bundinc*ltax;

/* 6%-skat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_komt=(c_kominc>0)*c_kominc*ktax;

/*Beregner samlet skattebetaling før vandret skatteloft */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;



%end;
%mend skat;
%skat;

data bif.skat1993_indkomst1990;
merge new1 (keep=pnr tax1 c_tax1 gift
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h 
aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;



/********************************/
/* MECHANICAL CHANGES 1991-1994 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1991(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1991(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1991(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1991 (keep=pnr hffsp in=d)
       	lign.indk_lign1991(in=e)
		indk2.indkomst1991(in=f)
		indk2.ex_indk1991(in=g)
		fain.fain1993(keep=pnr kom in=h)
		sskat.skat_indk1991(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1994;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1994/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat sskat2 fskat1 topskat sloft bfradrag1 vloft bfradrag3
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=1994));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1991_1994=1));
year=1994;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    atax=sskat2; /* Almindelig indkomstskat */
	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+atax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip invudl qovskejd
 ceiling1 ktax ltax mtax ttax atax underhol qsocyd);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       atax=c_atax
	   qsocyd=c_qsocyd
       underhol=c_underhol
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   invudl=c_invudl
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	  
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_atax=. then c_atax=0;
if c_qsocyd=. then c_qsocyd=0;
if c_qlontmp2=. then c_qlontmp2=0;
if c_underhol=. then c_underhol=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_invudl=. then c_invudl=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;

/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */            
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
kapindk_m=kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20000 kr. (1994-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>20000 then kapindk_top=kapindk-20000;
if kapindk<=20000 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk>c_persindk then do;
if h_kapindk>40000 then kapindk_top=h_kapindk-40000;
if h_kapindk<=40000 then kapindk_top=0;
end;

if gift=1 and persindk<c_persindk then kapindk_top=0;

/* Hvis samme personlig indkomst, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk=c_persindk then do;
if h_kapindk>40000 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk-40000;
if h_kapindk>40000 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=40000 then kapindk_top=0;
end;

/***************************************************************************************/
/* Værdien af underholdsbidrag over 40000 kr. (1994) fratrækkes i mellemskattegrundlag */
/***************************************************************************************/
if underhol<=40000 then underhol_m=0;
if underhol>40000 then underhol_m=underhol-40000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/***********************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund-, mellem og statsskattegrundlag */
/***********************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk-lignfrad-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-underhol_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* Almindelig indkomstskat */
alminc=persindk-bfradrag3;
alminc_neg=0;
if gift=1 then alminc_neg=(alminc<0)*alminc;

/* topindkomst */
topinc=persindk+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
c_kapindk_m=c_kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20000 kr. (1994-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>20000 then c_kapindk_top=c_kapindk-20000;
if c_kapindk<=20000 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if c_gift=1 and c_persindk>persindk then do;
if h_kapindk>40000 then c_kapindk_top=h_kapindk-40000;
if h_kapindk<=40000 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk<persindk then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk=persindk then do;
if h_kapindk>40000 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk-40000;
if h_kapindk>40000 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=40000 then c_kapindk_top=0;
end;


/***************************************************************************************/
/* Værdien af underholdsbidrag over 80000 kr. (1994) fratrækkes i mellemskattegrundlag */
/***************************************************************************************/
if c_underhol<=40000 then c_underhol_m=0;
if c_underhol>40000 then c_underhol_m=c_underhol-40000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/***********************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund-, mellem og statsskattegrundlag */
/***********************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-c_underhol_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* Almindelig indkomstskat */
c_alminc=c_persindk-bfradrag3;
c_alminc_neg=0;
if c_gift=1 then c_alminc_neg=(c_alminc<0)*c_alminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Almindelig indkomstskat */
nyalminc=alminc+c_alminc_neg;
almt=(nyalminc>0)*nyalminc*atax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+almt+topt+ambt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
midt=mellemt+almt;
if midt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Almindelig indkomstskat */
c_nyalminc=c_alminc+alminc_neg;
c_almt=(c_nyalminc>0)*c_nyalminc*c_atax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax1=c_komt+c_bundt+c_mellemt+c_almt+c_topt+c_ambt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;

run;


%end;
%mend skat;
%skat;

data bif.skat1994_indkomst1991;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h
bundt mellemt almt topt komt ambt deduct in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1992-1995 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1992(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1992(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1992(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1992 (keep=pnr hffsp in=d)
       	lign.indk_lign1992(in=e)
		indk2.indkomst1992(in=f)
		indk2.ex_indk1992(in=g)
		fain.fain1994(keep=pnr kom in=h)
		sskat.skat_indk1992(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1995;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1995/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat sskat2 topskat sloft bfradrag1 vloft bfradrag3 fskat1
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=1995));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1992_1995=1));
year=1995;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    atax=sskat2; /* Almindelig indkomstskat */
	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+atax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip invudl qovskejd
 ceiling1 ktax ltax mtax ttax atax underhol qsocyd);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       atax=c_atax
	   qsocyd=c_qsocyd
       underhol=c_underhol
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   invudl=c_invudl
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	  
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_atax=. then c_atax=0;
if c_qsocyd=. then c_qsocyd=0;
if c_qlontmp2=. then c_qlontmp2=0;
if c_underhol=. then c_underhol=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_invudl=. then c_invudl=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_Kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;

/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

h_aktind=aktind+c_aktind;


/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */            
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
kapindk_m=kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20200 kr. (1995-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>20200 then kapindk_top=kapindk-20200;
if kapindk<=20200 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if gift=1 and persindk>c_persindk then do;
if h_kapindk>40400 then kapindk_top=h_kapindk-40400;
if h_kapindk<=40400 then kapindk_top=0;
end;

if gift=1 and persindk<c_persindk then kapindk_top=0;

/* Hvis samme personlig indkomst, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk=c_persindk then do;
if h_kapindk>40400 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk-40400;
if h_kapindk>40400 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=40400 then kapindk_top=0;
end;

/***************************************************************************************/
/* Værdien af underholdsbidrag over 80000 kr. (1995) fratrækkes i mellemskattegrundlag */
/***************************************************************************************/
if underhol<=80000 then underhol_m=0;
if underhol>80000 then underhol_m=underhol-80000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/***********************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund-, mellem og statsskattegrundlag */
/***********************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk-lignfrad-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-underhol_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* Almindelig indkomstskat - tidligere 6%-skat */
alminc=persindk-bfradrag3;
c_alminc_neg=0;
if c_gift=1 then alminc_neg=(alminc<0)*alminc;

/* topindkomst */
topinc=persindk+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;

/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/***********************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */
/***********************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
c_kapindk_m=c_kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20200 kr. (1995-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>20200 then c_kapindk_top=c_kapindk-20200;
if c_kapindk<=20200 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if c_gift=1 and c_persindk>persindk then do;
if h_kapindk>40400 then c_kapindk_top=h_kapindk-40400;
if h_kapindk<=40400 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk<persindk then c_kapindk_top=0;

/* Hvis samme personlig indkomst, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk=persindk then do;
if h_kapindk>40400 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk-40400;
if h_kapindk>40400 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=40400 then c_kapindk_top=0;
end;


/***************************************************************************************/
/* Værdien af underholdsbidrag over 80000 kr. (1995) fratrækkes i mellemskattegrundlag */
/***************************************************************************************/
if c_underhol<=80000 then c_underhol_m=0;
if c_underhol>80000 then c_underhol_m=c_underhol-80000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/***********************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund-, mellem og statsskattegrundlag */
/***********************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-c_underhol_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* Almindelig indkomstskat */
c_alminc=c_persindk-bfradrag3;
c_alminc_neg=0;
if c_gift=1 then c_alminc_neg=(c_alminc<0)*c_alminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Almindelig indkomstskat */
nyalminc=alminc+c_alminc_neg;
almt=(nyalminc>0)*nyalminc*atax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+almt+topt+ambt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
midt=mellemt+almt;
if midt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;


/* Almindelig indkomstskat - tidligere 6%-skat */
c_nyalminc=c_alminc+alminc_neg;
c_almt=(c_nyalminc>0)*c_nyalminc*c_atax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax1=c_komt+c_bundt+c_mellemt+c_almt+c_topt+c_ambt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;


run;


%end;
%mend skat;
%skat;
data bif.skat1995_indkomst1992;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;

/********************************/
/* MECHANICAL CHANGES 1993-1996 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1993(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1993(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1993(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1993 (keep=pnr hffsp in=d)
       	lign.indk_lign1993(in=e)
		indk2.indkomst1993(in=f)
		indk2.ex_indk1993(in=g)
		fain.fain1995(keep=pnr kom in=h)
		sskat.skat_indk1993(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1996;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1996/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 vloft fskat1
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=1996));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1993_1996=1));
year=1996;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
   	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip invudl qovskejd
 ceiling1 ktax ltax mtax ttax underhol qsocyd);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
       qsocyd=c_qsocyd
       underhol=c_underhol
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   invudl=c_invudl
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	  
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qsocyd=. then c_qsocyd=0;
if c_qlontmp2=. then c_qlontmp2=0;
if c_underhol=. then c_underhol=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_invudl=. then c_invudl=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_Kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;

/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */            
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
kapindk_m=kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20700 kr. (1996-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>20700 then kapindk_top=kapindk-20700;
if kapindk<=20700 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if gift=1 and persindk>c_persindk then do;
if h_kapindk>41400 then kapindk_top=h_kapindk-41400;
if h_kapindk<=41400 then kapindk_top=0;
end;

if gift=1 and persindk<c_persindk then kapindk_top=0;

/* Hvis samme personlig indkomst, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk=c_persindk then do;
if h_kapindk>41400 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk-41400;
if h_kapindk>41400 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=41400 then kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk-lignfrad-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
c_kapindk_m=c_kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20700 kr. (1996-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>20700 then c_kapindk_top=c_kapindk-20700;
if c_kapindk<=20700 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt maSkattebaser førn er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if c_gift=1 and c_persindk>persindk then do;
if h_kapindk>41400 then c_kapindk_top=h_kapindk-41400;
if h_kapindk<=41400 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk<persindk then c_kapindk_top=0;

/* Hvis samme personlig indkomst, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk=persindk then do;
if h_kapindk>41400 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk-41400;
if h_kapindk>41400 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=41400 then c_kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/*  overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_bundinc_neg=0;
if c_gift=0 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=0 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling før vandret skatteloft */
tax1=komt+bundt+mellemt+topt+ambt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if gift=0 then do;
if formue>ffradrag1 then wtax=fskat1*(formue-ffradrag1);
if formue<=ffradrag1 then wtax=0;
end;
/* for gifte */
if gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
sharew=0;
if formue>0 and c_formue>0 then sharew=formue/h_formue;
if formue>0 and c_formue<=0 then sharew=1;
if formue<=0 and c_formue>0 then sharew=0;
/* Beregner herefter den enkeltes formueskat */
wtax=sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
skatindk=persindk+kapindk-lignfrad;
deduct=tax1+wtax-(vloft*skatindk);
if deduct<=0 then deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
tax&i=tax1-deduct;
if tax&i<0 then tax&i=0;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax1=c_komt+c_bundt+c_mellemt+c_topt+c_ambt;

/* Evt. nedslag i skattebetaling sfa. vandret skatteloft: Hvis den samlede indkomst- og */
/* formueskat er højere end det vandrette skatteloft x skattepligtig indkomst, nedsættes */
/* indkomstskatten med det overskydende beløb */

/* Formueskat */
/* For ugifte */
if c_gift=0 then do;
if c_formue>ffradrag1 then c_wtax=fskat1*(c_formue-ffradrag1);
if c_formue<=ffradrag1 then c_wtax=0;
end;
/* for gifte */
if c_gift=1 then do;
/* Beregner først husholdningens samlede formueskat */
if h_formue>ffradrag2*2 then h_wtax=fskat1*(h_formue-(ffradrag2*2));
if h_formue<=ffradrag2*2 then h_wtax=0;
/* Beregner dernæst andelen af formueskatten, som beskattes hos den enkelte ægtefælle */
c_sharew=0;
if c_formue>0 and formue>0 then c_sharew=c_formue/h_formue;
if c_formue>0 and formue<=0 then c_sharew=1;
if c_formue<=0 and formue>0 then c_sharew=0;
/* Beregner herefter den enkeltes formueskat */
c_wtax=c_sharew*h_wtax;
end;

/* Nu beregnes evt. nedslag */
c_skatindk=c_persindk+c_kapindk-c_lignfrad;
c_deduct=c_tax1+c_wtax-(vloft*c_skatindk);
if c_deduct<=0 then c_deduct=0; 
/* Endelige indkomstskatter med evt. nedslag sfa. det vandrette skatteloft */
c_tax&i=c_tax1-c_deduct;
if c_tax&i<0 then c_tax&i=0;

run;


%end;
%mend skat;
%skat;

data bif.skat1996_indkomst1993;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
             qsocyd c_qsocyd bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
+qsocyd-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd+c_arbindk+c_apersindk+c_kapindk-c_lignfrad+c_qsocyd-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+qsocyd
+c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
+c_qsocyd
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;

/********************************/
/* MECHANICAL CHANGES 1994-1997 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1994(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1994(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1994(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1994 (keep=pnr hffsp in=d)
       	lign.indk_lign1994(in=e)
		indk2.indkomst1994(in=f)
		indk2.ex_indk1994(in=g)
		fain.fain1996(keep=pnr kom in=h)
		sskat.skat_indk1994(keep=pnr samskat in=k);
kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1997;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1997/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=1997));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1994_1997=1));
year=1997;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip invudl qovskejd
 ceiling1 ktax ltax mtax ttax underhol);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift

       underhol=c_underhol
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   invudl=c_invudl
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	  
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_underhol=. then c_underhol=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_invudl=. then c_invudl=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;


%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;

/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */            
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
kapindk_m=kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 20800 kr. (1997-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>20800 then kapindk_top=kapindk-20800;
if kapindk<=20800 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if gift=1 and persindk>c_persindk then do;
if h_kapindk>41600 then kapindk_top=h_kapindk-41600;
if h_kapindk<=41600 then kapindk_top=0;
end;

if gift=1 and persindk<c_persindk then kapindk_top=0;

/* Hvis samme personlig indkomst, tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk=c_persindk then do;
if h_kapindk>41600 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk-41600;
if h_kapindk>41600 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=41600 then kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk-lignfrad-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
c_kapindk_m=c_kapindk;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>20800 then c_kapindk_top=c_kapindk-20800;
if c_kapindk<=20800 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if c_gift=1 and c_persindk>persindk then do;
if h_kapindk>41600 then c_kapindk_top=h_kapindk-41600;
if h_kapindk<=41600 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk<persindk then c_kapindk_top=0;

/* Hvis samme personlig indkomst, tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk=persindk then do;
if h_kapindk>41600 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk-41600;
if h_kapindk>41600 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=41600 then c_kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt;

run;

%end;
%mend skat;
%skat;

data bif.skat1997_indkomst1994;
merge new1 (keep=pnr tax1 c_tax1 gift
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1995-1998 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1995(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1995(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1995(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1995 (keep=pnr hffsp in=d)
       	lign.indk_lign1995(in=e)
		indk2.indkomst1995(in=f)
		indk2.ex_indk1995(in=g)
		fain.fain1997(keep=pnr kom in=h)
		sskat.skat_indk1995(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 year=1998;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1998/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=1998));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1995_1998=1));
year=1998;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip invudl qovskejd
 ceiling1 ktax ltax mtax ttax underhol);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift

       underhol=c_underhol
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   invudl=c_invudl
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	  
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_underhol=. then c_underhol=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_invudl=. then c_invudl=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;


/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */            
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
kapindk_m=kapindk;

/*******************************************************************************************/ 
/* Positiv kapitalindkomst over 21400 kr. (1998-sats), som bruges til beregning af topskat */
/*******************************************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>21400 then kapindk_top=kapindk-21400;
if kapindk<=21400 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if gift=1 and persindk>c_persindk then do;
if h_kapindk>42800 then kapindk_top=h_kapindk-42800;
if h_kapindk<=42800 then kapindk_top=0;
end;

if gift=1 and persindk<c_persindk then kapindk_top=0;

/* Hvis samme personlig indkomst, tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk=c_persindk then do;
if h_kapindk>42800 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk-42800;
if h_kapindk>42800 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=42800 then kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk-lignfrad-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*******************************************************************/
/* Kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* Ingen overførsel af kapitalindkomst mellem ægtefæller */
c_kapindk_m=c_kapindk;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>21400 then c_kapindk_top=c_kapindk-21400;
if c_kapindk<=21400 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst */
if c_gift=1 and c_persindk>persindk then do;
if h_kapindk>42800 then c_kapindk_top=h_kapindk-42800;
if h_kapindk<=42800 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk<persindk then c_kapindk_top=0;

/* Hvis samme personlig indkomst, tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk=persindk then do;
if h_kapindk>42800 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk-42800;
if h_kapindk>42800 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=42800 then c_kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt;


/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt;

run;


%end;
%mend skat;
%skat;

data bif.skat1998_indkomst1995;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a)  
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1996-1999 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1996(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1996(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1996(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1996 (keep=pnr hffsp in=d)
       	lign.indk_lign1996(in=e)
		indk2.indkomst1996(in=f)
		indk2.ex_indk1996(in=g)
		fain.fain1998(keep=pnr kom in=h)
		sskat.skat_indk1996(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=1999;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom1999/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=1999));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1996_1999=1));
year=1999;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 adagpag qovskejd
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
      qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   qovskejd=c_qovskejd
	   invudl=c_invudl
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	  
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_invudl=. then c_invudl=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;
/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*******************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_m=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_m=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_m=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_m=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_m=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_m=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk-lignfrad-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk_top+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*******************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_m=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_m=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_m=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_m=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_m=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_m=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk_top+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/* Beregner særlig pensionsopsparing */
spt=sp*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt+spt;


/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/* Beregner særlig pensionsopsparing */
c_spt=sp*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt+c_spt;

run;


%end;
%mend skat;
%skat;

data bif.skat1999_indkomst1996;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1997-2000 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1997(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1997(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1997(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1997 (keep=pnr hffsp in=d)
       	lign.indk_lign1997(in=e)
		indk2.indkomst1997(in=f)
		indk2.ex_indk1997(in=g)
		fain.fain1999(keep=pnr kom in=h)
		sskat.skat_indk1997(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=2000;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom2000/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=2000));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1997_2000=1));
year=2000;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;
/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 adagpag qovskejd
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   adagpag=c_adagpag
	   qovskejd=c_qovskejd
	   andakas=c_andakas
	   invudl=c_invudl
	   kapvaers=c_kapvaers
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_adagpag=. then c_adagpag=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_andakas=. then c_andakas=0;
if c_invudl=. then c_invudl=0;
if c_kapvaers=. then c_kapvaers=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;

/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/************************************************************/
/* Kapitalindkomst, som indgår i grundlaget for bundskatten */
/************************************************************/
/* hvis personer har negativ kapitalindkomst, indgår halvdelen af det i grundlaget 
for beregningen af bundskatten */
/* for ugifte*/
if gift=0 then do;
if kapindk<0 then kapindk_b=0.5*kapindk;
if kapindk=>0 then kapindk_b=kapindk;
end;
/* For gifte */
/* Kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_b=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_b=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_b=h_kapindk;
/* nul kapitalindkomst i husholdning */
if h_kapindk=0 then kapindk_b=0;
/* med negativ kapitalindkomst i husholdning */
if h_kapindk<0 and c_kapindk<0 and kapindk<0 then kapindk_b=0.5*kapindk;
if h_kapindk<0 and c_kapindk=>0 and kapindk<0 then kapindk_b=0.5*h_kapindk;
if h_kapindk<0 and c_kapindk<0 and kapindk=>0 then kapindk_b=0;
end; 

/*******************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_m=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_m=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_m=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_m=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_m=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_m=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;


/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

ebsats=0.04;
if h_persindk>0 then ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*ebsats;
if h_persindk<=0 then ebfradrag=(-h_kapindk>0)*(-h_kapindk*ebsats);
if gift=1 and ebfradrag>0 then ebfradrag=(kapindk<0)*ebfradrag*min(1,kapindk/h_kapindk);

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk_b-lignfrad-ebfradrag-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_m-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk_top+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/************************************************************/
/* Kapitalindkomst, som indgår i grundlaget for bundskatten */
/************************************************************/
/* hvis personer har negativ kapitalindkomst, indgår halvdelen af det i grundlaget 
for beregningen af bundskatten */
/* for ugifte*/
if c_gift=0 then do;
if c_kapindk<0 then c_kapindk_b=0.5*c_kapindk;
if c_kapindk=>0 then c_kapindk_b=c_kapindk;
end;
/* For gifte */
/* Kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_b=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_b=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_b=h_kapindk;
/* nul kapitalindkomst i husholdning */
if h_kapindk=0 then c_kapindk_b=0;
/* med negativ kapitalindkomst i husholdning */
if h_kapindk<0 and kapindk=>0 and c_kapindk<0 then c_kapindk_b=0.5*h_kapindk;
if h_kapindk<0 and kapindk<0 and c_kapindk<0 then c_kapindk_b=0.5*c_kapindk;
if h_kapindk<0 and kapindk<0 and c_kapindk=>0 then c_kapindk_b=0;
end; 

/*******************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af mellemskat */
/*******************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_m=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_m=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_m=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_m=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_m=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_m=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

c_ebsats=0.04;
if h_persindk>0 then c_ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*c_ebsats;
if h_persindk<=0 then c_ebfradrag=(-h_kapindk>0)*(-h_kapindk*c_ebsats);
if c_gift=1 and c_ebfradrag>0 then c_ebfradrag=(c_kapindk<0)*c_ebfradrag*min(1,c_kapindk/h_kapindk);

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk_b-c_lignfrad-c_ebfradrag-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_m-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/* Beregner særlig pensionsopsparing */
spt=sp*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt+spt;


/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;


/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/* Beregner særlig pensionsopsparing */
c_spt=sp*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt+c_spt;

run;

%end;
%mend skat;
%skat;

data bif.skat2000_indkomst1997;
merge new1 (keep=pnr tax1 c_tax1 gift
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1998-2001 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1998(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1998(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1998(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1998 (keep=pnr hffsp in=d)
       	lign.indk_lign1998(in=e)
		indk2.indkomst1998(in=f)
		indk2.ex_indk1998(in=g)
		fain.fain2000(keep=pnr kom in=h)
		sskat.skat_indk1998(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=2001;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom2001/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=2001));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1998_2001=1));
year=2001;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;

/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 adagpag qovskejd
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   adagpag=c_adagpag
	   qovskejd=c_qovskejd
	   andakas=c_andakas
	   invudl=c_invudl
	   kapvaers=c_kapvaers
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_adagpag=. then c_adagpag=0;
if c_qovskejd=. then c_qovskejd=0;
if c_stip=. then c_stip=0;
if c_andakas=. then c_andakas=0;
if c_invudl=. then c_invudl=0;
if c_kapvaers=. then c_kapvaers=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;
/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;
/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;
/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_bm=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_bm=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_bm=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;


/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

ebsats=0.08;
if h_persindk>0 then ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*ebsats;
if h_persindk<=0 then ebfradrag=(-h_kapindk>0)*(-h_kapindk*ebsats);
if gift=1 and ebfradrag>0 then ebfradrag=(kapindk<0)*ebfradrag*min(1,kapindk/h_kapindk);

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk_bm-lignfrad-ebfradrag-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_bm-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk_top+kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_bm=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_bm=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_bm=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

c_ebsats=0.08;
if h_persindk>0 then c_ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*c_ebsats;
if h_persindk<=0 then c_ebfradrag=(-h_kapindk>0)*(-h_kapindk*c_ebsats);
if c_gift=1 and c_ebfradrag>0 then c_ebfradrag=(c_kapindk<0)*c_ebfradrag*min(1,c_kapindk/h_kapindk);

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk_bm-c_lignfrad-c_ebfradrag-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_bm-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk_top+c_kapindk_top-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/* Beregner særlig pensionsopsparing */
spt=sp*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt+spt;
 

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/* Beregner særlig pensionsopsparing */
c_spt=sp*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt+c_spt;

run;

%end;
%mend skat;
%skat;

data bif.skat2001_indkomst1998;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 1999-2002 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk1999(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain1999(keep=pnr cnr cfalle civst in=b)
		idpe.idpe1999(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda1999 (keep=pnr hffsp in=d)
       	lign.indk_lign1999(in=e)
		indk2.indkomst1999(in=f)
		indk2.ex_indk1999(in=g)
		fain.fain2001(keep=pnr kom in=h)
		sskat.skat_indk1999(keep=pnr samskat in=k);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=2002;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom2002/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=2002));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl1999_2002=1));
year=2002;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;


/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   andakas=c_andakas
	   invudl=c_invudl
	   kapvaers=c_kapvaers
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_stip=. then c_stip=0;
if c_andakas=. then c_andakas=0;
if c_invudl=. then c_invudl=0;
if c_kapvaers=. then c_kapvaers=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb-sp))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb-sp);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;
/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_bm=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_bm=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_bm=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;


/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

ebsats=0.08;
if h_persindk>0 then ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*ebsats;
if h_persindk<=0 then ebfradrag=(-h_kapindk>0)*(-h_kapindk*ebsats);
if gift=1 and ebfradrag>0 then ebfradrag=(kapindk<0)*ebfradrag*min(1,kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2005, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
lignfrad_high=0;
if lignfrad>40000 then lignfrad_high=lignfrad-40000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk_bm-lignfrad_high-ebfradrag-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_bm-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top+arbpen14+arbpen15+pripen14+pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_bm=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_bm=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_bm=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=c_persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

c_ebsats=0.08;
if h_persindk>0 then c_ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*c_ebsats;
if h_persindk<=0 then c_ebfradrag=(-h_kapindk>0)*(-h_kapindk*c_ebsats);
if c_gift=1 and c_ebfradrag>0 then c_ebfradrag=(c_kapindk<0)*c_ebfradrag*min(1,c_kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2002, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
c_lignfrad_high=0;
if c_lignfrad>40000 then c_lignfrad_high=c_lignfrad-40000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk_bm-c_lignfrad_high-c_ebfradrag-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_bm-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top+c_arbpen14+c_arbpen15+c_pripen14+c_pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/* Beregner særlig pensionsopsparing */
spt=sp*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt+spt;


/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/* Beregner særlig pensionsopsparing */
c_spt=sp*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt+c_spt;

run;


%end;
%mend skat;
%skat;

data bif.skat2002_indkomst1999;
merge new1 (keep=pnr tax1 c_tax1 gift
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 2000-2003 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0(drop=alderp kon2 pstill2 sstill2 kom erhver erhver79);
 merge 	indk.indk2000(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain2000(keep=pnr cnr cfalle civst in=b)
		idpe.idpe2000(keep=pnr kon2 alderp pstill2 sstill2 /*ietype ieland*/ pdb932 cstatus
	   					erhver erhver79 anc017 ctype arledgr in=c)
		udda.udda2000 (keep=pnr hffsp in=d)
       	lign.indk_lign2000(in=e)
		indk2.indkomst2000(in=f)
		indk2.ex_indk2000(in=g)
		fain.fain2002(keep=pnr kom in=h);
 kon=input(kon2,1.);
 bopkom=input(kom,12.);
 alder=input(alderp,3.);
 pstill=input(pstill2,2.);
 sstill=input(sstill2,2.);
 exp=erhver79+erhver/1000;
 if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=2003;
 if cstatus in (2,3) and civst="G" then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom2003/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=2003));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl2000_2003=1));
year=2003;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;



/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   andakas=c_andakas
	   invudl=c_invudl
	   kapvaers=c_kapvaers
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_stip=. then c_stip=0;
if c_andakas=. then c_andakas=0;
if c_invudl=. then c_invudl=0;
if c_kapvaers=. then c_kapvaers=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;
/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;

/* Aktieindkomst */
h_aktind=aktind+c_aktind;


/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_bm=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_bm=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_bm=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;


/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

ebsats=0.06;
if h_persindk>0 then ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*ebsats;
if h_persindk<=0 then ebfradrag=(-h_kapindk>0)*(-h_kapindk*ebsats);
if gift=1 and ebfradrag>0 then ebfradrag=(kapindk<0)*ebfradrag*min(1,kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2003, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
lignfrad_high=0;
if lignfrad>60000 then lignfrad_high=lignfrad-60000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk_bm-lignfrad_high-ebfradrag-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_bm-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top+arbpen14+arbpen15+pripen14+pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_bm=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_bm=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_bm=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=c_persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

c_ebsats=0.06;
if h_persindk>0 then c_ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*c_ebsats;
if h_persindk<=0 then c_ebfradrag=(-h_kapindk>0)*(-h_kapindk*c_ebsats);
if c_gift=1 and c_ebfradrag>0 then c_ebfradrag=(c_kapindk<0)*c_ebfradrag*min(1,c_kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2003, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
c_lignfrad_high=0;
if c_lignfrad>60000 then c_lignfrad_high=c_lignfrad-60000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk_bm-c_lignfrad_high-c_ebfradrag-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_bm-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top+c_arbpen14+c_arbpen15+c_pripen14+c_pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/* Beregner særlig pensionsopsparing */
spt=sp*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt+spt;


/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/* Beregner særlig pensionsopsparing */
c_spt=sp*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt+c_spt;

run;

%end;
%mend skat;
%skat;

data bif.skat2003_indkomst2000;
merge new1 (keep=pnr tax1 c_tax1 gift
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 2001-2004 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0;
 merge 	indk.indk2001(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain2001(keep=pnr cnr cfalle civst in=b)
		udda.udda2001 (keep=pnr hffsp in=d)
       	lign.indk_lign2001(in=e)
		indk2.indkomst2001(in=f)
		indk2.ex_indk2001(in=g)
		fain.fain2003(keep=pnr kom in=h)
		sskat.skat_indk2001(keep=pnr samskat in=k);
 bopkom=input(kom,12.);
if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=2004;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom2004/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=2004));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl2001_2004=1));
year=2004;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;



/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   andakas=c_andakas
	   invudl=c_invudl
	   kapvaers=c_kapvaers
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_stip=. then c_stip=0;
if c_andakas=. then c_andakas=0;
if c_invudl=. then c_invudl=0;
if c_kapvaers=. then c_kapvaers=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;

/* Aktieindkomst */
aktind=qaktind*inflation;

/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;

/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;
/* Aktieindkomst */
h_aktind=aktind+c_aktind;
/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*************************/
/* Beskæftigelsesfradrag */
/************************/
/* Grundlag for beskæftigelsesfradrag: lønindkomst fratrukket privattegnede pensioner */
beindk=arbindk*(arbindk>0)-pripen10-pripen11-pripen12-pripen13-pripen14-pripen15;

befradrag=beindk*(beindk>0)*0.025; 

if befradrag>7000 then befradrag=7000; /*Loft på beksæftigelsesfradrag*/
if befradrag<0 then befradrag=0;/*Bund på beskæftigelsesfradrag*/

/* Beskæftigelsesfradrag overføres til ligningsmæssige fradrag */
Lignfrad=lignfrad+befradrag;


/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_bm=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_bm=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_bm=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;


/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

ebsats=0.04;
if h_persindk>0 then ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*ebsats;
if h_persindk<=0 then ebfradrag=(-h_kapindk>0)*(-h_kapindk*ebsats);
if gift=1 and ebfradrag>0 then ebfradrag=(kapindk<0)*ebfradrag*min(1,kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2004, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
lignfrad_high=0;
if lignfrad>80000 then lignfrad_high=lignfrad-80000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk_bm-lignfrad_high-ebfradrag-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_bm-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top+arbpen14+arbpen15+pripen14+pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*************************/
/* Beskæftigelsesfradrag */
/************************/
/* Grundlag for beskæftigelsesfradrag: lønindkomst fratrukket privattegnede pensioner */
c_beindk=c_arbindk*(c_arbindk>0)-c_pripen10-c_pripen11-c_pripen12-c_pripen13-c_pripen14-c_pripen15;

c_befradrag=c_beindk*(c_beindk>0)*0.025; 

if c_befradrag>7000 then c_befradrag=7000; /*Loft på beksæftigelsesfradrag*/
if c_befradrag<0 then c_befradrag=0;/*Bund på beskæftigelsesfradrag*/

/* Beskæftigelsesfradrag overføres til ligningsmæssige fradrag */
c_Lignfrad=c_lignfrad+c_befradrag;

/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_bm=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_bm=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_bm=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=c_persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

c_ebsats=0.04;
if h_persindk>0 then c_ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*c_ebsats;
if h_persindk<=0 then c_ebfradrag=(-h_kapindk>0)*(-h_kapindk*c_ebsats);
if c_gift=1 and c_ebfradrag>0 then c_ebfradrag=(c_kapindk<0)*c_ebfradrag*min(1,c_kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2004, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
c_lignfrad_high=0;
if c_lignfrad>80000 then c_lignfrad_high=c_lignfrad-80000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk_bm-c_lignfrad_high-c_ebfradrag-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_bm-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top+c_arbpen14+c_arbpen15+c_pripen14+c_pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt;

run;


%end;
%mend skat;
%skat;

data bif.skat2004_indkomst2001;
merge new1 (keep=pnr tax1 c_tax1 gift 
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
            bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;


/********************************/
/* MECHANICAL CHANGES 2002-2005 */
/********************************/

/******************************/
/* STEP 1: DATA INPUT */ 
/******************************/

Data samle0;
 merge 	indk.indk2002(drop=korydial qbrukor2 qsluskat qsluska2 qaktivf 
						qpassiv kursakt koejd rentupri rentudio qlon qfradrag fosfufrd 
						tilbtot korstoett in=a) 
		fain.fain2002(keep=pnr cnr cfalle civst in=b)
		udda.udda2002 (keep=pnr hffsp in=d)
       	lign.indk_lign2002(in=e)
		indk2.indkomst2002(in=f)
		indk2.ex_indk2002(in=g)
		fain.fain2004(keep=pnr kom in=h)
		sskat.skat_indk2002(keep=pnr samskat in=k);
 bopkom=input(kom,12.);
if arbpen10=. then arbpen10=0;
if arbpen11=. then arbpen11=0;
if arbpen12=. then arbpen12=0;
if arbpen13=. then arbpen13=0;
if arbpen14=. then arbpen14=0;
if arbpen15=. then arbpen15=0;
if pripen10=. then pripen10=0;
if pripen11=. then pripen11=0;
if pripen12=. then pripen12=0;
if pripen13=. then pripen13=0;
if pripen14=. then pripen14=0;
if pripen15=. then pripen15=0;
 year=2005;
 if samskat in (2,3) then gift=1; else gift=0; /* gift=1, hvis man er underlagt sambeskatning */
by pnr;
 if a=1 and b=1 and d=1 and e=1 and f=1 and g=1 and h=1 and k=1;
run;

proc sort data=samle0;
 by bopkom;
run;

/* Datasæt med kommuneskat */
Data komskat(keep=bopkom kskat); 
 set skat.kommuneskat;
 kskat=kom2005/100;
run;

proc sort data=komskat;
 by bopkom;
run;

/* Kommuneskat kobles på datasættet */
Data samle2;
 merge 	samle0 (in=a)
		komskat (in=b);
 by bopkom;
 if a=1 and b=1;
run;

/* Datasæt med skattesatser og beløbsgrænser */
Data satser(keep=year bundskat mellemskat topskat sloft bfradrag1 sp
bfradrag2 fradrag_mskat fradrag_tskat ffradrag1 ffradrag2 aktie_grund aktie_skat1 aktie_skat2 amb);
 set skat.skattesatser1984_2005(where=(year=2005));
 run;

 proc sort data=samle2;
 by year;
 run;

  /* Datasæt med beregnet inflation pga. vækst i broadincome */
 data inflation(keep=year inflation);
 set bif2.inflation(where=(infl2002_2005=1));
year=2005;
run;

proc sort data=inflation; by year; run;


 /* Skattesatser og beløbsgrænser kobles på datasættet */
Data samle3;
merge samle2 (in=a) satser(in=b) inflation (in=c);
by year;
	ktax=kskat; /*amts- og kommuneskat*/
	ltax=bundskat; /* bundskat */
	mtax=mellemskat; /* mellemskat */
    	ttax=topskat; /* topskat */
	/* Evt. nedslag sfa. skråt skatteloft */
	ceiling1=ktax+ltax+mtax+ttax-sloft;
if ceiling1>0 then ttax=(ttax-ceiling1);
if a=1 and b=1 and c=1;
run;


/* Kobler oplysninger om ægtefæller på personer */
data cfelle;
set samle3(keep=cnr cfalle gift qlontmp2 kapindkp lignfrdp perindkp qformue qaktind
kskat bdagp arblhu adagp stip andakas invudl kapvaers arbpen10 arbpen11 
arbpen12 arbpen13 arbpen14 arbpen15 pripen10 
pripen11 pripen12 pripen13 pripen14 pripen15 ceiling1 ktax ltax mtax ttax);
if cfalle=. then delete;
if gift=0 then delete;
rename gift=c_gift
	   qlontmp2=c_qlontmp2
       perindkp=c_perindkp
       kapindkp=c_kapindkp
	   lignfrdp=c_lignfrdp
	   qformue=c_qformue 
	   qaktind=c_qaktind
	   bdagp=c_bdagp
	   arblhu=c_arblhu
	   adagp=c_adagp
	   stip=c_stip
	   andakas=c_andakas
	   invudl=c_invudl
	   kapvaers=c_kapvaers
	   ktax=c_ktax
	   ltax=c_ltax
	   mtax=c_mtax
	   ttax=c_ttax
	   kskat=c_kskat
	   ceiling1=c_ceiling1
	   arbpen10=c_arbpen10
	   arbpen11=c_arbpen11
	   arbpen12=c_arbpen12
	   arbpen13=c_arbpen13
	   arbpen14=c_arbpen14
	   arbpen15=c_arbpen15
	   pripen10=c_pripen10
	   pripen11=c_pripen11
	   pripen12=c_pripen12
	   pripen13=c_pripen13
	   pripen14=c_pripen14
	   pripen15=c_pripen15
	   cfalle=pnr;
       run;
 
proc sort data=cfelle; by pnr cnr; run;

proc sort data=samle3; by pnr cnr; run;

data ny;
merge 	cfelle
		samle3(in=a);
by pnr cnr;
if c_qlontmp2=. then c_qlontmp2=0;
if c_perindkp=. then c_perindkp=0;
if c_kapindkp=. then c_kapindkp=0;
if c_lignfrdp=. then c_lignfrdp=0;
if c_qformue=. then c_qformue=0;
if c_qaktind=. then c_qaktind=0;
if c_bdagp=. then c_bdagp=0;
if c_arblhu=. then c_arblhu=0;
if c_adagp=. then c_adagp=0;
if c_stip=. then c_stip=0;
if c_andakas=. then c_andakas=0;
if c_invudl=. then c_invudl=0;
if c_kapvaers=. then c_kapvaers=0;
if c_ktax=. then c_ktax=0;
if c_ltax=. then c_ltax=0;
if c_mtax=. then c_mtax=0;
if c_ttax=. then c_ttax=0;
if c_ceiling1=. then c_ceiling1=0;
if c_kskat=. then c_kskat=0;
if c_gift=. then c_gift=0;
if c_arbpen10=. then c_arbpen10=0;
if c_arbpen11=. then c_arbpen11=0;
if c_arbpen12=. then c_arbpen12=0;
if c_arbpen13=. then c_arbpen13=0;
if c_arbpen14=. then c_arbpen14=0;
if c_arbpen15=. then c_arbpen15=0;
if c_pripen10=. then c_pripen10=0;
if c_pripen11=. then c_pripen11=0;
if c_pripen12=. then c_pripen12=0;
if c_pripen13=. then c_pripen13=0;
if c_pripen14=. then c_pripen14=0;
if c_pripen15=. then c_pripen15=0;
real=c_gift+gift;
if real=1 then gift=0;
if real=1 then c_gift=0;
if a=1;
run;

%macro skat;
%do i=1 %to 9;

data new&i;
set ny;

y="&i";
x=100;

/******************************************************************************/
/* STEP 2: DEFINITION OF INCOMES FOR MAIN TAXPAYER, SPOUSE AND HOUSEHOLD */
/******************************************************************************/

/***************/
/* HOVEDPERSON */
/***************/

/* Arbejdsindkomst */
arbindk=qlontmp2*inflation;
if y=2 then arbindk=qlontmp2*inflation+x;

/* Anden personlig indkomst */
apersindk=(perindkp-qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=3 then apersindk=apersindk+x;

/* Samlet personlig indkomst */
persindk=apersindk+arbindk*(1-amb);

/* Nettokapitalindkomst */
Kapindk=kapindkp*inflation;
if y=4 then kapindk=kapindk+x;

/* Ligningsmæssige fradrag */
Lignfrad=lignfrdp*inflation;
if y=5 then lignfrad=lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
persindk_top=persindk+(arbpen14+arbpen15+pripen14+pripen15)*inflation;

/* Formue */
formue=qformue*inflation;
/* Aktieindkomst */
aktind=qaktind*inflation;
/*************/
/* ÆGTEFÆLLE */
/*************/

/* Arbejdsindkomst */
c_arbindk=c_qlontmp2*inflation;
if y=6 then c_arbindk=c_qlontmp2*inflation+x;

/* Anden personlig indkomst */
c_apersindk=(c_perindkp-c_qlontmp2*(1-amb))*inflation; /*arbejdsmarkedsbidrag er fratrukket*/
if y=7 then c_apersindk=c_apersindk+x;

/* Samlet personlig indkomst */
c_persindk=c_apersindk+c_arbindk*(1-amb);

/* Nettokapitalindkomst */
c_kapindk=c_kapindkp*inflation;
if y=8 then c_kapindk=c_kapindk+x;

/* Ligningsmæssige fradrag */
c_Lignfrad=c_lignfrdp*inflation;
if y=9 then c_lignfrad=c_lignfrad-x;

/* Personlig indkomst med tillæg af tilskud til kapitalpension (bruges til beregning af topskat) */
c_persindk_top=c_persindk+(c_arbpen14+c_arbpen15+c_pripen14+c_pripen15)*inflation;

/* Formue */
c_formue=c_qformue*inflation;
/* Aktieindkomst */
c_aktind=c_qaktind*inflation;
/***************/
/* HUSHOLDNING */
/***************/

/* Kapitalindkomst */
h_kapindk=kapindk+c_kapindk;

/* Personlig indkomst */
h_persindk=persindk+c_persindk;

/* Formue */
h_formue=formue+c_formue;
/* Aktieindkomst */
h_aktind=aktind+c_aktind;
/****************************************************/
/* STEP 3: CALCULATES TAX BASES FOR MAIN TAXPAYER */
/****************************************************/
/*************************/
/* Beskæftigelsesfradrag */
/************************/
/* Grundlag for beskæftigelsesfradrag: lønindkomst fratrukket privattegnede pensioner */
beindk=arbindk*(arbindk>0)-pripen10-pripen11-pripen12-pripen13-pripen14-pripen15;

befradrag=beindk*(beindk>0)*0.025; 

if befradrag>7200 then befradrag=7200; /*Loft på beksæftigelsesfradrag*/
if befradrag<0 then befradrag=0;/*Bund på beskæftigelsesfradrag*/

/* Beskæftigelsesfradrag overføres til ligningsmæssige fradrag */
Lignfrad=lignfrad+befradrag;


/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if gift=0 then do;
/* med ikke positiv kapitalindkomst */
if kapindk<=0 then kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if kapindk>0 then kapindk_bm=kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and c_kapindk>0 and kapindk>0 then kapindk_bm=kapindk;
if h_kapindk>0 and c_kapindk>0 and kapindk<=0 then kapindk_bm=0;
if h_kapindk>0 and c_kapindk<=0 and kapindk>0 then kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if gift=0 then do;
if kapindk>0 then kapindk_top=kapindk;
if kapindk<=0 then kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if gift=1 and persindk_top>c_persindk_top then do;
if h_kapindk>0 then kapindk_top=h_kapindk;
if h_kapindk<=0 then kapindk_top=0;
end;

if gift=1 and persindk_top<c_persindk_top then kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if gift=1 and persindk_top=c_persindk_top then do;
if h_kapindk>0 and lignfrad=>c_lignfrad then kapindk_top=h_kapindk;
if h_kapindk>0 and lignfrad<c_lignfrad then kapindk_top=0;
if h_kapindk<=0 then kapindk_top=0;
end;


/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

ebsats=0.02;
if h_persindk>0 then ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*ebsats;
if h_persindk<=0 then ebfradrag=(-h_kapindk>0)*(-h_kapindk*ebsats);
if gift=1 and ebfradrag>0 then ebfradrag=(kapindk<0)*ebfradrag*min(1,kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2005, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
lignfrad_high=0;
if lignfrad>100000 then lignfrad_high=lignfrad-100000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind<=aktie_grund then tau_akt_h=aktie_skat1;
if aktind>aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=0 and aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if aktind=>-aktie_grund then tau_akt_h=aktie_skat1;
if aktind<-aktie_grund then tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
bundinc=persindk+kapindk_bm-lignfrad_high-ebfradrag-bfradrag1;
bundinc_neg=0;
if gift=1 then bundinc_neg=(bundinc<0)*bundinc;

/* mellemindkomst */
melleminc=persindk+kapindk_bm-fradrag_mskat;
melleminc_neg=0;
if gift=1 then melleminc_neg=(melleminc<0)*melleminc;

/* topindkomst */
topinc=persindk+kapindk_top+arbpen14+arbpen15+pripen14+pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
kominc=persindk+kapindk-lignfrad-bfradrag1;
kominc_neg=0;
if gift=1 then kominc_neg=(kominc<0)*kominc;
/**************************************************/
/* STEP 4: CALCULATES TAX BASES FOR SPOUSE */
/**************************************************/
/*************************/
/* Beskæftigelsesfradrag */
/************************/
/* Grundlag for beskæftigelsesfradrag: lønindkomst fratrukket privattegnede pensioner */
c_beindk=c_arbindk*(c_arbindk>0)-c_pripen10-c_pripen11-c_pripen12-c_pripen13-c_pripen14-c_pripen15;

c_befradrag=c_beindk*(c_beindk>0)*0.025; 

if c_befradrag>7200 then c_befradrag=7200; /*Loft på beksæftigelsesfradrag*/
if c_befradrag<0 then c_befradrag=0;/*Bund på beskæftigelsesfradrag*/

/* Beskæftigelsesfradrag overføres til ligningsmæssige fradrag */
c_Lignfrad=c_lignfrad+c_befradrag;

/****************************************************************************/
/* Positiv kapitalindkomst, som bruges til beregning af bund- og mellemskat */
/****************************************************************************/
/* For ugifte */
if c_gift=0 then do;
/* med ikke positiv kapitalindkomst */
if c_kapindk<=0 then c_kapindk_bm=0; /*Sætter kapitalindkomst til nul, hvis ikke positiv */
/* med positiv kapitalindkomst */
if c_kapindk>0 then c_kapindk_bm=c_kapindk;
end;

/* For gifte */
/* Negativ kapitalindkomst overføres mellem ægtefæller */
if c_gift=1 then do;
/* med positiv kapitalindkomst i husholdning */
if h_kapindk>0 and kapindk>0 and c_kapindk>0 then c_kapindk_bm=c_kapindk;
if h_kapindk>0 and kapindk>0 and c_kapindk<=0 then c_kapindk_bm=0;
if h_kapindk>0 and kapindk<=0 and c_kapindk>0 then c_kapindk_bm=h_kapindk;

/* med ikke positiv kapitalindkomst i husholdning */
if h_kapindk<=0 then c_kapindk_bm=0; /* sætter kapitalindkomst til nul, hvis ikke positiv */
end;

/****************************************************************/ 
/* Positiv kapitalindkomst, som bruges til beregning af topskat */
/****************************************************************/
/* For ugifte */
if c_gift=0 then do;
if c_kapindk>0 then c_kapindk_top=c_kapindk;
if c_kapindk<=0 then c_kapindk_top=0;
end; 

/* For gifte */
/* Såfremt man er gift, beregnes der topskat af den samlede positive nettokapitalindkomst 
hos den af ægtefællene, der har den højeste personlige indkomst med tillæg af indskud 
til kapitalpension) */
if c_gift=1 and c_persindk_top>persindk_top then do;
if h_kapindk>0 then c_kapindk_top=h_kapindk;
if h_kapindk<=0 then c_kapindk_top=0;
end;

if c_gift=1 and c_persindk_top<persindk_top then c_kapindk_top=0;

/* Hvis samme personlig indkomst med tillæg af kapitalpension, 
tildeles kapitalindkomsten ægtefællen med højeste ligningsmæssige fradrag */
if c_gift=1 and c_persindk_top=c_persindk_top then do;
if h_kapindk>0 and c_lignfrad>lignfrad then c_kapindk_top=h_kapindk;
if h_kapindk>0 and c_lignfrad<=lignfrad then c_kapindk_top=0;
if h_kapindk<=0 then c_kapindk_top=0;
end;

/************************************************************/
/* Det særlige tilskud til store negative kapitalindkomster */
/* som kan overføres mellem ægtefæller                      */
/************************************************************/

c_ebsats=0.02;
if h_persindk>0 then c_ebfradrag=(-h_kapindk/h_persindk>0.2)*(-h_kapindk-0.2*h_persindk)*c_ebsats;
if h_persindk<=0 then c_ebfradrag=(-h_kapindk>0)*(-h_kapindk*c_ebsats);
if c_gift=1 and c_ebfradrag>0 then c_ebfradrag=(c_kapindk<0)*c_ebfradrag*min(1,c_kapindk/h_kapindk);

/*********************************************************************************************/
/* Fradrag i bundskatten for den del af de ligningsmæssige fradrag (for den enkelte person), */
/* der overstiger 40000 kr. i 2002 (+20000 kr. hvert år indtil 2005, hvorefter               */
/* overgangsordningen forsvinder)                                                            */
/*********************************************************************************************/
c_lignfrad_high=0;
if c_lignfrad>100000 then c_lignfrad_high=c_lignfrad-100000;

/*****************/
/* Aktieindkomst */
/*****************/
/* for ugifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind=>0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind<=aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind>aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=0 and c_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if c_aktind=>-aktie_grund then c_tau_akt_h=aktie_skat1;
if c_aktind<-aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* for gifte */
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind=>0 then do;
h_aktie_grund=aktie_grund*2;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind<=h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind>h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/* hvis aktieindkomst er ikke negativ */
if c_gift=1 and h_aktind<0 then do;
/* indkomst under eller lig med progressionsgrænse */
if h_aktind=>-h_aktie_grund then c_tau_akt_h=aktie_skat1;
if h_aktind<-h_aktie_grund then c_tau_akt_h=aktie_skat2;
end;
/****************************************************************************************/
/* Skattebaser før overførsel af evt. uudnyttet fradrag i bund- og mellemskattegrundlag */
/****************************************************************************************/
/* Bundindkomst */
c_bundinc=c_persindk+c_kapindk_bm-c_lignfrad_high-c_ebfradrag-bfradrag1;
c_bundinc_neg=0;
if c_gift=1 then c_bundinc_neg=(c_bundinc<0)*c_bundinc;

/* mellemindkomst */
c_melleminc=c_persindk+c_kapindk_bm-fradrag_mskat;
c_melleminc_neg=0;
if c_gift=1 then c_melleminc_neg=(c_melleminc<0)*c_melleminc;

/* topindkomst */
c_topinc=c_persindk+c_kapindk_top+c_arbpen14+c_arbpen15+c_pripen14+c_pripen15-fradrag_tskat;

/* Amts- og kommuneindkomst */
c_kominc=c_persindk+c_kapindk-c_lignfrad-bfradrag1;
c_kominc_neg=0;
if c_gift=1 then c_kominc_neg=(c_kominc<0)*c_kominc;

/******************************************************/
/* STEP 5: TAX LIABILITY CALCULATIONS FOR MAIN TAXPAYER */
/******************************************************/

/* Bundskat */
nybundinc=bundinc+c_bundinc_neg;
bundt=(nybundinc>0)*nybundinc*ltax;

/* Mellemskat */
nymelleminc=melleminc+c_melleminc_neg;
mellemt=(nymelleminc>0)*nymelleminc*mtax;

/* Topskat */
topt=(topinc>0)*topinc*ttax;

/* Kommuneskat */
nykominc=kominc+c_kominc_neg;
komt=(nykominc>0)*nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
ambt=amb*arbindk*(arbindk>0);

/*Beregner samlet skattebetaling */
tax&i=komt+bundt+mellemt+topt+ambt;

/* Laver dummies, som indikerer om man betaler bund-, mellem eller topsskat, 
som højeste skattesats */
top_dummy=0;
if topt>0 then top_dummy=1;
mellem_dummy=0;
if mellemt>0 and top_dummy=0 then mellem_dummy=1;
bund_dummy=0;
lowt=komt+bundt;
if lowt>0 and top_dummy=0 and mellem_dummy=0 then bund_dummy=1;
notax_dummy=0;
if bund_dummy=0 and mellem_dummy=0 and top_dummy=0 then notax_dummy=1;

/****************************************************/
/* STEP 6: TAX LIABILITY CALCULATIONS FOR SPOUSE */
/****************************************************/

/* Bundskat */
c_nybundinc=c_bundinc+bundinc_neg;
c_bundt=(c_nybundinc>0)*c_nybundinc*ltax;

/* Mellemskat */
c_nymelleminc=c_melleminc+melleminc_neg;
c_mellemt=(c_nymelleminc>0)*c_nymelleminc*mtax;

/* Topskat */
c_topt=(c_topinc>0)*c_topinc*ttax;

/* Kommuneskat */
c_nykominc=c_kominc+kominc_neg;
c_komt=(c_nykominc>0)*c_nykominc*ktax;

/* Beregner arbejdsmarkedbidrag */
c_ambt=amb*c_arbindk*(c_arbindk>0);

/*Beregner samlet skattebetaling */
c_tax&i=c_komt+c_bundt+c_mellemt+c_topt+c_ambt;

run;

%end;
%mend skat;
%skat;

data bif.skat2005_indkomst2002;
merge new1 (keep=pnr tax1 c_tax1 gift  
            arbindk apersindk kapindk lignfrad c_arbindk c_apersindk c_kapindk c_lignfrad x 
           bund_dummy mellem_dummy top_dummy notax_dummy tau_akt_h c_tau_akt_h aktind c_aktind in=a) 
	  new2 (keep=pnr tax2 c_tax2 in=b) 
      new3 (keep=pnr tax3 c_tax3 in=c)
      new4 (keep=pnr tax4 c_tax4 in=d)
      new5 (keep=pnr tax5 c_tax5 in=e)
      new6 (keep=pnr tax6 c_tax6 in=f)
      new7 (keep=pnr tax7 c_tax7 in=g)
      new8 (keep=pnr tax8 c_tax8 in=h)
      new9 (keep=pnr tax9 c_tax9 in=i);


by pnr;

/************************************************************/
/* STEP 7: CALCULATES MECHANICAL CHANGE IN MARGINAL TAX RATES AND VIRTUAL INCOME */
/************************************************************/
/*******************************************************************/
/* Individuelle marginalskatter, baseret på individets skattebyrde */
/*******************************************************************/
/* For hovedperson */

/* Marginalskat af arbejdsindkomst */
tau_arb_i=(tax2-tax1)/x;

/* Marginalskat af anden personlig indkomst */
tau_apers_i=(tax3-tax1)/x;

/* Marginalskat af kapitalindkomst */
tau_kap_i=(tax4-tax1)/x;

/* Marginalskat af ligningsmæssige fradrag */
tau_frad_i=((tax5)-(tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
c_tau_arb_i=((c_tax6)-(c_tax1))/x;

/* Marginalskat af anden personlig indkomst */
c_tau_apers_i=((c_tax7)-(c_tax1))/x;

/* Marginalskat af kapitalindkomst */
c_tau_kap_i=((c_tax8)-(c_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
c_tau_frad_i=((c_tax9)-(c_tax1))/x;

/*******************************************************************************/
/* Individuelle marginalskatter, baseret på husholdningens samlede skattebyrde */
/*******************************************************************************/
/* Husholdningens samlede skattebyrde */
h_tax1=tax1+c_tax1;

/* For hovedpersoner */

/* Marginalskat af arbejdsindkomst */
h_tax2=tax2+c_tax2;
tau_arb_h=((h_tax2)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax3=tax3+c_tax3;
tau_apers_h=((h_tax3)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax4=tax4+c_tax4;
tau_kap_h=((h_tax4)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax5=tax5+c_tax5;
tau_frad_h=((h_tax5)-(h_tax1))/x;

/* For ægtefælle */

/* Marginalskat af arbejdsindkomst */
h_tax6=tax6+c_tax6;
c_tau_arb_h=((h_tax6)-(h_tax1))/x;

/* Marginalskat af anden personlig indkomst */
h_tax7=tax7+c_tax7;
c_tau_apers_h=((h_tax7)-(h_tax1))/x;

/* Marginalskat af kapitalindkomst */
h_tax8=tax8+c_tax8;
c_tau_kap_h=((h_tax8)-(h_tax1))/x;

/* Marginalskat af ligningsmæssige fradrag */
h_tax9=tax9+c_tax9;
c_tau_frad_h=((h_tax9)-(h_tax1))/x;

/********************/
/* Virtuel indkomst */
/********************/
/********************/
/* På individniveau */
/********************/
virtuelindk_i=tau_arb_i*arbindk+tau_apers_i*apersindk+tau_kap_i*kapindk-tau_frad_i*lignfrad
-tax1;

/*********************/
/* På husholdsniveau */
/*********************/
/* Virtuel indkomst til brug i quasi-joint specifikation, der tager ægtefællens valg */
/* for givet (dvs. ægtefællens indkomst behandles som eksogen indkomst)              */
virtuelindk_h1=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad
+c_arbindk+c_apersindk+c_kapindk-c_lignfrad-h_tax1;

/* Virtuel indkomst til brug i fuldt-joint specifikation, hvor begge ægtefællers valg */
/* optimeres simultant (dvs. ægtefællens marginalskat inkluderes direkte som          */
/* forklarende variabel i specifikation)                                              */
virtuelindk_h2=tau_arb_h*arbindk+tau_apers_h*apersindk+tau_kap_h*kapindk-tau_frad_h*lignfrad+
c_tau_arb_h*c_arbindk+c_tau_apers_h*c_apersindk+c_tau_kap_h*c_kapindk-c_tau_frad_h*c_lignfrad
-h_tax1;

if a=1 and b=1 and c=1 and d=1 and e=1 and f=1 and g=1 and h=1 and i=1;
run;

