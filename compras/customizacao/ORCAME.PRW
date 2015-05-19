/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 08/03/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Tela para lançamento do orcamento do projeto          ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

user function ORCAME()
	private cCadastro := "Orcamento do Projeto"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","U_ORCA01('V')",0,2},;
						{"Incluir","U_ORCA01('I')",0,3},;
						{"Alterar","U_ORCA01('A')",0,4},;
						{"Excluir","U_ORCA01('E')",0,5},;
						{"Lancamento","U_LANCORCA()",0,6},;
						{"Atualizar","U_ATUAORCA()",0,7},;
						{"Out Projetos","U_OUTPROJ()",0,8},;
						{"Legenda","U_LEGORCA()",0,3}}
	
	aColors := {{"Z3_FECHADO == 'N'","BR_VERDE"},;
				{"Z3_FECHADO == 'S'","BR_VERMELHO"}}
	
	DbSelectArea("SZ3")
	DbSetOrder(1)
	
	MBrowse(06,01,22,75,"SZ3",,,,,,aColors)
return

user function LEGORCA()
	local aLegenda := {}
	
	/* -- Cores disponíveis para Legenda --
		BR_AMARELO
		BR_AZUL
		BR_BRANCO
		BR_CINZA
		BR_LARANJA
		BR_MARRON
		BR_VERDE
		BR_VERMELHO
		BR_PINK
		BR_PRETO
	*/
	
	AAdd(aLegenda,{"BR_VERDE","Orcamento Aberto"})
	AAdd(aLegenda,{"BR_VERMELHO","Orcamento Fechado"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return (.T.)

user function ORCA01(cOpcao)
	SetPrvt("cTitulo,cAliasEnchoice,cAliasGetD,cLinOk,cTudOk,cFieldOk,aCpoEnchoice")
	SetPrvt("aHeader,aCols,nOpcE,nOpcG,cTit,n,cValid")
	SetPrvt("lVisual,lInclui,lAltera,lExclui")
	SetPrvt("_nPosNum,_nPosItem,_nPosGrupo,_nPosDescGrp,_nPosDtOrcam,_nPosVlOrcam,_nPosProjeto,_nPosVlAceRe")
	SetPrvt("_nPosVlRevis,_nPosSaldo,_nPosHabRev,_nPosVlReali,_nPosVlEmpen,_nPosGGrupo,_nPosDel,_nPosVlAcert,_nPosDesGGrp")
	
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
	
	RegToMemory("SZ3",lInclui)
	RegToMemory("SZ4",lAltera)
	
	nUsado := 0
	aHeader := {}
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbGoTop()
	DbSeek("SZ4")
	
	while !Eof() .and. X3_ARQUIVO == "SZ4"
		if AllTrim(X3_CAMPO) $ "Z4_FILIAL/Z4_NUM/Z4_CLIENTE/Z4_LOJA"// .or. AllTrim(X3_CAMPO) == "Z4_VLACERT" .or. AllTrim(X3_CAMPO) == "Z4_VLACREA"
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
				else											// Campo Virtual
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
	
	_nPosNum := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_NUM"})
	_nPosItem := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_ITEM"})
	_nPosGrupo := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_GRUPO"})
	_nPosDescGrp := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_DESCGRP"})
	_nPosDtOrcam := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_DTORCAM"})
	_nPosVlOrcam := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLORCAM"})
	_nPosVlRevis := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLREVIS"})
	_nPosSaldo := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_SALDO"})
	_nPosHabRev := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_HABREV"})
	_nPosVlReali := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLREALI"})
	_nPosVlEmpen := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_EMPENHA"})
	_nPosProjeto := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_PROJETO"})
	_nPosGGrupo := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_GGRUPO"})
	_nPosDesGGrp := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_DESCGGR"})
	_nPosIncSist := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_INCSIST"})
//	_nPosVlAcert := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLACERT"})
//	_nPosVlAceRe := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLACREA"})
	_nPosResiduo := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_RESIDUO"})
	_nPosDel := Len(aHeader) + 1
	
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
	aCordW			:= {00000,00000,0500,1250}
	
	if lAltera
		if !Empty(M->Z3_PROJETO)
			aAltEnchoice := {"Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA","Z3_FECHADO","Z3_PRJMAE"}
		else
			aAltEnchoice := {"Z3_PROJETO","Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA","Z3_FECHADO"}
		endif
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
		SZ3->Z3_DESCCLI	:= M->Z3_DESCCLI
		SZ3->Z3_DTINI	:= M->Z3_DTINI
		SZ3->Z3_CONTRAT	:= M->Z3_CONTRAT
		SZ3->Z3_DTFIM	:= M->Z3_DTFIM
		SZ3->Z3_OBSERVA	:= M->Z3_OBSERVA
		SZ3->Z3_FECHADO := IIf(Empty(M->Z3_FECHADO),"N",M->Z3_FECHADO)
		SZ3->Z3_PRJMAE	:= M->Z3_PRJMAE
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
	            SZ4->Z4_GGRUPO	:= aCols[nIt,_nPosGGrupo]
	            SZ4->Z4_DESCGGR := aCols[nIt,_nPosDesGGrp]
	            SZ4->Z4_GRUPO	:= aCols[nIt,_nPosGrupo]
	            SZ4->Z4_DESCGRP	:= aCols[nIt,_nPosDescGrp]
	            SZ4->Z4_PROJETO	:= aCols[nIt,_nPosProjeto]
	            SZ4->Z4_DTORCAM	:= aCols[nIt,_nPosDtOrcam]
	            SZ4->Z4_VLORCAM	:= aCols[nIt,_nPosVlOrcam]
	            SZ4->Z4_VLREVIS	:= aCols[nIt,_nPosVlRevis]
	            SZ4->Z4_VLREALI	:= aCols[nIt,_nPosVlReali]
	            SZ4->Z4_EMPENHA	:= aCols[nIt,_nPosVlEmpen]
//	            SZ4->Z4_VLACERT	:= aCols[nIt,_nPosVlAcert]
//	            SZ4->Z4_VLACREA	:= aCols[nIt,_nPosVlAceRe]
				SZ4->Z4_RESIDUO	:= aCols[nIt,_nPosResiduo]
	            SZ4->Z4_SALDO	:= aCols[nIt,_nPosSaldo]
	            SZ4->Z4_HABREV	:= "N"
	            SZ4->Z4_INCSIST	:= "N"
				
	            nTotSaldo += aCols[nIt,_nPosSaldo]
	            nNumIt++
            MsUnLock()
	    endif
	next nIt
	
	DbSelectArea("SZ3")
	DbSetOrder(1)
	DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
	RecLock("SZ3",.F.)
		SZ3->Z3_SALDO := nTotSaldo
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
		SZ3->Z3_DESCCLI	:= M->Z3_DESCCLI
		SZ3->Z3_DTINI	:= M->Z3_DTINI
		SZ3->Z3_CONTRAT	:= M->Z3_CONTRAT
		SZ3->Z3_DTFIM	:= M->Z3_DTFIM
		SZ3->Z3_OBSERVA	:= M->Z3_OBSERVA
		SZ3->Z3_FECHADO := IIf(Empty(M->Z3_FECHADO),"N",M->Z3_FECHADO)
		SZ3->Z3_PRJMAE	:= M->Z3_PRJMAE
	MsUnLock()
	
	nTotSaldo := 0
	nTotOrcad := 0
	
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
					SZ4->Z4_GGRUPO	:= aCols[nIt,_nPosGGrupo]
					SZ4->Z4_DESCGGR	:= aCols[nIt,_nPosDesGGrp]
					SZ4->Z4_GRUPO	:= aCols[nIt,_nPosGrupo]
					SZ4->Z4_DESCGRP	:= aCols[nIt,_nPosDescGrp]
					SZ4->Z4_PROJETO	:= aCols[nIt,_nPosProjeto]
					SZ4->Z4_DTORCAM	:= aCols[nIt,_nPosDtOrcam]
					SZ4->Z4_VLORCAM	:= aCols[nIt,_nPosVlOrcam]
					SZ4->Z4_VLREVIS	:= aCols[nIt,_nPosVlRevis]
					SZ4->Z4_VLREALI	:= aCols[nIt,_nPosVlReali]
					SZ4->Z4_EMPENHA	:= aCols[nIt,_nPosVlEmpen]
//					SZ4->Z4_VLACERT	:= aCols[nIt,_nPosVlAcert]
//					SZ4->Z4_VLACREA	:= aCols[nIt,_nPosVlAceRe]
					SZ4->Z4_RESIDUO	:= aCols[nIt,_nPosResiduo]
					SZ4->Z4_SALDO	:= aCols[nIt,_nPosSaldo]
					SZ4->Z4_HABREV	:= "N"
					SZ4->Z4_INCSIST	:= "N"
//					SZ4->Z4_HABREV	:= If(!Empty(aCols[nIt,_nPosVlOrcam]),"N","")
				MsUnLock()
			else
				RecLock("SZ4",.F.)
					SZ4->Z4_PROJETO	:= aCols[nIt,_nPosProjeto]
	            	SZ4->Z4_GGRUPO	:= aCols[nIt,_nPosGGrupo]
	            	SZ4->Z4_DESCGGR	:= aCols[nIt,_nPosDesGGrp]
					SZ4->Z4_GRUPO	:= aCols[nIt,_nPosGrupo]
					SZ4->Z4_DESCGRP	:= aCols[nIt,_nPosDescGrp]
					SZ4->Z4_DTORCAM	:= aCols[nIt,_nPosDtOrcam]
					SZ4->Z4_VLORCAM	:= aCols[nIt,_nPosVlOrcam]
					SZ4->Z4_VLREVIS	:= aCols[nIt,_nPosVlRevis]
					SZ4->Z4_VLREALI	:= aCols[nIt,_nPosVlReali]
					SZ4->Z4_EMPENHA	:= aCols[nIt,_nPosVlEmpen]
//					SZ4->Z4_VLACERT	:= aCols[nIt,_nPosVlAcert]
//					SZ4->Z4_VLACREA	:= aCols[nIt,_nPosVlAceRe]
					SZ4->Z4_RESIDUO	:= aCols[nIt,_nPosResiduo]
					SZ4->Z4_SALDO	:= aCols[nIt,_nPosSaldo]
					SZ4->Z4_HABREV	:= "N"
					SZ4->Z4_INCSIST	:= IIf(Empty(aCols[nIt,_nPosIncSist]),"N",aCols[nIt,_nPosIncSist])
				MsUnLock()
			endif
			
			nTotSaldo += aCols[nIt,_nPosSaldo]
			nTotOrcad += (aCols[nIt,_nPosVlOrcam] + aCols[nIt,_nPosVlRevis])
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
	
	DbSelectArea("SZ3")
	DbSetOrder(1)
	DbSeek(xFilial()+M->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
	RecLock("SZ3",.F.)
		SZ3->Z3_SALDO := nTotSaldo
		SZ3->Z3_ORCADO := nTotOrcad
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
		if Empty(aCols[n,_nPosGGrupo])
			Help(1,"","GGVAZIO")
			
	        lRet := .F.
	    endif
	    
	    if lRet .and. !Empty(aCols[n,_nPosGGrupo]) .and. Empty(aCols[n,_nPosDescGrp])
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

user function LANCORCA()
	local nI
	local oGetDados
	local oButton, oGroup, oGet
	local nUsado := 0
	
	private cNum := SZ3->Z3_NUM
 	private cPro := SZ3->Z3_PROJETO
 	private cCli := SZ3->Z3_CLIENTE
 	private cLoj := SZ3->Z3_LOJA
 	private cDes := IIf(SA1->(DbSeek(xFilial("SA1")+cCli+cLoj,.F.)),SA1->A1_NOME,"NAO ENCONTRADO")
 	private nPosItem := 0
	private nPosVlAcert := 0
	private nPosVlAcrea := 0
 	private nLin := 0
 	private oDlg
	private lRefresh := .T.
	private aHeader := {}
	private aCols := {}
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","AxInclui",0,3},;
						{"Alterar","AxAltera",0,4},;
						{"Excluir","AxDeleta",0,5}}
	
	cValid := "S"
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SZ4")
	
	while !Eof() .and. SX3->X3_ARQUIVO == "SZ4"
		if AllTrim(SX3->X3_CAMPO) $ "Z4_ITEM/Z4_GGRUPO/Z4_DESCGGR/Z4_GRUPO/Z4_DESCGRP/Z4_VLACERT/Z4_VLACREA"
			if X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado++
				
				AAdd(aHeader,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,SX3->X3_VALID,"",SX3->X3_TIPO,"","",;
								SX3->X3_INIBRW,SX3->X3_RELACAO})
			endif
		endif
		
		DbSkip()
	enddo
	
	DbSelectArea("SZ4")
	DbSetOrder(1)
	DbSeek(xFilial("SZ4")+SZ3->(Z3_NUM+Z3_PROJETO+Z3_CLIENTE+Z3_LOJA))
	
	while !Eof() .and. SZ4->Z4_NUM == cNum .and. SZ4->Z4_PROJETO == cPro .and. SZ4->Z4_CLIENTE == cCli .and. SZ4->Z4_LOJA == cLoj
		AAdd(aCols,Array(nUsado + 1))
		
		for i := 1 to nUsado
			aCols[Len(aCols),i] := FieldGet(FieldPos(aHeader[i,2]))
		next
		
		aCols[Len(aCols),nUsado + 1] := .F.
		nLin++
		
		DbSkip()
	enddo
	
	nPosItem := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_ITEM"})
	nPosVlAcert := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLACERT"})
	nPosVlAcrea := AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "Z4_VLACREA"})
	
	define msdialog oDlg title "Lancamentos para Acerto" from 000,000 to 400,800 pixel
		oGroup := TGroup():New(005,005,050,396," Orcamento ",oDlg,,,.T.)
		
		@017,010 say "Projeto"
		@015,035 get cPro size 010,007 when Empty(cPro)
		@017,075 say "Orcam"
		@015,093 get cNum size 050,007 when Empty(cNum)
		@035,010 say "Cliente"
		@033,035 get cCli size 030,007 when Empty(cCli)
		@035,075 say "Loja"
		@033,093 get cLoj size 005,007 when Empty(cLoj)
		@035,120 say "Razao Soc."
		@033,150 get cDes size 200,007 when Empty(cDes)
		
		oGetDados := MsGetDados():New(055,005,180,396,4,,,"+Z4_ITEM",.F.,{"Z4_VLACERT","Z4_VLACREA"},,.F.,200,,,,,oDlg)
		
		oButton := TButton():New(185,330,"OK",oDlg,{|| Fechar(nPosItem,nPosVlAcert,nPosVlAcrea)},030,010,,,,.T.)
		oButton := TButton():New(185,366,"Cancel",oDlg,{|| oDlg:End()},030,010,,,,.T.)
	activate msdialog oDlg center
