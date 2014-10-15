#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE _OPC_cGETFILE ( GETF_RETDIRECTORY + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_SHAREAWARE )

User Function ImgSra( cEmp , cFil )

Local aEmpresas
Local aRecnos

Local bWindowInit
Local bDialogInit

Local cTitle
Local cEmpresa

Local lConfirm

Local nEmpresa
Local nRecEmpresa

Local oDlg
Local oFont
Local oEmpresas

Local lExecInRmt	:= ( Type( "oMainWnd" ) == "O" )

CursorWait()

Begin Sequence

	cTitle := "Importação das Fotos dos Funcionáios"

	bWindowInit	:= { ||;
	  					Proc2BarGauge(	{ || GetSraImg( lExecInRmt ) }	,;	//Variavel do Tipo Bloco de Codigo com a Acao ser Executada
										cTitle							,;	//Variavel do Tipo Texto ( Caractere/String ) com o Titulo do Dialogo
										NIL								,;	//Variavel do Tipo Texto ( Caractere/String ) com a Mensagem para a 1a. BarGauge
										NIL								,;	//Variavel do Tipo Texto ( Caractere/String ) com a Mensagem para a 2a. BarGauge
										.F.								,;	//Variavel do Tipo Logica que habilitara o botao para "Abortar" o processo
										.T.								,;	//Variavel do Tipo Logica que definira o uso de controle de estimativa de tempo na 1a. BarGauge
										.F.								,;	//Variavel do Tipo Logica que definira o uso de controle de estimativa de tempo 2a. BarGauge
										.F.				 				 ;	//Variavel do Tipo Logica que definira se a 2a. BarGauge devera ser mostrada
  									 ),;
						MsgInfo( OemToAnsi( "Importação Finalizada" ) , cTitle );
					}

	IF !( lExecInRmt )

		Private oMainWnd

		IF (;
				( cEmp == NIL );
				.or.;
				( cFil == NIL );
			)

			IF ( Select( "SM0" ) == 0 )
				Private cArqEmp := "sigamat.emp"
				OpenSM0()
			EndIF

			IF ( Select( "SM0" ) == 0 )
				MsgInfo( "Não foi possível abrir o Cadastro de Empresas" )
				Break
			EndIF

			aEmpresas	:= {}
			aRecnos		:= {}

			SM0->( dbGoTop() )

			While SM0->( !Eof() )
				IF SM0->( UniqueKey( "M0_CODIGO" , "SM0" ) )
					cEmpresa := SM0->( M0_CODIGO + " - " + AllTrim( M0_NOME ) + " / " + AllTrim( M0_FILIAL ) )
					aAdd( aEmpresas , cEmpresa )
					SM0->( aAdd( aRecnos , Recno() ) )
				EndIF
				SM0->( dbSkip() )
			End While

			IF Empty( aRecnos )
				MsgInfo( "Não Existem Empresas Cadastradas no SIGAMAT.EMP" )
				Break
			EndIF

			lConfirm	:= .F.

			__cInterNet		:= NIL

			DEFINE FONT oFont NAME "Courier New" SIZE 0,-11 BOLD
			DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Selecione a Empresa" ) From 0,0 TO 100,430 OF GetWndDefault() STYLE DS_MODALFRAME STATUS  PIXEL
				@ 020,010 COMBOBOX oEmpresas VAR cEmpresa ITEMS aEmpresas SIZE 200,020 OF oDlg PIXEL FONT oFont
				oEmpresas:nAt		:= 1
				oEmpresas:bChange	:= { || ( nEmpresa := oEmpresas:nAt ) }
				Eval( oEmpresas:bChange )
				oDlg:lEscClose := .F.
				bDialogInit := { || EnchoiceBar( oDlg , { || lConfirm := .T. , oDlg:End() } , { || lConfirm := .F. , oDlg:End() } ) }
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDialogInit )

			IF !( lConfirm )
				Break
			EndIF

			nRecEmpresa := aRecnos[ nEmpresa ]
			
			SM0->( MsGoto( nRecEmpresa ) )

			cEmp	:= SM0->M0_CODIGO
			cFil	:= SM0->M0_CODFIL

			cTitle	+= " Empresa: "
			cTitle	+= aEmpresas[ nEmpresa ]

		EndIF

		CursorWait()

		PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil ) MODULO "CFG"

			InitPublic()

			SetsDefault()
			SetModulo( "SIGACFG" , "CFG" )

			__cInterNet	:= NIL

			lMsHelpAuto		:= .T.

			lMsFinalAuto	:= .T.

			DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( cTitle )
		  	ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )

		RESET ENVIRONMENT

	Else

  		Eval( bWindowInit )

	EndIF

