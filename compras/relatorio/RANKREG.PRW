/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 22/01/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio por regiao que mais compra ou vende         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RANKREG()
	private aOrd    := {"Regiao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RANKRE"
	private Cabec1  := "REGIAO                                                                                TOTAL                 ICMS                  IPI"
	private Cabec2  := ""
	private cDesc1  := "RANKING P/ REGIAO"
	private ContFun := 0
	private cString := "SF1"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	private aArea   := GetArea()
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cRegIni := ""
	private cRegFin := ""
	private cDatIni := CToD("")
	private cDatFin := CToD("")
	private nTipo := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Periodo de                                        ³
	//³ mv_par02 - Periodo ate                                       ³
	//³ mv_par03 - Regiao de                                         ³
	//³ mv_par04 - Regiao ate                                        ³
	//³ mv_par05 - Tipo (1-Sintetico/2-Analitico)                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDatIni := DToS(mv_par01)
	cDatFin := DToS(mv_par02)
	cRegIni := mv_par03
	cRegFin := mv_par04
	nTipo := mv_par05
	
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
	local aRegiao := {}
	local nX := 0
	
	if nModulo == 2
		cQry := "select A2_REGIAO as REGIAO, X5_DESCRI as RDESCRI, sum(F1_VALMERC) as VALMERC, sum(F1_VALICM) as VALICM, sum(F1_VALIPI) as VALIPI "
		cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SA2")+" SA2 on (F1_FORNECE = A2_COD and F1_LOJA = A2_LOJA and F1_TIPO not in ('B','D')) "
		cQry += "	inner join "+RetSqlName("SX5")+" SX5 on (X5_CHAVE = A2_REGIAO and X5_TABELA = 'MR') "
		cQry += "where (F1_EMISSAO between '"+cDatIni+"' and '"+cDatFin+"') and (A2_REGIAO between '"+cRegIni+"' and '"+cRegFin+"') and SF1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' and SX5.D_E_L_E_T_ <> '*' "
		cQry += "group by A2_REGIAO, X5_DESCRI "
		cQry += "order by VALMERC desc"
	elseif nModulo == 5
		cQry := "select A1_REGIAO as REGIAO, X5_DESCRI as RDESCRI, sum(F2_VALMERC) as VALMERC, sum(F2_VALICM) as VALICM, sum(F2_VALIPI) as VALIPI "
		cQry += "from "+RetSqlName("SF2")+" SF2 inner join "+RetSqlName("SA1")+" SA1 on (F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA and F2_TIPO not in ('B','D')) "
		cQry += "	inner join "+RetSqlName("SX5")+" SX5 on (X5_CHAVE = A1_REGIAO and X5_TABELA = 'MR') "
		cQry += "where (F2_EMISSAO between '"+cDatIni+"' and '"+cDatFin+"') and (A1_REGIAO between '"+cRegIni+"' and '"+cRegFin+"') and SF2.D_E_L_E_T_ <> '*' and SA1.D_E_L_E_T_ <> '*' and SX5.D_E_L_E_T_ <> '*' "
		cQry += "group by A1_REGIAO, X5_DESCRI "
		cQry += "order by VALMERC desc"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		AAdd(aRegiao,{TEMP->REGIAO,TEMP->VALMERC,TEMP->VALICM,TEMP->VALIPI,TEMP->RDESCRI})
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
	
	if nTipo == 2
		Cabec2  := "FORNECEDOR                                NOTA FISCAL    TIPO  EMISSAO                TOTAL                 ICMS                  IPI"
	endif
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	if nModulo == 2
		@nLin,000 psay PadC("------------------------------- COMPRAS -------------------------------",132)
	elseif nModulo == 5
		@nLin,000 psay PadC("----------------------------- FATURAMENTO -----------------------------",132)
	endif
	
	nLin++
	
	U_SaltaFolha()
	
	for nX := 1 to Len(aRegiao)
//	   	REGIAO                                                                                TOTAL                 ICMS                  IPI
//	    AAA   AAAAAAAAAAAAAAAAAAAA                                               999,999,999,999.99   999,999,999,999.99   999,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay aRegiao[nX][1]
		@nLin,006 psay aRegiao[nX][5]
		@nLin,074 psay Transf(aRegiao[nX][2],"@E 999,999,999,999.99")
		@nLin,095 psay Transf(aRegiao[nX][3],"@E 999,999,999,999.99")
		@nLin,116 psay Transf(aRegiao[nX][4],"@E 999,999,999,999.99")
		
		if nTipo == 2
			if nModulo == 2
				cQry := "select F1_FORNECE, F1_LOJA, A2_NREDUZ, F1_DOC, F1_SERIE, F1_TIPO, F1_EMISSAO, F1_VALMERC, F1_VALICM, F1_VALIPI "
				cQry += "from "+RetSqlName("SF1")+" SF1 inner join "+RetSqlName("SA2")+" SA2 on (F1_FORNECE = A2_COD and F1_LOJA = A2_LOJA and F1_TIPO not in ('B','D')) "
				cQry += "where (F1_EMISSAO between '"+cDatIni+"' and '"+cDatFin+"') and A2_REGIAO = '"+aRegiao[nX][1]+"' and SF1.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
				cQry += "order by A2_NREDUZ"
			elseif nModulo == 5
				cQry := "select A1_REGIAO as REGIAO, sum(F2_VALMERC) as VALMERC, sum(F2_VALICM) as VALICM, sum(F2_VALIPI) as VALIPI "
				cQry += "from "+RetSqlName("SF2")+" SF2 inner join "+RetSqlName("SA1")+" SA1 on (F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA and F2_TIPO not in ('B','D')) "
				cQry += "where (F2_EMISSAO between '"+cDatIni+"' and '"+cDatFin+"') and (A1_REGIAO between '"+cRegIni+"' and '"+cRegFin+"') and SF2.D_E_L_E_T_ <> '*' and SA1.D_E_L_E_T_ <> '*' "
				cQry += "group by A1_REGIAO "
				cQry += "order by VALMERC desc"
			endif
			
			tcquery cQry new alias "TEMP"
			DbSelectArea("TEMP")
			ProcRegua(TEMP->(RecCount()))
			TEMP->(DbGoTop())
			
			while !TEMP->(Eof())
//			   	FORNECEDOR                                NOTA FISCAL    TIPO  EMISSAO                TOTAL                 ICMS                  IPI
//			    999999-99 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  999999999-999  A     99/99/99  999,999,999,999.99   999,999,999,999.99   999,999,999,999.99
//				012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//				          1         2         3         4         5         6         7         8         9        10        11        12        13
				
				nLin++
				
				U_SaltaFolha()
				
				@nLin,000 psay TEMP->F1_FORNECE+"-"+TEMP->F1_LOJA+" "+TEMP->A2_NREDUZ
				@nLin,042 psay TEMP->F1_DOC+"-"+TEMP->F1_SERIE
				@nLin,057 psay TEMP->F1_TIPO
				@nLin,063 psay U_ConvData(TEMP->F1_EMISSAO)
				@nLin,073 psay Transf(TEMP->F1_VALMERC,"@E 999,999,999,999.99")
				@nLin,094 psay Transf(TEMP->F1_VALICM,"@E 999,999,999,999.99")
				@nLin,115 psay Transf(TEMP->F1_VALIPI,"@E 999,999,999,999.99")
				
				TEMP->(DbSkip())
			enddo
			
			nLin++
			
			U_SaltaFolha()
			
			TEMP->(DbCloseArea())
		endif
		
		nLin++
		
		U_SaltaFolha()
		IncProc()
	next
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	RestArea(aArea)
return