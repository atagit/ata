/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 29/04/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Browse para cadastro de ordem de compra               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

#define _TAMCABEC 300

/* -- Cores disponíveis para legenda Customizada --
	Azul		001
	Verde		002
	Cinza		003
	Laranja		004
	Roxo		005
	Vermelho	006
	Amarelo		007
*/

user function CADOC()
	private _N1 := 0
	private nPrzVencOC := GetMV("MV_OCPRZ")
	private cCadastro := "Ordem de Compra"
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
							{"Visualizar","U_CADOC01('V')",0,2},;
							{"Incluir","U_CADOC01('I')",0,3},;
							{"Alterar","U_CADOC01('A')",0,4},;
							{"Excluir","U_CADOC01('E')",0,5},;
							{"Imprimir","U_RELOC(SZM->ZM_OC)",0,6},;
							{"Atualizar","U_ATUOC(SZM->ZM_OC,SZM->ZM_CODIGO)",0,7},;
							{"Validar","U_VALOC(SZM->ZM_OC,SZM->ZM_CODIGO)",0,8},;
							{"Consultar","U_CONOC(SZM->ZM_OC,SZM->ZM_CODIGO)",0,9},;
							{"Legenda","U_LEGCADOC()",0,9}}
	
	aColors := {{"ZM_VENCOC > dDataBase","BR_VERDE"},;
					{"(ZM_VENCOC - "+AllTrim(Str(nPrzVencOC))+") >= dDataBase","BR_AMARELO"},;
					{"ZM_VENCOC < dDataBase","BR_VERMELHO"}}
	
	DbSelectArea("SZM")
	DbSetOrder(1)
	MBrowse(06,01,22,75,"SZM",,,,,,aColors)
return

user function LEGCADOC()
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
	
	AAdd(aLegenda,{"BR_VERDE","OC dentro do prazo"})
	AAdd(aLegenda,{"BR_AMARELO","OC "+AllTrim(Str(nPrzVencOC))+"dia(s) p/ vencer"})
	AAdd(aLegenda,{"BR_VERMELHO","Oc prazo vencido"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return (.T.)

user function CADOC01(cOpcao)
	SetPrvt("cTitulo,cAliasEnchoice,cAliasGetD,cLinOk,cTudOk,cFieldOk,aCpoEnchoice,aButtons")
	SetPrvt("aHeader,aCols,nOpcE,nOpcG,cTit,n,cValid")
	SetPrvt("lVisual,lInclui,lAltera,lExclui")
	SetPrvt("_nPosCodigo","_nPosItem","_nPosProjeto","_nPosQuant","_nPosUm","_nPosPrcUnit","_nPosTotal","_nPosVenc","_nPosDel","_nPosATF22",;
			"_nPosBmp","_nPosProduto")
	
	n := 1
	cValid := ""
	
	lVisual := IIf(cOpcao == "V",.T.,.F.)
	lInclui := IIf(cOpcao == "I",.T.,.F.)
	lAltera := IIf(cOpcao == "A",.T.,.F.)
	lExclui := IIf(cOpcao == "E",.T.,.F.)
	
	do case
		case cOpcao == "I" ; nOpcE := 3 ; nOpcG := 3 ; cTit := IIf(!Empty(cTit),"Incluir","")
		case cOpcao == "A" ; nOpcE := 3 ; nOpcG := 3 ; cTit := IIf(!Empty(cTit),"Alterar","")
		case cOpcao == "V" ; nOpcE := 2 ; nOpcG := 2 ; cTit := IIf(!Empty(cTit),"Visualizar","")
		otherwise ; cTit := IIf(!Empty(cTit),"Excluir","")
	endcase
	
	RegToMemory("SZM",lInclui)
	RegToMemory("SZN",lAltera)
	
	nUsado := 0
	aHeader := {}
	
	DbSelectArea("SX3")
	DbSeek("SZN")
	
	while !Eof() .and. X3_ARQUIVO == "SZN"
		if AllTrim(X3_CAMPO) == "ZN_FILIAL" .or. AllTrim(X3_CAMPO) == "ZN_CODIGO"
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
//			aCols[1,_ni] := IIf(AllTrim(Upper(aHeader[_ni,2])) == "ZN_ITEM",StrZero(_ni,2),CriaVar(aHeader[_ni,2]))
			aCols[1,_ni] := IIf(AllTrim(Upper(aHeader[_ni,2])) == "ZN_ITEM","01",CriaVar(aHeader[_ni,2]))
		next
	else
		if lVisual
			n := 1
		endif
		
		aCols := {}
		
		DbSelectArea("SZN")
		DbSetOrder(1)
		DbSeek(xFilial()+M->ZM_CODIGO)
		
		while !Eof() .and. xFilial() == SZN->ZN_FILIAL .and. SZN->ZN_CODIGO == M->ZM_CODIGO
			AAdd(aCols,Array(nUsado + 1))
			
			for _ni := 1 to nUsado
				if Upper(AllTrim(aHeader[_ni,10])) != "V"			// Campo Real
					aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				else												// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[_ni,2]))
					
					do case
						case cCpo == "ZN_DESCRI"
							aCols[Len(aCols),_ni] := GetAdvFVal("CTH","CTH_DESC01",xFilial("CTH")+SZN->ZN_PROJETO,1,"DESCRICAO NAO ENCONTRADA!!")
						otherwise
							aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
					endcase
				endif
			next
			
			aCols[Len(aCols),nUsado + 1] := .F.
			
			DbSkip()
		enddo
	endif
	
	_nPosCodigo		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_CODIGO"})
	_nPosItem		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_ITEM"})
	_nPosProjeto	:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_PROJETO"})
	_nPosQuant		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_QUANT"})
	_nPosUm			:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_UM"})
	_nPosPrcUnit	:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_PRCUNIT"})
	_nPosTotal		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_TOTAL"})
	_nPosVenc		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_VENCPRJ"})
//	_nPosATF22		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_ATF22"})
	_nPosBmp		:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_BMP"})
	_nPosProduto	:= AScan(aHeader,{|x| AllTrim(Upper(x[2])) == "ZN_PRODUTO"})
	_nPosDel		:= Len(aHeader) + 1
	
	if Len(aCols) <= 0
	    AAdd(aCols,Array(nUsado + 1))
	    
	    n := 1
	    
	    for _ni := 1 to nUsado
	        aCols[1,_ni] := CriaVar(aHeader[_ni,2])
	    next _ni
	    
	    aCols[1,_nPosItem] := "01"
	    aCols[1,nUsado + 1] := .T.		// Define como deletado
	endif
	
	cTitulo := "Ordem de Compra "+cTit
	cAliasEnchoice := "SZM"
	cAliasGetD := "SZN"
	cLinOk := "U_CadOCVld1()"
	cTudOk := "AllwaysTrue()"
	cFieldOk := "AllwaysTrue()"
	aCpoEnchoice := {"ZM_CODIGO"}
	aCordW := {00000,00000,0500,1250}
	aButtons := {{"Legenda",{|| LegendaSZN()},"BR_VERMELHO","Legenda"}}
	
/*	if lAltera
		if !Empty(M->Z3_PROJETO)
			aAltEnchoice := {"Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA","Z3_FECHADO"}
		else
			aAltEnchoice := {"Z3_PROJETO","Z3_CONTRAT","Z3_DTFIM","Z3_OBSERVA","Z3_FECHADO"}
		endif
	else
		aAltEnchoice := {}
	endif*/
	
	aAltEnchoice := {}
	
	DbSelectArea("SX3")
	DbSeek("SZM")
	
	while !Eof() .and. X3_ARQUIVO == "SZM"
		if AllTrim(X3_CAMPO) == "ZM_FILIAL"
			DbSkip()
			
			loop
		endif
		
		if X3Uso(X3_USADO) .and. cNivel >= X3_NIVEL
			AAdd(aAltEnchoice,AllTrim(X3_CAMPO))
		endif
		
		DbSkip()
	enddo
	
/*	aAltEnchoice := {"ZM_OC","ZM_VENCOC","ZM_CLIENTE","ZM_LOJA","ZM_CONTATO","ZM_QUANT","ZM_UM","ZM_PRCUNIT","ZM_TOTAL","ZM_ADIANTA","ZM_VLADIAN","ZM_GARANTI","ZM_VENGARA","ZM_BCOEMIT",;
						"ZM_PERCDB","ZM_VLDB","ZM_MULTA","ZM_VLMULTA","ZM_VENMULT","ZM_CONDPAG","ZM_ALQICMS","ZM_BASICMS","ZM_VALICMS","ZM_ALQIPI","ZM_BASIPI","ZM_VALIPI","ZM_ALQPIS",;
						"ZM_BASPIS","ZM_VALPIS","ZM_ALQCOF","ZM_BASCOF","ZM_VALCOF","ZM_ALQISS","ZM_BASISS","ZM_VALISS","ZM_NCM","ZM_TES1","ZM_TES2","ZM_TES3","ZM_TES4","ZM_PRJQTD",;
						"ZM_PRJVLR","ZM_PRJSLDQ","ZM_PRJSLDV","ZM_EMAIL","ZM_EMAILNF","ZM_TOTALG","ZM_T1CLI","ZM_T1LOJ","ZM_T2CLI","ZM_T2LOJ","ZM_T3CLI","ZM_T3LOJ","ZM_T4CLI","ZM_T4LOJ",;
						"ZM_VENADIA","ZM_PERCGAR","ZM_VENDB","ZM_DESTINA","ZM_ATT","ZM_BSADIAN","ZM_BSGARAN","ZM_VLGARAN","ZM_BSDATAB","ZM_BSMULTA","ZM_OBSICMS","ZM_OBSIPI","ZM_OBSPIS",;
						"ZM_OBSCOF","ZM_OBSISS","ZM_NATOPER","ZM_BCOREC","ZM_PROJETO","ZM_NATFAT","ZM_GARAPLI","ZM_GARDOC","ZM_GARANT2","ZM_GARDOC2","ZM_BCOEMI2","ZM_PERGAR2","ZM_BSGARA2",;
						"ZM_VLGARA2","ZM_VENGAR2","ZM_GARAPL2","ZM_GARANT3","ZM_GARDOC3","ZM_BCOEMI3","ZM_PERGAR3","ZM_BSGARA3","ZM_VLGARA3","ZM_VENGAR3","ZM_GARAPL3","ZM_GARANT4","ZM_GARDOC4",;
						"ZM_BCOEMI4","ZM_PERGAR4","ZM_BSGARA4","ZM_VLGARA4","ZM_VENGAR4","ZM_GARAPL4","ZM_GARANT5","ZM_GARDOC5","ZM_BCOEMI5","ZM_PERGAR5","ZM_BSGARA5","ZM_VLGARA5","ZM_VENGAR5",;
						"ZM_GARAPL5","ZM_VLAPLIC","ZM_VLAPLI2","ZM_VLAPLI3","ZM_VLAPLI4","ZM_VLAPLI5","ZM_PERRETE","ZM_BSRETEN","ZM_VLRETEN","ZM_VENRETE","ZM_DDADIC","ZM_TPPESAG"}*/
	
	if !lInclui
		_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,,aButtons,aCordW,_TAMCABEC)
		
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
			_lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,,,,aCordW,_TAMCABEC)
			
			if _lRet
