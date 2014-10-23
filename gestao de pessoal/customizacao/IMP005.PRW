/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar dependentes do MFOLHA                        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function IMP005()
	local oDlg, oFont
	
	private aAreaAnt := GetArea()
	
	define font oFont name "Arial" size 000,-12
	define msdialog oDlg title "IMPORTACAO MFOLHA" from 000,000 to 250,500 pixel
		@005,010 to 100,242 pixel
		@010,015 say "Esta rotina tem como objetivo importar o(s) dependente(s) do(s) funcionario(s)" pixel font oFont of oDlg
		@020,015 say "cadastrado no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
		@105,147 bmpbutton type 05 action Pergunte("MFUNC",.T.)
		@105,179 bmpbutton type 01 action ImportarDepend(oDlg)
		@105,211 bmpbutton type 02 action Close(oDlg)
	activate msdialog oDlg centered
return

static function ImportarDepend(oDlg)
	local cMatIni := ""
	local cMatFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Matricula de                                      ³
	//³ mv_par02 - Matricula ate                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Empty(mv_par01) .and. Empty(mv_par02)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cMatIni := mv_par01
	cMatFin := mv_par02
	
	Processa({|| U_IncDependente(cMatIni,cMatFin,.T.)},"","Aguarde processando...",.T.)
	RestArea(aAreaAnt)
return

user function IncDependente(cMatIni,cMatFin,lMsg)
	local cTblDEP := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\FILHO016.DBF","\DADOS1\FILHO003.DBF")
	local cIndDEP := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\FILHO016.IDX","\DADOS1\FILHO003.IDX")
	
	private lMsErroAuto := .F.
	
//	set century on
	
	DbUseArea(.T.,"DBFCDX",cTblDEP,"DEP",.T.,.F.)
	DbSetIndex(cIndDEP)
	
	DbSelectArea("SRA")
	ProcRegua(SRA->(LastRec()))
	SRA->(DbGoTop())
	SRA->(DbSeek(xFilial("SRA")+cMatIni,.T.))
	
	while !SRA->(Eof()) .and. SRA->RA_MAT >= cMatIni .and. SRA->RA_MAT <= cMatFin
		aCabec := {}
		aItens := {}
		aDtEntrada := {}
		
		DEP->(DbGoTop())
		
		if DEP->(DbSeek(SRA->RA_MAT,.F.))
			AAdd(aCabec,{"RA_FILIAL",xFilial("SRA"),nil})
			AAdd(aCabec,{"RA_MAT",DEP->FUNCC,nil})
			
			nItem := 1
			
			while !DEP->(Eof()) .and. DEP->FUNCC == SRA->RA_MAT
				aLinha := {}
				cCodigo := StrZero(nItem,2)
				cCpf := StrTran(StrTran(AllTrim(DEP->CPF_DEPEND),".",""),"-","")
				
				do case
					case DEP->TIPO == "1"
						cGrauPar := "F"
					case DEP->TIPO == "2"
						cGrauPar := "E"
					case DEP->TIPO == "3"
						cGrauPar := "C"
					otherwise
						cGrauPar := "O"
				endcase
				
				do case
					case DEP->DEP_IRRF == "S"
						cTipoIr := "1"
					case DEP->DEP_IRRF == "N"
						cTipoIr := "4"
					otherwise
						if cGrauPar == "E"
							cTipoIr := "3"
						else
							cTipoIr := "2"
						endif
				endcase
				
				if DEP->AB_FAMILIA == "1"
					cSalFamil := "3"
				else
					if Empty(DEP->BAIXA)
						cSalFamil := "1"
					else
						cSalFamil := "2"
					endif
				endif
				
				if DEP->ENTR_CERTD < SRA->RA_ADMISSA
					dEntrada := SRA->RA_ADMISSA
				else
					if DEP->ENTR_CERTD < DEP->DATA_NASC
						dEntrada := IIf(DEP->ENTR_CERTD == SRA->RA_ADMISSA,Date(),SRA->RA_ADMISSA)
					else
						dEntrada := DEP->ENTR_CERTD
					endif
				endif
				
				if DEP->BAIXA < dEntrada
					AAdd(aDtEntrada,{DEP->FUNCC,cCodigo,dEntrada})
					
					dEntrada := CToD("")
				endif
				
				aLinha := {{"RB_FILIAL",xFilial("SRB"),nil},;
							{"RB_MAT",DEP->FUNCC,nil},;
							{"RB_COD",cCodigo,nil},;
							{"RB_NOME",DEP->NOME_DEP,nil},;
							{"RB_DTNASC",DEP->DATA_NASC,nil},;
							{"RB_SEXO",DEP->SEXO,nil},;
							{"RB_TIPIR",cTipoIr,nil},;
							{"RB_GRAUPAR",cGrauPar,nil},;
							{"RB_TIPSF",cSalFamil,nil},;
							{"RB_LOCNASC",DEP->LOCAL_NASC,nil},;
							{"RB_CARTORI",DEP->CARTORIO,nil},;
							{"RB_NREGCAR",Left(DEP->REGISTRO,6),nil},;
							{"RB_NUMLIVR",DEP->LIVRO,nil},;
							{"RB_NUMFOLH",DEP->FOLHA,nil},;
							{"RB_DTENTRA",dEntrada,nil},;
							{"RB_DTBAIXA",DEP->BAIXA,nil},;
							{"RB_CIC",cCpf,nil}}
				
				AAdd(aItens,aLinha)
				
				nItem++
				DEP->(DbSkip())
			enddo
			
			MSExecAuto({|x,y,k,w,z| GPEA020(x,y,k,w,z)},nil,aCabec,aItens,3)
			
			if lMsErroAuto
				MostraErro()
				
				lMsErroAuto := .F.
			endif
			
			if !Empty(aDtEntrada)
				for i := 1 to Len(aDtEntrada)
					cQry := "update "+RetSqlName("SRB")+" set RB_DTENTRA = '"+DToS(aDtEntrada[i][3])+"' where RB_MAT = '"+aDtEntrada[i][1]+"' and RB_COD = '"+aDtEntrada[i][2]+"' and D_E_L_E_T_ <> '*'"
					
					TCSqlExec(cQry)
				next i
			endif
		endif
		
		IncProc()
		SRA->(DbSkip())
	enddo
	
	if lMsg
		MsgInfo("Dependente(s) importado com sucesso!")
	endif
	
	DEP->(DbCloseArea())
return 