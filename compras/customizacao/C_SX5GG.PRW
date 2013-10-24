/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 26/03/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para cadastro do grande grupo de produto         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"

#define _TABSX5 "GG"

user function C_SX5GG()
	local _sAlias := Alias()
	local _sRec   := Recno()
	
	private nOpcx := 3
	private _nChave := 0
	private _nDescri := 0
	
	//+-----------------------------------------------+
	//¦ Montando aHeader para a Getdados              ¦
	//+-----------------------------------------------+
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SX5")
	
	nUsado := 0
	aHeader := {}
	
	while !Eof() .and. (X3_ARQUIVO == "SX5")
		if X3USO(X3_USADO) .and. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO) $ "X5_FILIAL/X5_TABELA/X5_DESCSPA/X5_DESCENG")
			nUsado++
			
			AAdd(aHeader,{AllTrim(X3_TITULO),AllTrim(X3_CAMPO),X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"AllwaysTrue()",X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
		endif
		
		DbSkip()
	enddo
	
	//+-----------------------------------------------+
	//¦ Montando aCols para a GetDados                ¦
	//+-----------------------------------------------+
	
	aCols := Array(1,nUsado + 1)
	
	DbSelectArea("SX3")
	DbGoTop()
	DbSeek("SX5")
	
	DbSelectArea("SX5")
	DbGoTop()
	DbSeek(xFilial("SX5")+"00"+_TABSX5)
	
	//+----------------------------------------------+
	//¦ Variaveis do Cabecalho do Modelo 2           ¦
	//+----------------------------------------------+
	
	cTabela := SX5->X5_TABELA
	cChave := SX5->X5_CHAVE
	cDescri := Left(SX5->X5_DESCRI,40)
	
	//+----------------------------------------------+
	//¦ Variaveis do Rodape do Modelo 2              ¦
	//+----------------------------------------------+
	
	nLinGetD := 0
	aCols := {}
	
	DbSelectArea("SX5")
	DbGoTop()
	DbSeek(xFilial("SX5")+_TABSX5)
	
	while !Eof() .and. SX5->X5_TABELA == _TABSX5
		AAdd(aCols,{SX5->X5_CHAVE,SX5->X5_DESCRI,.F.})
		
		DbSkip()
	enddo
	
	//+----------------------------------------------+
	//¦ Titulo da Janela                             ¦
	//+----------------------------------------------+
	
	cTitulo := "Gr. Grupo de Produtos"
	
	//+----------------------------------------------+
	//¦ Array com descricao dos campos do Cabecalho  ¦
	//+----------------------------------------------+
	
	aC := {}
	
	#IFDEF WINDOWS
		AAdd(aC,{"cChave",{015,010},"Tabela","@!",,,.F.})
		AAdd(aC,{"cDescri",{015,100},"Descricao","@!",,,.F.})
	#ELSE
		AAdd(aC,{"cChave",{006,005},"Tabela","@!",,,.F.})
		AAdd(aC,{"cDescri",{006,040},"Descricao","@!",,,.F.})
	#ENDIF
	
	//+-------------------------------------------------+
	//¦ Array com descricao dos campos do Rodape        ¦
	//+-------------------------------------------------+
	
	aR := {}
	
/*	#IFDEF WINDOWS
		AAdd(aR,{"nLinGetD",{120,010},"Linha na GetDados","@E 999",,,.F.})
	#ELSE
		AAdd(aR,{"nLinGetD",{019,005},"Linha na GetDados","@E 999",,,.F.})
	#ENDIF*/
	
	//+------------------------------------------------+
	//¦ Array com coordenadas da GetDados no modelo2   ¦
	//+------------------------------------------------+
	
	#IFDEF WINDOWS
		aCGD := {044,005,118,315}
	#ELSE
		aCGD := {010,004,015,073}
	#ENDIF
	
	//+----------------------------------------------+
	//¦ Validacoes na GetDados da Modelo 2           ¦
	//+----------------------------------------------+
	
	cLinhaOk := "ExecBlock('X5LINOK',.F.,.F.)"
	cTudoOk := "ExecBlock('X5TUDOK',.F.,.F.)"
//	cTudoOk := "AllwaysTrue()"
	
	//+----------------------------------------------+
	//¦ Chamada da Modelo2                           ¦
	//+----------------------------------------------+
	
	// lRet = .t. se confirmou
	// lRet = .f. se cancelou
	
	lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
	
	_nChave := AScan(aHeader,{|x| x[2] == "X5_CHAVE"})
	_nDescri := AScan(aHeader,{|x| x[2] == "X5_DESCRI"})
	
	if lRet
		for _l := 1 to Len(aCols)
			if !aCols[_l,3]
				DbSelectArea("SX5")
				DbSetOrder(1)
				
				if !DbSeek(xFilial("SX5")+_TABSX5+aCols[_l,_nChave])
					RecLock("SX5",.T.)
				else
					RecLock("SX5",.F.)
				endif
				
				SX5->X5_FILIAL := xFilial("SX5")
				SX5->X5_TABELA := _TABSX5
				SX5->X5_CHAVE := aCols[_l,_nChave]
				SX5->X5_DESCRI := aCols[_l,_nDescri]
				SX5->X5_DESCSPA := aCols[_l,_nDescri]
				SX5->X5_DESCENG := aCols[_l,_nDescri]
				
				MsUnLock()
			else
				DbSelectArea("SX5")
				DbSetOrder(1)
				
				if DbSeek(xFilial("SX5")+_TABSX5+aCols[_l,_nChave])
					RecLock("SX5",.F.)
						DbDelete()
					MsUnLock()
				endif
			endif
		next _l
	endif
	
	DbSelectArea(_sAlias)
	DbGoTo(_sRec)
return