//				if Empty(M->ZM_CODIGO) .or. Empty(M->ZM_CLIENTE) .or. Empty(M->ZM_LOJA)
				if Empty(M->ZM_CODIGO)
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
	DbSelectArea("SZM")
	RecLock("SZM",.T.)
		SZM->ZM_FILIAL	:= xFilial()
		SZM->ZM_CODIGO	:= M->ZM_CODIGO
		SZM->ZM_OC		:= M->ZM_OC
		SZM->ZM_VENCOC	:= M->ZM_VENCOC
		SZM->ZM_CLIENTE	:= M->ZM_CLIENTE
		SZM->ZM_LOJA	:= M->ZM_LOJA
		SZM->ZM_CONTATO	:= M->ZM_CONTATO
		SZM->ZM_QUANT	:= M->ZM_QUANT
		SZM->ZM_UM		:= M->ZM_UM
		SZM->ZM_PRCUNIT	:= M->ZM_PRCUNIT
		SZM->ZM_TOTAL	:= M->ZM_TOTAL
		SZM->ZM_ADIANTA	:= M->ZM_ADIANTA
		SZM->ZM_VLADIAN	:= M->ZM_VLADIAN
		SZM->ZM_GARANTI	:= M->ZM_GARANTI
		SZM->ZM_VENGARA	:= M->ZM_VENGARA
		SZM->ZM_BCOEMIT	:= M->ZM_BCOEMIT
		SZM->ZM_PERCDB	:= M->ZM_PERCDB
		SZM->ZM_VLDB	:= M->ZM_VLDB
		SZM->ZM_MULTA	:= M->ZM_MULTA
		SZM->ZM_VLMULTA	:= M->ZM_VLMULTA
		SZM->ZM_VENMULT	:= M->ZM_VENMULT
		SZM->ZM_CONDPAG	:= M->ZM_CONDPAG
		SZM->ZM_ALQICMS	:= M->ZM_ALQICMS
		SZM->ZM_BASICMS	:= M->ZM_BASICMS
		SZM->ZM_VALICMS	:= M->ZM_VALICMS
		SZM->ZM_ALQIPI	:= M->ZM_ALQIPI
		SZM->ZM_BASIPI	:= M->ZM_BASIPI
		SZM->ZM_VALIPI	:= M->ZM_VALIPI
		SZM->ZM_ALQPIS	:= M->ZM_ALQPIS
		SZM->ZM_BASPIS	:= M->ZM_BASPIS
		SZM->ZM_VALPIS	:= M->ZM_VALPIS
		SZM->ZM_ALQCOF	:= M->ZM_ALQCOF
		SZM->ZM_BASCOF	:= M->ZM_BASCOF
		SZM->ZM_VALCOF	:= M->ZM_VALCOF
		SZM->ZM_ALQISS	:= M->ZM_ALQISS
		SZM->ZM_BASISS	:= M->ZM_BASISS
		SZM->ZM_VALISS	:= M->ZM_VALISS
		SZM->ZM_NCM		:= M->ZM_NCM
		SZM->ZM_TES1	:= M->ZM_TES1
		SZM->ZM_TES2	:= M->ZM_TES2
		SZM->ZM_TES3	:= M->ZM_TES3
		SZM->ZM_TES4	:= M->ZM_TES4
		SZM->ZM_PRJQTD	:= M->ZM_PRJQTD
		SZM->ZM_PRJVLR	:= M->ZM_PRJVLR
		SZM->ZM_PRJSLDQ	:= M->ZM_PRJSLDQ
		SZM->ZM_PRJSLDV	:= M->ZM_PRJSLDV
		SZM->ZM_EMAIL	:= M->ZM_EMAIL
		SZM->ZM_EMAILNF	:= M->ZM_EMAILNF
		SZM->ZM_TOTALG	:= M->ZM_TOTALG
		SZM->ZM_T1CLI	:= M->ZM_T1CLI
		SZM->ZM_T1LOJ	:= M->ZM_T1LOJ
		SZM->ZM_T2CLI	:= M->ZM_T2CLI
		SZM->ZM_T2LOJ	:= M->ZM_T2LOJ
		SZM->ZM_T3CLI	:= M->ZM_T3CLI
		SZM->ZM_T3LOJ	:= M->ZM_T3LOJ
		SZM->ZM_T4CLI	:= M->ZM_T4CLI
		SZM->ZM_T4LOJ	:= M->ZM_T4LOJ
		SZM->ZM_VENADIA	:= M->ZM_VENADIA
		SZM->ZM_PERCGAR	:= M->ZM_PERCGAR
		SZM->ZM_VENDB	:= M->ZM_VENDB
		SZM->ZM_DESTINA	:= M->ZM_DESTINA
		SZM->ZM_ATT		:= M->ZM_ATT
		SZM->ZM_BSADIAN	:= M->ZM_BSADIAN
		SZM->ZM_BSGARAN	:= M->ZM_BSGARAN
		SZM->ZM_VLGARAN	:= M->ZM_VLGARAN
		SZM->ZM_BSDATAB	:= M->ZM_BSDATAB
		SZM->ZM_BSMULTA	:= M->ZM_BSMULTA
		SZM->ZM_OBSICMS	:= M->ZM_OBSICMS
		SZM->ZM_OBSIPI	:= M->ZM_OBSIPI
		SZM->ZM_OBSPIS	:= M->ZM_OBSPIS
		SZM->ZM_OBSCOF	:= M->ZM_OBSCOF
		SZM->ZM_OBSISS	:= M->ZM_OBSISS
		SZM->ZM_NATOPER	:= M->ZM_NATOPER
		SZM->ZM_BCOREC	:= M->ZM_BCOREC
		SZM->ZM_PROJETO	:= M->ZM_PROJETO
		SZM->ZM_NATFAT	:= M->ZM_NATFAT
		SZM->ZM_GARAPLI	:= M->ZM_GARAPLI
		SZM->ZM_GARDOC	:= M->ZM_GARDOC
		SZM->ZM_GARANT2	:= M->ZM_GARANT2
		SZM->ZM_GARDOC2	:= M->ZM_GARDOC2
		SZM->ZM_BCOEMI2	:= M->ZM_BCOEMI2
		SZM->ZM_PERGAR2	:= M->ZM_PERGAR2
		SZM->ZM_BSGARA2	:= M->ZM_BSGARA2
		SZM->ZM_VLGARA2	:= M->ZM_VLGARA2
		SZM->ZM_VENGAR2	:= M->ZM_VENGAR2
		SZM->ZM_GARAPL2	:= M->ZM_GARAPL2
		SZM->ZM_GARANT3	:= M->ZM_GARANT3
		SZM->ZM_GARDOC3	:= M->ZM_GARDOC3
		SZM->ZM_BCOEMI3	:= M->ZM_BCOEMI3
		SZM->ZM_PERGAR3	:= M->ZM_PERGAR3
		SZM->ZM_BSGARA3	:= M->ZM_BSGARA3
		SZM->ZM_VLGARA3	:= M->ZM_VLGARA3
		SZM->ZM_VENGAR3	:= M->ZM_VENGAR3
		SZM->ZM_GARAPL3	:= M->ZM_GARAPL3
		SZM->ZM_GARANT4	:= M->ZM_GARANT4
		SZM->ZM_GARDOC4	:= M->ZM_GARDOC4
		SZM->ZM_BCOEMI4	:= M->ZM_BCOEMI4
		SZM->ZM_PERGAR4	:= M->ZM_PERGAR4
		SZM->ZM_BSGARA4	:= M->ZM_BSGARA4
		SZM->ZM_VLGARA4	:= M->ZM_VLGARA4
		SZM->ZM_VENGAR4	:= M->ZM_VENGAR4
		SZM->ZM_GARAPL4	:= M->ZM_GARAPL4
		SZM->ZM_GARANT5	:= M->ZM_GARANT5
		SZM->ZM_GARDOC5	:= M->ZM_GARDOC5
		SZM->ZM_BCOEMI5	:= M->ZM_BCOEMI5
		SZM->ZM_PERGAR5	:= M->ZM_PERGAR5
		SZM->ZM_BSGARA5	:= M->ZM_BSGARA5
		SZM->ZM_VLGARA5	:= M->ZM_VLGARA5
		SZM->ZM_VENGAR5	:= M->ZM_VENGAR5
		SZM->ZM_GARAPL5	:= M->ZM_GARAPL5
		SZM->ZM_VLAPLIC := M->ZM_VLAPLIC
		SZM->ZM_VLAPLI2 := M->ZM_VLAPLI2
		SZM->ZM_VLAPLI3 := M->ZM_VLAPLI3
		SZM->ZM_VLAPLI4 := M->ZM_VLAPLI4
		SZM->ZM_VLAPLI5 := M->ZM_VLAPLI5
		SZM->ZM_PERRETE := M->ZM_PERRETE
		SZM->ZM_BSRETEN := M->ZM_BSRETEN
		SZM->ZM_VLRETEN := M->ZM_VLRETEN
		SZM->ZM_VENRETE := M->ZM_VENRETE
		SZM->ZM_DDADIC	:= M->ZM_DDADIC
		SZM->ZM_TPPESAG	:= M->ZM_TPPESAG
		SZM->ZM_CONDPGT	:= M->ZM_CONDPGT
		SZM->ZM_NATUR1	:= M->ZM_NATUR1
		SZM->ZM_NATUR2	:= M->ZM_NATUR2
		SZM->ZM_NATUR3	:= M->ZM_NATUR3
		SZM->ZM_NATUR4	:= M->ZM_NATUR4
	MsUnLock()
	ConfirmSx8()
	
	nNumIt := 1
	nTotSaldo := 0
	nTotQuant := 0
	nTotTotal := 0
	
	for nIt := 1 to Len(aCols)
		if !aCols[nIt,_nPosDel]
			DbSelectArea("SZN")
			DbSetOrder(1)
			
			RecLock("SZN",.T.)
				SZN->ZN_FILIAL	:= xFilial()
				SZN->ZN_CODIGO	:= M->ZM_CODIGO
				SZN->ZN_ITEM	:= aCols[nIt,_nPosItem]
				SZN->ZN_PROJETO	:= aCols[nIt,_nPosProjeto]
				SZN->ZN_QUANT	:= aCols[nIt,_nPosQuant]
				SZN->ZN_UM		:= aCols[nIt,_nPosUm]
				SZN->ZN_PRCUNIT	:= aCols[nIt,_nPosPrcUnit]
				SZN->ZN_TOTAL	:= aCols[nIt,_nPosTotal]
				SZN->ZN_VENCPRJ	:= aCols[nIt,_nPosVenc]
