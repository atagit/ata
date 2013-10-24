/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/08/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de bancos a pagar por fornecedor              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

#define _MAX 80

user function BCOFOR()
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "BCOFOR"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "REL. P/ DEPOSITO BANCARIO"
	private ContFun := 0
	private cString := "SA2"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
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
	
	private cForIni	:= ""
	private cForFin	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Fornecedor de                                     ³
	//³ mv_par02 - Fornecedor ate                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cForIni := mv_par01
	cForFin := mv_par02
	
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
	local nCont := 1
	local cDef := ""
	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbGoTop())
	SA2->(DbSeek(xFilial("SA2")+cForIni))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin--
	
	while !SA2->(Eof()) .and. SA2->A2_COD >= cForIni .and. SA2->A2_COD <= cForFin
//				      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//				CNPJ/CPF: 99.999.999/9999-99                    CODIGO: 999999-99
//				END: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//				     AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//		       +==================================================================+
//		       | RESPONSAVEL: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA            |
//		       | TELEFONE...: 99 99999-9999  /  99 99999-9999                     |
//		       | E-MAIL.....: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  |
//		       |------------------------------------------------------------------|
//		       | IT  DATA      BANCO                   COD  AGENCIA  CONTA        |
//		       | 01  99/99/99  AAAAAAAAAAAAAAAAAAAA    999  99999    99999999999  |
//		       | 02  99/99/99  AAAAAAAAAAAAAAAAAAAA    999  99999    99999999999  |
//		       | 03  99/99/99  AAAAAAAAAAAAAAAAAAAA    999  99999    99999999999  |
//		       | 04  99/99/99  AAAAAAAAAAAAAAAAAAAA    999  99999    99999999999  |
//		       | 05  99/99/99  AAAAAAAAAAAAAAAAAAAA    999  99999    99999999999  |
//		       +==================================================================+
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890
//		          1         2         3         4         5         6         7         8
		cEndereco := AllTrim(SA2->A2_END)+", "+AllTrim(SA2->A2_BAIRRO)+" - "+AllTrim(SA2->A2_MUN)+"/"+SA2->A2_EST
		
		@nLin,000 psay PadC(AllTrim(SA2->A2_NOME),_MAX)
		
		if Len(AllTrim(SA2->A2_CGC)) == 14
			@++nLin,008 psay "CNPJ: "+Transf(SA2->A2_CGC,"@R 99.999.999/9999-99")
		else
			@++nLin,008 psay "CPF.: "+Transf(SA2->A2_CGC,"@R 999.999.999-99")
		endif
		
		@nLin,056 psay "CODIGO: "+SA2->A2_COD+"-"+SA2->A2_LOJA
		@++nLin,008 psay "END.: "+Left(cEndereco,60)
		
		if Len(cEndereco) > 60
			@++nLin,014 psay SubStr(cEndereco,61,60)
		endif
		
		@++nLin,007 psay "+==================================================================+"
		@++nLin,007 psay "| RESPONSAVEL: "+SA2->A2_NOMRESP
		@nLin,074 psay "|"
		@++nLin,007 psay "| TELEFONE...: "+IIf(!Empty(SA2->A2_FONE1),SA2->A2_DDD1+" "+Transf(SA2->A2_FONE1,"@E 9999-9999"),"")+IIf(!Empty(SA2->A2_FONE2),"  /  "+SA2->A2_DDD2+" "+Transf(SA2->A2_FONE2,"@E 9999-9999"),"")
		@nLin,074 psay "|"
		@++nLin,007 psay "| E-MAIL.....: "+SA2->A2_EMAIL1
		@nLin,074 psay "|"
		@++nLin,007 psay "|------------------------------------------------------------------|"
		@++nLin,007 psay "| IT  DATA      BANCO                   COD  AGENCIA  CONTA        |"
		@++nLin,007 psay "| 01  "
		@nLin,013 psay U_ConvData(DToS(SA2->A2_DTBCO1),"yy")
		@nLin,023 psay SA2->A2_NBCO1
		@nLin,047 psay SA2->A2_BCO1
		@nLin,052 psay SA2->A2_AG1
		@nLin,061 psay SA2->A2_CC1
		@nLin,074 psay "|"
		@++nLin,007 psay "| 02  "
		@nLin,013 psay U_ConvData(DToS(SA2->A2_DTBCO2),"yy")
		@nLin,023 psay SA2->A2_NBCO2
		@nLin,047 psay SA2->A2_BCO2
		@nLin,052 psay SA2->A2_AG2
		@nLin,061 psay SA2->A2_CC2
		@nLin,074 psay "|"
		@++nLin,007 psay "| 03  "
		@nLin,013 psay U_ConvData(DToS(SA2->A2_DTBCO3),"yy")
		@nLin,023 psay SA2->A2_NBCO3
		@nLin,047 psay SA2->A2_BCO3
		@nLin,052 psay SA2->A2_AG3
		@nLin,061 psay SA2->A2_CC3
		@nLin,074 psay "|"
		@++nLin,007 psay "| 04  "
		@nLin,013 psay U_ConvData(DToS(SA2->A2_DTBCO4),"yy")
		@nLin,023 psay SA2->A2_NBCO4
		@nLin,047 psay SA2->A2_BCO4
		@nLin,052 psay SA2->A2_AG4
		@nLin,061 psay SA2->A2_CC4
		@nLin,074 psay "|"
		@++nLin,007 psay "| 05  "
		@nLin,013 psay U_ConvData(DToS(SA2->A2_DTBCO5),"yy")
		@nLin,023 psay SA2->A2_NBCO5
		@nLin,047 psay SA2->A2_BCO5
		@nLin,052 psay SA2->A2_AG5
		@nLin,061 psay SA2->A2_CC5
		@nLin,074 psay "|"
		@++nLin,007 psay "+==================================================================+"
		
		nLin++
		
		@nLin,000 psay Replicate("-",80)
		
		nLin++
		nCont++
		
		if nCont > 3
			U_SaltaFolha()
			
			nLin--
			nCont := 1
		endif
		
		SA2->(DbSkip())
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return