// CentralaDlg.cpp : implementation file
//

#include "stdafx.h"
#include "Centrala.h"
#include "CentralaDlg.h"

#include <sys/stat.h>


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

CCentralaDlg::CCentralaDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CCentralaDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CCentralaDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CCentralaDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CCentralaDlg)
	DDX_Control(pDX, IDC_LIST, m_List);
	DDX_Control(pDX, IDC_COUNT, m_Count);
	DDX_Control(pDX, IDC_STOP, m_Stop);
	DDX_Control(pDX, IDC_START, m_Start);
	DDX_Control(pDX, IDC_COMMPORT, m_CommPort);
	DDX_Control(pDX, IDC_MSCOMM, m_MsComm);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CCentralaDlg, CDialog)
	//{{AFX_MSG_MAP(CCentralaDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_START, OnStart)
	ON_BN_CLICKED(IDC_STOP, OnStop)
	ON_COMMAND(ID_POPUP_INFO, OnPopupInfo)
	//}}AFX_MSG_MAP
	ON_MESSAGE(ID_POPUP_EXIT, OnTrayNotification)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CCentralaDlg message handlers

BOOL CCentralaDlg::OnInitDialog()
{
	CDialog::OnInitDialog();
	ASSERT((ID_POPUP_INFO & 0xFFF0) == ID_POPUP_INFO);
	ASSERT(ID_POPUP_INFO < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, ID_POPUP_INFO, strAboutMenu);
		}
	}
	SetIcon(m_hIcon, TRUE);
	SetIcon(m_hIcon, FALSE);
	
	TCHAR Caption[20];

	m_List.ModifyStyle( LVS_TYPEMASK, LVS_REPORT|LVS_SHOWSELALWAYS|LVS_SINGLESEL|LVS_NOSORTHEADER);
	m_List.SetExtendedStyle(LVS_EX_FULLROWSELECT);

	LoadString(AfxGetInstanceHandle(),IDS_VREME,Caption,sizeof(Caption));
	m_List.InsertColumn(0,Caption,LVCFMT_CENTER,110);
	LoadString(AfxGetInstanceHandle(),IDS_LOKAL,Caption,sizeof(Caption));
	m_List.InsertColumn(1,Caption,LVCFMT_CENTER,50);
	LoadString(AfxGetInstanceHandle(),IDS_TELEFONSKI_BROJ,Caption,sizeof(Caption));
	m_List.InsertColumn(2,Caption,LVCFMT_CENTER,97);
	LoadString(AfxGetInstanceHandle(),IDS_IMPULSI,Caption,sizeof(Caption));
	m_List.InsertColumn(3,Caption,LVCFMT_CENTER,60);
	LoadString(AfxGetInstanceHandle(),IDS_SEKUNDI,Caption,sizeof(Caption));
	m_List.InsertColumn(4,Caption,LVCFMT_CENTER,60);

	/*m_List.InsertItem(0,"09.04.2002 15:26:43");
	m_List.SetItemText(0,1,"600");
	m_List.SetItemText(0,2,"00496992106311");
	m_List.SetItemText(0,3,"3");
	m_List.SetItemText(0,4,"17");
	m_List.InsertItem(1,"2");
	m_List.InsertItem(2,"3");
	m_List.InsertItem(3,"4");
	m_List.InsertItem(4,"5");
	m_List.InsertItem(5,"6");
	m_List.InsertItem(6,"7");
	m_List.InsertItem(7,"8");
	m_List.InsertItem(8,"9");
	m_List.InsertItem(9,"10");*/

	CRegKey Reg;	
	DWORD Port=0;
	Reg.Create(HKEY_LOCAL_MACHINE,_T("Software\\BokiCSoft\\Centrala"));
	Reg.QueryValue(Port,"Port");
	Reg.Close();

	m_CommPort.SetCurSel(Port);

	OnStart();	
	return TRUE;
}

void CCentralaDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == ID_POPUP_INFO)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

void CCentralaDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

HCURSOR CCentralaDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

LRESULT CCentralaDlg::OnTrayNotification(WPARAM wParam, LPARAM lParam)
{
return ((CCentralaApp *)AfxGetApp())->m_Tray.OnTrayNotification(wParam, lParam);
}

