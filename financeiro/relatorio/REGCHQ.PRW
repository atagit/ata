/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 16/08/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de registro de cheque                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function REGCHQ()
	private aOrd    := {"Cheque"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "REGCHQ"
	private Cabec1  := "CHEQUE   DATA REGISTRO   CADASTRO POR"
	private Cabec2  := ""
	private cDesc1  := "REGISTRO DE CHEQUES"
	private ContFun := 0
	private cString := "SEF"
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
	
	private cBancoDe := ""
	private cAgenciaDe := ""
	private cContaDe := ""
	private cQtdCheques := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//³ mv_par04 - Qtd Cheq Impr                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cBancoDe := mv_par01
	cAgenciaDe := mv_par02
	cContaDe := mv_par03
	cQtdCheques := mv_par04
	
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
	local nItem := 0
	
	if AllTrim(cQtdCheques) == "*" .or. Empty(cQtdCheques)
		cQry := "select Z8_BANCO, Z8_AGENCIA, Z8_CONTA, Z8_CHEQUE, Z8_USERLGI, EF_USERLGI "
	else
		cQry := "select top "+cQtdCheques+" Z8_BANCO, Z8_AGENCIA, Z8_CONTA, Z8_CHEQUE, Z8_USERLGI, EF_USERLGI "
	endif
	
	cQry += "from "+RetSqlName("SZ8")+" SZ8 left join "+RetSqlName("SEF")+" SEF on (Z8_CHEQUE = EF_NUM and '' = EF_PREFIXO) "
	cQry += "where Z8_BANCO = '"+cBancoDe+"' and Z8_AGENCIA = '"+cAgenciaDe+"' and Z8_CONTA = '"+cContaDe+"' and SZ8.D_E_L_E_T_ <> '*' "
	cQry += "order by Z8_CHEQUE desc"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	cBanco := TEMP->(Z8_BANCO+Z8_AGENCIA+Z8_CONTA)
	
//	AAAAAAAAAAAAAAAAAAAA (999 99999 9999999999)
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	@nLin,000 psay IIf(SA6->(DbSeek(xFilial("SA6")+cBanco,.F.)),SA6->A6_NREDUZ," ")
	@nLin,021 psay "("+TEMP->Z8_BANCO
	@nLin,026 psay TEMP->Z8_AGENCIA
	@nLin,032 psay TEMP->Z8_CONTA+")"
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin,000 psay "CHEQUE   DATA REGISTRO   CADASTRO POR                               DATA LANCAMTO   LANCADO POR"
	
	nLin++
	
	while !TEMP->(Eof()) .and. TEMP->(Z8_BANCO+Z8_AGENCIA+Z8_CONTA) == cBanco
//		CHEQUE   DATA REGISTRO   CADASTRO POR                               DATA LANCAMTO   LANCADO POR
//		999999   99/99/9999      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   99/99/9999      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay Left(TEMP->Z8_CHEQUE,6)
		@nLin,009 psay FWLeUserlg("Z8_USERLGI",2)
		@nLin,025 psay Left(FWLeUserlg("Z8_USERLGI"),40)
		@nLin,068 psay FWLeUserlg("EF_USERLGI",2)
		@nLin,084 psay Left(FWLeUserlg("EF_USERLGI"),40)
		
		nLin++
		nItem++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay "T O T A L  G E R A L --->  ("+AllTrim(Transf(nItem,"@R 999,999"))+" REGISTROS)"
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return