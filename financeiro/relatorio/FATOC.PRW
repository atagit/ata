/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/11/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de faturas por ordem de compra              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function FATOC()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "FATOC"
	private Cabec1  := ""
	private Cabec2  := "EMISSAO  | NOTA FISCAL | NATUREZA        |            PESO |              TOTAL | VENCTO   |          REALIZADO | DATA PAG | ATRASO"
	private cDesc1  := "FATURA POR O.C."
	private cString := "SE1"
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
	private cOcIFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Projeto de                                        ³
	//³ mv_par02 - Projeto ate                                       ³
	//³ mv_par03 - O.C. de                                           ³
	//³ mv_par04 - O.C. ate                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cPrjIni := mv_par01
	cPrjFin := mv_par02
	cOcIni := mv_par03
	cOcFin := mv_par04
	
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
	local cNatureza := ""
	local aNatureza := {}
	local cAF := ""
	local nPeso := 0
	local nValor := 0
	local nValTot := 0
	local nQuant := 0
	local nTotal := 0
	local nTotReg := 0
	
	cQry := "select E1_EMISSAO, E1_VENCREA, E1_CLVLCR, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_NATUREZ, E1_VALOR, E1_CLIENTE, E1_LOJA, A1_NREDUZ, CTH_AF, CTH_DTREAL, E1_VALLIQ, E1_FATURA, E1_BAIXA "
	cQry += "from "+RetSqlName("SE1")+" SE1 inner join "+RetSqlName("CTH")+" CTH on (E1_CLVLCR = CTH_CLVL) "
	cQry += "	inner join "+RetSqlName("SA1")+" SA1 on (CTH_CLIENT = A1_COD and CTH_LOJACL = A1_LOJA) "
	cQry += "where (CTH_AF between '"+cOcIni+"' and '"+cOcFin+"') and (CTH_CLVL between '"+cPrjIni+"' and '"+cPrjFin+"') and CTH_BLOQ <> '1' and SE1.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' "
	cQry += "order by E1_NUM, E1_PREFIXO"
	
	tcquery cQry new alias "TEMP"
	count to nTotReg
	
	DbSelectArea("TEMP")
	ProcRegua(nTotReg)
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cAF := TEMP->CTH_AF
		Cabec1 := PadC("O.C.: "+cAF+"          CLIENTE: "+AllTrim(TEMP->A1_NREDUZ)+"          VENC.: "+U_ConvData(CTH_DTREAL,"yy"),132)
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		while !TEMP->(Eof()) .and. TEMP->CTH_AF == cAF
//			EMISSAO  | NOTA FISCAL | NATUREZA        |           PESO |              TOTAL | VENCTO   |          REALIZADO | DATA PAG | ATRASO
//			99/99/99   999999999     AAAAAAAAAAAAAAA   999,999,999.99   999,999,999,999.99   99/99/99   999,999,999,999.99   99/99/99     9999
//			01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12
			
			if Empty(TEMP->E1_PARCELA) .and. !Empty(TEMP->E1_FATURA) ; TEMP->(DbSkip()) ; loop ; endif
			
			@nLin,000 psay U_ConvData(TEMP->E1_EMISSAO,"yy")
			@nLin,011 psay TEMP->E1_NUM
			
			do case
				case AllTrim(TEMP->E1_NATUREZ) $ "10101/10108"
					cNatureza := "10101"
					nPeso := IIf(SF2->(DbSeek(xFilial("SF2")+TEMP->E1_NUM+"U  "+TEMP->E1_CLIENTE+TEMP->E1_LOJA,.F.)),SF2->F2_PLIQUI,0)
					
					@nLin,025 psay "FATURAMENTO"
					@nLin,043 psay Transf(nPeso,"@E 999,999,999.99")
				case AllTrim(TEMP->E1_NATUREZ) $ "10504"
					cNatureza := "10504"
					
					@nLin,025 psay "ADIANTAMENTO"
					@nLin,043 psay " "
			endcase
			
			nValor := TEMP->E1_VALLIQ
			
			@nLin,060 psay Transf(TEMP->E1_VALOR,"@E 999,999,999,999.99")
			@nLin,081 psay U_ConvData(TEMP->E1_VENCREA,"yy")
			@nLin,092 psay Transf(nValor,"@E 999,999,999,999.99")
			@nLin,113 psay U_ConvData(TEMP->E1_BAIXA,"yy")
			
			if Empty(TEMP->E1_BAIXA)
				@nLin,126 psay Transf(dDataBase - SToD(TEMP->E1_VENCREA),"@R 9999")
			else
				@nLin,126 psay Transf(SToD(TEMP->E1_BAIXA) - SToD(TEMP->E1_VENCREA),"@R 9999")
			endif 
			
			if (nInd := AScan(aNatureza,{|x| x[1] == cNatureza})) == 0
				AAdd(aNatureza,{cNatureza,TEMP->E1_VALOR})
			else
				aNatureza[nInd][2] += TEMP->E1_VALOR
			endif
			
			nLin++
			nQuant += nPeso
			nTotal += nValor
			nValTot += TEMP->E1_VALOR
			nPeso := 0 ; nValor := 0
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		@nLin,025 psay "T O T A L"
		@nLin,043 psay Transf(nQuant,"@E 999,999,999.99")
		@nLin,060 psay Transf(nValTot,"@E 999,999,999,999.99")
		@nLin,092 psay Transf(nTotal,"@E 999,999,999,999.99")
		
		nLin += 3
		
		U_SaltaFolha()
		