End Sequence

Return( NIL )

Static Function GetSraImg( lShowLog )

Local aLogTitle		:= {}
Local aLogFile		:= {}

Local a_fOpcoesGet

Local b_fOpcoes
Local bMakeLog

Local cPath 		:= cGetFile( "Fotos dos Funcionarios |????????.JPG| Fotos dos Funcionarios |????????.JPEG| Fotos dos Funcionarios |????????.BMP|" , OemToAnsi( "Selecione Diretorio" ) , NIL , "" , .F. , _OPC_cGETFILE )
Local cTime			:= Time()

Local cMaskJPG		:= "????????.JPG"
Local cMaskJPEG		:= "????????.JPEG"
Local cMaskBMP		:= "????????.BMP"

Local aFiles
Local aFilesJPG
Local aFilesJPEG
Local aFilesBMP

Local cFil
Local cMat
Local cFile
Local cTitulo
Local cPathFile
Local cMsgIncProc
Local c_fOpcoesGet
Local cPathLogFile

Local lf_Opcoes

Local nFile
Local nFiles
Local nFilesJPG
Local nFilesJPEG
Local nFilesBMP
Local nSraOrder

Local u_fOpcoesRet

Begin Sequence

	IF Empty( cPath )
		MsgInfo( OemToAnsi( "Não foi possível encontrar o diretório de imagens" ) )
		Break
	EndIF

	cPathFile	:= ( cPath + cMaskJPG )
	aFilesJPG	:= Array( aDir( cPathFile ) )
	nFilesJPG	:= aDir( cPathFile , aFilesJPG )

	cPathFile	:= ( cPath + cMaskJPEG )
	aFilesJPEG	:= Array( aDir( cPathFile ) )
	nFilesJPEG	:= aDir( cPathFile , aFilesJPEG )

	cPathFile	:= ( cPath + cMaskBMP )
	aFilesBMP	:= Array( aDir( cPathFile ) )
	nFilesBMP	:= aDir( cPathFile , aFilesBMP )

	nFiles		:= ( nFilesJPG + nFilesJPEG + nFilesBMP )

	IF ( nFiles == 0 )
		MsgInfo( "Não Existem Imagens a serem importadas" )
		Break
	EndIF

	aFiles := {}
	aEval( aFilesJPG  , { |cFile| aAdd( aFiles , cFile ) } )
	aEval( aFilesJPEG , { |cFile| aAdd( aFiles , cFile ) } )
	aEval( aFilesBMP  , { |cFile| aAdd( aFiles , cFile ) } )
	aFilesJPG	:= NIL
	aFilesJPEG	:= NIL
	aFilesBMP	:= NIL

	IF ( MsgNoYes( "Deseja Selecionar as Imagens a Serem Importadas?" ) )

		b_fOpcoes := { ||;
							a_fOpcoesGet	:= {},;
							u_fOpcoesRet	:= "",;
							aEval( aFiles , { |cFile,cAlias| cAlias := SubStr( cFile , 1 , 8 ) , c_fOpcoesGet := ( cAlias + " - " + cFile ) , aAdd( a_fOpcoesGet , c_fOpcoesGet ) , u_fOpcoesRet += cAlias } ),;
							c_fOpcoesGet	:= u_fOpcoesRet,;
							nFiles			:= Len( aFiles ),;
							lf_Opcoes		:= f_Opcoes(	@u_fOpcoesRet				,;	//Variavel de Retorno
															"Imagens"					,;	//Titulo da Coluna com as opcoes
															a_fOpcoesGet				,;	//Opcoes de Escolha (Array de Opcoes)
															c_fOpcoesGet				,;	//String de Opcoes para Retorno
															NIL							,;	//Nao Utilizado
															NIL							,;	//Nao Utilizado
															.F.							,;	//Se a Selecao sera de apenas 1 Elemento por vez
															8							,;	//Tamanho da Chave
															nFiles						,;	//No maximo de elementos na variavel de retorno
															.T.							,;	//Inclui Botoes para Selecao de Multiplos Itens
															.F.							,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
															NIL							,;	//Qual o Campo para a Montagem do aOpcoes
															.F.							,;	//Nao Permite a Ordenacao
															.F.							,;	//Nao Permite a Pesquisa
															.T.			    			,;	//Forca o Retorno Como Array
															NIL				 			 ;	//Consulta F3
					  									);
					 }

		MsAguarde( b_fOpcoes )

		IF !( lf_Opcoes )
			MsgInfo( OemToAnsi( "Importação Cancelada Pelo Usuário." ) )
			Break
		EndIF

		a_fOpcoesGet	:= {}

		For nFile := 1 To nFiles
            IF ( aScan( u_fOpcoesRet , { |cElem| ( cElem == SubStr( aFiles[ nFile ] , 1 , 8 ) ) } ) > 0 )
            	aAdd( a_fOpcoesGet , aFiles[ nFile ] )
            EndIF
		Next nFile

		aFiles 			:= a_fOpcoesGet
		a_fOpcoesGet	:= NIL

	EndIF

	nFiles	:= Len( aFiles )
	IF ( nFiles == 0 )
		MsgInfo( "Não Existem Imagens a serem importadas" )
		Break
	EndIF

	BarGauge1Set( nFiles )

	SetRepName( "SIGAADV" )

		FechaReposit()	//Força o Fechamento o Repositorio de Imangens
			PackRepository()
		FechaReposit()	//Força o Fechamento o Repositorio de Imangens

	SetRepName( "SIGAADV" )

	nSraOrder := RetOrder( "SRA" , "RA_FILIAL+RA_MAT" )

	SRA->( dbSetOrder( nSraOrder ) )

	For nFile := 1 To nFiles
		cFile		:= aFiles[ nFile ]
		cPathFile	:= ( cPath + cFile )
		cMsgIncProc	:= "Importando Imagem: "
		cMsgIncProc	+= cPathFile
		IncPrcG1Time( cMsgIncProc	,;	//01 -> Inicio da Mensagem
					  nFiles		,;	//02 -> Numero de Registros a Serem Processados
					  cTime			,;	//03 -> Tempo Inicial
					  .T.			,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
					  1				,;	//05 -> Contador de Processos
					  1		 		,;	//06 -> Percentual para Incremento
					  NIL			,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
					  .T.			 ;	//08 -> Se Forca a Atualizacao das Mensagens
					)
		IF !( DlgPutImg( cPathFile , cPath , cFile ) )
			aAdd( aLogFile , ( "Nao foi Possivel Adicionar a Imagem direto no cadastro de funcionario: " + cPathFile ) )
		EndIF
	Next nFile

	FechaReposit()	//Força o Fechamento o Repositorio de Imangens
		PackRepository()
	FechaReposit()	//Força o Fechamento o Repositorio de Imangens

