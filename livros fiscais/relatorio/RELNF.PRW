/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 22/02/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de notas fiscais                              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _MES {"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}

user function RELNF()
	private aOrd    := {"Nota Fiscal"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELNF"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := ""
	private cString := "SD2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "G"
	private nTamanho := IIf(Tamanho == "G",220,132)
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= "(N) - Normal | (B) - Beneficiamento | (D) - Devolucao | (C) - Frete"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private nNotas := 0
	private cDtIni := ""
	private cDtFin := ""
	private cCliForIni := ""
	private cCliForFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Notas Fiscais (1-Entrada/2-Saida)                 ³
	//³ mv_par02 - Periodo de                                        ³
	//³ mv_par03 - Periodo ate                                       ³
	//³ mv_par04 - Client/Fornec de                                  ³
	//³ mv_par05 - Client/Fornec ate                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	nNotas := mv_par01
	cDtIni := DToS(mv_par02)
	cDtFin := DToS(mv_par03)
	cCliForIni := mv_par04
	cCliForFin := mv_par05
	
	if nNotas == 1		//Entrada
		Processa({|| ImprEntrada()},"","Aguarde processando...",lAborta)
	else					//Saida
		Processa({|| ImprSaida()},"","Aguarde processando...",lAborta)
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

//********** Entrada **********\\
static function ImprEntrada()
	local aCFOP := {}
	local nQuant := 0, nGerQuant := 0, nTotQuant := 0
	local nTotal := 0, nGerTotal := 0, nTotTotal := 0
	local nIcms := 0, nGerIcms := 0, nTotIcms := 0
	local nIpi := 0, nGerIpi := 0, nTotIpi := 0
	local nPis := 0, nGerPis := 0, nTotPis := 0
	local nCofins := 0, nGerCofins := 0, nTotCofins := 0
	local nPeso := 0, nGerPeso := 0
	local nCont := 0, nGerCont := 0
	local nIss := 0, nGerIss := 0, nTotIss := 0
	local nTotAlqIcm := 0, nContAlqIcm := 0
	local nTotAlqIpi := 0, nContAlqIpi := 0
	
	cQry := "select D1_TIPO as TIPO, D1_DOC as DOC, D1_SERIE as SERIE, D1_EMISSAO as EMISSAO, D1_COD as COD, D1_DESCPRO as DESCRI, B1_POSIPI as NCM, D1_CF as CF, D1_CLASFIS as CLASFIS, D1_QUANT as QUANT, D1_VUNIT as PUNIT, (D1_TOTAL - D1_VALDESC + D1_SEGURO + D1_VALFRE + D1_DESPESA) as TOTAL, D1_VALICM as ICMS, D1_VALIPI as IPI, D1_VALIMP6 as PIS, D1_VALIMP5 as COFINS, D1_FORNECE as CLIEFOR, D1_LOJA as LOJA, F1_EST as EST, F4_TEXTO as NATUR, CTH.CTH_CLVL as CLVL, CTH.CTH_DESC01 as DESC01, SD1.D1_IPI as ALQIPI, D1_PICM as ALQICMS, D1_PEDIDO as PEDIDO, D1_CR as CR, D1_VALISS as ISS, F4_OPER as OPER, D1_DTDIGIT as DTDIGIT, D1_SEGURO as SEGURO, D1_VALFRE as FRETE, D1_DESPESA as DESPESA, B1_UM as UNID, F4_CREDICM as CREDICM, F4_LFICM as LFICM "
	cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SD1")+" SD1 on (SF1.F1_DOC = SD1.D1_DOC and SF1.F1_SERIE = SD1.D1_SERIE and SF1.F1_FORNECE = SD1.D1_FORNECE and SF1.F1_LOJA = SD1.D1_LOJA) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (SD1.D1_COD = SB1.B1_COD) "
	cQry += "	inner join "+RetSqlName("SF4")+" SF4 on (SD1.D1_TES = SF4.F4_CODIGO) "
	cQry += "	inner join "+RetSqlName("CTH")+" CTH on (SD1.D1_CLVL = CTH.CTH_CLVL) "
	cQry += "where (D1_DTDIGIT between '"+cDtIni+"' and '"+cDtFin+"') and (D1_FORNECE between '"+cCliForIni+"' and '"+cCliForFin+"') and F1_ESPECIE <> 'FAT' and SD1.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' and SF1.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' "
	cQry += "order by D1_DTDIGIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_CF"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	cDesc1  := "RELATORIO N.F. RECEBIDAS"
	Cabec1 := PadC("Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),nTamanho)
	Cabec2  := "TP DIA NOTA          CFOP  NATUREZA              CFIS CLIENTE/FORNECEDOR    UF PEDCOM                   QUANT                            TOTAL      %       ICMS      %        IPI        PIS     COFINS        ISS"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	@nLin,000 psay PadC("********** ENTRADAS **********",nTamanho)
	
	nLin += 2
	
	while !TEMP->(Eof())
		cMes := SubStr(TEMP->DTDIGIT,5,2)
		cAno := Left(TEMP->DTDIGIT,4)
		
		@nLin,000 psay _MES[Val(cMes)]+"/"+cAno
		
		nLin++
		
		while Left(TEMP->DTDIGIT,6) == cAno+cMes
//			TP DIA NOTA          CFOP  NATUREZA              CFIS CLIENTE/FORNECEDOR    UF PEDCOM                   QUANT                            TOTAL      %       ICMS      %        IPI        PIS     COFINS        ISS
//			A  99  999999999-AAA 9999  AAAAAAAAAAAAAAAAAAAA  999  AAAAAAAAAAAAAAAAAAAA  AA 999999         999,999,999.999               999,999,999,999.99 999.99 999,999.99 999.99 999,999.99 999,999.99 999,999.99 999,999.99
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
			
			if Right(AllTrim(TEMP->CF),3) $ "302" .and. TEMP->CREDICM == "N" .and. TEMP->LFICM == "N" ; TEMP->(DbSkip()) ; loop ; endif
			
			@nLin,000 psay TEMP->TIPO
			@nLin,003 psay Right(TEMP->DTDIGIT,2)
			@nLin,007 psay TEMP->DOC+"-"+TEMP->SERIE
			@nLin,021 psay Left(TEMP->CF,4)
			@nLin,027 psay TEMP->NATUR
			@nLin,049 psay TEMP->CLASFIS
			
			if TEMP->TIPO $ "B/D"
				@nLin,054 psay IIf(SA1->(DbSeek(xFilial("SA1")+TEMP->(CLIEFOR+LOJA),.F.)),Left(SA1->A1_NREDUZ,20),"")
			else
				@nLin,054 psay IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(CLIEFOR+LOJA),.F.)),Left(SA2->A2_NREDUZ,20),"")
			endif
			
			@nLin,076 psay TEMP->EST
			
			cNota := TEMP->(DOC+SERIE+CLIEFOR+LOJA)
			cCfop := TEMP->CF
			cOper := TEMP->OPER
			cPedido := TEMP->PEDIDO
			cUnid := TEMP->UNID
			
			while TEMP->(DOC+SERIE+CLIEFOR+LOJA) == cNota .and. TEMP->CF == cCfop
				if TEMP->PEDIDO <> cPedido
					cPedido := ""
				endif
				
				if (nInd := AScan(aCFOP,{|x| x[1] = Left(TEMP->CF,4)})) == 0
					AAdd(aCFOP,{Left(TEMP->CF,4),TEMP->QUANT,TEMP->TOTAL,IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS),TEMP->IPI,TEMP->PIS,TEMP->COFINS,0,TEMP->ISS,TEMP->NATUR,AllTrim(TEMP->OPER)})
				else
					aCFOP[nInd][2] += TEMP->QUANT 
					aCFOP[nInd][3] += TEMP->TOTAL
					aCFOP[nInd][4] += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					aCFOP[nInd][5] += TEMP->IPI
					aCFOP[nInd][6] += TEMP->PIS
					aCFOP[nInd][7] += TEMP->COFINS
					aCFOP[nInd][9] += TEMP->ISS
				endif
				
				if Left(cOper,1) $ "0/5"
					nTotQuant += TEMP->QUANT
					nTotTotal += TEMP->TOTAL
					nTotIcms += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					nTotIpi += TEMP->IPI
					nTotPis += TEMP->PIS
					nTotCofins += TEMP->COFINS
					nTotIss += TEMP->ISS
					
					if !Empty(TEMP->ALQICMS) .and. !(Right(AllTrim(TEMP->CF),3) $ "302/556")
						nTotAlqIcm += TEMP->ALQICMS 
						nContAlqIcm++
					endif
					
					if !Empty(TEMP->ALQIPI) 
						nTotAlqIpi := TEMP->ALQIPI
						nContAlqIpi++
					endif
					
					nQuant += TEMP->QUANT
					nTotal += TEMP->TOTAL
					nIcms += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					nIpi += TEMP->IPI
					nPis += TEMP->PIS
					nCofins += TEMP->COFINS
					nIss += TEMP->ISS
					
					nGerQuant += TEMP->QUANT
					nGerTotal += TEMP->TOTAL
					nGerIcms += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					nGerIpi += TEMP->IPI
					nGerPis += TEMP->PIS
					nGerCofins += TEMP->COFINS
					nGerIss += TEMP->ISS
				elseif Left(cOper,1) $ "2"
					nTotIcms += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					nTotIpi += TEMP->IPI
					nTotPis += TEMP->PIS
					nTotCofins += TEMP->COFINS
					nTotIss += TEMP->ISS
					
					if !Empty(TEMP->ALQICMS) .and. !(Right(AllTrim(TEMP->CF),3) $ "302/556")
						nTotAlqIcm += TEMP->ALQICMS 
						nContAlqIcm++
					endif
					
					if !Empty(TEMP->ALQIPI) 
						nTotAlqIpi := TEMP->ALQIPI
						nContAlqIpi++
					endif
					
					nIcms += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					nIpi += TEMP->IPI
					nPis += TEMP->PIS
					nCofins += TEMP->COFINS
					nIss += TEMP->ISS
					
					nGerIcms += IIf(Right(AllTrim(TEMP->CF),3) $ "302/556",0,TEMP->ICMS)
					nGerIpi += TEMP->IPI
					nGerPis += TEMP->PIS
					nGerCofins += TEMP->COFINS
					nGerIss += TEMP->ISS
				endif
				
				TEMP->(DbSkip())
			enddo
			
			@nLin,079 psay IIf(Empty(cPedido),Space(6),Left(cPedido,6))
			
			if !Empty(nTotQuant)
				@nLin,094 psay Transf(nTotQuant,"@E 999,999,999.999")
				@nLin,110 psay cUnid
			endif
			
			if !Empty(nTotTotal)
				if Left(cOper,1) <> "1"
					@nLin,124 psay Transf(nTotTotal,"@E 999,999,999,999.99")
				endif
			endif
			
			if !Empty(nTotIcms)
				@nLin,143 psay Transf(nTotAlqIcm / nContAlqIcm,"@E 999.99")
				@nLin,150 psay Transf(nTotIcms,"@E 999,999.99")
			endif
			
			if !Empty(nTotIpi)
				@nLin,161 psay Transf(nTotAlqIpi / nContAlqIpi,"@E 999.99")
				@nLin,168 psay Transf(nTotIpi,"@E 999,999.99")
			endif
			
			if !Empty(nTotPis)
				@nLin,179 psay Transf(nTotPis,"@E 999,999.99")
			endif
			
			if !Empty(nTotCofins)
				@nLin,190 psay Transf(nTotCofins,"@E 999,999.99")
			endif
			
			if !Empty(nTotIss)
				@nLin,201 psay Transf(nTotIss,"@E 999,999.99")
			endif
			
			nLin++
			nTotQuant := 0 ; nTotTotal := 0 ; nTotIcms := 0 ; nTotIpi := 0 ; nTotPis := 0 ; nTotCofins := 0 ; nTotIss := 0
			nTotAlqIcm := 0 ; nContAlqIcm := 0 ; nTotAlqIpi := 0 ; nContAlqIpi := 0
			
			if TEMP->(DOC+SERIE+CLIEFOR+LOJA) <> cNota
				nGerCont++
				nCont++
			endif
			
			if nLin >= 54
				@nLin,007 psay "TOTAL NF"
				@nLin,027 psay AllTrim(Transf(nCont,"@R 999999"))
				
				@nLin,094 psay IIf(!Empty(nQuant),Transf(nQuant,"@E 999,999,999.999")," ")
				@nLin,124 psay IIf(!Empty(nTotal),Transf(nTotal,"@E 999,999,999,999.99")," ")
				@nLin,150 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
				@nLin,168 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
				@nLin,179 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
				@nLin,190 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
				@nLin,201 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
				
				nQuant := 0 ; nTotal := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nPeso := 0 ; nIss := 0 ; nCont := 0
				nLin++
				
				U_SaltaFolha()
				
				nLin++
			endif
			
			U_SaltaFolha()
			IncProc()
		enddo
		
		if nLin > 9
			@nLin,007 psay "TOTAL NF"
			@nLin,027 psay AllTrim(Transf(nCont,"@R 999999"))
			
			@nLin,094 psay IIf(!Empty(nQuant),Transf(nQuant,"@E 999,999,999.999")," ")
			@nLin,124 psay IIf(!Empty(nTotal),Transf(nTotal,"@E 999,999,999,999.99")," ")
			@nLin,150 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
			@nLin,168 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
			@nLin,179 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
			@nLin,190 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
			@nLin,201 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
			
			nLin++
			
			U_SaltaFolha()
		endif
		
		nQuant := 0 ; nTotal := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nPeso := 0 ; nIss := 0 ; nCont := 0
		
		@nLin,007 psay "TOTAL GERAL NF"
		@nLin,027 psay AllTrim(Transf(nGerCont,"@R 999999"))
		
		@nLin,094 psay IIf(!Empty(nGerQuant),Transf(nGerQuant,"@E 999,999,999.999")," ")
		@nLin,124 psay IIf(!Empty(nGerTotal),Transf(nGerTotal,"@E 999,999,999,999.99")," ")
		@nLin,150 psay IIf(!Empty(nGerIcms),Transf(nGerIcms,"@E 999,999.99")," ")
		@nLin,168 psay IIf(!Empty(nGerIpi),Transf(nGerIpi,"@E 999,999.99")," ")
		@nLin,179 psay IIf(!Empty(nGerPis),Transf(nGerPis,"@E 999,999.99")," ")
		@nLin,190 psay IIf(!Empty(nGerCofins),Transf(nGerCofins,"@E 999,999.99")," ")
		@nLin,201 psay IIf(!Empty(nGerIss),Transf(nGerIss,"@E 999,999.99")," ")
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	@nLin,000 psay PadC("****** RESUMO CFOP ******",138)
	
	nLin += 2
	
	@nLin,000 psay "CFOP                                 QUANT               TOTAL        ICMS         IPI         PIS      COFINS         ISS             PESO"
	
	nLin++
	nTotQuant := 0 ; nTotTotal := 0 ; nTotPeso := 0 ; nTotIcms := 0 ; nTotIpi := 0 ; nTotPis := 0 ; nTotCofins := 0 ; nTotIss := 0
	lItem08 := .F.
	
	ASort(aCFOP,,,{|x,y| x[1] < y[1]})
	
	for i := 1 to Len(aCFOP)
