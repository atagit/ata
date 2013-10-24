/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 11/08/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de apuração PIS/COFINS                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _TABELA {{"SD1","SA2"},{"SD2","SA1"}}
#define _CAMPOS {{"D1_DTDIGIT","D1_EMISSAO","D1_DOC","D1_SERIE","D1_ITEM","D1_FORNECE","D1_LOJA","D1_CF","D1_TOTAL","D1_VALIMP5","D1_VALIMP6","A2_COD","A2_LOJA","A2_NREDUZ"},;
				 {"D2_EMISSAO","D2_EMISSAO","D2_DOC","D2_SERIE","D2_ITEM","D2_CLIENTE","D2_LOJA","D2_CF","D2_TOTAL","D2_VALIMP5","D2_VALIMP6","A1_COD","A1_LOJA","A1_NREDUZ"}}

user function PISCOF()
	private aOrd    := {"Data de Digitacao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "PISCOF"
	private Cabec1  := "EMISSAO    | NOTA FISCAL   | ITM | CFOP | FORNECEDOR/CLIENTE             |              TOTAL |               PIS |            COFINS"
	private Cabec2  := ""
	private cDesc1  := "APURACAO PIS/COFINS"
	private ContFun := 0
	private cString := "SD1"
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
	private nTpApu := 0
	private nTpRes := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data de                                           ³
	//³ mv_par02 - Data ate                                          ³
	//³ mv_par03 - Apuracao (1-entrada/2-saida/3-ambos)              ³
	//³ mv_par04 - So Resumo (1-nao/2-sim)                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	nTpApu := mv_par03
	nTpRes := mv_par04
	
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
	local cQry := ""
	local nI := 0
	local nIni := 0
	local nFin := 0
	local nTotal, nPis, nCofins, nTotGeral, nTotPis, nTotCofins
	local nInd	:= 0
	local aTotGrpE := {}
	local aTotGrpS := {}
	local aSortE := {}
	local aSortTotGrpS := {}
	local aApuracao := {}
	
	nTotal := 0 ; nPis := 0 ; nCofins := 0 ; nTotGeral := 0 ; nTotPis := 0 ; nTotCofins := 0
	
	if nTpApu == 1		// Entrada
		nIni := 1
		nFin := 1
	elseif nTpApu == 2	// Saida
		nIni := 2
		nFin := 2
	else				// Ambos
		nIni := 1
		nFin := 2
	endif
	
	for nI := nIni to nFin
		cQry := "select "+_CAMPOS[nI][1]+" as DTDIGIT, "+_CAMPOS[nI][2]+" as EMISSAO, "+_CAMPOS[nI][3]+" as DOC, "+_CAMPOS[nI][4]+" as SERIE, right("+_CAMPOS[nI][5]+",2) as ITEM, "+_CAMPOS[nI][6]+"+'/'+"+_CAMPOS[nI][7]+" as CLIFOR, "+_CAMPOS[nI][8]+" as CFOP, "+_CAMPOS[nI][9]+" as TOTAL, "+_CAMPOS[nI][10]+" as PIS, "+_CAMPOS[nI][11]+" as COFINS, "+_CAMPOS[nI][14]+" as NREDUZ "
		cQry += "from "+RetSqlName(_TABELA[nI][1])+" TB1 inner join "+RetSqlName(_TABELA[nI][2])+" TB2 on ("+_CAMPOS[nI][6]+" = "+_CAMPOS[nI][12]+" and "+_CAMPOS[nI][7]+" = "+_CAMPOS[nI][13]+") "
		cQry += "where ("+_CAMPOS[nI][1]+" between '"+cDtIni+"' and '"+cDtFin+"') and "+_CAMPOS[nI][4]+" not like '%X%' and TB1.D_E_L_E_T_ <> '*' and TB2.D_E_L_E_T_ <> '*' "
		
		do case
			case nOrdem == 1
				cQry += "order by "+_CAMPOS[nI][2]+", "+_CAMPOS[nI][3]+", "+_CAMPOS[nI][4]+", "+_CAMPOS[nI][6]+", "+_CAMPOS[nI][7]+", "+_CAMPOS[nI][5]
		endcase
		
		tcquery cQry new alias "TEMP"
		DbSelectArea("TEMP")
		
		TEMP->(DbGoTop())
		ProcRegua(TEMP->(RecCount()))
		
		if nTpRes == 1
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			@nLin,000 psay U_Negrito(.T.)+Padc(If(nI == 1,"E N T R A D A","S A I D A"),136)+U_Negrito(.F.)
			
			nLin += 2
		endif
		
		while !TEMP->(Eof())
			cEmissao := TEMP->EMISSAO
			cDoc := TEMP->DOC
			cSerie := TEMP->SERIE
			cCliFor := TEMP->CLIFOR
			
			while TEMP->EMISSAO == cEmissao .and. TEMP->DOC == cDoc .and. TEMP->SERIE == cSerie .and. TEMP->CLIFOR == cCliFor
//			EMISSAO    | NOTA FISCAL   | ITM | CFOP | FORNECEDOR/CLIENTE             |              TOTAL |               PIS |            COFINS
//			99/99/9999   999999999 999   99    9999   999999/99 AAAAAAAAAAAAAAAAAAAA   999,999,999,999.99   99,999,999,999.99   99,999,999,999.99
//			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
				if nTpRes == 1
					@nLin,000 psay U_ConvData(TEMP->EMISSAO)
					@nLin,013 psay TEMP->DOC+" "+TEMP->SERIE
					@nLin,029 psay TEMP->ITEM
					@nLin,035 psay TEMP->CFOP
					@nLin,042 psay TEMP->CLIFOR+" "+TEMP->NREDUZ
					@nLin,075 psay Transf(TEMP->TOTAL,"@E 999,999,999,999.99")
					@nLin,096 psay Transf(TEMP->PIS,"@E 99,999,999,999.99")
					@nLin,116 psay Transf(TEMP->COFINS,"@E 99,999,999,999.99")
				endif
				
				nTotal += TEMP->TOTAL
				nPis += TEMP->PIS
				nCofins += TEMP->COFINS
				nTotGeral += TEMP->TOTAL
				nTotPis += TEMP->PIS
				nTotCofins += TEMP->COFINS
				nLin++
				
				if nI == 1
					if (nInd := AScan(aTotGrpE,{|x| x[1] = TEMP->CFOP})) == 0
						AAdd(aTotGrpE,{TEMP->CFOP,TEMP->TOTAL,TEMP->PIS,TEMP->COFINS})
					else
						aTotGrpE[nInd][2] += TEMP->TOTAL
						aTotGrpE[nInd][3] += TEMP->PIS
						aTotGrpE[nInd][4] += TEMP->COFINS
					endif
				elseif nI == 2
					if (nInd := AScan(aTotGrpS,{|x| x[1] = TEMP->CFOP})) == 0
						AAdd(aTotGrpS,{TEMP->CFOP,TEMP->TOTAL,TEMP->PIS,TEMP->COFINS})
					else
						aTotGrpS[nInd][2] += TEMP->TOTAL
						aTotGrpS[nInd][3] += TEMP->PIS
						aTotGrpS[nInd][4] += TEMP->COFINS
					endif
				endif
				
				if nLin >= 55 .and. nTpRes == 1
					U_Rdp(nRdpPag,cRdpLeg,Tamanho)
					U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
					
					nRdpPag++
				endif
				
				TEMP->(DbSkip())
			enddo
			
			if nTpRes == 1
				@nLin,075 psay Transf(nTotal,"@E 999,999,999,999.99")
				@nLin,096 psay Transf(nPis,"@E 99,999,999,999.99")
				@nLin,116 psay Transf(nCofins,"@E 99,999,999,999.99")
			endif
			
			nTotal := 0 ; nPis := 0 ; nCofins := 0
			nLin += 2
			
			if nLin >= 55 .and. nTpRes == 1
				U_Rdp(nRdpPag,cRdpLeg,Tamanho)
				U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
				
				nRdpPag++
			endif
			
			IncProc()
		enddo
		
		if nTpRes == 1
			@nLin,061 psay "TOTAL GERAL"
			@nLin,075 psay Transf(nTotGeral,"@E 999,999,999,999.99")
			@nLin,096 psay Transf(nTotPis,"@E 99,999,999,999.99")
			@nLin,116 psay Transf(nTotCofins,"@E 99,999,999,999.99")
		endif
		
		AAdd(aApuracao,{nTotGeral,nTotPis,nTotCofins})
		
		if nLin >= 55 .and. nTpRes == 1
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			nRdpPag++
		endif
		
		nTotGeral := 0 ; nTotPis := 0 ; nTotCofins := 0
		nLinAux := nLin
		
		TEMP->(DbCloseArea())
		
		if nTpRes == 1
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		endif
		
		nRdpPag++
	next
	
	nRdpPag := If(nTpRes == 1,1,nRdpPag)
	aSortE := ASort(aTotGrpE,,,{|x,y| x[1] < y[1]})
	aSortTotGrpS := ASort(aTotGrpS,,,{|x,y| x[1] < y[1]})
	
	nTam := If(Len(aTotGrpE) > Len(aTotGrpS),Len(aTotGrpE),Len(aTotGrpS))
	nTotGeralE := 0 ; nTotPisE := 0 ; nTotCofinsE := 0
	nTotGeralS := 0 ; nTotPisS := 0 ; nTotCofinsS := 0
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	@nLin,001 psay U_Negrito(.T.)+Padc("R E S U M O",136)+U_Negrito(.F.)
	
	nLin += 2
	
	@nLin  ,000 psay U_Negrito(.T.)+"ENTRADA"+U_Negrito(.F.)
	@nLin  ,077 psay U_Negrito(.T.)+"SAIDA"+U_Negrito(.F.)
	@++nLin,000 psay "CFOP              VALOR               PIS            COFINS"
	@nLin  ,075 psay "CFOP              VALOR               PIS            COFINS"
	
	for i := 1 to nTam
		nLin++
		
		if i <= Len(aSortE)
			@nLin,000 psay aSortE[i][1]
			@nLin,005 psay Transf(aSortE[i][2],"@E 999,999,999,999.99")
			@nLin,024 psay Transf(aSortE[i][3],"@E 99,999,999,999.99")
			@nLin,042 psay Transf(aSortE[i][4],"@E 99,999,999,999.99")
			
			nTotGeralE += aSortE[i][2]
			nTotPisE += aSortE[i][3]
			nTotCofinsE += aSortE[i][4]
		endif
		
		if i <= Len(aSortTotGrpS)
			@nLin,075 psay aSortTotGrpS[i][1]
			@nLin,080 psay Transf(aSortTotGrpS[i][2],"@E 999,999,999,999.99")
			@nLin,099 psay Transf(aSortTotGrpS[i][3],"@E 99,999,999,999.99")
			@nLin,117 psay Transf(aSortTotGrpS[i][4],"@E 99,999,999,999.99")
			
			nTotGeralS += aSortTotGrpS[i][2]
			nTotPisS += aSortTotGrpS[i][3]
			nTotCofinsS += aSortTotGrpS[i][4]
		endif
		
		U_SaltaFolha()
	next
	
	if nTpApu == 3
		nLin += 3
		
		@nLin,000 psay U_Negrito(.T.)+Padc("A P U R A C A O",136)+U_Negrito(.F.)
		
		nLin += 2
		
		@nLin  ,0000 psay "                  BASE CALC.            VLR PIS         VLR COFINS"
		@++nLin,000 psay "CREDITO.: "+Transf(aApuracao[1][1],"@E 999,999,999,999.99")+"  "+Transf(aApuracao[1][2],"@E 99,999,999,999.99")+"  "+Transf(aApuracao[1][3],"@E 99,999,999,999.99")
		@++nLin,000 psay "DEBITO..: "+Transf(aApuracao[2][1],"@E 999,999,999,999.99")+"  "+Transf(aApuracao[2][2],"@E 99,999,999,999.99")+"  "+Transf(aApuracao[2][3],"@E 99,999,999,999.99")
		@++nLin,000 psay "APURADO.: "+Transf(aApuracao[1][1] - aApuracao[2][1],"@E 999,999,999,999.99")+"  "+Transf(aApuracao[1][2] - aApuracao[2][2],"@E 99,999,999,999.99")+"  "+Transf(aApuracao[1][3] - aApuracao[2][3],"@E 99,999,999,999.99")
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
return