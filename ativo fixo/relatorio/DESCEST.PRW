/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 25/09/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao da descricao estendida do Ativo Fixo          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function DESCEST()
	private aOrd    := {"Codigo do Ativo Fixo","Descricao do Ativo Fixo","Numero do Patrimonio","Codigo do Sub Centro"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := PadR(FunName(),Len(SX1->X1_GRUPO))
	private Cabec1  := "ATIVO            DESCRICAO                                 CHAPA"
	private Cabec2  := "DESCRICAO ESTENDIDA"
	private cDesc1  := "DESCRICAO ESTENDIDA DO ATIVO FIXO"
	private cDesc2  := ""
	private cDesc3  := ""
	private ContFun := 0
	private cString := "SN1"
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
	
	private cAtivoIni := ""
	private cAtivoFin := ""
	private cPatriIni := ""
	private cPatriFin := ""
	private cSubCenIni := ""
	private cSubCenFin := ""
	private cDescIni := ""
	private cDescFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Ativo de                                          ³
	//³ mv_par02 - Ativo ate                                         ³
	//³ mv_par03 - Patrimonio de                                     ³
	//³ mv_par04 - Patrimonio ate                                    ³
	//³ mv_par05 - Sub Centro de                                     ³
	//³ mv_par06 - Sub Centro ate                                    ³
	//³ mv_par07 - Descricao de                                      ³
	//³ mv_par08 - Descricao ate                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	PutSx1(cPerg,"01","Ativo de","","","mv_ch1","C",10,0,0,"G","","SN1","","","mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Ativo ate","","","mv_ch2","C",10,0,0,"G","","SN1","","","mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Patrimonio de","","","mv_ch3","C",5,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Patrimonio ate","","","mv_ch4","C",5,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","Sub Centro de","","","mv_ch5","C",4,0,0,"G","","CTT","","","mv_par05","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"06","Sub Centro ate","","","mv_ch6","C",4,0,0,"G","","CTT","","","mv_par06","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"07","Descricao de","","","mv_ch7","C",40,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"08","Descricao ate","","","mv_ch8","C",40,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","")
	
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
	
	cAtivoIni := mv_par01
	cAtivoFin := mv_par02
	cPatriIni := mv_par03
	cPatriFin := mv_par04
	cSubCenIni := mv_par05
	cSubCenFin := mv_par06
	cDescIni := mv_par07
	cDescFin := mv_par08
	
	RptStatus({|| RunReport()},Titulo)
return

static function RunReport()
	local cQry := ""
	
	cQry := "select N1_CBASE, N1_ITEM, N1_DESCRIC, N1_CHAPA, N1_CUSTBEM, N2_SEQUENC, N2_HISTOR "
	cQry += "from "+RetSqlName("SN1")+" SN1 inner join "+RetSqlName("SN2")+" SN2 on (N1_CBASE = N2_CBASE and N1_ITEM = N2_ITEM) "
	cQry += "where (N1_CBASE between '"+cAtivoIni+"' and '"+cAtivoFin+"') and (N1_CHAPA between '"+cPatriIni+"' and '"+cPatriFin+"') and (N1_CUSTBEM between '"+cSubCenIni+"' and '"+cSubCenFin+"') and (N1_DESCRIC between '"+cDescIni+"' and '"+cDescFin+"') and SN1.D_E_L_E_T_ <> '*' and SN2.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by N1_CBASE, N1_ITEM, N2_SEQUENC"
	elseif nOrdem == 2
		cQry += "order by N1_DESCRIC, N1_CBASE, N1_ITEM, N2_SEQUENC"
	elseif nOrdem == 3
		cQry += "order by N1_CHAPA, N1_CBASE, N1_ITEM, N2_SEQUENC"
	elseif nOrdem == 4
		cQry += "order by N1_CUSTBEM, N1_CBASE, N1_ITEM, N2_SEQUENC"
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
		
		//ATIVO            DESCRICAO                                 CHAPA
		//DESCRICAO ESTENDIDA
		//9999999999-0001  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA  99999
		//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//          1         2         3         4         5         6         7         8         9        10        11        12
		
		@nLin,000 psay TEMP->N1_CBASE+"-"+TEMP->N1_ITEM
		@nLin,017 psay TEMP->N1_DESCRIC
		@nLin,059 psay TEMP->N1_CHAPA
		
		cAtivo := TEMP->N1_CBASE
		nLin += 2
		
		while cAtivo == TEMP->N1_CBASE
			if lAbortPrint
				@nLin,000 psay "*** CANCELADO PELO OPERADOR ***"
				
				exit
			endif         
			
			@nLin,000 psay AllTrim(TEMP->N2_HISTOR)
			
			nLin++
			
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