//		CFOP                                 QUANT               TOTAL        ICMS         IPI         PIS      COFINS         ISS             PESO
//		9999 AAAAAAAAAAAAAAAAAAAA  999,999,999.999  999,999,999,999.99  999,999.99  999,999.99  999,999.99  999,999.99  999,999.99  999,999,999.999
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
		if aCFOP[i][11] <> "08"
			@nLin,000 psay aCFOP[i][1]
			@nLin,005 psay aCFOP[i][10]
			@nLin,027 psay IIf(!Empty(aCFOP[i][2]),Transf(aCFOP[i][2],"@E 999,999,999.999")," ")
			@nLin,044 psay IIf(!Empty(aCFOP[i][3]),Transf(aCFOP[i][3] + aCFOP[i][5],"@E 999,999,999,999.99")," ")
			@nLin,064 psay IIf(!Empty(aCFOP[i][4]),Transf(aCFOP[i][4],"@E 999,999.99")," ")
			@nLin,076 psay IIf(!Empty(aCFOP[i][5]),Transf(aCFOP[i][5],"@E 999,999.99")," ")
			@nLin,088 psay IIf(!Empty(aCFOP[i][6]),Transf(aCFOP[i][6],"@E 999,999.99")," ")
			@nLin,100 psay IIf(!Empty(aCFOP[i][7]),Transf(aCFOP[i][7],"@E 999,999.99")," ")
			@nLin,112 psay IIf(!Empty(aCFOP[i][9]),Transf(aCFOP[i][9],"@E 999,999.99")," ")
			@nLin,124 psay IIf(!Empty(aCFOP[i][8]),Transf(aCFOP[i][8],"@E 999,999,999.999")," ")
			
			if Left(aCFOP[i][11],1) $ "0/5"
				nQuant += aCFOP[i][2]
				nTotal += aCFOP[i][3]
				nPeso += aCFOP[i][8]
				nTotQuant += aCFOP[i][2]
				nTotTotal += aCFOP[i][3]
				nTotPeso += aCFOP[i][8]
			endif
			
			nIcms += aCFOP[i][4]
			nIpi += aCFOP[i][5]
			nPis += aCFOP[i][6]
			nCofins += aCFOP[i][7]
			nIss += aCFOP[i][9]
			nTotIcms += aCFOP[i][4]
			nTotIpi += aCFOP[i][5]
			nTotPis += aCFOP[i][6]
			nTotCofins += aCFOP[i][7]
			nTotIss += aCFOP[i][9]
			
			nLin++
			
			U_SaltaFolha()
		else
			lItem08 := .T.
		endif
	next
	
	@nLin,005 psay "TOTAL"
	@nLin,027 psay IIf(!Empty(nQuant),Transf(nQuant,"@E 999,999,999.999")," ")
	@nLin,044 psay IIf(!Empty(nTotal),Transf(nTotal + nIpi,"@E 999,999,999,999.99")," ")
	@nLin,064 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
	@nLin,076 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
	@nLin,088 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
	@nLin,100 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
	@nLin,112 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
	@nLin,124 psay IIf(!Empty(nPeso),Transf(nPeso,"@E 999,999,999.999")," ")
	
	if lItem08
		nLin += 2
		nQuant := 0 ; nTotal := 0 ; nPeso := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nIss := 0
		
		U_SaltaFolha()
		
		for i := 1 to Len(aCFOP)
			if aCFOP[i][11] == "08"
				@nLin,000 psay aCFOP[i][1]
				@nLin,005 psay aCFOP[i][10]
				@nLin,027 psay IIf(!Empty(aCFOP[i][2]),Transf(aCFOP[i][2],"@E 999,999,999.999")," ")
				@nLin,044 psay IIf(!Empty(aCFOP[i][3]),Transf(aCFOP[i][3] + aCFOP[i][5],"@E 999,999,999,999.99")," ")
				@nLin,064 psay IIf(!Empty(aCFOP[i][4]),Transf(aCFOP[i][4],"@E 999,999.99")," ")
				@nLin,076 psay IIf(!Empty(aCFOP[i][5]),Transf(aCFOP[i][5],"@E 999,999.99")," ")
				@nLin,088 psay IIf(!Empty(aCFOP[i][6]),Transf(aCFOP[i][6],"@E 999,999.99")," ")
				@nLin,100 psay IIf(!Empty(aCFOP[i][7]),Transf(aCFOP[i][7],"@E 999,999.99")," ")
				@nLin,112 psay IIf(!Empty(aCFOP[i][9]),Transf(aCFOP[i][9],"@E 999,999.99")," ")
				@nLin,124 psay IIf(!Empty(aCFOP[i][8]),Transf(aCFOP[i][8],"@E 999,999,999.999")," ")
				
				if Left(aCFOP[i][11],1) $ "0/5"
					nQuant += aCFOP[i][2]
					nTotal += aCFOP[i][3]
					nPeso += aCFOP[i][8]
					nTotQuant += aCFOP[i][2]
					nTotTotal += aCFOP[i][3]
					nTotPeso += aCFOP[i][8]
				endif
				
				nIcms += aCFOP[i][4]
				nIpi += aCFOP[i][5]
				nPis += aCFOP[i][6]
				nCofins += aCFOP[i][7]
				nIss += aCFOP[i][9]
				nTotIcms += aCFOP[i][4]
				nTotIpi += aCFOP[i][5]
				nTotPis += aCFOP[i][6]
				nTotCofins += aCFOP[i][7]
				nTotIss += aCFOP[i][9]
				
				nLin++
				
				U_SaltaFolha()
			endif
		next
		
		@nLin,005 psay "TOTAL"
		@nLin,027 psay IIf(!Empty(nQuant),Transf(nQuant,"@E 999,999,999.999")," ")
		@nLin,044 psay IIf(!Empty(nTotal),Transf(nTotal + nIpi,"@E 999,999,999,999.99")," ")
		@nLin,064 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
		@nLin,076 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
		@nLin,088 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
		@nLin,100 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
		@nLin,112 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
		@nLin,124 psay IIf(!Empty(nPeso),Transf(nPeso,"@E 999,999,999.999")," ")
	endif
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,005 psay "TOTAL GERAL"
	@nLin,027 psay IIf(!Empty(nTotQuant),Transf(nTotQuant,"@E 999,999,999.999")," ")
	@nLin,044 psay IIf(!Empty(nTotTotal),Transf(nTotTotal + nTotIpi,"@E 999,999,999,999.99")," ")
	@nLin,064 psay IIf(!Empty(nTotIcms),Transf(nTotIcms,"@E 999,999.99")," ")
	@nLin,076 psay IIf(!Empty(nTotIpi),Transf(nTotIpi,"@E 999,999.99")," ")
	@nLin,088 psay IIf(!Empty(nTotPis),Transf(nTotPis,"@E 999,999.99")," ")
	@nLin,100 psay IIf(!Empty(nTotCofins),Transf(nTotCofins,"@E 999,999.99")," ")
	@nLin,112 psay IIf(!Empty(nTotIss),Transf(nTotIss,"@E 999,999.99")," ")
	@nLin,124 psay IIf(!Empty(nTotPeso),Transf(nTotPeso,"@E 999,999,999.999")," ")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return

