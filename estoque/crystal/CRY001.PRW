/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/06/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatorio de Resumo dos Materiais (produtos)          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function CRY001()
	private lAborta := .T.
	
	private cProdIni := ""
	private cProdFin := ""
	private cArmzIni := ""
	private cArmzFin := ""
	private nQtdZerado := 0
	private nQtdNegativo := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Produto de                                        ³
	//³ mv_par02 - Produto ate                                       ³
	//³ mv_par03 - Armazem de                                        ³
	//³ mv_par04 - Armazem ate                                       ³
	//³ mv_par05 - Quant Zerada (1-Sim/2-Nao)                        ³
	//³ mv_par06 - Quant Negativa (1-Sim/2-Nao)                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Pergunte("CRY001")
		cProdIni := mv_par01
		cProdFin := mv_par02
		cArmzIni := mv_par03
		cArmzFin := mv_par04
		nQtdZerado := mv_par05
		nQtdNegativo := mv_par06
		
		GeraRel()
	else
		MsgAlert("Parametros CRY001 nao cadastrado.")
	endif
return

static function GeraRel()
	local cArqDBF := GetMV("MV_DBFCRY")+"CRY001.DBF"
	Local aCampDt := {}		// Campos Data para a Nova Estrutura do Arquivo a ser criado
	local cQry := ""
	
	private cReport := "CRY001"
	private cOpcoes := "1;0;1;Resumo dos Materiais"
	private cParam  := AllTrim(cEmpAnt)+";"+AllTrim(cFilAnt)+";"
	private cArqTRB := ""
	
	cQry := "select B2_COD, B2_LOCAL, left(X5_DESCRI,40) as X5_DESCRI, lefT(B1_DESC,20) as B1_DESC, B1_UM, B1_MATERIA, B2_QATU, B2_CM1, B2_VATU1 "
	cQry += "from "+RetSqlName("SB2")+" SB2 inner join "+RetSqlName("SB1")+" SB1 on (B2_COD = B1_COD) "
	cQry += "	inner join "+RetSqlName("SX5")+" SX5 on (X5_TABELA = 'AM' and B2_LOCAL = X5_CHAVE) "
	cQry += "where (B2_COD between '"+cProdIni+"' and '"+cProdFin+"') and (B2_LOCAL between '"+cArmzIni+"' and '"+cArmzFin+"') and "+IIf(nQtdZerado == 1,"","B2_QATU <> 0 and ")+IIf(nQtdNegativo == 1,"","B2_QATU > 0 and ")+"SB2.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*'"
	
	tcquery cQry alias "TMP" new
	
	DbSelectArea("TMP")
	DbGoTop()
	
	if !TMP->(Eof())
		//Transforma o resultado da Query em DBF
		Processa({|| cArqTRB := U_TransQuery("TMP","TRB",cArqDBF,aCampDt)},"","Aguarde processando...",lAborta)
//		cArqTRB := U_TransQuery("TMP","TRB",cArqDBF,aCampDt)
		
		//Executa Relatório Crystal
		CallCrys(cReport,cParam,cOpcoes)
		
		DbSelectArea(cArqTRB)
		DbCloseArea()
	else
		MsgBox("Não foram encontrados registros para geracao do Relatorio!","Registros nao Encontrados","ALERT")
		
		DbSelectArea("TMP")
		DbCloseArea()
	endif
return