//				SZN->ZN_ATF22	:= aCols[nIt,_nPosATF22]
				SZN->ZN_BMP		:= aCols[nIt,_nPosBmp]
				SZN->ZN_PRODUTO	:= aCols[nIt,_nPosProduto]
				
//				nTotSaldo += aCols[nIt,_nPosSaldo]
				nTotQuant += aCols[nIt,_nPosQuant]
				nTotTotal += aCols[nIt,_nPosTotal]
				nNumIt++
			MsUnLock()
//		else
//			nNumIt++
		endif
	next nIt
	
	DbSelectArea("SZM")
	DbSetOrder(1)
	DbSeek(xFilial()+M->ZM_CODIGO)
	RecLock("SZM",.F.)
		SZM->ZM_PRJQTD	:= nTotQuant
		SZM->ZM_PRJVLR	:= nTotTotal
		SZM->ZM_PRJSLDQ	:= M->ZM_QUANT - nTotQuant
		SZM->ZM_PRJSLDV	:= M->ZM_TOTAL - nTotTotal
	MsUnLock()
	
	DbSelectArea("SZM")
return

static function AlteraBanco()
	DbSelectArea("SZM")
	DbSetOrder(1)
	DbSeek(xFilial()+M->ZM_CODIGO)
	RecLock("SZM",.F.)
		SZM->ZM_FILIAL	:= xFilial()
		SZM->ZM_CODIGO	:= M->ZM_CODIGO
		SZM->ZM_OC		:= M->ZM_OC
		SZM->ZM_VENCOC	:= M->ZM_VENCOC
		SZM->ZM_CLIENTE	:= M->ZM_CLIENTE
		SZM->ZM_LOJA	:= M->ZM_LOJA
		SZM->ZM_CONTATO	:= M->ZM_CONTATO
		SZM->ZM_QUANT	:= M->ZM_QUANT
		SZM->ZM_UM		:= M->ZM_UM
		SZM->ZM_PRCUNIT	:= M->ZM_PRCUNIT
		SZM->ZM_TOTAL	:= M->ZM_TOTAL
		SZM->ZM_ADIANTA	:= M->ZM_ADIANTA
		SZM->ZM_VLADIAN	:= M->ZM_VLADIAN
		SZM->ZM_GARANTI	:= M->ZM_GARANTI
		SZM->ZM_VENGARA	:= M->ZM_VENGARA
		SZM->ZM_BCOEMIT	:= M->ZM_BCOEMIT
		SZM->ZM_PERCDB	:= M->ZM_PERCDB
		SZM->ZM_VLDB	:= M->ZM_VLDB
		SZM->ZM_MULTA	:= M->ZM_MULTA
		SZM->ZM_VLMULTA	:= M->ZM_VLMULTA
		SZM->ZM_VENMULT	:= M->ZM_VENMULT
		SZM->ZM_CONDPAG	:= M->ZM_CONDPAG
		SZM->ZM_ALQICMS	:= M->ZM_ALQICMS
		SZM->ZM_BASICMS	:= M->ZM_BASICMS
		SZM->ZM_VALICMS	:= M->ZM_VALICMS
		SZM->ZM_ALQIPI	:= M->ZM_ALQIPI
		SZM->ZM_BASIPI	:= M->ZM_BASIPI
		SZM->ZM_VALIPI	:= M->ZM_VALIPI
		SZM->ZM_ALQPIS	:= M->ZM_ALQPIS
		SZM->ZM_BASPIS	:= M->ZM_BASPIS
		SZM->ZM_VALPIS	:= M->ZM_VALPIS
		SZM->ZM_ALQCOF	:= M->ZM_ALQCOF
		SZM->ZM_BASCOF	:= M->ZM_BASCOF
		SZM->ZM_VALCOF	:= M->ZM_VALCOF
		SZM->ZM_ALQISS	:= M->ZM_ALQISS
		SZM->ZM_BASISS	:= M->ZM_BASISS
		SZM->ZM_VALISS	:= M->ZM_VALISS
		SZM->ZM_NCM		:= M->ZM_NCM
		SZM->ZM_TES1	:= M->ZM_TES1
		SZM->ZM_TES2	:= M->ZM_TES2
		SZM->ZM_TES3	:= M->ZM_TES3
		SZM->ZM_TES4	:= M->ZM_TES4
		SZM->ZM_PRJQTD	:= M->ZM_PRJQTD
		SZM->ZM_PRJVLR	:= M->ZM_PRJVLR
		SZM->ZM_PRJSLDQ	:= M->ZM_PRJSLDQ
		SZM->ZM_PRJSLDV	:= M->ZM_PRJSLDV
		SZM->ZM_EMAIL	:= M->ZM_EMAIL
		SZM->ZM_EMAILNF	:= M->ZM_EMAILNF
		SZM->ZM_TOTALG	:= M->ZM_TOTALG
		SZM->ZM_T1CLI	:= M->ZM_T1CLI
		SZM->ZM_T1LOJ	:= M->ZM_T1LOJ
		SZM->ZM_T2CLI	:= M->ZM_T2CLI
		SZM->ZM_T2LOJ	:= M->ZM_T2LOJ
		SZM->ZM_T3CLI	:= M->ZM_T3CLI
		SZM->ZM_T3LOJ	:= M->ZM_T3LOJ
		SZM->ZM_T4CLI	:= M->ZM_T4CLI
		SZM->ZM_T4LOJ	:= M->ZM_T4LOJ
		SZM->ZM_VENADIA	:= M->ZM_VENADIA
		SZM->ZM_PERCGAR	:= M->ZM_PERCGAR
		SZM->ZM_VENDB	:= M->ZM_VENDB
		SZM->ZM_DESTINA	:= M->ZM_DESTINA
		SZM->ZM_ATT		:= M->ZM_ATT
		SZM->ZM_BSADIAN	:= M->ZM_BSADIAN
		SZM->ZM_BSGARAN	:= M->ZM_BSGARAN
		SZM->ZM_VLGARAN	:= M->ZM_VLGARAN
		SZM->ZM_BSDATAB	:= M->ZM_BSDATAB
		SZM->ZM_BSMULTA	:= M->ZM_BSMULTA
		SZM->ZM_OBSICMS	:= M->ZM_OBSICMS
		SZM->ZM_OBSIPI	:= M->ZM_OBSIPI
		SZM->ZM_OBSPIS	:= M->ZM_OBSPIS
		SZM->ZM_OBSCOF	:= M->ZM_OBSCOF
		SZM->ZM_OBSISS	:= M->ZM_OBSISS
		SZM->ZM_NATOPER	:= M->ZM_NATOPER
		SZM->ZM_BCOREC	:= M->ZM_BCOREC
		SZM->ZM_PROJETO	:= M->ZM_PROJETO
		SZM->ZM_NATFAT	:= M->ZM_NATFAT
		SZM->ZM_GARAPLI	:= M->ZM_GARAPLI
		SZM->ZM_GARDOC	:= M->ZM_GARDOC
		SZM->ZM_GARANT2	:= M->ZM_GARANT2
		SZM->ZM_GARDOC2	:= M->ZM_GARDOC2
		SZM->ZM_BCOEMI2	:= M->ZM_BCOEMI2
		SZM->ZM_PERGAR2	:= M->ZM_PERGAR2
		SZM->ZM_BSGARA2	:= M->ZM_BSGARA2
		SZM->ZM_VLGARA2	:= M->ZM_VLGARA2
		SZM->ZM_VENGAR2	:= M->ZM_VENGAR2
		SZM->ZM_GARAPL2	:= M->ZM_GARAPL2
		SZM->ZM_GARANT3	:= M->ZM_GARANT3
		SZM->ZM_GARDOC3	:= M->ZM_GARDOC3
		SZM->ZM_BCOEMI3	:= M->ZM_BCOEMI3
		SZM->ZM_PERGAR3	:= M->ZM_PERGAR3
		SZM->ZM_BSGARA3	:= M->ZM_BSGARA3
		SZM->ZM_VLGARA3	:= M->ZM_VLGARA3
		SZM->ZM_VENGAR3	:= M->ZM_VENGAR3
		SZM->ZM_GARAPL3	:= M->ZM_GARAPL3
		SZM->ZM_GARANT4	:= M->ZM_GARANT4
		SZM->ZM_GARDOC4	:= M->ZM_GARDOC4
		SZM->ZM_BCOEMI4	:= M->ZM_BCOEMI4
		SZM->ZM_PERGAR4	:= M->ZM_PERGAR4
		SZM->ZM_BSGARA4	:= M->ZM_BSGARA4
		SZM->ZM_VLGARA4	:= M->ZM_VLGARA4
		SZM->ZM_VENGAR4	:= M->ZM_VENGAR4
		SZM->ZM_GARAPL4	:= M->ZM_GARAPL4
		SZM->ZM_GARANT5	:= M->ZM_GARANT5
		SZM->ZM_GARDOC5	:= M->ZM_GARDOC5
		SZM->ZM_BCOEMI5	:= M->ZM_BCOEMI5
		SZM->ZM_PERGAR5	:= M->ZM_PERGAR5
		SZM->ZM_BSGARA5	:= M->ZM_BSGARA5
		SZM->ZM_VLGARA5	:= M->ZM_VLGARA5
		SZM->ZM_VENGAR5	:= M->ZM_VENGAR5
		SZM->ZM_GARAPL5	:= M->ZM_GARAPL5
		SZM->ZM_VLAPLIC := M->ZM_VLAPLIC
		SZM->ZM_VLAPLI2 := M->ZM_VLAPLI2
		SZM->ZM_VLAPLI3 := M->ZM_VLAPLI3
		SZM->ZM_VLAPLI4 := M->ZM_VLAPLI4
		SZM->ZM_VLAPLI5 := M->ZM_VLAPLI5
		SZM->ZM_PERRETE := M->ZM_PERRETE
		SZM->ZM_BSRETEN := M->ZM_BSRETEN
		SZM->ZM_VLRETEN := M->ZM_VLRETEN
		SZM->ZM_VENRETE := M->ZM_VENRETE
		SZM->ZM_DDADIC	:= M->ZM_DDADIC
		SZM->ZM_TPPESAG	:= M->ZM_TPPESAG
		SZM->ZM_CONDPGT	:= M->ZM_CONDPGT
		SZM->ZM_NATUR1	:= M->ZM_NATUR1
		SZM->ZM_NATUR2	:= M->ZM_NATUR2
		SZM->ZM_NATUR3	:= M->ZM_NATUR3
		SZM->ZM_NATUR4	:= M->ZM_NATUR4
	MsUnLock()
	