//********** Saida **********\\
static function ImprSaida()
	local aCFOP := {}
	local nQuant := 0, nGerQuant := 0, nTotQuant := 0
	local nTotal := 0, nGerTotal := 0, nTotTotal := 0
	local nIcms := 0, nGerIcms := 0, nTotIcms := 0
	local nIpi := 0, nGerIpi := 0, nTotIpi := 0
	local nPis := 0, nGerPis := 0, nTotPis := 0
	local nCofins := 0, nGerCofins := 0, nTotCofins := 0
	local nPeso := 0, nGerPeso := 0, nTotPeso := 0
	local nCont := 0, nGerCont := 0, nTotCont := 0
	local nIss := 0, nGerIss := 0, nTotIss := 0
	local nTotAlqIcms := 0, nTotAlqIpi := 0, nContAlqIpi := 0, nContAlqIcm := 0
	
	cQry := "select D2_TIPO as TIPO, D2_DOC as DOC, D2_SERIE as SERIE, D2_EMISSAO as EMISSAO, D2_COD as COD, C6_DESCRI as DESCRI, B1_POSIPI as NCM, D2_CF as CF, D2_CLASFIS as CLASFIS, D2_QUANT as QUANT, D2_PRCVEN as PUNIT, (D2_TOTAL + D2_VALIPI + D2_SEGURO + D2_VALFRE + D2_DESPESA) as TOTAL, D2_VALICM as ICMS, D2_VALIPI as IPI, D2_VALIMP6 as PIS, D2_VALIMP5 as COFINS, C5_PESOL as PESOL, D2_CLIENTE as CLIEFOR, D2_LOJA as LOJA, F2_EST as EST, F4_TEXTO as NATUR, CTH.CTH_CLVL as CLVL, CTH.CTH_DESC01 as DESC01, SD2.D2_IPI as ALQIPI, D2_PICM as ALQICMS, D2_VALISS as ISS, F4_OPER as OPER, D2_SEGURO as SEGURO, D2_VALFRE as FRETE, D2_DESPESA as DESPESA, B1_UM as UNID "
	cQry += "from "+RetSqlName("SF2")+" SF2 inner join "+RetSqlName("SD2")+" SD2 on (SF2.F2_DOC = SD2.D2_DOC and SF2.F2_SERIE = SD2.D2_SERIE and SF2.F2_CLIENTE = SD2.D2_CLIENTE and SF2.F2_LOJA = SD2.D2_LOJA) "
	cQry += "	inner join "+RetSqlName("SC6")+" SC6 on (SD2.D2_PEDIDO = SC6.C6_NUM and SD2.D2_ITEMPV = SC6.C6_ITEM) "
	cQry += "	inner join "+RetSqlName("SC5")+" SC5 on (SC6.C6_NUM = SC5.C5_NUM) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (SD2.D2_COD = SB1.B1_COD) "
	cQry += "	inner join "+RetSqlName("SF4")+" SF4 on (SD2.D2_TES = SF4.F4_CODIGO) "
	cQry += "	inner join "+RetSqlName("CTH")+" CTH on (SC6.C6_CLVL = CTH.CTH_CLVL) "
	cQry += "where (D2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (D2_CLIENTE between '"+cCliForIni+"' and '"+cCliForFin+"') and SF2.D_E_L_E_T_ <> '*' and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' and CTH.D_E_L_E_T_ <> '*' "
