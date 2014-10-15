/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 30/08/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Funcao para copiar uma determinada TES                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"

user function COPSF4()
//	local aAreaAnt := GetArea()
	local cTes := SF4->F4_CODIGO
	local cTipo := SF4->F4_TIPO
	local aCampos := {}
	local aRegistro := {}
	local nPosCodigo := 0
	local nUsado := 0
	local cTesNova := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Cod.TES Nova                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PreparaPergunta("COPSF4")
	Pergunte("COPSF4",.T.)
	
	cTesNova := mv_par01
	
	if cTipo == "E"
		if cTesNova >= "500"
			MsgInfo("A TES que deseja copiar e de ENTRADA, sendo assim, o codigo tem que esta ABAIXO de 500.")
			
			return
		endif
	else
		if cTesNova < "500"
			MsgInfo("A TES que deseja copiar e de SAIDA, sendo assim, o codigo tem que esta ACIMA de 500.")
			
			return
		endif
	endif
	
	if !Empty(cTesNova)
		DbSelectArea("SX3")
		SX3->(DbSetOrder(1))
		SX3->(DbSeek("SF4"))
		
		while !SX3->(Eof()) .and. (SX3->X3_ARQUIVO == "SF4")
			if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado++
				
				AAdd(aCampos,AllTrim(SX3->X3_CAMPO))
				
				if AllTrim(SX3->X3_CAMPO) == "F4_CODIGO"
					nPosCodigo := nUsado
				endif
			endif
			
			SX3->(DbSkip())
		enddo
		
		AAdd(aCampos,"F4_FILIAL")
		AAdd(aCampos,"F4_AGRRETC")
		AAdd(aCampos,"F4_FRETAUT")
		
		DbSelectArea("SF4")
		SF4->(DbGoTop())
		
		if SF4->(MsSeek(xFilial("SF4")+cTes,.F.))
			for i := 1 to Len(aCampos)
				AAdd(aRegistro,SF4->&(aCampos[i]))
			next
			
			AAdd(aRegistro,"01")
			AAdd(aRegistro,"2")
			AAdd(aRegistro,"1")
			
			aRegistro[nPosCodigo] := cTesNova
		endif
		
		if !Empty(aRegistro)
			RecLock("SF4",.T.)
				for i := 1 to Len(aCampos)
					SF4->&(aCampos[i]) := aRegistro[i]
				next
			MsUnLock()
			
			SF4->(DbGoTop())
			SF4->(DbSeek(xFilial("SF4")+cTesNova,.F.))
		endif
	endif
	
//	RestArea(aAreaAnt)
return

static function PreparaPergunta(cPerg)
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	
	if SX1->(DbSeek(cPerg))
		RecLock("SX1",.F.)
			SX1->X1_CNT01 := "                                                            "
		MsUnLock()
	endif
return