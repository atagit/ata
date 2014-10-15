/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/09/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de itens para solicitacao de compra           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELSC()
	private aOrd    := {"Codigo"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELSC"
	private Cabec1  := "   PRODUTO                                                    UN  AM     PNT.PED     ESTOQUE         QUANT REQ"
	private Cabec2  := ""
	private cDesc1  := "RELACAO PARA SOLICITAR COMPRA"
	private cDesc1  := "REL. P/ SOLICITAR COMPRA"
	private cString := "SC1"
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
	
	private cSeparador := ""
	private cProd := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Separador                                         ³
	//³ mv_par02 - Produto(s)                                        ³
	//³ mv_par03 - Produto(s)                                        ³
	//³ mv_par04 - Produto(s)                                        ³
	//³ mv_par05 - Produto(s)                                        ³
	//³ mv_par06 - Produto(s)                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cSeparador := mv_par01
	cProd := AllTrim(mv_par02)+IIf(Right(AllTrim(mv_par02),1) == cSeparador,"",cSeparador)
	
	if !Empty(mv_par03)
		cProd += AllTrim(mv_par03)+IIf(Right(AllTrim(mv_par03),1) == cSeparador,"",cSeparador)
	endif
	
	if !Empty(mv_par04)
		cProd += AllTrim(mv_par04)+IIf(Right(AllTrim(mv_par04),1) == cSeparador,"",cSeparador)
	endif
	
	if !Empty(mv_par05)
		cProd += AllTrim(mv_par05)+IIf(Right(AllTrim(mv_par05),1) == cSeparador,"",cSeparador)
	endif
	
	if !Empty(mv_par06)
		cProd += AllTrim(mv_par06)+IIf(Right(AllTrim(mv_par06),1) == cSeparador,"",cSeparador)
	endif
	
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
	local cProdutos := ""
	local aProdutos := {}
	
	aProdutos := StrTokArr(cProd,cSeparador)
	cProdutos := "'"+aProdutos[1]+"'"
	
	for i := 2 to Len(aProdutos)
		cProdutos += ",'"+aProdutos[i]+"'"
	next i
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select B1_COD, B1_DESC, B1_UM, B1_LOCPAD, B2_QATU, B1_EMIN, B1_CEME "
	cQry += "from "+RetSqlName("SB1")+" SB1 inner join "+RetSqlName("SB2")+" SB2 on (B1_COD = B2_COD and B1_LOCPAD = B2_LOCAL) "
	cQry += "where B1_COD in ("+cProdutos+") and SB1.D_E_L_E_T_ <> '*' and SB2.D_E_L_E_T_ <> '*' "
	cQry += "order by B1_COD"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
//	   PRODUTO                                                    UN  AM     PNT.PED     ESTOQUE         QUANT REQ
//	   AAA999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  AA  99  999,999.99  999,999.99        ___________
//	
//	   ULT.PED.: 999999       EMISSAO: 99/99/99       FORNECEDOR: AAAAAAAAAAAAAAAAAAAA       PRC.UNIT.: 999,999.99
//	------------------------------------------------------------------------------------------------------------------------------------
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nReg := 1
		nLin++
		
		while !TEMP->(Eof()) .and. nReg <= 7
			@nLin,003 psay Left(TEMP->B1_COD,6)
			@nLin,010 psay TEMP->B1_DESC
			@nLin,062 psay TEMP->B1_UM
			@nLin,066 psay TEMP->B1_LOCPAD
			@nLin,070 psay Transf(TEMP->B1_EMIN,"@E 999,999.99")
			@nLin,082 psay Transf(TEMP->B2_QATU,"@E 999,999.99")
			@nLin,100 psay "___________"
			
			nLin += 2
			
			cQry := "select top 1 C7_NUM, C7_EMISSAO, C7_FORNECE, C7_NOMFORN, C7_DATPRF, C7_QUANT, C7_PRECO, B1_EMIN, C7_TOTAL, C7_QUJE, B1_COD, C7_CONAPRO "
			cQry += "from "+RetSqlName("SB1")+" SB1 inner join "+RetSqlName("SB2")+" SB2 on (B1_COD = B2_COD and B1_LOCPAD = B2_LOCAL) "
			cQry += "		inner join "+RetSqlName("SC7")+" SC7 on (B1_COD = C7_PRODUTO) "
			cQry += "where B1_COD = '"+TEMP->B1_COD+"' and SB1.D_E_L_E_T_ <> '*' and SC7.D_E_L_E_T_ <> '*' "
			cQry += "order by SC7.C7_NUM desc"
			
			tcquery cQry new alias "CON"
			
			DbSelectArea("CON")
			
			@nLin,003 psay "ULT.PED.: "+CON->C7_NUM
			@nLin,026 psay "EMISSAO: "+U_ConvData(CON->C7_EMISSAO,"yy")
			@nLin,050 psay "FORNECEDOR: "+CON->C7_NOMFORN
			@nLin,089 psay "PRC.UNIT.: "+AllTrim(Transf(CON->C7_PRECO,"@E 999,999.99"))
			
			CON->(DbCloseArea())
			
			nLin += 2
			
			@nLin,000 psay "------------------------------------------------------------------------------------------------------------------------------------"
			
			nLin += 2
			nReg++
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin += 5
		
		@nLin+1,000 psay Padc("         Solicitado por                           Verificado por                            Aprovado por         ",132)
		@nLin+2,000 psay Padc("_______________________________          _______________________________          _______________________________",132)
		@nLin+3,000 psay Padc("           /       /                                /       /                                /       /           ",132)
		
		nRdpPag++
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		
		nReg := 1
	enddo
	
	DbSelectArea("TEMP")
return