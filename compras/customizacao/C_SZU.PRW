/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 31/07/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse cadastro de tabelas Codigo de Rastreabilidade  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function C_SZU()
	private cCadastro := "Codigo de Rastreabilidade"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
							{"Visualizar","AxVisual",0,2},;
							{"Legenda","U_SZULeg()",0,3},;
							{"Cancelar","U_SZUCanc()",0,4}}
	private aCores := {{"ZU_USADO == 'S'","BR_VERMELHO"},;
							{"ZU_USADO == 'N'","BR_VERDE"},;
							{"ZU_USADO == 'C'","BR_BRANCO"},;
							{"ZU_USADO == 'E'","BR_PRETO"}}
	
	DbSelectArea("SZU")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZU",,,,,,aCores)
return

user function SZULeg()
	aLegenda := {{"BR_VERDE","CR nao usado"},;
					{"BR_VERMELHO","CR ja usado"},;
					{"BR_BRANCO","CR cancelado"},;
					{"BR_PRETO","CR excluido"}}
	
	BrwLegenda("Legenda","CR Usado",aLegenda)
return (.T.)

user function SZUCanc()
	local aArea := GetArea()
	local cSequencia := SZU->ZU_SEQUENC
	
	if MsgNoYes("Cancelando o protocolo ("+AllTrim(SZU->ZU_NUMCR)+") ele nao podera ser mais utilizado. Cancela-lo?"," Confirmar ")
		SZU->(DbSetOrder(5))
		
		if SZU->(DbSeek(xFilial("SZU")+cSequencia,.F.))
			while SZU->ZU_SEQUENC == cSequencia
				if SZU->ZU_USADO == "S" ; SZU->(DbSkip()) ; loop ; endif
				
				if RecLock("SZU",.F.)
					SZU->ZU_USADO := "C"
					
					MsUnLock()
				endif
				
				SZU->(DbSkip())
			enddo
		endif
		
		RestArea(aArea)
	endif
return (.T.)