End Sequence

IF !Empty( aLogFile )

	cTitulo := "Inconsistencias na Importacao de Fotos"
	aAdd( aLogTitle , cTitulo )
	bMakeLog := { || cPathLogFile := fMakeLog(	{ aLogFile }	,;	//Array que contem os Detalhes de Ocorrencia de Log
												aLogTitle		,;	//Array que contem os Titulos de Acordo com as Ocorrencias
												NIL				,;	//Pergunte a Ser Listado
												lShowLog		,;	//Se Havera "Display" de Tela
												NIL				,;	//Nome Alternativo do Log
												cTitulo			,;	//Titulo Alternativo do Log
												"M"				,;	//Tamanho Vertical do Relatorio de Log ("P","M","G")
												"L"				,;	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
												NIL				,;	//Array com a Mesma Estrutura do aReturn
												.T.				 ;	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
			  								);
				}
	MsAguarde( bMakeLog , "Gerando o Log" )

	IF !( lShowLog )
		MsgInfo( OemToAnsi( "O Arquivo de Log foi gerado em: " + cPathLogFile ) )
	EndIF

EndIF

Return( NIL )

Static Function DlgPutImg( cPathFile , cPath , cFile )

Local bDialogInit

Local oDlg
Local oRepository

Local lPutOk := .T.

DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 PIXEL

	@ 000,000 REPOSITORY oRepository SIZE 0,0 OF oDlg

	lPutOk		:= PutImg( oRepository , cPathFile , cPath , cFile )
	bDialogInit	:= { || oRepository:lStretch := .T. , oDlg:End() , oRepository := NIL , oDlg:= NIL }

ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit )

Return( lPutOk )

Static Function PutImg( oRepository , cPathFile , cPath , cFile )

Local cSraBitMap

Local lPutOk	:= .F.
Local lPut		:= .F.
Local lLock		:= .F.
Local lAllOk	:= .F.
Local lFound	:= .F.

Local nRecno

Begin Sequence

	IF !( lPutOk := File( cPathFile ) )
		Break
	EndIF

   	cSraBitMap := RetFileName( cPathFile )

	lFound := SRA->( dbSeek( cSraBitMap , .F. ) )

	IF !( lFound )
		Break
	EndIF

	nRecno := SRA->( Recno() )

	lPutOk	:= ( cSraBitMap == oRepository:InsertBmp( cPathFile , NIL , @lPut ) )

	IF (;
			( lPutOk );	//Obtido a partir do Teste de Retorno do Metodo :InsertBmp()
			.and.;
			( lPut );	//Retornado por referencia pelo Metodo :InsertBmp() .T. Inseriu a Nova Imagem, caso contrario, .F.
		)	
	   	SRA->( MsGoto( nRecno ) )

		IF SRA->( lLock := RecLock( "SRA" , .F. ) )
			SRA->RA_BITMAP := cSraBitMap
	    	oRepository:LoadBmp( cSraBitMap )
			oRepository:Refresh()
			SRA->( MsUnLock() )
			MoveFile( cPathFile , cPath , cFile )
		EndIF
	EndIF

End Sequence

lAllOk := (;
				( lFound );	//Verifica se Encontrou o Funcionario
				.and.;
				( lPutOk );	//Obtido a partir do Teste de Retorno do Metodo :InsertBmp()
				.and.;
				( lPut );	//Retornado por referencia pelo Metodo :InsertBmp() .T. Inseriu a Nova Imagem, caso contrario, .F.
				.and.;
				( lLock );	//Gravou a Referencia da Imagem no SRA ( Cadastro de Funcionarios )
			)	

Return( lAllOk )

Static Function MoveFile( cPathFile , cPath , cFile )

Local cNewPath
Local cNewPathFile

Begin Sequence

	cNewPath := ( cPath + "BACK\" )

	IF !( DirMake( cNewPath ) )
		Break
	EndIF

	cNewPathFile := ( cNewPath + cFile )

	FileMove( cPathFile , cNewPathFile )

End Sequence

Return( NIL )

Static Function EqualFile( cFile1 , cFile2 )

Local lIsEqualFile	:= .F.

Local nfhFile1	:= fOpen( cFile1 )
Local nfhFile2	:= fOpen( cFile2 )

Begin Sequence

	IF (;
			( nfhFile1 <= 0 );
			.or.;
			( nfhFile2 <= 0 );
		)
		Break
	EndIF

	lIsEqualFile := ArrayCompare( GetAllTxtFile( nfhFile1 ) , GetAllTxtFile( nfhFile2 ) )

	fClose( nfhFile1 )
	fClose( nfhFile2 )

End Sequence

Return( lIsEqualFile )

Static Function DirMake( cMakeDir , nTimes , nSleep )

Local lMakeOk
Local nMakeOk

IF !( lMakeOk := lIsDir( cMakeDir ) )
	MakeDir( cMakeDir )
	nMakeOk			:= 0
	DEFAULT nTimes	:= 10
	DEFAULT nSleep	:= 1000
	While (;
			!( lMakeOk := lIsDir( cMakeDir ) );
			.and.;
			( ++nMakeOk <= nTimes );
	   )
		Sleep( nSleep )
		MakeDir( cMakeDir )
	End While
EndIF

Return( lMakeOk )

Static Function FileMove( cOldPathFile , cNewPathFile , lErase )

Local lMoveFile

Begin Sequence

	IF !(;
			lMoveFile := (;
							( __CopyFile( cOldPathFile , cNewPathFile ) );
							.and.;
							File( cNewPathFile );
							.and.;
							EqualFile( cOldPathFile , cNewPathFile );
						 );
		)
		Break
	EndIF

	DEFAULT lErase := .T.
	IF ( lErase )
		fErase( cOldPathFile )
	EndIF	

End Sequence

Return( lMoveFile )
