/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 19/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de produtos                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

#define _MEMTAM 129

user function RELPRO()
	private aOrd    := {"Codigo","Descricao","Tipo","Grupo"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELPRO"
	private Cabec1  := "CODIGO | AM | UN | DESCRICAO                                          | MATERIAL        | GRUPO | BLOQ"
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE PRODUTOS"
	private ContFun := 0
	private cString := "SB1"
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
	
	private cProdDe := ""
	private cProdAte := ""
	private cTipoDe := ""
	private cTipoAte := ""
	private cGrupDe := ""
	private cGrupAte := ""
	private nBloqueado := 0
	private cArmazDe := ""
	private cArmazAte := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Produto de                                        ³
	//³ mv_par02 - Produto ate                                       ³
	//³ mv_par03 - Tipo de                                           ³
	//³ mv_par04 - Tipo ate                                          ³
	//³ mv_par05 - Grupo de                                          ³
	//³ mv_par06 - Grupo ate                                         ³
	//³ mv_par07 - Bloqueados  (1-Sim/2-Nao)                         ³
	//³ mv_par08 - Armazem de                                        ³
	//³ mv_par09 - Armazem ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cProdDe := mv_par01
	cProdAte := mv_par02
	cTipoDe := mv_par03
	cTipoAte := mv_par04
	cGrupDe := mv_par05
	cGrupAte := mv_par06
	nBloqueado := mv_par07
	cArmazDe := mv_par08
	cArmazAte := mv_par09
	
	if nLastKey == 27 ; return ; endif
	
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
	local nTotal := 0
	local cDescCient := ""
	
	cQry := "select B1_COD, B1_LOCPAD, B1_UM, B1_TIPO, B1_DESC, B1_MATERIA, B1_GRUPO, B5_CEME+' '+B5_CEME1+' '+B5_CEME2+' '+B5_CEME3+' '+B5_CEME4+' '+B5_CEME5+' '+B5_CEME6 as B5_CEME, B1_MSBLQL "
	cQry += "from "+RetSqlName("SB1")+" SB1 inner join "+RetSqlName("SB5")+" SB5 on (B1_COD = B5_COD) "
	cQry += "where (B1_COD between '"+cProdDe+"' and '"+cProdAte+"') and "+;
			"(B1_LOCPAD between '"+cArmazDe+"' and '"+cArmazAte+"') and "+;
			"(B1_TIPO between '"+cTipoDe+"' and '"+cTipoAte+"') and "+;
			"(B1_GRUPO between '"+cGrupDe+"' and '"+cGrupAte+"') and "+;
			"B1_MSBLQL in ("+IIf(nBloqueado == 1,"'1'","'','2'")+") and SB1.D_E_L_E_T_ <> '*' and SB5.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by B1_COD, B1_LOCPAD"
	elseif nOrdem == 2
		cQry += "order by B1_DESC, B1_COD, B1_LOCPAD"
	elseif nOrdem == 3
		cQry += "order by B1_TIPO, B1_COD, B1_LOCPAD"
	elseif nOrdem == 4
		cQry += "order by B1_GRUPO, B1_COD, B1_LOCPAD"
	endif
	
	tcquery cQry New Alias "TEMP"
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	//CODIGO | AM | UN | DESCRICAO                                          | MATERIAL        | GRUPO | BLOQ
	//A123456789B123456789C123456789D123456789E123456789F123456789G123456789H123456789I123456789J123456789K123456789L123456789M123456789
	//          1         2         3         4         5         6         7         8         9        10        11        12
	//AAAAAA   AA   AA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAA   AAAAA   AAA
	
	while !TEMP->(Eof())
		nLin++
		
		@nLin,000 psay LefT(TEMP->B1_COD,6)
		@nLin,009 psay TEMP->B1_LOCPAD
		@nLin,014 psay TEMP->B1_UM
		@nLin,019 psay TEMP->B1_DESC
		@nLin,072 psay TEMP->B1_MATERIA
		@nLin,090 psay TEMP->B1_GRUPO
		@nLin,098 psay IIf(TEMP->B1_MSBLQL == "1","SIM","NAO")
		
		cDescCient := AllTrim(TEMP->B5_CEME)
		
		for k := 1 to MLCount(cDescCient,_MEMTAM)
			nLin++
			
			U_SaltaFolha()
			
			@nLin,000 psay MemoLine(cDescCient,_MEMTAM,k)
		next
		
		nLin++
		nTotal++
		
		U_SaltaFolha()
		IncProc()
		TEMP->(DbSkip())
	enddo
	
	nLin += 2
	
	U_SaltaFolha()
	
	@nLin  ,000 psay __PrtThinLine()
	@++nLin,000 psay "TOTAL: "+Transf(nTotal,"@E 999,999,999,999")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return