//	nTotSaldo := 0
//	nTotOrcad := 0
	nTotQuant := 0
	nTotTotal := 0
	
	for nIt := 1 to Len(aCols)
		if !aCols[nIt,_nPosDel]
			DbSelectArea("SZN")
			DbSetOrder(1)
			
			if !DbSeek(xFilial()+M->ZM_CODIGO+aCols[nIt,_nPosItem])
				RecLock("SZN",.T.)
					SZN->ZN_FILIAL	:= xFilial()
					SZN->ZN_CODIGO	:= M->ZM_CODIGO
					SZN->ZN_ITEM	:= aCols[nIt,_nPosItem]
					SZN->ZN_PROJETO	:= aCols[nIt,_nPosProjeto]
					SZN->ZN_QUANT	:= aCols[nIt,_nPosQuant]
					SZN->ZN_UM		:= aCols[nIt,_nPosUm]
					SZN->ZN_PRCUNIT	:= aCols[nIt,_nPosPrcUnit]
					SZN->ZN_TOTAL	:= aCols[nIt,_nPosTotal]
					SZN->ZN_VENCPRJ	:= aCols[nIt,_nPosVenc]
//					SZN->ZN_ATF22	:= aCols[nIt,_nPosATF22]
					SZN->ZN_BMP		:= aCols[nIt,_nPosBmp]
					SZN->ZN_PRODUTO	:= aCols[nIt,_nPosProduto]
				MsUnLock()
			else
				RecLock("SZN",.F.)
					SZN->ZN_PROJETO	:= aCols[nIt,_nPosProjeto]
					SZN->ZN_QUANT	:= aCols[nIt,_nPosQuant]
					SZN->ZN_UM		:= aCols[nIt,_nPosUm]
					SZN->ZN_PRCUNIT	:= aCols[nIt,_nPosPrcUnit]
					SZN->ZN_TOTAL	:= aCols[nIt,_nPosTotal]
					SZN->ZN_VENCPRJ	:= aCols[nIt,_nPosVenc]
