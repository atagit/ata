/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 01/03/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de notas fiscais emitidas via excel           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

user function RELNFEX()
	local oDlg
	local oButton1
	local oButton2
	local oGroup1
	local oRadMenu1
	local nRadMenu1 := 1
	
	define msdialog oDlg title "Gerar Impressao" from 000,000 to 095,237 colors 0,16777215 pixel
		@002,003 group oGroup1 to 029,116 of oDlg color 0,16777215 pixel
		@008,006 radio oRadMenu1 var nRadMenu1 items "Relatorio","Plan. Excel" size 069,017 of oDlg color 0,16777215 pixel
		@032,037 button oButton1 prompt "OK" size 037,012 of oDlg action IIf(nRadMenu1 == 1,Imprimir(oDlg),Excel(oDlg)) pixel
		@032,078 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
	activate msdialog oDlg center
return

static function Excel(oDlg)
	local aStru := {}
	
	Close(oDlg)
	Pergunte("RELNFE1",.F.)
	
	AAdd(aStru,{"TIPO","C",01,00})
	AAdd(aStru,{"NOTA","C",09,00})
	AAdd(aStru,{"SERIE","C",03,00})
	AAdd(aStru,{"EMISSAO","C",09,00})
	AAdd(aStru,{"CODPRO","C",06,00})
	AAdd(aStru,{"DESCPRO","C",150,00})
	AAdd(aStru,{"NCM","C",09,00})
	AAdd(aStru,{"CFOP","C",04,00})
	AAdd(aStru,{"CLASFIS","C",03,00})
	AAdd(aStru,{"QUANT","N",17,06})
	AAdd(aStru,{"VUNIT","N",17,06})
	AAdd(aStru,{"TOTAL","N",17,02})
	AAdd(aStru,{"ICMS","N",14,02})
	AAdd(aStru,{"IPI","N",14,02})
	AAdd(aStru,{"PESOL","N",11,04})
	
	cTemp := CriaTrab(aStru,.T.)
	
	DbUseArea(.T.,"DBFCDX",cTemp,"TMP",.F.,.F.)
	
	cQry := "select D2_TIPO, D2_DOC, D2_SERIE, (right(D2_EMISSAO,2)+'/'+substring(D2_EMISSAO,5,2)+'/'+left(D2_EMISSAO,4)) as D2_EMISSAO, D2_COD, C6_DESCRI, B1_POSIPI, D2_CF, D2_CLASFIS, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_VALICM, D2_VALIPI, C5_PESOL "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SC6")+" SC6 on (SD2.D2_PEDIDO = SC6.C6_NUM and SD2.D2_ITEMPV = SC6.C6_ITEM) "
	cQry += "	inner join "+RetSqlName("SC5")+" SC5 on (SC6.C6_NUM = SC5.C5_NUM) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (SD2.D2_COD = SB1.B1_COD and SD2.D2_LOCAL = SB1.B1_LOCPAD) "
	cQry += "where (D2_EMISSAO between '20121201' and '20121231') and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by D2_TIPO, D2_DOC, D2_SERIE"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		RecLock("TMP",.T.)
			TMP->TIPO := TEMP->D2_TIPO
			TMP->NOTA := TEMP->D2_DOC
			TMP->SERIE := TEMP->D2_SERIE
			TMP->EMISSAO := TEMP->D2_EMISSAO
			TMP->CODPRO := Left(TEMP->D2_COD,6)
			TMP->DESCPRO := TEMP->C6_DESCRI
			TMP->NCM := Left(TEMP->B1_POSIPI,9)
			TMP->CFOP := Left(TEMP->D2_CF,4)
			TMP->CLASFIS := TEMP->D2_CLASFIS
			TMP->QUANT := TEMP->D2_QUANT
			TMP->VUNIT := TEMP->D2_PRCVEN
			TMP->TOTAL := TEMP->D2_TOTAL
			TMP->ICMS := TEMP->D2_VALICM
			TMP->IPI := TEMP->D2_VALIPI
			TMP->PESOL := TEMP->C5_PESOL
		MsUnLock()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	if !ApOleClient("MsExcel")
		MsgStop("Microsoft Excel nao instalado.")
		
		return
	endif
	
	cArq := cTemp+".DBF"
	
	TEMP->(DbCloseArea())
	DbSelectArea("TMP")
	TMP->(DbCloseArea())
	
	__CopyFile(cArq,AllTrim(GetTempPath())+cTemp+".XLS")
	
	oExcelApp := MsExcel():New()
	
	oExcelApp:WorkBooks:Open(AllTrim(GetTempPath())+cTemp+".XLS")
	oExcelApp:SetVisible(.T.)
	
	FErase(cTemp+".DBF")
	FErase(cTemp+".IDX")