//	cQry += "order by D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_CF"
	cQry += "union all "
	cQry += "select distinct F2_TIPO as TIPO, F2_DOC as DOC, F2_SERIE as SERIE, F2_EMISSAO as EMISSAO, '' as COD, '' as DESCRI, '' as NCM, F3_CFO as CF, '' as CLASFIS, 0 as QUANT, 0 as PUNIT, 0 as TOTAL, 0 as ICMS, 0 as IPI, 0 as PIS, 0 as COFINS, 0 as PESOL, F2_CLIENTE as CLIEFOR, F2_LOJA as LOJA, F3_ESTADO as EST, '' as NATUR, '' as CLVL, '' as DESC01, 0 as ALQIPI, 0 as ALQICMS, 0 as ISS, '' as OPER, 0 as SEGURO, 0 as FRETE, 0 as DESPESA, '' as UNID "
	cQry += "from "+RetSqlName("SF2")+" SF2 inner join "+RetSqlName("SF3")+" SF3 on (F2_DOC = F3_NFISCAL and F2_SERIE = F3_SERIE and F2_CLIENTE = F3_CLIEFOR and F2_LOJA = F3_LOJA) "
	cQry += "where (F2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (F2_CLIENTE between '"+cCliForIni+"' and '"+cCliForFin+"') and F3_DTCANC <> '' and SF2.D_E_L_E_T_ = '*' and SF3.D_E_L_E_T_ <> '*' "
	cQry += "order by D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_CF"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	cDesc1  := "RELATORIO N.F. EMITIDAS"
	Cabec1 := PadC("Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),nTamanho)
	Cabec2  := "TP DIA NOTA          CFOP  NATUREZA              CFIS CLIENTE/FORNECEDOR    UF PROJETO           QUANT                            TOTAL      %       ICMS      %        IPI        PIS     COFINS        ISS            PESO"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	@nLin,000 psay PadC("********** SAIDAS **********",nTamanho)
	
	nLin += 2
	
	while !TEMP->(Eof())
		cMes := SubStr(TEMP->EMISSAO,5,2)
		cAno := Left(TEMP->EMISSAO,4)
		
		@nLin,000 psay _MES[Val(cMes)]+"/"+cAno
		
		nLin++
		
		while Left(TEMP->EMISSAO,6) == cAno+cMes
//			TP DIA NOTA          CFOP  NATUREZA              CFIS CLIENTE/FORNECEDOR    UF PROJETO           QUANT          UNIT              TOTAL      %       ICMS      %        IPI        PIS     COFINS        ISS            PESO
//			A  99  999999999-AAA 9999  AAAAAAAAAAAAAAAAAAAA  999  AAAAAAAAAAAAAAAAAAAA  AA 999999  999,999,999.999 9,999,999.999 999,999,999,999.99 999.99 999,999.99 999.99 999,999.99 999,999.99 999,999.99 999,999.99 999,999,999.999
//			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
			
			if Empty(TEMP->(COD+DESCRI+NCM+CLASFIS+NATUR+CLVL+DESC01+OPER))
				@nLin,000 psay TEMP->TIPO
				@nLin,003 psay Right(TEMP->EMISSAO,2)
				@nLin,007 psay TEMP->DOC+"-"+TEMP->SERIE
				@nLin,021 psay Left(TEMP->CF,4)
				@nLin,027 psay "NF CANCELADO"
				
				if TEMP->TIPO $ "B/D"
					@nLin,054 psay IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(CLIEFOR+LOJA),.F.)),Left(SA2->A2_NREDUZ,20),"")
				else
					@nLin,054 psay IIf(SA1->(DbSeek(xFilial("SA1")+TEMP->(CLIEFOR+LOJA),.F.)),Left(SA1->A1_NREDUZ,20),"")
				endif
				
				@nLin,076 psay TEMP->EST
				
				nLin++
				nCont++
				nGerCont++
				
				U_SaltaFolha()
				
				TEMP->(DbSkip())
				
				loop
			endif
			
			@nLin,000 psay TEMP->TIPO
			@nLin,003 psay Right(TEMP->EMISSAO,2)
			@nLin,007 psay TEMP->DOC+"-"+TEMP->SERIE
			@nLin,021 psay Left(TEMP->CF,4)
			@nLin,027 psay TEMP->NATUR
			@nLin,049 psay TEMP->CLASFIS
			
			if TEMP->TIPO $ "B/D"
				@nLin,054 psay IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(CLIEFOR+LOJA),.F.)),Left(SA2->A2_NREDUZ,20),"")
			else
				@nLin,054 psay IIf(SA1->(DbSeek(xFilial("SA1")+TEMP->(CLIEFOR+LOJA),.F.)),Left(SA1->A1_NREDUZ,20),"")
			endif
			
			@nLin,076 psay TEMP->EST
			@nLin,079 psay Left(TEMP->CLVL,6)
			
			cNota := TEMP->(DOC+SERIE+CLIEFOR+LOJA)
			cOper := TEMP->OPER
			cUnid := TEMP->UNID
			
			while TEMP->(DOC+SERIE+CLIEFOR+LOJA) == cNota
				if (nInd := AScan(aCFOP,{|x| x[1] = Left(TEMP->CF,4)})) == 0
					if Right(AllTrim(TEMP->CF),3) == "933"
						AAdd(aCFOP,{Left(TEMP->CF,4),TEMP->QUANT,TEMP->TOTAL,0,TEMP->IPI,TEMP->PIS,TEMP->COFINS,TEMP->PESOL,TEMP->ISS,TEMP->NATUR,AllTrim(TEMP->OPER)})
					else
						AAdd(aCFOP,{Left(TEMP->CF,4),TEMP->QUANT,TEMP->TOTAL,TEMP->ICMS,TEMP->IPI,TEMP->PIS,TEMP->COFINS,TEMP->PESOL,TEMP->ISS,TEMP->NATUR,AllTrim(TEMP->OPER)})
					endif
				else
					aCFOP[nInd][2] += TEMP->QUANT 
					aCFOP[nInd][3] += TEMP->TOTAL
					aCFOP[nInd][4] += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					aCFOP[nInd][5] += TEMP->IPI
					aCFOP[nInd][6] += TEMP->PIS
					aCFOP[nInd][7] += TEMP->COFINS
					aCFOP[nInd][8] += TEMP->PESOL
					aCFOP[nInd][9] += TEMP->ISS
				endif
				
				if Left(TEMP->OPER,1) $ "0/5"
					if !Empty(TEMP->ALQICMS) .and. !(Right(AllTrim(TEMP->CF),3) == "933")
						nTotAlqIcm += TEMP->ALQICMS 
						nContAlqIcm++
					endif
					
					if !Empty(TEMP->ALQIPI) 
						nTotAlqIpi := TEMP->ALQIPI
						nContAlqIpi++
					endif
					
					nTotQuant += TEMP->QUANT
					nTotTotal += TEMP->TOTAL
					nTotIcms += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					nTotIpi += TEMP->IPI
					nTotPis += TEMP->PIS
					nTotCofins += TEMP->COFINS
					nTotPeso += TEMP->PESOL
					nTotIss += TEMP->ISS
					
					nQuant += TEMP->QUANT
					nTotal += TEMP->TOTAL
					nIcms += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					nIpi += TEMP->IPI
					nPis += TEMP->PIS
					nCofins += TEMP->COFINS
					nPeso += TEMP->PESOL
					nIss += TEMP->ISS
					
					nGerQuant += TEMP->QUANT
					nGerTotal += TEMP->TOTAL
					nGerIcms += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					nGerIpi += TEMP->IPI
					nGerPis += TEMP->PIS
					nGerCofins += TEMP->COFINS
					nGerPeso += TEMP->PESOL
					nGerIss += TEMP->ISS
				elseif Left(TEMP->OPER,1) $ "7"
					if !Empty(TEMP->ALQICMS) .and. !(Right(AllTrim(TEMP->CF),3) == "933")
						nTotAlqIcm += TEMP->ALQICMS 
						nContAlqIcm++
					endif
					
					if !Empty(TEMP->ALQIPI) 
						nTotAlqIpi := TEMP->ALQIPI
						nContAlqIpi++
					endif
					
					nTotIcms += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					nTotIpi += TEMP->IPI
					nTotPis += TEMP->PIS
					nTotCofins += TEMP->COFINS
					nTotPeso += TEMP->PESOL
					nTotIss += TEMP->ISS
					
					nIcms += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					nIpi += TEMP->IPI
					nPis += TEMP->PIS
					nCofins += TEMP->COFINS
					nPeso += TEMP->PESOL
					nIss += TEMP->ISS
					
					nGerIcms += IIf(Right(AllTrim(TEMP->CF),3) == "933",0,TEMP->ICMS)
					nGerIpi += TEMP->IPI
					nGerPis += TEMP->PIS
					nGerCofins += TEMP->COFINS
					nGerPeso += TEMP->PESOL
					nGerIss += TEMP->ISS
				endif
				
				TEMP->(DbSkip())
			enddo
			
