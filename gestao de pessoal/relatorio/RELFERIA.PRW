/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 23/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relacao de funcionarios de ferias                     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function RELFERIA()
	private aOrd    := {"Matr. Func.","Nome Func."}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := "RELFERIA"
	private Cabec1  := "                                                                          |                    FERIAS                   |"
	private Cabec2  := "   FUNCIONARIO                           | DEPARTAMENTO                   | DIAS | INICIO   | FINAL    |          VALOR |"
	private cDesc1  := "FUNCIONARIOS DE FERIAS"
	private cString := "SRF"
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
	private cDeptoDe := ""
	private cDeptoAte := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Matricula de                                      ³
	//³ mv_par02 - Matricula ate                                     ³
	//³ mv_par03 - Departamento de                                   ³
	//³ mv_par04 - Departamento ate                                  ³
	//³ mv_par05 - Periodo de                                        ³
	//³ mv_par06 - Periodo ate                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	cMatDe := mv_par01
	cMatAte := mv_par02
	cDeptoDe := mv_par03
	cDeptoAte := mv_par04
	
	Processa({|| Impr(StrTran(mv_par05,"/",""),StrTran(mv_par06,"/",""))},"","Aguarde processando...",lAborta)
	
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

static function Impr(cPerDe,cPerAte)
	local cMesDe := Left(cPerDe,2)
	local cMesAte := Left(cPerAte,2)
	local cAnoDe := Right(cPerDe,4)
	local cAnoAte := Right(cPerAte,4)
	
	cQry := "select MONTH(RH_DATAINI) as MES, YEAR(RH_DATAINI) as ANO, RF_MAT, RA_NOME, QB_DESCRIC, RH_DFERIAS, RH_DATAINI, RH_DATAFIM "
	cQry += "from "+RetSqlName("SRF")+" SRF inner join "+RetSqlName("SRA")+" SRA on (RF_MAT = RA_MAT) "
	cQry += "	inner join "+RetSqlName("SRH")+" SRH on (RF_MAT = RH_MAT) "
	cQry += "	inner join "+RetSqlName("SQB")+" SQB on (RA_DEPTO = QB_DEPTO) "
	cQry += "where (RA_MAT between '"+cMatDe+"' and '"+cMatAte+"') and (QB_DEPTO between '"+cDeptoDe+"' and '"+cDeptoAte+"') and (MONTH(RH_DATAINI) between '"+AllTrim(Str(Val(cMesDe)))+"' and '"+AllTrim(Str(Val(cMesAte)))+"') and (YEAR(RH_DATAINI) between '"+cAnoDe+"' and '"+cAnoAte+"') and SRF.D_E_L_E_T_ <> '*' and SRA.D_E_L_E_T_ <> '*' and SRH.D_E_L_E_T_ <> '*' and SQB.D_E_L_E_T_ <> '*' "
	
	if nOrdem == 1
		cQry += "order by ANO, MES, RF_MAT"
	else
		cQry += "order by ANO, MES, RA_NOME, RF_MAT"
	endif
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	ProcRegua(TEMP->(LastRec()))
	TEMP->(DbGoTop())
	
//	                                                                          |                    FERIAS                   |
//	   FUNCIONARIO                           | DEPARTAMENTO                   | DIAS | INICIO   | FINAL    |          VALOR |
//	   999999-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    999   99/99/99   99/99/99   999,999,999.99
//	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//	          1         2         3         4         5         6         7         8         9        10        11        12        13
	
	while !TEMP->(Eof())
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		cPeriodo := StrZero(TEMP->MES,2)+StrZero(TEMP->ANO,4)
		nReg := 0
		nTotal := 0
		nLin++
		
		@nLin,000 psay PadC("Periodo: "+StrZero(TEMP->MES,2)+"/"+StrZero(TEMP->ANO,4),132)
		
		nLin += 2
		
		while !TEMP->(Eof()) .and. StrZero(TEMP->MES,2)+StrZero(TEMP->ANO,4) == cPeriodo
			nValFerias := ValorFerias(TEMP->RF_MAT)
			
			@nLin,003 psay TEMP->RF_MAT+"-"+TEMP->RA_NOME
			@nLin,043 psay TEMP->QB_DESCRIC
			@nLin,077 psay Transf(TEMP->RH_DFERIAS,"@R 999")
			@nLin,083 psay U_ConvData(TEMP->RH_DATAINI,"yy")
			@nLin,094 psay U_ConvData(TEMP->RH_DATAFIM,"yy")
			@nLin,105 psay Transf(nValFerias,"@E 999,999,999.99")
			
			nLin++
			nReg++
			nTotal += nValFerias
			
			U_SaltaFolha()
			IncProc()
			TEMP->(DbSkip())
		enddo
		
		nLin++
		
		@nLin,000 psay __PrtThinLine()
		
		nLin++
		
		@nLin,000 psay "TOTAL DE REGISTRO(S)  -->  "+AllTrim(Transf(nReg,"@R 999999"))
		@nLin,105 psay Transf(nTotal,"@E 999,999,999.99")
		
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	enddo
	
	TEMP->(DbCloseArea())
return

static function ValorFerias(cMatricula)
	local nValor := 0
	local nProventos := 0
	local nDescontos := 0
	
	cQry := "select RV_TIPOCOD, SUM(RR_VALOR) as RR_VALOR "
	cQry += "from "+RetSqlName("SRR")+" SRR inner join "+RetSqlName("SRV")+" SRV on (RR_PD = RV_COD) "
	cQry += "where RR_MAT = '"+cMatricula+"' and RV_COD <> '445' and RV_TIPOCOD in ('1','2') and SRR.D_E_L_E_T_ <> '*' and SRV.D_E_L_E_T_ <> '*' "
	cQry += "group by RV_TIPOCOD"
	
	tcquery cQry new alias "CON"
	
	DbSelectArea("CON")
	CON->(DbGoTop())
	
	while !CON->(Eof())
		if CON->RV_TIPOCOD == "1"
			nProventos := CON->RR_VALOR
		else
			nDescontos := CON->RR_VALOR
		endif
		
		CON->(DbSkip())
	enddo
	
	nValor := nProventos - nDescontos
	
	CON->(DbCloseArea())
	DbSelectArea("TEMP")
return nValor