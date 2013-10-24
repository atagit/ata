/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 28/03/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Demonstrativo gerencial de impostos                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _TAMQUAD 125
#define _ALQIRRF 15
#define _ALQCSLL 9

user function DEMONSTRA()
	private aOrd    	:= {}
	private aReturn 	:= {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   	:= "DEMGE"
	private Cabec1  	:= ""
	private Cabec2  	:= ""
	private cDesc1  	:= "DEMONSTRATIVO GERENCIAL DE IMPOSTOS"
	private ContFun 	:= 0
	private cString 	:= "SFT"
	private m_pag   	:= 1
	private nOrdem  	:= 0
	private nTipo   	:= 0
	private Tamanho 	:= "M"
	private Titulo  	:= cDesc1
	private wnrel   	:= FunName()
	private lAborta 	:= .T.
	private nPag		:= 1
	private nTamanho := IIf(Tamanho == "G",220,132)
	private lAborta := .T.
	
	private nLin		:= 014
	private cQry 		:= ""
	private nRdpPag	:= 1
	private nInd		:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa	:= SubStr(cNumEmp,1,2)
	
	private aContas := Array(11,4)
	private aTotContas := Array(1,2)
	private aImposto := Array(9,5)
	private aTotal := Array(6)
	
	private cDataDe := ""
	private cDataAte := ""
	private nMesAntICMS := 0
	private nMesAntIPI := 0
	private nMesAntPIS := 0
	private nMesAntCOFINS := 0
	private nMesAntISS := 0
	private nMesAntIRRF := 0
	private nMesAntCSLL := 0
	private nPenhoraICMS := 0
	private nPenhoraIPI := 0
	private nPenhoraPIS := 0
	private nPenhoraCOFINS := 0
	private nPenhoraISS := 0
	private nPenhoraIRRF := 0
	private nPenhoraCSLL := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Sld Mes Ant ICMS                                  ³
	//³ mv_par04 - Sld Mes Ant IPI                                   ³
	//³ mv_par05 - Sld Mes Ant PIS                                   ³
	//³ mv_par06 - Sld Mes Ant COFINS                                ³
	//³ mv_par07 - Sld Mes Ant ISS                                   ³
	//³ mv_par08 - Sld Mes Ant IRRF                                  ³
	//³ mv_par09 - Sld Mes Ant CSLL                                  ³
	//³ mv_par10 - Penhora ICMS                                      ³
	//³ mv_par11 - Penhora IPI                                       ³
	//³ mv_par12 - Penhora PIS                                       ³
	//³ mv_par13 - Penhora COFINS                                    ³
	//³ mv_par14 - Penhora ISS                                       ³
	//³ mv_par15 - Penhora IRRF                                      ³
	//³ mv_par16 - Penhora CSLL                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDataDe := DToS(mv_par01)
	cDataAte := DToS(mv_par02)
	nMesAntICMS := mv_par03
	nMesAntIPI := mv_par04
	nMesAntPIS := mv_par05
	nMesAntCOFINS := mv_par06
	nMesAntISS := mv_par07
	nMesAntIRRF := mv_par08
	nMesAntCSLL := mv_par09
	nPenhoraICMS := mv_par10
	nPenhoraIPI := mv_par11
	nPenhoraPIS := mv_par12
	nPenhoraCOFINS := mv_par13
	nPenhoraISS := mv_par14
	nPenhoraIRRF := mv_par15
	nPenhoraCSLL := mv_par16
	
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
	lProduto := .F.
	lSucata := .F.
	aTotContas[1][1] := 0
	aTotContas[1][2] := 0
	
	AFill(aTotal,0)
	
	aContas[1][1] := "PRODUTOS"
	aContas[2][1] := "TRANSFERENCIA"
	aContas[3][1] := "DEVOLUCAO"
	aContas[4][1] := "ENERGIA ELETRICA"
	aContas[5][1] := "COMUNICACAO"
	aContas[6][1] := "TRANSPORTE"
	aContas[7][1] := "ATIVO PERMANENTE"
	aContas[8][1] := "USO CONSUMO"
	aContas[9][1] := "OUTRAS"
	aContas[10][1] := "SERVICOS"
	aContas[11][1] := "SUCATA"
	
	for i := 1 to Len(aContas)
		aContas[i][2] := 0
		aContas[i][3] := 0
		aContas[i][4] := 0
	next
	
	aImposto[1][1] := "ICMS"
	aImposto[2][1] := "IPI"
	aImposto[3][1] := "ISS"
	aImposto[4][1] := "PIS"
	aImposto[5][1] := "COFINS"
	aImposto[6][1] := "IR VENDAS (15%)"
	aImposto[7][1] := "C SOCIAL VENDAS (9%)"
	aImposto[8][1] := "IR SERVICOS (15%)"
	aImposto[9][1] := "C SOCIAL SERVICOS (9%)"
	aImposto[1][4] := nMesAntICMS
	aImposto[2][4] := nMesAntIPI
	aImposto[3][4] := nMesAntISS
	aImposto[4][4] := nMesAntPIS
	aImposto[5][4] := nMesAntCOFINS
//	aImposto[6][4] := 0
//	aImposto[7][4] := 0
	aImposto[8][4] := nMesAntIRRF
	aImposto[9][4] := nMesAntCSLL
	aImposto[1][5] := nPenhoraICMS
	aImposto[2][5] := nPenhoraIPI
	aImposto[3][5] := nPenhoraISS
	aImposto[4][5] := nPenhoraPIS
	aImposto[5][5] := nPenhoraCOFINS
//	aImposto[6][5] := 0
//	aImposto[7][5] := 0
	aImposto[8][5] := nPenhoraIRRF
	aImposto[9][5] := nPenhoraCSLL
	
	for i := 1 to Len(aImposto)
		aImposto[i][2] := 0
		aImposto[i][3] := 0
	next
	
	cQry := "select F4_DAPI as DAPI, D1_TES as TES, sum(F1_PBRUTO) as PESO, sum(D1_TOTAL + D1_VALIPI - D1_VALDESC + D1_SEGURO + D1_VALFRE + D1_DESPESA) as TOTAL, sum(case when F4_CREDICM = 'S' then D1_VALICM else 0 end) as ICMS, sum(case when F4_CREDIPI = 'S' then D1_VALIPI else 0 end) as IPI, sum(D1_VALIMP5) as COFINS, sum(D1_VALIMP6) as PIS, sum(D1_VALISS) as ISS, sum(D1_VALIRR) as IRRF, sum(D1_VALCSL) as CSLL "
	cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SD1")+" SD1 on (F1_DOC = D1_DOC and F1_SERIE = D1_SERIE and F1_FORNECE = D1_FORNECE and F1_LOJA = D1_LOJA) "
	cQry += "	inner join "+RetSqlName("SF4")+" SF4 on (D1_TES = F4_CODIGO) "
	cQry += "where (D1_DTDIGIT between '"+cDataDe+"' and '"+cDataAte+"') and F4_DAPI <> '00' and SF1.D_E_L_E_T_ <> '*' and SD1.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
	cQry += "group by F4_DAPI, D1_TES, F1_PBRUTO "
	cQry += "union all "
	cQry += "select F4_DAPI as DAPI, D2_TES as TES, sum(F2_PBRUTO) as PESO, sum(D2_TOTAL + D2_VALIPI - D2_DESC + D2_SEGURO + D2_VALFRE + D2_DESPESA) as TOTAL, sum(case when F4_CREDICM = 'S' then D2_VALICM else 0 end) as ICMS, sum(case when F4_CREDIPI = 'S' then D2_VALIPI else 0 end) as IPI, sum(D2_VALIMP5) as COFINS, sum(D2_VALIMP6) as PIS, sum(D2_VALISS) as ISS, sum(D2_VALIRRF) as IRRF, sum(D2_VALCSL) as CSLL "
	cQry += "from "+RetSqlName("SF2")+" SF2 inner join "+RetSqlName("SD2")+" SD2 on (F2_DOC = D2_DOC and F2_SERIE = D2_SERIE and F2_CLIENTE = D2_CLIENTE and F2_LOJA = D2_LOJA) "
	cQry += "	inner join "+RetSqlName("SF4")+" SF4 on (D2_TES = F4_CODIGO) "
	cQry += "where (D2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"') and F4_DAPI <> '00' and SF2.D_E_L_E_T_ <> '*'  and SD2.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
	cQry += "group by F4_DAPI, D2_TES, F2_PBRUTO "
	cQry += "order by F4_DAPI"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		lServico := .F.
		nES := IIf(Val(TEMP->DAPI) < 40,3,2)
		
		SF4->(DbGoTop())
		SF4->(DbSeek(xFilial("SF4")+TEMP->TES,.F.))
		
		cOper := AllTrim(SF4->F4_OPER)
		
		if !(SF4->F4_DAPI $ "30/60") .and. SF4->F4_LFICM == "N" ; TEMP->(DbSkip()) ; loop ; endif
		if !(SF4->F4_DAPI $ "30/60") .and. SF4->F4_LFIPI == "N" ; TEMP->(DbSkip()) ; loop ; endif
		
		do case
			case TEMP->DAPI $ "16/44"
				aContas[1][nES] += TEMP->TOTAL
				lProduto := .T.
			case TEMP->DAPI $ "17/45"
				aContas[2][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "18/46"
				aContas[3][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "19/47"
				aContas[4][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "20/48"
				aContas[5][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "21/49"
				aContas[6][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "22"
				aContas[7][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "23"
				aContas[8][nES] += TEMP->TOTAL
			case TEMP->DAPI $ "24/50"
				if cOper $ "25/55"
					aContas[11][nES] += TEMP->TOTAL
					lSucata := .T.
				else
					aContas[9][nES] += TEMP->TOTAL
				endif
			case TEMP->DAPI $ "30/60"
				aContas[10][nES] += TEMP->TOTAL
				
				if nES == 2
					lServico := .T.
				endif
		endcase
		
		aTotContas[1][nES - 1] += TEMP->TOTAL
		
		if !(TEMP->TES $ "538/537/541")
			aImposto[1][nES] += IIf(!lServico,TEMP->ICMS,0)
		endif
		
		aImposto[2][nES] += TEMP->IPI
		aImposto[3][nES] += IIf(lServico,TEMP->ISS,0)
		aImposto[4][nES] += TEMP->PIS
		aImposto[5][nES] += TEMP->COFINS
		aImposto[8][nES] += TEMP->IRRF
		aImposto[9][nES] += TEMP->CSLL
		
		TEMP->(DbSkip())
	enddo
	
	aImposto[6][3] := (aTotContas[1][2] - aContas[10][3] - aImposto[2][3]) * _ALQIRRF / 100
	aImposto[7][3] := (aTotContas[1][2] - aContas[10][3] - aImposto[2][3]) * _ALQCSLL / 100
	aImposto[6][2] := (aTotContas[1][1] - aContas[10][2] - aImposto[2][2]) * _ALQIRRF / 100
	aImposto[7][2] := (aTotContas[1][1] - aContas[10][2] - aImposto[2][2]) * _ALQCSLL / 100
	
	Peso(lProduto,lSucata)
	
	Cabec1 := PadC("Periodo: "+U_ConvData(cDataDe)+" a "+U_ConvData(cDataAte),nTamanho)
	
	ProcRegua(Len(aContas))
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	CONTAS (R$)                                               PESO SAIDA           NF SAIDA           NF ENTRA              SALDO
//	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA                        999,999,999.99     999,999,999.99     999,999,999.99     999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin,000 psay Replicate("=",_TAMQUAD)
	@++nLin,000 psay "CONTAS (R$)                                               PESO SAIDA           NF SAIDA           NF ENTRA              SALDO"
	@++nLin,000 psay Replicate("-",_TAMQUAD)
	
	nLin++
	
	for i := 1 to Len(aContas)
		nSaldo := aContas[i][2] - aContas[i][3]
		
		@nLin,000 psay AllTrim(aContas[i][1])
		@nLin,054 psay IIf(!Empty(aContas[i][4]),Transf(aContas[i][4],"@E 999,999,999.99")," ")
		@nLin,073 psay Transf(aContas[i][2],"@E 999,999,999.99")
		@nLin,092 psay Transf(aContas[i][3],"@E 999,999,999.99")
		@nLin,111 psay Transf(nSaldo,"@E 999,999,999.99")
		
		aTotal[2] += aContas[i][2]
		aTotal[3] += aContas[i][3]
		aTotal[4] += nSaldo
		aTotal[5] += aContas[i][4]
		nLin++
		
		U_SaltaFolha()
		IncProc()
	next
	
	@nLin,000 psay Replicate("-",_TAMQUAD)
	@++nLin,000 psay "TOTAL CONTAS"
	@nLin,054 psay Transf(aTotal[5],"@E 999,999,999.99")
	@nLin,073 psay Transf(aTotal[2],"@E 999,999,999.99")
	@nLin,092 psay Transf(aTotal[3],"@E 999,999,999.99")
	@nLin,111 psay Transf(aTotal[4],"@E 999,999,999.99")
	@++nLin,000 psay Replicate("=",_TAMQUAD)
	
	AFill(aTotal,0)
	ProcRegua(Len(aImposto))
	
//	IMPOSTOS (R$)                             PENHORA      SALDO MES ANT           NF SAIDA           NF ENTRA              SALDO
//	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA     999,999,999.99     999,999,999.99     999,999,999.99     999,999,999.99     999,999,999.99
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
//	@++nLin,000 psay "IMPOSTOS (R$)                         SALDO MES ANT             NF SAIDA             NF ENTRA                SALDO"
	@++nLin,000 psay "IMPOSTOS (R$)                             PENHORA      SALDO MES ANT           NF SAIDA           NF ENTRA              SALDO"
	@++nLin,000 psay Replicate("-",_TAMQUAD)
	
	nLin++
	
	for i := 1 to (Len(aImposto) - 4)
		nSaldo := aImposto[i][4] + aImposto[i][3] - aImposto[i][2]
		
		@nLin,000 psay AllTrim(aImposto[i][1])
		@nLin,035 psay Transf(aImposto[i][5],"@E 999,999,999.99")
		@nLin,054 psay Transf(aImposto[i][4],"@E 999,999,999.99")
		@nLin,073 psay Transf(aImposto[i][2],"@E 999,999,999.99")
		@nLin,092 psay Transf(aImposto[i][3],"@E 999,999,999.99")
		@nLin,111 psay Transf(nSaldo,"@E 999,999,999.99")
		
		aTotal[2] += aImposto[i][2]
		aTotal[3] += aImposto[i][3]
		aTotal[4] += nSaldo
		aTotal[5] += aImposto[i][4]
		aTotal[6] += aImposto[i][5]
		nLin++
		
		U_SaltaFolha()
		IncProc()
	next
	
	@nLin,000 psay Replicate("-",_TAMQUAD)
	@++nLin,000 psay "TOTAL IMPOSTOS"
	@nLin,035 psay Transf(aTotal[6],"@E 999,999,999.99")
	@nLin,054 psay Transf(aTotal[5],"@E 999,999,999.99")
	@nLin,073 psay Transf(aTotal[2],"@E 999,999,999.99")
	@nLin,092 psay Transf(aTotal[3],"@E 999,999,999.99")
	@nLin,111 psay Transf(aTotal[4],"@E 999,999,999.99")
	@++nLin,000 psay Replicate("=",_TAMQUAD)
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	
	if Select("PESOS") <> 0
		PESOS->(DbCloseArea())
	endif
	
	if Select("PESOP") <> 0
		PESOP->(DbCloseArea())
	endif
	
	TEMP->(DbCloseArea())
return

static function Peso(lProd,lSucat)
	if lSucat
		cQry1 := "select distinct F2_TIPO, F2_DOC, F2_PBRUTO "
		cQry1 += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SF2")+" SF2 on (D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA) "
		cQry1 += "	inner join "+RetSqlName("SF4")+" SF4 on (D2_TES = F4_CODIGO) "
		cQry1 += "where (F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"') and F4_DAPI in ('50') and F4_OPER in ('55') and SD2.D_E_L_E_T_ <> '*' and SF2.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
		
		tcquery cQry1 new alias "PESOS"
		
		DbSelectArea("PESOS")
		ProcRegua(PESOS->(RecCount()))
		PESOS->(DbGoTop())
		
		while !PESOS->(Eof())
			aContas[11][4] += PESOS->F2_PBRUTO
			
			PESOS->(DbSkip())
			IncProc()
		enddo
	endif
	
	if lProd
		cQry1 := "select distinct F2_TIPO, F2_DOC, F2_PBRUTO "
		cQry1 += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SF2")+" SF2 on (D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA) "
		cQry1 += "	inner join "+RetSqlName("SF4")+" SF4 on (D2_TES = F4_CODIGO) "
		cQry1 += "where (F2_EMISSAO between '"+cDataDe+"' and '"+cDataAte+"') and F4_DAPI in ('44') and SD2.D_E_L_E_T_ <> '*' and SF2.D_E_L_E_T_ <> '*' and SF4.D_E_L_E_T_ <> '*' "
		
		tcquery cQry1 new alias "PESOP"
		
		DbSelectArea("PESOP")
		ProcRegua(PESOP->(RecCount()))
		PESOP->(DbGoTop())
		
		while !PESOP->(Eof())
			aContas[1][4] += PESOP->F2_PBRUTO
			
			PESOP->(DbSkip())
			IncProc()
		enddo
	endif
return