//					SZN->ZN_ATF22	:= aCols[nIt,_nPosATF22]
					SZN->ZN_BMP		:= aCols[nIt,_nPosBmp]
					SZN->ZN_PRODUTO	:= aCols[nIt,_nPosProduto]
				MsUnLock()
			endif
			
//			nTotSaldo += aCols[nIt,_nPosSaldo]
//			nTotOrcad += (aCols[nIt,_nPosVlOrcam] + aCols[nIt,_nPosVlRevis])
			nTotQuant += aCols[nIt,_nPosQuant]
			nTotTotal += aCols[nIt,_nPosTotal]
	    else
			DbSelectArea("SZN")
			DbSetOrder(1)
			
			if DbSeek(xFilial()+M->ZM_CODIGO+aCols[nIt,_nPosItem])
	            RecLock("SZN",.F.)
	            	DbDelete()
	            MsUnLock()
	            
	            DbSelectArea("SX2")
	            DbSeek("SZN")
	            RecLock("SX2",.F.)
	            	SX2->X2_DELET := SX2->X2_DELET + 1
	            MsUnLock()
	        endif
	    endif
	next nIt
	
	DbSelectArea("SZM")
	DbSetOrder(1)
	DbSeek(xFilial()+M->ZM_CODIGO)
	RecLock("SZM",.F.)
		SZM->ZM_PRJQTD	:= nTotQuant
		SZM->ZM_PRJVLR	:= nTotTotal
		SZM->ZM_PRJSLDQ	:= M->ZM_QUANT - nTotQuant
		SZM->ZM_PRJSLDV	:= M->ZM_TOTAL - nTotTotal
	MsUnLock()
	
	nNumIt := 1
	
	DbSelectArea("SZN")
	DbSetOrder(1)
	DbSeek(xFilial("SZN")+SZM->ZM_CODIGO)
	
	while !Eof() .and. xFilial("SZN") == SZ2->Z2_FILIAL .and. SZN->ZN_CODIGO == SZM->ZM_CODIGO
	    RecLock("SZN",.F.)
		    SZN->ZN_ITEM := StrZero(nNumIt,2)
		    nNumIt++
	    MsUnLock()
		
		DbSkip()
	enddo
	
	DbSelectArea("SZM")
