/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/03/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para lançamento das resuisicoes de aquisicao     ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"

user function REQUIS()
	private cCadastro := "Requisitos de Aquisicao"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","U_REQU01('V')",0,2},;
						{"Incluir","U_REQU01('I')",0,3},;
						{"Alterar","U_REQU01('A')",0,4},;
						{"Excluir","U_REQU01('E')",0,5}}
	
	DbSelectArea("SZX")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZX",,,,,,)
return

user function REQU01(cOpcao)
	SetPrvt("cTitulo,cAliasEnchoice,cAliasGetD,cLinOk,cTudOk,cFieldOk,aCpoEnchoice")
	SetPrvt("aHeader,aCols,nOpcE,nOpcG,cTit,n,cValid")
	SetPrvt("lVisual,lInclui,lAltera,lExclui")
	SetPrvt("_nPosCod,_nPosItem,_nPosRequi,_nPosMA,_nPosSST,_nPosQUA,_nPosDel")
	
	n := 1
	cValid := ""
	
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
	
	RegToMemory("SZX",lInclui)
	RegToMemory("SZY",lAltera)
	
	nUsado := 0
	aHeader := {}
	
	DbSelectArea("SX3")
	DbSeek("SZY")
	
	while !Eof() .and. X3_ARQUIVO == "SZY"
		if AllTrim(X3_CAMPO) == "ZY_FILIAL" .or. AllTrim(X3_CAMPO) == "ZY_CODIGO"
			DbSkip()
			
			loop
		endif
		
		if X3Uso(X3_USADO) .and. cNivel >= X3_NIVEL
			nUsado := nUsado + 1
			
			AAdd(aHeader,{Trim(X3_TITULO),X3_CAMPO,X3_PICTURE,X3_TAMANHO,;
							X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,;
							X3_ARQUIVO,X3_CONTEXT,X3_VISUAL,X3_WHEN,X3_BROWSE,;
							X3_RELACAO,X3_INIBRW})
		endif
		
		DbSkip()
	enddo
	
	if lInclui
		aCols := {Array(nUsado + 1)}
		aCols[1,nUsado + 1] := .F.
		
		for _ni := 1 to nUsado
			aCols[1,_ni] := If(AllTrim(Upper(aHeader[_ni,2])) == "ZY_ITEM",StrZero(_ni,2),CriaVar(aHeader[_ni,2]))
		next
	else
		if lVisual
			n := 1
		endif
		
		aCols := {}
		
	    DbSelectArea("SZY")
		DbSetOrder(1)
		DbSeek(xFilial()+M->ZX_CODIGO)
		
	    while !Eof() .and. xFilial() == SZY->ZY_FILIAL .and. SZY->ZY_CODIGO == M->ZX_CODIGO
			AAdd(aCols,Array(nUsado + 1))
			
			for _ni := 1 to nUsado
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
	        next
	        
			aCols[Len(aCols),nUsado + 1] := .F.
			
			DbSkip()
		enddo
	endif
	
	_nPosCod	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZY_CODIGO"})
	_nPosItem	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZY_ITEM"})
	_nPosRequi	 := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZY_REQUISI"})
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
	
	cTitulo 		:= "Requisitos de Aquisicao "+cTit
	cAliasEnchoice 	:= "SZX"
	cAliasGetD 		:= "SZY"
	cLinOk 			:= "U_RequisVld1()"
	cTudOk 			:= "AllwaysTrue()"
	cFieldOk 		:= "AllwaysTrue()"
	aCpoEnchoice 	:= {"ZX_CODIGO"}
	aCordW			:= {00000,00000,0500,1250}
	
	if lAltera
		aAltEnchoice := {"ZX_DESCRIC","ZX_MA","ZX_SST","ZX_QUA"}
	else
		aAltEnchoice := {}
	endif
	
	if !lInclui
		_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,,,aCordW,100)
		
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
			_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,,,,aCordW,100)
			
			if _lRet
				if Empty(M->ZX_CODIGO) .or. Empty(M->ZX_DESCRIC)
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
	DbSelectArea("SZX")
	
	RecLock("SZX",.T.)
		SZX->ZX_FILIAL	:= xFilial()
		SZX->ZX_CODIGO	:= M->ZX_CODIGO
		SZX->ZX_DESCRIC := M->ZX_DESCRIC
		SZX->ZX_MA 		:= M->ZX_MA
		SZX->ZX_SST		:= M->ZX_SST
		SZX->ZX_QUA		:= M->ZX_QUA
	MsUnLock()
