/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 30/10/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de posicao do cliente (NF's)                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "topconn.ch"

user function POSCLI()
	private aOrd    := {""}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "POSCLI"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "POSICAO DO CLIENTE"
	private ContFun := 0
	private cString := "SE1"
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
	
	private cCliDe := ""
	private cCliAte := ""
	private cLojDe := ""
	private cLojaAte := ""
	private cEmiDe := ""
	private cEmiAte := ""
	private cNatDe := ""
	private cNatAte := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Cliente de                                        ³
	//³ mv_par02 - Cliente ate                                       ³
	//³ mv_par03 - Loja de                                           ³
	//³ mv_par04 - Loja ate                                          ³
	//³ mv_par05 - Emissao de                                        ³
	//³ mv_par06 - Emissao ate                                       ³
	//³ mv_par07 - Natureza de                                       ³
	//³ mv_par08 - Natureza ate                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cCliDe := mv_par01
	cCliAte := mv_par02
	cLojDe := mv_par03
	cLojaAte := mv_par04
	cEmiDe := mv_par05
	cEmiAte := mv_par06
	cNatDe := mv_par07
	cNatAte := mv_par08
	
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
	private lFirst := .T.
	
/*select E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, E1_EMISSAO, E1_VENCREA, E1_BAIXA, E5_MOTBX, E1_VALLIQ, E1_SALDO, E1_NATUREZ, E1_BALGER, E1_FATPREF, E1_FATURA, E1_DTFATUR
from SE1010 SE1 inner join SE5010 SE5 on (E1_NUM = E5_NUMERO and E1_PREFIXO = E5_PREFIXO and E1_CLIENTE = E5_CLIFOR and E1_LOJA = E5_LOJA)
where E1_CLIENTE = '000014' and SE1.D_E_L_E_T_ <> '*' and SE5.D_E_L_E_T_ <> '*'*/
	
	
	cQry := "select * "
	cQry += "from "+RetSqlName("SEF")+" "
	cQry += "where (EF_NUM between '"+cChqIni+"' and '"+cChqFin+"') and EF_BANCO = '"+cBancoDe+"' and EF_AGENCIA = '"+cAgenciaDe+"' and EF_CONTA = '"+cContaDe+"' and EF_TIPO = '' and D_E_L_E_T_ <> '*' "
	cQry += "order by EF_NUM"
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(RecCount()))
	TEMP->(DbGoTop())
	
//	@000,000 psay Chr(27)+Chr(48)
//	@000,000 psay Chr(27)+"C"+Chr(24)
	@000,000 psay Chr(27)+"C"+Chr(24)
	
	while !TEMP->(Eof())
		SE5->(DbSetOrder(11))
		SE5->(DbGoTop())
		
		if SE5->(DbSeek(xFilial("SE5")+cBancoDe+cAgenciaDe+cContaDe+TEMP->EF_NUM,.F.)) .and. TEMP->EF_PREDATA == "T"
			while !SE5->(Eof()) .and. SE5->E5_BANCO == cBancoDe .and. SE5->E5_AGENCIA == cAgenciaDe .and. SE5->E5_CONTA == cContaDe .and. SE5->E5_NUMCHEQ == TEMP->EF_NUM
				if SE5->E5_TIPODOC == "CH"
					dData := SE5->E5_DTDIGIT
				endif
				
				SE5->(DbSkip())
			enddo
		else
			dData := SToD(TEMP->EF_DATA)
		endif
		
		U_Cheque(cBancoDe,cAgenciaDe,cContaDe,TEMP->EF_NUM,TEMP->EF_VALOR,TEMP->EF_BENEF,dData)
		
		@PRow() + 9,000 psay ""
		
		TEMP->(DbSkip())
	enddo
	
	TEMP->(DbCloseArea())
return