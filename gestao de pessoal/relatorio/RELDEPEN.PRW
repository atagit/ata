/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de dependentes                                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELDEPEN()
	private aOrd    := {"Matr. Func.","Nome Func."}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELDEPN"
	private Cabec1  := "FUNCIONARIO                           | DEPENDENTE                     | TIPO    | SEXO      | NASCIM.  | IRRF        | SAL. FAMIL."
	private Cabec2  := ""
	private cDesc1  := "RELACAO DE DEPENTES"
	private cString := "SRB"
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
	
	private cMatDe := ""
	private cMatAte := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Matricula de                                      ³
	//³ mv_par02 - Matricula ate                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cMatDe := mv_par01
	cMatAte := mv_par02
	
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
	cQry := "select RA_MAT, RA_NOME, RB_NOME, RB_GRAUPAR, RB_SEXO, RB_TIPIR, RB_TIPSF, RB_DTNASC "
	cQry += "from "+RetSqlName("SRA")+" SRA inner join "+RetSqlName("SRB")+" SRB on (RA_MAT = RB_MAT) "
	cQry += "where (RA_MAT between '"+cMatDe+"' and '"+cMatAte+"') and SRA.D_E_L_E_T_ <> '*' and SRB.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by RA_MAT, RB_COD"
	else
		cQry += "order by RA_NOME, RA_MAT, RB_COD"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
//	FUNCIONARIO                           | DEPENDENTE                     | TIPO    | SEXO      | NASCIM.  | IRRF        | SAL. FAMIL.
//	999999-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAA   AAAAAAAAA   99/99/99   AAAAAAAAAAA   AAAAAAAAAAA
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nReg := 0
	
	while !TEMP->(Eof())
		cMatFunc := TEMP->RA_MAT
		nLin++
		
		@nLin,000 psay TEMP->RA_MAT+"-"+TEMP->RA_NOME
		
		while !TEMP->(Eof()) .and. cMatFunc == TEMP->RA_MAT
			@nLin,040 psay TEMP->RB_NOME
			
			do case
				case TEMP->RB_GRAUPAR == "C"
					@nLin,073 psay "CONJUGE"
				case TEMP->RB_GRAUPAR == "F"
					@nLin,073 psay "FILHO"
				case TEMP->RB_GRAUPAR == "E"
					@nLin,073 psay "ENTEADO"
				case TEMP->RB_GRAUPAR	 == "P"
					@nLin,073 psay "PAI/MAE"
				otherwise
					@nLin,073 psay "OUTROS"
			endcase
			
			@nLin,083 psay IIf(TEMP->RB_SEXO == "M","MASCULINO","FEMININO")
			@nLin,095 psay U_ConvData(TEMP->RB_DTNASC,"yy")
			
			do case
				case TEMP->RB_TIPIR == "1"
					@nLin,106 psay "S/LIM.IDADE"
				case TEMP->RB_TIPIR == "2"
					@nLin,106 psay "ATE 21 ANOS"
				case TEMP->RB_TIPIR == "3"
					@nLin,106 psay "ATE 24 ANOS"
				otherwise
					@nLin,106 psay "NAO E DEP."
			endcase
			
			do case
				case TEMP->RB_TIPSF == "1"
					@nLin,120 psay "S/LIM.IDADE"
				case TEMP->RB_TIPSF == "2"
					@nLin,120 psay "ATE 14 ANOS"
				otherwise
					@nLin,120 psay "NAO E DEP."
			endcase
			
			nLin++
			nReg++
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		@nLin,000 psay __PrtThinLine()
	enddo
	
	nLin++
	
	@nLin,000 psay "TOTAL DE REGISTRO(S)  -->  "+AllTrim(Transf(nReg,"@R 999999"))
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	TEMP->(DbCloseArea())
return