/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 14/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao NF Saida para exportar para Excel             ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#define _EOL Chr(13)+Chr(10)

user function NFSAIEX()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "NFSAIEX"
	private Cabec1  := "TP EMISSAO  NOTA FISCAL   CFOP CLIENTE/FORNECEDOR                  NCM                 TOTAL          IPI          ICM       COFINS          PIS"
	private Cabec2  := ""
	private cDesc1  := "NOTAS FISCAIS DE SAIDA"
	private ContFun := 0
	private cString := "SD2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private nLastKey := 0
	private lFilter := .F.
	private lDic	:= .F.
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	private lExterior := .F.
	
	private cDtIni := ""
	private cDtFin := ""
	private nGerar := 0
	private cPath := ""
	private cArq := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Gerar (1-Impresso/2-Plan. Excel)                  ³
	//³ mv_par04 - Caminho                                           ³
	//³ mv_par05 - Arquivo                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,lDic,aOrd,,Tamanho,,lFilter)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cDtIni := DToS(mv_par01)
	cDtFin := DToS(mv_par02)
	nGerar := mv_par03
	cPath := IIf(Right(AllTrim(mv_par04),1) == "\",AllTrim(mv_par04),AllTrim(mv_par04)+"\")
	cArq := AllTrim(mv_par05)
	
	if nGerar <> 1
		if Empty(cPath)
			MsgAlert("O caminho do arquivo nao foi informado!")
			
			return
		endif
		
		if Empty(cArq)
			MsgAlert("O nome do arquivo nao foi informado!")
			
			return
		endif
	endif
	
	Processa({|| Impr()},"","Aguarde processando...",lAborta)
return

static function Impr()
	local cQry := ""
	local nTotReg := 0
	local aStru := {}
	
	if Select("TEMP") > 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select F2_TIPO, F2_EMISSAO, F2_DOC, F2_SERIE, D2_CF, A1_CGC = case when A1_CGC is not null then A1_CGC else A2_CGC end, A1_NREDUZ = case when A1_NREDUZ is not null then A1_NREDUZ else A2_NREDUZ end, B1_POSIPI, D2_TOTAL, D2_VALIPI, D2_VALICM, D2_VALIMP5, D2_VALIMP6 "
	cQry += "from "+RetSqlName("SF2")+" SF2 inner join "+RetSqlName("SD2")+" SD2 on (F2_DOC = D2_DOC and F2_SERIE = D2_SERIE and F2_CLIENTE = D2_CLIENTE and F2_LOJA = D2_LOJA) "
	cQry += "	inner join "+RetSqlName("SB1")+" SB1 on (D2_COD = B1_COD) "
	cQry += "	left join "+RetSqlName("SA1")+" SA1 on (F2_CLIENTE = A1_COD and F2_LOJA = A1_LOJA) and F2_TIPO not in ('B','D') "
	cQry += "	left join "+RetSqlName("SA2")+" SA2 on (F2_CLIENTE = A2_COD and F2_LOJA = A2_LOJA) and F2_TIPO in ('B','D') "
	cQry += "where (F2_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and SF2.D_E_L_E_T_ <> '*' and SD2.D_E_L_E_T_ <> '*' "
	cQry += "order by F2_EMISSAO"
	
	tcquery cQry new alias "TEMP"
	count to nTotReg
	
	ProcRegua(nTotReg)
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	if nGerar == 1
		cCbcRef := "Periodo: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin)
		
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
//		TP EMISSAO  NOTA FISCAL   CFOP CLIENTE/FORNECEDOR                  NCM                 TOTAL          IPI          ICM       COFINS          PIS
//		A  99/99/99 999999999 AAA 9999 99999999999999 AAAAAAAAAAAAAAAAAAAA 99999999   999,999,999.99   999,999.99   999,999.99   999,999.99   999,999.99
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		while !TEMP->(Eof())
			@nLin,000 psay TEMP->F2_TIPO
			@nLin,003 psay U_ConvData(TEMP->F2_EMISSAO,"yy")
			@nLin,012 psay TEMP->(F2_DOC+" "+F2_SERIE)
			@nLin,026 psay TEMP->D2_CF
			@nLin,031 psay TEMP->A1_CGC
			@nLin,046 psay TEMP->A1_NREDUZ
			@nLin,067 psay TEMP->B1_POSIPI
			@nLin,078 psay Transf(TEMP->D2_TOTAL,"@E 999,999,999.99")
			@nLin,095 psay Transf(TEMP->D2_VALIPI,"@E 999,999.99")
			@nLin,108 psay Transf(TEMP->D2_VALICM,"@E 999,999.99")
			@nLin,121 psay Transf(TEMP->D2_VALIMP5,"@E 999,999.99")
			@nLin,134 psay Transf(TEMP->D2_VALIMP6,"@E 999,999.99")
			
			nLin++
			
			IncProc()
			U_SaltaFolha()
			TEMP->(DbSkip())
		enddo
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		
		set device to screen
		
		if aReturn[5] == 1
			DbCommitAll()
			
			set printer to
			
			OurSpool(wnrel)
		endif
		
		MS_Flush()
	else
		cArqCompleto := cPath+cArq+".CSV"
		nArq := FCreate(cArqCompleto)
		
		if nArq == -1
			MsgAlert("Nao conseguiu criar o arquivo!")
			
			return
		endif
		
		FWrite(nArq,"TIPO;EMISSAO;NOTA FISCAL;CFOP;CLIENTE/FORNECEDOR;NCM;TOTAL;IPI;ICMS;COFINS;PIS"+_EOL)
		
		while !TEMP->(Eof())
			FWrite(nArq,TEMP->F2_TIPO+";"+U_ConvData(TEMP->F2_EMISSAO)+";"+TEMP->F2_DOC+" "+TEMP->F2_SERIE+";"+TEMP->D2_CF+";"+TEMP->A1_CGC+" "+TEMP->A1_NREDUZ+";"+;
						TEMP->B1_POSIPI+";"+Transf(TEMP->D2_TOTAL,"@E 99,999,999,999,999.99")+";"+Transf(TEMP->D2_VALIPI,"@E 999,999,999.99")+";"+;
						Transf(TEMP->D2_VALICM,"@E 999,999,999.99")+";"+Transf(TEMP->D2_VALIMP5,"@E 999,999,999.99")+";"+Transf(TEMP->D2_VALIMP6,"@E 999,999,999.99")+_EOL)
			
			TEMP->(DbSkip())
		enddo
		
		FClose(nArq)
		
		oExcel := MSExcel():New()
		
		oExcel:WorkBooks:Open(cArqCompleto)
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
		
		FErase(cArqCompleto)
/*		aStru := {}		//TEMP->(DbStruct())
		
		AAdd(aStru,{"TIPO","C",1,0})
		AAdd(aStru,{"EMISSAO","D",8,0})
		AAdd(aStru,{"NFISCAL","C",13,0})
		AAdd(aStru,{"CFOP","C",5,0})
		AAdd(aStru,{"CGC","C",14,0})
		AAdd(aStru,{"RAZSOCIAL","C",20,0})
		AAdd(aStru,{"NCM","C",10,0})
		AAdd(aStru,{"TOTAL","N",17,2})
		AAdd(aStru,{"IPI","N",14,2})
		AAdd(aStru,{"ICMS","N",14,2})
		AAdd(aStru,{"COFINS","N",14,2})
		AAdd(aStru,{"PIS","N",14,2})
		
		cTemp := CriaTrab(aStru, .T.)
		
		DbUseArea(.T.,"DBFCDX",cTemp,"TMP",.F.,.F.)
		DbSelectArea("TEMP")
		TCSetField("TEMP","F2_EMISSAO","D",8,0)
		TCSetField("TEMP","D2_TOTAL","N",17,2)
		TCSetField("TEMP","D2_VALIPI","N",14,2)
		TCSetField("TEMP","D2_VALICM","N",14,2)
		TCSetField("TEMP","D2_VALIMP5","N",14,2)
		TCSetField("TEMP","D2_VALIMP6","N",14,2)
		
		while !TEMP->(Eof())
			Reclock("TMP",.T.)
				TMP->TIPO		:= TEMP->F2_TIPO
				TMP->EMISSAO	:= TEMP->F2_EMISSAO
				TMP->NFISCAL	:= TEMP->F2_DOC+" "+TEMP->F2_SERIE
				TMP->CFOP		:= TEMP->D2_CF
				TMP->CGC		:= TEMP->A1_CGC
				TMP->RAZSOCIAL	:= TEMP->A1_NREDUZ
				TMP->NCM		:= TEMP->B1_POSIPI
				TMP->TOTAL		:= TEMP->D2_TOTAL
				TMP->IPI		:= TEMP->D2_VALIPI
				TMP->ICMS		:= TEMP->D2_VALICM
				TMP->COFINS		:= TEMP->D2_VALIMP5
				TMP->PIS		:= TEMP->D2_VALIMP6
			MsUnlock()
			
			TEMP->(DbSkip())
		enddo
		
		if !ApOleClient("MsExcel")
			MsgStop("Microsoft Excel nao instalado.")
			
			return
		endif
		
		cArq := cTemp+".DBF"
//		cXls := AllTrim(GetTempPath())+cTemp+".XLS"
		cXls := cLocal
		
		DbSelectArea("TMP")
		TMP->(DbCloseArea())
		__CopyFIle(cArq,cXls)
		
		oExcelApp := MsExcel():New()
		
		oExcelApp:WorkBooks:Open(cXls)
		oExcelApp:SetVisible(.T.)*/
	endif
return