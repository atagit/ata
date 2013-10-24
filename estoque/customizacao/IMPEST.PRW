/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 05/03/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar arquivo TXT gerado pelo SIGMANEST            ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"
#include "fileio.ch"

#define _EOL Chr(13)+Chr(10)
#define _EXT ".TXT"
#define _PRJINT "000000000"

user function IMPEST()
	local oDlg, oFont
	
	define font oFont name "Arial" size 000,-12
	
	define msdialog oDlg title "IMPORTACAO SIGMANEST" from 000,000 to 250,500 pixel
		@005,010 to 100,242 pixel
		@010,015 say "Esta rotina tem como objetivo importar os arquivos .txt gerado pelo programa" pixel font oFont of oDlg
		@020,015 say "Sigmanest, efetuando a baixa de produto dos mesmo." pixel font oFont of oDlg
		@105,147 bmpbutton type 05 action Pergunte("IMPTXT",.T.)
		@105,179 bmpbutton type 01 action Importar(oDlg)
		@105,211 bmpbutton type 02 action Close(oDlg)
	activate msdialog oDlg centered
return

static function Importar(oDlg)
	local aEstSigma := {}
	local aArqProj := {}
	local aSigmaProj := {}
	local cLine := ""
	local lImport := .F.
	local lExiste := .F.
	local lAborta := .T.
	local cDrive, cDir, cNome, cExt
	
	private cArqBkp := ""
	private cArq := ""
	
	private cDtIni := ""
	private cDiretorio := ""
	private cProjIni := ""
	private cProjFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Diretorio                                         ³
	//³ mv_par02 - Projeto de                                        ³
	//³ mv_par03 - Projeto ate                                       ³
	//³ mv_par04 - Data inicial                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