return

static function Imprimir(oDlg)
	private aOrd    := {"Tipo+NF"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELNFE2"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := ""
	private cString := "SD2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "G"
	private nTamanho := IIf(Tamanho == "G",220,132)
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= "(N) - Normal | (B) - Beneficiamento | (D) - Devolucao | (C) - Frete"
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cDtIni := ""
	private cDtFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	Close(oDlg)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par02)
	cDtFin := DToS(mv_par03)
	
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
	cQry := "select D2_TIPO, D2_DOC, D2_SERIE, D2_EMISSAO, D2_COD, C6_DESCRI, B1_POSIPI, D2_CF, D2_CLASFIS, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_VALICM, D2_VALIPI, C5_PESOL "
	cQry += "from "+RetSqlName("SD2")+" SD2 inner join "+RetSqlName("SC6")+" SC6 on (SD2.D2_PEDIDO = SC6.C6_NUM and SD2.D2_ITEMPV = SC6.C6_ITEM) "
	cQry += "	inner join "+RetSqlName("SC5")+" SC5 on (SC6.C6_NUM = SC5.C5_NUM) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (SD2.D2_COD = SB1.B1_COD and SD2.D2_LOCAL = SB1.B1_LOCPAD) "
	cQry += "where (D2_EMISSAO between '20121201' and '20121231') and SD2.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' and SC5.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' "
	cQry += "order by D2_TIPO, D2_DOC, D2_SERIE"
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),nTamanho)
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
//		TP NOTA          EMISSAO    PRODUTO                                                   NCM      CFOP CFIS           QUANT          UNIT              TOTAL       ICMS        IPI            PESO
//		A  999999999-AAA 99/99/9999 999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 99999999 9999 999  999,999,999.999 9,999,999.999 999,999,999,999.99 999,999.99 999,999.99 999,999,999.999
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
		
		@nLin,000 psay TEMP->TIPO
		@nLin,003 psay TEMP->DOC+"-"+TEMP->SERIE
		@nLin,017 psay U_ConvData(TEMP->D2_EMISSAO)
		@nLin,028 psay Left(TEMP->D2_COD)+" "+Left(TEMP->C6_DESCRI,50)
		@nLin,086 psay Left(TEMP->B1_POSIPI,8)
		@nLin,095 psay Left(TEMP->D2_CF,4)
		@nLin,100 psay TEMP->CLASFIS
		@nLin,105 psay Transf(TEMP->D2_QUANT,"@E 999,999,999.999")
		@nLin,121 psay Transf(TEMP->D2_PRCVEN,"@E 9,999,999.999")
		@nLin,135 psay Transf(TEMP->D2_TOTAL,"@E 999,999,999,999.99")
		@nLin,154 psay Transf(TEMP->D2_VALICM,"@E 999,999.99")
		@nLin,165 psay Transf(TEMP->D2_VALIPI,"@E 999,999.99")
		@nLin,176 psay Transf(TEMP->C5_PESOL,"@E 999,999,999.999")
		
		nLin++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return