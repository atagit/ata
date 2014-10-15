/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/10/14 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar funcionários do MFOLHA                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function IMP003()
	local oDlg, oFont
	
	private aAreaAnt := GetArea()
	
	define font oFont name "Arial" size 000,-12
	define msdialog oDlg title "IMPORTACAO MFOLHA" from 000,000 to 250,500 pixel
		@005,010 to 100,242 pixel
		@010,015 say "Esta rotina tem como objetivo importar o(s) funcionario(s) cadastrado" pixel font oFont of oDlg
		@020,015 say "no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
		@105,147 bmpbutton type 05 action Pergunte("MFUNC",.T.)
		@105,179 bmpbutton type 01 action Processa({|| ImportarFunc(oDlg)},"","Aguarde processando...",.T.)
		@105,211 bmpbutton type 02 action Close(oDlg)
	activate msdialog oDlg centered
return

static function ImportarFunc(oDlg)
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
	
	Processa({|| IncluirFunc(cMatIni,cMatFin)},"","Aguarde processando...",.T.)
	
	RestArea(aAreaAnt)
return

static function IncluirFunc(cMatIni,cMatFin)
	local cTblFUN := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\FUNCS016.DBF","\DADOS1\FUNCS003.DBF")
	local cIndFUN := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\FUNCS016.IDX","\DADOS1\FUNCS003.IDX")
	local cTblSAL := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\SALAR016.DBF","\DADOS1\SALAR003.DBF")
	local cIndSAL := "\\ATFSRV001\mastermaq$\MFOLHA"+IIf(cEmpAnt == "02","\DADOS4\SALAR016.IDX","\DADOS1\SALAR003.IDX")
	local cTblBCO := "\\ATFSRV001\mastermaq$\MFOLHA\BANCO.DBF"
	local cIndBCO := "\\ATFSRV001\mastermaq$\MFOLHA\BANCO.IDX"
	
	local lError := .T.
	local nContReg := 0
	local cMat := ""
	local cCpf := ""
	local cHabilitacao := ""
	local cTitEleitor := ""
	local cCodFuncao := ""
	local cDesFuncao := ""
	local cBcoSal := ""
	local cCtaSal := ""
	local cBcoFgts := ""
	local cCtaFgts := ""
	local nSalario := 0
	local cEstCivil := ""
	local cTipoAdm := ""
	local cInstrucao := ""
	local cCodDepto := ""
	local cDesDepto := ""
	
	private lMsErroAuto := .F.
	
	DbUseArea(.T.,"DBFCDX",cTblFUN,"FUN",.T.,.F.)
	DbSetIndex(cIndFUN)
	DbUseArea(.T.,"DBFCDX",cTblSAL,"SAL",.T.,.F.)
	DbSetIndex(cIndSAL)
	DbUseArea(.T.,"DBFCDX",cTblBCO,"BCO",.T.,.F.)
	DbSetIndex(cIndBCO)
	
	FUN->(DbGoTop())
	FUN->(DbSeek(cMatIni,.F.))
	
	while !FUN->(Eof()) .and. FUN->FUNCC >= cMatIni .and. FUN->FUNCC <= cMatFin
		nContReg++
		
		FUN->(DbSkip())
	enddo
	
	DbSelectArea("SRA")
	SRA->(DbSetOrder(27))
	
	ProcRegua(nContReg)
	
	FUN->(DbGoTop())
	FUN->(DbSeek(cMatIni,.F.))
	
	while !FUN->(Eof()) .and. FUN->FUNCC >= cMatIni .and. FUN->FUNCC <= cMatFin
		if !Empty(FUN->RESCISAO) ; FUN->(DbSkip()) ; loop ; endif
		
		SRA->(DbGoTop())
		
		if !SRA->(DbSeek(xFilial("SRA")+FUN->FUNCC,.F.))
			aAliasAnt1 := GetArea()
			
			cCodFuncao := U_IncluirFuncao(FUN->FUNCAO,FUN->FUNCAO,.F.)
			cCodDepto := U_IncluirDepto(FUN->DEPTO,FUN->DEPTO,.F.)
			
			RestArea(aAliasAnt1)
			SRJ->(DbGoTop())
			
			if SRJ->(DbSeek(xFilial("SRJ")+cCodFuncao,.F.))
				cCodFuncao := SRJ->RJ_FUNCAO
				cDesFuncao := SRJ->RJ_DESC
			endif
			
			SQB->(DbGoTop())
			
			if SQB->(DbSeek(xFilial("SQB")+cCodDepto,.F.))
				cCodDepto := SQB->QB_DEPTO
				cDesDepto := SQB->QB_DESCRIC
			endif
			
			SRJ->(DbSetOrder(1))
			SQB->(DbSetOrder(1))
			SAL->(DbGoTop())
			
			if SAL->(DbSeek(FUN->FUNCC,.F.))
				cDataSal := SAL->DATA
				nSalario := SAL->VALOR
				
				while !SAL->(Eof()) .and. SAL->FUNCC >= FUN->FUNCC .and. SAL->FUNCC <= FUN->FUNCC
					if SAL->DATA >= cDataSal
						cDataSal := SAL->DATA
						nSalario := SAL->VALOR
					endif
					
					SAL->(DbSkip())
				enddo
			endif
			
			cMat := StrZero(Val(FUN->FUNCC),6)
			cCpf := StrTran(StrTran(AllTrim(FUN->CPF),".",""),"-","")
			cHabilitacao := StrTran(AllTrim(FUN->CARTHABIL),"-","")
			cTitEleitor := StrTran(AllTrim(FUN->TITELEIT),"-","")
			
			do case
				case FUN->TIPO_ADM == "01"
					cTipoAdm := "9A"
				case FUN->TIPO_ADM == "02"
					cTipoAdm := "9B"
				otherwise
					cTipoAdm := "9B"
			endcase
			
			do case
				case FUN->EST_CIVIL == "1"
					cEstCivil := "C"
				case FUN->EST_CIVIL == "2"
					cEstCivil := "S"
				case FUN->EST_CIVIL == "3"
					cEstCivil := "V"
				case FUN->EST_CIVIL == "4"
					cEstCivil := "Q"
				case FUN->EST_CIVIL == "5"
					cEstCivil := "D"
				otherwise
					cEstCivil := "M"
			endcase
			
			do case
				case FUN->INSTRUCAO == "01"
					cInstrucao := "10"
				case FUN->INSTRUCAO == "02"
					cInstrucao := "20"
				case FUN->INSTRUCAO == "03"
					cInstrucao := "25"
				case FUN->INSTRUCAO == "04"
					cInstrucao := "30"
				case FUN->INSTRUCAO == "05"
					cInstrucao := "35"
				case FUN->INSTRUCAO == "06"
					cInstrucao := "40"
				case FUN->INSTRUCAO == "07"
					cInstrucao := "45"
				case FUN->INSTRUCAO == "08"
					cInstrucao := "50"
				case FUN->INSTRUCAO == "09"
					cInstrucao := "55"
				case FUN->INSTRUCAO == "10"
					cInstrucao := "85"
				case FUN->INSTRUCAO == "11"
					cInstrucao := "65"
				case FUN->INSTRUCAO == "12"
					cInstrucao := "75"
				case FUN->INSTRUCAO == "13"
					cInstrucao := "95"
				otherwise
					cInstrucao := ""
			endcase
			
			do case
				case FUN->FUNC_SOCIO == "2"
					cCatFunc := "P"
				case FUN->FUNC_SOCIO == "3"
					cCatFunc := "E"
				otherwise
					cCatFunc := "H"
			endcase
			
			cBcoSal := "" ; cCtaSal := ""
			
