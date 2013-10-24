/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/10/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio cadastro de conta bancaria                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function CADBCO()
	private aOrd    := {"Banco"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "CADBCO"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "CADASTRO BANCARIO"
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
	
	private cBancoDe	:= ""
	private cAgenciaDe	:= ""
	private cContaDe	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco de                                          ³
	//³ mv_par02 - Agencia de                                        ³
	//³ mv_par03 - Conta de                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cBancoDe	:= mv_par01
	cAgenciaDe	:= mv_par02
	cContaDe	:= mv_par03
	
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
/*	cQry := "select * "
	cQry += "from "+RetSqlName("SA6")+" "
	cQry += "where A6_COD = '"+cBancoDe+"' and A6_AGENCIA = '"+cAgenciaDe+"' and A6_NUMCON = '"+cContaDe+"' and D_E_L_E_T_ <> '*' "
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())*/
	
	DbSelectArea("SA6")
	SA6->(DbGoTop())
	SA6->(DbSeek(xFilial("SA6")+cBancoDe+cAgenciaDe+cContaDe,.F.))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
//	BANCO...: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	N.REDUZ.: AAAAAAAAAAAAAAA                                    COD..: 999
//	AGENCIA.: 99999                                              CONTA: 9999999999
//	TITULAR.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	GERENTE.: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA          E-MAIL: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//	TELEFONE: 9999999999                                       CELULAR: 9999999999
//	CIDADE..: AAAAAAAAAAAAAAA-AA                                   CEP: 99.999-999
//	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !SA6->(Eof()) .and. SA6->A6_COD = cBancoDe .and. SA6->A6_AGENCIA = cAgenciaDe .and. SA6->A6_NUMCON = cContaDe
		@nLin,000 psay PadC("*****  D A D O S  C A D A S T R A I S  *****",132)
		
		nLin += 2
		
		@nLin,000 psay "BANCO...: "+SA6->A6_NOME
		@++nLin,000 psay "N.REDUZ.: "+SA6->A6_NREDUZ
		@nLin,061 psay "COD..: "+SA6->A6_COD
		@++nLin,000 psay "AGENCIA.: "+SA6->A6_AGENCIA
		@nLin,061 psay "CONTA: "+SA6->A6_NUMCON
		@++nLin,000 psay "TITULAR.: "+Left(SA6->A6_CORRENT,40)
		@++nLin,000 psay "GERENTE.: "+Left(SA6->A6_CONTATO,40)
		@nLin,060 psay "E-MAIL: "+Left(SA6->A6_EMAIL,50)
		@++nLin,000 psay "TELEFONE: "+AllTrim(SA6->A6_TEL)
		@nLin,059 psay "CELULAR: "+AllTrim(SA6->A6_CELULAR)
		@++nLin,000 psay "CIDADE..: "+AllTrim(SA6->A6_MUN)+"-"+SA6->A6_EST
		@nLin,063 psay "CEP: "+Transf(SA6->A6_CEP,"@R 99.999-999")
		
		nLin += 2
		
		DbSelectArea("SZQ")
		SZQ->(DbGoTop())
		
		if SZQ->(DbSeek(xFilial("SZQ")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON),.F.))
			while !SZQ->(Eof()) .and. SZQ->(ZQ_BANCO+ZQ_AGENCIA+ZQ_CONTA) == SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)
				cTipo := SZQ->ZQ_TIPO
				
				@nLin,000 psay __PrtThinLine()
				
				nLin++
				
				do case
					case cTipo == "1"
						@nLin,000 psay PadC("*****  L I M I T E  D E  C R E D I T O S  *****",132)
					case cTipo == "2"
						@nLin,000 psay PadC("*****  O U T R O S  C R E D I T O S  *****",132)
					case cTipo == "3"
						@nLin,000 psay PadC("*****  A P L I C A C O E S  *****",132)
				endcase
				
				nLin += 2
				
				@nLin,000 psay "DESCRICAO                                  LIMITE    TAXA  VENCTO     OBSERVACAO"
				
				nLin++
				nTotal := 0
				
				while SZQ->ZQ_TIPO == cTipo
//					DESCRICAO                                  LIMITE    TAXA  VENCTO     OBSERVACAO
//					AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99,999,999,999.99  999.99  99/99/99   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
//					0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//					          1         2         3         4         5         6         7         8         9        10        11        12        13
					
					@nLin,000 psay SZQ->ZQ_CREDITO
					@nLin,032 psay Transf(SZQ->ZQ_VALOR,"@E 99,999,999,999.99")
					@nLin,051 psay Transf(SZQ->ZQ_TAXA,"@E 999.99")
					@nLin,059 psay U_ConvData(DToS(SZQ->ZQ_VENCTO),"yy")
					@nLin,070 psay SZQ->ZQ_OBS
					
					nLin++
					nTotal += SZQ->ZQ_VALOR
					
					U_SaltaFolha()
					SZQ->(DbSkip())
				enddo
				
				if !Empty(nTotal)
					@nLin,000 psay "T O T A L"
					@nLin,032 psay Transf(nTotal,"@E 99,999,999,999.99")
				endif
				
				nLin += 2
				
				U_SaltaFolha()
			enddo
		endif
		
		nLinMemo := MlCount(SA6->A6_OBS)
		
		if !Empty(nLinMemo)
			@nLin,000 psay __PrtThinLine()
			
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay PadC("*****  O B S E R V A C O E S  *****",132)
			
			nLin += 2
			
			U_SaltaFolha()
			
			for i := 1 to nLinMemo
				@nLin,000 psay MemoLine(SA6->A6_OBS,130,i)
				
				nLin++
				
				U_SaltaFolha()
			next
		endif
		
		SA6->(DbSkip())
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
return