//			if !(Left(cOper,1) $ "6/7/8")
			if Left(cOper,1) $ "0/5"
				@nLin,087 psay Transf(nTotQuant,"@E 999,999,999.999")
				@nLin,103 psay cUnid
//				@nLin,103 psay Transf(TEMP->PUNIT,"@E 9,999,999.999")
				@nLin,117 psay Transf(nTotTotal,"@E 999,999,999,999.99")
			endif
			
			if !Empty(nTotAlqIcms)
				@nLin,136 psay Transf(nTotAlqIcms / nContAlqIcm,"@E 999.99")
				@nLin,143 psay Transf(nTotIcms,"@E 999,999.99")
			endif
			
			if !Empty(nTotAlqIpi)
				@nLin,154 psay Transf(nTotAlqIpi / nContAlqIpi,"@E 999.99")
				@nLin,161 psay Transf(nTotIpi,"@E 999,999.99")
			endif
			
			if !Empty(nTotPis)
				@nLin,172 psay Transf(nTotPis,"@E 999,999.99")
			endif
			
			if !Empty(nTotCofins)
				@nLin,183 psay Transf(nTotCofins,"@E 999,999.99")
			endif
			
			if !Empty(nTotIss)
				@nLin,194 psay Transf(nTotIss,"@E 999,999.99")
			endif
			
			if !Empty(nTotPeso)
				@nLin,205 psay Transf(nTotPeso,"@E 999,999,999.999")
			endif
			
			nGerCont++
			nCont++
			nLin++
			nTotQuant := 0 ; nTotTotal := 0 ; nTotIcms := 0 ; nTotIpi := 0 ; nTotPis := 0 ; nTotCofins := 0 ; nTotPeso := 0 ; nTotIss := 0 ; nTotAlqIpi := 0 ; nContAlqIpi := 0  ; nTotAlqIcms := 0 ; nContAlqIcm := 0
			
			if nLin >= 54
				@nLin,007 psay "TOTAL NF"
				@nLin,027 psay AllTrim(Transf(nCont,"@R 999999"))
				
				@nLin,087 psay Transf(nQuant,"@E 999,999,999.999")
				@nLin,117 psay Transf(nTotal,"@E 999,999,999,999.99")
				@nLin,143 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
				@nLin,161 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
				@nLin,172 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
				@nLin,183 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
				@nLin,194 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
				@nLin,205 psay IIf(!Empty(nPeso),Transf(nPeso,"@E 999,999,999.999")," ")
				
				nQuant := 0 ; nTotal := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nPeso := 0 ; nIss := 0 ; nCont := 0
				
				nLin++
				
				U_SaltaFolha()
				
				nLin++
			endif
			
			U_SaltaFolha()
			IncProc()
		enddo
		
		if nLin > 9
			@nLin,007 psay "TOTAL NF"
			@nLin,027 psay AllTrim(Transf(nCont,"@R 999999"))
			
			@nLin,087 psay Transf(nQuant,"@E 999,999,999.999")
			@nLin,117 psay Transf(nTotal,"@E 999,999,999,999.99")
			@nLin,143 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
			@nLin,161 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
			@nLin,172 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
			@nLin,183 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
			@nLin,194 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
			@nLin,205 psay IIf(!Empty(nPeso),Transf(nPeso,"@E 999,999,999.999")," ")
			
			nLin++
			
			U_SaltaFolha()
		endif
		
		nQuant := 0 ; nTotal := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nPeso := 0 ; nIss := 0 ; nCont := 0
		
		@nLin,007 psay "TOTAL GERAL NF"
		@nLin,027 psay AllTrim(Transf(nGerCont,"@R 999999"))
		
		@nLin,087 psay Transf(nGerQuant,"@E 999,999,999.999")
		@nLin,117 psay Transf(nGerTotal,"@E 999,999,999,999.99")
		@nLin,143 psay IIf(!Empty(nGerIcms),Transf(nGerIcms,"@E 999,999.99")," ")
		@nLin,161 psay IIf(!Empty(nGerIpi),Transf(nGerIpi,"@E 999,999.99")," ")
		@nLin,172 psay IIf(!Empty(nGerPis),Transf(nGerPis,"@E 999,999.99")," ")
		@nLin,183 psay IIf(!Empty(nGerCofins),Transf(nGerCofins,"@E 999,999.99")," ")
		@nLin,194 psay IIf(!Empty(nGerIss),Transf(nGerIss,"@E 999,999.99")," ")
		@nLin,205 psay IIf(!Empty(nGerPeso),Transf(nGerPeso,"@E 999,999,999.999")," ")
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	@nLin,000 psay PadC("****** RESUMO CFOP ******",138)
	
	nLin += 2
	
	@nLin,000 psay "CFOP                                 QUANT               TOTAL        ICMS         IPI         PIS      COFINS         ISS             PESO"
	
	nLin++
	nTotQuant := 0 ; nTotTotal := 0 ; nTotPeso := 0 ; nTotIcms := 0 ; nTotIpi := 0 ; nTotPis := 0 ; nTotCofins := 0 ; nTotIss := 0
	lItem57 := .F.
	
	ASort(aCFOP,,,{|x,y| x[1] < y[1]})
	
	for i := 1 to Len(aCFOP)
