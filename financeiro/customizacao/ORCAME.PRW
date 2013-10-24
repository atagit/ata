/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/03/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para lançamento do orcamento do projeto          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"

user function ORCAME()
	private cCadastro := "Orcamento do Projeto"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","U_ORCA01('V')",0,2},;
						{"Incluir","U_ORCA01('I')",0,3},;
						{"Alterar","U_ORCA01('A')",0,4},;
						{"Excluir","U_ORCA01('E')",0,5}}
	
	DbSelectArea("SZ3")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZ3")
return

user function ORCA01(cOpcao)
	SetPrvt("cTitulo,cAliasEnchoice,cAliasGetD,cLinOk,cTudOk,cFieldOk,aCpoEnchoice")
	SetPrvt("aHeader,aCols,nOpcE,nOpcG,cTit,n")
	SetPrvt("lVisual,lInclui,lAltera,lExclui")
	SetPrvt("_nPosNum,_nPosItem,_nPosGrupo,_nPosDescGrp,_nPosDtOrcam,_nPosVlOrcam,_nPosProjeto")
	SetPrvt("_nPosVlRevis,_nPosSaldo,_nPosHabRev,_nPosVlReali,_nPosVlEmpen,_nPosDel")
	
	n := 1
	
	lVisual := IIf(cOpcao == "V",.T.,.F.)
	lInclui := IIf(cOpcao == "I",.T.,.F.)
	lAltera := IIf(cOpcao == "A",.T.,.F.)
	lExclui := IIf(cOpcao == "E",.T.,.F.)
	
	do case
		case cOpcao == "I" ; nOpcE := 3 ; nOpcG := 3 ; cTit := If(!Empty(cTit),"Incluir","")
		case cOpcao == "A" ; nOpcE := 3 ; nOpcG := 3 ; cTit := If(!Empty(cTit),"Alterar","")
		case cOpcao == "V" ; nOpcE := 2 ; nOpcG := 2 ; cTit := If(!Empty(cTit),"Visualizar","")
		otherwise ; cTit := If(!Empty(cTit),"Excluir","")
	endcase
	
	RegToMemory("SZ3",lInclui)
	RegToMemory("SZ4",lAltera)
	
	nUsado := 0
	aHeader := {}
	
	DbSelectArea("SX3")
	DbSeek("SZ4")
	
	while !Eof() .and. X3_ARQUIVO == "SZ4"
		if AllTrim(X3_CAMPO) == "Z4_FILIAL" .or. AllTrim(X3_CAMPO) == "Z4_NUM" .or. AllTrim(X3_CAMPO) == "Z4_CLIENTE" .or. AllTrim(X3_CAMPO) == "Z4_LOJA"
			DbSkip()
			
			loop
		endif
		
		if X3Uso(X3_USADO) .and. cNivel >= X3_NIVEL
			nUsado := nUsado + 1
			
			AAdd(aHeader,{Trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,;
							X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,;
							X3_ARQUIVO,X3_CONTEXT,X3_VISUAL,X3_WHEN,X3_BROWSE})
		endif
		
		DbSkip()
	enddo
	
	if lInclui
		aCols := {Array(nUsado + 1)}
		aCols[1,nUsado + 1] := .F.
		
		for _ni := 1 to nUsado
			aCols[1,_ni] := If(AllTrim(Upper(aHeader[_ni,2])) == "Z4_ITEM",StrZero(_ni,2),CriaVar(aHeader[_ni,2]))
		next
	else
		if lVisual
			n := 1
		endif
		
		aCols := {}
		
	    DbSelectArea("SZ4")
		DbSetOrder(1)
		DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
		
	    while !Eof() .and. xFilial() == SZ4->Z4_FILIAL .and. SZ4->Z4_NUM == M->Z3_NUM .and. SZ4->Z4_PROJETO == M->Z3_PROJETO .and. SZ4->Z4_CLIENTE == M->Z3_CLIENTE .and. SZ4->Z4_LOJA == M->Z3_LOJA
			AAdd(aCols,Array(nUsado + 1))
			
			for _ni := 1 to nUsado
				if Upper(AllTrim(aHeader[_ni,10])) != "V"		// Campo Real
	                aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				else		// Campo Virtual
	                cCpo := AllTrim(Upper(aHeader[_ni,2]))
	                
					do case
						case cCpo == "Z4_DESCGRP"
	        	            aCols[Len(aCols),_ni] := GetAdvFVal("SBM","BM_DESC",xFilial("SBM")+SZ4->Z4_GRUPO,1,"DESCRICAO NAO ENCONTRADA!!")
						otherwise
		                    aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
	                endcase
	            endif
	        next
	        
			aCols[Len(aCols),nUsado + 1] := .F.
			
			DbSkip()
		enddo
	endif
	
	_nPosNum	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_NUM"})
	_nPosItem	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_ITEM"})
	_nPosGrupo	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_GRUPO"})
	_nPosDescGrp := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_DESCGRP"})
	_nPosDtOrcam := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_DTORCAM"})
	_nPosVlOrcam := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLORCAM"})
	_nPosVlRevis := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLREVIS"})
	_nPosSaldo	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_SALDO"})
	_nPosHabRev	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_HABREV"})
	_nPosVlReali := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLREALI"})
	_nPosVlEmpen := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_EMPENHA"})
	_nPosProjeto := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_PROJETO"})
	_nPosDel	 := Len(aHeader) + 1
	
	if Len(aCols) <= 0
	    AAdd(aCols,Array(nUsado + 1))
	    
	    n := 1
	    
	    for _ni := 1 to nUsado
	        aCols[1,_ni] := CriaVar(aHeader[_ni,2])
	    next _ni
	    
	    aCols[1,_nPosItem] := "01"
	    aCols[1,nUsado + 1] := .T.		// Define como deletado
	endif
	
	cTitulo 		:= "Orcamento do Projeto "+cTit
	cAliasEnchoice 	:= "SZ3"
	cAliasGetD 		:= "SZ4"
	cLinOk 			:= "U_OrcameVld1()"
	cTudOk 			:= "AllwaysTrue()"
	cFieldOk 		:= "AllwaysTrue()"
	aCpoEnchoice 	:= {"Z3_NUM","Z3_CLIENTE","Z3_LOJA"}