//		AAAAAAAAA:           999,999,999,999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12
		
		@nLin,000 psay "                                  VALOR"
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "FATURADO.:"
		@nLin,021 psay Transf(nValTot,"@E 999,999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "RECEBIDO.:"
		@nLin,021 psay Transf(nTotal,"@E 999,999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "EM ABERTO:"
		@nLin,021 psay Transf(nValTot - nTotal,"@E 999,999,999,999.99")
		
		nLin += 2
		
		U_SaltaFolha()
		
		@nLin,000 psay __PrtThinLine()
		
		nLin++
		nQuantContrat := 0
		nValorContrat := 0
		
		U_SaltaFolha()
		
		DbSelectArea("SZM")
		SZM->(DbSetOrder(2))
		SZM->(DbGoTop())
		
		if SZM->(DbSeek(xFilial("SZM")+cAF,.F.))
			nQuantContrat += SZM->ZM_QUANT
			nValorContrat += SZM->ZM_TOTALG
		endif
		
//		                                   PESO                   VALOR
//		AAAAAAAA:                999,999,999.99      999,999,999,999.99
//		0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12
		
		@nLin,000 psay "                                   PESO                   VALOR"
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "CONTRATO:"
		@nLin,025 psay Transf(nQuantContrat,"@E 999,999,999.99")
		@nLin,045 psay Transf(nValorContrat,"@E 999,999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "ENTREGUE:"
		@nLin,025 psay Transf(nQuant,"@E 999,999,999.99")
		@nLin,045 psay Transf(nValTot,"@E 999,999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay "SALDO...:"
		@nLin,025 psay Transf(nQuantContrat - nQuant,"@E 999,999,999.99")
		@nLin,045 psay Transf(nValorContrat - nValTot,"@E 999,999,999,999.99")
		
/*		@nLin,011 psay "REALIZADO..:"
		@nLin,033 psay Transf(nQuant,"@E 999,999,999.99")
		@nLin,051 psay Transf(nTotal,"@E 999,999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		DbSelectArea("SZM")
		SZM->(DbSetOrder(2))
		SZM->(DbGoTop())
		
		if SZM->(DbSeek(xFilial("SZM")+cAF,.F.))
			@nLin,011 psay "ORCADO.....:"
			@nLin,033 psay Transf(SZM->ZM_QUANT,"@E 999,999,999.99")
			@nLin,051 psay Transf(SZM->ZM_TOTALG,"@E 999,999,999,999.99")
			
			nLin++
			
			U_SaltaFolha()
			
			@nLin,011 psay "PENDENTE...:"
			@nLin,033 psay Transf(SZM->ZM_QUANT - nQuant,"@E 999,999,999.99")
			@nLin,051 psay Transf(SZM->ZM_TOTALG - nTotal,"@E 999,999,999,999.99")
		endif*/
		
		nQuant := 0 ; nTotal := 0 ; nValTot := 0
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay __PrtThinLine()
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "NATUREZA                                TOTAL"
	
	nLin++
	
	U_SaltaFolha()
	
//	NATUREZA                                TOTAL
//	10101 AAAAAAAAAAAAAAA      999,999,999,999.99
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12
	
	nTotal := 0
	
	for i := 1 to Len(aNatureza)
		@nLin,000 psay AllTrim(aNatureza[i][1])
		
		do case
			case aNatureza[i][1] == "10101"
				@nLin,006 psay "FATURAMENTO"
			case aNatureza[i][1] == "10504"
				@nLin,006 psay "ADIANTAMENTO"
		endcase
		
		@nLin,027 psay Transf(aNatureza[i][2],"@E 999,999,999,999.99")
		
		nLin++
		nTotal += aNatureza[i][2]
		
		U_SaltaFolha()
	next
	
	@nLin,000 psay "T O T A L"
	@nLin,027 psay Transf(nTotal,"@E 999,999,999,999.99")
	
	TEMP->(DbCloseArea())
return