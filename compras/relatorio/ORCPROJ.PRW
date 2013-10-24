/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/05/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de Orcamento Consolidado                    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function ORCPROJ()
	private aOrd    := {"Projeto"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "ORCPROJ"
	private Cabec1  := "PROJETO                                                                                    FORNECEDOR                      ENTREGAR"
	private Cabec2  := "GRUPO                                | DT ORCAM |          VL ORCAM |     VL REALIZADO |         VL SALDO"
	private cDesc1  := "ACOMP. FISICO FINANCEIRO DE PROJETO"
	private ContFun := 0
	private cString := "SZ3"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cPrjIni := ""
	private cPrjFin := ""
	private cOcIni := ""
	private nPor := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Projeto de                                        ³
	//³ mv_par02 - Projeto ate                                       ³
	//³ mv_par03 - O.C. de                                           ³
	//³ mv_par04 - Impressao Por (1-Projeto/2-O.C.)                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrjIni := mv_par01
	cPrjFin := mv_par02
	cOcIni := mv_par03
	nPor := mv_par04
	
	if nPor == 2			//Ordem de Compra
		Processa({|| Impr1()},"","Aguarde processando...",lAborta)
	else					//Projeto
		Processa({|| Impr()},"","Aguarde processando...",lAborta)
	endif
	
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return

//**************************************************************\\
// Impressao por Projeto                                        \\
//**************************************************************\\
static function Impr()
	local aIncSist := {}
	
	cQry := "select SZ3.Z3_PROJETO, SZ3.Z3_DESCPRO, SZ3.Z3_CLIENTE, SZ3.Z3_LOJA, SZ3.Z3_DESCCLI, SZ4.Z4_GGRUPO, SZ4.Z4_GRUPO, SZ4.Z4_DESCGRP, SZ4.Z4_DTORCAM, SZ4.Z4_VLORCAM, SZ4.Z4_VLREVIS, SZ4.Z4_VLREALI, SZ4.Z4_EMPENHA, SZ4.Z4_SALDO, SZ4.Z4_INCSIST "
	cQry += "from "+RetSqlName("SZ3")+" SZ3 inner join "+RetSqlName("SZ4")+" SZ4 on (SZ3.Z3_NUM = SZ4.Z4_NUM and SZ3.Z3_PROJETO = SZ4.Z4_PROJETO) "
	cQry += "where (SZ3.Z3_PROJETO between '"+cPrjIni+"' and '"+cPrjFin+"') and SZ3.D_E_L_E_T_ <> '*' and SZ4.D_E_L_E_T_ <> '*' "
	cQry += "order by SZ4.Z4_GGRUPO"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !TEMP->(Eof())
		cProjeto := TEMP->Z3_PROJETO
		nTotOrcam := 0 ; nTotGeral := 0 ; nTotRevis := 0 ; nTotReali := 0 ; nTotEmpenha := 0
		nLin++
		
//		PROJETO                                                                                    FORNECEDOR                      ENTREGAR
//		999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99/99/99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay Left(TEMP->Z3_PROJETO,6)+" - "+Left(TEMP->Z3_DESCPRO,80)
		@nLin,091 psay Left(TEMP->Z3_DESCCLI,30)
		@nLin,123 psay IIf(CTH->(DbSeek(xFilial("CTH")+TEMP->Z3_PROJETO,.F.)),U_ConvData(DToS(CTH->CTH_DTENTR),"yy")," ")
		
		nLin += 2
		
		U_SaltaFolha()
		
		while !TEMP->(Eof()) .and. cProjeto == TEMP->Z3_PROJETO
			if TEMP->Z4_INCSIST == "N"
				aAlias := GetArea()
				cGGrupo := TEMP->Z4_GGRUPO
				
				cCon := "select count(Z4_GRUPO) as QUANT, sum(Z4_VLORCAM) as Z4_VLORCAM, sum(Z4_EMPENHA) as Z4_EMPENHA, sum(Z4_SALDO) as Z4_SALDO "
				cCon += "from "+RetSqlName("SZ4")+" "
				cCon += "where Z4_PROJETO = '"+cProjeto+"' and Z4_GGRUPO = '"+cGGrupo+"' and D_E_L_E_T_ <> '*'"
				
				tcquery cCon new alias "TEMP1"
				
				DbSelectArea("TEMP1")
				
				@nLin,000 psay cGGrupo+"-"+If(SX5->(DbSeek(xFilial("SX5")+"GG"+cGGrupo,.F.)),Left(SX5->X5_DESCRI,30),"")
				@nLin,039 psay U_ConvData(TEMP->Z4_DTORCAM,"yy")
				
				if TEMP1->QUANT > 1
					@nLin,053 psay Transf(TEMP1->Z4_VLORCAM,"@E 999,999,999.99")
					@nLin,072 psay Transf(TEMP1->Z4_EMPENHA,"@E 999,999,999.99")
					@nLin,091 psay Transf(TEMP1->Z4_SALDO,"@E 999,999,999.99")
				endif
				
				TEMP1->(DbCloseArea())
				
				RestArea(aAlias)
				
				while cGGrupo == TEMP->Z4_GGRUPO
					if !Empty(TEMP->Z4_GRUPO)
						@++nLin,003 psay AllTrim(TEMP->Z4_GRUPO)+"-"+TEMP->Z4_DESCGRP
					endif
					
					@nLin,053 psay Transf(TEMP->Z4_VLORCAM,"@E 999,999,999.99")
//					@nLin,067 psay Transf(TEMP->Z4_VLREVIS,"@E 999,999,999.99")
//					@nLin,072 psay Transf(TEMP->Z4_VLREALI,"@E 999,999,999.99")
					@nLin,072 psay Transf(TEMP->Z4_EMPENHA,"@E 999,999,999.99")
//					@nLin,101 psay Transf(TEMP->Z4_EMPENHA,"@E 999,999,999.99")
					@nLin,091 psay Transf(TEMP->Z4_SALDO,"@E 999,999,999.99")
					
//					GRUPO                                | DT ORCAM |          VL ORCAM |     VL REALIZADO |         VL SALDO
//					99999-999999999999999999999999999999   99/99/99      999,999,999.99     999,999,999.99     999,999,999.99
//					012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//					          1         2         3         4         5         6         7         8         9        10        11        12        13
					
					nTotOrcam += TEMP->Z4_VLORCAM
					nTotRevis += TEMP->Z4_VLREVIS
					nTotReali += TEMP->Z4_VLREALI
					nTotEmpenha += TEMP->Z4_EMPENHA
					nTotGeral += TEMP->Z4_SALDO
					
					U_SaltaFolha()
					IncProc()
					TEMP->(DbSkip())
				enddo
				
				nLin++
				
				U_SaltaFolha()
			else
				if (nInd := AScan(aIncSist,{|x| x[1] = TEMP->Z4_GGRUPO})) == 0
					AAdd(aIncSist,{TEMP->Z4_GGRUPO,TEMP->Z4_DTORCAM,TEMP->Z4_VLORCAM,TEMP->Z4_VLREVIS,TEMP->Z4_VLREALI,TEMP->Z4_EMPENHA,TEMP->Z4_SALDO})
				else
					aIncSist[nInd][3] += TEMP->Z4_VLORCAM
					aIncSist[nInd][4] += TEMP->Z4_VLREVIS
					aIncSist[nInd][5] += TEMP->Z4_VLREALI
					aIncSist[nInd][6] += TEMP->Z4_EMPENHA
					aIncSist[nInd][7] += TEMP->Z4_SALDO
				endif
				
				TEMP->(DbSkip())
			endif
		enddo
		
//		@nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",131))
//		@nLin,000 psay Replicate("-",136)
		@nLin,000 psay "TOTAL"
		@nLin,053 psay Transf(nTotOrcam,"@E 999,999,999.99")
//		@nLin,067 psay Transf(nTotRevis,"@E 999,999,999.99")
//		@nLin,084 psay Transf(nTotReali,"@E 999,999,999.99")
		@nLin,072 psay Transf(nTotEmpenha,"@E 999,999,999.99")
//		@nLin,101 psay Transf(nTotEmpenha,"@E 999,999,999.99")
		@nLin,091 psay Transf(nTotGeral,"@E 999,999,999.99")
		
		if !Empty(aIncSist)
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay Replicate("-",132)
			
			nLin++
			
			U_SaltaFolha()
			
			nOrcam := 0 ; nRevis := 0 ; nReali := 0 ; nEmpenha := 0 ; nGeral := 0
			
			for i := 1 to Len(aIncSist)
				@nLin,000 psay aIncSist[i][1]+"-"+IIf(SX5->(DbSeek(xFilial("SX5")+"GG"+aIncSist[i][1],.F.)),Left(SX5->X5_DESCRI,30),"")
				@nLin,039 psay U_ConvData(aIncSist[i][2],"yy")
				@nLin,053 psay Transf(aIncSist[i][3],"@E 999,999,999.99")
//				@nLin,067 psay Transf(aIncSist[i][4],"@E 999,999,999.99")
//				@nLin,084 psay Transf(aIncSist[i][5],"@E 999,999,999.99")
				@nLin,072 psay Transf(aIncSist[i][6],"@E 999,999,999.99")
//				@nLin,101 psay Transf(aIncSist[i][6],"@E 999,999,999.99")
				@nLin,091 psay Transf(aIncSist[i][7],"@E 999,999,999.99")
				
				nOrcam += aIncSist[i][3]
				nRevis += aIncSist[i][4]
				nReali += aIncSist[i][5]
				nEmpenha += aIncSist[i][6]
				nGeral += aIncSist[i][7] 
				
				nTotOrcam += aIncSist[i][3]
				nTotRevis += aIncSist[i][4]
				nTotReali += aIncSist[i][5]
				nTotEmpenha += aIncSist[i][6]
				nTotGeral += aIncSist[i][7]
				nLin++
				
				U_SaltaFolha()
			next
			
			@nLin,000 psay "TOTAL"
			@nLin,053 psay Transf(nOrcam,"@E 999,999,999.99")
//			@nLin,067 psay Transf(nRevis,"@E 999,999,999.99")
//			@nLin,084 psay Transf(nReali,"@E 999,999,999.99")
//			@nLin,101 psay Transf(nEmpenha,"@E 999,999,999.99")
			@nLin,072 psay Transf(nEmpenha,"@E 999,999,999.99")
			@nLin,091 psay Transf(nGeral,"@E 999,999,999.99")
			
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay Replicate("-",132)
			
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay "TOTAL GERAL"
			@nLin,053 psay Transf(nTotOrcam,"@E 999,999,999.99")
//			@nLin,067 psay Transf(nTotRevis,"@E 999,999,999.99")
//			@nLin,084 psay Transf(nTotReali,"@E 999,999,999.99")
//			@nLin,101 psay Transf(nTotEmpenha,"@E 999,999,999.99")
			@nLin,072 psay Transf(nTotEmpenha,"@E 999,999,999.99")
			@nLin,091 psay Transf(nTotGeral,"@E 999,999,999.99")
		endif
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

//**************************************************************\\
// Impressao por Ordem de Compra                                \\
//**************************************************************\\
static function Impr1()
	local aIncSist := {}
	local aRealiProj := {}
	local aProjetos := {}
	local aTempStru := {}
	local aProjMae := {}
	local cArqTrab1
	
	cQry := "select SZ3.Z3_NUM, SZ3.Z3_PROJETO, SZ3.Z3_DESCPRO, SZ3.Z3_CLIENTE, SZ3.Z3_LOJA, SZ3.Z3_DESCCLI, SZ4.Z4_GGRUPO, SZ4.Z4_GRUPO, SZ4.Z4_DESCGRP, SZ4.Z4_DTORCAM, SZ4.Z4_VLORCAM, SZ4.Z4_VLREVIS, SZ4.Z4_VLREALI, SZ4.Z4_EMPENHA, SZ4.Z4_SALDO, SZ4.Z4_INCSIST, SZ3.Z3_PRJMAE "
	cQry += "from "+RetSqlName("SZ3")+" SZ3 inner join "+RetSqlName("SZ4")+" SZ4 on (SZ3.Z3_NUM = SZ4.Z4_NUM and SZ3.Z3_PROJETO = SZ4.Z4_PROJETO) "
//	cQry += "where (SZ3.Z3_NUM between '"+cOcIni+"' and '"+cOcFin+"') and SZ3.D_E_L_E_T_ <> '*' and SZ4.D_E_L_E_T_ <> '*' "
	cQry += "where SZ3.Z3_NUM = '"+cOcIni+"' and SZ3.D_E_L_E_T_ <> '*' and SZ4.D_E_L_E_T_ <> '*' "
	cQry += "order by SZ4.Z4_GGRUPO"
	
	tcquery cQry new alias "QTRB"
	
	DbSelectArea("QTRB")
	ProcRegua(QTRB->(LastRec()))
	QTRB->(DbGoTop())
	
	while !QTRB->(Eof())
		if QTRB->Z3_PRJMAE == "T"
			if (nInd := AScan(aProjMae,{|x| x[1] = QTRB->Z3_PROJETO})) == 0
				AAdd(aProjMae,{QTRB->Z3_PROJETO,AllTrim(QTRB->Z3_DESCPRO),AllTrim(QTRB->Z3_DESCCLI),IIf(CTH->(DbSeek(xFilial("CTH")+QTRB->Z3_PROJETO,.F.)),DToS(CTH->CTH_DTENTR)," "),QTRB->Z3_NUM,QTRB->Z4_EMPENHA})
			else
				aProjMae[nInd][6] += QTRB->Z4_EMPENHA
			endif
		else
			if (nInd := AScan(aProjetos,{|x| x[1] = QTRB->Z3_PROJETO})) == 0
				AAdd(aProjetos,{QTRB->Z3_PROJETO,AllTrim(QTRB->Z3_DESCPRO),QTRB->Z4_DTORCAM,QTRB->Z4_VLORCAM,QTRB->Z4_VLREVIS,QTRB->Z4_VLREALI,QTRB->Z4_EMPENHA,QTRB->Z4_SALDO})
			else
				aProjetos[nInd][4] += QTRB->Z4_VLORCAM
				aProjetos[nInd][5] += QTRB->Z4_VLREVIS
				aProjetos[nInd][6] += QTRB->Z4_VLREALI
				aProjetos[nInd][7] += QTRB->Z4_EMPENHA
				aProjetos[nInd][8] += QTRB->Z4_SALDO
			endif
		endif
		
		if (nInd := AScan(aRealiProj,{|x| x[1] = QTRB->Z4_GGRUPO})) == 0
			AAdd(aRealiProj,{QTRB->Z4_GGRUPO,QTRB->Z4_DTORCAM,QTRB->Z4_VLORCAM,QTRB->Z4_VLREVIS,QTRB->Z4_VLREALI,QTRB->Z4_EMPENHA,QTRB->Z4_SALDO,QTRB->Z4_INCSIST})
		else
			aRealiProj[nInd][3] += QTRB->Z4_VLORCAM
			aRealiProj[nInd][4] += QTRB->Z4_VLREVIS
			aRealiProj[nInd][5] += QTRB->Z4_VLREALI
			aRealiProj[nInd][6] += QTRB->Z4_EMPENHA
			aRealiProj[nInd][7] += QTRB->Z4_SALDO
		endif
		
		IncProc()
		QTRB->(DbSkip())
	enddo
	
	Cabec1 := PadC("O.C. "+AllTrim(aProjMae[1][5]),130)
	Cabec2 := ""
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	PROJETO PRINCIPAL                                                                          FORNECEDOR                      ENTREGAR
//	999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99/99/99
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	nLin++
	
	@nLin,000 psay "PROJETO.: "+Left(aProjMae[1][1],6)+" - "+Left(aProjMae[1][2],80)
	@++nLin,000 psay "CLIENTE.: "+Left(aProjMae[1][3],30)
	@++nLin,000 psay "ENTREGAR: "+U_ConvData(aProjMae[1][4])
	
	nLin += 2
	nTotOrcam := 0 ; nTotGeral := 0 ; nTotRevis := 0 ; nTotReali := 0 ; nTotEmpenha := 0
	
	U_SaltaFolha()
	
	@nLin,000 psay "GRUPO                                  DT ORCAM            VL ORCAM       VL REALIZADO           VL SALDO"
	@++nLin,000 psay "---------------------------------------------------------------------------------------------------------"
	
	nLin++
	
	for i := 1 to Len(aRealiProj)
//		GRUPO                                  DT ORCAM            VL ORCAM       VL REALIZADO           VL SALDO
//		99999-999999999999999999999999999999   99/99/99      999,999,999.99     999,999,999.99     999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay aRealiProj[i][1]+"-"+IIf(SX5->(DbSeek(xFilial("SX5")+"GG"+aRealiProj[i][1],.F.)),Left(SX5->X5_DESCRI,30),"")
		@nLin,039 psay U_ConvData(aRealiProj[i][2],"yy")
		@nLin,053 psay Transf(aRealiProj[i][3],"@E 999,999,999.99")
		@nLin,072 psay Transf(aRealiProj[i][6],"@E 999,999,999.99")
		@nLin,091 psay Transf(aRealiProj[i][7],"@E 999,999,999.99")
		
		nTotOrcam += aRealiProj[i][3]
		nTotRevis += aRealiProj[i][4]
		nTotReali += aRealiProj[i][5]
		nTotEmpenha += aRealiProj[i][6]
		nTotGeral += aRealiProj[i][7]
		
		U_SaltaFolha()
		IncProc()
		
		nLin++
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "---------------------------------------------------------------------------------------------------------"
//	@nLin,000 psay If(aReturn[5] == 1,__PrtThinLine(),Replicate("-",131))
//	@nLin,000 psay Replicate("-",136)
	@++nLin,000 psay "T O T A L  --->"
	@nLin,053 psay Transf(nTotOrcam,"@E 999,999,999.99")
//	@nLin,067 psay Transf(nTotRevis,"@E 999,999,999.99")
//	@nLin,084 psay Transf(nTotReali,"@E 999,999,999.99")
	@nLin,072 psay Transf(nTotEmpenha,"@E 999,999,999.99")
//	@nLin,101 psay Transf(nTotEmpenha,"@E 999,999,999.99")
	@nLin,091 psay Transf(nTotGeral,"@E 999,999,999.99")
	
	nLin += 3
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	@++nLin,000 psay PadC("PROJETOS RELACIONADOS",130)
	@++nLin,000 psay __PrtThinLine()
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "PROJETO PRINCIPAL                                                                                                      VL REALIZADO"
	
	nLin++
	
	@nLin,000 psay Left(aProjMae[1][1],6)+" - "+aProjMae[1][2]
	@nLin,117 psay Transf(aProjMae[1][6],"@E 999,999,999.99")
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "OUTROS PROJETOS                                                                                                        VL REALIZADO"
	
	nLin++
	nTotGeral := 0
	
	U_SaltaFolha()
	ASort(aProjetos,,,{|x,y| x[1] < y[1]})
		
	for i := 1 to Len(aProjetos)
//		PROJETO                                                                                                                VL REALIZADO
//		999999 - AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                            999,999,999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay Left(aProjetos[i][1],6)+" - "+Left(aProjetos[i][2],80)
		@nLin,117 psay Transf(aProjetos[i][7],"@E 999,999,999.99")
		
		nLin++
		nTotGeral += aProjetos[i][7]
		
		U_SaltaFolha()
	next
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "PROJETO PRINCIPAL...: "
	@nLin,025 psay Transf(aProjMae[1][6],"@E 999,999,999.99")
	@++nLin,000 psay "OUTROS PROJETOS.....: "
	@nLin,025 psay Transf(nTotGeral,"@E 999,999,999.99")
	@++nLin,000 psay "TOTAL GERAL.........:"
	@nLin,025 psay Transf(nTotGeral + aProjMae[1][6],"@E 999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	QTRB->(DbCloseArea())
return