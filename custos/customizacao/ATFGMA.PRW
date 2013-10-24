#include "rwmake.ch"

user function ATFGMA()
	DbUseArea(.T.,,"P:\Atf\ATFWIN\ATFGMA.DBF","GMA",.F.,.F.)
	
	Alert(GMA->codigo)
return