// Centrala.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "Centrala.h"
#include "CentralaDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

BEGIN_MESSAGE_MAP(CCentralaApp, CWinApp)
	//{{AFX_MSG_MAP(CCentralaApp)
	ON_COMMAND(ID_POPUP_EXIT, OnPopupExit)
	ON_COMMAND(ID_POPUP_SHOWPROGRAM, OnPopupShowprogram)
	//}}AFX_MSG_MAP
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

CCentralaApp::CCentralaApp()
{
}

CCentralaApp theApp;

BOOL CCentralaApp::InitInstance()
{
	TCHAR ErrorBuffer[200];

	AfxEnableControlContainer();
	//AfxGetModuleState()->m_dwVersion = 0x0601;
	if (m_hPrevInstance)
		return false;	// Treba da se korigira, neznam zasto ne raboti.

	try {
		AfxDaoInit();
		}
		catch(...)
		{
		LoadString(AfxGetInstanceHandle(),IDS_GRESKA_PRI_DAO,ErrorBuffer,sizeof(ErrorBuffer));
		DoMessageBox(ErrorBuffer,MB_OK,0);
		return FALSE;
		};
	//if (ReadIdeDrive()!=0) // Tabak=109757;TabakNov=110028 Mojot=
		//return FALSE; // na file offset: 118A
	CRegKey Reg;	
	_TCHAR Path[180];

	memset(Path,0,sizeof(Path));
	Reg.Create(HKEY_LOCAL_MACHINE,_T("Software\\BokiCSoft\\Centrala"));
	unsigned long Size=sizeof(Path);
	Reg.QueryValue(Path,"Path",&Size);
	if((_tcslen(Path)>0)&&(Path[_tcslen(Path)-1]!='\\'))
		_tcscat(Path,"\\");
	_tcscat(Path,"Centrala.mdb");

	try
		{
		m_dbase.Open(Path);
		m_recordset = new CDaoRecordset(&m_dbase);
		m_recordset->Open(dbOpenTable,_T("MAIN"),dbAppendOnly&dbDenyWrite);	
		}
	catch (...)
		{
		LoadString(AfxGetInstanceHandle(),IDS_GRESKA_PRI_CENTRALA_MDB,ErrorBuffer,sizeof(ErrorBuffer));
		DoMessageBox(ErrorBuffer,MB_OK,0);
		return FALSE;
		}
	dlg = new CCentralaDlg;
	if (dlg->Create(IDD_CENTRALA_DIALOG)==false)
		{
		LoadString(AfxGetInstanceHandle(),IDS_GRESKA_PRI_MSCOMM,ErrorBuffer,sizeof(ErrorBuffer));
		DoMessageBox(ErrorBuffer,MB_OK,0);
		return false;
		}
		else
	m_pMainWnd = dlg;
	m_Tray.Create(m_pMainWnd,ID_POPUP_EXIT,"",AfxGetApp()->LoadIcon(IDR_MAINFRAME),IDR_POPUP_MENU);
	return true;
}

int CCentralaApp::ExitInstance() 
{
	//m_pMainWnd->DestroyWindow();
	m_Tray.DestroyWindow();
	delete dlg;

	if ((m_recordset!=NULL)&&(m_recordset->IsOpen()==TRUE))
		m_recordset->Close();

	if (m_recordset!=NULL)
		delete m_recordset;

	if (m_dbase.IsOpen()==TRUE)
		m_dbase.Close();

	AfxDaoTerm();

	return CWinApp::ExitInstance();
}

void CCentralaApp::OnPopupExit() 
{
	m_pMainWnd->DestroyWindow();
}

void CCentralaApp::OnPopupShowprogram() 
{
	m_pMainWnd->ShowWindow(SW_SHOWNORMAL);	
}