//	aAltEnchoice 	:= If(lAltera,{"Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA"},{})		// Campos que seram permitido a alterar na alteração
	
	if lAltera
		if !Empty(M->Z3_PROJETO)
			aAltEnchoice 	:= {"Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA"}
		else
			aAltEnchoice 	:= {"Z3_PROJETO","Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA"}
		endif
	else
		aAltEnchoice 	:= {}
	endif
	
	if !lInclui
		_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice)
		
		if lAltera
			if _lRet
				AlteraBanco()
			endif
		endif
		
		if lExclui
			if _lRet
				ExcluiBanco()
			endif
		endif
	else
		while .T.
	        _lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
			
			if _lRet
				If Empty(M->Z3_NUM) .or. Empty(M->Z3_CLIENTE) .or. Empty(M->Z3_LOJA)
	                Help("",1,"OBRIGAT")
	                
	                loop
	            else
	                IncluiBanco()
	                
	                exit
	            endif
	        else
	            exit
	        endif
		enddo
	endif
	
	lVisual := "" ; lInclui := "" ; lAltera := "" ; lExclui := ""
return

static function IncluiBanco()
	DbSelectArea("SZ3")
	RecLock("SZ3",.T.)
		SZ3->Z3_FILIAL	:= xFilial()
		SZ3->Z3_NUM		:= M->Z3_NUM
		SZ3->Z3_PROJETO	:= M->Z3_PROJETO
		SZ3->Z3_DESCPRO	:= M->Z3_DESCPRO
		SZ3->Z3_CLIENTE	:= M->Z3_CLIENTE
		SZ3->Z3_LOJA	:= M->Z3_LOJA
		SZ3->Z3_DTINI	:= M->Z3_DTINI
		SZ3->Z3_CONTRAT	:= M->Z3_CONTRAT
		SZ3->Z3_DTFIM	:= M->Z3_DTFIM
		SZ3->Z3_OBSERVA	:= M->Z3_OBSERVA
	MsUnLock()
