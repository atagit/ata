/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/01/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório histórico financeiro de compra              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function HISTCOM()
	private aOrd    := {}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   := "HISCOM"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "HISTORICO DE COMPRAS"
	private ContFun := 0
	private cString := "SE2"
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
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDtIni := ""
	private cDtFin := ""
	private cForIni := ""
	private cForFin := ""
	private cNFIni:= ""
	private cNFFin := ""
	private cBcoIni := ""
	private cBcoFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
	//³ mv_par05 - Nota Fiscal de                                    ³
	//³ mv_par06 - Nota Fiscal ate                                   ³
	//³ mv_par07 - Banco de                                          ³
	//³ mv_par08 - Banco ate                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	cForIni := mv_par03
	cForFin := mv_par04
	cNFIni:= mv_par05
	cNFFin := mv_par06
	cBcoIni := mv_par07
	cBcoFin := mv_par08
	
	RptStatus({|| Impr()},"","Aguarde processando...",lAborta)
	
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
	cQry := "select E2_FORNECE, E2_LOJA, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_BAIXA, E2_CR, E2_BCOPAG, E2_NUMBCO, E2_VALOR, E2_MULTA, E2_DESCONT, E2_FATURA, E2_FATPREF "
	cQry += "from "+RetSqlName("SE2")+" "
	cQry += "where (E2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (E2_FORNECE between '"+cForIni+"' and '"+cForFin+"') and (E2_NUM between '"+cNFIni+"' and '"+cNFFin+"') and (E2_BCOPAG between '"+cBcoIni+"' and '"+cBcoFin+"') and E2_FATURA <> 'NOTFAT' and D_E_L_E_T_ <> '*' "
	cQry += "order by E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_NUM, E2_PARCELA"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	SetRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	Cabec2 := "NOTA FISCAL   | PARC | EMISSAO  | VENCTO   | BAIXA    | PROT.   | CHEQUE | BCO  |          VALOR |      JUROS |    DESCONT | ATRASO"
	
//	NOTA FISCAL   | PARC | EMISSAO  | VENCTO   | BAIXA    | PROT.   | CHEQUE | BCO  |          VALOR |      JUROS |    DESCONT | ATRASO
//	999999999-999   999    99/99/99   99/99/99   99/99/99   9999999   AAAAAA   AAAA   999,999,999.99   999,999.99   999,999.99   9999
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nLin++
		
		@nLin,000 psay U_Negrito(.T.)+"FORNECEDOR: "+IIf(SA2->(DbSeek(xFilial("SA2")+TEMP->(E2_FORNECE+E2_LOJA),.F.)),AllTrim(SA2->A2_NREDUZ),"")+" ("+TEMP->E2_FORNECE+"-"+TEMP->E2_LOJA+")"+U_Negrito(.F.)
		
		nLin++
		
		@nLin,000 psay Replicate("-",132)
		
		nLin++
		nCont := 0 ; nTotValor := 0 ; nTotMulta := 0 ; nTotDesco := 0
		nTotAberto := 0 ; nContAberto := 0 ; nTotPago := 0 ; nContPago := 0
		cFornecedor := TEMP->(E2_FORNECE+E2_LOJA)
		
		while !TEMP->(Eof()) .and. TEMP->(E2_FORNECE+E2_LOJA) == cFornecedor
			nAtraso := IIf(Empty(TEMP->E2_BAIXA),dDataBase - SToD(TEMP->E2_VENCREA),SToD(TEMP->E2_BAIXA) - SToD(TEMP->E2_VENCREA))
			
			@nLin,000 psay TEMP->E2_NUM+"-"+TEMP->E2_PREFIXO
			@nLin,016 psay TEMP->E2_PARCELA
			@nLin,023 psay U_ConvData(TEMP->E2_EMISSAO,"yy")
			@nLin,034 psay U_ConvData(TEMP->E2_VENCREA,"yy")
			@nLin,045 psay U_ConvData(TEMP->E2_BAIXA,"yy")
			@nLin,056 psay Left(TEMP->E2_CR,7)
			@nLin,066 psay Left(TEMP->E2_NUMBCO,6)
			
			if Empty(TEMP->(E2_FATURA+E2_FATPREF))
				cBcoPag := TEMP->E2_BCOPAG
			else
				cQry := "select E2_BCOPAG from "+RetSqlName("SE2")+" where E2_NUM = '"+TEMP->E2_FATURA+"' and E2_PREFIXO = '"+TEMP->E2_FATPREF+"' and E2_FATURA = 'NOTFAT' and D_E_L_E_T_ <> '*'"
				
				tcquery cQry new alias "CON"
				
				DbSelectArea("CON")
				
				cBcoPag := CON->E2_BCOPAG
				
				CON->(DbCloseArea())
			endif
			
			@nLin,075 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBcoPag,.F.)),SA6->A6_SIGLA," ")
			@nLin,082 psay Transf(TEMP->E2_VALOR,"@E 999,999,999.99")
			@nLin,099 psay Transf(TEMP->E2_MULTA,"@E 999,999.99")
			@nLin,112 psay Transf(TEMP->E2_DESCONT,"@E 999,999.99")
			@nLin,125 psay Transf(nAtraso,"@R 9999")
			
			nLin++
			nCont++
			nTotValor += TEMP->E2_VALOR
			nTotMulta += TEMP->E2_MULTA
			nTotDesco += TEMP->E2_DESCONT
			
			if Empty(cBcoPag)
				nTotAberto += TEMP->E2_VALOR
				nContAberto++
			else
				nTotPago += TEMP->E2_VALOR
				nContPago++
			endif
			
			U_SaltaFolha()
			IncRegua()
			TEMP->(DbSkip())
		enddo
		
		@nLin,000 psay Replicate("-",132)
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,034 psay "COMPRAS..:"
		@nLin,056 psay Transf(nCont,"@R 999999")
		@nLin,082 psay Transf(nTotValor,"@E 999,999,999.99")
		@nLin,099 psay Transf(nTotMulta,"@E 999,999.99")
		@nLin,112 psay Transf(nTotDesco,"@E 999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,034 psay "PAGAS....:"
		@nLin,056 psay Transf(nContPago,"@R 999999")
		@nLin,082 psay Transf(nTotPago,"@E 999,999,999.99")
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,034 psay "EM ABERTO:"
		@nLin,056 psay Transf(nContAberto,"@R 999999")
		@nLin,082 psay Transf(nTotAberto,"@E 999,999,999.99")
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
	
	DbSelectArea("TEMP")
return