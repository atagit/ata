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
	private Cabec2  := "EMISSAO    | PROJETO | NOTA FISCAL   | NATUREZA                  |           QUANT |              TOTAL"
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
	
	private nNuPor := 0
	private cPrjIni := ""
	private cPrjFin := ""
	private cOcIni := ""
	private cOcIFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Por (1-Projeto/2-O.C.)                            ³
	//³ mv_par02 - Projeto de                                        ³
	//³ mv_par03 - Projeto ate                                       ³
	//³ mv_par04 - O.C. de                                           ³
	//³ mv_par05 - O.C. ate                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	nNuPor := mv_par01
	cPrjIni := mv_par02
	cPrjFin := mv_par03
	cOcIni := mv_par04
	cOcFin := mv_par05
	
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
	local nTotReg := 0
	local nTotal := 0
	local nQuant := 0
	local nTgQuant := 0
	local nTgTotal := 0
	
	private nQuantOC := 0
	private nValorOC := 0
	private nQuantPJ := 0
	private nValorPJ := 0
	private cCliente := ""
	private cDtVenc := ""
	
	cQry := "select CTH_AF, C6_CLVL, D2_TIPO, D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, C5_PESOL, sum(D2_QUANT) as D2_QUANT, sum(D2_TOTAL) as D2_TOTAL "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SC6")+" SC6 on (SD2.D2_PEDIDO = SC6.C6_NUM) inner join "+RetSqlName("SC5")+" SC5 on (SC6.C6_NUM = SC5.C5_NUM) inner join "+RetSqlName("CTH")+" CTH on (SC6.C6_CLVL = CTH.CTH_CLVL) inner join "+RetSqlName("SF4")+" SF4 on (SD2.D2_TES = SF4.F4_CODIGO) "
	
	if nNuPor == 1
		cQry += "where (C6_CLVL between '"+cPrjIni+"' and '"+cPrjFin+"') and SF4.F4_DUPLIC = 'S' and SC6.C6_TPPROJE in ('0003','0005','0006','0007') and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
	else
		cQry += "where (CTH_AF between '"+cOcIni+"' and '"+cOcFin+"') and SF4.F4_DUPLIC = 'S' and SC6.C6_TPPROJE in ('0003','0005','0006','0007') and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
	endif
	
	cQry += "group by CTH_AF, C6_CLVL, D2_TIPO, D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, C5_PESOL "
	cQry += "order by CTH_AF, C6_CLVL, D2_EMISSAO, D2_DOC, D2_SERIE"
	
	tcquery cQry new alias "TEMP"
	count to nTotReg
	
	DbSelectArea("TEMP")
	ProcRegua(nTotReg)
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		if TEMP->D2_TIPO $ "B/D"
			cCliente := IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(D2_CLIENTE+D2_LOJA),.F.)),Left(SA2->A2_NREDUZ,30),"")
		else
			cCliente := IIf(SA1->(DbSeek(xFilial("SA1")+TEMP->(D2_CLIENTE+D2_LOJA),.F.)),Left(SA1->A1_NREDUZ,30),"")
		endif
		
		cAF := TEMP->CTH_AF
		Cabec1 := PadC("O.C.: "+cAF+"          CLIENTE: "+AllTrim(cCliente)+"          VENC.: "+U_ConvData(cDtVenc,"yy"),132)
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		while !TEMP->(Eof()) .and. TEMP->CTH_AF == cAF
			if CTH->(DbSeek(xFilial("CTH")+TEMP->C6_CLVL,.F.))
				nQuantPJ := CTH->CTH_PESAF
				nValorPJ := CTH->CTH_PESAF * CTH->CTH_VLAF
				cDtVenc := CTH->CTH_DTREAL
			endif
			