return

static function ExcluiBanco()
    for _nIt := 1 to Len(aCols)
        DbSelectArea("SZN")
        DbSetOrder(1)
        
        if DbSeek(xFilial()+M->ZM_CODIGO+aCols[_nIt,_nPosItem])
            RecLock("SZN",.F.)
            	DbDelete()
            MsUnLock()
            
            DbSelectArea("SX2")
            DbSeek("SZN")
            RecLock("SX2",.F.)
            	SX2->X2_DELET := SX2->X2_DELET + 1
            MsUnLock()
        endif
    next _nIt

    DbSelectArea("SZM")
    DbSetOrder(1)
    
    if DbSeek(xFilial()+M->ZM_CODIGO)
        RecLock("SZM",.F.)
        	DbDelete()
        MsUnLock()
        
        DbSelectArea("SX2")
        DbSeek("SZM")
        RecLock("SX2",.F.)
        	SX2->X2_DELET := SX2->X2_DELET + 1
        MsUnLock()
    endif
return

user function CadOCVld1()
	local lRet := .T.
	local nTotQuant := 0
	local nTotTotal := 0
	
	if !aCols[n,_nPosDel]
		if Empty(aCols[n,_nPosProjeto])
			Help(1,"","PRJVAZIO")
			
	        lRet := .F.
	    endif
	endif
	
	for i := 1 to n
		nTotQuant += aCols[n,_nPosQuant]
		nTotTotal += aCols[n,_nPosTotal]
	next
	
	M->ZM_PRJSLDQ := M->ZM_QUANT - nTotQuant
	M->ZM_PRJSLDV := M->ZM_TOTAL - nTotTotal
	_N1 := Val(aCols[n,_nPosItem]) + 1
	
	ValidLegenda()
return lRet

static function ValidLegenda()
	local lRet := .F.
	local lDesv := .F.
	
	lRet := IIf(Empty(aCols[n,_nPosProjeto]),.T.,lRet)
	lRet := IIf(Empty(aCols[n,_nPosQuant]),.T.,lRet)
	lRet := IIf(Empty(aCols[n,_nPosUm]),.T.,lRet)
	lRet := IIf(Empty(aCols[n,_nPosPrcUnit]),.T.,lRet)
	lRet := IIf(Empty(aCols[n,_nPosTotal]),.T.,lRet)
	lRet := IIf(Empty(aCols[n,_nPosVenc]),.T.,lRet)
	
	if CTH->(DbSeek(xFilial("CTH")+aCols[n,_nPosProjeto],.F.))
		if CTH->CTH_ATF22 == "S"
			lDesv := .T.
		endif
	endif
	
	if lDesv
		aCols[n,_nPosBmp] := "003"
	elseif lRet
		aCols[n,_nPosBmp] := "006"
	else
		aCols[n,_nPosBmp] := "002"
	endif
return

user function ATUOC(cOC,cCodigo)
	local aSalvArea := GetArea()
	local nItem := 0
	local lRet := .F.
	
	DbSelectArea("SZN")
	SZN->(DbSetOrder(2))
	
	cQry := "select max(ZN_ITEM) as MAIOR "
	cQry += "from "+RetSqlName("SZM")+" SZM inner join "+RetSqlName("SZN")+" SZN on (ZM_CODIGO = ZN_CODIGO) "
	cQry += "where ZM_OC = '"+cOC+"' and SZM.D_E_L_E_T_ <> '*' and SZN.D_E_L_E_T_ <> '*'"
	
	tcquery cQry alias "TMP1" new
	
	nItem := Val(TMP1->MAIOR)
	
	DbSelectArea("CTH")
	CTH->(DbSetOrder(7))
	CTH->(DbGoTop())
	CTH->(DbSeek(xFilial("CTH")+cOC,.F.))
	
	while !CTH->(Eof()) .and. AllTrim(CTH->CTH_AF) == AllTrim(cOC)
		SZN->(DbGoTop())
		
		if SZN->(DbSeek(xFilial("SZN")+Left(CTH->CTH_CLVL,6),.F.))
			RecLock("SZN",.F.)
