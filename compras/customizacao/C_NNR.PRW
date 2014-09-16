/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 27/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro de locais de estoque                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"

user function C_NNR()
	private cCadastro := "Locais de Estoque"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisua",0,2},;
						{"Incluir","AxInclui('NNR',NNR->(Recno()),3,,,,'(U_INCLUIRNNR(),.T.)',.F.,,,,,,.T.,,,,,)",0,3},;
						{"Alterar","AxAltera('NNR',NNR->(Recno()),4,,,,,'(U_ALTERARNNR(),.T.)',,,,,,.T.)",0,4},;
						{"Excluir","AxDeleta('NNR',NNR->(Recno()),5,'(U_DELETANNR(),.T.)',,,,,.T.)",0,5}}
	
	DbSelectArea("NNR")
	DbSetOrder(1)
	MBrowse(06,01,22,75,"NNR")
return

user function INCLUIRNNR()
	local aAreaAnt := GetArea()
	
	if RecLock("SX5",.T.)
		SX5->X5_FILIAL := xFilial("SX5")
		SX5->X5_TABELA := "AM"
		SX5->X5_CHAVE := M->NNR_CODIGO
		SX5->X5_DESCRI := M->NNR_DESCRI
		SX5->X5_DESCSPA := M->NNR_DESCRI
		SX5->X5_DESCENG := M->NNR_DESCRI
		
		MsUnLock()
	endif
	
	RestArea(aAreaAnt)
return

user function ALTERARNNR()
	local aAreaAnt := GetArea()
	
	DbSelectArea("SX5")
	SX5->(DbGoTop())
	
	if SX5->(DbSeek(xFilial("SX5")+"AM"+M->NNR_CODIGO,.F.))
		if RecLock("SX5",.F.)
			SX5->X5_DESCRI := M->NNR_DESCRI
			SX5->X5_DESCSPA := M->NNR_DESCRI
			SX5->X5_DESCENG := M->NNR_DESCRI
			
			MsUnLock()
		endif
	else
		MsgAlert("Codigo nao encontrado na tabela AM (SX5)")
	endif
	
	RestArea(aAreaAnt)
return

user function DELETANNR()
	local aAreaAnt := GetArea()
	
	DbSelectArea("SX5")
	SX5->(DbGoTop())
	
	if SX5->(DbSeek(xFilial("SX5")+"AM"+NNR->NNR_CODIGO,.F.))
		if RecLock("SX5",.F.)
			DbDelete()
			MsUnLock()
		endif
	else
		MsgAlert("Codigo nao encontrado na tabela AM (SX5)")
	endif
	
	RestArea(aAreaAnt)
return