return

static function Fechar()
	for i := 1 to nLin
		cUpd := "update "+RetSqlName("SZ4")+" set Z4_VLACERT = "+AllTrim(Str(aCols[i][nPosVlAcert]))+", Z4_VLACREA = "+AllTrim(Str(aCols[i][nPosVlAcrea]))+", Z4_SALDO = Z4_VLORCAM + Z4_VLREVIS - Z4_EMPENHA - Z4_VLACERT - Z4_RESIDUO "
		cUpd += "where Z4_NUM = '"+cNum+"' and Z4_PROJETO = '"+cPro+"' and Z4_CLIENTE = '"+cCli+"' and Z4_LOJA = '"+cLoj+"' and Z4_ITEM = '"+aCols[i][nPosItem]+"'"
		
		nRet := TCSqlExec(cUpd)
	next
	
	oDlg:End()
return

user function ATUAORCA()
	local aArea := GetArea()
	local cProjeto := SZ3->Z3_PROJETO
	local aGrupo := {}, aGGrupo := {}
	local aSZ3 := {SZ3->Z3_FILIAL,SZ3->Z3_NUM,SZ3->Z3_CLIENTE,SZ3->Z3_LOJA,SZ3->Z3_PROJETO}
	
	if MsgNoYes("Os valores do projeto "+AllTrim(cProjeto)+" podera ser alterado, tem certeza que deseja atualizar?"," Confirmar ")
		//*** EMPENHADO ***\\
