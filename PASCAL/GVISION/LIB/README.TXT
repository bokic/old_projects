Welcome to GraphVision version 2.01 (bugfixed) package!

GraphVision is a GUI library for Turbo/Borland Pascal, based on Turbo Vision
package.

What's new
==========
 - VESA 256 color modes support;
 - mouse cursor for all supported modes; 
 - streams in XMS;
 - big (> 64 kb) images support;
 - Windows BMP import;
 - PCX import;
 - fast screen scrolling.

List of reported bugs
=====================

   1. GraphStaticBitmap.Done doesn't free memory.  Fixed.
   2. Push button's hot keys take no effect.  Fixed.
   3. SetExclusiveArea procedure doesn't work properly. Fixed.
   4. Some mouse drivers destroy videoregisters' values
      and it causes garbage on the screen. Fixed.
   5. MouseHardInt procedure doesn't restore Graphics Address
      register value.  Fixed.
   6. Screen scrolling sometimes crashes the program. Fixed.
   7. A couple of little bugs in Geditors.pas were fixed.
   8. TXmsStream.Truncate method doesn't work properly. Fixed.

A lot of small bugs also were fixed.

Please send your bug reports to:   serg@em-isrir.msk.su  or
                                   serg@riis.ru

How to build GraphVision
========================

Go to the SOURCES directory and run either buildr.bat or buildp.bat files 
to build the real mode or protected mode version accordinghly.
You are ready to start with GraphVision - now compile the gvdemo.pas
and run it.

Status
======

This is freeware. You can use this library for any purpose without
any fee.

Enjoy!

Regards,
Sergey E. Levov
