/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/11/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Incluir produto MOD                                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function INCMOD(cCC,cDesc,cOpc)
	local cNumCC := AllTrim(cCC)
	local cDesCC := AllTrim(cDesc)
	local aRotAuto := {}
	local nOpc
	
	private lMsHelpAuto := .T.			// se .T. direciona as mensagens de help para o arq. de log
	private lMsErroAuto := .F.			//necessario a criacao, pois sera atualizado quando houver alguma incosistencia nos parametros
	
	do case
		case cOpc == "I"
			nOpc := 3
		case cOpc == "A"
			nOpc := 4
		otherwise
			nOpc := 0
	endcase
	
	if nOpc == 0
		MsgInfo("Produto MOD nao processado (incluido/excluido/alterado)!")
	else
		begin transaction
			aRotAuto := {{"B1_COD","MOD"+cNumCC,nil},;
						{"B1_DESC",cDesCC,nil},;
						{"B1_GRUPO","00400",nil},;
						{"B1_TIPO","MO",nil},;
						{"B1_UM","UN",nil},;
						{"B1_LOCPAD","09",nil},;
						{"B1_CONTA","214010001",nil},;
						{"B1_ORIGEM","0",nil},;
						{"B1_POSIPI","99999999",nil},;
						{"B1_IPSAUDE","N",nil},;
						{"B1_CRITICO","N",nil}}
			
			MSExecAuto({|x,y| MATA010(x,y)},aRotAuto,nOpc)
			
			if lMsErroAuto
				DisarmTransaction()
				
				break
			endif
		end transaction
		
		if lMsErroAuto
			/*
			Se estiver em uma aplicao normal e ocorrer alguma incosistencia nos parametros
			passados,mostrar na tela o log informando qual coluna teve a incosistencia.
			*/
			MostraErro()
			
			return .F.
		endif
	endif
return .T.