/*		cQry := "select BM_ORCGRP, B1_GRUPO, ((C7_QUANT - C7_QUJE) * C7_PRECO) + (((((C7_QUANT - C7_QUJE) * C7_PRECO)) * C7_IPI) / 100) as C7_TOTAL "
//		cQry := "select BM_ORCGRP, B1_GRUPO, (C7_TOTAL + C7_VALIPI) as C7_TOTAL "
		cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SB1")+" SB1 on (C7_PRODUTO = B1_COD and C7_LOCAL = B1_LOCPAD) "
		cQry += "	inner join "+RetSqlName("SBM")+" SBM on (B1_GRUPO = BM_GRUPO) "
		cQry += "where C7_CLVL = '"+cProjeto+"' and BM_ORCGRP <> '999' and SC7.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SBM.D_E_L_E_T_ <> '*' "
		cQry += "order by BM_ORCGRP, B1_GRUPO, C7_TOTAL "*/
		
		cQry := "select B1_GRUPO, BM_ORCGRP, C7_PRODUTO, C7_QUANT, C7_QUJE, C7_PRECO, C7_TOTAL, C7_RESIDUO, C7_ENCER, C7_IPI, C7_VALIPI "
		cQry += "from "+RetSqlName("SC7")+" SC7 inner join "+RetSqlName("SB1")+" SB1 on (C7_PRODUTO = B1_COD) "
		cQry += "	inner join "+RetSqlName("SBM")+" SBM on (B1_GRUPO = BM_GRUPO) "
		cQry += "where C7_CLVL = '"+cProjeto+"' and BM_ORCGRP <> '999' and SC7.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SBM.D_E_L_E_T_ <> '*' "
		cQry += "order by BM_ORCGRP, B1_GRUPO"
		
		tcquery cQry new alias "TEMP"
		
		DbSelectArea("TEMP")
		TEMP->(DbGoTop())
		
		nValor := 0
		
		while !TEMP->(Eof())
			if Empty(TEMP->C7_RESIDUO)
				nValor := TEMP->(C7_TOTAL + C7_VALIPI)
			else
				if !Empty(TEMP->C7_QUJE)
					nValor := TEMP->(C7_QUJE * C7_PRECO) + ((TEMP->(C7_QUJE * C7_PRECO) * TEMP->C7_VALIPI) / 100)
				else
					nValor := 0
				endif
			endif
			
			if (nInd := AScan(aGrupo,{|x| x[1] = TEMP->B1_GRUPO})) == 0
				AAdd(aGrupo,{TEMP->B1_GRUPO,nValor,0,"N",TEMP->BM_ORCGRP})
			else
				aGrupo[nInd][2] += nValor
			endif
			
			if (nInd := AScan(aGGrupo,{|x| x[1] = TEMP->BM_ORCGRP})) == 0
				AAdd(aGGrupo,{TEMP->BM_ORCGRP,nValor,0,"N"})
			else
				aGGrupo[nInd][2] += nValor
			endif
			
			TEMP->(DbSkip())
		enddo
		
		TEMP->(DbCloseArea())
		
		//*** REALIZADO ***\\
		cQry := "select BM_ORCGRP, B1_GRUPO, (D1_TOTAL + D1_VALIPI) as D1_TOTAL, (D1_VALDEV + ((D1_VALDEV * D1_IPI) / 100)) as D1_VALDEV "
		cQry += "from "+RetSqlName("SD1")+" SD1 inner join "+RetSqlName("SB1")+" SB1 on (D1_COD = B1_COD and D1_LOCAL = B1_LOCPAD) "
		cQry += "	inner join "+RetSqlName("SBM")+" SBM on (B1_GRUPO = BM_GRUPO) "
		cQry += "where D1_CLVL = '"+cProjeto+"' and BM_ORCGRP <> '999' and D1_TIPO not in ('B','D') and SD1.D_E_L_E_T_ <> '*' and SB1.D_E_L_E_T_ <> '*' and SBM.D_E_L_E_T_ <> '*' "
		cQry += "order by BM_ORCGRP, B1_GRUPO, D1_TOTAL "
		
		tcquery cQry new alias "TEMP"
		
		DbSelectArea("TEMP")
		TEMP->(DbGoTop())
		
		while !TEMP->(Eof())
			if (nInd := AScan(aGrupo,{|x| x[1] = TEMP->B1_GRUPO})) == 0
				AAdd(aGrupo,{TEMP->B1_GRUPO,0,TEMP->D1_TOTAL - TEMP->D1_VALDEV,"N",TEMP->BM_ORCGRP})
			else
				aGrupo[nInd][3] += (TEMP->D1_TOTAL - TEMP->D1_VALDEV) 
			endif
			
			if (nInd := AScan(aGGrupo,{|x| x[1] = TEMP->BM_ORCGRP})) == 0
				AAdd(aGGrupo,{TEMP->BM_ORCGRP,0,TEMP->D1_TOTAL - TEMP->D1_VALDEV,"N"})
			else
				aGGrupo[nInd][3] += (TEMP->D1_TOTAL - TEMP->D1_VALDEV) 
			endif
			
			TEMP->(DbSkip())
		enddo
		
		//*** ATUALIZAR SALDO DOS ITENS (SZ4) ***\\
		TEMP->(DbCloseArea())
		DbSelectArea("SZ4")
		SZ4->(DbSetOrder(3))
		
		if SZ4->(DbSeek(xFilial("SZ4")+cProjeto,.F.))
			nSaldo := 0
			nItem := 0
			
			while !SZ4->(Eof()) .and. SZ4->Z4_PROJETO == cProjeto
				nItem++
				cCodGrupo := AllTrim(SZ4->Z4_GRUPO)
				cCodGGrupo := AllTrim(SZ4->Z4_GGRUPO)
				
				if Empty(cCodGrupo)
					nInd := AScan(aGGrupo,{|x| x[1] = cCodGGrupo})
					
					if nInd > 0
						cEmpenha := AllTrim(Str(aGGrupo[nInd][2]))
						cRealiza := AllTrim(Str(aGGrupo[nInd][3]))
						cCondicao := "Z4_GGRUPO = '"+cCodGGrupo+"'"
						aGGrupo[nInd][4] := "S"
					else
						cEmpenha := "0"
						cRealiza := "0"
						cCondicao := "Z4_GGRUPO = '"+cCodGGrupo+"'"
					endif
				else
					nInd := AScan(aGGrupo,{|x| x[1] = cCodGGrupo})
					nInd1 := AScan(aGrupo,{|x| x[1] = cCodGrupo})
					
