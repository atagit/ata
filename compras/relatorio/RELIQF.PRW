/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 22/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de avaliacao do fornecedor                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELIQF()
	private aOrd    := {"Codigo","N. Fantasia"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELIQF"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "AVALIACAO FORNECEDOR"
	private ContFun := 0
	private cString := "SA2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := cPerg
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= "APROV - Aprovado    |    REPRO - Reprovado    |    ACEIT - Aceito com restricao"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private nTipo := 0
	private cDataIni := ""
	private cForIni := ""
	private cForFin := ""
	private cCritico := ""
	private nCritico := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Tipo (1-Atual/2-Historico)                        ³
	//³ mv_par02 - Apartir de                                        ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//³ mv_par05 - Forn. Critico (1-Sim/2-Nao/3-Ambos)               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	nTipo := mv_par01
	cDataIni := DToS(mv_par02)
	cForIni := mv_par03
	cForFin := mv_par04
	nCritico := mv_par05
	
	do case
		case nCritico == 1
			cCritico := "S"
		case nCritico == 2
			cCritico := "N"
		case nCritico == 3
			cCritico := "A"
	endcase
	
	if nTipo == 1
		RptStatus({|| Impr()},"","Aguarde processando...",lAborta)
	else
		RptStatus({|| Impr1()},"","Aguarde processando...",lAborta)
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

static function Impr()
	local aCalcIQF := {}
	
	DbSelectArea("SZV")
	SZV->(DbSetOrder(4))
	
	cQry := "select A2_COD, A2_LOJA, A2_NREDUZ, A2_ULTCOM, A2_CRITICO "
	cQry += "from "+RetSqlName("SA2")+" "
	cQry += "where (A2_COD between '"+cForIni+"' and '"+cForFin+"') and D_E_L_E_T_ <> '*' "
//	cQry += "where (A2_COD between '"+cForIni+"' and '"+cForFin+"') and A2_MSBLQL <> 1 and D_E_L_E_T_ <> '*' "
	
	do case
		case nOrdem == 1
			cQry += "order by A2_COD, A2_LOJA"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, A2_COD, A2_LOJA"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
/*	if !Empty(cSituacao)
		DbSelectArea("SX5")
		SX5->(DbGoTop())
		
		if SX5->(DbSeek(xFilial("SX5")+"ST"+cSituacao,.F.))
			cCondicao := "TEMP->A2_AVALIAC "+AllTrim(SX5->X5_DESCSPA)+" .and. TEMP->A2_AVALIAC "+AllTrim(SX5->X5_DESCENG)
		endif
	endif*/
//	Cabec1  := "FORNECEDOR                              | ULT. COMP  | CRIT | APROV | REPRO | ACEIT |    IQF | STATUS"
	Cabec1  := "FORNECEDOR                              | ULT COMP | CRIT | APROV | REPRO | ACEIT | NC REP | NC ACE |    IQF | STATUS"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
//	FORNECEDOR                              | ULT COMP | CRIT | APROV | REPRO | ACEIT | NC REP | NC ACE |    IQF | STATUS
//	999999-99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAA   99/99/99   SIM    99999   99999   99999    99999    99999   999.99   ACEITO COM RESTRICAO
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		if cCritico <> "A"
			if TEMP->A2_CRITICO <> cCritico ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		@nLin,000 psay TEMP->A2_COD+"/"+TEMP->A2_LOJA+" "+TEMP->A2_NREDUZ
		@nLin,042 psay U_ConvData(TEMP->A2_ULTCOM,"yy")
		@nLin,053 psay IIf(TEMP->A2_CRITICO == "S","SIM","NAO")
		
		SZV->(DbGoTop())
		
		if SZV->(DbSeek(xFilial("SZV")+TEMP->A2_COD+TEMP->A2_LOJA,.F.))
			while !SZV->(Eof()) .and. SZV->ZV_FORNECE == TEMP->A2_COD .and. SZV->ZV_LOJA == TEMP->A2_LOJA
				if SZV->ZV_USADO == "S"
					aCalcIQF := U_CalcIQF(0,0,0,SZV->ZV_VALIQF)
					
					@nLin,060 psay Transf(SZV->ZV_RA,"@E 99999")
					@nLin,068 psay Transf(SZV->ZV_RR,"@E 99999")
					@nLin,076 psay Transf(SZV->ZV_RC,"@E 99999")
					@nLin,085 psay Transf(SZV->ZV_NCD,"@E 99999")
					@nLin,094 psay Transf(SZV->ZV_NCA,"@E 99999")
					@nLin,102 psay Transf(SZV->ZV_VALIQF,"@E 999.99")
					@nLin,111 psay aCalcIQF[1][2]
				endif
				
				SZV->(DbSkip())
			enddo
		else
			@nLin,111 psay "SEM CLASSIFICACAO"
		endif
		
		nLin++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return

static function Impr1()
	local aCalcIQF := {}
	
	cQry := "select A2_COD, A2_LOJA, A2_NREDUZ, A2_ULTCOM, A2_CRITICO, ZV_INIAVAL, ZV_FINAVAL, ZV_RA, ZV_RC, ZV_RR, ZV_VALIQF, ZV_STATUS, ZV_MAXPED "
	cQry += "from "+RetSqlName("SA2")+" SA2 inner join "+RetSqlName("SZV")+" SZV on (A2_COD = ZV_FORNECE and A2_LOJA = ZV_LOJA) "
	cQry += "where (A2_COD between '"+cForIni+"' and '"+cForFin+"') and ZV_INIAVAL >= '"+cDataIni+"' and A2_MSBLQL <> 1 and SA2.D_E_L_E_T_ <> '*' and SZV.D_E_L_E_T_ <> '*' "
	
	do case 
		case nOrdem == 1
			cQry += "order by A2_COD, A2_LOJA, ZV_CODIGO"
		case nOrdem == 2
			cQry += "order by A2_NREDUZ, A2_COD, A2_LOJA, ZV_CODIGO"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1  := "FORNECEDOR                              | CRIT"
	Cabec2  := "ABERTO     | FECHADO    | MAX PED | APROV | REPRO | ACEIT |    IQF | STATUS"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//FORNECEDOR                              | CRIT
	//ABERTO     | FECHADO    | MAX PED | APROV | REPRO | ACEIT |    IQF | STATUS
	//999999-99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAA   SIM
	//99/99/9999   99/99/9999     99999   99999   99999   99999   999.99   ACEITO COM RESTRICAO
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//          1         2         3         4         5         6         7         8         9        10
	
	while !TEMP->(Eof())
		if cCritico <> "A"
			if TEMP->A2_CRITICO <> cCritico ; TEMP->(DbSkip()) ; loop ; endif
		endif
		
		nLin++
		cFornecedor := TEMP->A2_COD
		cLoja := TEMP->A2_LOJA
		
		@nLin,000 psay U_Negrito(.T.)+cFornecedor+"/"+cLoja+" "+TEMP->A2_NREDUZ+U_Negrito(.F.)
		@nLin,040 psay IIf(TEMP->A2_CRITICO == "S","SIM","NAO")
		
		while TEMP->A2_COD == cFornecedor .and. TEMP->A2_LOJA == cLoja
			nLin++
			aCalcIQF := U_CalcIQF(0,0,0,TEMP->ZV_VALIQF)
			
			@nLin,000 psay U_ConvData(TEMP->ZV_INIAVAL)
			@nLin,013 psay U_ConvData(TEMP->ZV_FINAVAL)
			@nLin,028 psay Transf(TEMP->ZV_MAXPED,"@E 99999")
			@nLin,036 psay Transf(TEMP->ZV_RA,"@E 99999")
			@nLin,044 psay Transf(TEMP->ZV_RR,"@E 99999")
			@nLin,052 psay Transf(TEMP->ZV_RC,"@E 99999")
			@nLin,060 psay Transf(TEMP->ZV_VALIQF,"@E 999.99")
			@nLin,069 psay aCalcIQF[1][2]
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return