void CCentralaDlg::OnStart() 
{
m_MsComm.SetCommPort(m_CommPort.GetCurSel()+1);
m_MsComm.SetPortOpen(TRUE);
if (m_MsComm.GetPortOpen()==FALSE)
	PostQuitMessage(-1);
m_Start.EnableWindow(FALSE);
m_CommPort.EnableWindow(FALSE);
m_Stop.EnableWindow();

memset(Buffer,0,1024*10);
CountChars=0;
CurrentPos=-1;
EmptiedBuffers=0;MissedCalls=0;

int TLog=0;
CFile TFile;
struct _stat Buf;
do	{
	TLog++;
	itoa(TLog,LogName,10);
	do	{
		memmove(&LogName[1],&LogName,strlen(LogName)+1);
		LogName[0]=48;
		}while(strlen(LogName)<4);
	memmove(&LogName[3],&LogName,strlen(LogName)+1);
	LogName[0]=76;
	LogName[1]=111;
	LogName[2]=103;
	strcat(LogName,".txt");
	}while(_stat(LogName,&Buf)!=-1);

if (TLog>1000)
	PostQuitMessage(0);

LogFile.Open(LogName,CFile::modeCreate | CFile::modeWrite);
((CCentralaApp *)AfxGetApp())->m_Tray.SetIcon(IDR_MAINFRAME);
}

void CCentralaDlg::OnStop() 
{
m_MsComm.SetPortOpen(FALSE);
m_Start.EnableWindow();
m_CommPort.EnableWindow();
m_Stop.EnableWindow(FALSE);
LogFile.Close();
((CCentralaApp *)AfxGetApp())->m_Tray.SetIcon(IDR_NOCONNECTION);
}

void CCentralaDlg::OnPopupInfo() 
{
	CAboutDlg dlgAbout;
	dlgAbout.DoModal();	
}

BOOL CCentralaDlg::DestroyWindow() 
{
	CRegKey Reg;	
	DWORD Port=m_CommPort.GetCurSel();
	Reg.Create(HKEY_LOCAL_MACHINE,_T("Software\\BokiCSoft\\Centrala"));
	Reg.SetValue(Port,"Port");
	Reg.Close();

	OnClose();
	return CDialog::DestroyWindow();
}
BEGIN_EVENTSINK_MAP(CCentralaDlg, CDialog)
    //{{AFX_EVENTSINK_MAP(CCentralaDlg)
	ON_EVENT(CCentralaDlg, IDC_MSCOMM, 1 /* OnComm */, OnOnCommMscomm, VTS_NONE)
	//}}AFX_EVENTSINK_MAP
END_EVENTSINK_MAP()