//				SZN->ZN_ATF22 := CTH->CTH_ATF22
				SZN->ZN_BMP := IIf(CTH->CTH_ATF22 == "S","003",SZN->ZN_BMP)
			MsUnLock()
			
			lRet := .T.
		else
			nItem++
			
			RecLock("SZN",.T.)
				SZN->ZN_FILIAL	:= xFilial()
				SZN->ZN_CODIGO	:= cCodigo
				SZN->ZN_ITEM	:= StrZero(nItem,2)
				SZN->ZN_PROJETO	:= Left(CTH->CTH_CLVL,6)
				SZN->ZN_QUANT	:= 0
				SZN->ZN_UM		:= "  "
				SZN->ZN_PRCUNIT	:= 0
				SZN->ZN_TOTAL	:= 0
				SZN->ZN_VENCPRJ	:= CToD("")
//				SZN->ZN_ATF22	:= CTH->CTH_ATF22
				SZN->ZN_BMP		:= "006"
				SZN->ZN_PRODUTO	:= "      "
			MsUnLock()
			
			lRet := .T.
		endif
		
		CTH->(DbSkip())
	enddo
	
	TMP1->(DbCloseArea())
	
	if lRet
		MsgInfo("O projeto da ordem de compra "+AllTrim(cOC)+" foram atualizados.")
	else
		MsgInfo("Nao teve alteracao no(s) projeto(s) da ordem de compra "+AllTrim(cOC)+".")
	endif
	
	RestArea(aSalvArea)
return

/*user function CADOCTOTAL()
	local nQuant := M->ZM_QUANT
	local nPrcUnit := M->ZM_PRCUNIT
	local nAlqIcms := M->ZM_ALQICMS
	local nAlqIpi := M->ZM_ALQIPI
	local nAlqPis := M->ZM_ALQPIS
	local nAlqCofins := M->ZM_ALQCOF
	local nAlqIss := M->ZM_ALQISS
	
	nPercImpostos := (100 - (nAlqIcms + nAlqIpi + nAlqPis + nAlqCofins + nAlqIss)) / 100
	nPrcUnitImp := nPrcUnit / nPercImpostos
	
	M->ZM_PUNITIM := nPrcUnitImp
	M->ZM_TOTAL := nQuant * nPrcUnit
	M->ZM_TOTALG := nQuant * nPrcUnitImp
	M->ZM_PRJSLDQ := M->ZM_QUANT - M->ZM_PRJQTD
return*/

user function CONOC(cOC,cCodigo)
	local oButton1, oButton2
	local oGroup1, oGroup2
	local oSay1, oSay2, oSay3, oSay4
	
	private oDlg
	private aWBrowse1, aWBrowse2
	private oWBrowse1, oWBrowse2
	private lWBrowse1, lWBrowse2
	
	oFont := TFont():New("Arial",,15,,.F.)
	oFontN := TFont():New("Arial",,15,,.T.)
	
	define msdialog oDlg title "Consultar" from 000,000 to 335,650 colors 0,16777215 pixel
		@003,004 group oGroup1 to 022,323 of oDlg color 0,16777215 pixel
		
		oSay1 := TSay():New(009,007,{|| "CODIGO"},oDlg,,oFont,,,,.T.,,,,)
		oSay2 := TSay():New(009,034,{|| cCodigo},oDlg,,oFontN,,,,.T.,,,,)
		oSay3 := TSay():New(009,103,{|| "O.C."},oDlg,,oFont,,,,.T.,,,,)
		oSay4 := TSay():New(009,120,{|| cOC},oDlg,,oFontN,,,,.T.,,,,)
		
		@026,004 group oGroup2 to 149,161 prompt " Pre-Nota " of oDlg color 0,16777215 pixel
		
		FWBrowse1(cCodigo)
		
		@026,167 group oGroup3 to 149,323 prompt " Nota Fiscal " of oDlg color 0,16777215 pixel
		
		FWBrowse2(cCodigo)
		
		@153,123 button oButton1 prompt "Visualizar" size 037,012 of oDlg action Visual("PV",aWBrowse1[oWBrowse1:nAt,1]) when lWBrowse1 pixel
		@153,285 button oButton2 prompt "Visualizar" size 037,012 of oDlg action Visual("NF",aWBrowse2[oWBrowse2:nAt,1]+aWBrowse2[oWBrowse2:nAt,2]) when lWBrowse2 pixel
	activate msdialog oDlg centered
return

static function Visual(nOpc,cReg)
	if nOpc == "PV"
		SC5->(MsSeek(xFilial("SC5")+cReg,.F.))
		
		A410Visual("SC5",SC5->(Recno()),2)
	elseif nOpc == "NF"
		SF2->(MsSeek(xFilial("SF2")+cReg,.F.))
		
		Mc090Visual("SF2",SF2->(Recno()),2)
	endif
return

static function FWBrowse1(cCod)
	aWBrowse1 := {}
	
	if Select("TMP") <> 0
		TMP->(DbCloseArea())
	endif
	
	cQry := "select C5_NUM, C5_PROJETO "
	cQry += "from "+RetSqlName("SC5")+" "
	cQry += "where C5_FOLROST = '"+cCod+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by C5_NUM"
	
	tcquery cQry new alias "TMP"
	
	DbSelectArea("TMP")
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		AAdd(aWBrowse1,{TMP->C5_NUM,TMP->C5_PROJETO})
		
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	
	if Len(aWBrowse1) <= 0
		AAdd(aWBrowse1,{"",""})
		
		lWBrowse1 := .F.
	endif
	
	@034,008 listbox oWBrowse1 fields header "PRE-NOTA","PROJETO" size 149,112 of oDlg pixel /*colsizes 50,30*/
		oWBrowse1:SetArray(aWBrowse1)
		oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,1],aWBrowse1[oWBrowse1:nAt,2]}}
		oWBrowse1:Refresh()
return

static function FWBrowse2(cCod)
	aWBrowse2 := {}
	
	if Select("TMP") <> 0
		TMP->(DbCloseArea())
	endif
	
	cQry := "select C6_NFORI, C6_SERIORI, C5_TIPO "
	cQry += "from "+RetSqlName("SC5")+" SC5 inner join "+RetSqlName("SC6")+" SC6 on (C5_NUM = C6_NUM) "
	cQry += "where C5_FOLROST = '"+cCod+"' and SC5.D_E_L_E_T_ <> '*' and SC6.D_E_L_E_T_ <> '*' "
	cQry += "order by C6_NFORI"
	
	tcquery cQry new alias "TMP"
	
	DbSelectArea("TMP")
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if !Empty(TMP->C6_NFORI)
			AAdd(aWBrowse2,{TMP->C6_NFORI,TMP->C6_SERIORI,TMP->C5_TIPO})
		endif
		
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	
	if Len(aWBrowse2) <= 0
		AAdd(aWBrowse2,{"","",""})
		
		lWBrowse2 := .F.
	endif
	
	@034,170 listbox oWBrowse2 fields header "NOTA","SERIE","TIPO" size 149,112 of oDlg pixel /*colsizes 50,30*/
		oWBrowse2:SetArray(aWBrowse2)
		oWBrowse2:bLine := {|| {aWBrowse2[oWBrowse2:nAt,1],aWBrowse2[oWBrowse2:nAt,2],aWBrowse2[oWBrowse2:nAt,3]}}
		oWBrowse2:Refresh()
