/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 26/01/12 ¦
   +----------+--------------------------------------------------------¦
   ¦Descrição ¦ Sumazriza Encargos para atualizar subTotais            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function PASZC

	local nSoma	 := 0
	local cQry 	 := ''
	local cTab	 := ''

	cQry := "select ZC_TABELA TAB,ZC_GRUPO GRP, sum(ZC_PERC) nPERC "
	cQry += "from "+RetSqlName("SZC")
    cQry += " where ZC_GRUPO < '96' and ZC_TITULO = 'E' and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZC_TABELA,ZC_GRUPO "

	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	DbGoTop()
	While TEMP->( !Eof() )
	    
		cTAB  := TEMP->TAB
		cGrp  := TEMP->GRP
		cPERC := alltrim(STR(TEMP->nPERC,6,2))
        nSoma := nSoma + TEMP->nPERC          

	   //	msgbox(cgrp+' '+cperc)
        
   		cUPD := ""
		cUPD := "update "+RetSqlName("SZC")
		cUPD += " set ZC_PERC = '"+cPERC+"' " 
 		cUPD += " where ZC_TABELA='"+cTAB+"' and ZC_GRUPO='"+cGRP+"' and ZC_TITULO='T' and D_E_L_E_T_ <> '*' "
        
		TCSqlExec(cUPD)	 
	 	 
		dbSelectArea('TEMP')
		TEMP->(DbSkip())
	
	EndDo
	DbCloseArea("TEMP")
	// atualiza TOTAL ENCARGOS
	    
	cPERC := alltrim(STR(nSoma,6,2))
        
	cUPD := ""
	cUPD := "update "+RetSqlName("SZC")
	cUPD += " set ZC_PERC = '"+cPERC+"' " 
	cUPD += " where ZC_TABELA='"+cTAB+"' and ZC_GRUPO='96' and D_E_L_E_T_ <> '*' "
        
	TCSqlExec(cUPD)

return
            
