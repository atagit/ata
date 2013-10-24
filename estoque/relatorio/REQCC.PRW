/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/12/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relação requisicoes por centro de custos              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function REQCC()
	private aOrd    := {"Centro de Custos"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "REQCC"
//	private Cabec1  := "CENTRO DE CUSTOS"
//	private Cabec2  := "CODESP     PRODUTO                                                  |       QUANT |      ULT PRECO |              TOTAL"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "REQUISICAO POR C.C."
	private ContFun := 0
	private cString := "SD3"
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
	
	private cDtIni := ""
	private cDtFin := ""
	private cCCIni := ""
	private cCCFin := ""
	private cProdIni := ""
	private cProdFin := ""
	private cArmazIni := ""
	private cArmazFin := ""
	private cCodDesIni := ""
	private cCodDesFin := ""
	private nTipoRel := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data Emissao de                                   ³
	//³ mv_par02 - Data Emissao ate                                  ³
	//³ mv_par03 - C.C. de                                           ³
	//³ mv_par04 - C.C. ate                                          ³
	//³ mv_par05 - Produto de                                        ³
	//³ mv_par06 - Produto ate                                       ³
	//³ mv_par07 - Armazem de                                        ³
	//³ mv_par08 - Armazem ate                                       ³
	//³ mv_par09 - Cod Despesa de                                    ³
	//³ mv_par10 - Cod Despesa ate                                   ³
	//³ mv_par11 - Tipo (2-Sintetico/1-Analitico)                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cCCIni := mv_par03
	cCCFin := mv_par04
	cProdIni := mv_par05
	cProdFin := mv_par06
	cArmazIni := mv_par07
	cArmazFin := mv_par08
	cCodDesIni := mv_par09
	cCodDesFin := mv_par10
	nTipoRel := mv_par11
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
	
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

static function Impr()
	local nTotQuant := 0
	local nTotPreco := 0
	local nTotGeral := 0
	
/*	cQry := "select D3_TM, D3_CC, CTT_DESC01, D3_COD, D3_LOCAL, B1_DESC, B1_ULTPRC, sum(D3_QUANT) as D3_QUANT "
	cQry += "from "+RetSqlName("SD3")+" SD3 inner join "+RetSqlName("SB1")+" SB1 on (SD3.D3_COD = SB1.B1_COD and SD3.D3_LOCAL = SB1.B1_LOCPAD) "
	cQry += "	inner join "+RetSqlName("CTT")+" CTT on (SD3.D3_CC = CTT.CTT_CUSTO) "
	cQry += "where (D3_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (D3_CC between '"+cCCIni+"' and '"+cCCFin+"') and (D3_COD between '"+cProdIni+"' and '"+cProdFin+"') and (D3_LOCAL between '"+cArmazIni+"' and '"+cArmazFin+"') and D3_TM in ('499','501') and SD3.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and CTT.D_E_L_E_T_ <> '*' "
	cQry += "group by D3_TM, D3_CC, CTT_DESC01, D3_COD, D3_LOCAL, B1_DESC, B1_ULTPRC "
	cQry += "order by D3_CC, D3_COD, D3_LOCAL, D3_TM"*/
	
	cQry := "select D3_TM, D3_CC, CTT_DESC01, ZB_CODESP, ZB_DESC, D3_COD, D3_LOCAL, B1_DESC, B1_ULTPRC, sum(D3_QUANT) as D3_QUANT "
	cQry += "from "+RetSqlName("SD3")+" SD3 inner join "+RetSqlName("SB1")+" SB1 on (SD3.D3_COD = SB1.B1_COD and SD3.D3_LOCAL = SB1.B1_LOCPAD) "
	cQry += "	inner join "+RetSqlName("CTT")+" CTT on (SD3.D3_CC = CTT.CTT_CUSTO) "
	cQry += "	inner join "+RetSqlName("SZB")+" SZB on (SB1.B1_CODESP = SZB.ZB_CODESP) "
	cQry += "where (D3_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (D3_CC between '"+cCCIni+"' and '"+cCCFin+"') and (D3_COD between '"+cProdIni+"' and '"+cProdFin+"') and (D3_LOCAL between '"+cArmazIni+"' and '"+cArmazFin+"') and (ZB_CODESP between '"+cCodDesIni+"' and '"+cCodDesFin+"') and D3_TM in ('499','501') and D3_LOCAL <> '10' and D3_ESTORNO <> 'S' and SD3.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and CTT.D_E_L_E_T_ <> '*' "
	cQry += "group by ZB_CODESP, ZB_DESC, D3_TM, D3_CC, CTT_DESC01, ZB_CODESP, ZB_DESC, D3_COD, D3_LOCAL, B1_DESC, B1_ULTPRC "
	cQry += "order by D3_CC, ZB_CODESP, D3_COD, D3_LOCAL, D3_TM"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	cCbcRef := "Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	CENTRO DE CUSTOS
//	CODESP     PRODUTO                                                  |       QUANT |      ULT PRECO |              TOTAL
//	9999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	-----------------------------------------------------------------------------------------------------------------------
//	999.999    AAA999-99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA         99999999.99   999,999,999.99   999,999,999,999.99
//	                                                                      -------------------------------------------------
//	999.999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	nTotalQG := 0 ; nTotalVG := 0
	
	while !TEMP->(Eof())
		U_SaltaFolha()
		
		cCC := TEMP->D3_CC
		nTotQuant := 0 ; nTotPreco := 0 ; nTotGeral := 0
		nLin -= 2
		
		@nLin,000 psay AllTrim(TEMP->D3_CC)
		@nLin,005 psay Left(TEMP->CTT_DESC01,40)
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "======================================================================================================================="
		@++nLin,000 psay "CODESP  "+IIf(nTipoRel == 1,"DESCRICAO   ","    PRODUTO  ")+"                                                |       QUANT |      ULT PRECO |              TOTAL"
		@++nLin,000 psay "======================================================================================================================="
		
		nLin++
		
		U_SaltaFolha()
		
		while TEMP->D3_CC == cCC
			cGCodDesp := Left(TEMP->ZB_CODESP,2)
			nVCodDesp := 0 ; nQCodDesp := 0
			
			if nTipoRel == 1		//Sintetico
				while TEMP->D3_CC == cCC .and. Left(TEMP->ZB_CODESP,2) == cGCodDesp
					cCodDesp := TEMP->ZB_CODESP
					nTotalVG := 0 ; nTotalQG := 0
					
					DbSelectArea("SZB")
					SZB->(DbSetOrder(1))
					SZB->(DbGoTop())
					
					if SZB->(DbSeek(xFilial("SZB")+cCodDesp,.F.))
						@nLin,000 psay Trans(cCodDesp,"@R 999.999")
						@nLin,008 psay SZB->ZB_DESC
					endif
					
					while TEMP->D3_CC == cCC .and. Left(TEMP->ZB_CODESP,2) == cGCodDesp .and. TEMP->ZB_CODESP == cCodDesp
						nTotQuant += TEMP->D3_QUANT
						nTotPreco += TEMP->B1_ULTPRC
						nTotGeral += TEMP->D3_QUANT * TEMP->B1_ULTPRC
						nTotalQG += TEMP->D3_QUANT
						nTotalVG += TEMP->D3_QUANT * TEMP->B1_ULTPRC
						nQCodDesp += TEMP->D3_QUANT
						nVCodDesp += TEMP->D3_QUANT * TEMP->B1_ULTPRC
						
						IncProc()
						TEMP->(DbSkip())
					enddo
					
					@nLin,070 psay Trans(nTotalQG,"@E 99999999.99")
					@nLin,101 psay Trans(nTotalVG,"@E 999,999,999,999.99")
					
					nLin++
					
					U_SaltaFolha()
				enddo
			else					//Analitico
				while TEMP->D3_CC == cCC .and. Left(TEMP->ZB_CODESP,2) == cGCodDesp
					@nLin,000 psay Trans(TEMP->ZB_CODESP,"@R 999.999")
					@nLin,011 psay AllTrim(TEMP->D3_COD)+"-"+AllTrim(TEMP->D3_LOCAL)
					@nLin,021 psay Left(TEMP->B1_DESC,40)
					@nLin,070 psay Trans(TEMP->D3_QUANT,"@E 99999999.99")
					@nLin,084 psay Trans(TEMP->B1_ULTPRC,"@E 999,999,999.99")
					@nLin,101 psay Trans(TEMP->D3_QUANT * TEMP->B1_ULTPRC,"@E 999,999,999,999.99")
					
					nTotQuant += TEMP->D3_QUANT
					nTotPreco += TEMP->B1_ULTPRC
					nTotGeral += TEMP->D3_QUANT * TEMP->B1_ULTPRC
					nTotalQG += TEMP->D3_QUANT
					nTotalVG += TEMP->D3_QUANT * TEMP->B1_ULTPRC
					nQCodDesp += TEMP->D3_QUANT
					nVCodDesp += TEMP->D3_QUANT * TEMP->B1_ULTPRC
					
					nLin++
					
					U_SaltaFolha()
					IncProc()
					TEMP->(DbSkip())
				enddo
			endif
			
			@nLin,000 psay "-----------------------------------------------------------------------------------------------------------------------"
			
			nLin++
			
			U_SaltaFolha()
			DbSelectArea("SZB")
			SZB->(DbSetOrder(2))
			SZB->(DbGoTop())
			
			if SZB->(MsSeek(xFilial("SZB")+cGCodDesp+"1"))
				@nLin,000 psay Trans(SZB->ZB_CODESP,"@R 999.999")
				@nLin,008 psay SZB->ZB_DESC
				@nLin,070 psay Trans(nQCodDesp,"@E 99999999.99")
				@nLin,101 psay Trans(nVCodDesp,"@E 999,999,999,999.99")
				
				nLin++
				
				U_SaltaFolha()
				
				@nLin,000 psay "-----------------------------------------------------------------------------------------------------------------------"
			endif
			
			nLin++
			
			U_SaltaFolha()
		enddo
		
		@nLin,000 psay "======================================================================================================================="
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,070 psay Trans(nTotQuant,"@E 99999999.99")
		@nLin,101 psay Trans(nTotGeral,"@E 999,999,999,999.99")
		
		nLin := 60
	enddo
	
/*	nLin++
	
	U_SaltaFolha()
	
	@nLin,019 psay "TOTAL GERAL"
	@nLin,070 psay Trans(nTotalQG,"@E 99999999.99")
	@nLin,101 psay Trans(nTotalVG,"@E 999,999,999,999.99")*/
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return