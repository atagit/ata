/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 25/10/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao dos requisitos de aquisicao de servico        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELREQU()
	private aOrd    := {"Codigo"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := PadR(FunName(),Len(SX1->X1_GRUPO))
	private Cabec1  := "CODIGO  DESCRICAO                                                                                              CRITICO"
	private Cabec2  := ""
	private cDesc1  := "REQUISITO AQUISICAO SERVICO"
	private cDesc2  := ""
	private cDesc3  := ""
	private ContFun := 0
	private cString := "SZX"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private limite := 132
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	private nomeprog := FunName()
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cCodIni := ""
	private cCodFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Codigo de                                         ³
	//³ mv_par02 - Codigo ate                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	PutSx1(cPerg,"01","Codigo de","","","mv_ch1","C",4,0,0,"G","","SZX","","","mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Codigo ate","","","mv_ch2","C",4,0,0,"G","","SZX","","","mv_par02","","","","","","","","","","","","","","","","")
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	if nLastKey == 27
		return
	endif
	
	SetDefault(aReturn,cString)
	
	nTipo := If(aReturn[4]==1,15,18)
	nOrdem := aReturn[8]
	
	if nLastKey == 27
		return
	endif
	
	cCodIni := mv_par01
	cCodFin := mv_par02
	
	RptStatus({|| RunReport()},Titulo)
return

static function RunReport()
	local cQry := ""
	local cCric := ""
	
	cQry := "select ZX_CODIGO, ZX_DESCRIC, ZX_MA, ZX_SST, ZX_QUA, ZY_ITEM, ZY_REQUISI "
	cQry += "from "+RetSqlName("SZX")+" SZX inner join "+RetSqlName("SZY")+" SZY on (ZX_CODIGO = ZY_CODIGO) "
	cQry += "where (ZX_CODIGO between '"+cCodIni+"' and '"+cCodFin+"') and SZX.D_E_L_E_T_ <> '*' and SZY.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by ZX_CODIGO, ZY_ITEM"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	
	while !TEMP->(Eof())
		if lAbortPrint
			@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
			
			exit
		endif
		
		U_SaltaFolha()
		
		//CODIGO  DESCRICAO                                                                                              CRITICO
		//9999    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   MA/SST/QUA
		//        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		//01 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		//   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//          1         2         3         4         5         6         7         8         9        10        11        12
		
		cDesc := AllTrim(TEMP->ZX_DESCRIC)
		cCod := TEMP->ZX_CODIGO
		cCric := ""
		
		@nLin,000 psay U_Negrito(.T.)+TEMP->ZX_CODIGO
		@nLin,008 psay MemoLine(cDesc,100,1)
		
		if TEMP->ZX_MA == "T"
			cCric += "MA/"
		endif
		
		if TEMP->ZX_SST == "T"
			cCric += "SST/"
		endif
		
		if TEMP->ZX_QUA == "T"
			cCric += "QUA"
		endif
		
		@nLin,111 psay SubStr(cCric,1,Len(cCric) - 1)
		
		if MLCount(cDesc,100) > 1
			for k := 2 to MLCount(cDesc,100)
				nLin++
				
				@nLin,008 psay MemoLine(cDesc,100,k)
			next
		endif
		
		@nLin,000 psay U_Negrito(.F.)
		
		while TEMP->ZX_CODIGO == cCod
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif         
			
			nLin++
			cReq := AllTrim(TEMP->ZY_REQUISI)
			
			@nLin,000 psay TEMP->ZY_ITEM
			@nLin,003 psay MemoLine(cReq,120,1)
			
			if MLCount(cReq,120) > 1
				for k := 2 to MLCount(cReq,120)
					nLin++
					
					U_SaltaFolha()
					
					@nLin,003 psay MemoLine(cReq,120,k)
				next
			endif
			
			U_SaltaFolha()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		U_SaltaFolha()
		
		@nLin,000 psay __PrtThinLine()
		
		nLin++
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
	
	set device to screen
	
	if aReturn[5] == 1
		DbCommitAll()
		
		set printer to
		
		OurSpool(wnrel)
	endif
	
	Ms_Flush()
return