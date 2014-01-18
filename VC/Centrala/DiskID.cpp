#include "stdafx.h"



int ReadIdeDrive(void)
{
   int done = 0;
   int controller = 0;

   HANDLE hScsiDriveIOCTL = 0;
     char   driveName [256]="\\\\.\\Scsi0:";
      //  Try to get a handle to PhysicalDrive IOCTL, report failure
      //  and exit if can't.
   sprintf (driveName, "\\\\.\\Scsi%d:", controller);
      //  Windows NT, Windows 2000, any rights should do
   hScsiDriveIOCTL = CreateFile (driveName,GENERIC_READ | GENERIC_WRITE,FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,OPEN_EXISTING, 0, NULL);
   if (hScsiDriveIOCTL == INVALID_HANDLE_VALUE)
	   return 0;

   if (hScsiDriveIOCTL != INVALID_HANDLE_VALUE)
   {
      int drive = 0;

      char buffer [sizeof (SRB_IO_CONTROL) + SENDIDLENGTH];
      SRB_IO_CONTROL *p = (SRB_IO_CONTROL *) buffer;
      SENDCMDINPARAMS *pin = (SENDCMDINPARAMS *) (buffer + sizeof (SRB_IO_CONTROL));
	    DWORD dummy;
   
		memset (buffer, 0, sizeof (buffer));
        p -> HeaderLength = sizeof (SRB_IO_CONTROL);
        p -> Timeout = 10000;
        p -> Length = SENDIDLENGTH;
        p -> ControlCode = IOCTL_SCSI_MINIPORT_IDENTIFY;
        strncpy ((char *) p -> Signature, "SCSIDISK", 8);
  
        pin -> irDriveRegs.bCommandReg = IDE_ATA_IDENTIFY;
        pin -> bDriveNumber = drive;
        if (DeviceIoControl (hScsiDriveIOCTL, IOCTL_SCSI_MINIPORT, buffer, sizeof (SRB_IO_CONTROL) + sizeof (SENDCMDINPARAMS) - 1, buffer, sizeof (SRB_IO_CONTROL) + SENDIDLENGTH, &dummy, NULL))
			{
               SENDCMDOUTPARAMS *pOut = (SENDCMDOUTPARAMS *) (buffer + sizeof (SRB_IO_CONTROL));
               IDSECTOR *pId = (IDSECTOR *) pOut->bBuffer;
				__int16 *TT;

				TT=(__int16*)&pId->sSerialNumber[0];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[2];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[4];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[6];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[8];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[10];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[12];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[14];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[16];
				done += *TT;
				TT=(__int16*)&pId->sSerialNumber[18];
				done += *TT;
			}
      CloseHandle (hScsiDriveIOCTL);
   }
return done;
}