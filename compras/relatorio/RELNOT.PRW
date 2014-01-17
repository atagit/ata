/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/01/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório de notificacao de nao conformidade          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELNOT()
	private aOrd    := {}
	private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELNOT"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE NOTIFICACAO DE N.C."
	private ContFun := 0
	private cString := "SZR"
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Emissao de                                        ³
	//³ mv_par02 - Emissao ate                                       ³
	//³ mv_par03 - Fornecedor de                                     ³
	//³ mv_par04 - Fornecedor ate                                    ³
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
	cQry := "select ZR_EMISSAO, ZR_FORNECE, ZR_LOJA, A2_NREDUZ, ZR_NOTIF, ZR_NUMNC, ZR_NUMPC, ZR_NUMIT, ZR_ACDEV, ZR_TIPO, ZR_ENCERR, ZR_NFISCAL, ZR_SERIE, ZR_DTNF "
	cQry += "from "+RetSqlName("SZR")+" SZR inner join "+RetSqlName("SA2")+" SA2 on (ZR_FORNECE = A2_COD and ZR_LOJA = A2_LOJA) "
	cQry += "where (ZR_EMISSAO between '"+cDtIni+"' and '"+cDtFin+"') and (ZR_FORNECE between '"+cForIni+"' and '"+cForFin+"') and SZR.D_E_L_E_T_ <> '*' and SA2.D_E_L_E_T_ <> '*' "
	cQry += "order by ZR_FORNECE, ZR_LOJA, ZR_EMISSAO"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	SetRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
	Cabec1 := PadC("Referencia: "+U_ConvData(cDtIni)+" a "+U_ConvData(cDtFin),132)
	Cabec2 := "EMISSAO  | NOTIFICACAO                 | PED COMP   | NOTA FISCAL   | DATA NF  | TIPO               | ENCERRADO"
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	EMISSAO  | NOTIFICACAO                 | PED COMP   | NOTA FISCAL   | DATA NF  | TIPO               | ENCERRADO
//	99/99/99   999999 ACEITO COM RESTRICAO   999999-999   999999999-999   99/99/99   APOS O RECEBIMENTO   INCOMPLETA
//	12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	         1         2         3         4         5         6         7         8         9        10        11        12        13        14
	nLin++
	
	while !TEMP->(Eof())
		@nLin,000 psay U_Negrito(.T.)+TEMP->ZR_FORNECE+"-"+TEMP->ZR_LOJA+" "+TEMP->A2_NREDUZ+U_Negrito(.F.)
		
		nLin++
		cFornecedor := TEMP->(ZR_FORNECE+ZR_LOJA)
		
		while !TEMP->(Eof()) .and. TEMP->(ZR_FORNECE+ZR_LOJA) == cFornecedor
			@nLin,000 psay U_ConvData(TEMP->ZR_EMISSAO,"yy")
			@nLin,012 psay TEMP->ZR_NOTIF
			@nLin,019 psay IIf(TEMP->ZR_ACDEV == "1","ACEITO COM RESTRICAO","DEVOLUCAO")
			@nLin,042 psay TEMP->ZR_NUMPC+IIf(Empty(TEMP->ZR_NUMIT)," ","-"+TEMP->ZR_NUMIT)
			@nLin,055 psay TEMP->ZR_NFISCAL+IIf(Empty(TEMP->ZR_SERIE)," ","-"+TEMP->ZR_SERIE)
			@nLin,071 psay U_ConvData(TEMP->ZR_DTNF,"yy")
			@nLin,082 psay IIf(TEMP->ZR_TIPO == "1","NO RECEBIMENTO","APOS O RECEBIMENTO")
			
			if TEMP->ZR_ENCERR == "1"
				@nLin,103 psay "SIM"
			elseif TEMP->ZR_ENCERR == "2"
				@nLin,103 psay "NAO"
			elseif TEMP->ZR_ENCERR == "3"
				@nLin,103 psay "INCOMPLETA"
			endif
			
			nLin++
			
			U_SaltaFolha()
			IncRegua()
			TEMP->(DbSkip())
		enddo
		
		nLin += 2
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	DbSelectArea("TEMP")
return