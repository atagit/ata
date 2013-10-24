/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 26/07/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Antes da exclusão da SF2                              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

user function SF2520E()
	local cServer := GetMV("MV_RELSERV")
	local cPassword := GetMV("MV_RELPSW")
	local cAccount := GetMV("MV_RELACNT")
	local cSubject := "Cancelamento Nota Fiscal"
	local cTo := "fiscal@ata.ind.br"
	local cMensagem := ""
	local cEmp := ""
	
	do case
		case cEmpAnt == "01" ; cEmp := "ATA"
		case cEmpAnt == "02" ; cEmp := "ATF"
		otherwise ; cEmp := "TESTE"
	endcase
	
	cMensagem := "<html> "
	cMensagem += "Nota Fiscal de Saida <b>"+SF2->F2_DOC+"-"+AllTrim(SF2->F2_SERIE)+" "+If(SA1->(DbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),.F.)),SA1->A1_NREDUZ,"")+"</b> da empresa "+cEmp+" foi cancelada. "
	cMensagem += "</html> "
	
	if APMsgNoYes("Cancelar nota fiscal?")
		U_EnvEmail(.T.,.F.,cServer,cAccount,cPassword,cTo,,cSubject,cMensagem)
	endif
return