//					Alert("|"+aGGrupo[nInd][1]+"| = |"+cCodGrupo+"|")
					
					if nInd1 > 0
						cEmpenha := AllTrim(Str(aGGrupo[nInd][2]))
						cRealiza := AllTrim(Str(aGGrupo[nInd][3]))
						cCondicao := "Z4_GRUPO = '"+cCodGrupo+"'"
						aGGrupo[nInd][4] := "S"
						aGrupo[nInd1][4] := "S"
					else
						cEmpenha := "0"
						cRealiza := "0"
						cCondicao := "Z4_GGRUPO = '"+cCodGGrupo+"'"
					endif
				endif
				
//				if nInd > 0
					cUpd := "update "+RetSqlName("SZ4")+" "
					cUpd += "set Z4_EMPENHA = "+cEmpenha+", Z4_VLREALI = "+cRealiza+", Z4_SALDO = (Z4_VLORCAM + Z4_VLREVIS - "+cEmpenha+" - Z4_RESIDUO) "
					cUpd += "where Z4_PROJETO = '"+cProjeto+"' and "+cCondicao+" and D_E_L_E_T_ <> '*'"
					
					nRet := TCSqlExec(cUpd)
//				endif
				
				SZ4->(DbSkip())
			enddo
			
			//*** INCLUIR SZ4 CASO NAO TENHA LANCADO MANUALMENTE ***\\
			for i := 1 to Len(aGGrupo)
				if aGGrupo[i][4] == "N"
					if RecLock("SZ4",.T.)
						nItem++
						
						SZ4->Z4_FILIAL := aSZ3[1]
						SZ4->Z4_NUM := aSZ3[2]
						SZ4->Z4_CLIENTE := aSZ3[3]
						SZ4->Z4_LOJA := aSZ3[4]
						SZ4->Z4_ITEM := StrZero(nItem,2)
						SZ4->Z4_DTORCAM := dDataBase
						SZ4->Z4_VLORCAM := 0.01
						SZ4->Z4_EMPENHA := aGGrupo[i][2]
						SZ4->Z4_VLREALI := aGGrupo[i][3]
						SZ4->Z4_SALDO := 0.01 - aGGrupo[i][2]
						SZ4->Z4_GGRUPO := aGGrupo[i][1]
						SZ4->Z4_DESCGGR := IIf(SX5->(DbSeek(xFilial("SX5")+"GG"+aGGrupo[i][1],.F.)),SX5->X5_DESCRI,"")
						SZ4->Z4_INCSIST := "S"
						SZ4->Z4_HABREV := "N"
						SZ4->Z4_PROJETO := aSZ3[5]
						SZ4->Z4_RESIDUO	:= 0 
						
						MsUnLock()
					endif
				endif
			next
			
			//*** ATUALIZAR SALDO DO CABECALHO (SZ3) ***\\
			cUpd := "update "+RetSqlName("SZ3")+" "
			cUpd += "set Z3_SALDO = (select sum(Z4_SALDO) as Z4_SALDO "
			cUpd += "				from "+RetSqlName("SZ3")+" SZ3 inner join "+RetSqlName("SZ4")+" SZ4 on (Z3_PROJETO = Z4_PROJETO) "
			cUpd += "				where Z3_PROJETO = '"+cProjeto+"' and SZ3.D_E_L_E_T_ <> '*' and SZ4.D_E_L_E_T_ <> '*' "
			cUpd += "				group by Z3_PROJETO) "
			cUpd += "where Z3_PROJETO = '"+cProjeto+"' and D_E_L_E_T_ <> '*'"
			
			nRet := TCSqlExec(cUpd)
			
			MsgInfo("Projeto "+AllTrim(cProjeto)+" atualizado.")
		endif
	endif
	
	RestArea(aArea)
return

user function OUTPROJ()
	Alert("ola mundo")
return