//	ConfirmSx8()
	
	nNumIt := 1
	
	for nIt := 1 to Len(aCols)
		if !aCols[nIt,_nPosDel]
	        DbSelectArea("SZY")
	        DbSetOrder(1)
	        
            RecLock("SZY",.T.)
	            SZY->ZY_FILIAL	:= xFilial()
	            SZY->ZY_ITEM	:= aCols[nIt,_nPosItem]
	            SZY->ZY_CODIGO	:= M->ZX_CODIGO
	            SZY->ZY_REQUISI	:= aCols[nIt,_nPosRequi]
				
	            nNumIt++
            MsUnLock()
	    endif
	next nIt
	
	DbSelectArea("SZX")
return

static function AlteraBanco()
	DbSelectArea("SZX")
	DbSetOrder(1)
	DbSeek(xFilial()+M->ZX_CODIGO)
	
	RecLock("SZX",.F.)
		SZX->ZX_DESCRIC := M->ZX_DESCRIC
		SZX->ZX_MA 		:= M->ZX_MA
		SZX->ZX_SST		:= M->ZX_SST
		SZX->ZX_QUA		:= M->ZX_QUA
	MsUnLock()
	
	for nIt := 1 to Len(aCols)
		if !aCols[nIt,_nPosDel]
	        DbSelectArea("SZY")
	        DbSetOrder(1)
	        
	        if !DbSeek(xFilial()+M->ZX_CODIGO+aCols[nIt,_nPosItem])
	            RecLock("SZY",.T.)
		            SZY->ZY_FILIAL	:= xFilial()
		            SZY->ZY_ITEM	:= aCols[nIt,_nPosItem]
		            SZY->ZY_CODIGO	:= M->ZX_CODIGO
		            SZY->ZY_REQUISI	:= aCols[nIt,_nPosRequi]
	            MsUnLock()
	        else
	            RecLock("SZY",.F.)
		            SZY->ZY_REQUISI	:= aCols[nIt,_nPosRequi]
	            MsUnLock()
	        endif
	    else
	        DbSelectArea("SZY")
	        DbSetOrder(1)
	        
	        if DbSeek(xFilial()+M->ZX_CODIGO+aCols[nIt,_nPosItem])
	            RecLock("SZY",.F.)
	            	DbDelete()
	            MsUnLock()
	            
	            DbSelectArea("SX2")
	            DbSeek("SZY")
	            
	            RecLock("SX2",.F.)
	            	SX2->X2_DELET := SX2->X2_DELET + 1
	            MsUnLock()
	        endif
	    endif
	next nIt
	
	nNumIt := 1
	
	DbSelectArea("SZY")
	DbSetOrder(1)
	DbSeek(xFilial()+SZX->ZX_CODIGO)
	
	while !Eof() .and. xFilial() == SZY->ZY_FILIAL .and. SZY->ZY_CODIGO == SZX->ZX_CODIGO
	    RecLock("SZY",.F.)
		    SZY->ZY_ITEM := StrZero(nNumIt,2)
		    nNumIt := nNumIt + 1
	    MsUnLock()
		
		DbSkip()
	enddo
	
	DbSelectArea("SZX")
return

static function ExcluiBanco()
    for _nIt := 1 to Len(aCols)
        DbSelectArea("SZY")
        DbSetOrder(1)
        
        if DbSeek(xFilial()+M->ZX_CODIGO+aCols[_nIt,_nPosItem])
            RecLock("SZY",.F.)
            	DbDelete()
            MsUnLock()
            
            DbSelectArea("SX2")
            DbSeek("SZY")
            
            RecLock("SX2",.F.)
            	SX2->X2_DELET := SX2->X2_DELET + 1
            MsUnLock()
        endif
    next _nIt

    DbSelectArea("SZX")
    DbSetOrder(1)
    
    if DbSeek(xFilial()+M->ZX_CODIGO)
        RecLock("SZX",.F.)
        	DbDelete()
        MsUnLock()
        
        DbSelectArea("SX2")
        DbSeek("SZX")
        
        RecLock("SX2",.F.)
        	SX2->X2_DELET := SX2->X2_DELET + 1
        MsUnLock()
    endif
return

user function RequisVld1()
	local lRet := .T.
	
	if !aCols[n,_nPosDel]
		if Empty(aCols[n,_nPosRequi])
			Help(1,"","REQUISI")
			
	        lRet := .F.
	    endif
	endif
return lRet