//		CFOP                                 QUANT               TOTAL        ICMS         IPI         PIS      COFINS         ISS             PESO
//		9999 AAAAAAAAAAAAAAAAAAAA  999,999,999.999  999,999,999,999.99  999,999.99  999,999.99  999,999.99  999,999.99  999,999.99  999,999,999.999
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
		
		if aCFOP[i][11] <> "57"
			@nLin,000 psay aCFOP[i][1]
			@nLin,005 psay aCFOP[i][10]
			@nLin,027 psay IIf(!Empty(aCFOP[i][2]),Transf(aCFOP[i][2],"@E 999,999,999.999")," ")
			@nLin,044 psay IIf(!Empty(aCFOP[i][3]),Transf(aCFOP[i][3] + aCFOP[i][5],"@E 999,999,999,999.99")," ")
			@nLin,064 psay IIf(!Empty(aCFOP[i][4]),Transf(aCFOP[i][4],"@E 999,999.99")," ")
			@nLin,076 psay IIf(!Empty(aCFOP[i][5]),Transf(aCFOP[i][5],"@E 999,999.99")," ")
			@nLin,088 psay IIf(!Empty(aCFOP[i][6]),Transf(aCFOP[i][6],"@E 999,999.99")," ")
			@nLin,100 psay IIf(!Empty(aCFOP[i][7]),Transf(aCFOP[i][7],"@E 999,999.99")," ")
			@nLin,112 psay IIf(!Empty(aCFOP[i][9]),Transf(aCFOP[i][9],"@E 999,999.99")," ")
			@nLin,124 psay IIf(!Empty(aCFOP[i][8]),Transf(aCFOP[i][8],"@E 999,999,999.999")," ")
			
			if Left(aCFOP[i][11],1) $ "0/5"
				nQuant += aCFOP[i][2]
				nTotal += aCFOP[i][3]
				nPeso += aCFOP[i][8]
				nTotQuant += aCFOP[i][2]
				nTotTotal += aCFOP[i][3]
				nTotPeso += aCFOP[i][8]
			endif
			
			nIcms += aCFOP[i][4]
			nIpi += aCFOP[i][5]
			nPis += aCFOP[i][6]
			nCofins += aCFOP[i][7]
			nIss += aCFOP[i][9]
			nTotIcms += aCFOP[i][4]
			nTotIpi += aCFOP[i][5]
			nTotPis += aCFOP[i][6]
			nTotCofins += aCFOP[i][7]
			nTotIss += aCFOP[i][9]
			
			nLin++
			
			U_SaltaFolha()
		else
			lItem57 := .T.
		endif
	next
	
	@nLin,005 psay "TOTAL"
	@nLin,027 psay IIf(!Empty(nQuant),Transf(nQuant,"@E 999,999,999.999")," ")
	@nLin,044 psay IIf(!Empty(nTotal),Transf(nTotal + nIpi,"@E 999,999,999,999.99")," ")
	@nLin,064 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
	@nLin,076 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
	@nLin,088 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
	@nLin,100 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
	@nLin,112 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
	@nLin,124 psay IIf(!Empty(nPeso),Transf(nPeso,"@E 999,999,999.999")," ")
	
	nQuant := 0 ; nTotal := 0 ; nPeso := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nIss := 0
	
	if lItem57
		nLin += 2
		nQuant := 0 ; nTotal := 0 ; nPeso := 0 ; nIcms := 0 ; nIpi := 0 ; nPis := 0 ; nCofins := 0 ; nIss := 0
		
		U_SaltaFolha()
		
		for i := 1 to Len(aCFOP)
			if aCFOP[i][11] == "57"
				@nLin,000 psay aCFOP[i][1]
				@nLin,005 psay aCFOP[i][10]
				@nLin,027 psay IIf(!Empty(aCFOP[i][2]),Transf(aCFOP[i][2],"@E 999,999,999.999")," ")
				@nLin,044 psay IIf(!Empty(aCFOP[i][3]),Transf(aCFOP[i][3] + aCFOP[i][5],"@E 999,999,999,999.99")," ")
				@nLin,064 psay IIf(!Empty(aCFOP[i][4]),Transf(aCFOP[i][4],"@E 999,999.99")," ")
				@nLin,076 psay IIf(!Empty(aCFOP[i][5]),Transf(aCFOP[i][5],"@E 999,999.99")," ")
				@nLin,088 psay IIf(!Empty(aCFOP[i][6]),Transf(aCFOP[i][6],"@E 999,999.99")," ")
				@nLin,100 psay IIf(!Empty(aCFOP[i][7]),Transf(aCFOP[i][7],"@E 999,999.99")," ")
				@nLin,112 psay IIf(!Empty(aCFOP[i][9]),Transf(aCFOP[i][9],"@E 999,999.99")," ")
				@nLin,124 psay IIf(!Empty(aCFOP[i][8]),Transf(aCFOP[i][8],"@E 999,999,999.999")," ")
				
				if Left(aCFOP[i][11],1) $ "0/5"
					nQuant += aCFOP[i][2]
					nTotal += aCFOP[i][3]
					nPeso += aCFOP[i][8]
					nTotQuant += aCFOP[i][2]
					nTotTotal += aCFOP[i][3]
					nTotPeso += aCFOP[i][8]
				endif
				
				nIcms += aCFOP[i][4]
				nIpi += aCFOP[i][5]
				nPis += aCFOP[i][6]
				nCofins += aCFOP[i][7]
				nIss += aCFOP[i][9]
				nTotIcms += aCFOP[i][4]
				nTotIpi += aCFOP[i][5]
				nTotPis += aCFOP[i][6]
				nTotCofins += aCFOP[i][7]
				nTotIss += aCFOP[i][9]
				
				nLin++
				
				U_SaltaFolha()
			endif
		next
		
		@nLin,005 psay "TOTAL"
		@nLin,027 psay IIf(!Empty(nQuant),Transf(nQuant,"@E 999,999,999.999")," ")
		@nLin,044 psay IIf(!Empty(nTotal),Transf(nTotal + nIpi,"@E 999,999,999,999.99")," ")
		@nLin,064 psay IIf(!Empty(nIcms),Transf(nIcms,"@E 999,999.99")," ")
		@nLin,076 psay IIf(!Empty(nIpi),Transf(nIpi,"@E 999,999.99")," ")
		@nLin,088 psay IIf(!Empty(nPis),Transf(nPis,"@E 999,999.99")," ")
		@nLin,100 psay IIf(!Empty(nCofins),Transf(nCofins,"@E 999,999.99")," ")
		@nLin,112 psay IIf(!Empty(nIss),Transf(nIss,"@E 999,999.99")," ")
		@nLin,124 psay IIf(!Empty(nPeso),Transf(nPeso,"@E 999,999,999.999")," ")
	endif
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,005 psay "TOTAL GERAL"
	@nLin,027 psay IIf(!Empty(nTotQuant),Transf(nTotQuant,"@E 999,999,999.999")," ")
	@nLin,044 psay IIf(!Empty(nTotTotal),Transf(nTotTotal + nTotIpi,"@E 999,999,999,999.99")," ")
	@nLin,064 psay IIf(!Empty(nTotIcms),Transf(nTotIcms,"@E 999,999.99")," ")
	@nLin,076 psay IIf(!Empty(nTotIpi),Transf(nTotIpi,"@E 999,999.99")," ")
	@nLin,088 psay IIf(!Empty(nTotPis),Transf(nTotPis,"@E 999,999.99")," ")
	@nLin,100 psay IIf(!Empty(nTotCofins),Transf(nTotCofins,"@E 999,999.99")," ")
	@nLin,112 psay IIf(!Empty(nTotIss),Transf(nTotIss,"@E 999,999.99")," ")
	@nLin,124 psay IIf(!Empty(nTotPeso),Transf(nTotPeso,"@E 999,999,999.999")," ")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return