// CentralaDlg.h : header file
//
//{{AFX_INCLUDES()
#include "mscomm.h"
//}}AFX_INCLUDES

#if !defined(AFX_CENTRALADLG_H__66D0F4FC_CF08_41C1_86D0_7BEE0E29779F__INCLUDED_)
#define AFX_CENTRALADLG_H__66D0F4FC_CF08_41C1_86D0_7BEE0E29779F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CCentralaDlg dialog

class CCentralaDlg : public CDialog
{
// Construction
public:
	int CountChars;
	char LogName[18];
	CCentralaDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CCentralaDlg)
	enum { IDD = IDD_CENTRALA_DIALOG };
	CListCtrl	m_List;
	CStatic	m_Count;
	CButton	m_Stop;
	CButton	m_Start;
	CComboBox	m_CommPort;
	CMSComm	m_MsComm;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CCentralaDlg)
	public:
	virtual BOOL DestroyWindow();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	virtual BOOL OnNotify(WPARAM wParam, LPARAM lParam, LRESULT* pResult);
	//}}AFX_VIRTUAL
	signed int CurrentPos;
	unsigned int MissedCalls;
	unsigned int EmptiedBuffers;

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CCentralaDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnStart();
	afx_msg void OnStop();
	afx_msg void OnPopupInfo();
	afx_msg void OnOnCommMscomm();
	DECLARE_EVENTSINK_MAP()
	//}}AFX_MSG
	afx_msg LRESULT OnTrayNotification(WPARAM wParam, LPARAM lParam);
	DECLARE_MESSAGE_MAP()
private:
	char Buffer[1024*10];
	CFile LogFile;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CENTRALADLG_H__66D0F4FC_CF08_41C1_86D0_7BEE0E29779F__INCLUDED_)
