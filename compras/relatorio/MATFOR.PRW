/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 15/10/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de fornecedor por material                    ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function MATFOR()
	static oButton1
	static oButton2
	
	private oDlg
	private oFolder1
	private oWBrowse1
	private aWBrowse1 := {}
	private cCodigo := ""
	
	define msdialog oDlg title "MATERIAL" from 000,000 to 245,360 colors 0,16777215 pixel
		FWBrowse1()
		
		@107,139 button oButton1 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
		@107,100 button oButton2 prompt "Imprimir" size 037,012 of oDlg action Imprimir() pixel
	activate msdialog oDlg centered
return

static function FWBrowse1()
	local oOk := LoadBitmap(GetResources(),"LBOK")
	local oNo := LoadBitmap(GetResources(),"LBNO")
	
	DbSelectArea("SX5")
	SX5->(DbGoTop())
	SX5->(DbSeek(xFilial("SX5")+"GM",.F.))
	
	while !SX5->(Eof()) .and. SX5->X5_TABELA == "GM"
		AAdd(aWBrowse1,{.F.,SX5->X5_CHAVE,SX5->X5_DESCRI})
		
		SX5->(DbSkip())
	enddo
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{.F.,"",""})
	endif
	
	@002,003 listbox oWBrowse1 fields header "","CODIGO","DESCRICAO" size 176,100 of oDlg pixel colsizes 50,30
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {IIf(aWBrowse1[oWBrowse1:nAt,1],oOk,oNo),aWBrowse1[oWBrowse1:nAt,2],aWBrowse1[oWBrowse1:nAt,3]}}
		// DoubleClick event
		oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],oWBrowse1:DrawSelect()}
return

static function Imprimir()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := ""
	private Cabec1  := "PRODUTO                                         N. FANTASIA              CNPJ/CPF            CODIGO        PONTUACAO"
	private Cabec2  := ""
	private cDesc1  := "FORNECEDOR POR MATERIAL"
	private ContFun := 0
	private cString := "SX5"
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
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	if nLastKey == 27 ; return ; endif
	
	for i := 1 to Len(aWBrowse1)
		if aWBrowse1[i,1]
			cCodigo += "'"+AllTrim(aWBrowse1[i,2])+"',"
		endif
	next
	
	if !Empty(cCodigo)
		cCodigo := SubStr(cCodigo,1,Len(cCodigo) - 1)
		
		Processa({|| Impr()},"","Aguarde processando...",lAborta)
	endif
	
	Close(oDlg)
	
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
	cQry := "select ZO_GRPMAT, ZO_DGRPMAT, ZO_DFORNEC, ZO_CPFCNPJ, A2_COD, A2_LOJA "
	cQry += "from "+RetSqlName("SZO")+" SZO inner join "+RetSqlName("SA2")+" SA2 on (ZO_CPFCNPJ = A2_CGC) "
	cQry += "where ZO_GRPMAT in ("+cCodigo+") and SZO.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "order by ZO_GRPMAT, ZO_DFORNEC"
	
	tcquery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	PRODUTO                                         N. FANTASIA              CNPJ/CPF            CODIGO        PONTUACAO
//	AAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    AAAAAAAAAAAAAAAAAAAA     99.999.999/9999-99  999999-99        999.99
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		nLin++
		cGrpMat := TEMP->ZO_GRPMAT
		
		@nLin,000 psay TEMP->ZO_GRPMAT
		@nlin,004 psay TEMP->ZO_DGRPMAT
		
		while !TEMP->(Eof()) .and. TEMP->ZO_GRPMAT == cGrpMat
			@nlin,048 psay TEMP->ZO_DFORNEC
			@nlin,072 psay Transf(TEMP->ZO_CPFCNPJ,IIf(Len(TEMP->ZO_CPFCNPJ) == 14,"@R 99.999.999/9999-99","@R 999.999.999-99"))
			@nlin,092 psay TEMP->A2_COD+"-"+TEMP->A2_LOJA
			
			cQry := "select ZV_VALIQF, ZV_FINAVAL, ZV_STATUS "
			cQry += "from "+RetSqlName("SZV")+" "
			cQry += "where ZV_FORNECE = '"+TEMP->A2_COD+"' and ZV_LOJA = '"+TEMP->A2_LOJA+"' and D_E_L_E_T_ <> '*' "
			cQry += "order by ZV_STATUS, ZV_FINAVAL desc"
			
			tcquery cQry New Alias "CON"
			DbSelectArea("CON")
			CON->(DbGoTop())
			
			if !Empty(CON->ZV_VALIQF)
				@nLin,110 psay Transf(CON->ZV_VALIQF,"@E 999.99")
			endif
			
			CON->(DbCloseArea())
			
			nLin++
			
			U_SaltaFolha()
			
			TEMP->(DbSkip())
		enddo
		
		nLin++
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return