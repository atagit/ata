/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/11/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Movimento Bancário detalhado                          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function MVBCODET()
	private aOrd    := {"Data","Naturez"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "MOVBCO"
	private Cabec1  := "BANCO/AGENCIA"
	private Cabec2  := "CONTA      | DATA     | NATUREZ | CHEQUE   | DOCUMENTO         |            ENTRADA |              SAIDA | HISTORICO"
	private cDesc1  := "MOV. BANCARIO DETALHADO"
	private ContFun := 0
	private cString := "SE5"
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
	private cRdpLeg	:= "OBS.: Aparecendo a letra 'A' antes do numero do cheque, quer dizer que ele foi aglutinado."
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDtIni := ""
	private cDtFin := ""
	private cBcoIni := ""
	private cBcoFin := ""
	private cNatIni := ""
	private cNatFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Data de                                           ³
	//³ mv_par02 - Data ate                                          ³
	//³ mv_par03 - Banco de                                          ³
	//³ mv_par04 - Banco ate                                         ³
	//³ mv_par05 - Natureza de                                       ³
	//³ mv_par06 - Natureza ate                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cBcoIni := mv_par03
	cBcoFin := mv_par04
	cNatIni := mv_par05
	cNatFin := mv_par06
	
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
	local nTotalE := 0
	local nTotalS := 0
	local nTotGeralE := 0
	local nTotGeralS := 0
	
	cQry := "select E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_DATA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NATUREZ, E5_NUMCHEQ, E5_VALOR, E5_RECPAG, E5_HISTOR "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (E5_DATA between '"+cDtIni+"' and '"+cDtFin+"') and (E5_BANCO between '"+cBcoIni+"' and '"+cBcoFin+"') and (E5_NATUREZ between '"+cNatIni+"' and '"+cNatFin+"') and E5_NUMERO <> '' and D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by E5_BANCO, E5_AGENCIA, E5_CONTA, E5_DATA, E5_NATUREZ"
	elseif nOrdem == 2
		cQry += "order by E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NATUREZ, E5_DATA"
	endif
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	CONTA      | DATA     | NATUREZ | CHEQUE   | DOCUMENTO         |            ENTRADA |              SAIDA | HISTORICO
//	9999999999   99/99/99   999999    A 999999   999999999           999,999,999,999.99   999,999,999,999.99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//                                               AAA-000000000-000
//	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		cBanco := TEMP->E5_BANCO
		cAgencia := TEMP->E5_AGENCIA
		
		@nLin,000 psay U_Negrito(.T.)+TEMP->E5_BANCO+"/"+TEMP->E5_AGENCIA+U_Negrito(.F.)
		
		nLin++
		
		while cBanco == TEMP->E5_BANCO .and. cAgencia == TEMP->E5_AGENCIA
			@nLin,000 psay TEMP->E5_CONTA
			@nLin,013 psay U_ConvData(TEMP->E5_DATA,"yy")
			@nLin,024 psay Left(TEMP->E5_NATUREZ,6)
			
			cCon := "select EF_ORIGEM "
			cCon += "from "+RetSqlName("SEF")+" "
			cCon += "where EF_NUM = '"+TEMP->E5_NUMCHEQ+"' and EF_TITULO = '' and D_E_L_E_T_ <> '*'"
			
			tcquery cCon new alias "CON"
			DbSelectArea("CON")
			
			@nLin,034 psay If(AllTrim(CON->EF_ORIGEM) == "FINA190","A"," ")+' '+Left(TEMP->E5_NUMCHEQ,6)
			
			CON->(DbCloseArea())
			
			@nLin,045 psay AllTrim(TEMP->E5_PREFIXO)+"-"+AllTrim(TEMP->E5_NUMERO)+"-"+AllTrim(TEMP->E5_PARCELA)
			
			if TEMP->E5_RECPAG == "R"
				@nLin,065 psay Transf(TEMP->E5_VALOR,"@E 999,999,999,999.99")
				
				nTotalE += TEMP->E5_VALOR
			else
				@nLin,086 psay Transf(TEMP->E5_VALOR,"@E 999,999,999,999.99")
				
				nTotalS += TEMP->E5_VALOR
			endif
			
			@nLin,107 psay Left(TEMP->E5_HISTOR,30)
			
			nLin++
			
			IncProc()
			
			U_SaltaFolha()
			
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		if !Empty(nTotalE)
			@nLin,065 psay Transf(nTotalE,"@E 999,999,999,999.99")
		endif
		
		if !Empty(nTotalS)
			@nLin,086 psay Transf(nTotalS,"@E 999,999,999,999.99")
		endif
		
		nTotGeralE += nTotalE
		nTotGeralS += nTotalS
		nTotalE := 0
		nTotalS := 0
		nLin += 2
		
		U_SaltaFolha()
	enddo
	
	@nLin  ,069 psay "TOTAL ENTRADA:   "+Transf(nTotGeralE,"@E 999,999,999,999.99")
	@nLin+1,069 psay "TOTAL SAIDA..:   "+Transf(nTotGeralS,"@E 999,999,999,999.99")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return