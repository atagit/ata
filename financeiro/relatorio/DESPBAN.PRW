/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/09/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de relacao das despesas bancarias           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function DESPBAN()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "DESBAN"
	private Cabec1  := ""
	private Cabec2  := "ITM  PREVISAO  EMISSAO   OPERACAO                                  NATUREZ  DOCUMENTO                        VALOR"
	private cDesc1  := "RELACAO DESPESAS BANCARIA"
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
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDataIni	:= ""
	private cDataFin	:= ""
	private cBancoDe	:= ""
	private cAgenciaDe 	:= ""
	private cContaDe 	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Periodo de                                        ³
	//³ mv_par02 - Periodo ate                                       ³
	//³ mv_par03 - Banco                                             ³
	//³ mv_par04 - Agencia                                           ³
	//³ mv_par05 - Conta                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDataIni := DToS(mv_par01)
	cDataFin := DToS(mv_par02)
	cBancoDe := mv_par03
	cAgenciaDe := mv_par04
	cContaDe := mv_par05
	
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
	local nTotItem := 1
	local nValor := 0
	local nTotValor := 0
	local aNatureza := {}
	
	cQry := "select E5_DTDISPO, E5_DTDIGIT, E5_VALOR, E5_NATUREZ, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, E5_NUMTED, E5_RECPAG, E5_HISTOR, E5_BENEF, E5_NATUREZ "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (E5_DTDISPO between '"+cDataIni+"' and '"+cDataFin+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and left(E5_NATUREZ,3) in ('206','212') and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DTDISPO"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Periodo de "+U_ConvData(cDataIni)+" a "+U_ConvData(cDataFin),132)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
//		ITM  PREVISAO  EMISSAO   OPERACAO                                  NATUREZ  DOCUMENTO                        VALOR
//		999  99/99/99  99/99/99  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  999999   AAAAAAAAAAAAAAAAAAAA  9,999,999,999.99
//		01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay StrZero(nTotItem,3)
		@nLin,005 psay U_ConvData(TEMP->E5_DTDISPO,"yy")
		@nLin,015 psay U_ConvData(TEMP->E5_DTDIGIT,"yy")
		@nLin,025 psay Left(IIf(Empty(TEMP->E5_HISTOR),TEMP->E5_BENEF,TEMP->E5_HISTOR),40)
		@nLin,067 psay Left(TEMP->E5_NATUREZ,6)
		@nLin,076 psay Left(IIf(Empty(TEMP->E5_NUMCHEQ),TEMP->E5_NUMTED,TEMP->E5_NUMCHEQ),20)
		@nLin,098 psay Transf(TEMP->E5_VALOR,"@E 9,999,999,999.99")
		
		if (nInd := AScan(aNatureza,{|x| x[1] = TEMP->E5_NATUREZ})) == 0
			AAdd(aNatureza,{TEMP->E5_NATUREZ,1,TEMP->E5_VALOR})
		else
			aNatureza[nInd][2]++
			aNatureza[nInd][3] += TEMP->E5_VALOR
		endif
		
		nLin++
		nTotItem++
		nTotValor += TEMP->E5_VALOR
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L -----> ("+AllTrim(Str(nTotItem - 1))+" MOVIMENTACOES)"
	@nLin,098 psay Transf(nTotValor,"@E 9,999,999,999.99")
	
	nLin++
	
	@nLin,000 psay __PrtThinLine()
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "NATUREZA                                QUANT             TOTAL"
	
	nLin++
	nTotValor := 0
	nTotItem := 0
	
	U_SaltaFolha()
	
	if !Empty(aNatureza)
		for i := 1 to Len(aNatureza)
//			NATUREZA                                QUANT             TOTAL
//			999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   99999  9,999,999,999.99
//			01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			          1         2         3         4         5         6         7         8         9        10        11        12        13
			
			@nLin,000 psay Left(aNatureza[i][1],6)
			@nLin,007 psay Left(IIf(SED->(DbSeek(xFilial("SED")+aNatureza[i][1],.F.)),SED->ED_DESCRIC," "),30)
			@nLin,040 psay Transf(aNatureza[i][2],"@R 99999")
			@nLin,047 psay Transf(aNatureza[i][3],"@E 9,999,999,999.99")
			
			nLin++
			nTotItem += aNatureza[i][2]
			nTotValor += aNatureza[i][3]
		next
		
		@nLin,000 psay "T O T A L"
		@nLin,040 psay Transf(nTotItem,"@R 99999")
		@nLin,047 psay Transf(nTotValor,"@E 9,999,999,999.99")
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return