/*			if !Empty(FUN->CONTA)
				BCO->(DbGoTop())
				
				if BCO->(Dbseek(FUN->BANCO,.F.))
					cBcoSal := BCO->COD_BANCO+FormatAgenc(BCO->COD_AGENC)
				endif
				
				cCtaSal := StrZero(Val(AllTrim(FUN->CONTA)),12)
			endif*/
			
			if !EMpty(FUN->CTA_FGTS)
				BCO->(DbGoTop())
				
				if BCO->(Dbseek(FUN->BCO_FGTS,.F.))
					cBcoSal := BCO->COD_BANCO+FormatAgenc(BCO->COD_AGENC)
				endif
				
				cCtaFgts := StrZero(AllTrim(FUN->CTA_FGTS),12)
			else
				cBcoFgts := "CX100001"
				cCtaFgts := "000000000000"
			endif
			
			aVetor := {{"RA_FILIAL",xFilial("SRA"),nil},;
						{"RA_MAT",cMat,nil},;
						{"RA_NOME",FUN->NOME,nil},;
						{"RA_ENDEREC",FUN->ENDERECO,nil},;
						{"RA_BAIRRO",FUN->BAIRRO,nil},;
						{"RA_MUNICIP",IIf(Right(AllTrim(FUN->CIDADE),10) == "FABRICIANO","CORONEL FABRICIANO",AllTrim(FUN->CIDADE)),nil},;
						{"RA_ESTADO",FUN->UF,nil},;
						{"RA_CEP",FUN->CEP,nil},;
						{"RA_TELEFON",FUN->TELEFONE,nil},;
						{"RA_PAI",FUN->PAI,nil},;
						{"RA_MAE",FUN->MAE,nil},;
						{"RA_SEXO",IIf(FUN->SEXO == "1","M","F"),nil},;
						{"RA_NASC",FUN->NASCIMENTO,nil},;
						{"RA_CIC",cCpf,nil},;
						{"RA_PIS",FUN->PIS,nil},;
						{"RA_RG",FUN->CI,nil},;
						{"RA_NUMCP",IIf(Empty(FUN->CARTEIRA),'0000000',FUN->CARTEIRA),nil},;
						{"RA_SERCP",IIf(Empty(FUN->SERIE),'00000',FUN->SERIE),nil},;
						{"RA_UFCP",FUN->UF_CP,nil},;
						{"RA_HABILIT",cHabilitacao,nil},;
						{"RA_TITULOE",cTitEleitor,nil},;
						{"RA_ZONASEC",FUN->ZONA+"/"+FUN->SECAOELE,nil},;
						{"RA_REGISTR",StrZero(Val(FUN->REGISTRO),6),nil},;
						{"RA_NOMECMP",FUN->NOME_COMPL,nil},;
						{"RA_NATURAL",FUN->UF_NATURAL,nil},;
						{"RA_ADMISSA",FUN->ADMISSAO,nil},;
						{"RA_HRSMES",FUN->HORAS_MES,nil},;
						{"RA_HRSEMAN",FUN->HORAS_SEM,nil},;
						{"RA_CODFUNC",cCodFuncao,nil},;
						{"RA_DESCFUN",cDesFuncao,nil},;
						{"RA_BCDEPSA",cBcoSal,nil},;
						{"RA_CTDEPSA",cCtaSal,nil},;
						{"RA_BCDPFGT",cBcoFgts,nil},;
						{"RA_CTDPFGT",cCtaFgts,nil},;
						{"RA_SALARIO",nSalario,nil},;
						{"RA_CRACHA",Left(cMat,6),nil},;
						{"RA_CHAPA",Right(cMat,5),nil},;
						{"RA_OPCAO",FUN->ADMISSAO,nil},;
						{"RA_NACIONA",IIf(FUN->NACIONAL == "10","10",FUN->NACIONAL),nil},;
						{"RA_ESTCIVI",cEstCivil,nil},;
						{"RA_TIPOADM",cTipoAdm,nil},;
						{"RA_GRINRAI",cInstrucao,nil},;
						{"RA_DEPTO",cCodDepto,nil},;
						{"RA_DDEPTO",cDesDepto,nil},;
						{"RA_TNOTRAB","001",nil},;
						{"RA_ADTPOSE","***N**",nil},;
						{"RA_CATFUNC",cCatFunc,nil},;
						{"RA_TIPOPGT","M",nil},;
						{"RA_TPMAIL","1",nil},;
						{"RA_MSBLQL","2",nil},;
						{"RA_PGCTSIN","P",nil},;
						{"RA_SINDICA","01",nil},;
						{"RA_DEFIFIS","2",nil},;
						{"RA_VIEMRAI","10",nil},;
						{"RA_TPDEFFI","0",nil},;
						{"RA_HOPARC","2",nil},;
						{"RA_COMPSAB","2",nil}}
			
			MsExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},nil,nil,aVetor,IIf(SRA->(DbSeek(xFilial("SRA")+FUN->FUNCC,.F.)),4,3))
			
			if lMsErroAuto
				MostraErro()
				
				lMsErroAuto := .F.
			endif
		endif
		
		cMat := "" ; cCpf := "" ; cHabilitacao := "" ; cTitEleitor := "" ; cCodFuncao := "" ; cDesFuncao := "" ; cBcoSal := "" ; cCtaSal := ""
		cBcoFgts := "" ; cCtaFgts := "" ; nSalario := 0 ; cEstCivil := "" ; cTipoAdm := "" ; cInstrucao := "" ; cCodDepto := ""
		
		IncProc()
		FUN->(DbSkip())
	enddo

	MsgInfo("Dados importado com sucesso! E necessario que atualizar alguns dados desse(s) funcionario(s).")
	
	BCO->(DbCloseArea())
	SAL->(DbCloseArea())
	FUN->(DbCloseArea())
return

static function FormatAgenc(cAgenc)
	local lParar := .F.
	local nCont := 1
	local cRet := ""
	
	while !lParar .and. nCont <= 5
		if SubStr(cAgenc,nCont,1) <> "-"
			cRet += SubStr(cAgenc,nCont,1)
		else
			lParar := .T.
		endif
		
		nCont++
	enddo
	
	cRet := IIf(Empty(cRet),"0",cRet)
return StrZero(Val(AllTrim(cRet)),4)