void CCentralaDlg::OnOnCommMscomm() 
{
	char Formated[512]="", TSt[512], ReciveData[1028]="";

	if (m_MsComm.GetInBufferCount()>0)
		{
		COleVariant Var(m_MsComm.GetInput());
		wcstombs(ReciveData,Var.bstrVal,1024);
		//strcpy(ReciveData,"\r00 999 020319 1456 601  00020 0001 0    121111               a    0011 a        0.00 E 708  0    121111\r00 001 020319 1457 661        0000 0    2                    a     0004 a        0.00 I 709  0    2\r00 002 020319 1458 661  00007 0001 0    042212832            a     0026 a        0.00 E 711  0    042212832"); // Testing
		CountChars+=strlen(ReciveData);
		LogFile.Write(ReciveData,strlen(ReciveData));
		strcat(Buffer,ReciveData);
		int TLoop=0;
Loop1:

		char *FindStr1=strstr(Buffer,"\r");
		char *FindStr2=NULL;
		if (FindStr1!=NULL)
			FindStr2=strstr(FindStr1+1,"\r");
		if ((FindStr1!=NULL)&&(FindStr2!=NULL))
			{
			memmove(Buffer,FindStr1+1,strlen(FindStr1)); // Skratuvanje na Buffer-ot
			memset(TSt,0,512);
			memcpy(TSt,Buffer,6);
			memmove(&TSt[2],&TSt[3],4);

/*			memset(TSt,0,512);// Povicite so 0 sec. i 0 imp. da ne gi zapisuva.
			_memccpy(TSt,&Buffer[24],32,6);// Dolzina na razgovor vo sec.
			TSt[strlen(TSt)-1]=0;
			if (strcmp(TSt,_T("")))
				{
				memset(TSt,0,512);
				_memccpy(TSt,&Buffer[30],32,5);// Broj na potroseni impulsi.
				TSt[strlen(TSt)-1]=0;
				if (strcmp(TSt,_T("0")))
					goto Loop1;
				}// Do ovde za povicite so 0 sec. i 0 imp. da ne gi zapisuva.*/
			((CCentralaApp *)AfxGetApp())->m_recordset->AddNew();
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("RedBr",TSt);
			if (CurrentPos==999)
				CurrentPos=0;
			if ((atoi(TSt)==CurrentPos+1)||(CurrentPos==-1))
				{
				CurrentPos=atoi(TSt);
				}
				else
				{
				TCHAR Ocekuvano[200];
				LoadString(AfxGetInstanceHandle(),IDS_OCEKUVANO,Ocekuvano,sizeof(Ocekuvano));
				sprintf(TSt,Ocekuvano,CurrentPos+1,atoi(TSt),LogName);
				((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Zabeleski",TSt);
				}
			if (m_List.GetItemCount()>9)
				m_List.DeleteItem(0);

			memset(TSt,0,512);
			_memccpy(TSt,&Buffer[24],32,6);// Dolzina na razgovor vo sec.
			TSt[strlen(TSt)-1]=0;
			if (strcmp(TSt,"")==0)
				strcpy(TSt,"00000");
			COleDateTimeSpan Span(0,0,0,atoi(TSt)); // Vreme na povik = Vreme na zavrsuvanje na razgovor - dolzina
			TSt[2]=0;
			memcpy(TSt,&Buffer[7],2);
			int Year=2000+atoi(TSt);
			memcpy(TSt,&Buffer[9],2);
			int Month=atoi(TSt);
			memcpy(TSt,&Buffer[11],2);
			int Day=+atoi(TSt);
			memcpy(TSt,&Buffer[14],2);
			int Hour=atoi(TSt);
			memcpy(TSt,&Buffer[16],2);
			int Minute=atoi(TSt);
			COleDateTime Time(Year, Month, Day, Hour, Minute, 0);
			Time-=Span;
			COleVariant Variant(Time);
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Vreme",Variant);
			CString TCStr=Time.Format(LOCALE_NOUSEROVERRIDE,LANG_USER_DEFAULT);
			m_List.InsertItem(m_List.GetItemCount(),TCStr);

			memset(TSt,0,512);
			_memccpy(TSt,&Buffer[19],32,4);// Lokal br.
			TSt[strlen(TSt)-1]=0;
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Lokal",TSt);
			m_List.SetItemText(m_List.GetItemCount()-1,1,TSt);

			memset(TSt,0,512);
			_memccpy(TSt,&Buffer[24],32,6);// Dolzina na razgovor vo sec.
			TSt[strlen(TSt)-1]=0;
			if (strlen(TSt)==0)
				strcpy(TSt,"00000");// Ako TSt='' -> '0'
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Sekundi",TSt);
			m_List.SetItemText(m_List.GetItemCount()-1,4,TSt);

			memset(TSt,0,512);
			_memccpy(TSt,&Buffer[30],32,5);// Broj na potroseni impulsi.
			TSt[strlen(TSt)-1]=0;
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Impulsi",TSt);
			m_List.SetItemText(m_List.GetItemCount()-1,3,TSt);

			memset(TSt,0,512);
			_memccpy(TSt,&Buffer[40],32,22);// Telefonski broj.
			TSt[strlen(TSt)-1]=0;
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("TelefonskiBroj",TSt);
			m_List.SetItemText(m_List.GetItemCount()-1,2,TSt);

			memset(TSt,0,512);
			TSt[0]=Buffer[86]; // Internal/External
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Tip",TSt);

			sprintf(TSt,"Broj na uspesno zapisani razgovori: %u",CurrentPos);
// 
			((CCentralaApp *)AfxGetApp())->m_Tray.SetTooltipText(TSt);

			((CCentralaApp *)AfxGetApp())->m_recordset->Update();

			goto Loop1;
			};
		if ((strlen(Buffer)>1024)&&(FindStr1==NULL))
			{			
			MissedCalls++;
			((CCentralaApp *)AfxGetApp())->m_recordset->Edit();
//
			sprintf(TSt,"Prinudno ispraznet buffer vo log datoteka %s",LogName);
			((CCentralaApp *)AfxGetApp())->m_recordset->SetFieldValue("Zabeleski",TSt);

			((CCentralaApp *)AfxGetApp())->m_recordset->Update();
			memmove(&Buffer,&Buffer[512],strlen(Buffer)-511); // Da se koregira size-ot nemam vreme sega
			}
//
		sprintf(TSt,"Број на примени карактери: %u",CountChars);
		m_Count.SetWindowText(TSt);
		}	
}

BOOL CCentralaDlg::OnNotify(WPARAM wParam, LPARAM lParam, LRESULT* pResult) 
{

        switch (((NMHDR*)lParam)->code)
        {
                case HDN_BEGINTRACKW:
                case HDN_BEGINTRACKA:
                        *pResult = TRUE;                // disable tracking
                        return TRUE;                    // Processed message
        } 
	return CDialog::OnNotify(wParam, lParam, pResult);
}