/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 26/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gatilho para retornar soma PERCENTUAL encargos        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function ZCTITULO(cTab,cGrupo)

	local cAlias := Alias()
	local nRet	 := 0
	local nSoma	 := 0
	local cQry 	 := ''

	// gatilho do campo _TITULO='T' - na Inclusão

	cQry := "select sum(ZC_PERC) nPERC "
	cQry += "from "+RetSqlName("SZC")
	
	If !cGrupo == '96'
	  // sumariza ENCARGOS (titulo=E) do grupo posicionado
	  cQry += " where ZC_TABELA ='"+cTab+"' and ZC_GRUPO ='"+cGrupo+"' and ZC_TITULO = 'E' and D_E_L_E_T_ <> '*' "
	Else
	  // sumariza sub-totais dos grupos de encargos (titulo=T) abaixo do grupo=96
	  cQry += " where ZC_TABELA ='"+cTab+"' and ZC_GRUPO <'"+cGrupo+"' and ZC_TITULO = 'T' and D_E_L_E_T_ <> '*' "
    EndIf	

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	nRet := TEMP->nPERC 
	
	DbCloseArea("TEMP")

DbSelectArea(cAlias)

return (nRet)
            
