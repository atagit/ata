/*   
+----------+-----------+----------+-------------------------+------+-----------+
|Programa  | Geral     | Autor    |Wladimir R. Fernandes      |Data|10.06.2003 |
+----------+-----------+----------+-------------------------+------+-----------+
|Descricao | Cria Tabelas Temporárias apartir de uma Tabela Gerada por Query   |
+----------+-------------------------------------------------------------------+
| USO      | Especifico para Miramar                                           |
+----------+-------------------------------------------------------------------+
|           ALTERACOES FEITAS DESDE A CRIACAO                                  |
+----------+-----------+-------------------------------------------------------+
|Autor     | Data      | Descricao                                             |
+----------+-----------+-------------------------------------------------------+
|Gerson    |12.11.2008 | Se não existir nome de Arquivo cria temporario na     |
|		   |           | pasta StartPath                                       |
+----------+-----------+-------------------------------------------------------+
*/

#include "protheus.ch"


User Function TransQuery(cAliaAuxi,cNovoAlia,cNomeArq,aCamposDt)
****************************************************************************************
* Transforma uma query read-only em arquito de trabalho leitura e gravacao
* Parametros: <cAliaAuxi> obrigatorio
*             [cNovoAlia] Novo alias do arquivo de trabalho, caso este nao seja
*             informado assumirá c Alias
*			  {aCamDt} Array contendo os campos Tipo Data.
*             [lTemp] Define se o arquivo DBF será aleatorio ou definido
* Retorno: retorna o nome do arquivo de trabalho que deverá ser apagado.
***            

Local aStruAuxi := {}
Local cArquTrab := ""
Local nxI       := 0
Local lReabArqu := (cNovoAlia == NIL .Or. cNovoAlia == cAliaAuxi)
Local aSalvArea := GetArea()
Local cArq 		:= cNomeArq	//  If(Type("cNomeArq")=="U",Nil,cNomeArq)

cNovoAlia := Iif(lReabArqu,CriaTrab(,.F.),cNovoAlia)
               
dbSelectArea(cAliaAuxi)
aStruAuxi := dbStruct()

For nx := 1 To Len(aStruAuxi)
/*	if aStruAuxi[nx][2] == "N"
		Alert(AllTrim(Str(aStruAuxi[nx][3]))+","+AllTrim(Str(aStruAuxi[nx][4])))
	endif*/
	if aStruAuxi[nx][2] == "N"
		aStruAuxi[nx][3] := 17
		aStruAuxi[nx][4] := 4
	endif
	
	if AScan(aCamposDt,aStruAuxi[nx][1]) <> 0
		aStruAuxi[nx][2] := "D"
	endif*/
Next

// Acerta os campos tipo Data
/*If Len(aCamposDt) > 0
	For nx:=1 To Len(aStruAuxi)
		For nx:=1 To Len(aCamposDt)
			If Trim(aStruAuxi[nx][1]) == Trim(aCamposDt[nz])
				aStruAuxi[nx][2] := "D"
			EndIf
		Next               
		//Marcus - Paleativo
		If aStruAuxi[nx][4] == 8
			aStruAuxi[nx][4] := 6
		EndIf
	Next
EndIf*/

// Se não existir nome de Arquivo cria temporario na pasta StartPath - Acrescentado por Gerson 12.11.2008
If cArq==Nil
	cArquTrab := CriaTrab(aStruAuxi,.T.)
Else
	DbCreate( cArq, aStruAuxi )
	cArquTrab := cArq
	cNovoAlia := cArq
EndIf

dbUseArea(.T.,,cArquTrab,cNovoAlia,.F.,.F.)

dbSelectArea(cAliaAuxi)
ProcRegua(RecCount())
dbGoTop()
While !Eof()

	dbSelectArea(cNovoAlia)
	(cNovoAlia)->(dbAppend())  //RecLock(cNovoAlia,.T.)
	
	dbSelectArea(cAliaAuxi)
	
	For nxI := 1 To (cAliaAuxi)->(FCount())
		If aStruAuxi[nxI][2] == "D"
			(cNovoAlia)->(&(FieldName(nxI))) := StoD(FieldGet(nxI))
		Else
	 		(cNovoAlia)->(&(FieldName(nxI))) := FieldGet(nxI)
	 	EndIf
	Next
	
	dbSelectArea(cAliaAuxi)
	dbSkip()
	IncProc()
EndDo

dbSelectArea(cAliaAuxi)
dbCloseArea()

If lReabArqu
	dbSelectArea(cNovoAlia)
	dbCloseArea()
	
	dbUseArea(.T.,,cArquTrab,cAliaAuxi,.F.,.F.)
Endif

RestArea(aSalvArea)

Return(cArquTrab)