// Centrala.h : main header file for the CENTRALA application
//

#if !defined(AFX_CENTRALA_H__E560D3B6_F2EA_4088_8896_F0D8E3D7830E__INCLUDED_)
#define AFX_CENTRALA_H__E560D3B6_F2EA_4088_8896_F0D8E3D7830E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols
#include "SystemTray.h"	// Added by ClassView
#include "CentralaDlg.h"	// Added by ClassView


/////////////////////////////////////////////////////////////////////////////
// CCentralaApp:
// See Centrala.cpp for the implementation of this class
//

class CCentralaApp : public CWinApp
{
public:
	CSystemTray m_Tray;
	CCentralaDlg* dlg;
	CDaoDatabase m_dbase;
	CDaoRecordset *m_recordset;
	CCentralaApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CCentralaApp)
	public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CCentralaApp)
	afx_msg void OnPopupExit();
	afx_msg void OnPopupShowprogram();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CENTRALA_H__E560D3B6_F2EA_4088_8896_F0D8E3D7830E__INCLUDED_)