//	Pergunte("IMPTXT",.T.)
	
	if Empty(mv_par01) .and. Empty(mv_par02) .and. Empty(mv_par03) .and. Empty(mv_par04)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cDiretorio := If(Right(AllTrim(mv_par01),1) == "\",AllTrim(mv_par01),AllTrim(mv_par01)+"\")
	cProjIni := AllTrim(mv_par02)
	cProjFin := AllTrim(mv_par03)
	cDtIni := DToS(mv_par04)
	
	DbSelectArea("CTH")
	CTH->(DbSeek(xFilial("CTH")+cProjIni,.F.))
	
	while CTH->CTH_CLVL >= cProjIni .and. CTH->CTH_CLVL <= cProjFin
		aEstSigma := {}
		
		if CTH->CTH_CLVL == _PRJINT .and. cEmpAnt == "01"
			cArq := cDiretorio+"ATA"+_EXT
		elseif CTH->CTH_CLVL == _PRJINT .and. cEmpAnt == "02"
			cArq := cDiretorio+"ATF"+_EXT
		else
			cArq := cDiretorio+AllTrim(CTH->CTH_CLVL)+_EXT
		endif
		
		if !File(cArq)
			AAdd(aArqProj,{cArq})
			
			CTH->(DbSkip())
			
			loop
		endif
		
		nHandle := FT_FUse(AllTrim(cArq)) //abre o arquivo
		
		//se houver erro de abertura do arquivo abandona processamento
		if nHandle == -1
			MsgStop("Erro de abertura do arquivo "+AllTrim(cArq)+": FERROR "+Str(FError(),4))
			
			break
		endif
		
		SplitPath(cArq,@cDrive,@cDir,@cNome,@cExt)
		
		cArqBkp := cDrive+cDir+"BKP"+Upper(cNome)+Upper(cExt)
		
		if !File(cArqBkp)
			nDestino := FCreate(cArqBkp,FC_NORMAL) //cria o arquivo de backup
		else
			nDestino := FOpen(cArqBkp,FO_WRITE+FO_SHARED) //abre o arquivo de backup
		endif
		
		//se houver erro de abertura do arquivo de backup abandona processamento
		if nDestino == -1
			MsgStop("Erro de abertura do arquivo de backup "+AllTrim(cArqBkp)+": FERROR "+Str(FError(),4))
			
			break
		endif
		
		FT_FGoTop() //posiciona na primeria linha
		
		nLast := FT_FLastRec() //retorna o número de linhas do arquivo
		
		while !FT_FEof()
			cLine := FT_FReadLn() //retorna a linha corrente
			nRecno := FT_FRecno() //retorna o recno da Linha
			
//			aRet := StrTokArr(cLine,";") //arquivo serparado por ";"
			
//			cProd := aRet[1]
//			cLimite := aRet[7]
			
			cProd := SubStr(cLine,4,6)
			cLimite := Right(cLine,1)
			
			if AllTrim(cProd) <> "" .and. cLimite <> "*"
//				cProj := aRet[2]
//				cProt := aRet[3]
//				cData := DToS(Date(aRet[4]))
//				nQtde := Val(aRet[5])
//				nPeso := Val(StrTran(aRet[6],",",".",0,1))
				
				cProj := AllTrim(SubStr(cLine,13,6))
				cProt := AllTrim(SubStr(cLine,25,7))
//				cProg := AllTrim(SubStr(cLine,38,11))
				cProg := SubStr(cLine,38,12)
				cData := DToS(CToD(AllTrim(SubStr(cLine,50,10))))
				nQtde := Val(AllTrim(SubStr(cLine,71,10)))
				nPeso := Val(StrTran(SubStr(cLine,88,Len(cLine)),",",".",0,1))
				
				if cProj $ "ATA/ATF"
					cProj := _PRJINT
				endif
				
				if cData >= cDtIni
					if (nInd := AScan(aEstSigma,{|x| x[1] = cProd .and. x[2] = cProj .and. x[3] = cData .and. x[6] = cProg})) == 0
						AAdd(aEstSigma,{cProd,cProj,cData,cProt,nQtde * nPeso,cProg})
					else
						aEstSigma[nInd][5] += nQtde * nPeso
					endif
					
//					aSigmaProj := aEstSigma
					
/*					if (nInd := AScan(aSigmaProj,{|x| x[1] = cProd .and. x[2] = cProj .and. x[3] = cData})) == 0
						AAdd(aSigmaProj,{cProd,cProj,cData,cProt,nQtde * nPeso})
					else
						aSigmaProj[nInd][5] += nQtde * nPeso
					endif*/
					
					lImport := .T.
				endif
			endif
			
			GravaBkpTXT(cLine,cLimite)
			
			FT_FSkip() //pula para próxima linha
		enddo
		
		FT_FUse() //fecha o arquivo
		FClose(nDestino) //fecha o arquivo de backup
		FErase(cArq) //apaga o arquivo original
		FRename(cArqBkp,cArq) //renomeia o arquivo de backup para o original
		
		if lImport
			if Len(aEstSigma) > 0
				Processa({|| GravaSD3(aEstSigma,CTH->CTH_CLVL)},"","Aguarde processando...",lAborta)
			endif
		else
			MsgBox("Apartir dessa data inicial nao foram feitas baixa para o projeto "+AllTrim(CTH->CTH_CLVL)+".","Aviso","INFO")
		endif
		
		CTH->(DbSkip())
	enddo
	
	if ApMsgYesNo("Deseja visualizar o relatorio de importacao?","Relatorio de Importacao")
//		RelLog(aSigmaProj,aArqProj)
		RelLog(aEstSigma,aArqProj)
	endif
	
	Close(oDlg)
return

static function GravaSD3(aEstSigma,cPro)
	local lError := .F.
	local cProjetos := ""
	
	private lMsErroAuto := .F.
	
	ProcRegua(Len(aEstSigma))
	
	for i := 1 to Len(aEstSigma)
		IncProc()
		
//		DbSelectArea("SD3")
		
		_cProg := SubStr(aEstSigma[i][6],1,12)
		_cData := aEstSigma[i][3]
		_cProd := SubStr(aEstSigma[i][1]+Space(15 - Len(aEstSigma[i][1])),1,15)
		_cProj := SubStr(aEstSigma[i][2]+Space(9 - Len(aEstSigma[i][2])),1,9)
		_cProt := SubStr(aEstSigma[i][4]+Space(7 - Len(aEstSigma[i][4])),1,7)
		_cQtde := Str(aEstSigma[i][5],12,2)
		
		SD3->(DbSetOrder(12))
		if !(SD3->(DbSeek(xFilial("SD3")+_cProg+_cData+_cProd+_cProj+_cProt+_cQtde,.F.)))
			if !(aEstSigma[i][2] $ cProjetos)
				cProjetos += aEstSigma[i][2]+", "
			endif
			
			aVetor := {{"D3_TM","501",nil},;
						{"D3_COD",aEstSigma[i][1],nil},;
						{"D3_QUANT",aEstSigma[i][5],nil},;
						{"D3_CLVL",aEstSigma[i][2],nil},;
						{"D3_CR",aEstSigma[i][4],nil},;
						{"D3_EMISSAO",SToD(aEstSigma[i][3]),nil},;
						{"D3_DOC","IMPSIGMA",nil},;
						{"D3_PROGRSN",aEstSigma[i][6],nil}}
			
			MsExecAuto({|x,y| MATA240(x,y)},aVetor,3)
			
			if lMsErroAuto
				MostraErro()
				
				lError := .T.
				lMsErroAuto := .F.
			endif
		endif
	next
	
	if !lError
		cProjetos := Left(cProjetos,Len(cProjetos) - 2)
		
		MsgBox("Importacao com sucesso do projeto "+AllTrim(cProjetos)+"!","Alerta","ALERT")
	else
		MsgBox("Alguns registros nao foram importados, conforme tela de error apresentada anteriormente.","Alert","ALERT")
	endif
return

static function GravaBkpTXT(cLine,cLimite)
	FSeek(nDestino,0,FS_END)
	
	if cLimite <> "*"
//		FWrite(nDestino,cLine+";*"+_EOL,Len(cLine+";*"+_EOL))
		FWrite(nDestino,cLine+"*"+_EOL,Len(cLine+"*"+_EOL))
	else
//		FWrite(nDestino,cLine+_EOL,Len(cLine+_EOL)
		FWrite(nDestino,cLine+_EOL,Len(cLine+_EOL))
	endif
return

static function RelLog(aEstSigma,aArqProj)
	private aOrd    := {}
	private aReturn := {"Especial",1,"Administracao",1,2,1,"",1}
	private cPerg 	:= ""
	private Cabec1  := "PRODUTO                               | PROJETO | PROGRAMA     | BAIXA      |          QUANTIDADE"
	private Cabec2  := ""
	private cDesc1  := "PRODUTOS IMPORTADO"
	private cString := "SD3"
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
	
	Processa({|| Impr(aEstSigma,aArqProj)},"","Aguarde processando...",lAborta)
	
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

static function Impr(aEstSigma,aArqProj)
//	PRODUTO                               | PROJETO | PROGRAMA     | BAIXA      |          QUANTIDADE
// 	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//	          1         2         3         4         5         6         7         8         9        10        11
//	999999 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   999999    AAAAAAAAAAAA   99/99/9999   999,999,999,999.999
	aSortSigma := ASort(aEstSigma,,,{|x,y| x[3] < y[3] .and. x[1] < y[1]})
	aSortArq := ASort(aArqProj,,,{|x,y| x[1] < y[1]})
	
	U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
	
	if Len(aSortSigma) > 0
		nLin ++
		
		cProd := aSortSigma[1][1]
		
		@nLin,000 psay aSortSigma[1][1]+" "+If(SB1->(DbSeek(xFilial("SB1")+aSortSigma[1][1],.F.)),Left(SB1->B1_DESC,30),"")
		@nLin,040 psay Left(aSortSigma[1][2],6)
		@nLin,050 psay AllTrim(aSortSigma[1][6])
		@nLin,065 psay U_ConvData(aSortSigma[1][3])
		@nLin,078 psay Transf(aSortSigma[1][5],"@E 999,999,999,999.999")
		
		for i := 2 to Len(aSortSigma)
			nLin++
			
			if cProd == aSortSigma[i][1]
				@nLin,040 psay Left(aSortSigma[i][2],6)
				@nLin,050 psay AllTrim(aSortSigma[1][6])
				@nLin,065 psay U_ConvData(aSortSigma[i][3])
				@nLin,078 psay Transf(aSortSigma[i][5],"@E 999,999,999,999.999")
			else
				@nLin,000 psay aSortSigma[i][1]+" "+If(SB1->(DbSeek(xFilial("SB1")+aSortSigma[i][1],.F.)),Left(SB1->B1_DESC,30),"")
				@nLin,040 psay Left(aSortSigma[i][2],6)
				@nLin,050 psay AllTrim(aSortSigma[1][6])
				@nLin,065 psay U_ConvData(aSortSigma[i][3])
				@nLin,078 psay Transf(aSortSigma[i][5],"@E 999,999,999,999.999")
			endif
			
			cProd := aSortSigma[i][1]
			
			IncProc()
			U_SaltaFolha()
		next
	else
		nLin ++
		
		@nLin,000 psay "Nao tiveram produtos importado."
	endif
	
	if Len(aSortArq) > 0
		nLin += 2
		
		@nLin,000 psay __PrtThinLine()
		
		nLin++
		
		@nLin,000 psay "Arquivo(s) de projeto nao encontrado:"
		
		for i := 1 to Len(aSortArq)
			@nLin+1,000 psay aSortArq[i][1]
			
			IncProc()
			U_SaltaFolha()
		next
	endif
	
	U_Rdp(nRdpPag,cRdpLeg,Tamanho)
return