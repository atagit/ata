/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 20/08/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de saldos bancarios                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function SALBCO()
	private aOrd    := {"Banco"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := ""
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "SALDO BANCARIO"
	private ContFun := 0
	private cString := "SA6"
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
	
/*	private cBancoDe := ""
	private cAgenciaDe := ""
	private cContaDe := ""
	private cDataDe := CToD("")
	private cDataAte := CToD("")*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//³ mv_par04 - Periodo de                                        ³
	//³ mv_par05 - Periodo ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
/*	cBancoDe := mv_par01
	cAgenciaDe := mv_par02
	cContaDe := mv_par03
	cDataDe := DToS(mv_par04)
	cDataAte := DToS(mv_par05)*/
	
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
	local nTotal := 0
	local nItem := 0
	
	DbSelectArea("SA6")
	ProcRegua(SA6->(RecCount()))
	SA6->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	================================================================================================
//	BANCO                                      | STS |            LIMITE |  TAXA |             SALDO
//	------------------------------------------------------------------------------------------------
	
	@nLin,000 psay "================================================================================================"
	@++nLin,000 psay "BANCO                                      | STS |            LIMITE |  TAXA |             SALDO"
	@++nLin,000 psay "------------------------------------------------------------------------------------------------"
	
	nLin++
	
	while !SA6->(Eof())
//		BANCO                                      | STS |            LIMITE |  TAXA |             SALDO
//		AAAAAAAAAAAAAAAAAAAA  999 99999 9999999999 |  A  | 99,999,999,999.99 | 99,99 | 99,999,999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		if SA6->A6_EXIBREL <> "S" ; DbSkip() ; loop ; endif
		
		@nLin,000 psay SA6->A6_NREDUZ
		@nLin,022 psay SA6->A6_COD
		@nLin,026 psay SA6->A6_AGENCIA
		@nLin,032 psay SA6->A6_NUMCON
		@nLin,043 psay "|"
		@nLin,046 psay IIf(SA6->A6_BLOCKED == "1","B","L")
		@nLin,049 psay "|"
		@nLin,051 psay Transf(SA6->A6_LIMCRED,"@E 99,999,999,999.99")
		@nLin,069 psay "|"
		@nLin,071 psay Transf(SA6->A6_TXCOBSI,"@E 99.99")
		@nLin,077 psay "|"
		@nLin,079 psay Transf(SA6->A6_SALATU,"@E 99,999,999,999.99")
		
		nLin++
		nItem++
		nTotal += SA6->A6_SALATU
		
		U_SaltaFolha()
		SA6->(DbSkip())
	enddo
	
	@nLin,000 psay "------------------------------------------------------------------------------------------------"
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L -----> ("+AllTrim(Str(nItem))+" REGISTROS)"
	@nLin,077 psay "|"
	@nLin,079 psay Transf(nTotal,"@E 99,999,999,999.99")
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "================================================================================================"
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return