return

user function VALOC(cOC,cCodigo)
	private aOrd    := {"Validar OC"}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg   := ""
	private Cabec1  := "                                                                                                              CTH        SZN"
	private Cabec2  := "PROJETO DESCRICAO                                                                                          BLOQ DESV  EXCL DESV  INT"
	private cDesc1  := "VALIDAR PROJETOS DA O.C."
	private ContFun := 0
	private cString := "SZN"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := FunName()
	private lAborta := .T.
	
	private nLin	:= 014
	private cQry 	:= ""
	private nRdpPag	:= 1
	private nInd	:= 0
	private cRdpLeg	:= ""
	private cCbcRef	:= ""
	private cCbcNum	:= ""
	private cEmpresa := SubStr(cNumEmp,1,2)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	Processa({|| Impr(cOC,cCodigo)},"","Aguarde processando...",lAborta)
	
	set device to screen
	
	if aReturn[5] == 1
		set printer to
		
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return

static function Impr(cOC,cCodigo)
	local aProjeto := {}
	local aSalvArea := GetArea()
	
	//Tabela de projetos (CTH)
	cQry := "select * "
	cQry += "from "+RetSqlName("CTH")+" "
	cQry += "where CTH_AF = '"+cOC+"' and D_E_L_E_T_ <> '*' "
	cQry += "order by CTH_CLVL"
	
	tcquery cQry new alias "TMP"
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		AAdd(aProjeto,{Left(TMP->CTH_CLVL,6),TMP->CTH_DESC01,IIf(TMP->CTH_BLOQ == "1","SIM","NAO"),IIf(TMP->CTH_ATF22 == "S","SIM","NAO")," "," "," "})
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	
	//Tabela de ordem de compra (SZN)
	cQry := "select SZN.* "
	cQry += "from "+RetSqlName("SZN")+" SZN inner join "+RetSqlName("SZM")+" SZM on (ZN_CODIGO = ZM_CODIGO) "
	cQry += "where ZM_OC = '"+cOC+"' and SZN.D_E_L_E_T_ <> '*' and SZM.D_E_L_E_T_ <> '*' "
	cQry += "order by ZN_PROJETO"
	
	tcquery cQry new alias "TMP"
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if (nInd := AScan(aProjeto,{|x| x[1] = TMP->ZN_PROJETO})) == 0
			AAdd(aProjeto,{TMP->ZN_PROJETO,IIf(CTH->(DbSeek(xFilial("CTH")+TMP->PROJETO,.F.)),CTH->CTH_DESC01,"")," "," ",IIf(TMP->ZN_ATF22 == "S","SIM","NAO"),IIf(TMP->ZN_ATF22 == "S","SIM","NAO")," "})
		else
			aProjeto[nInd][5] := IIf(TMP->ZN_ATF22 == "S","SIM","NAO")
			aProjeto[nInd][6] := IIf(TMP->ZN_ATF22 == "S","SIM","NAO")
		endif
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	
	//Tabela intermediária (ATFPRO)
	cQry := "select * "
	cQry += "from [DADOSATF].dbo.ATFPRO "
	cQry += "where proj_cli = '"+cOC+"' "
	cQry += "order by numero"
	
	tcquery cQry new alias "TMP"
	
	DbSelectArea("TMP")
	ProcRegua(TMP->(RecCount()))
	TMP->(DbGoTop())
	
	while !TMP->(Eof())
		if (nInd := AScan(aProjeto,{|x| x[1] = TMP->numero})) == 0
			AAdd(aProjeto,{TMP->numero,TMP->descricao," "," "," "," "," "})
		else
			aProjeto[nInd][7] := "X"
		endif
		
		IncProc()
		TMP->(DbSkip())
	enddo
	
	TMP->(DbCloseArea())
	ProcRegua(Len(aProjeto))
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	nLin++
	nCont := 0 ; nInt := 0 ; nCth := 0 ; nSzn := 0
	
	for i := 1 to Len(aProjeto)
//		                                                                                                              CTH        SZN
//		PROJETO DESCRICAO                                                                                          BLOQ DESV  EXCL DESV  INT
//		999999  AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA          AAA AAA    AAA AAA     X
//		999 Registro(s)                                                                                               999        999     999
//		012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//		          1         2         3         4         5         6         7         8         9        10        11        12        13
		
		@nLin,000 psay aProjeto[i][1]
		@nLin,008 psay Left(aProjeto[i][2],90)
		@nLin,108 psay aProjeto[i][3]
		@nLin,112 psay aProjeto[i][4]
		@nLin,119 psay aProjeto[i][5]
		@nLin,123 psay aProjeto[i][6]
		@nLin,131 psay aProjeto[i][7]
		
		nLin++
		nCont++
		nInt += IIf(Empty(aProjeto[i][7]),0,1)
		nCth += IIf(Empty(aProjeto[i][4]),0,1)
		nSzn += IIf(Empty(aProjeto[i][6]),0,1)
		
		U_SaltaFolha()
	next
	
	nLin++
	
	U_SaltaFolha()
	
	@nLin,000 psay AllTrim(Transf(nCont,"@R 999"))
	@nLin,004 psay "Registro(s)"
	@nLin,110 psay Transf(nInt,"@R 999")
	@nLin,121 psay Transf(nCth,"@R 999")
	@nLin,129 psay Transf(nSzn,"@R 999")
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
	RestArea(aSalvArea)
return

static function LegendaSZN()
	static oDlg
	static oBitmap1
	static oBitmap2
	static oBitmap3
	static oGroup1
	static oSay1
	static oSay2
	static oSay3
	static oSay4
	
	define msdialog oDlg title "LEGENDA" from 000,000 to 100,390 colors 0,16777215 pixel
		@015,004 bitmap oBitmap1 size 010,009 of oDlg filename "002.png" noborder pixel
		@026,004 bitmap oBitmap2 size 010,009 of oDlg filename "006.png" noborder pixel
		@038,004 bitmap oBitmap3 size 010,009 of oDlg filename "003.png" noborder pixel
		@002,003 say oSay1 prompt "Legenda" size 025,007 of oDlg colors 0,16777215 pixel
		@011,003 group oGroup1 to 013,191 of oDlg color 0,16777215 pixel
		@016,016 say oSay2 prompt "Projeto liberado" size 170,007 of oDlg colors 0,16777215 pixel
		@027,016 say oSay3 prompt "Projeto incompleto" size 170,007 of oDlg colors 0,16777215 pixel
		@039,016 say oSay4 prompt "Projeto desvinculado" size 170,007 of oDlg colors 0,16777215 pixel
	activate msdialog oDlg centered
return