//	ConfirmSx8()
	
	nNumIt := 1
	nTotSaldo := 0
	
	for nIt := 1 to Len(aCols)
		if !aCols[nIt,_nPosDel]
	        DbSelectArea("SZ4")
	        DbSetOrder(1)
	        
            RecLock("SZ4",.T.)
	            SZ4->Z4_FILIAL	:= xFilial()
	            SZ4->Z4_ITEM	:= aCols[nIt,_nPosItem]
	            SZ4->Z4_NUM		:= M->Z3_NUM
	            SZ4->Z4_CLIENTE	:= M->Z3_CLIENTE
	            SZ4->Z4_LOJA	:= M->Z3_LOJA
	            SZ4->Z4_GRUPO	:= aCols[nIt,_nPosGrupo]
	            SZ4->Z4_DESCGRP	:= aCols[nIt,_nPosDescGrp]
	            SZ4->Z4_PROJETO	:= aCols[nIt,_nPosProjeto]
	            SZ4->Z4_DTORCAM	:= aCols[nIt,_nPosDtOrcam]
	            SZ4->Z4_VLORCAM	:= aCols[nIt,_nPosVlOrcam]
	            SZ4->Z4_VLREVIS	:= aCols[nIt,_nPosVlRevis]
	            SZ4->Z4_VLREALI	:= aCols[nIt,_nPosVlReali]
	            SZ4->Z4_EMPENHA	:= aCols[nIt,_nPosVlEmpen]
	            SZ4->Z4_SALDO	:= aCols[nIt,_nPosSaldo]
	            SZ4->Z4_HABREV	:= "N"
				
	            nTotSaldo += aCols[nIt,_nPosSaldo]
	            nNumIt++
            MsUnLock()
	    endif
	next nIt
	
	RecLock("SZ3",.F.)
		SZ3->Z3_SALDO	:= nTotSaldo
	MsUnLock()
	
	DbSelectArea("SZ3")
return

static function AlteraBanco()
	DbSelectArea("SZ3")
	DbSetOrder(1)
	DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
	RecLock("SZ3",.F.)
		SZ3->Z3_FILIAL	:= xFilial()
		SZ3->Z3_NUM		:= M->Z3_NUM
		SZ3->Z3_PROJETO	:= M->Z3_PROJETO
		SZ3->Z3_DESCPRO	:= M->Z3_DESCPRO
		SZ3->Z3_CLIENTE	:= M->Z3_CLIENTE
		SZ3->Z3_LOJA	:= M->Z3_LOJA
		SZ3->Z3_DTINI	:= M->Z3_DTINI
		SZ3->Z3_CONTRAT	:= M->Z3_CONTRAT
		SZ3->Z3_DTFIM	:= M->Z3_DTFIM
		SZ3->Z3_OBSERVA	:= M->Z3_OBSERVA
	MsUnLock()
	
	nTotSaldo := 0
	
	for nIt := 1 to Len(aCols)
		if !aCols[nIt,_nPosDel]
	        DbSelectArea("SZ4")
	        DbSetOrder(1)
	        
	        if !DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA)+aCols[nIt,_nPosItem])
	            RecLock("SZ4",.T.)
		            SZ4->Z4_FILIAL	:= xFilial()
		            SZ4->Z4_ITEM	:= aCols[nIt,_nPosItem]
		            SZ4->Z4_NUM		:= M->Z3_NUM
		            SZ4->Z4_CLIENTE	:= M->Z3_CLIENTE
		            SZ4->Z4_LOJA	:= M->Z3_LOJA
		            SZ4->Z4_GRUPO	:= aCols[nIt,_nPosGrupo]
		            SZ4->Z4_DESCGRP	:= aCols[nIt,_nPosDescGrp]
		            SZ4->Z4_PROJETO	:= aCols[nIt,_nPosProjeto]
		            SZ4->Z4_DTORCAM	:= aCols[nIt,_nPosDtOrcam]
		            SZ4->Z4_VLORCAM	:= aCols[nIt,_nPosVlOrcam]
		            SZ4->Z4_VLREVIS	:= aCols[nIt,_nPosVlRevis]
		            SZ4->Z4_VLREALI	:= aCols[nIt,_nPosVlReali]
		            SZ4->Z4_EMPENHA	:= aCols[nIt,_nPosVlEmpen]
		            SZ4->Z4_SALDO	:= aCols[nIt,_nPosSaldo]
		            SZ4->Z4_HABREV	:= "N"
