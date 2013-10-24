/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 09/04/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Movimentação Financeira                               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function MOVFIN()
	private aOrd    := {"Data de Disponibilizacao"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "MOVFIN"
	private Cabec1  := "DT MOVIMEN | NATUREZA                                  | BANCO"
	private Cabec2  := "TP | TITULO            |              VALOR | MOEDA | TP DOC | RP | MOT BX | BENEFICIARIO                   | HISTORICO                                | LA"
	private cDesc1  := "MOVIMENT. FINANCEIRA"
	private ContFun := 0
	private cString := "SE5"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nTotGrp := {}
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	private cMvtIni := ""
	private cMvtFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Movto Financeiro de (aaaamm)                      ³
	//³ mv_par02 - Movto Financeiro ate (aaaamm)                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cMvtIni := mv_par01
	cMvtFin := mv_par02
	
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
	local nTotItem := 0
	
	cQry := "select E5_DATA, E5_DTDISPO, E5_NATUREZ, E5_BANCO, E5_VALOR, E5_MOEDA, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_TIPODOC, E5_RECPAG, E5_MOTBX, E5_BENEF, E5_HISTOR, E5_LA "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where D_E_L_E_T_ <> '*' and left(E5_DATA,6) between '"+cMvtIni+"' and '"+cMvtFin+"' and E5_MOTBX not in ('DAC','FAT','DEV','VEN','CHQ') and E5_TIPODOC not in ('CH','EC','CA') "
	
	do case 
		case nOrdem == 1
			cQry += "order by E5_DTDISPO, E5_NATUREZ, E5_BANCO, E5_VALOR"
	endcase
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	TEMP->(DbGoTop())
	ProcRegua(TEMP->(RecCount()))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	while !TEMP->(Eof())
		cDtDispo := TEMP->E5_DATA
		cNaturez := TEMP->E5_NATUREZ
		cBanco := TEMP->E5_BANCO
		
		@nLin,000 psay U_Negrito(.T.)+U_ConvData(cDtDispo)
		@nLin,013 psay AllTrim(cNaturez)+" - "+If(SED->(DbSeek(xFilial("SED")+cNaturez,.F.)),SED->ED_DESCRIC,"")
		@nLin,058 psay AllTrim(cBanco)+" - "+If(SA6->(DbSeek(xFilial("SA6")+cBanco,.F.)),SA6->A6_NOME,"")+U_Negrito(.F.)
		
		while cDtDispo == TEMP->E5_DTDISPO .and. cNaturez == TEMP->E5_NATUREZ .and. cBanco == TEMP->E5_BANCO
			nLin++
			
			@nLin,000 psay TEMP->E5_TIPO
			@nLin,005 psay TEMP->E5_NUMERO+"-"+TEMP->E5_PARCELA+"/"+TEMP->E5_PREFIXO
			@nLin,025 psay Transf(TEMP->E5_VALOR,"@E 999,999,999,999.99")
			@nLin,046 psay TEMP->E5_MOEDA
			@nLin,054 psay TEMP->E5_TIPODOC
			@nLin,063 psay TEMP->E5_RECPAG
			@nLin,068 psay TEMP->E5_MOTBX
			@nLin,077 psay TEMP->E5_BENEF
			@nLin,110 psay TEMP->E5_HISTOR
			@nLin,153 psay TEMP->E5_LA
			
			U_SaltaFolha()
			
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		nTotItem++
		
		U_SaltaFolha()
	enddo
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return