//			EMISSAO    | PROJETO | NOTA FISCAL   | NATUREZA                  |           QUANT |              TOTAL | VENCTO
//			99/99/9999   999999    999999999-999   AAAAAAAAAAAAAAAAAAAAAAAAA   999,999,999.999   999,999,999,999.99   99/99/99
//			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12
			
			@nLin,000 psay U_ConvData(TEMP->D2_EMISSAO)
			@nLin,013 psay Left(TEMP->C6_CLVL,6)
			@nLin,023 psay TEMP->D2_DOC+"-"+TEMP->D2_SERIE
			@nLin,039 psay "NOTA FISCAL"
			@nLin,067 psay Transf(TEMP->C5_PESOL,"@E 999,999,999.999")
			@nLin,085 psay Transf(TEMP->D2_TOTAL,"@E 999,999,999,999.99")
			
			cQry := "select E1_CLVLCR, E1_VALOR, E1_EMISSAO, E1_VENCREA, E1_NATUREZ, ED_DESCRIC "
			cQry += "from "+RetSqlName("SE1")+" SE1 inner join "+RetSqlName("SED")+" SED on (SE1.E1_NATUREZ = SED.ED_CODIGO) "
			cQry += "where E1_NUM = '"+TEMP->D2_DOC+"' and E1_FATURA = 'NOTFAT' and E1_CLIENTE = '"+TEMP->D2_CLIENTE+"' and E1_LOJA = '"+TEMP->D2_LOJA+"' and SE1.D_E_L_E_T_ <> '*' and SED.D_E_L_E_T_ <> '*' "
			cQry += "order by E1_PARCELA"
			
			tcquery cQry new alias "CON"
			
			DbSelectArea("CON")
			CON->(DbGoTop())
			
			if !CON->(Eof())
				while !CON->(Eof())
					nLin++
					
					@nLin,023 psay TEMP->D2_DOC+"-"+TEMP->D2_SERIE
					@nLin,039 psay CON->ED_DESCRIC
					@nLin,085 psay Transf(CON->E1_VALOR,"@E 999,999,999,999.99")
					@nLin,106 psay U_ConvData(CON->E1_VENCREA,"yy")
					
					CON->(DbSkip())
				enddo
			endif
			
			CON->(DbCloseArea())
			
			nQuant += TEMP->C5_PESOL
			nTotal += TEMP->D2_TOTAL
			
			nLin++
			
			U_SaltaFolha()
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		TotalOC(cAF)
		
		nLin += 2
		
		@nLin,014 psay "REALIZADO..:"
		@nLin,067 psay Transf(nQuant,"@E 999,999,999.999")
		@nLin,085 psay Transf(nTotal,"@E 999,999,999,999.99")
		
		nTgQuant += nQuant
		nTgTotal += nTotal
		
		nLin++
		
		@nLin,014 psay "ORCADO.....:"
		@nLin,067 psay Transf(nQuantPJ,"@E 999,999,999.999")
		@nLin,085 psay Transf(nValorPJ,"@E 999,999,999,999.99")
		
		nLin++
		
		@nLin,014 psay "PENDENTE...:"
		@nLin,067 psay Transf(nQuantPJ - nQuant,"@E 999,999,999.999")
		@nLin,085 psay Transf(nValorPJ - nTotal,"@E 999,999,999,999.99")
		
		nQuant := 0 ; nTotal := 0 ; nQuantPJ := 0 ; nTotalPJ := 0 ; nTgQuant := 0 ; nTgTotal := 0
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return

static function TotalOC(cOC)
	nQuantOC := 0
	nValorOC := 0
	
	cCon := "select sum(CTH_PESAF) as PESO, sum(CTH_VLAF) as VALOR, sum(CTH_PESAF * CTH_VLAF) as TOTAL from CTH010 where CTH_AF = '"+cOC+"' and D_E_L_E_T_ <> '*'"
	
	tcquery cCon new alias "CON"
	DbSelectArea("CON")
	
	nQuantOC := CON->PESO
	nValorOC := CON->TOTAL
	
	CON->(DbCloseArea())
return