//		            SZ4->Z4_HABREV	:= If(!Empty(aCols[nIt,_nPosVlOrcam]),"N","")
	            MsUnLock()
	        else
	            RecLock("SZ4",.F.)
	            	SZ4->Z4_PROJETO	:= aCols[nIt,_nPosProjeto]
		            SZ4->Z4_GRUPO	:= aCols[nIt,_nPosGrupo]
		            SZ4->Z4_DESCGRP	:= aCols[nIt,_nPosDescGrp]
		            SZ4->Z4_DTORCAM	:= aCols[nIt,_nPosDtOrcam]
		            SZ4->Z4_VLORCAM	:= aCols[nIt,_nPosVlOrcam]
		            SZ4->Z4_VLREVIS	:= aCols[nIt,_nPosVlRevis]
		            SZ4->Z4_VLREALI	:= aCols[nIt,_nPosVlReali]
		            SZ4->Z4_EMPENHA	:= aCols[nIt,_nPosVlEmpen]
		            SZ4->Z4_SALDO	:= aCols[nIt,_nPosSaldo]
		            SZ4->Z4_HABREV	:= "N"
	            MsUnLock()
	        endif
	        
	        nTotSaldo += aCols[nIt,_nPosSaldo]
	    else
	        DbSelectArea("SZ4")
	        DbSetOrder(1)
	        
	        if DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA)+aCols[nIt,_nPosItem])
	            RecLock("SZ4",.F.)
	            	DbDelete()
	            MsUnLock()
	            
	            DbSelectArea("SX2")
	            DbSeek("SZ4")
	            RecLock("SX2",.F.)
	            	SX2->X2_DELET := SX2->X2_DELET + 1
	            MsUnLock()
	        endif
	    endif
	next nIt
	
	RecLock("SZ3",.F.)
		SZ3->Z3_SALDO	:= nTotSaldo
	MsUnLock()
	
	nNumIt := 1
	
	DbSelectArea("SZ4")
	DbSetOrder(1)
	DbSeek(xFilial("SZ4")+SZ3->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
	
	while !Eof() .and. xFilial("SZ4") == SZ2->Z2_FILIAL .and. SZ4->Z4_NUM == SZ3->Z3_NUM .and. SZ4->Z4_PROJETO == SZ3->Z3_PROJETO .and. SZ4->Z4_CLIENTE == SZ3->Z3_CLIENTE .and. SZ4->Z4_LOJA == SZ3->Z3_LOJA
	    RecLock("SZ4",.F.)
		    SZ4->Z4_ITEM := StrZero(nNumIt,2)
		    nNumIt := nNumIt + 1
	    MsUnLock()
		
		DbSkip()
	enddo
	
	DbSelectArea("SZ3")
return

static function ExcluiBanco()
    for _nIt := 1 to Len(aCols)
        DbSelectArea("SZ4")
        DbSetOrder(1)
        
        if DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA)+aCols[_nIt,_nPosItem])
            RecLock("SZ4",.F.)
            	DbDelete()
            MsUnLock()
            
            DbSelectArea("SX2")
            DbSeek("SZ4")
            RecLock("SX2",.F.)
            	SX2->X2_DELET := SX2->X2_DELET + 1
            MsUnLock()
        endif
    next _nIt

    DbSelectArea("SZ3")
    DbSetOrder(1)
    
    if DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
        RecLock("SZ3",.F.)
        	DbDelete()
        MsUnLock()
        
        DbSelectArea("SX2")
        DbSeek("SZ3")
        RecLock("SX2",.F.)
        	SX2->X2_DELET := SX2->X2_DELET + 1
        MsUnLock()
    endif
return

user function OrcameVld1()
	local lRet := .T.
	
	if !aCols[n,_nPosDel]
		if Empty(aCols[n,_nPosGrupo])
			Help(1,"","GRPVAZIO")
			
	        lRet := .F.
	    else
			if !ExistCpo("SBM",aCols[n,_nPosGrupo])
	            lRet := .F.
	        endif
		endif
		
	    if lRet .and. Empty(aCols[n,_nPosDescGrp])
			aCols[n,_nPosDescGrp] := GetAdvFVal("SBM","BM_DESC",xFilial("SBM")+aCols[n,_nPosGrupo],1,"DESCRICAO NAO ENCONTRADA!!")
	    endif
	    
		if Empty(aCols[n,_nPosDtOrcam])
			Help(1,"","DTOVAZIO")
			
	        lRet := .F.
	    endif
	    
		if Empty(aCols[n,_nPosVlOrcam])
			Help(1,"","VLOVAZIO")
			
	        lRet := .F.
	    endif
	    
	    if Empty(aCols[n,_nPosProjeto])
			Help(1,"","PROJVAZIO")
			
	        lRet := .F.
	    endif
	endif
return lRet