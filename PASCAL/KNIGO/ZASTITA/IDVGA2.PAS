
unit idvga2;
interface
procedure DumpRegisters;

procedure AnalyseMode;

procedure CalcRegisters;

function dumpVGAregs:word;

procedure dumpVGAregfile;

procedure loadmodes;

function FormatRgs(var b:byte):word;   {Format registers for dump}

  {Check for PCI devices - Flag is PCI_ flag}
procedure findPCI(flag:word);

 {Checks for a PCI card with ID=sign, returns index in PCIrec, 0 if not found
  start is the PCI device to start at (0 first time, last ID next time)}
function CheckPCI(start,vendor,device:word):integer;


function DACflags:word;


{$i VGADECL.INC}      {Common definitions}


const  {findPCI parameter}
  PCI_off   = 255;
  PCI_test  =   0;  {Auto test}
  PCI_type1 =   1;  {Force PCI Type 1}
  PCI_type2 =   2;  {Force PCI Type 2}

  PCIdevs:word=0;       {Number of PCI video devices}
var
  PCItype:word;
  PCIrec:array[1..10] of record
           PCIbase:word;
           case integer of   {For }
             0:(l:array[0..63] of longint);
             1:(w:array[0..127] of word);
             2:(b:array[0..255] of byte);
             3:(vendor,device,command,status:word;
                rev,prog:byte;class:word;
                cache,latency,header,bist:byte;
                base0,base1,base2,base3,base4,base5
                     ,xx0,xx1,rom:longint;
                capab,xx4,xx5,xx6:byte;
                xx3:longint;
                iline,ipin,mingnt,maxlat:byte);
         end;
  VESAcheat:integer;    {The chipset (CV index) used for VESA mode calcs}
  cv:vidinfo;    {The currently selected video system}
  vids:word;
  vid:array[1..5] of vidinfo;   {Max 5 video systems }

procedure wPCIbyte(index,val:word);
procedure wPCIword(index,val:word);
procedure wPCIlong(index:word;val:longint);
function rPCIbyte(index:word):word;
function rPCIword(index:word):word;
function rPCIlong(index:word):longint;


type
  modetype=record
             md,xres,yres,bytes:word;
             memmode:byte;
             flags:byte;
           end;

  moderec=record
            md:word;
            xres,yres:integer;
            size:word;
            mode:byte;
          end;
  modearr=array[1..100] of moderec;
  moderecp=^moderec;
  modearrp=^modearr;


type
  intarr=array[1..100] of word;



  {VESA VBE (VGA) record definitions}
  _vbe0=record
          sign  :longint;       {Must be 'VESA'}
          vers  :word;          {VBE version.}
          oemadr:^char;
          capab :longint;
          model :^intarr;       {Ptr to list of modes}
          mem   :word;          {#64k blocks}
            {Remaining fields for VBE 2.0 or later}
          oemver:word;          {OEM version}
          vendor,               {Vendor name}
          product,              {Product Name}
          prodrev:^char;        {Product Revision}
          xx:array[0..511] of byte;   {Buffer is too large, as some cards
                                         can return more than 256/512 bytes}
        end;


  _vbe1=record
          attr  :word;
          wina  :byte;
          winb  :byte;
          gran  :word;
          winsiz:word;
          sega  :word;
          segb  :word;
          pagefunc:pointer;
          bytes :word;
          width :word;
          height:word;
          charw :byte;
          charh :byte;
          planes:byte;
          bits  :byte;   {bits per pixel}
          nbanks:byte;
          model :byte;
          banks :byte;
          images:byte;
          res   :byte;
                       {Remaining VBE 1.2+}
          redinf:word;   {red   - low byte = #bits, high byte = start pos}
          grninf:word;   {green - }
          bluinf:word;   {blue  - }
          resinf:word;
          info:byte;     {Bit 0: Gamma, 1: Res field}
                       {Remaining VBE2+}
          padr:longint;  {Linear Address}
          offscr:longint;  {Start of offscreen memory}
          offsiz:word;     {Size of offscreen memory in Kb}
          x:array[0..255] of byte;    {might get trashed by 4F01h}
        end;
  _vbe1p=^_vbe1;


  {VESA VXE (XGA) record definitions}
  _xbe0=record
          sign:longint;    {must be 'VESA'}
          vers:word;
          oemadr:^char;
          capab:longint;
          xgas:word;
          xx:array[1..240] of byte;
        end;

  _xbe1=record
          oemadr:^char;
          capab:longint;
          romadr:longint;
          memreg:longint;
          iobase:word;
          vidadr:longint;  {32bit address of video memory}
          adr4MB:longint;
          adr1MB:longint;
          adr64k:longint;
          adroem:longint;
          sizoem:word;
          modep :^intarr;
          memory:word;
          manid :longint;
          xx:array[1..206] of byte;
        end;

  _xbe2=record
          attrib:word;
          bytes :word;
          pixels:word;
          lins  :word;
          charw :byte;
          charh :byte;
          planes:byte;
          bits  :byte;
          model :byte;
          images:byte;
          redinf:word;   {red   - low byte = #bits, high byte = start pos}
          grninf:word;   {green - }
          bluinf:word;   {blue  - }
          resinf:word;
          xx:array[1..234] of byte;
        end;

const
  ATTR= $3C0;
  SEQ = $3C4;
  GRC = $3CE;



const

  { Chip sub-versions }

  VS_VBE      =   90;
  VS_XBE      =   91;

  CL_Unk54    =  100;
  CL_AVGA1    =  101;
  CL_AVGA2    =  102;
  CL_GD5401   =  103;
  CL_GD5402   =  104;
  CL_GD5402r1 =  105;
  CL_GD5420   =  106;
  CL_GD5420r1 =  107;
  CL_GD5422   =  108;
  CL_GD5424   =  109;
  CL_GD5425   =  110;
  CL_GD5426   =  111;
  CL_GD5428   =  112;
  CL_GD5429   =  113;
  CL_GD5430   =  114;
  CL_GD54M30  =  115;
  CL_GD5440   =  116;
  CL_GD54M40  =  117;
  CL_GD5434   =  118;
  CL_GD5436   =  119;
  CL_GD5446   =  120;
  CL_GD7541   =  121;    {Nordic Lite}
  CL_GD7542   =  122;    {Nordic}
  CL_GD7543   =  123;    {Viking}
  CL_GD7548   =  124;    {?}
  CL_GD7555   =  124;    {?}
  CL_GD7556   =  124;    {?}
  CL_GD5480   =  125;

  CL_GD6205   =  201;
  CL_GD6215   =  202;
  CL_GD6225   =  203;
  CL_GD6235   =  204;
  CL_GD6245   =  205;

  CL_Unk64    =  300;
  CL_GD5410   =  301;
  CL_GD6410   =  302;
  CL_GD6412   =  303;
  CL_GD6420A  =  304;
  CL_GD6420B  =  305;
  CL_GD6440   =  306;

  WD_PVGA1A   =  401;
  WD_90c00    =  402;
  WD_90c10    =  403;
  WD_90c11    =  404;
  WD_90c20    =  405;
  WD_90c20A   =  406;
  WD_90c22    =  407;
  WD_90c24    =  408;
  WD_90c26    =  409;
  WD_90c30    =  410;
  WD_90c31    =  411;
  WD_90c33    =  412;
  WD_9710     =  413;

  CT_Unknown  =  500;
  CT_451      =  501;
  CT_455      =  502;
  CT_456      =  503;
  CT_457      =  504;
  CT_452      =  505;
  CT_450      =  506;
  CT_453      =  507;
  CT_65520    =  508;
  CT_65530    =  509;
  CT_65510    =  510;
  CT_65535    =  511;
  CT_65540    =  512;
  CT_65545    =  513;
  CT_65548    =  514;
  CT_64200    =  515;
  CT_64300    =  516;
  CT_64310    =  517;

  CL_old_unk  =  600;  {CL-GD410/420}
  CL_V7_OEM   =  601;
  CL_GD5x0    =  602;
  CL_GD6x0    =  603;
  CL_GD5320   =  604;

  NCR_Unknown =  700;
  NCR_77c21   =  701;
  NCR_77c22   =  702;
  NCR_77c22e  =  703;
  NCR_77c22ep =  704;
  NCR_77c32BLT=  705;

  OAK_Unknown =  800;
  OAK_037     =  801;
  OAK_057     =  802;
  OAK_067     =  803;
  OAK_077     =  804;
  OAK_083     =  805;
  OAK_087     =  806;
  OAK_107     =  807;
  OAK_109     =  808;
  OAK_111     =  809;
  OAK_112     =  810;
  OAK_117     =  811;

  RT_Unknown  =  900;
  RT_3103     =  901;
  RT_3105     =  902;
  RT_3106     =  903;

  S3_Unknown  = 1000;
  S3_911      = 1001;
  S3_924      = 1002;
  S3_801AB    = 1003;
  S3_805AB    = 1004;
  S3_801C     = 1005;
  S3_805C     = 1006;
  S3_801D     = 1007;
  S3_805D     = 1008;
  S3_801I     = 1009;
  S3_805I     = 1010;
  S3_801P     = 1011;
  S3_805P     = 1012;
  S3_928      = 1013;
  S3_928C     = 1014;
  S3_928D     = 1015;
  S3_928E     = 1016;
  S3_928PCI   = 1017;
  S3_864      = 1018;
  S3_964      = 1019;
  S3_866      = 1020;
  S3_868      = 1021;  {Don't know if these should be above the Trio's yet?}
  S3_968      = 1022;
  S3_732      = 1023;  {Trio32}
  S3_764      = 1024;  {Trio64}
  S3_765      = 1025;  {Trio64 V+}
  S3_767      = 1026;  {Trio64UV+}
  S3_775      = 1027;  {Trio64V2/DX}
  S3_785      = 1028;  {Trio64V2/GX}
  S3_Auro     = 1029;  {Aurora64+}
  S3_Plato    = 1030;  {Aurora64+}
  S3_325      = 1031;  {Plato PX}
  S3_988      = 1032;  {Virge/VX}
  S3_375      = 1033;  {Virge/DX}
  S3_385      = 1034;  {Virge/GX}
  S3_365      = 1035;  {Trio3D}
  S3_357      = 1036;  {ViRGE/GX2}
  S3_391      = 1037;  {Savage3D}
  S3_260      = 1038;  {/MX (LCD)}
  S3_280      = 1039;  {/MX+ (LCD)}

  TR_Unknown  = 1100;
  TR_8800BR   = 1101;
  TR_8800CS   = 1102;
  TR_8900B    = 1103;
  TR_8900C    = 1104;
  TR_9000     = 1105;
  TR_LCD9100B = 1106;
  TR_LX8200   = 1107;
  TR_LCD9320  = 1108;
  TR_IITAGX   = 1109;
  TR_9000i    = 1110;
  TR_9000C    = 1111;
  TR_8900CL   = 1112;
  TR_9200CXr  = 1113;
  TR_9400CXi  = 1114;
  TR_GUI9420  = 1115;
  TR_GUI9430  = 1116;
  TR_GUI9440  = 1117;  {9440AGi}
  TR_GUI9440_1= 1118;  {9440-1}
  TR_GUI9470  = 1119;  {TVG9470}
  TR_GUI9660  = 1120;
  TR_GUI9680  = 1121;
  TR_GUI9682  = 1122;
  TR_GUI9685  = 1123;
  TR_GUI9692  = 1124;
  TR_Cyb9382  = 1125;  {Cyber 938x}
  TR_Cyb9385  = 1126;  {Cyber 938x}
  TR_Cyb9388  = 1127;  {Cyber 938x}
  TR_Cyb9397  = 1128;  {Cyber 938x}
  TR_3D9750   = 1129;  {3DImage975}
  TR_3D9850   = 1130;  {3DImage985}

  AH_A        = 1201;
  AH_B        = 1202;

  ALG_Unknown = 1300;
  ALG_2101    = 1301;
  ALG_2201    = 1302;
  ALG_2228    = 1303;
  ALG_2301    = 1304;
  ALG_2302    = 1305;
  ALG_2364    = 1306;

  CPQ_Unknown = 1400;
  CPQ_AVPORT  = 1401;
  CPQ_IVGS    = 1402;
  CPQ_AVGA    = 1403;
  CPQ_QV      = 1404;   {The original QVision}
  CPQ_QV1024  = 1405;
  CPQ_QV1280  = 1406;

  MX_Unknown  = 1500;
  MX_86000    = 1501;
  MX_86010    = 1502;

  MX_86100    = 1503;
  MX_86101    = 1504;
  MX_86200    = 1505;
  MX_86250    = 1506;
  MX_86251    = 1507;


  GE_5100     = 1601;
  GE_5300     = 1602;
  GE_6100     = 1603;
  GE_6200     = 1604;
  GE_6400     = 1605;

  PR_2000     = 1701;

  IIT_AGX1x   = 1801;
  IIT_AGX14   = 1802;
  IIT_AGX15   = 1803;
  IIT_AGX16   = 1804;
  IIT_AGX17   = 1805;   {Does the AGX-017 really exist?}

  ET_4Unk     = 1900;
  ET_3000     = 1901;
  ET_4000     = 1902;
  ET_4W32     = 1903;
  ET_4W32i_a  = 1904;
  ET_4W32i_b  = 1905;
  ET_4W32i_c  = 1906;
  ET_4W32p_a  = 1907;
  ET_4W32p_b  = 1908;
  ET_4W32p_c  = 1909;
  ET_4W32p_d  = 1910;
  ET_6000     = 1911;
  ET_6100     = 1912;
  ET_6300     = 1913;

  V7_Unknown  = 2000;
  V7_VEGA     = 2001;
  V7_208_13   = 2002;
  V7_208A     = 2003;
  V7_208B     = 2004;
  V7_208CD    = 2005;
  V7_216BC    = 2006;
  V7_216D     = 2007;
  V7_216E     = 2008;
  V7_216F     = 2009;

  WT_Unk      = 2110;
  WT_5086     = 2111;
  WT_5186     = 2112;
  WT_5286     = 2113;
  WT_P9100    = 2114;  {P9100 VGA part}

  YA_6388     = 2201;

  XGA_org     = 2301;
  XGA_NI      = 2302;

  UMC_408     = 2401;
  UMC_418     = 2402;

  ATI_Unknown = 2500;
  ATI_EGA     = 2501;
  ATI_18800   = 2502;
  ATI_18800_1 = 2503;
  ATI_28800_2 = 2504;
  ATI_28800_4 = 2505;
  ATI_28800_5 = 2506;
  ATI_28800_6 = 2507;
  ATI_GUP_3   = 2508;
  ATI_GUP_6   = 2509;
  ATI_GUP_AX  = 2510;
  ATI_GUP_LX  = 2511;
  ATI_M32_Unk = 2512;
  ATI_M64_GX  = 2513;
  ATI_M64_CX  = 2514;
  ATI_M64_CT  = 2515;
  ATI_M64_ET  = 2516;
  ATI_M64_VT  = 2517;
  ATI_M64_GT  = 2518;   {RAGE I}
  ATI_M64_VT2 = 2519;
  ATI_M64_GT2 = 2520;   {RAGE II+}
  ATI_M64_GTP = 2521;   {RAGE Pro}
  ATI_M64_Unk = 2522;

  HMC_304     = 2601;
  HMC_314     = 2602;

  MGA_Unknown = 2700;
  MGA_VGA     = 2701;  {The VGA part of the MGA chipset}
  MGA_Titan   = 2702;  {Ultima (Titan+Dubic)}
  MGA_Helena  = 2703;  {Impression Lite/Plus (Helena)}
  MGA_2085PX  = 2704;  {2085PX ??}
  MGA_2064W   = 2705;  {Millenium (Storm)}
  MGA_1064SG  = 2706;  {Mystique}
  MGA_2164W   = 2707;  {Millenium II}
  MGA_1164SG  = 2708;  {Mystique 220}
  MGA_G100    = 2709;

  ARK_Unknown = 2800;  {ARK Logic}
  ARK_1000VL  = 2801;
  ARK_1000PV  = 2802;
  ARK_2000PV  = 2803;
  ARK_2000MT  = 2804;
  ARK_2000MI  = 2805;

  AC_Unk      = 2900;
  AC_M3135    = 2901;  {Acer ALi CAT/32 - M3135}
  AC_M3141    = 2902;       {           - M3141}
  AC_M3145    = 2903;  {            /64 - M3145}
  AC_M3147    = 2904;  {            /64 - M3147V}

  SC_Unknown  = 3000;
  SC_15064    = 3001;  {Sierra Falcon/64}

  MV_PG1024   = 3101;  {Pro Graphics 1024}
  MV_PG1280   = 3102;

  AS_Unk     = 3200;  {Unknown}
  AS_3210    = 3201;  {Alliance Pro Motion 3210}
  AS_6410    = 3202;
  AS_6422    = 3203;
  AS_6424    = 3204;  {Alliance Pro Motion AT24}
  AS_643D    = 3205;  { AT25/3D}

  IMG_Unknown = 3300;
  IMG_128     = 3301;  {Imagine-128}
  IMG_128v2   = 3302;  {Imagine-128 series 2}
  IMG_t2r     = 3303;  {Imagine-128 Revolution 3D}
  IMG_t2r4    = 3304;  {Imagine-128 Revolution IV}

  SIS_201     = 3401;
  SIS_6202    = 3402;
  SIS_6205    = 3403;
  SIS_6215    = 3404;
  SIS_6225    = 3405;
  SIS_5596    = 3406;
  SIS_5598    = 3407;
  SIS_6326    = 3408;

  NV_NV1      = 3501;
  NV_STG2000  = 3502;
  NV_RIVA128  = 3503;
  NV_STG3000  = 3504;
  NV_RIVA128zx= 3505;
  NV_RIVATNT  = 3506;

  OPTi_168    = 3601;
  OPTi_178    = 3602;
  OPTi_264    = 3603;
  OPTi_265    = 3604;
  OPTi_268    = 3605;

  IGS_Unknown = 3700;
  IGS_1680    = 3701;
  IGS_1682    = 3702;
  IGS_2000    = 3703;
  IGS_2010    = 3704;

  NM_Unknown  = 3800;
  NM_2070     = 3801;
  NM_2090     = 3802;
  NM_2093     = 3803;
  NM_2160     = 3804;

  SM_Unknown  = 3900;
  SM_8104     = 3901;
  SM_8106     = 3902;
  SM_8107     = 3903;
  SM_8108     = 3904;
  SM_8110     = 3905;

  RND_Unknown = 4000;
  RND_V1000   = 4001;  {Rendition Verite V1000}
  RND_V2100   = 4002;
  RND_V2200   = 4003;

  HiQ_Unknown = 4100;
  HiQ_65550   = 4101;  {Chips&tech HiQ 6555x}
  HiQ_65554   = 4102;
  HiQ_65555   = 4103;
  HiQ_68554   = 4104;

  SIG_6425    = 4201;  {Sigma Designs Realmagic 64/GX aka SD6425}

  _3D_vga     = 4301;  {3D Labs VGA core}

  VL_Unknown  = 4400;  {Unknown VLSI chip}
  VL_975      = 4401;  {VL82c975}
  VL_976      = 4402;  {VL82c976}

  CY_GX       = 4501;  {Cyrix MediaGX}

     {Cirrus Laguna (546x) series}
  CL_GD5462   = 4601;
  CL_GD5464   = 4602;
  CL_GD5465   = 4603;

  IN_Unknown  = 4700;
  IN_740      = 4701;


  MP_Mpact2   = 4801;  {MPact2}

  Df_Banshee  = 4901;  {3Dfx Banshee}


    {Tseng 4000 subversions}
  TS_SpeedStar = 1;
  TS_Genoa7900 = 2;



  novgamodes=14;
  stdmodetbl:array[1..novgamodes] of modetype=
     ((md: 0;xres: 40;yres: 25;bytes: 80;memmode:_TEXT;flags:MFL_enVGA)
     ,(md: 1;xres: 40;yres: 25;bytes: 80;memmode:_TEXT;flags:MFL_enVGA)
     ,(md: 2;xres: 80;yres: 25;bytes:160;memmode:_TEXT;flags:MFL_enVGA)
     ,(md: 3;xres: 80;yres: 25;bytes:160;memmode:_TEXT;flags:MFL_enVGA)
     ,(md: 4;xres:320;yres:200;bytes: 80;memmode:_cga2;flags:MFL_enVGA)
     ,(md: 5;xres:320;yres:200;bytes: 80;memmode:_cga2;flags:MFL_enVGA)
     ,(md: 6;xres:640;yres:200;bytes: 80;memmode:_cga1;flags:MFL_enVGA)
     ,(md:13;xres:320;yres:200;bytes: 40;memmode:_pl4 ;flags:MFL_enGrVGA)
     ,(md:14;xres:640;yres:200;bytes: 80;memmode:_pl4 ;flags:MFL_enGrVGA)
     ,(md:15;xres:640;yres:350;bytes: 80;memmode:_pl1 ;flags:MFL_enVGA)
     ,(md:16;xres:640;yres:350;bytes: 80;memmode:_pl4 ;flags:MFL_enGrVGA)
     ,(md:17;xres:640;yres:480;bytes: 80;memmode:_pl1 ;flags:MFL_enVGA)
     ,(md:18;xres:640;yres:480;bytes: 80;memmode:_pl4 ;flags:MFL_enGrVGA)
     ,(md:19;xres:320;yres:200;bytes:320;memmode:_p8  ;flags:MFL_enGrVGA));

  colbits:array[1..max_mode] of integer=   {Bits of data per pixel}
               (0,0,0,1,1,1,1,2,2,2,4,4,4,4,8,15,16,24,24,24,24,24,24);
  usebits:array[1..max_mode] of integer=   {Bits used per pixel}
               (0,0,0,1,1,1,1,2,2,2,4,4,4,4,8,16,16,24,24,32,32,32,32);
  rowbits:array[1..max_mode] of integer=   {Bits used per pixel per plane}
               (0,0,0,1,1,1,1,2,1,2,1,4,4,4,8,16,16,24,24,32,32,32,32);

  modecols:array[1..max_mode] of longint=
               (0,0,0,2,2,2,2,4,4,4,16,16,16,16,256,32768,65536
               ,16777216,16777216,16777216,16777216,16777216,16777216);

  mdtxt:array[1..max_mode] of string[20]=('Text','2 color Text','4 color Text'
                ,'Hercules','CGA 2 color','CGA 4 color','Monochrome','2 colors planar'
                ,'4 colors planar','4 colors packed','16 colors planar','16 colors packed'
                ,'16 colors packed','16 colors packed','256 colors packed','32K colors','64K colors'
                ,'16M colors','16M colors'
                ,'16M col(RGBa)','16M col(BGRa)','16M col(aRGB)','16M col(aBGR)');

  mmodenames:array[1..max_mode] of string[4]=('TXT ','TXT2','TXT4','HERC','CGA1','CGA2'
              ,'PL1 ','PL1E','PL2 ','PK2 ','PL4 ','PK4 ','PK4A;','PK4B','P8  ','P15 ','P16 '
              ,'P24 ','P24b','P32 ','P32b','P32c','P32d');





const






  dacSTDwrInx    =  0;  {3C8h}
  dacSTDpelData  =  1;  {3C9h}
  dacSTDpelMask  =  2;  {3C6h}
  dacSTDrdInx    =  3;  {3C7h}

  dacHIcmd      =  6;  {Command register}


  dacTVPindex   =  6;  {TI TVP 3020/5 index register}
  dacTVPdata    =  7;  {     --       data register}

  dacTVP6index  =  0;  {TI TVP 3026 index register}
  dacTVP6cinx   =  4;  {     --     Cursor LUT index}
  dacTVP6ccol   =  5;  {     --     Cursor LUT data}
  dacTVP6dcur   =  9;  {     --     direct cursor}
  dacTVP6data   = 10;  {     --     data register}
  dacTVP6cram   = 11;  {     --     Cursor RAM data}

  dacTLCtest    = 14;  {TI TLC 34075 test register}


  dacBT1cwrInx  =  4;  {Cursor Wr Addr}
  dacBT1cData   =  5;  {Cursor Data}
  dacBT1cmdA    =  6;  {Command Reg A}
  dacBT1crdInx  =  7;  {Cursor Rd Addr}
  dacBTIipixm   =  0;  {Indexed: Ind Pixel Mask}
  dacBTIovrl    =  1;  {Indexed: Overlay Mask}
  dacBTIcmdB    =  2;  {Indexed: Command B}
  dacBTIcur     =  3;  {Indexed: Cursor}
  dacBTIcurX    =  4;  {Indexed: Cursor X}
  dacBTIcurY    =  6;  {Indexed: Cursor Y}

      {Bt484/5, ATT504/5 series}
  dacBTcwrInx   =  4;
  dacBTcData    =  5;
  dacBTcmd0     =  6;  {Cmd reg 0}
  dacBTcrdInx   =  7;  {Cursor Rd Addr}
  dacBTcmd1     =  8;
  dacBTcmd2     =  9;
  dacBTstat     = 10;  {Status/Cmd3 register}
  dacBTcMap     = 11;  {Cursor Map data}
  dacBTcurX     = 12;  {Hardware cursor X position}
  dacBTcurY     = 14;

    {IBM RGB52x series}
  dacIBMind0    =  4;  {Index - low}
  dacIBMind1    =  5;  {Index - high}
  dacIBMdata    =  6;  {Indexed Data}
  dacIBMctrl    =  7;  {Index Control}

  dacIBMiRev    =  0;  {Indexed}
  dacIBMiId     =  1;


    {Sierra SC150xx}
  dacSCinx      =  3;
  dacSCdata     =  0;


type
  regblk=record
           base:word;
           nbr:word;
           case byte of
             0:(x:array[0..255] of byte);
             1:(w:array[0..127] of word);
             2:(l:array[0..63] of longint);
         end;

  regtype=record
            chip:byte;
            mmode:byte;
            mode,pixels,lins,bytes,tridold0d,tridold0e:word;
            attregs:array[0..31] of byte;
            seqregs,grcregs,crtcregs,xxregs:regblk;
            stdregs:array[$3c0..$3df] of byte;
            xgaregs:array[0..15] of byte;
            dacregs:array[0..16] of byte;
            dacinxd:regblk;
          end;



var
  nomodes:word;
  modetbl:array[1..60] of modetype;   {The complete mode list - disabled}

  noumodes:word;
  usermodes:array[1..50] of modetype;  {Xtra user modes}

  dotest:array[1..max_CHIP] of boolean;
  rgs:regtype;
const
  NBRCHIPS=354;

const
  CHIPSLIST:array[1..NBRCHIPS] of
    record
      nbr:integer;
      nam:string[35];
    end
    =((nbr:VS_VBE      ;nam:'VESA VBE (')
     ,(nbr:VS_XBE      ;nam:'VESA XBE (')

     ,(nbr:CL_Unk54    ;nam:'Unknown Cirrus 54xx (')
     ,(nbr:CL_AVGA1    ;nam:'Acumos AVGA1 (5401)')
     ,(nbr:CL_AVGA2    ;nam:'Acumos AVGA2 (5402)')
     ,(nbr:CL_GD5401   ;nam:'Cirrus CL-GD5401')
     ,(nbr:CL_GD5402   ;nam:'Cirrus CL-GD5402')
     ,(nbr:CL_GD5402r1 ;nam:'Cirrus CL-GD5402 rev 1')
     ,(nbr:CL_GD5420   ;nam:'Cirrus CL-GD5420')
     ,(nbr:CL_GD5420r1 ;nam:'Cirrus CL-GD5420 rev 1')
     ,(nbr:CL_GD5422   ;nam:'Cirrus CL-GD5422')
     ,(nbr:CL_GD5424   ;nam:'Cirrus CL-GD5424')
     ,(nbr:CL_GD5425   ;nam:'Cirrus CL-GD5425')
     ,(nbr:CL_GD5426   ;nam:'Cirrus CL-GD5426')
     ,(nbr:CL_GD5428   ;nam:'Cirrus CL-GD5428')
     ,(nbr:CL_GD5429   ;nam:'Cirrus CL-GD5429')
     ,(nbr:CL_GD5430   ;nam:'Cirrus CL-GD5430')
     ,(nbr:CL_GD54M30  ;nam:'Cirrus CL-GD54M30')
     ,(nbr:CL_GD5440   ;nam:'Cirrus CL-GD5440')
     ,(nbr:CL_GD54M40  ;nam:'Cirrus CL-GD54M40')
     ,(nbr:CL_GD5434   ;nam:'Cirrus CL-GD5434')
     ,(nbr:CL_GD5436   ;nam:'Cirrus CL-GD5436')
     ,(nbr:CL_GD5446   ;nam:'Cirrus CL-GD5446')
     ,(nbr:CL_GD7541   ;nam:'Cirrus CL-GD7541 (Nordic Lite)')
     ,(nbr:CL_GD7542   ;nam:'Cirrus CL-GD7542 (Nordic)')
     ,(nbr:CL_GD7543   ;nam:'Cirrus CL-GD7543 (Viking)')
     ,(nbr:CL_GD7548   ;nam:'Cirrus CL-GD7548 (?)')
     ,(nbr:CL_GD7555   ;nam:'Cirrus CL-GD7555')
     ,(nbr:CL_GD7556   ;nam:'Cirrus CL-GD7556')
     ,(nbr:CL_GD5480   ;nam:'Cirrus CL-GD5480')

     ,(nbr:CL_GD6205   ;nam:'Cirrus CL-GD6205')
     ,(nbr:CL_GD6215   ;nam:'Cirrus CL-GD6215')
     ,(nbr:CL_GD6225   ;nam:'Cirrus CL-GD6225')
     ,(nbr:CL_GD6235   ;nam:'Cirrus CL-GD6235')
     ,(nbr:CL_GD6245   ;nam:'Cirrus CL-GD6245')

     ,(nbr:CL_GD5462   ;nam:'Cirrus CL-GD5462')
     ,(nbr:CL_GD5464   ;nam:'Cirrus CL-GD5464')
     ,(nbr:CL_GD5465   ;nam:'Cirrus CL-GD5465')

     ,(nbr:CL_Unk64    ;nam:'Unknown Cirrus 64xx (')
     ,(nbr:CL_GD5410   ;nam:'Cirrus CL-GD5410')
     ,(nbr:CL_GD6410   ;nam:'Cirrus CL-GD6410')
     ,(nbr:CL_GD6412   ;nam:'Cirrus CL-GD6412')
     ,(nbr:CL_GD6420A  ;nam:'Cirrus CL-GD6420A')
     ,(nbr:CL_GD6420B  ;nam:'Cirrus CL-GD6420B')
     ,(nbr:CL_GD6440   ;nam:'Cirrus CL-GD6440')

     ,(nbr:WD_PVGA1A   ;nam:'Paradise PVGA1A')
     ,(nbr:WD_90c00    ;nam:'Paradise WD90c00')
     ,(nbr:WD_90c10    ;nam:'Paradise WD90c10')
     ,(nbr:WD_90c11    ;nam:'Paradise WD90c11')
     ,(nbr:WD_90c20    ;nam:'Paradise WD90c20')
     ,(nbr:WD_90c20A   ;nam:'Paradise WD90c20A')
     ,(nbr:WD_90c22    ;nam:'Paradise WD90c22')
     ,(nbr:WD_90c24    ;nam:'Paradise WD90c24')
     ,(nbr:WD_90c26    ;nam:'Paradise WD90c26')
     ,(nbr:WD_90c30    ;nam:'Paradise WD90c30')
     ,(nbr:WD_90c31    ;nam:'Paradise WD90c31')
     ,(nbr:WD_90c33    ;nam:'Paradise WD90c33')
     ,(nbr:WD_9710     ;nam:'Paradise WD9710')

     ,(nbr:CT_Unknown  ;nam:'Unknown Chips&Tech (')
     ,(nbr:CT_451      ;nam:'Chips&Tech 82c451')
     ,(nbr:CT_455      ;nam:'Chips&Tech 82c455')
     ,(nbr:CT_456      ;nam:'Chips&Tech 82c456')
     ,(nbr:CT_457      ;nam:'Chips&Tech 82c457')
     ,(nbr:CT_452      ;nam:'Chips&Tech 82c452')
     ,(nbr:CT_450      ;nam:'Chips&Tech 82c450')
     ,(nbr:CT_453      ;nam:'Chips&Tech 82c453')
     ,(nbr:CT_65520    ;nam:'Chips&Tech F65520')
     ,(nbr:CT_65530    ;nam:'Chips&Tech F65530')
     ,(nbr:CT_65510    ;nam:'Chips&Tech F65510')
     ,(nbr:CT_65535    ;nam:'Chips&Tech F65535')
     ,(nbr:CT_65540    ;nam:'Chips&Tech F65540')
     ,(nbr:CT_65545    ;nam:'Chips&Tech F65545')
     ,(nbr:CT_65548    ;nam:'Chips&Tech F65548')
     ,(nbr:CT_64200    ;nam:'Chips&Tech 64200')
     ,(nbr:CT_64300    ;nam:'Chips&Tech 64300')
     ,(nbr:CT_64310    ;nam:'Chips&Tech 64310')

     ,(nbr:CL_old_unk  ;nam:'Unknown Old Cirrus (')
     ,(nbr:CL_V7_OEM   ;nam:'Cirrus V7 OEM')
     ,(nbr:CL_GD5x0    ;nam:'Cirrus 510/520')
     ,(nbr:CL_GD6x0    ;nam:'Cirrus 610/620')
     ,(nbr:CL_GD5320   ;nam:'Cirrus CL-GD5320')

     ,(nbr:NCR_Unknown ;nam:'Unknown NCR (')
     ,(nbr:NCR_77c21   ;nam:'NCR 77c21')
     ,(nbr:NCR_77c22   ;nam:'NCR 77c22')
     ,(nbr:NCR_77c22e  ;nam:'NCR 77c22e')
     ,(nbr:NCR_77c22ep ;nam:'NCR 77c22e+')
     ,(nbr:NCR_77c32BLT;nam:'NCR 77c32BLT')

     ,(nbr:OAK_Unknown ;nam:'Unknown OAK (')
     ,(nbr:OAK_037     ;nam:'OAK-037C')
     ,(nbr:OAK_057     ;nam:'OAK-057')
     ,(nbr:OAK_067     ;nam:'OAK-067')
     ,(nbr:OAK_077     ;nam:'OAK-077')
     ,(nbr:OAK_083     ;nam:'OAK-083')
     ,(nbr:OAK_087     ;nam:'OAK-087')
     ,(nbr:OAK_107     ;nam:'OAK-64107')
     ,(nbr:OAK_109     ;nam:'OAK-64109')
     ,(nbr:OAK_111     ;nam:'OAK-64111')
     ,(nbr:OAK_112     ;nam:'OAK-64112')
     ,(nbr:OAK_117     ;nam:'OAK-64117')

     ,(nbr:RT_Unknown  ;nam:'Unknown Realtek (')
     ,(nbr:RT_3103     ;nam:'Realtek RT3103')
     ,(nbr:RT_3105     ;nam:'Realtek 3105')
     ,(nbr:RT_3106     ;nam:'Realtek 3106')

     ,(nbr:S3_Unknown  ;nam:'Unknown S3 (')
     ,(nbr:S3_911      ;nam:'S3 86c911')
     ,(nbr:S3_924      ;nam:'S3 86c911A/924')
     ,(nbr:S3_801AB    ;nam:'S3 86c801A/B')
     ,(nbr:S3_805AB    ;nam:'S3 86c805A/B')
     ,(nbr:S3_801C     ;nam:'S3 86c801C')
     ,(nbr:S3_805C     ;nam:'S3 86c805C')
     ,(nbr:S3_801D     ;nam:'S3 86c801D')
     ,(nbr:S3_805D     ;nam:'S3 86c805D')
     ,(nbr:S3_801I     ;nam:'S3 86c801i')
     ,(nbr:S3_805I     ;nam:'S3 86c805i')
     ,(nbr:S3_801P     ;nam:'S3 86c801p')
     ,(nbr:S3_805P     ;nam:'S3 86c805p')
     ,(nbr:S3_928      ;nam:'S3 86c928')
     ,(nbr:S3_928C     ;nam:'S3 86c928C')
     ,(nbr:S3_928D     ;nam:'S3 86c928D')
     ,(nbr:S3_928E     ;nam:'S3 86c928E')
     ,(nbr:S3_928PCI   ;nam:'S3 86c928P')
     ,(nbr:S3_864      ;nam:'S3 Vision864')
     ,(nbr:S3_964      ;nam:'S3 Vision964')
     ,(nbr:S3_866      ;nam:'S3 86c866')
     ,(nbr:S3_868      ;nam:'S3 86c868')
     ,(nbr:S3_968      ;nam:'S3 86c968')
     ,(nbr:S3_732      ;nam:'S3 Trio32 (732)')
     ,(nbr:S3_764      ;nam:'S3 Trio64 (764)')
     ,(nbr:S3_765      ;nam:'S3 Trio64 V+ (765)')
     ,(nbr:S3_767      ;nam:'S3 Trio64UV+ (767)')
     ,(nbr:S3_775      ;nam:'S3 Trio64V2/DX (775)')
     ,(nbr:S3_785      ;nam:'S3 Trio64V2/GX (785)')
     ,(nbr:S3_Auro     ;nam:'S3 Aurora64 ()')
     ,(nbr:S3_Plato    ;nam:'S3 Plato PX ()')
     ,(nbr:S3_325      ;nam:'S3 Virge (325)')
     ,(nbr:S3_988      ;nam:'S3 Virge/VX (988)')
     ,(nbr:S3_375      ;nam:'S3 Virge/DX (375)')
     ,(nbr:S3_385      ;nam:'S3 Virge/GX (385)')
     ,(nbr:S3_365      ;nam:'S3 Trio3D (365)')
     ,(nbr:S3_357      ;nam:'S3 Virge/GX2 (357)')
     ,(nbr:S3_391      ;nam:'S3 Savage3D (391)')
     ,(nbr:S3_260      ;nam:'S3 Virge/MX (260)')
     ,(nbr:S3_280      ;nam:'S3 Virge/MX+ (280)')

     ,(nbr:TR_Unknown  ;nam:'Unknown Trident (')
     ,(nbr:TR_8800BR   ;nam:'Trident TVGA8800BR')
     ,(nbr:TR_8800CS   ;nam:'Trident TVGA8800CS')
     ,(nbr:TR_8900B    ;nam:'Trident TVGA8900B')
     ,(nbr:TR_8900C    ;nam:'Trident TVGA8900C')
     ,(nbr:TR_9000     ;nam:'Trident TVGA9000')
     ,(nbr:TR_9000i    ;nam:'Trident TVGA9000i')
     ,(nbr:TR_LCD9100B ;nam:'Trident LCD9100B')
     ,(nbr:TR_LX8200   ;nam:'Trident LX8200')
     ,(nbr:TR_LCD9320  ;nam:'Trident LCD9320')
     ,(nbr:TR_IITAGX   ;nam:'(IIT AGX builtin)')
     ,(nbr:TR_9000C    ;nam:'Trident TVGA9000C')
     ,(nbr:TR_8900CL   ;nam:'Trident TVGA8900CL')
     ,(nbr:TR_9200CXr  ;nam:'Trident TGUI9200CXr')
     ,(nbr:TR_9400CXi  ;nam:'Trident TGUI9400CXi')
     ,(nbr:TR_GUI9420  ;nam:'Trident TGUI9420DGi')
     ,(nbr:TR_GUI9430  ;nam:'Trident TGUI9430')
     ,(nbr:TR_GUI9440  ;nam:'Trident TGUI9440AGi')
     ,(nbr:TR_GUI9440_1;nam:'Trident TGUI9440AGi-1')
     ,(nbr:TR_GUI9470  ;nam:'Trident TVG9470')
     ,(nbr:TR_GUI9660  ;nam:'Trident TGUI9660XGi')
     ,(nbr:TR_GUI9680  ;nam:'Trident TGUI9680XGi')
     ,(nbr:TR_GUI9682  ;nam:'Trident TGUI9682')
     ,(nbr:TR_GUI9685  ;nam:'Trident TGUI9685')
     ,(nbr:TR_GUI9692  ;nam:'Trident TGUI9692')
     ,(nbr:TR_Cyb9382  ;nam:'Trident Cyber9382')
     ,(nbr:TR_Cyb9385  ;nam:'Trident Cyber9385')
     ,(nbr:TR_Cyb9388  ;nam:'Trident Cyber9382')
     ,(nbr:TR_Cyb9397  ;nam:'Trident Cyber9385')
     ,(nbr:TR_3D9750   ;nam:'Trident 3DImage975')
     ,(nbr:TR_3D9850   ;nam:'Trident 3DImage985')

     ,(nbr:AH_A        ;nam:'Ahead V5000A')
     ,(nbr:AH_B        ;nam:'Ahead V5000B')

     ,(nbr:ALG_Unknown ;nam:'Unknown Avance Logic (')
     ,(nbr:ALG_2101    ;nam:'Avance Logic ALG2101')
     ,(nbr:ALG_2201    ;nam:'Avance Logic ALG2201')
     ,(nbr:ALG_2228    ;nam:'Avance Logic ALG2228')
     ,(nbr:ALG_2301    ;nam:'Avance Logic ALG2301')

     ,(nbr:CPQ_Unknown ;nam:'Unknown Compaq (')
     ,(nbr:CPQ_AVPORT  ;nam:'Compaq Adv VGA Port')
     ,(nbr:CPQ_IVGS    ;nam:'Compaq IVGS')
     ,(nbr:CPQ_AVGA    ;nam:'Compaq AVGA')
     ,(nbr:CPQ_QV      ;nam:'Compaq QVision')
     ,(nbr:CPQ_QV1024  ;nam:'Compaq QVision 1024')
     ,(nbr:CPQ_QV1280  ;nam:'Compaq QVision 1280')

     ,(nbr:MX_Unknown  ;nam:'Unknown MXIC (')
     ,(nbr:MX_86000    ;nam:'MXIC MX86000')
     ,(nbr:MX_86010    ;nam:'MXIC MX86010')
     ,(nbr:MX_86100    ;nam:'MXIC MX86100')
     ,(nbr:MX_86101    ;nam:'MXIC MX86101')
     ,(nbr:MX_86200    ;nam:'MXIC MX86200')
     ,(nbr:MX_86250    ;nam:'MXIC MX86250')
     ,(nbr:MX_86251    ;nam:'MXIC MX86251')

     ,(nbr:GE_5100     ;nam:'Genoa 51/5200 (Tseng)')
     ,(nbr:GE_5300     ;nam:'Genoa 53/5400 (Tseng)')
     ,(nbr:GE_6100     ;nam:'Genoa 6100')
     ,(nbr:GE_6200     ;nam:'Genoa 62/6300')
     ,(nbr:GE_6400     ;nam:'Genoa 64/6600')

     ,(nbr:PR_2000     ;nam:'Primus P2000')

     ,(nbr:IIT_AGX1x   ;nam:'IIT AGX-010/1')
     ,(nbr:IIT_AGX14   ;nam:'IIT AGX-014')
     ,(nbr:IIT_AGX15   ;nam:'IIT AGX-015')
     ,(nbr:IIT_AGX16   ;nam:'IIT AGX-016')
     ,(nbr:IIT_AGX17   ;nam:'IIT AGX-017')

     ,(nbr:ET_4Unk     ;nam:'Unknown Tseng ET4000W32 (')
     ,(nbr:ET_3000     ;nam:'Tseng ET3000')
     ,(nbr:ET_4000     ;nam:'Tseng ET4000')
     ,(nbr:ET_4W32     ;nam:'Tseng ET4000W32')
     ,(nbr:ET_4W32i_a  ;nam:'Tseng ET4000W32i rev A')
     ,(nbr:ET_4W32i_b  ;nam:'Tseng ET4000W32i rev B')
     ,(nbr:ET_4W32i_c  ;nam:'Tseng ET4000W32i rev C')
     ,(nbr:ET_4W32p_a  ;nam:'Tseng ET4000W32p rev A')
     ,(nbr:ET_4W32p_b  ;nam:'Tseng ET4000W32p rev B')
     ,(nbr:ET_4W32p_c  ;nam:'Tseng ET4000W32p rev C')
     ,(nbr:ET_4W32p_d  ;nam:'Tseng ET4000W32p rev D')
     ,(nbr:ET_6000     ;nam:'Tseng ET6000')
     ,(nbr:ET_6100     ;nam:'Tseng ET6100')
     ,(nbr:ET_6300     ;nam:'Tseng ET6300')

     ,(nbr:V7_Unknown  ;nam:'Unknown Video7 (')
     ,(nbr:V7_VEGA     ;nam:'Video7 VEGA VGA')
     ,(nbr:V7_208_13   ;nam:'Video7 HT208 Version 1-3')
     ,(nbr:V7_208A     ;nam:'Video7 HT208 rev A')
     ,(nbr:V7_208B     ;nam:'Video7 HT208 rev B')
     ,(nbr:V7_208CD    ;nam:'Video7 HT208 rev C/D')
     ,(nbr:V7_216BC    ;nam:'Video7 HT216 rev B/C')
     ,(nbr:V7_216D     ;nam:'Video7 HT216 rev D')
     ,(nbr:V7_216E     ;nam:'Video7 HT216 rev E')
     ,(nbr:V7_216F     ;nam:'Video7 HT216 rev F')

     ,(nbr:WT_Unk      ;nam:'Unknown Weitek (')
     ,(nbr:WT_5086     ;nam:'Weitek 5086')
     ,(nbr:WT_5186     ;nam:'Weitek 5186')
     ,(nbr:WT_5286     ;nam:'Weitek 5286')
     ,(nbr:WT_P9100    ;nam:'Weitek P9100')

     ,(nbr:YA_6388     ;nam:'Yamaha VPD6388')

     ,(nbr:XGA_org     ;nam:'IBM XGA')
     ,(nbr:XGA_NI      ;nam:'IBM XGA-NI')

     ,(nbr:UMC_408     ;nam:'UMC UM85C408')
     ,(nbr:UMC_418     ;nam:'UMC UM85C418')

     ,(nbr:ATI_Unknown ;nam:'Unknown ATI (')
     ,(nbr:ATI_EGA     ;nam:'ATI EGA')
     ,(nbr:ATI_18800   ;nam:'ATI VGA Wonder (18800)')
     ,(nbr:ATI_18800_1 ;nam:'ATI VGA Wonder (18800-1)')
     ,(nbr:ATI_28800_2 ;nam:'ATI VGA Wonder (28800-2)')
     ,(nbr:ATI_28800_4 ;nam:'ATI VGA Wonder (28800-4)')
     ,(nbr:ATI_28800_5 ;nam:'ATI VGA Wonder XL (28800-5)')
     ,(nbr:ATI_28800_6 ;nam:'ATI VGA Wonder XL (28800-6)')
     ,(nbr:ATI_GUP_3   ;nam:'ATI Mach32 (68800-3)')
     ,(nbr:ATI_GUP_6   ;nam:'ATI Mach32 (68800-6)')
     ,(nbr:ATI_GUP_AX  ;nam:'ATI Mach32 (68800-AX)')
     ,(nbr:ATI_GUP_LX  ;nam:'ATI Mach32 (68800-LX)')
     ,(nbr:ATI_M32_Unk ;nam:'Unknown ATI Mach32 (')
     ,(nbr:ATI_M64_CX  ;nam:'ATI Mach64 (88800CX)')
     ,(nbr:ATI_M64_GX  ;nam:'ATI Mach64 (88800GX)')
     ,(nbr:ATI_M64_CT  ;nam:'ATI Mach64 (264CT)')
     ,(nbr:ATI_M64_ET  ;nam:'ATI Mach64 (264ET)')
     ,(nbr:ATI_M64_VT  ;nam:'ATI Mach64 (264VT)')
     ,(nbr:ATI_M64_GT  ;nam:'ATI Mach64 (264GT RAGE)')
     ,(nbr:ATI_M64_VT2 ;nam:'ATI Mach64 (264VT2)')
     ,(nbr:ATI_M64_GT2 ;nam:'ATI Mach64 (264GT RAGE II)')
     ,(nbr:ATI_M64_GTP ;nam:'ATI Mach64 (264GT RAGE Pro)')
     ,(nbr:ATI_M64_Unk ;nam:'Unknown ATI Mach64 (')

     ,(nbr:HMC_304     ;nam:'HMC HM86304')
     ,(nbr:HMC_314     ;nam:'HMC HM86314')

     ,(nbr:MGA_Unknown ;nam:'Unknown Matrox (')
     ,(nbr:MGA_VGA     ;nam:'Matrox VGA')
     ,(nbr:MGA_Titan   ;nam:'Matrox Ultima')
     ,(nbr:MGA_Helena  ;nam:'Matrox Imp Lite/Plus')
     ,(nbr:MGA_2085PX  ;nam:'Matrox 2085PX')
     ,(nbr:MGA_2064W   ;nam:'Matrox Millennium (2064W)')
     ,(nbr:MGA_1064SG  ;nam:'Matrox Mystique (1064SG)')
     ,(nbr:MGA_2164W   ;nam:'Matrox Millennium II (2164W)')
     ,(nbr:MGA_1164SG  ;nam:'Matrox Mystique 220 (1164SG)')
     ,(nbr:MGA_G100    ;nam:'Matrox Productiva G100')

     ,(nbr:ARK_Unknown ;nam:'Unknown ARK (')
     ,(nbr:ARK_1000VL  ;nam:'ARK1000VL')
     ,(nbr:ARK_1000PV  ;nam:'ARK1000PV')
     ,(nbr:ARK_2000PV  ;nam:'ARK2000PV')
     ,(nbr:ARK_2000MT  ;nam:'ARK2000MT')
     ,(nbr:ARK_2000MI  ;nam:'ARK2000MI')

     ,(nbr:MV_PG1024   ;nam:'MediaVision Pro Graphics 1024')
     ,(nbr:MV_PG1280   ;nam:'MediaVision Pro Graphics 1280')

     ,(nbr:AS_3210    ;nam:'Unknown Alliance (')
     ,(nbr:AS_3210    ;nam:'Alliance Pro Motion 3210')
     ,(nbr:AS_6410    ;nam:'Alliance Pro Motion 6410')
     ,(nbr:AS_6422    ;nam:'Alliance Pro Motion 6422')
     ,(nbr:AS_6424    ;nam:'Alliance Pro Motion AT24')
     ,(nbr:AS_643D    ;nam:'Alliance Pro Motion AT3D')

     ,(nbr:IMG_Unknown ;nam:'Unknown Imagine (')
     ,(nbr:IMG_128     ;nam:'Imagine-128')
     ,(nbr:IMG_128v2   ;nam:'Imagine-128 s2')
     ,(nbr:IMG_t2r     ;nam:'Revolution 3D')
     ,(nbr:IMG_t2r4    ;nam:'Revolution IV')

     ,(nbr:SC_15064    ;nam:'Sierra SC15064')

     ,(nbr:SIS_201     ;nam:'SiS SG86c201')
     ,(nbr:SIS_6202    ;nam:'SiS 6202')
     ,(nbr:SIS_6205    ;nam:'SiS 6205')
     ,(nbr:SIS_6215    ;nam:'SiS 6215')
     ,(nbr:SIS_6225    ;nam:'SiS 6225')
     ,(nbr:SIS_6326    ;nam:'SiS 6326')
     ,(nbr:SIS_5596    ;nam:'SiS 5596')
     ,(nbr:SIS_5598    ;nam:'SiS 5598')

     ,(nbr:NV_NV1      ;nam:'Nvidia NV1')
     ,(nbr:NV_STG2000  ;nam:'SGS STG2000')
     ,(nbr:NV_RIVA128  ;nam:'Nvidia RIVA128')
     ,(nbr:NV_STG3000  ;nam:'SGS STG3000')
     ,(nbr:NV_RIVA128zx;nam:'nVidia RIVA128zx')
     ,(nbr:NV_RivaTNT  ;nam:'nVidia RivaTNT')

     ,(nbr:OPTi_168    ;nam:'OPTi 92c168')
     ,(nbr:OPTi_178    ;nam:'OPTi 92c178')
     ,(nbr:OPTi_264    ;nam:'OPTi 82c264')
     ,(nbr:OPTi_265    ;nam:'OPTi 82c265')
     ,(nbr:OPTi_268    ;nam:'OPTi 82c268')

     ,(nbr:IGS_Unknown ;nam:'Unknown IGS (')
     ,(nbr:IGS_1680    ;nam:'IGS 1680')
     ,(nbr:IGS_1682    ;nam:'IGS 1682')
     ,(nbr:IGS_2000    ;nam:'IGS CyberPro2000')
     ,(nbr:IGS_2010    ;nam:'IGS CyberPro2010')

     ,(nbr:NM_Unknown  ;nam:'NeoMagic Unknown (')
     ,(nbr:NM_2070     ;nam:'NeoMagic NM2070')
     ,(nbr:NM_2090     ;nam:'NeoMagic NM2090 (128V)')
     ,(nbr:NM_2093     ;nam:'NeoMagic NM2093 (128ZV)')
     ,(nbr:NM_2160     ;nam:'NeoMagic NM2160 (128XD)')

     ,(nbr:AC_M3135    ;nam:'Acer M3135')
     ,(nbr:AC_M3141    ;nam:'Acer M3141')
     ,(nbr:AC_M3145    ;nam:'Acer M3145')
     ,(nbr:AC_M3147    ;nam:'Acer M3147V')
     ,(nbr:AC_Unk      ;nam:'Acer M31xx (')

     ,(nbr:SM_8104     ;nam:'S-MOS SPC8104')
     ,(nbr:SM_8106     ;nam:'S-MOS SPC8106')
     ,(nbr:SM_8107     ;nam:'S-MOS SPC8107')
     ,(nbr:SM_8108     ;nam:'S-MOS SPC8108')
     ,(nbr:SM_8110     ;nam:'S-MOS SPC8110')

     ,(nbr:RND_Unknown ;nam:'Unknown Verite (')
     ,(nbr:RND_V1000   ;nam:'Verite V1000')
     ,(nbr:RND_V2100   ;nam:'Verite V2100')
     ,(nbr:RND_V2200   ;nam:'Verite V2200')

     ,(nbr:HiQ_Unknown ;nam:'Unknown HiQ (')
     ,(nbr:HiQ_65550   ;nam:'HiQ 65550')
     ,(nbr:HiQ_65554   ;nam:'HiQ 65554')
     ,(nbr:HiQ_65555   ;nam:'HiQ 65555')
     ,(nbr:HiQ_68554   ;nam:'HiQ 68554')

     ,(nbr:SIG_6425    ;nam:'Sigma SD6425')

     ,(nbr:_3D_vga     ;nam:'3D Labs VGA')

     ,(nbr:VL_Unknown  ;nam:'Unknown VLSI (')
     ,(nbr:VL_975      ;nam:'VLSI VL82c975')
     ,(nbr:VL_976      ;nam:'VLSI VL82c976')

     ,(nbr:CY_GX       ;nam:'Cyrix MediaGX')

     ,(nbr:IN_Unknown  ;nam:'Unknown Intel (')
     ,(nbr:IN_740      ;nam:'Intel740')

     ,(nbr:MP_MPact2   ;nam:'MPact2')

     ,(nbr:DF_Banshee  ;nam:'Banshee')

     );

implementation
uses crt,dos,supervga,dacclk,idvga;

const

  MR_3DLabs=2;
  mr3DLabs:array[1..MR_3DLabs] of moderec
     =((md:  $14;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $15;xres: 640;yres: 480;size:0;mode:_P8));
  MR_Ahead=19;
  mrAhead:array[1..MR_Ahead] of moderec
     =((md:  $22;xres: 132;yres:  44;size:0;mode:_text)
      ,(md:  $23;xres: 132;yres:  25;size:0;mode:_text)
      ,(md:  $24;xres: 132;yres:  28;size:0;mode:_text)
      ,(md:  $25;xres: 640;yres: 480;size:0;mode:_pl4)
      ,(md:  $26;xres: 640;yres: 480;size:0;mode:_pl4)
      ,(md:  $2F;xres: 160;yres:  50;size:0;mode:_text)
      ,(md:  $34;xres:  80;yres:  66;size:0;mode:_text)
      ,(md:  $50;xres: 132;yres:  25;size:0;mode:_txt2)
      ,(md:  $52;xres: 132;yres:  44;size:0;mode:_txt2)
      ,(md:  $60;xres: 640;yres: 400;size:0;mode:_p8)
      ,(md:  $61;xres: 640;yres: 480;size:0;mode:_p8)
      ,(md:  $62;xres: 800;yres: 600;size:0;mode:_p8)
      ,(md:  $63;xres:1024;yres: 768;size:0;mode:_p8)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_pl4)
      ,(md:  $70;xres: 720;yres: 396;size:0;mode:_pl4)
      ,(md:  $71;xres: 800;yres: 600;size:0;mode:_pl4)
      ,(md:  $74;xres:1024;yres: 768;size:0;mode:_pl4)
      ,(md:  $75;xres:1024;yres: 768;size:0;mode:_pl2)
      ,(md:  $76;xres:1024;yres: 768;size:0;mode:_pl1));
  MR_Al3210=4;
  mrAl3210:array[1..MR_Al3210] of moderec
     =((md:  $29;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $28;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $3D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $58;xres: 800;yres: 768;size:0;mode:_PL4));
  MR_Alli=36;
  mrAlli:array[1..MR_Alli] of moderec
     =((md:  $26;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $27;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $28;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $29;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $2A;xres:1024;yres: 768;size:0;mode:_PK4)
      ,(md:  $2B;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $2F;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $31;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $34;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $35;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md:  $38;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $39;xres: 640;yres: 400;size:0;mode:_P32)
      ,(md:  $3A;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $3B;xres:1600;yres:1200;size:0;mode:_P15)
      ,(md:  $40;xres:1280;yres:1024;size:0;mode:_PK4)
      ,(md:  $41;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $60;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $61;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $64;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $65;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $66;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $67;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6D;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $75;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $77;xres:1024;yres: 768;size:0;mode:_P32)
      ,(md:  $78;xres:1600;yres:1200;size:0;mode:_P16)
      ,(md:  $79;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $7A;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $7B;xres:1280;yres:1024;size:0;mode:_P24)
      ,(md:  $7C;xres:1152;yres: 864;size:0;mode:_P24)
      ,(md:  $7D;xres:1152;yres: 864;size:0;mode:_PK4)
      ,(md:  $7F;xres:1152;yres: 864;size:0;mode:_P32));
  MR_Ati=21;
  mrAti:array[1..MR_Ati] of moderec
     =((md:  $21;xres: 100;yres:  25;size:0;mode:_text)
      ,(md:  $22;xres: 100;yres:  30;size:0;mode:_text)
      ,(md:  $23;xres: 132;yres:  25;size:0;mode:_text)
      ,(md:  $27;xres: 132;yres:  25;size:0;mode:_txt2)
      ,(md:  $33;xres: 132;yres:  44;size:0;mode:_text)
      ,(md:  $37;xres: 132;yres:  44;size:0;mode:_txt2)
      ,(md:  $53;xres: 800;yres: 560;size:0;mode:_pl4)
      ,(md:  $54;xres: 800;yres: 600;size:0;mode:_pl4)
      ,(md:  $55;xres:1024;yres: 768;size:0;mode:_pl4)
      ,(md:  $58;xres:  80;yres:  33;size:0;mode:_text)
      ,(md:  $5B;xres:  80;yres:  30;size:0;mode:_text)
      ,(md:  $61;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $62;xres: 640;yres: 480;size:0;mode:_p8)
      ,(md:  $63;xres: 800;yres: 600;size:0;mode:_p8)
      ,(md:  $64;xres:1024;yres: 768;size:0;mode:_p8)
      ,(md:  $65;xres:1024;yres: 768;size:0;mode:_pk4)
      ,(md:  $67;xres:1024;yres: 768;size:0;mode:_pl2)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_pl4)
      ,(md:  $72;xres: 640;yres: 480;size:0;mode:_p15)
      ,(md:  $73;xres: 800;yres: 600;size:0;mode:_p15)
      ,(md:  $75;xres: 640;yres: 480;size:2048;mode:_p24));  {XL24}
  MR_ALG=28;
  mrAlg:array[1..MR_ALG] of moderec
     =((md:  $20;xres: 132;yres:  25;size:0;mode:_text)
      ,(md:  $21;xres: 132;yres:  30;size:0;mode:_text)
      ,(md:  $22;xres: 132;yres:  43;size:0;mode:_text)
      ,(md:  $23;xres: 132;yres:  60;size:0;mode:_text)
      ,(md:  $24;xres:  80;yres:  30;size:0;mode:_text)
      ,(md:  $25;xres:  80;yres:  43;size:0;mode:_text)
      ,(md:  $26;xres:  80;yres:  60;size:0;mode:_text)
      ,(md:  $27;xres: 960;yres: 720;size:0;mode:_pl4 )
      ,(md:  $28;xres: 512;yres: 512;size:0;mode:_P8  )  {2101}
      ,(md:  $29;xres: 640;yres: 400;size:0;mode:_P8  )
      ,(md:  $2A;xres: 640;yres: 480;size:0;mode:_P8  )
      ,(md:  $2B;xres: 800;yres: 600;size:0;mode:_PL4 )
      ,(md:  $2C;xres: 800;yres: 600;size:0;mode:_P8  )
      ,(md:  $2D;xres: 768;yres:1024;size:0;mode:_PL4 )
      ,(md:  $2E;xres: 768;yres:1024;size:0;mode:_P8  )
      ,(md:  $2F;xres:1024;yres: 768;size:0;mode:_PL2 )
      ,(md:  $30;xres:1024;yres: 768;size:0;mode:_PL4 )
      ,(md:  $31;xres:1024;yres: 768;size:0;mode:_P8  )
      ,(md:  $36;xres:1280;yres:1024;size:0;mode:_PL4 )
      ,(md:  $37;xres:1280;yres:1024;size:0;mode:_P8  )
      ,(md:  $40;xres: 320;yres: 200;size:0;mode:_P16 )
      ,(md:  $41;xres: 512;yres: 512;size:0;mode:_P16 )
      ,(md:  $42;xres: 640;yres: 400;size:0;mode:_P16 )
      ,(md:  $43;xres: 640;yres: 480;size:0;mode:_P16 )
      ,(md:  $44;xres: 800;yres: 600;size:0;mode:_P16 )
      ,(md:  $45;xres:1024;yres: 768;size:0;mode:_P16 )
      ,(md:  $48;xres: 640;yres: 480;size:0;mode:_P24 )  {2228}
      ,(md:  $49;xres: 800;yres: 600;size:0;mode:_P24 ));     {2228}
  MR_Chips=29;
  mrChips:array[1..MR_Chips] of moderec
     =((md:  $20;xres: 640;yres: 480;size:0;mode:_PK4)
      ,(md:  $22;xres: 800;yres: 600;size:0;mode:_PK4)
      ,(md:  $24;xres:1024;yres: 768;size:0;mode:_PK4)
      ,(md:  $28;xres:1280;yres:1024;size:0;mode:_PK4)
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $32;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $34;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $38;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $40;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $41;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $42;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $43;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $44;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $45;xres:1024;yres: 768;size:0;mode:_P16)  {64300}
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $60;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $61;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $70;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $71;xres: 960;yres: 720;size:0;mode:_PL4)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $73;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $74;xres:1280;yres: 960;size:0;mode:_PL4)
      ,(md:  $78;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $79;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $7A;xres: 720;yres: 540;size:0;mode:_P8)
      ,(md:  $7B;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $7C;xres: 800;yres: 600;size:0;mode:_P8)  {c453}
      ,(md:  $7E;xres:1024;yres: 768;size:0;mode:_P8));
  MR_CtHiQ=25;
  mrCtHiQ:array[1..MR_CtHiQ] of moderec
     =((md:  $20;xres: 640;yres: 480;size:0;mode:_PK4)
      ,(md:  $22;xres: 800;yres: 600;size:0;mode:_PK4)
      ,(md:  $24;xres:1024;yres: 768;size:0;mode:_PK4)
      ,(md:  $28;xres:1280;yres:1024;size:0;mode:_PK4)
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $31;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $32;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $34;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $38;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $40;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $41;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $42;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $43;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $44;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $45;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $54;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $58;xres:1280;yres:1024;size:0;mode:_P24)
      ,(md:  $64;xres:1024;yres: 768;size:0;mode:_Pl4)
      ,(md:  $68;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $70;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $71;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $72;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $74;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $78;xres:1280;yres:1024;size:0;mode:_P8));
  MR_Cir=21;
  mrCir:array[1..MR_Cir] of moderec   {Cirrus 4x0,5x0,5x0}
     =((md:  $15;xres: 132;yres:  25;size:0;mode:_TXT2)
      ,(md:  $16;xres: 132;yres:  44;size:0;mode:_TXT2)
      ,(md:  $18;xres: 132;yres:  30;size:0;mode:_TXT2)
      ,(md:  $1E;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $1F;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $20;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $22;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $31;xres: 100;yres:  37;size:0;mode:_TXT2)
      ,(md:  $40;xres: 720;yres: 540;size:0;mode:_PL4)
      ,(md:  $50;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $51;xres: 512;yres: 480;size:0;mode:_P8)
      ,(md:  $61;xres: 640;yres: 400;size:0;mode:_PL4)
      ,(md:  $62;xres: 640;yres: 450;size:0;mode:_PL4)
      ,(md:  $63;xres: 720;yres: 540;size:0;mode:_PL4)
      ,(md:  $64;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $70;xres: 360;yres: 480;size:0;mode:_P8)
      ,(md:  $71;xres: 528;yres: 400;size:0;mode:_P8)
      ,(md:  $72;xres: 528;yres: 480;size:0;mode:_P8)
      ,(md:  $74;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $75;xres: 640;yres: 400;size:0;mode:_P8));
  MR_Cir54=29;
  mrCir54:array[1..MR_Cir54] of moderec    {Cirrus 54xx and 62xx}
     =((md:  $14;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4 )
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8  )
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4 )
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8  )
      ,(md:  $60;xres:1024;yres: 768;size:0;mode:_P8  )
      ,(md:  $64;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $65;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $66;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $67;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $68;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6C;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $6D;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $6F;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $70;xres: 320;yres: 200;size:2048;mode:_P24)
      ,(md:  $71;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md:  $72;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $73;xres:1024;yres: 768;size:0;mode:_P32)
      ,(md:  $74;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $75;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $76;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $77;xres:1280;yres:1024;size:0;mode:_P24)
      ,(md:  $78;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $78;xres: 800;yres: 600;size:3072;mode:_P24)
      ,(md:  $79;xres:1152;yres: 870;size:0;mode:_P32)
      ,(md:  $7C;xres:1152;yres: 864;size:0;mode:_P8));
  MR_CirLAG=22;
  mrCirLAG:array[1..MR_CirLAG] of moderec    {Cirrus 546x}
     =((md:  $58;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5E;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $60;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $64;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $64;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $65;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $65;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6C;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $6D;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $71;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $72;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $74;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $74;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $76;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $78;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $7A;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $7A;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $7B;xres:1600;yres:1200;size:0;mode:_P8));
  MR_Cir64=14;
  mrCir64:array[1..MR_Cir64] of moderec   {Cirrus 64xx}
     =((md:  $2D;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $2E;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $2F;xres: 648;yres: 480;size:0;mode:_P8)
      ,(md:  $30;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $37;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $41;xres: 100;yres:  50;size:0;mode:_TEXT)
      ,(md:  $42;xres: 100;yres:  60;size:0;mode:_TEXT)
      ,(md:  $44;xres: 100;yres:  25;size:0;mode:_TEXT)
      ,(md:  $51;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $52;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $53;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $54;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $64;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4));
  MR_Compaq=22;
  mrCompaq:array[1..MR_Compaq] of moderec      {Compaq QV}
     =((md:  $22;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $23;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $27;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $28;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $29;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $2E;xres: 640;yres: 480;size:1024;mode:_P8)   {Last AVGA mode}
      ,(md:  $32;xres: 640;yres: 480;size:1024;mode:_P8)
      ,(md:  $33;xres: 640;yres: 400;size:1024;mode:_P8)
      ,(md:  $34;xres: 800;yres: 600;size:1024;mode:_P8)
      ,(md:  $37;xres:1024;yres: 768;size:0;mode:_PK4a)
      ,(md:  $38;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $39;xres:1280;yres:1024;size:1024;mode:_PK4a)
      ,(md:  $3A;xres:1280;yres:1024;size:2048;mode:_P8)
      ,(md:  $3B;xres: 512;yres: 480;size:0;mode:_P8)
      ,(md:  $3C;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $3E;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $3E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $3F;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $40;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $4D;xres: 512;yres: 480;size:0;mode:_P32)
      ,(md:  $4E;xres: 640;yres: 400;size:0;mode:_P32)
      ,(md:  $4F;xres: 640;yres: 480;size:0;mode:_P32));
  MR_Cyrix=34;
  mrCyrix:array[1..MR_Cyrix] of moderec   {Cyrix MediaGX}
     =((md:  $20;xres: 320;yres: 200;size:0;mode:_P8)
      ,(md:  $21;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $22;xres: 320;yres: 240;size:0;mode:_P15)
      ,(md:  $23;xres: 320;yres: 240;size:0;mode:_P16)
      ,(md:  $25;xres: 400;yres: 300;size:0;mode:_P8)
      ,(md:  $26;xres: 400;yres: 300;size:0;mode:_P15)
      ,(md:  $27;xres: 400;yres: 300;size:0;mode:_P16)
      ,(md:  $29;xres: 512;yres: 384;size:0;mode:_P8)
      ,(md:  $2A;xres: 512;yres: 384;size:0;mode:_P15)
      ,(md:  $2B;xres: 512;yres: 384;size:0;mode:_P16)
      ,(md:  $2D;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $2E;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $2F;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $5A;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $5B;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $60;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $64;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $65;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $68;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6B;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $6C;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $6D;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $6E;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $6F;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $73;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $78;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $79;xres: 320;yres: 200;size:0;mode:_P16));
  MR_Everex=34;
  mrEverex:array[1..MR_Everex] of moderec   {Everex}
     =((md:  $00;xres: 640;yres: 480;size:0;mode:_PL4)
      ,(md:  $01;xres: 752;yres: 410;size:0;mode:_PL4)
      ,(md:  $02;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $03;xres:  80;yres:  34;size:0;mode:_TEXT)
      ,(md:  $04;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $05;xres:  94;yres:  29;size:0;mode:_TEXT)
      ,(md:  $06;xres:  94;yres:  51;size:0;mode:_TEXT)
      ,(md:  $07;xres: 100;yres:  43;size:0;mode:_TEXT)
      ,(md:  $08;xres: 100;yres:  75;size:0;mode:_TEXT)
      ,(md:  $09;xres:  80;yres:  44;size:0;mode:_TEXT)
      ,(md:  $0A;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $0B;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $0C;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $0D;xres:  80;yres:  44;size:0;mode:_TXT2)
      ,(md:  $0E;xres: 132;yres:  25;size:0;mode:_TXT2)
      ,(md:  $0F;xres: 132;yres:  44;size:0;mode:_TXT2)
      ,(md:  $11;xres:1280;yres: 350;size:0;mode:_PL2)
      ,(md:  $12;xres:1280;yres: 600;size:0;mode:_PL2)
      ,(md:  $13;xres: 640;yres: 350;size:0;mode:_P8)
      ,(md:  $14;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $15;xres: 512;yres: 480;size:0;mode:_P8)
      ,(md:  $16;xres:  80;yres:  30;size:0;mode:_TEXT)
      ,(md:  $18;xres: 100;yres:  27;size:0;mode:_TEXT)
      ,(md:  $20;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $21;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $31;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $40;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $50;xres: 132;yres:  32;size:0;mode:_TXT2)
      ,(md:  $62;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $70;xres: 512;yres: 480;size:0;mode:_P15)
      ,(md:  $71;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $76;xres: 512;yres: 480;size:0;mode:_P24)
      ,(md:  $77;xres: 640;yres: 480;size:0;mode:_P24));
  MR_Genoa=31;
  mrGenoa:array[1..MR_Genoa] of moderec    {Genoa}
     =((md:  $43;xres:  80;yres:  29;size:0;mode:_TXT2)
      ,(md:  $44;xres:  80;yres:  32;size:0;mode:_TXT2)
      ,(md:  $45;xres:  80;yres:  44;size:0;mode:_TXT2)
      ,(md:  $46;xres: 132;yres:  25;size:0;mode:_TXT2)
      ,(md:  $47;xres: 132;yres:  29;size:0;mode:_TXT2)
      ,(md:  $48;xres: 132;yres:  32;size:0;mode:_TXT2)
      ,(md:  $49;xres: 132;yres:  44;size:0;mode:_TXT2)
      ,(md:  $58;xres:  80;yres:  32;size:0;mode:_TEXT)
      ,(md:  $59;xres: 720;yres: 512;size:0;mode:_PL4 )
      ,(md:  $5A;xres: 100;yres:  42;size:0;mode:_TEXT)
      ,(md:  $5B;xres: 640;yres: 350;size:0;mode:_P8)
      ,(md:  $5C;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $5D;xres: 720;yres: 512;size:0;mode:_P8)
      ,(md:  $5E;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5F;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $60;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $61;xres: 132;yres:  29;size:0;mode:_TEXT)
      ,(md:  $62;xres: 132;yres:  32;size:0;mode:_TEXT)
      ,(md:  $63;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $64;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6B;xres: 100;yres:  75;size:0;mode:_TEXT)
      ,(md:  $6C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $72;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $73;xres: 640;yres: 480;size:0;mode:_PL4)
      ,(md:  $74;xres:  80;yres:  66;size:0;mode:_TEXT)
      ,(md:  $78;xres: 100;yres:  75;size:0;mode:_TEXT)
      ,(md:  $79;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $7D;xres: 512;yres: 512;size:0;mode:_P8)
      ,(md:  $7E;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $7F;xres:1024;yres: 768;size:0;mode:_PL2));
  MR_Intel=42;
  mrIntel:array[1..MR_Intel] of moderec    {Intel}
     =((md:  $14;xres: 320;yres: 200;size:0;mode:_P8)
      ,(md:  $15;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $15;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $16;xres: 320;yres: 200;size:0;mode:_P24)
      ,(md:  $17;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $18;xres: 320;yres: 240;size:0;mode:_P15)
      ,(md:  $18;xres: 320;yres: 240;size:0;mode:_P16)
      ,(md:  $19;xres: 320;yres: 240;size:0;mode:_P24)
      ,(md:  $1A;xres: 400;yres: 300;size:0;mode:_P8)
      ,(md:  $1B;xres: 400;yres: 300;size:0;mode:_P15)
      ,(md:  $1B;xres: 400;yres: 300;size:0;mode:_P16)
      ,(md:  $1C;xres: 400;yres: 300;size:0;mode:_P24)
      ,(md:  $1D;xres: 512;yres: 384;size:0;mode:_P8)
      ,(md:  $1E;xres: 512;yres: 384;size:0;mode:_P15)
      ,(md:  $1E;xres: 512;yres: 384;size:0;mode:_P16)
      ,(md:  $1F;xres: 512;yres: 384;size:0;mode:_P24)
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $31;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $32;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $34;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $38;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $3A;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $40;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $41;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $42;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $43;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $44;xres:1020;yres: 768;size:0;mode:_P15)
      ,(md:  $45;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $48;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $49;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $52;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $54;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $61;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $61;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $62;xres: 640;yres: 400;size:0;mode:_P24)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $70;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $71;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $72;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $74;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $78;xres:1280;yres:1024;size:0;mode:_P8));
  MR_MXIC=9;
  mrMXIC:array[1..MR_MXIC] of moderec    {Macronix}
     =((md:  $50;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $51;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $55;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $56;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $57;xres: 640;yres: 350;size:0;mode:_P8)
      ,(md:  $58;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $59;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $5A;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5B;xres:1024;yres: 768;size:0;mode:_P8));
  MR_MXIC2=26;
  mrMXIC2:array[1..MR_MXIC2] of moderec  {MXIC MX86100-251}
     =((md:  $20;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $25;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_PL4)
      ,(md:  $31;xres: 800;yres: 800;size:0;mode:_PL4)
      ,(md:  $32;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $34;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $40;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $41;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $42;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $44;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $45;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $52;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $54;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $55;xres:1600;yres:1200;size:0;mode:_P15)
      ,(md:  $60;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $61;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $62;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $64;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $65;xres:1600;yres:1200;size:0;mode:_P16)
      ,(md:  $70;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $71;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P32)
      ,(md:  $76;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $77;xres: 800;yres: 600;size:0;mode:_P24));
  MR_NCR=27;
  mrNCR:array[1..MR_NCR] of moderec     {NCR}
     =((md:  $40;xres:1600;yres:1200;size:0;mode:_PL4)
      ,(md:  $41;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $54;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $56;xres: 132;yres:  50;size:0;mode:_TXT4)
      ,(md:  $57;xres: 132;yres:  25;size:0;mode:_TXT4)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $59;xres: 800;yres: 600;size:0;mode:_PL1 )
      ,(md:  $5A;xres:1024;yres: 768;size:0;mode:_PL1 )
      ,(md:  $5B;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5E;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $61;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $62;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $67;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $6A;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $6B;xres:1280;yres: 960;size:0;mode:_P8  )
      ,(md:  $70;xres: 640;yres: 480;size:0;mode:_P15 )
      ,(md:  $71;xres: 800;yres: 600;size:0;mode:_P15 )
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P15 )
      ,(md:  $78;xres: 640;yres: 480;size:0;mode:_P16 )
      ,(md:  $79;xres: 800;yres: 600;size:0;mode:_P16 )
      ,(md:  $7A;xres:1024;yres: 768;size:0;mode:_P16 ));
  MR_NV1=11;
  mrNV1:array[1..MR_NV1] of moderec     {nVidia NV1}
     =((md:  $41;xres:  80;yres:  25;size:0;mode:_TEXT)
      ,(md:  $47;xres:  40;yres:  25;size:0;mode:_TEXT)
      ,(md:  $54;xres:  80;yres:  25;size:0;mode:_TEXT)
      ,(md:  $55;xres:  40;yres:  25;size:0;mode:_TEXT)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4 )
      ,(md:  $59;xres: 640;yres: 400;size:0;mode:_P8  )
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8  )
      ,(md:  $5E;xres: 640;yres: 400;size:0;mode:_P8  )
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8  )
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4 )
      ,(md:  $6B;xres: 800;yres: 600;size:0;mode:_PL4 ));
  MR_NV3=63;
  mrNV3:array[1..MR_NV3] of moderec     {nVidia RIVA128}
     =((md:  $20;xres: 320;yres: 200;size:0;mode:_P32)
      ,(md:  $21;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $22;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $30;xres: 320;yres: 200;size:0;mode:_P8)
      ,(md:  $31;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $32;xres: 320;yres: 400;size:0;mode:_P15)
      ,(md:  $32;xres: 320;yres: 400;size:0;mode:_P16)
      ,(md:  $33;xres: 320;yres: 400;size:0;mode:_P32)
      ,(md:  $34;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $35;xres: 320;yres: 240;size:0;mode:_P15)
      ,(md:  $35;xres: 320;yres: 240;size:0;mode:_P16)
      ,(md:  $36;xres: 320;yres: 240;size:0;mode:_P32)
      ,(md:  $37;xres: 400;yres: 300;size:0;mode:_P8)
      ,(md:  $38;xres: 400;yres: 300;size:0;mode:_P15)
      ,(md:  $38;xres: 400;yres: 300;size:0;mode:_P16)
      ,(md:  $39;xres: 400;yres: 300;size:0;mode:_P32)
      ,(md:  $3A;xres: 512;yres: 384;size:0;mode:_P8)
      ,(md:  $3B;xres: 512;yres: 384;size:0;mode:_P15)
      ,(md:  $3B;xres: 512;yres: 384;size:0;mode:_P16)
      ,(md:  $3C;xres: 512;yres: 384;size:0;mode:_P32)
      ,(md:  $3D;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $3D;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $3E;xres: 640;yres: 400;size:0;mode:_P32)
      ,(md:  $3F;xres:1024;yres: 768;size:0;mode:_P32)
      ,(md:  $41;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $42;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md:  $42;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md:  $43;xres:1152;yres: 864;size:0;mode:_P32)
      ,(md:  $44;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $44;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $45;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $46;xres:1600;yres:1200;size:0;mode:_P15)
      ,(md:  $46;xres:1600;yres:1200;size:0;mode:_P16)
      ,(md:  $47;xres: 480;yres: 360;size:0;mode:_P8)
      ,(md:  $48;xres: 480;yres: 360;size:0;mode:_P15)
      ,(md:  $48;xres: 480;yres: 360;size:0;mode:_P16)
      ,(md:  $49;xres: 480;yres: 360;size:0;mode:_P32)
      ,(md:  $4A;xres: 960;yres: 720;size:0;mode:_P8)
      ,(md:  $4B;xres: 960;yres: 720;size:0;mode:_P15)
      ,(md:  $4B;xres: 960;yres: 720;size:0;mode:_P16)
      ,(md:  $4C;xres: 960;yres: 720;size:0;mode:_P32)
      ,(md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $5A;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $5B;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5E;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $64;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $65;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $68;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6B;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $6F;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $6F;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $78;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $78;xres: 320;yres: 200;size:0;mode:_P16));
  MR_OAK=25;
  mrOAK:array[1..MR_OAK] of moderec    {Oak}
     =((md:  $4E;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $4F;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $50;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $51;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $52;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $53;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $54;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $55;xres:1024;yres: 768;size:0;mode:_PL2)
      ,(md:  $56;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $57;xres: 768;yres:1024;size:0;mode:_PL4)
      ,(md:  $58;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $59;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5B;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $5B;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $5C;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $5C;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $5D;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $5D;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $5E;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $61;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $63;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $64;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $69;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $6B;xres: 800;yres: 600;size:0;mode:_P32));
  MR_WD=34;
  mrWD:array[1..MR_WD] of moderec    {Paradise}
     =((md:  $41;xres:  80;yres:  34;size:0;mode:_TEXT)
      ,(md:  $47;xres: 132;yres:  28;size:0;mode:_TEXT)
      ,(md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $56;xres: 132;yres:  43;size:0;mode:_TXT4)
      ,(md:  $57;xres: 132;yres:  25;size:0;mode:_TXT4)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $59;xres: 800;yres: 600;size:0;mode:_PL1E)  {OLD MODELS}
      ,(md:  $5A;xres:1024;yres: 768;size:0;mode:_PL1E)  {OLD MODELS}
      ,(md:  $5B;xres:1024;yres: 768;size:0;mode:_PK2)   {OLD MODELS}
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5E;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $60;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $61;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $62;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $63;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $64;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $65;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $66;xres:  80;yres:  50;size:0;mode:_TEXT)
      ,(md:  $67;xres:  80;yres:  43;size:0;mode:_TEXT)
      ,(md:  $68;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $69;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $6C;xres:1280;yres: 960;size:0;mode:_PL4)
      ,(md:  $6D;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $6F;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $71;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $72;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $73;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $74;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $75;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $77;xres:1600;yres:1200;size:0;mode:_P8));
  MR_Zymos=6;
  mrZymos:array[1..MR_Zymos] of moderec    {Zymos Poach}
     =((md:  $60;xres: 960;yres: 720;size:0;mode:_PL4)
      ,(md:  $61;xres:1280;yres: 640;size:0;mode:_PL4)
      ,(md:  $62;xres: 512;yres: 512;size:0;mode:_P8)
      ,(md:  $63;xres: 720;yres: 540;size:0;mode:_PL4)
      ,(md:  $64;xres: 720;yres: 540;size:0;mode:_P8)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4));
  MR_Primus=35;
  mrPrimus:array[1..MR_Primus] of moderec    {Primus}
     =((md:  $1E;xres:  80;yres:  30;size:0;mode:_TEXT)
      ,(md:  $1F;xres:  80;yres:  43;size:0;mode:_TEXT)
      ,(md:  $20;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $21;xres: 100;yres:  75;size:0;mode:_TEXT)
      ,(md:  $24;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $25;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $26;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $27;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $28;xres: 512;yres: 512;size:0;mode:_PL4)
      ,(md:  $29;xres: 512;yres: 512;size:0;mode:_P8)
      ,(md:  $2A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $2B;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $2C;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $2D;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $2E;xres: 768;yres:1024;size:0;mode:_PL4)
      ,(md:  $2F;xres: 768;yres:1024;size:0;mode:_P8)
      ,(md:  $30;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $31;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $32;xres:1024;yres:1024;size:0;mode:_PL4)
      ,(md:  $33;xres:1024;yres:1024;size:0;mode:_P8)
      ,(md:  $34;xres:1152;yres: 900;size:0;mode:_PL4)
      ,(md:  $35;xres:1152;yres: 900;size:0;mode:_P8)
      ,(md:  $36;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $37;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $41;xres: 512;yres: 512;size:0;mode:_P15 )
      ,(md:  $42;xres: 640;yres: 350;size:0;mode:_P15)
      ,(md:  $43;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $44;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $45;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $41;xres: 512;yres: 512;size:0;mode:_P16 )
      ,(md:  $42;xres: 640;yres: 350;size:0;mode:_P16)
      ,(md:  $43;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $44;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $45;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $4A;xres: 640;yres: 480;size:0;mode:_P24));
  MR_Rtek=24;
  mrRtek:array[1..MR_Rtek] of moderec    {Realtek}
     =((md:  $18;xres:  80;yres:  30;size:0;mode:_TEXT)
      ,(md:  $19;xres:  80;yres:  43;size:0;mode:_TEXT)
      ,(md:  $1A;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $1B;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $1C;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $1D;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $1E;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $1F;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $20;xres: 960;yres: 720;size:0;mode:_PL4)
      ,(md:  $21;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $22;xres: 768;yres:1024;size:0;mode:_PL4)
      ,(md:  $23;xres:1024;yres: 768;size:0;mode:_PL2)
      ,(md:  $24;xres: 512;yres: 512;size:0;mode:_P8)
      ,(md:  $25;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $26;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $27;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $28;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $29;xres:1024;yres:1024;size:0;mode:_P8)
      ,(md:  $2A;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $38;xres: 320;yres: 200;size:0;mode:_P16 )
      ,(md:  $39;xres: 512;yres: 512;size:0;mode:_P16)
      ,(md:  $3A;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $3B;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $3C;xres: 800;yres: 600;size:0;mode:_P16));
  MR_V1000=47;
  mrV1000:array[1..MR_V1000] of moderec   {Rendition V1000}
     =((md:  $20;xres: 320;yres: 200;size:0;mode:_P8  )
      ,(md:  $21;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $22;xres: 384;yres: 288;size:0;mode:_P8)
      ,(md:  $23;xres: 400;yres: 300;size:0;mode:_P8)
      ,(md:  $24;xres: 512;yres: 384;size:0;mode:_P8)
      ,(md:  $25;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $26;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $27;xres: 720;yres: 480;size:0;mode:_P8)
      ,(md:  $28;xres: 768;yres: 576;size:0;mode:_P8)
      ,(md:  $29;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $2A;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $2B;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $2C;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $30;xres: 320;yres: 400;size:0;mode:_P15)
      ,(md:  $31;xres: 320;yres: 480;size:0;mode:_P15)
      ,(md:  $32;xres: 384;yres: 576;size:0;mode:_P15)
      ,(md:  $33;xres: 400;yres: 300;size:0;mode:_P15)
      ,(md:  $34;xres: 512;yres: 384;size:0;mode:_P15)
      ,(md:  $35;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $36;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $37;xres: 720;yres: 480;size:0;mode:_P15)
      ,(md:  $38;xres: 768;yres: 576;size:0;mode:_P15)
      ,(md:  $39;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $3A;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $3B;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md:  $40;xres: 320;yres: 400;size:0;mode:_P16)
      ,(md:  $41;xres: 320;yres: 480;size:0;mode:_P16)
      ,(md:  $42;xres: 384;yres: 576;size:0;mode:_P16)
      ,(md:  $43;xres: 400;yres: 300;size:0;mode:_P16)
      ,(md:  $44;xres: 512;yres: 384;size:0;mode:_P16)
      ,(md:  $45;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $46;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $47;xres: 720;yres: 480;size:0;mode:_P16)
      ,(md:  $48;xres: 768;yres: 576;size:0;mode:_P16)
      ,(md:  $49;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $4A;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $4B;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md:  $50;xres: 320;yres: 400;size:0;mode:_P32)
      ,(md:  $51;xres: 320;yres: 480;size:0;mode:_P32)
      ,(md:  $52;xres: 384;yres: 576;size:0;mode:_P32)
      ,(md:  $53;xres: 400;yres: 300;size:0;mode:_P32)
      ,(md:  $54;xres: 512;yres: 384;size:0;mode:_P32)
      ,(md:  $55;xres: 640;yres: 400;size:0;mode:_P32)
      ,(md:  $56;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $57;xres: 720;yres: 480;size:0;mode:_P32)
      ,(md:  $58;xres: 768;yres: 576;size:0;mode:_P32)
      ,(md:  $59;xres: 800;yres: 600;size:0;mode:_P32));
  MR_REND=61;
  mrREND:array[1..MR_REND] of moderec    {Rendition V2x00}
     =((md:  $20;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $21;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $23;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $25;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $27;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $2D;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $2E;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $2F;xres: 320;yres: 200;size:0;mode:_P32 )
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $31;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $32;xres: 640;yres: 480;size:0;mode:_P32 )
      ,(md:  $33;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $34;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $35;xres: 800;yres: 600;size:0;mode:_P32 )
      ,(md:  $36;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $37;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $38;xres:1024;yres: 768;size:0;mode:_P32 )
      ,(md:  $39;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $3A;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $3C;xres: 320;yres: 200;size:0;mode:_P8)
      ,(md:  $3D;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $3E;xres: 320;yres: 240;size:0;mode:_P15)
      ,(md:  $3F;xres: 320;yres: 240;size:0;mode:_P16 )
      ,(md:  $40;xres: 320;yres: 240;size:0;mode:_P32 )
      ,(md:  $41;xres: 384;yres: 288;size:0;mode:_P8)
      ,(md:  $42;xres: 384;yres: 288;size:0;mode:_P15)
      ,(md:  $43;xres: 384;yres: 288;size:0;mode:_P16)
      ,(md:  $44;xres: 384;yres: 288;size:0;mode:_P32 )
      ,(md:  $45;xres: 400;yres: 300;size:0;mode:_P8)
      ,(md:  $46;xres: 400;yres: 300;size:0;mode:_P15)
      ,(md:  $47;xres: 400;yres: 300;size:0;mode:_P16)
      ,(md:  $48;xres: 400;yres: 300;size:0;mode:_P32 )
      ,(md:  $49;xres: 512;yres: 384;size:0;mode:_P8)
      ,(md:  $4A;xres: 512;yres: 384;size:0;mode:_P15)
      ,(md:  $4B;xres: 512;yres: 384;size:0;mode:_P16)
      ,(md:  $4C;xres: 512;yres: 384;size:0;mode:_P32 )
      ,(md:  $4D;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $4E;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $4F;xres: 640;yres: 400;size:0;mode:_P32 )
      ,(md:  $50;xres: 720;yres: 400;size:0;mode:_P8)
      ,(md:  $51;xres: 720;yres: 400;size:0;mode:_P15)
      ,(md:  $52;xres: 720;yres: 400;size:0;mode:_P16)
      ,(md:  $53;xres: 720;yres: 400;size:0;mode:_P32 )
      ,(md:  $54;xres: 720;yres: 480;size:0;mode:_P8)
      ,(md:  $55;xres: 720;yres: 480;size:0;mode:_P15)
      ,(md:  $56;xres: 720;yres: 480;size:0;mode:_P16)
      ,(md:  $57;xres: 720;yres: 480;size:0;mode:_P32 )
      ,(md:  $58;xres: 768;yres: 576;size:0;mode:_P8)
      ,(md:  $59;xres: 768;yres: 576;size:0;mode:_P15)
      ,(md:  $5A;xres: 768;yres: 576;size:0;mode:_P16)
      ,(md:  $5B;xres: 768;yres: 576;size:0;mode:_P32 )
      ,(md:  $5C;xres: 856;yres: 480;size:0;mode:_P8)
      ,(md:  $5D;xres: 856;yres: 480;size:0;mode:_P15)
      ,(md:  $5E;xres: 856;yres: 480;size:0;mode:_P16)
      ,(md:  $5F;xres: 856;yres: 480;size:0;mode:_P32 )
      ,(md:  $60;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $61;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md:  $62;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md:  $64;xres:1280;yres: 960;size:0;mode:_P8)
      ,(md:  $65;xres:1280;yres: 960;size:0;mode:_P15)
      ,(md:  $66;xres:1280;yres: 960;size:0;mode:_P16));
  MR_S3=32;
  mrS3:array[1..MR_S3] of moderec    {S3}
     =((md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md: $101;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md: $102;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md: $103;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md: $104;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md: $105;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md: $206;xres:1280;yres: 960;size:1024;mode:_PK4a)
      ,(md: $208;xres:1280;yres:1024;size:1024;mode:_PK4a)
      ,(md: $211;xres: 640;yres: 480;size:2048;mode:_P16)
      ,(md: $212;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md: $301;xres: 640;yres: 480;size:2048;mode:_P15)
      ,(md: $301;xres: 640;yres: 480;size:2048;mode:_P16)
      ,(md: $106;xres:1280;yres:1024;size:0;mode:_Pl4)
      ,(md: $107;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md: $110;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md: $111;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md: $112;xres: 640;yres: 480;size:2048;mode:_P32)
      ,(md: $113;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md: $114;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md: $115;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md: $116;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md: $117;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md: $118;xres:1024;yres: 768;size:0;mode:_P32)
      ,(md: $119;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md: $11A;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md: $120;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md: $124;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md: $125;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md: $126;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md: $312;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md: $315;xres: 800;yres: 600;size:0;mode:_P24));
    {  ,(chp:__S3      ;md:  $45;mode:_P8  ;xres:1600;yres:1200;size:2048)}
  MR_Sig=28;
  mrSig:array[1..MR_Sig] of moderec    {Sigma Design}
     =((md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $56;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $5C;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $5D;xres:1152;yres: 864;size:0;mode:_p15)
      ,(md:  $5E;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $60;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $61;xres: 320;yres: 200;size:0;mode:_p15)
      ,(md:  $62;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $63;xres: 320;yres: 200;size:0;mode:_P24)
      ,(md:  $64;xres: 320;yres: 200;size:0;mode:_P32)
      ,(md:  $65;xres: 640;yres: 480;size:0;mode:_p15)
      ,(md:  $66;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $67;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $68;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $6B;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $6D;xres: 800;yres: 600;size:0;mode:_p15)
      ,(md:  $6E;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $70;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $71;xres:1024;yres: 768;size:0;mode:_p15)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $75;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $76;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $77;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $78;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $7D;xres:1600;yres:1200;size:0;mode:_PL4)
      ,(md:  $7E;xres:1600;yres:1200;size:0;mode:_P8));
  MR_SiS=30;
  mrSiS:array[1..MR_SiS] of moderec   {SiS SG86c201}
     =((md:  $22;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $23;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $24;xres: 132;yres:  28;size:0;mode:_TEXT)
      ,(md:  $26;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $29;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $2A;xres: 100;yres:  40;size:0;mode:_TEXT)
      ,(md:  $2D;xres: 640;yres: 350;size:0;mode:_P8)
      ,(md:  $2E;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $2F;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $30;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $37;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $38;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $39;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $3A;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $3B;xres:1600;yres:1200;size:0;mode:_PL4)
      ,(md:  $3C;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $40;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $41;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $42;xres: 320;yres: 200;size:0;mode:_P24)
      ,(md:  $43;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $44;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $45;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $46;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $47;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $48;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $49;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $4A;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $4B;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $4C;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $4D;xres:1280;yres:1024;size:0;mode:_P16));
  MR_Trid=42;
  mrTrid:array[1..MR_Trid] of moderec   {Trident}
     =((md:  $50;xres:  80;yres:  30;size:0;mode:_TEXT)
      ,(md:  $51;xres:  80;yres:  43;size:0;mode:_TEXT)
      ,(md:  $52;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $53;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $54;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $56;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $57;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $58;xres: 132;yres:  30;size:0;mode:_TEXT)
      ,(md:  $59;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $5A;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $5B;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $5C;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5D;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $5E;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5F;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $60;xres:1024;yres: 768;size:0;mode:_PL2)
      ,(md:  $61;xres: 768;yres:1024;size:0;mode:_PL4)
      ,(md:  $62;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $63;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $64;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $65;xres:1600;yres:1200;size:0;mode:_PL4)
      ,(md:  $66;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6B;xres: 320;yres: 200;size:0;mode:_P24)
      ,(md:  $6C;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $6D;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $6E;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $70;xres: 512;yres: 480;size:0;mode:_P15)
      ,(md:  $71;xres: 512;yres: 480;size:0;mode:_P16)
      ,(md:  $72;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $73;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $74;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $75;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $76;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $77;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $78;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $79;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $7A;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $7B;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $7E;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $7F;xres: 320;yres: 200;size:0;mode:_P16));
  MR_AGX=2;
  mrAGX:array[1..MR_AGX] of moderec   {IIT AGX}
     =((md:  $64;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $65;xres:1024;yres: 768;size:0;mode:_P8));
  MR_Tseng=46;
  mrTseng:array[1..MR_Tseng] of moderec   {Tseng}
     =((md:  $18;xres: 132;yres:  44;size:0;mode:_TXT4)
      ,(md:  $19;xres: 132;yres:  25;size:0;mode:_TXT4)
      ,(md:  $1A;xres: 132;yres:  28;size:0;mode:_TXT4)
      ,(md:  $22;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $23;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $24;xres: 132;yres:  28;size:0;mode:_TEXT)
      ,(md:  $25;xres: 640;yres: 480;size:0;mode:_PL4)
      ,(md:  $26;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $27;xres: 720;yres: 512;size:0;mode:_PL4)
      ,(md:  $29;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $2A;xres: 100;yres:  40;size:0;mode:_TEXT)
      ,(md:  $2D;xres: 640;yres: 350;size:0;mode:_P8)
      ,(md:  $2E;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $2F;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $30;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $36;xres: 960;yres: 720;size:0;mode:_PL4)
      ,(md:  $37;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $38;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $3B;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $3D;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $3E;xres:1280;yres: 960;size:0;mode:_PL4)
      ,(md: $53E;xres: 640;yres: 480;size:0;mode:_P24)        {Genoa 16M}
      ,(md:  $3F;xres:1280;yres:1024;size:0;mode:_P8)        {W32}
      ,(md:  $41;xres:1600;yres:1200;size:0;mode:_P8)        {W32}
      ,(md: $12E;xres: 640;yres: 480;size:2048;mode:_P24)     {SpeedStar 24}
      ,(md: $22D;xres: 640;yres: 350;size:2048;mode:_P24)
      ,(md: $22E;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md: $22F;xres: 640;yres: 400;size:2048;mode:_P24)
      ,(md: $230;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md: $238;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md: $313;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md: $32D;xres: 640;yres: 350;size:0;mode:_P15)
      ,(md: $32E;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md: $32F;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md: $330;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md: $338;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md: $33B;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md: $33F;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md: $413;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md: $42D;xres: 640;yres: 350;size:0;mode:_P16)
      ,(md: $42E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md: $42F;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md: $430;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md: $438;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md: $43B;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md: $43F;xres:1280;yres:1024;size:0;mode:_P16));
  MR_UMC=29;
  mrUMC:array[1..MR_UMC] of moderec   {UMC}
     =((md:  $46;xres: 132;yres:  25;size:0;mode:_TXT2)
      ,(md:  $47;xres: 132;yres:  29;size:0;mode:_TXT2)
      ,(md:  $48;xres: 132;yres:  32;size:0;mode:_TXT2)
      ,(md:  $49;xres: 132;yres:  44;size:0;mode:_TXT2)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $58;xres:  80;yres:  32;size:0;mode:_TEXT)
      ,(md:  $5C;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $5E;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5F;xres:1024;yres: 768;size:0;mode:_PL4 )
      ,(md:  $60;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $61;xres: 132;yres:  29;size:0;mode:_TEXT)
      ,(md:  $62;xres: 132;yres:  32;size:0;mode:_TEXT)
      ,(md:  $63;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $64;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6B;xres: 100;yres:  37;size:0;mode:_TEXT)
      ,(md:  $6C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $72;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $73;xres: 640;yres: 480;size:0;mode:_PL4)
      ,(md:  $74;xres:  80;yres:  66;size:0;mode:_TEXT)
      ,(md:  $78;xres: 100;yres:  37;size:0;mode:_TEXT)
      ,(md:  $79;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $7A;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $7D;xres: 512;yres: 512;size:0;mode:_P8)
      ,(md:  $7E;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $7F;xres:1024;yres: 768;size:0;mode:_P8));
  MR_Video7=18;
  mrVideo7:array[1..MR_Video7] of moderec   {Video7}
     =((md:  $40;xres:  80;yres:  43;size:0;mode:_TEXT)
      ,(md:  $41;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $42;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $43;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $44;xres: 100;yres:  60;size:0;mode:_TEXT)
      ,(md:  $45;xres: 132;yres:  28;size:0;mode:_TEXT)
      ,(md:  $60;xres: 752;yres: 410;size:0;mode:_PL4)
      ,(md:  $61;xres: 720;yres: 540;size:0;mode:_PL4)
      ,(md:  $62;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $63;xres:1024;yres: 768;size:0;mode:_PL1)
      ,(md:  $64;xres:1024;yres: 768;size:0;mode:_PL2)
      ,(md:  $65;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $66;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $67;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $68;xres: 720;yres: 540;size:0;mode:_P8)
      ,(md:  $69;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $6A;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $70;xres:1280;yres:1024;size:0;mode:_PL4));   {Only newer boards}
  MR_Weitek=22;
  mrWeitek:array[1..MR_Weitek] of moderec   {Weitek}
     =((md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $56;xres: 132;yres:  43;size:0;mode:_TXT4)
      ,(md:  $57;xres: 132;yres:  25;size:0;mode:_TXT4)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $59;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $5A;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5E;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $64;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $65;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $66;xres: 132;yres:  60;size:0;mode:_TXT4)
      ,(md:  $67;xres: 132;yres:  50;size:0;mode:_TXT4)
      ,(md:  $68;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $69;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6C;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $6D;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $6F;xres: 800;yres: 600;size:0;mode:_P16));
  MR_HMC=12;
  mrHMC:array[1..MR_HMC] of moderec   {HMC}
     =((md:  $20;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $21;xres: 132;yres:  44;size:0;mode:_TEXT)
      ,(md:  $22;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $28;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $29;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $2A;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $2B;xres: 640;yres: 200;size:0;mode:_P8)
      ,(md:  $2C;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $2D;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $2E;xres: 800;yres: 600;size:832;mode:_P8)
      ,(md:  $31;xres:1024;yres: 768;size:0;mode:_PL2)
      ,(md:  $32;xres:1024;yres: 768;size:0;mode:_PL2));
  MR_Mach32=20;
  mrM32:array[1..MR_Mach32] of moderec   {Mach32}
     =((md: $101;xres: 800;yres: 600;size:0;mode:_PK4B)
      ,(md: $111;xres:1280;yres:1024;size:0;mode:_PK4B)
      ,(md: $121;xres: 640;yres: 480;size:0;mode:_PK4B)
      ,(md: $141;xres:1024;yres: 768;size:0;mode:_PK4B)
      ,(md: $301;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md: $311;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md: $321;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md: $341;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md: $501;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md: $511;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md: $521;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md: $541;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md: $D01;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md: $D11;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md: $D21;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md: $D41;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md: $701;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md: $711;xres:1280;yres:1024;size:0;mode:_P24)
      ,(md: $721;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md: $741;xres:1024;yres: 768;size:0;mode:_P24));
  MR_Mach64=30;
  mrM64:array[1..MR_Mach64] of moderec   {Mach64}
     =((md:$1281;xres: 640;yres: 480;size:0;mode:_PK4B)
      ,(md:$6A81;xres: 800;yres: 600;size:0;mode:_PK4B)
      ,(md:$5591;xres:1024;yres: 768;size:0;mode:_PK4B)
      ,(md:$8381;xres:1280;yres:1024;size:0;mode:_PK4B)
      ,(md:$8481;xres:1600;yres:1200;size:0;mode:_PK4B)
      ,(md:$1292;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:$6A92;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:$5592;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:$8392;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:$8492;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:$1293;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:$6A93;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:$5593;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:$8393;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:$8493;xres:1600;yres:1200;size:0;mode:_P15)
      ,(md:$1294;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:$6A94;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:$5594;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:$8394;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:$8494;xres:1600;yres:1200;size:0;mode:_P16)
      ,(md:$1295;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:$6A95;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:$5595;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:$8395;xres:1280;yres:1024;size:0;mode:_P24)
      ,(md:$8495;xres:1600;yres:1200;size:0;mode:_P24)
      ,(md:$1296;xres: 640;yres: 480;size:0;mode:_P32b)
      ,(md:$6A96;xres: 800;yres: 600;size:0;mode:_P32b)
      ,(md:$5596;xres:1024;yres: 768;size:0;mode:_P32b)
      ,(md:$8396;xres:1280;yres:1024;size:0;mode:_P32b)
      ,(md:$8496;xres:1600;yres:1200;size:0;mode:_P32b));
  MR_MGA=9;
  mrMGA:array[1..MR_MGA] of moderec   {Matrox MGA}
     =((md:  $27;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $2A;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $33;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $34;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $38;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $3B;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $41;xres:  90;yres:  25;size:0;mode:_TEXT)
      ,(md:  $43;xres: 120;yres:  25;size:0;mode:_TEXT)
      ,(md:  $44;xres: 132;yres:  25;size:0;mode:_TEXT));
  MR_ARK=21;
  mrARK:array[1..MR_ARk] of moderec   {Matrox MGA}
     =((md:  $24;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $26;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $27;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $31;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $32;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $33;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $40;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $41;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $42;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $43;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $44;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $4F;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $52;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $54;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $55;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $56;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $58;xres: 640;yres: 480;size:0;mode:_P24)  {P32 for the 2000PV +}
      ,(md:  $59;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $5F;xres: 640;yres: 400;size:0;mode:_P24));
  MR_Acer=19;
  mrAcer:array[1..MR_Acer] of moderec   {Acer}
     =((md:  $51;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $52;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $54;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $56;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $57;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $59;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5A;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5B;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $5E;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $70;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $71;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $72;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md:  $73;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $74;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $75;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $76;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $77;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $72;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $75;xres: 800;yres: 600;size:0;mode:_P32));
  MR_SC=22;
  mrSC:array[1..MR_SC] of moderec   {Sierra}
     =((md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 321;yres:  25;size:0;mode:_TEXT)
      ,(md:  $58;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $59;xres:1600;yres:1200;size:0;mode:_PL4)
      ,(md:  $5A;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $5B;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5D;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $5E;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $60;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $69;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $6F;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $6F;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $70;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $71;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $71;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $73;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $75;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $75;xres:1280;yres:1024;size:0;mode:_P16));
  MR_IGS=27;
  mrIGS:array[1..MR_IGS] of moderec   {InteGraphics}
     =((md:  $30;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $31;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $32;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $33;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $34;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $43;xres:1280;yres:1024;size:0;mode:_PL4)
      ,(md:  $44;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $46;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $47;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $48;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $49;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $4A;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $52;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $53;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $54;xres:1600;yres:1200;size:0;mode:_P15)
      ,(md:  $50;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $51;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $52;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $53;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $54;xres:1600;yres:1200;size:0;mode:_P16)
      ,(md:  $55;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $56;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $57;xres:1024;yres: 768;size:0;mode:_P24)
      ,(md:  $58;xres:1280;yres:1024;size:0;mode:_P24)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4));
  MR_NM=12;
  mrNM:array[1..MR_NM] of moderec   {NeoMagic}
     =((md:  $20;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $21;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $22;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $23;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $24;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $25;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $29;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $2B;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $2D;xres: 320;yres: 200;size:0;mode:_P15)
      ,(md:  $2E;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $30;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $31;xres: 640;yres: 480;size:0;mode:_P16));
  MR_OPTi=26;
  mrOPTi:array[1..MR_OPTi] of moderec   {OPTi}
     =((md:  $22;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $23;xres: 132;yres:  25;size:0;mode:_TEXT)
      ,(md:  $24;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $25;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $26;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $30;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $31;xres:1024;yres: 768;size:0;mode:_PL4)
      ,(md:  $32;xres:1280;yres:1004;size:0;mode:_PL4)
      ,(md:  $33;xres:1600;yres:1200;size:0;mode:_PL4)
      ,(md:  $38;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $39;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $3A;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $3B;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $3C;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $3D;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $40;xres: 640;yres: 400;size:0;mode:_P15)
      ,(md:  $41;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $42;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $43;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $48;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $49;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $4A;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $4B;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $50;xres: 640;yres: 400;size:0;mode:_P24)
      ,(md:  $51;xres: 640;yres: 480;size:0;mode:_P24)
      ,(md:  $52;xres: 800;yres: 600;size:0;mode:_P24));
  MR_MPACT=10;
  mrMPACT:array[1..MR_MPACT] of moderec   {MPact}
     =((md:  $5B;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5E;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $69;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md:  $6B;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $70;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $71;xres: 800;yres: 600;size:0;mode:_P24)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P16));
  MR_3Dfx=33;
  mr3Dfx:array[1..MR_3Dfx] of moderec  {3Dfx Banshee}
     =((md:  $20;xres: 320;yres: 240;size:0;mode:_P8)
      ,(md:  $21;xres: 320;yres: 240;size:0;mode:_P16)
      ,(md:  $22;xres: 320;yres: 240;size:1024;mode:_P24)
      ,(md:  $23;xres: 400;yres: 300;size:0;mode:_P8)
      ,(md:  $24;xres: 400;yres: 300;size:0;mode:_P16)
      ,(md:  $25;xres: 400;yres: 300;size:2048;mode:_P24)
      ,(md:  $26;xres: 512;yres: 384;size:0;mode:_P8)
      ,(md:  $27;xres: 512;yres: 384;size:0;mode:_P16)
      ,(md:  $28;xres: 512;yres: 384;size:2048;mode:_P24)
      ,(md:  $29;xres: 640;yres: 400;size:0;mode:_P16)
      ,(md:  $2A;xres: 640;yres: 400;size:2048;mode:_P24)
      ,(md:  $54;xres: 132;yres:  43;size:0;mode:_TEXT)
      ,(md:  $55;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $5B;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $5C;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $5E;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $5F;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $64;xres: 132;yres:  60;size:0;mode:_TEXT)
      ,(md:  $65;xres: 132;yres:  50;size:0;mode:_TEXT)
      ,(md:  $68;xres:  80;yres:  60;size:0;mode:_TEXT)
      ,(md:  $69;xres: 640;yres: 480;size:2048;mode:_P24)
      ,(md:  $6A;xres: 800;yres: 600;size:0;mode:_PL4)
      ,(md:  $6B;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $6E;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $70;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $71;xres: 800;yres: 600;size:4096;mode:_P24)
      ,(md:  $72;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $73;xres:1024;yres: 768;size:4096;mode:_P24)
      ,(md:  $74;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $75;xres:1280;yres:1024;size:4096;mode:_P24)
      ,(md:  $78;xres: 320;yres: 200;size:0;mode:_P8)
      ,(md:  $79;xres: 320;yres: 200;size:0;mode:_P16)
      ,(md:  $7A;xres: 320;yres: 200;size:0;mode:_P24));
  MR_IMAG=25;
  mrIMAG:array[1..MR_IMAG] of moderec
     =((md:  $20;xres: 640;yres: 400;size:0;mode:_P8)
      ,(md:  $21;xres: 640;yres: 480;size:0;mode:_P8)
      ,(md:  $22;xres: 800;yres: 600;size:0;mode:_P8)
      ,(md:  $23;xres:1024;yres: 768;size:0;mode:_P8)
      ,(md:  $24;xres:1280;yres:1024;size:0;mode:_P8)
      ,(md:  $25;xres: 640;yres: 480;size:0;mode:_P15)
      ,(md:  $26;xres: 640;yres: 480;size:0;mode:_P16)
      ,(md:  $27;xres: 640;yres: 480;size:0;mode:_P32)
      ,(md:  $28;xres: 800;yres: 600;size:0;mode:_P15)
      ,(md:  $29;xres: 800;yres: 600;size:0;mode:_P16)
      ,(md:  $2A;xres: 800;yres: 600;size:0;mode:_P32)
      ,(md:  $2B;xres:1024;yres: 768;size:0;mode:_P15)
      ,(md:  $2C;xres:1024;yres: 768;size:0;mode:_P16)
      ,(md:  $2D;xres:1024;yres: 768;size:0;mode:_P32)
      ,(md:  $2E;xres:1280;yres:1024;size:0;mode:_P15)
      ,(md:  $2F;xres:1280;yres:1024;size:0;mode:_P16)
      ,(md:  $30;xres:1280;yres:1024;size:0;mode:_P32)
      ,(md:  $31;xres:1600;yres:1200;size:0;mode:_P8)
      ,(md:  $32;xres:1600;yres:1200;size:0;mode:_P15)
      ,(md:  $33;xres:1600;yres:1200;size:0;mode:_P16)
      ,(md:  $34;xres:1600;yres:1200;size:0;mode:_P32)
      ,(md:  $35;xres:1152;yres: 864;size:0;mode:_P8)
      ,(md:  $36;xres:1152;yres: 864;size:0;mode:_P15)
      ,(md:  $37;xres:1152;yres: 864;size:0;mode:_P16)
      ,(md:  $38;xres:1152;yres: 864;size:0;mode:_P32));


  MRESLISTS=51;
  mreslist:array[1..MRESLISTS] of
    record
      chp: byte;
      recs:byte;
      mr  :moderecp;
      vers:byte;
    end
    =((chp:__3DLabs ;recs:MR_3DLabs;mr:@mr3DLabs[1];vers:0)
     ,(chp:__Ahead  ;recs:MR_Ahead ;mr:@mrAhead[1];vers:0)
     ,(chp:__Alli   ;recs:MR_Alli  ;mr:@mrAlli[1];vers:0)
     ,(chp:__Alli   ;recs:MR_Al3210;mr:@mrAl3210[1];vers:lo(AS_3210))
     ,(chp:__ATI    ;recs:MR_Ati   ;mr:@mrAti[1];vers:0)
     ,(chp:__ALG    ;recs:MR_ALG   ;mr:@mrAlg[1];vers:0)
     ,(chp:__Chips  ;recs:MR_Chips ;mr:@mrChips[1];vers:0)
     ,(chp:__ctHiQ  ;recs:MR_CtHiQ ;mr:@mrCtHiQ[1];vers:0)
     ,(chp:__Cirrus ;recs:MR_Cir   ;mr:@mrCir[1];vers:0)
     ,(chp:__Cir54  ;recs:MR_Cir54 ;mr:@mrCir54[1];vers:0)
     ,(chp:__CirLAG ;recs:MR_CirLAG;mr:@mrCirLAG[1];vers:0)
     ,(chp:__Cir64  ;recs:MR_Cir64 ;mr:@mrCir64[1];vers:0)
     ,(chp:__Compaq ;recs:MR_Compaq;mr:@mrCompaq[1];vers:0)
     ,(chp:__Cyrix  ;recs:MR_Cyrix ;mr:@mrCyrix[1];vers:0)
     ,(chp:__Everex ;recs:MR_Everex;mr:@mrEverex[1];vers:0)
     ,(chp:__Genoa  ;recs:MR_Genoa ;mr:@mrGenoa[1];vers:0)
     ,(chp:__Intel  ;recs:MR_Intel ;mr:@mrIntel[1];vers:0)
     ,(chp:__MXIC   ;recs:MR_MXIC  ;mr:@mrMXIC[1];vers:0)
     ,(chp:__MX2    ;recs:MR_MXIC2 ;mr:@mrMXIC2[1];vers:0)
     ,(chp:__NCR    ;recs:MR_NCR   ;mr:@mrNCR[1];vers:0)
     ,(chp:__NV     ;recs:MR_NV1   ;mr:@mrNV1[1];vers:0)
     ,(chp:__NV2    ;recs:MR_NV3   ;mr:@mrNV3[1];vers:0)
     ,(chp:__OAK    ;recs:MR_OAK   ;mr:@mrOAK[1];vers:0)
     ,(chp:__WD     ;recs:MR_WD    ;mr:@mrWD[1];vers:0)
     ,(chp:__Poach  ;recs:MR_Zymos ;mr:@mrZymos[1];vers:0)
     ,(chp:__P2000  ;recs:MR_Primus;mr:@mrPrimus[1];vers:0)
     ,(chp:__Realtek;recs:MR_Rtek  ;mr:@mrRtek[1];vers:0)
     ,(chp:__Rend   ;recs:MR_REND  ;mr:@mrREND[1];vers:0)
     ,(chp:__Rend   ;recs:MR_V1000 ;mr:@mrV1000[1];vers:lo(RND_V1000))
     ,(chp:__S3     ;recs:MR_S3    ;mr:@mrS3[1];vers:0)
     ,(chp:__Sig    ;recs:MR_Sig   ;mr:@mrSig[1];vers:0)
     ,(chp:__SiS    ;recs:MR_SiS   ;mr:@mrSiS[1];vers:0)
     ,(chp:__Trid   ;recs:MR_Trid  ;mr:@mrTrid[1];vers:0)
     ,(chp:__AGX    ;recs:MR_AGX   ;mr:@mrAGX[1];vers:0)
     ,(chp:__Tseng  ;recs:MR_Tseng ;mr:@mrTseng[1];vers:0)
     ,(chp:__UMC    ;recs:MR_UMC   ;mr:@mrUMC[1];vers:0)
     ,(chp:__Video7 ;recs:MR_Video7;mr:@mrUMC[1];vers:0)
     ,(chp:__Weitek ;recs:MR_Weitek;mr:@mrWeitek[1];vers:0)
     ,(chp:__HMC    ;recs:MR_HMC   ;mr:@mrHMC[1];vers:0)
     ,(chp:__Mach32 ;recs:MR_Mach32;mr:@mrM32[1];vers:0)
     ,(chp:__Mach64 ;recs:MR_Mach64;mr:@mrM64[1];vers:0)
     ,(chp:__Matrox ;recs:MR_MGA   ;mr:@mrMGA[1];vers:0)
     ,(chp:__ARK    ;recs:MR_ARK   ;mr:@mrARK[1];vers:0)
     ,(chp:__Acer   ;recs:MR_Acer  ;mr:@mrAcer[1];vers:0)
     ,(chp:__SC     ;recs:MR_SC    ;mr:@mrSC[1];vers:0)
     ,(chp:__IGS    ;recs:MR_IGS   ;mr:@mrIGS[1];vers:0)
     ,(chp:__NM     ;recs:MR_NM    ;mr:@mrNM[1];vers:0)
     ,(chp:__OPTi   ;recs:MR_OPTi  ;mr:@mrOPTi[1];vers:0)
     ,(chp:__3Dfx   ;recs:MR_3Dfx  ;mr:@mr3Dfx[1];vers:0)
     ,(chp:__MPact  ;recs:MR_MPact ;mr:@mrMPACT[1];vers:0)
     ,(chp:__IMAG   ;recs:MR_IMAG  ;mr:@mrIMAG[1];vers:0));



 (* NBRMODES=1021;
  MODELIST:array[1..NBRMODES] of
    record
      chp :byte;
      md  :word;
      mode:byte;
      xres:integer;
      yres:integer;
      size:integer;
    end *)





















function DACflags:word;
var flag:word;
begin
  flag:=0;
  case cv.dactype of
  _dac0,_dac8,_dacCEG:;

  _dacInt:;
  _dac15,_dac16,_dacADAC1,_dacSC486,_dacUMC188:
       flag:=DFL_CmdReg;

  _dacALG1101:;
  _dacALG1201,_dacALG1301:
       flag:=DFL_CmdReg;

  _dacATI68860,_dacATI68880:
       flag:=DFL_8bit;

  _dacATT490,_dacATT491:
       flag:=DFL_CmdReg+DFL_8bit;
  _dacATT492,_dacATT493:
       flag:=DFL_CmdReg;
  _dacATT498,_dacATT1498,_dacATT2498:
       flag:=DFL_CmdReg+DFL_8bit;

  _dacBt477:
       flag:=DFL_8bit;
  _dacBt481,_dacBt482:
       flag:=DFL_CmdReg+DFL_8bit+DFL_cursor;
  _dacBt484,_dacBt485,_dacATT504,_dacATT505:
       flag:=DFL_8bit+DFL_cursor;

  _dacCH8391,
  _dacCH8398:
       flag:=DFL_CmdReg+DFL_8bit+DFL_Clock;

  _dacCL5200:
       flag:=DFL_CmdReg;

 _dacIBM514,_dacIBM524,_dacIBM525,_dacIBM526,
 _dacIBM528,_dacIBM530,_dacIBM561,_dacIBM624:
       flag:=DFL_cursor+DFL_8bit+DFL_Clock;

  _dacICS5301:
       flag:=DFL_CmdReg;

  _dacICW498,_dacICW516:
       flag:=DFL_CmdReg+DFL_8bit;

  _dacMU1880,_dacMU4870:
       flag:=DFL_CmdReg;
  _dacMU4910:
       flag:=DFL_CmdReg+DFL_8bit;
  _dacMU9910:
       flag:=DFL_CmdReg+DFL_8bit+DFL_Clock;

  _dacS3_716,_dacS3_708:
       flag:=DFL_CmdReg+DFL_8bit+DFL_Clock;
  _dacSC15021,_dacSC15025:
       flag:=DFL_CmdReg+DFL_8bit;
  _dacSTG1700,_dacSTG1702:
       flag:=DFL_CmdReg+DFL_8bit;
  _dacSTG1703:
       flag:=DFL_CmdReg+DFL_8bit+DFL_Clock;
  _dacSTG1732,_dacSTG1764:
       flag:=DFL_8bit+DFL_Clock+DFL_Cursor;

  _dacTLC34075,_dacTLC34076:
       flag:=DFL_8bit;    {8bit DACs from input pin}
  _dacTR8001:
       flag:=DFL_CmdReg+DFL_8bit;
  _dacTVP3010,_dacTVP3020:
       flag:=DFL_8bit+DFL_Cursor;
  _dacTVP3025,_dacTVP3026,_dacTVP3030:
       flag:=DFL_8bit+DFL_Cursor+DFL_Clock;
  end;
  DACflags:=flag;
end;

procedure loadmodes;              {Load extended modes for this chip}
var
  t:text;
  s,pat:string;
  mrp:modearrp;
  md,x,y,xres,yres,err,mreq,byt:word;
  vbe0:_vbe0;
  vbe1:_vbe1;
  xbe1:_xbe1;
  xbe2:_xbe2;
  ok:boolean;

function VESAmemmode(model,bits,redinf,grninf,bluinf,resinf:word):integer;
const
  mode6s=8;
  mode:array[1..mode6s] of byte=(
       _p15,_p16,_p24 ,_p24b,_p32 ,_p32b,_p32c,_p32d);
  blui:array[1..mode6s] of word =(
          5,   5,    8,$1008,    8,$1008, $808,$1808);
  grni:array[1..mode6s] of word =(
       $505,$506, $808, $808, $808, $808,$1008,$1008);
  redi:array[1..mode6s] of word =(
       $A05,$B05,$1008,    8,$1008,    8,$1808, $808);
  resi:array[1..mode6s] of word =(
       $F01,   0,    0,    0,$1808,$1808,    8,    8);
var x:word;
begin
  VESAmemmode:=_text;  {catch weird modes}
  if (bits=16) and (resinf=0) and (redinf=$A05) then
    resinf:=$F01;       {OPTi blew it too..}
  if (bits=15) and (resinf=0)  then resinf:=$F01;   {Bloody ATI Vesa driver @#$}
  if (bits=16) and (resinf=$E01) then
  begin
    resinf:=$F01;   {Bloody SiS Vesa driver @#$}
    bits:=15;
  end;
  if (bits=15) and (bluinf=5) and (grninf=$405) then grninf:=$505;
                                                   {@#$ Mach64 VESA driver}
  case model of
    0:VESAmemmode:=_text;
    1:case bits of
        1:VESAmemmode:=_cga1;
        2:VESAmemmode:=_cga2;
      end;
    2:VESAmemmode:=_herc;
    3:case bits of
        2:VESAmemmode:=_pl2;
        4:VESAmemmode:=_pl4;
      end;
    4:case bits of
        4:VESAmemmode:=_pk4;
        8:VESAmemmode:=_p8;
       15:VESAmemmode:=_p15;
       16:VESAmemmode:=_p16;
       24:VESAmemmode:=_p24;
       32:VESAmemmode:=_p32;
      end;
    5:; {YUV coding}
    6:begin
        if (bits=15) and (resinf>$F01) then resinf:=$f01;
        if (bits=16) and (resinf>0) then bits:=15;
        if bits=16 then resinf:=0;
        if (bits=32) and (resinf=0) then resinf:=$1808;
        for x:=1 to mode6s do
          if (redinf=redi[x]) and (grninf=grni[x]) and (bluinf=blui[x])
            and (resinf=resi[x]) then VESAmemmode:=mode[x];
      end;
    7:;
  end;
end;


procedure addmode(md,xres,yres,bytes:word;memmode:integer);
begin
  inc(nomodes);
  modetbl[nomodes].md     :=md;
  modetbl[nomodes].xres   :=xres;
  modetbl[nomodes].yres   :=yres;
  modetbl[nomodes].bytes  :=bytes;
  modetbl[nomodes].memmode:=memmode;
  modetbl[nomodes].flags  :=MFL_enabled;
  if memmode>=_PL4 then
    modetbl[nomodes].flags:=modetbl[nomodes].flags OR MFL_graphics;
end;

procedure loadVESAmodes(txt:boolean);
var x:integer;
begin
  vbe0.sign:=$41534556;    (* VESA *)
  viop($4F00,0,0,0,@vbe0);

     {S3 VESA driver can return wrong segment if run with QEMM}
  IF seg(vbe0.model^)=$E000 then
    vbe0.model:=ptr($C000,ofs(vbe0.model^));
  x:=1;
  while vbe0.model^[x]<>$FFFF do
  begin
    vesamodeinfo(vbe0.model^[x],vbe1);
    if (vbe1.attr and 1)<>0  then
    begin
      memmode:=VESAmemmode(vbe1.model,vbe1.bits,vbe1.redinf
         ,vbe1.grninf,vbe1.bluinf,vbe1.resinf);
      if txt or (memmode>_TEXT) then
        addmode(vbe0.model^[x],vbe1.width,vbe1.height,vbe1.bytes,memmode);
    end;
    inc(x);
  end;
end;


begin
  nomodes:=0;

  if (cv.flags and FLG_StdVGA)>0 then
  begin
    move(stdmodetbl,modetbl,novgamodes*sizeof(modetype));
    nomodes:=novgamodes;
  end;

  case cv.chip of
    __MGA:loadVESAmodes(false);
     __s3,
   __vesa:loadVESAmodes(true);
         (*begin
            vbe0.sign:=$41534556;    { VESA }
            viop($4F00,0,0,0,@vbe0);

               {S3 VESA driver can return wrong segment if run with QEMM}
            IF seg(vbe0.model^)=$E000 then
              vbe0.model:=ptr($C000,ofs(vbe0.model^));
            x:=1;
            while vbe0.model^[x]<>$FFFF do
            begin
              vesamodeinfo(vbe0.model^[x],vbe1);
              if (vbe1.attr and 1)<>0 then
              begin
                memmode:=VESAmemmode(vbe1.model,vbe1.bits,vbe1.redinf
                   ,vbe1.grninf,vbe1.bluinf,vbe1.resinf);
                addmode(vbe0.model^[x],vbe1.width,vbe1.height,vbe1.bytes,memmode);
              end;
              inc(x);
            end;
          end;*)
    __xbe:begin
            viop($4E01,0,0,cv.id,@xbe1);
            x:=1;
            while xbe1.modep^[x]<>$FFFF do
            begin
              viop($4E02,0,xbe1.modep^[x],cv.id,@xbe2);
              if (rp.ax=$4E) and ((xbe2.attrib and 1)>0) then
              begin
                memmode:=VESAmemmode(xbe2.model,xbe2.bits,xbe2.redinf
                   ,xbe2.grninf,xbe2.bluinf,xbe2.resinf);
                if xbe2.bits=4 then memmode:=_pk4;
                addmode(xbe1.modep^[x],xbe2.pixels,xbe2.lins,xbe2.bytes,memmode);
              end;
              inc(x);
            end;

          end;
  else {case}
    x:=0;
    for y:=1 to MRESLISTS do
      if (mreslist[y].chp=cv.chip) and ((mreslist[y].vers=0)
       or (mreslist[y].vers=lo(cv.version))) then x:=y;
    mrp:=modearrp(mreslist[x].mr);
    y:=mreslist[x].recs;

    if x>0 then
    for x:=1 to y do
    begin
      ok:=true;
      md     :=mrp^[x].md;
      memmode:=mrp^[x].mode;
      xres   :=mrp^[x].xres;
      yres   :=mrp^[x].yres;
      planes:=1;
      if memmode=_pl4 then
      begin
        bytes:=xres shr 3;
        planes:=4;
      end;

      case cv.dactype of
        _dacCEG,
          _dac8:if memmode>_p8 then ok:=false;
         _dac15:if memmode>_p15 then ok:=false;
         _dac16,_dacMU4870:
                if memmode>_p16 then ok:=false;
    _dacALG1101:if (memmode=_p15) or (memmode>_p16) then ok:=false;
      end;
      case cv.chip of
       __ALG:if (md=$48) and (cv.Version=ALG_2228) then bytes:=2048;
       __ARK:if (memmode=_P24) and (cv.Version>=ARK_2000PV) then
             begin
               memmode:=_P32;
               bytes:=xres*4;
             end;
       __ATI:begin
               if (md<$100) and (cv.Version<ATI_M64_GX) then
               begin
                 rp.bx:=$5506;
                 rp.bp:=$FFFF;
                 rp.si:=0;
                 vio($1200+md);
                 if rp.bp=$FFFF then ok:=false;
               end;
                     {The VGA chip can't handle the ATI dac yet}
               if (cv.dactype=_dacATI68860) and (memmode>_P8) then ok:=false;
             end;
    __Compaq:if (cv.Version<CPQ_QV) and (md>$2E) then ok:=false;
     __Cir54:if (cv.Version<CL_GD5430) and ((memmode=_p32) or (xres>1280)) then ok:=false;
    __Mach64:if (memmode=_P32b) then memmode:=_P32;
        __S3:if (cv.version<=S3_924) then
             begin
               if ((md>$105) and (md<$200)) or (md=$212) or (md=$211) then ok:=false;
             end
             else begin
               if (md>$210) and (cv.version<S3_325) then ok:=false;
               if (cv.version=S3_928) and (memmode=_PK4a) then ok:=false;
               if ((cv.version=S3_988) or (cv.version<S3_928))
                 and (memmode=_p32) then memmode:=_p24;
             end;
      __Trid:begin
               if (cv.version>=TR_GUI9660) and (cv.version<TR_GUI9685)
                and (memmode=_P24) then  memmode:=_P32;
               if cv.version=TR_IITAGX then
                 if (md>=$60) then ok:=false;
             end;
     __Tseng:case cv.version of
               ET_3000:if md=$2F then ok:=false;
               ET_4000:case cv.subvers of
                         TS_SpeedStar:if (hi(md)=2) or (md=$53E) then ok:=false;
                         TS_Genoa7900:if (hi(md)=1) or (hi(md)=2) then ok:=false;
                       else
                         if (md=$53E) or (hi(md)=1) then ok:=false;
                       end;
             else if (md=$53E) or (hi(md)=1) then ok:=false;
             end;
      end;
      if memmode<_herc then bytes:=xres*2
          else bytes:=(xres*rowbits[memmode]) shr 3;
      byt  :=mrp^[x].size;
      if (byt>0) then bytes:=byt;
      mreq:=(longint(bytes*planes)*yres+1023) div 1024;
      if ok and (cv.mm>=mreq) then
        addmode(md,xres,yres,bytes,memmode);
    end;
    for x:=1 to noumodes do  {User overrides (.CFG)}
      if usermodes[x].flags=cv.chip then
        if usermodes[x].memmode=__None then
        begin
          for xres:=1 to nomodes do
            if modetbl[xres].md=usermodes[x].md then
              modetbl[xres].flags:=0;    {Disable}
        end
        else addmode(usermodes[x].md,usermodes[x].xres,usermodes[x].yres
                    ,usermodes[x].bytes,usermodes[x].memmode);
  end;
end;



procedure findPCI(flag:word);
const ROMs:array[0..3] of string[4]=(' 32K',' 64K','128K','256K');
  YesNo:array[boolean] of string[4]=('No ','Yes');
var
  i,j,z,x,max:word;
  hdr:byte;
  PCIid:longint;
  mb,tmp:longint;
  PCIval:array[1..512] of longint;
  PCIvals:integer;
  s:string;

label ENDE;

function wrPCIbase(base:longint):string;
begin
  if base=0 then wrPCIbase:=''
  else if (base and 1)>0 then wrPCIbase:=' i'+hex4(base and $FF00)
  else wrPCIbase:=' '+hex8(base and $FFFFFF00);
end;

procedure mkPCIbase(txt:string;inx,bs:integer);
var str:string;
  l,base:longint;
begin
  cv.PCIid:=inx;  {Hack for r/wPCI}
  base:=PCIrec[inx].l[bs+4];
  inx:=PCIrec[inx].PCIbase;
  bs:=bs*4+16;

  wPCIlong(bs,base xor $FFFFFFF0);
  l:=rPCIlong(bs);
  wPCIlong(bs,base);
  l:=(l xor base) and $FFFFFFF0;  {Writable bits (top) are 1, R/O (low) 0}
  bs:=32;
  while (l<>0) do
  begin
    l:=l shl 1;
    dec(bs);
  end;

  str:='      '+txt+': '+hex8(base)+'  at ';
  if (base and 1)>0 then
       str:=str+'I/O: '+hex4(base and $FF00)+'h ( -'+istr(bs)+')'
  else str:=str+'Mem: '+hex8(base and $FFFFFF00)+'h ('+istr(base shr 20)+'M -'+istr(bs)+')';
  if (base and 8)>0 then str:=str+' Cachable';
  wrlog(LOG_Crit,str);
  writeln(str);
end;

begin
  PCItype:=0;mb:=0;
  outp($CF8,0);
  outp($CFA,0);
  if (flag<>PCI_type2) and (inp($CF8)=0) and (inp($CFA)=0) then PCItype:=2
  else if flag<>PCI_type1 then
  begin
    tmp:=inplong($CF8);
    for i:=1 to 10 do;  {delay}
    outplong($CF8,$80000000);
    for i:=1 to 10 do;
    if inplong($CF8)=$80000000 then PCItype:=1;
    for i:=1 to 10 do;
    outplong($CF8,tmp);
  end;
  PCIvals:=0;
  writeln('Bus  Device:  In  Stat   Memory:');
  if PCItype>0 then
  begin
    wrlog(LOG_Crit,'PCI bus type '+istr(PCItype));
    case PCItype of
      1:begin   {PCI type 1}
          i:=0;max:=4096;
          while i<max do
          begin
            outplong($CF8,$80000000+i*longint(256));
            tmp:=inplong($CFC);
            wrlog(LOG_Crit,'PCI test #'+istr(i)+': '+hex8(tmp));
            if (word(tmp)<>$FFFF) and ((tmp shr 16)<>$FFFF) then
            begin
              inc(PCIvals);
              PCIval[PCIvals]:=tmp;
              inc(PCIdevs);
              PCIrec[PCIdevs].PCIbase:=i;
              PCIrec[PCIdevs].l[0]:=tmp;
              for j:=1 to 63 do
              begin
                outplong($CF8,$80000000+i*longint(256)+j*4);
                PCIrec[PCIdevs].l[j]:=inplong($CFC);
              end;
              hdr:=PCIrec[PCIdevs].b[$E];  {SAVE header field}
              s:=copy(hex4(i),2,3)+' '+hex4(PCIrec[PCIdevs].vendor)+' '
                 +hex4(PCIrec[PCIdevs].device)
                 +' '+hex4(PCIrec[PCIdevs].w[$1e])+' '+hex8(PCIrec[PCIdevs].l[2])+' ';
              if (PCIrec[PCIdevs].status and 32)>0 then s:=s+'6' else s:=s+'3'; {66 vs 33MHz}
              if (PCIrec[PCIdevs].command and 1)>0 then s:=s+'I' else s:=s+'i'; {IO access}
              if (PCIrec[PCIdevs].command and 2)>0 then s:=s+'M' else s:=s+'m'; {Mem access}
              if (PCIrec[PCIdevs].command and 4)>0 then s:=s+'B' else s:=s+'b'; {Bus Master}
              s:=s+wrPCIbase(PCIrec[PCIdevs].base0)+wrPCIbase(PCIrec[PCIdevs].base1)
                  +wrPCIbase(PCIrec[PCIdevs].base2)+wrPCIbase(PCIrec[PCIdevs].base3)
                  +wrPCIbase(PCIrec[PCIdevs].base4)+wrPCIbase(PCIrec[PCIdevs].base5);
              writeln(s);
              if (PCIrec[PCIdevs].status and $10)<>0 then
              begin
                s:='';
                z:=PCIrec[PCIdevs].capab;
                while z<>0 do
                begin
                  j:=PCIrec[PCIdevs].b[z];
                  x:=PCIrec[PCIdevs].b[z+2];
                  if j=2 then
                  begin
                    s:=s+' AGP v'+istr(x shr 4)+'.'+istr(x and 15);
                    if (PCIrec[PCIdevs].b[z+9] and 1)>0 then s:=s+' Enabled';
                    s:=s+' 1x:';
                    if (PCIrec[PCIdevs].b[z+4] and 1)>0 then s:=s+'S';
                    if (PCIrec[PCIdevs].b[z+8] and 1)>0 then s:=s+'E';
                    s:=s+' 2x:';
                    if (PCIrec[PCIdevs].b[z+4] and 2)>0 then s:=s+'S';
                    if (PCIrec[PCIdevs].b[z+8] and 2)>0 then s:=s+'E';
                    s:=s+' Sband:';
                    if (PCIrec[PCIdevs].b[z+5] and 2)>0 then s:=s+'S';
                    if (PCIrec[PCIdevs].b[z+9] and 2)>0 then s:=s+'E';
                  end
                  else s:=s+' Cap'+hex2(j)+' v'+istr(x shr 4)+'.'+istr(x and 15);
                  z:=PCIrec[PCIdevs].b[z+1];
                end;
                if s<>'' then writeln(s);
              end;
              case PCIrec[PCIdevs].class of
                $600:begin                {Host Bridge chipset}
                       MB:=PCIrec[PCIdevs].l[0];
                       dec(PCIdevs);
                       if mb=$88811060 then max:=384;   {UMC 8881/6}
                       if mb=$06001080 then max:=1024;  {CONTAQ 82c595}
                       if mb=$00011078 then max:=256;   {Cyrix MediaGX}
                     end;
              1,$300,$301,$380:;  {VGA & 8514/A etc}
              else dec(PCIdevs);
              end;
            end;
            if (hdr<128) or ((i and 7)=7) then i:=(i+8) and $FFF8
                                          else inc(i);
          end;
        end;
      2:begin   {PCI type 2}
          outp($CF8,$80);
          outp($CFA,0);   {Bus select?}
          for i:=0 to 15 do
          begin
            tmp:=inplong($C000+i*256);
            wrlog(LOG_Crit,'PCI test #'+istr(i)+': '+hex8(tmp));
            if (word(tmp)<>$FFFF) and ((tmp shr 16)<>$FFFF) then
            begin
              inc(PCIdevs);
              PCIrec[PCIdevs].PCIbase:=i;
              PCIrec[PCIdevs].l[0]:=tmp;
              for j:=1 to 63 do PCIrec[PCIdevs].l[j]:=inplong($C000+i*256+j*4);
              case PCIrec[PCIdevs].class of
                $600:begin
                       MB:=PCIrec[PCIdevs].l[0];
                       dec(PCIdevs);
                     end;
              1,$300:;  {VGA & 8514/A}
              else dec(PCIdevs);
              end;
            end;
          end;
          outp($CF8,0);
        end;
    end;
ENDE:
  {  SetTextMode;}
    s:='PCI bus type '+istr(PCItype)+' MB: '+hex4(mb)+':'+hex4(mb shr 16)+' Devices:';
    wrlog(LOG_Crit,s);
    writeln(s);
    if PCIdevs>0 then
    begin
      for i:=1 to PCIdevs do
      begin
        wrlog(LOG_Crit,'  Vendor: '+hex4(PCIrec[i].vendor)+'  Device: '
               +hex4(PCIrec[i].device)+'.'+hex2(PCIrec[PCIdevs].b[8])
               +'  Cmd: '+hex4(PCIrec[i].command)+' Stat: '+hex4(PCIrec[i].status));
        writeln('  Vendor: '+hex4(PCIrec[i].vendor)+'  Device: '+hex4(PCIrec[i].device)
               +'.'+hex2(PCIrec[i].b[8])+'  Cmd: '+hex4(PCIrec[i].command)
               +' Stat: '+hex4(PCIrec[i].status));
        if PCIrec[i].base0<>0 then mkPCIbase('Base0',i,0);
        if PCIrec[i].base1<>0 then mkPCIbase('Base1',i,1);
        if PCIrec[i].base2<>0 then mkPCIbase('Base2',i,2);
        if PCIrec[i].base3<>0 then mkPCIbase('Base3',i,3);
        if PCIrec[i].base4<>0 then mkPCIbase('Base4',i,4);
        if PCIrec[i].base5<>0 then mkPCIbase('Base5',i,5);
        if PCIrec[i].rom<>0   then mkPCIbase('ROM  ',i,8);

        writeln;
      end;
    end;
    if readkey='' then;
  end;
end;


 {Checks for a PCI card with ID=sign, returns index in PCIrec, 0 if not found
  START is the }
function CheckPCI(start,vendor,device:word):integer;
var i:integer;
begin
  i:=start;
  repeat inc(i);
  until (i>PCIdevs) or ((PCIrec[i].vendor=vendor) and ((PCIrec[i].command and 3)<>0)
      and ((PCIrec[i].device=device) or (device=$FFFF)));
  if i<=PCidevs then CheckPCI:=i
                else CheckPCI:=0;  {Default: None found}
end;

procedure wPCIbyte(index,val:word);
begin
  case PCItype of
    1:begin
        outplong($CF8,$80000000+PCIrec[cv.PCIid].PCIbase*longint(256)+index);
        outp($CFC,val);
      end;
    2:begin
        outp($CF8,$80);
        outp($CFA,0);   {Bus select?}
        outp($C000+PCIrec[cv.PCIid].PCIbase*256+index,val);
        outp($CF8,0);
      end;
  end;
end;

procedure wPCIword(index,val:word);
begin
  case PCItype of
    1:begin
        outplong($CF8,$80000000+PCIrec[cv.PCIid].PCIbase*longint(256)+index);
        outpw($CFC,val);
      end;
    2:begin
        outp($CF8,$80);
        outp($CFA,0);   {Bus select?}
        outpw($C000+PCIrec[cv.PCIid].PCIbase*256+index,val);
        outp($CF8,0);
      end;
  end;
end;

procedure wPCIlong(index:word;val:longint);
begin
  case PCItype of
    1:begin
        outplong($CF8,$80000000+PCIrec[cv.PCIid].PCIbase*longint(256)+index);
        outpl($CFC,val);
      end;
    2:begin
        outp($CF8,$80);
        outp($CFA,0);   {Bus select?}
        outpl($C000+PCIrec[cv.PCIid].PCIbase*256+index,val);
        outp($CF8,0);
      end;
  end;
end;

function rPCIbyte(index:word):word;
begin
  case PCItype of
    1:begin
        outplong($CF8,$80000000+PCIrec[cv.PCIid].PCIbase*longint(256)+index);
        rPCIbyte:=inp($CFC);
      end;
    2:begin
        outp($CF8,$80);
        outp($CFA,0);   {Bus select?}
        rPCIbyte:=inp($C000+PCIrec[cv.PCIid].PCIbase*256+index);
        outp($CF8,0);
      end;
  end;
end;

function rPCIword(index:word):word;
begin
  case PCItype of
    1:begin
        outplong($CF8,$80000000+PCIrec[cv.PCIid].PCIbase*longint(256)+index);
        rPCIword:=inpw($CFC);
      end;
    2:begin
        outp($CF8,$80);
        outp($CFA,0);   {Bus select?}
        rPCIword:=inpw($C000+PCIrec[cv.PCIid].PCIbase*256+index);
        outp($CF8,0);
      end;
  end;
end;

function rPCIlong(index:word):longint;
begin
  case PCItype of
    1:begin
        outplong($CF8,$80000000+PCIrec[cv.PCIid].PCIbase*longint(256)+index);
        rPCIlong:=inpl($CFC);
      end;
    2:begin
        outp($CF8,$80);
        outp($CFA,0);   {Bus select?}
        rPCIlong:=inpl($C000+PCIrec[cv.PCIid].PCIbase*256+index);
        outp($CF8,0);
      end;
  end;
end;




    (* Analyse the current mode *)

var
  oldreg:boolean;

procedure DumpRegisters;

function inxmask(base,mask:word):word;
var ix:word;
begin
  outp(base,0);
  ix:=inp(base) xor mask;
  outp(base,mask);
  inxmask:=ix and inp(base);
end;

procedure dumprg(base,start,ende:word;var rg:regblk);
var six,ix:word;
  same:boolean;
begin
  rg.base:=base;
  {six:=inp(base);
  outp(base,0);
  ix:=inp(base) xor 255;
  outp(base,255);
  ix:=ix and inp(base);}
  ix:=inxmask(base,255);
  if ix=0 then ix:=inxmask(base,127);
  if ix=0 then ix:=inxmask(base,63);
  if ix=0 then ix:=inxmask(base,31);
  if ix=0 then ix:=inxmask(base,15);

  if ende=0 then
    if ix>127 then ende:=255
    else if ix>63 then ende:=127
    else if ix>31 then ende:=63
    else if ix>15 then ende:=31
    else if ix>7 then ende:=15
    else ende:=7;
  if (base=CRTC) and (ende<31) then ende:=31;
  for ix:=start to ende do
    rg.x[ix]:=rdinx(base,ix);
  rg.nbr:=ende;
  outp(base,six);
  same:=true;
  while (rg.nbr>7) and same do    {Check for doubles}
  begin
    six:=succ(rg.nbr) div 2;
    for ix:=0 to six-1 do
      if rg.x[ix]<>rg.x[ix+six] then same:=false;
    if same then rg.nbr:=rg.nbr div 2;
  end;

end;

procedure DumpTridOldRegs;
begin
  wrinx(SEQ,$B,0);
  rgs.tridold0d:=rdinx(SEQ,$D);
  rgs.tridold0e:=rdinx(SEQ,$E);
  if rdinx(SEQ,$B)=0 then;  {New mode}
  oldreg:=true;
end;



procedure DumpXGAregs;
var x:word;
begin
  dumprg(cv.IOadr+10,0,0,rgs.xxregs);
  for x:=0 to 15 do
    rgs.xgaregs[x]:=inp(cv.IOadr+x);
end;
const
  WDbnk:array[1..17] of byte=
      (0,$16,$30,$31,$32,$33,2,3, 4, 5,7,9,$11,$14,$15,$17,$38);
  WDinx:array[1..17] of byte=
      (16, 8, 16,  5, 10, 11,2,6,12,13,3,6, 12,  3, 15,  6, 14);
var x,y,z,m:word;
  cheat:boolean;
  l,l2:longint;
begin
  if (cv.chip=__VESA) and (VESAcheat<>0) then
  begin
    cv:=vid[VESAcheat];
    cheat:=true;
  end
  else cheat:=false;
  case cv.chip of  { Enable ext }
     __S3:begin
	    wrinx(crtc,$38,$48);
	    wrinx(crtc,$39,$A5);
            if (cv.version=S3_732) or (cv.Version=S3_764) then wrinx(SEQ,8,6);
	  end;
   __Trid:begin
            outpw(SEQ,$B);
            if inp(SEQ+1)=0 then;
            x:=rdinx(SEQ,$E) XOR 2;
            outp(SEQ+1,x OR $80);   {Enable extended registers}
          end;
 __Compaq:wrinx(GRC,$F,5);
 {__Video7:wrinx(SEQ,6,$EA); }
  end;
  fillchar(rgs,sizeof(rgs),0);
  oldreg:=false;
  vclk:=0;
  for x:=$3C2 to $3DF do rgs.stdregs[x]:=inp(x);
  rgs.stdregs[$3DA]:=inp(CRTC+6);
  rgs.stdregs[$3C0]:=inp($3C0);
  for x:=0 to 31 do rgs.attregs[x]:=rdinx($3C0,x);
  x:=rdinx($3C0,$30);
  rgs.mode:=curmode;
  dumprg(CRTC,0,0,rgs.crtcregs);
  dumprg(SEQ,0,0,rgs.seqregs);
  dumprg(GRC,0,0,rgs.grcregs);
  for x:=0 to 15 do
    rgs.dacregs[x]:=rdDACreg(x);
  if (DACflags and DFL_CmdReg)>0 then
  begin
    dac2comm;
    rgs.dacregs[16]:=rdDACreg(dacSTDpelMask);
    dac2pel;
  end;
  rgs.dacinxd.nbr :=0;
  rgs.dacinxd.base:=0;
  case cv.chip of
   __3Dfx:begin

            rgs.xxregs.nbr:=255;
            rgs.xxregs.base:=cv.ioadr;
            for z:=0 to 255 do
              rgs.xxregs.x[z]:=inp(cv.ioadr+z);
          end;
   __Alli:begin
            if mem[SegA000:$D8]=0 then;
            outpw(SEQ,$1210);
            setinx(SEQ,$1C,8);
            modinx(SEQ,$1B,7,1);

            rgs.xxregs.nbr:=255;
            rgs.xxregs.base:=1;
            move(mem[SegA000:0],rgs.xxregs.x,256);
            clrinx(SEQ,$1B,7);
            clrinx(SEQ,$1C,8);
          end;
    __ati:begin
            dumprg(cv.IOadr,$A0,$BF,rgs.xxregs);
            rgs.xxregs.x[0]:=inp($6AEC);
            rgs.xxregs.x[1]:=inp($6AED);
            rgs.xxregs.x[2]:=inp($6AEE);
            rgs.xxregs.x[3]:=inp($6AEF);
            rgs.xxregs.x[4]:=inp($72EC);
            rgs.xxregs.x[5]:=inp($72ED);
            rgs.xxregs.x[6]:=inp($72EE);
            rgs.xxregs.x[7]:=inp($72EF);
            rgs.xxregs.x[8]:=inp($62EC);
            rgs.xxregs.x[9]:=inp($62ED);
            rgs.xxregs.x[10]:=inp($62EE);
            rgs.xxregs.x[11]:=inp($62EF);
            rgs.xxregs.x[12]:=inp($1EEC);
            rgs.xxregs.x[13]:=inp($1EED);
            rgs.xxregs.x[14]:=inp($1EEE);
            rgs.xxregs.x[15]:=inp($1EEF);
          end;
  __chips:begin
            dumprg(cv.IOadr,0,0,rgs.xxregs);
            if (cv.version>=CT_65540) and (cv.version<>CT_64200) then
            begin                       {The clock values can't be read}
              clrinx(cv.IOadr,$33,$20);               {VCLK values}
              rgs.xxregs.x[$FA]:=rdinx(cv.IOadr,$30);
              rgs.xxregs.x[$FB]:=rdinx(cv.IOadr,$31);
              rgs.xxregs.x[$FC]:=rdinx(cv.IOadr,$32);
              setinx(cv.IOadr,$33,$20);              {MCLK values}
              rgs.xxregs.x[$FD]:=rdinx(cv.IOadr,$30);
              rgs.xxregs.x[$FE]:=rdinx(cv.IOadr,$31);
              rgs.xxregs.x[$FF]:=rdinx(cv.IOadr,$32);
              wrinx(cv.IOadr,$33,rgs.xxregs.x[$33]);
            end;
          end;
 __cirLAG:begin
            rgs.xxregs.base:=SegB000;
            rgs.xxregs.nbr:=61;
            move(mem[SegB000:$C0],rgs.xxregs.x[0],8);
            move(mem[SegB000:$EA],rgs.xxregs.x[8],3);
            move(mem[SegB000:$1FC],rgs.xxregs.x[11],8);
            if cv.version<CL_GD5465 then
              move(mem[SegB000:$8C],rgs.xxregs.x[19],2)
            else move(mem[SegB000:$2C0],rgs.xxregs.x[19],2);
            move(mem[SegB000:$2C4],rgs.xxregs.x[21],2);
            move(mem[SegB000:$2C8],rgs.xxregs.x[23],2);
            move(mem[SegB000:$3EC],rgs.xxregs.x[25],4);
            move(mem[SegB000:$3F4],rgs.xxregs.x[29],12);
            move(mem[SegB000:$400],rgs.xxregs.x[41],8);
            move(mem[SegB000:$413C],rgs.xxregs.x[49],1);
            move(mem[SegB000:$416C],rgs.xxregs.x[50],2);
            move(mem[SegB000:$4424],rgs.xxregs.x[52],4);
            move(mem[SegB000:$4440],rgs.xxregs.x[56],4);
            x:=rPCIword($F4);
            rgs.xxregs.x[50]:=x;
            rgs.xxregs.x[51]:=hi(x);
            (*for x:=0 to 127 do
            begin
              y:=memw[SegB000:x*2];
              move(y,rgs.xxregs.x[x*2],2);
            end;*)
          end;
 __compaq:begin
	    for x:=1 to 15 do
	      for m:=0 to 15 do
		rgs.xxregs.x[(x-1)*16+m]:=inp(x*$1000+$3C0+m);
	    rgs.xxregs.base:=$3C;
	    rgs.xxregs.nbr:=240;
	  end;
    __hmc:dumprg(SEQ,$0,$FF,rgs.xxregs);
   __IMAG:begin
            rgs.xxregs.base:=cv.IOadr;
            rgs.xxregs.nbr:=255;
            for x:=0 to 127 do
              rgs.xxregs.x[x]:=inp(cv.IOadr+x);
            IMAGonoff(true);
            move(mem[SegA000:0],rgs.xxregs.x[128],128);
            IMAGonoff(false);
            if cv.version>=IMG_T2R4 then
            begin
              outp(cv.IOadr+$9C,0);
              outp(cv.IOadr+$94,0);
              for x:=0 to 255 do
              begin
                outp(cv.IOadr+$90,x);
                rgs.dacinxd.x[x]:=inp(cv.IOadr+$98);
              end;
              rgs.dacinxd.base:=$3C6;
              rgs.dacinxd.nbr:=255;
            end;
          end;
  __ctHiQ,
  __Intel:dumprg($3D6,0,0,rgs.xxregs);
        (*  begin
            flatinstall;
            rgs.xxregs.base:=$2EC;
            rgs.xxregs.nbr:=$68;
            l:=$E2000000;
            for x:=0 to 7 do
            begin
              l2:=rd4Gd(l+$3C0+x*4);
              move(l2,rgs.xxregs.x[x*4],4);
            end;
            for x:=0 to 16 do
            begin
              {l2:=rd4Gd(l+$3000+x*4);}
              move(l2,rgs.xxregs.x[32+x*4],4);
            end;
            l2:=rd4Gd(l+$3040);
            move(l2,rgs.xxregs.x[$60],4);
            l2:=rd4Gd(l+$6000);
            move(l2,rgs.xxregs.x[$64],4);
          end; *)
   __Mach64:begin
              for x:=0 to 255 do
                rgs.xxregs.x[x]:=inp(Mach64io($2EC+(x and 3)+(x and $FC)*256));

             { move(mem[cv.Xseg:0],rgs.xxregs.x,256);
              rgs.xxregs.x[$D4]:=inp($6AEC);
              rgs.xxregs.x[$D5]:=inp($6AED);
              rgs.xxregs.x[$D6]:=inp($6AEE);
              rgs.xxregs.x[$D7]:=inp($6AEF); }
              rgs.xxregs.base:=$2EC;
              rgs.xxregs.nbr:=256;
              if cv.version>=ATI_M64_CT then
              begin
                y:=inp(Mach64IO($4AED));
                for x:=0 to 15 do
                begin
                  outp(Mach64IO($4AED),(y and $C3) or (x*4+2));
                  m:=inp(Mach64IO($4AEE));
                  rgs.xxregs.x[$F0+x]:=inp(Mach64IO($4AEE));  {Should be read twice ?}
                end;
              end;
            end;
   __Mach32:begin
            rgs.xxregs.base:=$2E8;
            rgs.xxregs.nbr:=128;
            for x:=0 to 63 do    {Mach8 & 32}
            begin
              m:=inpw($2E8+(x shl 10));
              rgs.xxregs.x[x*2]:=lo(m);
              rgs.xxregs.x[x*2+1]:=hi(m);
            end;
            if cv.Version>=ATI_GUP_3 then  {Mach32}
            begin
              for x:=0 to 63 do
              begin
                m:=inpw($2EE+(x shl 10));
                rgs.xxregs.x[x*2+128]:=lo(m);
                rgs.xxregs.x[x*2+129]:=hi(m);
              end;
              rgs.xxregs.nbr:=256;
            end;
          end;
    __MGA:begin
            dumprg($3DE,0,0,rgs.xxregs);
            if cv.dactype=_dacInt then
            begin
              y:=rdDACreg(dacTVP6index);
              for y:=0 to $4F do
              begin
                wrDACreg(dacTVP6index,y);
                rgs.dacinxd.x[y]:=rdDACreg(dacTVP6data);
              end;
              rgs.dacinxd.base:=$3C7;
              rgs.dacinxd.nbr:=80;
            end;
          end;
    __Matrox,
    __oak:dumprg($3DE,0,0,rgs.xxregs);
   __OPTi:begin
            rgs.xxregs.base:=$B8f0;
            rgs.xxregs.nbr:=63;
            move(mem[$B8F0:0],rgs.xxregs.x,64);
          end;
  __MPact:begin
            x:=inpw($3D0);
            outpw($3D0,$F800);
            move(mem[SegA000:0],rgs.xxregs.x[0],256);
            rgs.xxregs.base:=$A000;
            rgs.xxregs.nbr:=255;
            outpw($3D0,x);
          end;
     __nV:begin                   {nV1/STG2000}
            cv.xseg:=SegB000;
            write32($1E04,$564E6F47);  {Enable ext}
            write32($1E40,$600000);
            move(mem[SegB000:$2000],rgs.xxregs.x[0],4);
            move(mem[SegB000:$2200],rgs.xxregs.x[4],4);
            move(mem[SegB000:$2400],rgs.xxregs.x[8],4);
            move(mem[SegB000:$2500],rgs.xxregs.x[12],4);
            move(mem[SegB000:$2510],rgs.xxregs.x[16],4);
            move(mem[SegB000:$2520],rgs.xxregs.x[20],4);
            move(mem[SegB000:$2530],rgs.xxregs.x[24],4);
            move(mem[SegB000:$2540],rgs.xxregs.x[28],4);
            move(mem[SegB000:$2550],rgs.xxregs.x[32],4);
            move(mem[SegB000:$2560],rgs.xxregs.x[36],4);
            move(mem[SegB000:$2570],rgs.xxregs.x[40],4);
            write32($1E40,$608000);
            move(mem[SegB000:$3000],rgs.xxregs.x[44],4);
            move(mem[SegB000:$3004],rgs.xxregs.x[48],4);
            move(mem[SegB000:$3008],rgs.xxregs.x[52],4);
            move(mem[SegB000:$300C],rgs.xxregs.x[56],4);
            move(mem[SegB000:$3010],rgs.xxregs.x[60],4);
            move(mem[SegB000:$3014],rgs.xxregs.x[64],4);
            move(mem[SegB000:$3018],rgs.xxregs.x[68],4);
            move(mem[SegB000:$301C],rgs.xxregs.x[72],4);
            write32($1E04,$564E6F4E);  {Disable MMap regs}
            rgs.xxregs.base:=$B000;
            rgs.xxregs.nbr:=75;
          end;
    __nV2:begin   {RIVA}
            wrinx(SEQ,6,$57);
            for x:=$19 to $3f do rgs.crtcregs.x[x]:=rdinx(crtc,x);
            l:=RIVAread($0);move(l,rgs.xxregs.x[0],4);
            l:=RIVAread($100000);move(l,rgs.xxregs.x[4],4);
            l:=RIVAread($100044);move(l,rgs.xxregs.x[8],4);
            l:=RIVAread($100080);move(l,rgs.xxregs.x[12],4);
            l:=RIVAread($1000C0);move(l,rgs.xxregs.x[16],4);
            l:=RIVAread($100200);move(l,rgs.xxregs.x[20],4);
            l:=RIVAread($100204);move(l,rgs.xxregs.x[24],4);
            l:=RIVAread($100300);move(l,rgs.xxregs.x[28],4);
            l:=RIVAread($101000);move(l,rgs.xxregs.x[32],4);
            l:=RIVAread($680504);move(l,rgs.xxregs.x[36],4);
            l:=RIVAread($680508);move(l,rgs.xxregs.x[40],4);
            l:=RIVAread($68050C);move(l,rgs.xxregs.x[44],4);
            l:=RIVAread($680600);move(l,rgs.xxregs.x[48],4);
            l:=RIVAread($478);move(l,rgs.xxregs.x[52],4);
            rgs.xxregs.base:=$3D0;
            rgs.xxregs.nbr:=55;
            wrinx(SEQ,6,0);
          end;
   __REND:begin
            rgs.xxregs.base:=cv.IOadr;
            rgs.xxregs.nbr:=256;
            for x:=0 to 191 do
              rgs.xxregs.x[x]:=inp(cv.IOadr+x);
          end;
     __SC:begin    {Sierra SC15025 24bit DAC}
            setDACreg(dacHIcmd,$10);
            for x:=0 to 31 do
            begin
              wrDACreg(dacSCinx,x);
              rgs.dacinxd.x[x]:=rdDACreg(dacSCdata);
              if x<8 then
                rgs.dacinxd.x[x+32]:=rdDACreg(dacSCdata);
            end;
            rgs.dacinxd.base:=$3C7;
            rgs.dacinxd.nbr:=39;
            clrDACreg(dacHIcmd,$10);
          end;
  __Tseng:if cv.version>=ET_6000 then
          begin
            rgs.xxregs.base:=cv.IOadr;
            rgs.xxregs.nbr:=256;
            for x:=0 to 127 do
              rgs.xxregs.x[x]:=inp(cv.IOadr+x);
            for x:=0 to 63 do
            begin
              outp(cv.IOadr+$67,x);
              rgs.xxregs.x[2*x+128]:=inp(cv.IOadr+$69);
              rgs.xxregs.x[2*x+129]:=inp(cv.IOadr+$69);
            end;
            outp(cv.IOadr+$67,rgs.xxregs.x[$67]);
          end
          else if cv.version>=ET_4W32 then dumprg($217A,0,0,rgs.xxregs);
   __trid:begin
            DumpTridOldRegs;
            if cv.version>=TR_GUI9660 then
            begin
              rgs.xxregs.base:=$2100;
              rgs.xxregs.nbr:=256;
              for x:=0 to 255 do
                rgs.xxregs.x[x]:=inp($2100+x);
            end
            else begin
              rgs.xxregs.base:=cv.IOadr;
              rgs.xxregs.nbr:=256;
              for x:=0 to 255 do
              begin
                outp(cv.IOadr-2,x and $fc);
                rgs.xxregs.x[x]:=inp(cv.IOadr+(x and 3));
              end;
            end;
          end;
   __VLSI:dumprg(cv.IOadr,0,0,rgs.xxregs);
     __WD:if cv.Version=WD_90c24 then
            begin
              wrinx(SEQ,$35,$50);  {Unlock clock regs}
              rgs.seqregs.x[$31]:=rdinx(SEQ,$31);
              wrinx(crtc,$34,$A6);
              wrinx(crtc,$35,$30);
              for x:=$31 to $3F do
                rgs.crtcregs.x[x]:=rdinx(crtc,x);
              wrinx(crtc,$34,0);
              wrinx(crtc,$35,0);
            end
          else if cv.version=WD_9710 then
          begin
            z:=0;
            for x:=1 to 17 do
            begin
              outpw($23C0,$F080);
              outpw($23C0,$F000+WDbnk[x]);
              for m:=1 to WDinx[x] do
              begin
                y:=inpw($23C0);
                rgs.xxregs.x[z]  :=lo(y);
                inc(z);
                if x>6 then
                begin
                  rgs.xxregs.x[z]:=hi(y);
                  inc(z);
                end;
              end;
            end;
            rgs.xxregs.nbr:=z;
            rgs.xxregs.base:=$23C0;
          end;
 (*   __agx:if (inp(cv.IOadr) and 4)=0 then DumpTridOldRegs
	  else DumpXGAregs;  *)
    __AGX,__xbe,__xga:
          DumpXGAregs;
  else rgs.xxregs.base:=0;
  end;

  case cv.dactype of
_dacCL5200:begin
             wrDACreg(dacSTDpelMask,0);
             dac2comm;
             rgs.dacregs[6]:=rdDACreg(dacSTDpelMask);
             dac2pel;
             wrDACreg(dacSTDpelMask,rgs.dacregs[2]);
           end;
_dacMU1880:begin
             dac2comm;
             dac2comm;
             x:=8;
             while (x>0) and (rdDACreg(dacSTDpelMask)<>$8E) do dec(x);
             rgs.dacinxd.x[6]:=rdDACreg(dacSTDpelMask);
             rgs.dacinxd.x[6]:=rdDACreg(dacSTDpelMask);
             dac2pel;

           end;
 _dacSC15021,_dacSc15025:
           begin    {Sierra SC15025 24bit DAC}
             setDACreg(dacHIcmd,$10);
             for x:=0 to 31 do
             begin
               wrDACreg(dacSCinx,x);
               rgs.dacinxd.x[x]:=rdDACreg(dacSCdata);
               if x<8 then
                 rgs.dacinxd.x[x+32]:=rdDACreg(dacSCdata);
             end;
             rgs.dacinxd.base:=$3C7;
             rgs.dacinxd.nbr:=39;
             clrDACreg(dacHIcmd,$10);
           end;
 _dacSTG1700,_dacSTG1702,_dacSTG1703:
           begin
             rgs.dacinxd.base:=$3C6;
             rgs.dacinxd.nbr:=7;
             y:=rdDACreg(dacHIcmd);
             wrDACreg(dacHIcmd,y or 16);
             dac2comm;
             m:=rdDACreg(dacSTDpelMask);
             wrDACreg(dacSTDpelMask,0);
             wrDACreg(dacSTDpelMask,0);
             for x:=0 to 7 do
               rgs.dacinxd.x[x]:=rdDACreg(dacSTDpelMask);
             if cv.dactype=_dacSTG1703 then
             begin
               for x:=8 to $5F do
                 rgs.dacinxd.x[x]:=rdDACreg(dacSTDpelMask);
               rgs.dacinxd.nbr:=$5F;
             end;
             wrDACreg(dacHIcmd,y);
           end;
   _dacSTG1732,_dacSTG1764:
           begin
             rgs.dacinxd.base:=$3C6;
             rgs.dacinxd.nbr:=$5f;
             wrDACreg(5,0);
             for x:=0 to rgs.dacinxd.nbr do
             begin
               wrDACreg(4,x);
               rgs.dacinxd.x[x]:=rdDACreg(6);
             end;
           end;
    _dacATT408:
           begin
             rgs.dacinxd.base:=$3C6;
             rgs.dacinxd.nbr:=7;
             y:=rdDACreg(dacHIcmd);
             wrDACreg(dacHIcmd,y or 1);
             for x:=0 to 127 do
             begin
               wrDACreg(dacSTDwrinx,x);
               rgs.dacinxd.x[x]:=rdDACreg(dacSTDpelMask);
             end;
             dac2comm;
             wrDACreg(dacHIcmd,y);
           end;
 _dacBt481,_dacBt482:
           begin
             if cv.chip=__AGX then outp(cv.IOadr,1);
           (*  outp(SetDACpage(dacBT1cmdA),1);
             for x:=0 to 15 do {This screws up the DAC, so we drop it for now}
             begin
               outp($3C8,x);
               rgs.dacinxd.x[x]:=inp($3C6);
             end;
             rgs.dacinxd.base:=$3C6;
             rgs.dacinxd.nbr:=15;
             outp(SetDACpage(dacBT1cmdA),rgs.dacregs[dacBT1cmdA]); *)
             if cv.chip=__AGX then outp(cv.IOadr,4);
           end;
 _dacBt484,_dacBt485,_dacATT504,_dacATT505:
           begin    {BrookTree Bt484/5 or ATT20c504/5 DAC}
             wrDACreg(dacBTcmd0,rgs.dacregs[dacBTcmd0] or $80);
             wrDACreg(0,0);
             rgs.dacregs[dacBTstat]:=rdDACreg(dacBTstat);
             wrDACreg(0,1);
             rgs.dacregs[16]:=rdDACreg(dacBTstat);
             wrDACreg(dacBTcmd0,rgs.dacregs[dacBTcmd0]);
           end;
_dacCH8391,
_dacCH8398:begin
             wrDACreg(7,0);
             for x:=1 to 4 do y:=rdDACreg(4);
             rgs.dacregs[16]:=rdDACreg(4);
             wrDACreg(7,0);
             for x:=0 to 47 do rgs.dacinxd.x[x]:=rdDACreg(5);
             rgs.dacinxd.base:=$3C8;
             rgs.dacinxd.nbr :=47;
           end;
 _dacICS5301,
 _dacS3_708,_dacS3_716:
           begin  {S3 SDAC and GenDAC}
             wrDACreg(7,0);
             for x:=0 to 31 do  {There are 16 16bit registers}
             begin
               {outp(SetDACpage(7),x);}
               rgs.dacinxd.x[x]:=rdDACreg(5);
             end;
             rgs.dacinxd.base:=$3C6;
             rgs.dacinxd.nbr:=31;
           end;
 _dacTVP3010,_dacTVP3020,_dacTVP3025:
           begin    {TI TVP 302x DAC}
             y:=rdDACreg(dacTVPindex);
             for y:=0 to $3F do
             begin
               wrDACreg(dacTVPindex,y);
               rgs.dacinxd.x[y]:=rdDACreg(dacTVPdata);
             end;

             wrDACreg(dacTVPindex,$2C);
             wrDACreg(dacTVPdata,0);  {PLL 1st byte}
             wrDACreg(dacTVPindex,$2D);
             rgs.dacinxd.x[$40]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2E);
             rgs.dacinxd.x[$43]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2F);
             rgs.dacinxd.x[$46]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2C);
             wrDACreg(dacTVPdata,$15);  {PLL 2nd byte}
             wrDACreg(dacTVPindex,$2D);
             rgs.dacinxd.x[$41]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2E);
             rgs.dacinxd.x[$44]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2F);
             rgs.dacinxd.x[$47]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2C);
             wrDACreg(dacTVPdata,2);  {PLL 3rd byte}
             wrDACreg(dacTVPindex,$2D);
             rgs.dacinxd.x[$42]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2E);
             rgs.dacinxd.x[$45]:=rdDACreg(dacTVPdata);
             wrDACreg(dacTVPindex,$2F);
             rgs.dacinxd.x[$48]:=rdDACreg(dacTVPdata);
             rgs.dacinxd.nbr:=$48;
             rgs.dacinxd.base:=$3C6;
             wrDACreg(dacTVP6index,y);
           end;
 _dacTVP3026,_dacTVP3030:
           begin    {TI TVP 3026/30 DAC}
             y:=rdDACreg(dacTVP6index);
             for y:=0 to $3F do
             begin
               wrDACreg(dacTVP6index,y);
               rgs.dacinxd.x[y]:=rdDACreg(dacTVP6data);
             end;

             wrDACreg(dacTVP6index,$2C);
             wrDACreg(dacTVP6data,0);  {PLL 1st byte}
             wrDACreg(dacTVP6index,$2D);
             rgs.dacinxd.x[$40]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2E);
             rgs.dacinxd.x[$43]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2F);
             rgs.dacinxd.x[$46]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2C);
             wrDACreg(dacTVP6data,$15);  {PLL 2nd byte}
             wrDACreg(dacTVP6index,$2D);
             rgs.dacinxd.x[$41]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2E);
             rgs.dacinxd.x[$44]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2F);
             rgs.dacinxd.x[$47]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2C);
             wrDACreg(dacTVP6data,$2A);  {PLL 3rd byte}
             wrDACreg(dacTVP6index,$2D);
             rgs.dacinxd.x[$42]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2E);
             rgs.dacinxd.x[$45]:=rdDACreg(dacTVP6data);
             wrDACreg(dacTVP6index,$2F);
             rgs.dacinxd.x[$48]:=rdDACreg(dacTVP6data);
             rgs.dacinxd.nbr:=$48;
             rgs.dacinxd.base:=$3C6;
             wrDACreg(dacTVP6index,y);
           end;
_dacMU9910:begin
             rgs.dacinxd.base:=$83C9;
             rgs.dacinxd.nbr:=$1F;
             outp(SetDACpage(7),0);
             for y:=0 to $1F do
               rgs.dacinxd.x[y]:=inp(SetDACpage(5));
           end;
   _dacIBM514,_dacIBM524,_dacIBM525,_dacIBM526,
   _dacIBM528,_dacIBM530,_dacIBM561,_dacIBM624:
           begin
             rgs.dacinxd.base:=$3C6;
             rgs.dacinxd.nbr:=255;

             wrDACreg(dacIBMind1,0);
             for x:=0 to 191 do
             begin
               wrDACreg(dacIBMind0,x);
               rgs.dacinxd.x[x]:=rdDACreg(dacIBMdata);
             end;
             wrDACreg(dacIBMind0,rgs.dacregs[dacIBMind0]);
             x:=rdDACreg(dacIBMdata);
           end;
  end;
  clearDACpage;
  case cv.chip of  { Disable ext }
     __S3:begin
            if (cv.version=S3_732) or (cv.Version=S3_764) then
              wrinx(SEQ,8,rgs.seqregs.x[8]);
	    wrinx(crtc,$38,0);
	    wrinx(crtc,$39,$5A);
	  end;
   __Trid:if cv.version>=TR_GUI9440 then
          begin
            setinx(SEQ,$C,$60);
            rgs.dacregs[ 8]:=inp($43C8);
            rgs.dacregs[ 9]:=inp($43C9);
            rgs.dacregs[10]:=inp($43C6);
            rgs.dacregs[11]:=inp($43C7);
            wrinx(SEQ,$C,rgs.seqregs.x[$C]);
          end;
  end;
  if cheat then cv:=vid[CurrentChip];
end;

procedure CalcRegisters;
{const
  wd24clk:array[0..15] of real=(29.979,77.408,0,80.092,25.175,28.322
          ,65,36,39.822,50.114,42.060,44.297,31.5,35.501,75.166,50.114); }
var x,y,m,wid,wordadr,pixwid,clksel,vclkdiv:word;
    force256,graph,isilace:boolean;
    hfreqfact:word;

  cheat,
  SerialDAC:boolean;     {If set the DAC takes one byte at a time}
  SkipDAC:boolean;     {Skip normal DAC processing if set}
  SkipVGA:boolean;     {Skip VGA processing if set}
begin
  if (cv.chip=__VESA) and (VESAcheat<>0) then
  begin
    cv:=vid[VESAcheat];
    cheat:=true;
  end
  else cheat:=false;
  SerialDAC:=true;
  SkipDAC:=false;
  SkipVGA:=false;
  m:=rgs.grcregs.x[6];
  case (m shr 2) and 3 of
  0,1:calcvseg:=SegA000;
    2:calcvseg:=SegB000;
    3:calcvseg:=SegB800;
  end;
  clksel:=(rgs.stdregs[$3CC] shr 2) and 3;
  vclkdiv:=12;     {Base 12.}
  begin
    ilace:=false;    {Interlaced, double the #lines}
    isilace:=false;  {Interlaced, but do not double lines!!}
    extpixfact:=1;
    extlinfact:=1;

    hfreqfact:=1;
    calclines:=rgs.crtcregs.x[$12];
    pixwid:=8;
    calcpixels:=rgs.crtcregs.x[1];
    force256:=false;
    calchtot:=rgs.crtcregs.x[0]+5;
    calcvtot:=rgs.crtcregs.x[6]+2;

    calchblks:=rgs.crtcregs.x[2];
    calchrtrs:=rgs.crtcregs.x[4];
    calchblke:=rgs.crtcregs.x[3] and 31;
    calchrtre:=rgs.crtcregs.x[5] and 31;
    hrtrmask:=$1F;   {Retrace and blanking masks (valid bits)}
    hblkmask:=$3F;
    calcvblks:=rgs.crtcregs.x[$15];
    calcvrtrs:=rgs.crtcregs.x[$10];
    calcvblke:=rgs.crtcregs.x[$16] and 127;
    calcvrtre:=rgs.crtcregs.x[$11] and 15;
    vblkmask:=$7F;
    vrtrmask:=$F;

    if (rgs.crtcregs.x[7] and   1)>0 then inc(calcvtot, 256);
    if (rgs.crtcregs.x[7] and   2)>0 then inc(calclines,256);
    if (rgs.crtcregs.x[7] and   4)>0 then inc(calcvrtrs,256);
    if (rgs.crtcregs.x[7] and   8)>0 then inc(calcvblks,256);
    if (rgs.crtcregs.x[7] and $20)>0 then inc(calcvtot, 512);
    if (rgs.crtcregs.x[7] and $40)>0 then inc(calclines,512);
    if (rgs.crtcregs.x[7] and $80)>0 then inc(calcvrtrs,512);
    if (rgs.crtcregs.x[5] and $80)>0 then inc(calchblke, 32);
    if (rgs.crtcregs.x[9] and $20)>0 then inc(calcvblks,512);

    if (rgs.seqregs.x[1] and 8)>0 then vclkdiv:=vclkdiv*2;

    graph:=(rgs.attregs[$10] and 1)>0;
    if graph then
    begin
      extlinfact:=(rgs.crtcregs.x[9] and $1F)+1;
      if (rgs.crtcregs.x[9] and $80)>0 then extlinfact:=extlinfact*2;
    end
    else begin
      if {((rgs.attregs[$10] and 4)>0) or} ((rgs.seqregs.x[1] and 1)=0) then charwid:=9 else charwid:=8;
      charhigh:=(rgs.crtcregs.x[9] and $1f)+1;
    end;

    wid:=rgs.crtcregs.x[$13];
    wordadr:=2;
    if (rgs.crtcregs.x[$14] and 64)<>0 then wordadr:=8
    else if (rgs.crtcregs.x[$17] and 64)=0 then wordadr:=4;
    case cv.chip of
      __3Dfx:begin
               if (rgs.crtcregs.x[$1A] and 1)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$1A] and 64)>0 then inc(calchrtrs,256);
               if (rgs.crtcregs.x[$1B] and 1)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$1B] and 16)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$1B] and 64)>0 then inc(calcvrtrs,1024);
               if (rgs.xxregs.x[$5C] and 1)>0 then
               begin
                 calchrtrs:=calchrtrs*8;
                 calchblks:=calchblks*8;
                 calchtot :=calchtot*8;
                 wordadr:=1;pixwid:=1;
                 force256:=true;
                 wid:=rgs.xxregs.x[$E9]*256+rgs.xxregs.x[$E8];
                 calcmmode:=_P8;
                 calcpixels:=((rgs.xxregs.x[$99]*256+rgs.xxregs.x[$98]) and $fff)-1;
                 calclines :=((rgs.xxregs.x[$9A]*256+rgs.xxregs.x[$99]) shr 4)-1;
                 cv.flags:=cv.flags and (not FLG_StdVGA);
                 extlinfact:=1;
               end;
             end;
    __3DLabs:begin
               if (rgs.grcregs.x[9] and 128)>0 then pixwid:=4;
             end;
      __Acer:begin
               wid:=wid+(rgs.crtcregs.x[$81] and 3) shl 8;
               if (rgs.grcregs.x[$B] and $10)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
               if (rgs.grcregs.x[$A] and 1)>0 then pixwid:=16;
               if (rgs.grcregs.x[$A] and 4)>0 then wordadr:=wordadr*2;
               if (rgs.grcregs.x[$A] and $80)>0 then
               begin
                 ilace:=true;
                 wordadr:=wordadr div 2;
               end;
               if (rgs.crtcregs.x[$82] and 1)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$82] and 2)>0 then inc(calcpixels,256);
               if (rgs.crtcregs.x[$82] and 4)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$82] and 8)>0 then
               begin
                 inc(calchblks,64);
                 hblkmask:=$7F;
               end;
               if (rgs.crtcregs.x[$82] and 16)>0 then inc(calchrtrs,256);
               if (rgs.crtcregs.x[$82] and 32)>0 then
               begin
                 inc(calchrtrs,32);
                 hrtrmask:=$3F;
               end;
               if (rgs.crtcregs.x[$83] and 1)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$83] and 2)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$83] and 4)>0 then inc(calcvrtrs,1024);
               if (rgs.crtcregs.x[$83] and 8)>0 then inc(calcvblks,1024);
             end;
       __AGX:begin
	       calcpixels:=rgs.xxregs.x[$13]*256+rgs.xxregs.x[$12]+1;
	       calchtot:=rgs.xxregs.x[$11]*256+rgs.xxregs.x[$10]+1;
	       pixwid:=8;
	       calclines :=rgs.xxregs.x[$23]*256+rgs.xxregs.x[$22]+1;
	       calcvtot:=rgs.xxregs.x[$21]*256+rgs.xxregs.x[$20]+1;
	       wid :=rgs.xxregs.x[$44]*256+rgs.xxregs.x[$43];
	       wordadr:=8;
               vclkdiv:=12;  {Nominal}
               if (rgs.xxregs.x[$50] and 8)>0 then ilace:=true;
	     end;
     __ahead:begin
	       if (rgs.grcregs.x[$1c] and 12)=12 then ilace:=true;
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=16;
	     end;
       __ALG:begin
	       if (rgs.grcregs.x[$C] and $10)>0 then wordadr:=wordadr shl 1
               else if (rgs.crtcregs.x[$14] and 64)>0 then  {Packed mode}
               begin
                 pixwid:=4;
                 vclkdiv:=vclkdiv*2;
               end;
	       if (rgs.crtcregs.x[$19] and 1)>0 then
	       begin
		 ilace:=true;
		 wordadr:=wordadr shr 1;
	       end;
               if (cv.version>ALG_2101) and ((rgs.crtcregs.x[$19] and $80)>0) then
               begin
                 if (rdinx(crtc,$2A) and 1)>0 then inc(calchtot,256);
                 if (rdinx(crtc,$28) and $80)>0 then inc(wid,256);
               end;
	     end;
      __Alli:begin
               if (rgs.grcregs.x[5] and $40)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
                 if cv.version<AS_6422 then pixwid:=4;
               end;
               inc(wid,(rgs.crtcregs.x[$1C] shr 4)*256);
               if (rgs.xxregs.x[$D2] and 1)>0 then isilace:=true;
               if (rgs.crtcregs.x[$1A] and 1)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$1A] and 2)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$1A] and 4)>0 then inc(calcvrtrs,1024);
               if (rgs.crtcregs.x[$1A] and 8)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$1B] and 1)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$1B] and 4)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$1B] and 8)>0 then inc(calchrtrs,256);
             end;
       __ARK:begin
               if (rgs.crtcregs.x[$44] and 4)>0 then ilace:=true;
               if (rgs.crtcregs.x[$41] and 128)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$41] and  64)>0 then inc(calcpixels,256);
               if (rgs.crtcregs.x[$41] and  32)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$41] and  16)>0 then inc(calchrtrs,256);
               if (rgs.crtcregs.x[$41] and   8)>0 then inc(wid,256);
               if (rgs.crtcregs.x[$40] and 128)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$40] and  64)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$40] and  32)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$40] and  16)>0 then inc(calcvrtrs,1024);
             end;
       __ati:begin
               if cv.Version=ATI_18800 then
               begin
                 if (rgs.xxregs.x[$B2] and 1)<>0 then ilace:=true;
               end
  	       else if (rgs.xxregs.x[$BE] and 2)<>0 then ilace:=true;
	       if (rgs.xxregs.x[$B0] and $20)>0 then
	       begin
		 force256:=true;
		 if cv.Version=ATI_18800 then wordadr:=8
                                         else wordadr:=16;
	       end;
               if ((rgs.xxregs.x[$B3] and $40)>0) and (cv.Version>ATI_18800) then
               begin
                 pixwid:=pixwid*2;
                 wordadr:=wordadr*2;
               end;
               if ((rgs.xxregs.x[$B6] and $10)>0) and ((cv.version<ATI_GUP_3)
                   or (cv.Version>=ATI_M64_GX)) then
               begin
                 force256:=false;
               end;
               if ((rgs.xxregs.x[$B1] and $40)>0) then
               begin
                 calclines:=calclines div 2;
                 calcvtot:=calcvtot div 2;
               end;
               if ((rgs.seqregs.x[4] and 8)>0) and not force256 then
                  pixwid:=pixwid*2;   {Mode 65h (PK4) fix}


               if (cv.Version=ATI_28800_6) and ((rgs.xxregs.x[$AD] and 8)>0) then
               begin
                 if (rgs.xxregs.x[$AD] and 1)>0 then inc(calchtot,256);
                 if (rgs.xxregs.x[$AD] and 2)>0 then inc(calchblks,256);
                 if (rgs.xxregs.x[$AD] and 4)>0 then inc(calchrtrs,256);
               end;
	     end;
     __chips:begin
	      { if (rgs.xxregs.x[$D] and 1)<>0 then inc(wid,256);}
               if (rgs.xxregs.x[$D] and 4)>0 then inc(wid,256);
	       if (rgs.xxregs.x[$B] and 4)>0 then
	       begin
                 force256:=true;
		 wordadr:=8;
	         if cv.version<CT_65520 then
                 begin
                   pixwid:=4;
                   vclkdiv:=vclkdiv*2;
                 end;
	       end;
               if (cv.version>=CT_65535) and (cv.version<>CT_64200) then
               begin
                 if (rgs.xxregs.x[$17] and 1)>0 then inc(calchtot,256);
                 if (rgs.xxregs.x[$17] and 2)>0 then inc(calcpixels,256);
                 if (rgs.xxregs.x[$17] and 4)>0 then inc(calchrtrs,256);
                 if (rgs.xxregs.x[$17] and 16)>0 then inc(calchblks,256);
                 if (rgs.xxregs.x[$17] and 64)>0 then
                 begin
                   if (rgs.xxregs.x[$17] and 8)>0 then inc(calchrtre,32);
                   hrtrmask:=$3F;
                   if (rgs.xxregs.x[$17] and 32)>0 then inc(calchblke,64);
                   hblkmask:=$7F;
                 end;
                 if (rgs.xxregs.x[$16] and 1)>0 then inc(calcvtot,1024);
                 if (rgs.xxregs.x[$16] and 2)>0 then inc(calclines,1024);
                 if (rgs.xxregs.x[$16] and 4)>0 then inc(calcvrtrs,1024);
                 if (rgs.xxregs.x[$16] and 16)>0 then inc(calcvblks,1024);
               end;
               if (rgs.xxregs.x[$28] and $20)>0 then ilace:=true;
	     end;
     __cir54:begin
	       if (rgs.seqregs.x[4] and 8)>0 then wordadr:=8;
	       if (rgs.crtcregs.x[$1B] and 16)>0 then inc(wid,256);
	       if (rgs.crtcregs.x[$1A] and 1)>0 then ilace:=true;
               if (rgs.crtcregs.x[$1B] and $80)>0 then
               begin
                 inc(calchblke,(rgs.crtcregs.x[$1A] and $30) shl 2);
                 hblkmask:=$FF;
                 calcvblke:=rgs.crtcregs.x[$16]+((rgs.crtcregs.x[$1A] and $C0) shl 2);
                 vblkmask:=$3FF;
               end;
	     end;
    __cirLAG:begin
               if (rgs.seqregs.x[7] and 1)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
	       if (rgs.crtcregs.x[$1A] and 1)>0 then ilace:=true;
	       if (rgs.crtcregs.x[$1B] and 16)>0 then inc(wid,256);
               if (rgs.crtcregs.x[$1D] and 1)>0 then inc(wid,512);
               if (rgs.crtcregs.x[$1E] and 1)>0 then inc(calcvrtrs,1024);
               if (rgs.crtcregs.x[$1E] and 2)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$1E] and 4)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$1E] and 8)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$1E] and 16)>0 then inc(calchrtrs,256);
               if (rgs.crtcregs.x[$1E] and 32)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$1E] and 64)>0 then inc(calcpixels,256);
               if (rgs.crtcregs.x[$1E] and 128)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$1B] and $80)>0 then
               begin
                 inc(calchblke,(rgs.crtcregs.x[$1A] and $30) shl 2);
                 hblkmask:=$FF;
                 calcvblke:=rgs.crtcregs.x[$16]+((rgs.crtcregs.x[$1A] and $C0) shl 2);
                 vblkmask:=$3FF;
               end;
             end;
     __cir64:begin
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
	       if (rgs.grcregs.x[$82] and 7)=2 then pixwid:=4;
	       if (rgs.grcregs.x[$79] and  1)>0 then inc(calchtot,1024);
	       if (rgs.grcregs.x[$79] and  2)>0 then inc(calclines,1024);
	       if (rgs.grcregs.x[$79] and 16)>0 then inc(calchrtrs,1024);
               inc(calchblks,(rgs.grcregs.x[$79] and $C) shl 7);
	     end;
    __compaq:begin
	       if (rgs.grcregs.x[$F] and $F0)=0 then wordadr:=8;
               inc(wid,(rgs.grcregs.x[$42] and 3)*256);
	       if (rgs.crtcregs.x[$14] and 64)>0 then pixwid:=4;
               if (rgs.grcregs.x[$51] and $40)>0 then inc(calcvtot,1024);
               if (rgs.grcregs.x[$51] and $80)>0 then inc(calcvrtrs,1024);
              { if (rgs.grcregs.x[$51] and $20)>0 then inc(calchrtre,32);
               hrtrmask:=$3F; }
               if cv.version>=CPQ_QV then
               begin
                 SerialDAC:=false;   {Dirty Hack!!}
                 if memmode>=_PK4 then pixwid:=pixwid shr 2;
               end;
	     end;
     __ctHiQ,
     __Intel:begin
               if (rgs.xxregs.x[9] and 1)>0 then  {CRT extensions}
               begin
                 calcvtot :=(calcvtot and $ff)+(rgs.crtcregs.x[$30]*256);
                 calclines:=(calclines and $ff)+(rgs.crtcregs.x[$31]*256);
                 calcvrtrs:=(calcvrtrs and $ff)+(rgs.crtcregs.x[$32]*256);
                 calcvblks:=(calcvblks and $ff)+(rgs.crtcregs.x[$33]*256);
                 inc(wid,rgs.crtcregs.x[$41] shl 8);
                 if (rdinx(crtc,$70) and $80)>0 then ilace:=true;
                 if (rgs.crtcregs.x[$35] and 1)>0 then inc(calchtot,256);
               end;
               if (rgs.xxregs.x[$81] and 15)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
             end;
     __Cyrix:begin
               inc(wid,(rgs.crtcregs.x[$45] and 3) shl 8);
               if (rgs.crtcregs.x[$43] and 1)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
             end;
     __genoa:begin
               if (rgs.crtcregs.x[$2F] and 2)>0 then wordadr:=16
               else if memmode>=_P8 then vclkdiv:=vclkdiv*2;
               if (rgs.crtcregs.x[$2F] and 1)>0 then
               begin
                 ilace:=true;
                 wordadr:=wordadr shr 1;  {Ie. for 2 scanlines, half each}
               end;
               if (rgs.seqregs.x[4] and 8)>0 then pixwid:=4;
               if (rgs.seqregs.x[9] and $20)>0 then pixwid:=pixwid*2;
             end;
       __hmc:begin
               IF (rgs.xxregs.x[$E7] and 1)>0 then ilace:=true;
               if (rgs.xxregs.x[$E7] and 2)>0 then force256:=true;
              { if (rgs.xxregs.x[$E7] and 64)>0 then inc(clksel,4);
               vclk:=HMCclk[clksel]; }
             end;
       __IGS:begin
               if (rgs.grcregs.x[$90] and 1)>0 then wordadr:=8;
               if (rgs.grcregs.x[$11] and 1)>0 then inc(calcvtot,1024);
               if (rgs.grcregs.x[$11] and 2)>0 then inc(calclines,1024);
               if (rgs.grcregs.x[$11] and 4)>0 then inc(calcvrtrs,1024);
               if (rgs.grcregs.x[$11] and 8)>0 then inc(calcvblks,1024);
               if (rgs.grcregs.x[$11] and $20)>0 then ilace:=true;
               inc(wid,(rgs.grcregs.x[$15] and $30)*16);
             end;
      __IMAG:begin
               calcpixels:=rgs.xxregs.x[$B1]*256+rgs.xxregs.x[$B0];
               calchtot  :=rgs.xxregs.x[$B5]*256+rgs.xxregs.x[$B4]+calcpixels;
               calchrtrs :=rgs.xxregs.x[$B9]*256+rgs.xxregs.x[$B8]+calcpixels;
               calchrtre :=rgs.xxregs.x[$BD]*256+rgs.xxregs.x[$BC]+calchrtrs;
               calclines :=rgs.xxregs.x[$C1]*256+rgs.xxregs.x[$C0];
               calcvtot  :=rgs.xxregs.x[$C5]*256+rgs.xxregs.x[$C4]+calclines;
               calcvrtrs :=rgs.xxregs.x[$C9]*256+rgs.xxregs.x[$C8]+calclines;
               calcvrtre :=rgs.xxregs.x[$CD]*256+rgs.xxregs.x[$CC]+calcvrtrs;
               wid:=rgs.xxregs.x[$AD]*256+rgs.xxregs.x[$AC];
               if cv.version=IMG_T2R4 then
               begin
                 case rgs.dacinxd.x[$A] of
                   4:if (rgs.dacinxd.x[$C] and 2)>0 then calcmmode:=_P16
                                                    else calcmmode:=_P15;
                   5:calcmmode:=_P24;
                   6:calcmmode:=_P32;
                 else calcmmode:=_P8;
                 end;
                 SerialDAC:=false;
                 if calcmmode>=_P32 then pixwid:=2
                 else if calcmmode>=_P15 then pixwid:=4
                 else pixwid:=8;
                 SkipDAC:=true;
               end
               else begin
                 SkipVGA:=true;
                 calcmmode:=_P8;
               end;
                    {Rest needed to fool }
                 dec(calcpixels);dec(calclines); wordadr:=1;
               force256:=true;
             end;
    __Mach32:begin
               calcpixels:=rgs.xxregs.x[$D8]+1;   {B2EE}
               calchtot  :=rgs.xxregs.x[$D9]+1;   {B2EF}
               calcvtot  :=(rgs.xxregs.x[$E0]+rgs.xxregs.x[$E1]*256)+1; {C2EE}
               calclines :=(rgs.xxregs.x[$E2]+rgs.xxregs.x[$E3]*256)+1; {C6EE}
               calchrtrs :=rgs.xxregs.x[$DA];   {B6EE}
               calchrtre :=calchrtrs+(rgs.xxregs.x[$DC] and $1F);   {BAEE}
               calcvrtrs :=(rgs.xxregs.x[$E4]+rgs.xxregs.x[$E5]*256)+1; {CAEE}
               calcvrtre :=calcvrtrs+(rgs.xxregs.x[$E8] and $1F);   {D2EE}
               pixwid:=8;
               case rgs.xxregs.x[$C6] and $30 of   {8EEE}
                   0:calcmmode:=_pk4;
                 $10:calcmmode:=_p8;
                 $20:case rgs.xxregs.x[$C6] and $C0 of
                        0:calcmmode:=_p15;
                      $40:calcmmode:=_p16;
                     end;
                 $30:case rgs.xxregs.x[$C7] and 6 of
                       0:calcmmode:=_p24;
                       2:calcmmode:=_p32c;
                       4:calcmmode:=_p24b;
                       6:calcmmode:=_p32b;
                     end;
               end;
               SerialDAC:=false;   {Is this true for all DACs ??}
               {There is no way to determine the bytes/scanline (Write only)}
             end;
    __Mach64:begin
               calchtot  :=(rgs.xxregs.x[$0]+rgs.xxregs.x[$1]*256)+1;
               calcpixels:=(rgs.xxregs.x[$2]+rgs.xxregs.x[$3]*256)+1;
               calcvtot  :=(rgs.xxregs.x[$8]+rgs.xxregs.x[$9]*256)+1;
               calclines :=(rgs.xxregs.x[$A]+rgs.xxregs.x[$B]*256)+1;
               wid       :=(rgs.xxregs.x[$16]+rgs.xxregs.x[$17]*256) shr 6;
               calchrtrs :=rgs.xxregs.x[$4];
               calchrtre :=calchrtrs+(rgs.xxregs.x[$6] and $1F);
               calcvrtrs :=(rgs.xxregs.x[$C]+rgs.xxregs.x[$D]*256)+1;
               calcvrtre :=calcvrtrs+(rgs.xxregs.x[$E] and $1F);
               pixwid:=8;
               calcmmode:=_P8;
               if (rgs.xxregs.x[$1C] and 2)>0 then ilace:=true;
               case rgs.xxregs.x[$1D] and 7 of
                 1:calcmmode:=_PK4;
                 2:calcmmode:=_P8;
                 3:calcmmode:=_P15;
                 4:calcmmode:=_P16;
                 5:calcmmode:=_P24;
                 6:calcmmode:=_P32;
               end;
               wordadr:=usebits[calcmmode];
               SerialDAC:=false;
             end;
    __Matrox:begin
               if (rgs.xxregs.x[$D] and $40)>0 then
               begin
                 ilace:=true;
                 if (rgs.xxregs.x[1] and 8)=0 then   {not Ext 256c}
                   wordadr:=wordadr shr 1;
               end;
               if (rgs.xxregs.x[1] and 8)>0 then   {Ext 256c}
                 wordadr:=wordadr shl 2;
             end;
       __MGA:if (rgs.xxregs.x[3] and 128)>0 then
             begin
               force256:=true;
               if cv.version=MGA_1064SG then wordadr:=16
                                        else wordadr:=8;
               if (rgs.xxregs.x[0] and 128)>0 then ilace:=true;
               inc(wid,(rgs.xxregs.x[0] and $30) shl 4);
               if (rgs.xxregs.x[1] and 1)>0 then inc(calchtot,256);
               if (rgs.xxregs.x[1] and 2)>0 then inc(calchblks,256);
               if (rgs.xxregs.x[1] and 4)>0 then inc(calchrtrs,256);
               if (rgs.xxregs.x[1] and 64)>0 then inc(calchblke,64);
               hblkmask:=$7F;
               inc(calcvtot,(rgs.xxregs.x[2] and 3) shl 10);
               inc(calcvblks,(rgs.xxregs.x[2] and $18) shl 7);
               inc(calcvrtrs,(rgs.xxregs.x[2] and $60) shl 5);
               if (rgs.xxregs.x[2] and 4)>0 then inc(calclines,1024);
             end;
     __MPact:if (rgs.seqregs.x[$87] and 1)>0 then
             begin
               wid:=rgs.xxregs.x[$21]*256+rgs.xxregs.x[$20];
               wordadr:=1;
               calclines:=rgs.xxregs.x[$1D]*256+rgs.xxregs.x[$1C]+1;
               calcpixels:=rgs.xxregs.x[$15]*256+rgs.xxregs.x[$14]+1;
               pixwid:=1;
               force256:=true;
               case rgs.xxregs.x[$48] shr 6 of
                 0:calcmmode:=_P16;
                 2:calcmmode:=_P8;
                 3:calcmmode:=_P24;
               end;
               cv.flags:=cv.flags and (not FLG_StdVGA);
               extlinfact:=1;
             end;
      __mxic:if (rgs.seqregs.x[$F0] and 3)=3 then ilace:=true;
       __MX2:begin
               if (rgs.crtcregs.x[$32] and 1)>0 then
                 wid:=rgs.crtcregs.x[$1F]+(rgs.crtcregs.x[$20] and 3)*256;
               if (rgs.crtcregs.x[$24] and 8)>0 then ilace:=true;
               if (rgs.crtcregs.x[$22] and 1)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$22] and 2)>0 then inc(calcpixels,256);
               if (rgs.crtcregs.x[$22] and 4)>0 then inc(calchrtrs,256);
               if (rgs.crtcregs.x[$22] and 8)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$22] and 16)>0 then inc(calchrtre,32);
               if (rgs.crtcregs.x[$22] and 64)>0 then inc(calchblke,64);
               hrtrmask:=$3F;
               hblkmask:=$7F;
               if (rgs.crtcregs.x[$23] and 1)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$23] and 2)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$23] and 4)>0 then inc(calcvrtrs,1024);
               if (rgs.crtcregs.x[$23] and 8)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$23] and 32)>0 then inc(calcvrtre,16);
               vrtrmask:=$1F;
             end;
       __NCR:begin
	       if (rgs.seqregs.x[$20] and 2)<>0 then
	       begin
		 force256:=true;
		 wordadr:=8;
	       end;
	       if (rgs.seqregs.x[$1F] and $10)<>0 then
		 case rgs.seqregs.x[$1F] and 15 of
		   0:pixwid:=4;
		  11:pixwid:=16;
		 else pixwid:=(rgs.seqregs.x[$1F] and 15)+6;
		 end;
	       if (rgs.crtcregs.x[$30] and $10)<>0 then
	       begin
		 ilace:=true;
		 extlinfact:=1;
	       end;
               if (rgs.crtcregs.x[$30] and  1)>0 then inc(calchtot,256);
	       if (rgs.crtcregs.x[$30] and  2)>0 then inc(calcpixels,256);
               if (rgs.crtcregs.x[$30] and  4)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$30] and  8)>0 then inc(calchrtrs,256);
	       if (rgs.crtcregs.x[$31] and 16)>0 then inc(wid,256);
               if cv.version>=NCR_77c22Ep then
               begin
                 if (rgs.crtcregs.x[$32] and 1)>0 then inc(calchtot,512);
                 if (rgs.crtcregs.x[$32] and 2)>0 then inc(calcpixels,512);
                 if (rgs.crtcregs.x[$32] and 4)>0 then inc(calchblks,512);
                 if (rgs.crtcregs.x[$32] and 8)>0 then inc(calchrtrs,512);
                 if (rgs.crtcregs.x[$33] and 1)>0 then inc(calcvtot,1024);
                 if (rgs.crtcregs.x[$33] and 2)>0 then inc(calclines,1024);
                 if (rgs.crtcregs.x[$33] and 4)>0 then inc(calcvblks,1024);
                 if (rgs.crtcregs.x[$33] and 8)>0 then inc(calcvrtrs,1024);
                 if (rgs.crtcregs.x[$30] and 32)>0 then
                 begin
                   inc(calchblke,(rgs.crtcregs.x[$32] and $30) shl 2);
                   hblkmask:=$FF;
                   inc(calchrtre,(rgs.crtcregs.x[$32] and $C0) shr 1);
                   hrtrmask:=$7F;
                   calcvblke:=rgs.crtcregs.x[$16]+((rgs.crtcregs.x[$33] and $60) shl 3);
                   vblkmask:=$3FF;
                   inc(calchrtre,(rgs.crtcregs.x[$33] and $80) shr 3);
                   vrtrmask:=$1F;
                 end;
               end;
	     end;
        __NM:begin
               inc(wid,rgs.grcregs.x[$F] shl 8);
             end;
        __nV:begin
               cv.xseg:=SegB000;
               write32($1E04,$564E6F47);  {Enable ext}
               write32($1E40,$600000);
               calcpixels:=memw[SegB000:$2530];
               calchrtrs :=calcpixels+memw[SegB000:$2500];
               calchrtre :=calchrtrs+memw[SegB000:$2510];
               calchtot  :=calchrtre+memw[SegB000:$2520];
               calclines :=memw[SegB000:$2570];
               calcvrtrs :=calclines+memw[SegB000:$2540];
               calcvrtre :=calcvrtrs+memw[SegB000:$2550];
               calcvtot  :=calcvrtre+memw[SegB000:$2560];
               case mem[SegB000:$2201] and 3 of
                 1:calcmmode:=_P8;
                 2:calcmmode:=_P16;
               end;
               write32($1E04,$564E6F4E);  {Disable MMap regs}
               hblkmask:=$ffff;hrtrmask:=$ffff;
               vblkmask:=$ffff;vrtrmask:=$ffff;
               pixwid:=1;
              { cv.flags:=cv.flags and (not FLG_StdVGA);}
             end;
       __nV2:begin
               inc(wid,(rgs.crtcregs.x[$19] and $E0) shl 3);
               if (rgs.crtcregs.x[$25] and 1)>0 then inc(calcvtot,$400);
               if (rgs.crtcregs.x[$25] and 2)>0 then inc(calclines,$400);
               if (rgs.crtcregs.x[$25] and 4)>0 then inc(calcvrtrs,$400);
               if (rgs.crtcregs.x[$25] and 8)>0 then inc(calcvblks,$400);
               if (rgs.crtcregs.x[$25] and $10)>0 then inc(calchblke,$40);
               hblkmask:=$7F;
               if (rgs.crtcregs.x[$25] and $20)>0 then inc(wid,$800);
               if (rgs.crtcregs.x[$2D] and 1)>0 then inc(calchtot,$100);
               if (rgs.crtcregs.x[$2D] and 2)>0 then inc(calcpixels,$100);
               if (rgs.crtcregs.x[$2D] and 4)>0 then inc(calchblks,$100);
               if (rgs.crtcregs.x[$2D] and 8)>0 then inc(calchrtrs,$100);
               if (rgs.crtcregs.x[$33] and $80)>0 then ilace:=true;

               if (rgs.attregs[$10] and $40)>0 then
               begin
                 force256:=true;
		 wordadr:=8;
               end;
             end;
       __oak:if cv.version>=OAK_107 then
             begin
	       if (rgs.xxregs.x[$30] and 128)>0 then ilace:=true;
               if (rgs.grcregs.x[5] and 64)>0 then wordadr:=16;
               if (rgs.xxregs.x[$30] and 2)>0 then inc(calcvblks,1024);
               if (rgs.xxregs.x[$30] and 4)>0 then inc(calcvrtrs,1024);
             end
             else if cv.version>OAK_037 then
             begin
	       if (rgs.xxregs.x[$14] and 128)<>0 then ilace:=true;
               if (rgs.xxregs.x[$14] and 1)>0 then inc(calcvtot,1024);
               if (rgs.xxregs.x[$14] and 2)>0 then inc(calclines,1024);
               if (rgs.xxregs.x[$14] and 4)>0 then inc(calcvrtrs,1024);
               if cv.Version<=OAK_083 then
               begin
                 if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=16;
					  {Cheat for 256 color mode}
               end
               else begin
                 if (rgs.seqregs.x[4] and 8)<>0 then
                   if (rgs.xxregs.x[$21] and 4)>0 then wordadr:=16
                                                  else pixwid:=4;
               end;
	     end;
      __OPTi:begin
               inc(wid,(rgs.crtcregs.x[$30] and $60) shl 3);
               if (rgs.crtcregs.x[$30] and 1)>0 then inc(calcvrtrs,1024);
               if (rgs.crtcregs.x[$30] and 2)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$30] and 4)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$30] and 8)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$31] and 64)>0 then ilace:=true;
               if (rgs.seqregs.x[$11] and 1)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
             end;
     __p2000:begin
	       if (rgs.grcregs.x[$13] and $40)<>0 then
	       begin
		 wordadr:=wordadr shr 1;
		 ilace:=true;
	       end;
	       if (rgs.grcregs.x[$21] and $20)<>0 then inc(wid,256);
	     end;
        __WD:if cv.version>=WD_9710 then
             begin
               if (rgs.xxregs.x[WDbk00+9] and 2)>0 then ilace:=true;
               if (rdinx(GRC,5) and 64)>0 then wordadr:=8;
               wid:=rgs.xxregs.x[WDbk11+2]+(rgs.xxregs.x[WDbk11+3] and 15)*256;
               calchtot  :=rgs.xxregs.x[WDbk15+ 2]+(rgs.xxregs.x[WDbk15+ 3] and 15)*256+1;
               calcpixels:=rgs.xxregs.x[WDbk15+ 4]+(rgs.xxregs.x[WDbk15+ 5] and 15)*256+1;
               calchrtrs :=rgs.xxregs.x[WDbk15+10]+(rgs.xxregs.x[WDbk15+11] and 15)*256+1;
               calchblks :=rgs.xxregs.x[WDbk15+ 6]+(rgs.xxregs.x[WDbk15+ 7] and 15)*256+1;
               calcvtot  :=rgs.xxregs.x[WDbk15+16]+(rgs.xxregs.x[WDbk15+17] and 15)*256+1;
               calclines :=rgs.xxregs.x[WDbk15+18]+(rgs.xxregs.x[WDbk15+19] and 15)*256+1;
               calcvrtrs :=rgs.xxregs.x[WDbk15+24]+(rgs.xxregs.x[WDbk15+25] and 15)*256+1;
               calcvblks :=rgs.xxregs.x[WDbk15+20]+(rgs.xxregs.x[WDbk15+21] and 15)*256+1;
             end
             else begin
	       if (cv.version>=WD_90c00) then
                 if (rgs.crtcregs.x[$2D] and $20)>0 then ilace:=true;
	       if (cv.version>=WD_90c30) then
               begin
                 if (rgs.crtcregs.x[$3D] and 1)>0 then inc(calcvtot,1024);
                 if (rgs.crtcregs.x[$3D] and 2)>0 then inc(calclines,1024);
                 if (rgs.crtcregs.x[$3D] and 4)>0 then inc(calcvrtrs,1024);
                 if (rgs.crtcregs.x[$3D] and 8)>0 then inc(calcvblks,1024);
               end;
	       if (rgs.seqregs.x[4] and 8)>0 then wordadr:=8;
					  {Cheat for 256 color mode}
	     {  if (rgs.grcregs.x[$C] and 2)>0 then inc(clksel,4);
	       vclk:=WDclk[clksel];  }
	       if (cv.version>=WD_90c33) and ((rgs.crtcregs.x[$3E] and $20)>0) then inc(calchtot,256);
	     end;
   __realtek:begin
	       if (rgs.seqregs.x[4] and 8)>0 then
               begin
                 pixwid:=4;
                 hfreqfact:=2;
               end;
	       if (rgs.grcregs.x[$C] and $10)>0 then
	       begin
		 pixwid:=pixwid*2;
		 wid:=wid*2;
	       end;
	       if (rgs.crtcregs.x[$19] and 1)>0 then
	       begin
		 ilace:=true;
		 wid:=wid div 2;
	       end;
	     end;
      __Rend:begin
               calcmmode:=_P8;
               pixwid:=8;
               wordadr:=1;
               {cv.flags:=cv.flags and (not FLG_StdVGA);}
               calcpixels:=rgs.xxregs.x[$88]+1;
               calclines :=(rgs.xxregs.x[$8D] and 7)*256+rgs.xxregs.x[$8C]+1;
               case (rgs.xxregs.x[$84] shr 2) and 3 of
                 0:wid:=calcpixels*8;
                 1:wid:=calcpixels*16;
               else wid:=calcpixels*32;
               end;
               if (rgs.xxregs.x[$84] and 16)>0 then m:=128 else m:=64;
               if (wid mod m)<>0 then
                 wid:=(wid div m)*m+rgs.xxregs.x[$98]+rgs.xxregs.x[$99]*256;
               SkipVGA:=true;
             end;
	__s3:begin
	       if (rgs.crtcregs.x[$42] and $20)>0 then ilace:=true;
	       if (rgs.crtcregs.x[$43] and 4)>0   then inc(wid,256);
	       if (rgs.crtcregs.x[$43] and $80)>0 then pixwid:=pixwid*2;
	       if (rgs.seqregs.x[4] and 8)>0 then wordadr:=8 else wordadr:=2;
	       if (rgs.attregs[$10] and 1)=0 then wid:=wid*2;
               if (rgs.crtcregs.x[$3A] and $10)>0 then force256:=true;
               if (cv.Version>S3_924) then
               begin
                 if (rgs.crtcregs.x[$5D] and  1)>0 then inc(calchtot,256);
                 if (rgs.crtcregs.x[$5D] and  2)>0 then inc(calcpixels,256);
                 if (rgs.crtcregs.x[$5D] and  4)>0 then inc(calchblks,256);
                 if (rgs.crtcregs.x[$5D] and 16)>0 then inc(calchrtrs,256);
                 if (rgs.crtcregs.x[$5E] and  1)>0 then inc(calcvtot,1024);
                 if (rgs.crtcregs.x[$5E] and  2)>0 then inc(calclines,1024);
                 if (rgs.crtcregs.x[$5E] and  4)>0 then inc(calcvblks,1024);
                 if (rgs.crtcregs.x[$5E] and 16)>0 then inc(calcvrtrs,1024);
                 if (rgs.crtcregs.x[$51] and $30)>0 then
                   wid:=(wid and $FF)+(rgs.crtcregs.x[$51] and $30) shl 4;
                 if (cv.version>=S3_864) and (cv.dactype<>_dacInt)
                  and ((rgs.crtcregs.x[$67] shr 4)>0) then
                 begin  {16bit DAC path, external DAC}
                   pixwid:=pixwid div 2;
                   vclkdiv:=vclkdiv*2;
                 end;
                 if (cv.version=S3_964) or (cv.version=S3_968) then
                   if (rgs.crtcregs.x[$67] and 16)>0 then
                   begin
                     pixwid:=pixwid*2;
                     vclkdiv:=vclkdiv div 2;
                   end;
               end;
	     end;
        __SC:begin
               wid:=wid+(rgs.seqregs.x[$14] and $30) shl 4;
               if (rgs.seqregs.x[5] and 8)>0 then
               begin
                 isilace:=true;
                 dec(calclines);
               end;
               SerialDAC:=false;
               if (rgs.seqregs.x[4] and 8)>0 then
               begin
                 force256:=true;
               end;
               if (rgs.grcregs.x[$C] and $80)>0 then pixwid:=pixwid*2;
                     {Either bit 1,2 or 4 ?}
               if (rgs.grcregs.x[$C] and 4)>0 then wordadr:=8;
             end;
       __Sig:begin
               wid:=wid+((rgs.crtcregs.x[$45] and $C0) shl 2);
             end;
       __SiS:begin
               wid:=wid+(rgs.seqregs.x[$A] and $F0) shl 4;
               if (rgs.seqregs.x[$A] and 1)>0 then inc(calcvtot,1024);
               if (rgs.seqregs.x[$A] and 2)>0 then inc(calclines,1024);
               if (rgs.seqregs.x[$A] and 4)>0 then inc(calcvblks,1024);  {Swap ?}
               if (rgs.seqregs.x[$A] and 8)>0 then inc(calcvrtrs,1024);
               if (rgs.seqregs.x[6] and $20)>0 then
               begin
                 ilace:=true;
                 wid:=wid shr 1;
               end;
               if cv.version>=SiS_6326 then
               begin
                 if (rgs.seqregs.x[$12] and 1)>0 then inc(calchtot,256);
                 if (rgs.seqregs.x[$12] and 2)>0 then inc(calcpixels,256);
                 if (rgs.seqregs.x[$12] and 4)>0 then inc(calchblks,256);
                 if (rgs.seqregs.x[$12] and 8)>0 then inc(calchrtrs,256);
                 if (rgs.seqregs.x[$12] and 16)>0 then inc(calchblke,64);
                 hblkmask:=$7F;
               end;
             end;
      __trid:begin
               if memmode>=_P8 then wordadr:=8;   {Req'd for 9440 800x600 16bit}
	       if (rgs.tridold0d and 16)<>0 then wordadr:=wordadr*2
	       else if cv.version<TR_GUI9440 then
               begin
                 if (rgs.seqregs.x[4] and 8)>0 then pixwid:=pixwid div 2;
                 if memmode>=_p8 then vclkdiv:=vclkdiv*2;
               end;
	       if (rgs.crtcregs.x[$1e] and 4)<>0 then
                 if cv.version=TR_IITAGX then isilace:=true
                 else begin
                   ilace:=true;
                   if cv.version<TR_GUI9440 then wordadr:=wordadr div 2;
                 end;
               if (cv.mm=512) and (memmode>=_p8) and
                 (cv.version<TR_IITAGX) then hfreqfact:=2;
               if cv.version>=TR_8900CL then
               begin
                 if (rgs.crtcregs.x[$27] and $10)>0 then inc(calclines,1024);
                 if (rgs.crtcregs.x[$27] and $20)>0 then inc(calcvblks,1024);
                 if (rgs.crtcregs.x[$27] and $40)>0 then inc(calcvrtrs,1024);
                 if (rgs.crtcregs.x[$27] and $80)>0 then inc(calcvtot,1024);
                 if (rgs.crtcregs.x[$29] and $10)>0 then inc(wid,256);
                 if cv.version>=TR_GUI9660 then
                 begin
                   if (rgs.crtcregs.x[$29] and $20)>0 then inc(wid,512);
                   if (rgs.seqregs.x[$D] and 2)>0 then pixwid:=pixwid*2;

                   if (rgs.crtcregs.x[$2B] and 1)>0 then inc(calchtot,256);
                 end
                 else
                   if (rgs.grcregs.x[$F] and 8)>0 then pixwid:=pixwid*2;
               end;
	     end;
     __Tseng:if cv.version=ET_3000 then
             begin
	       if (rgs.crtcregs.x[$25] and $80)>0 then ilace:=true;
               if (rgs.crtcregs.x[$25] and 1)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$25] and 2)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$25] and 4)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$25] and 8)>0 then inc(calcvrtrs,1024);
	       if (rgs.grcregs.x[5] and $40)>0 then wordadr:=16;
	       if (rgs.seqregs.x[7] and $40)>0 then
	       begin
		 pixwid:=pixwid*2;
		 wordadr:=wordadr*2;
	       end;
	     end
             else begin {ET4000}
               if (rgs.crtcregs.x[$3F] and $80)>0 then inc(wid,256);
               if (rgs.crtcregs.x[$3F] and  1)>0 then inc(calchtot,256);
               if (rgs.crtcregs.x[$3F] and  4)>0 then inc(calchblks,256);
               if (rgs.crtcregs.x[$3F] and 16)>0 then inc(calchrtrs,256);
               if (rgs.crtcregs.x[$35] and 1)>0 then inc(calcvblks,1024);
               if (rgs.crtcregs.x[$35] and 2)>0 then inc(calcvtot,1024);
               if (rgs.crtcregs.x[$35] and 4)>0 then inc(calclines,1024);
               if (rgs.crtcregs.x[$35] and 8)>0 then inc(calcvrtrs,1024);
               if (rgs.crtcregs.x[$35] and $80)>0 then isilace:=true;
               if (rgs.attregs[$10] and $40)>0 then pixwid:=4;
           {    if ((rgs.attregs[$16] and $20)>0) and (cv.version>=ET_4W32P) then pixwid:=pixwid*2; }
             end;
       __UMC:begin
	       if (rgs.crtcregs.x[$33] and $10)>0 then wordadr:=16
               else if ((rgs.attregs[$10] and 64)>0) then
               begin
                 pixwid:=4;
                 hfreqfact:=2;
               end;
	       if (rgs.crtcregs.x[$2F] and 1)>0 then
	       begin
		 ilace:=true;
		 wordadr:=wordadr div 2;
                 dec(calclines);
	       end;
	     end;
    __video7:begin
	       if (rgs.seqregs.x[$E0] and 1)<>0 then ilace:=true;
               if (rgs.attregs[$10] and $40)>0 then
               begin
                 pixwid:=4;
                 wordadr:=8;
                 hfreqfact:=2;
               end;
               if (rgs.seqregs.x[$C8] and $10)>0 then
               begin
                 force256:=true;
                 wordadr:=8;
               end;
	     end;
      __VLSI:begin
               inc(wid,(rgs.crtcregs.x[$1B] and $60) shl 3);
             end;
    __Weitek:begin
               if (rgs.grcregs.x[$C] and 4)>0 then
               begin
                 wordadr:=8;
                 force256:=true;
               end;
             end;
 __xbe,__xga:begin
	       calchtot  :=rgs.xxregs.x[$11]*256+rgs.xxregs.x[$10]+1;
	       calcpixels:=rgs.xxregs.x[$13]*256+rgs.xxregs.x[$12]+1;
	       calchblks :=rgs.xxregs.x[$15]*256+rgs.xxregs.x[$14]+1;
	       calchblke :=rgs.xxregs.x[$17]*256+rgs.xxregs.x[$16]+1;
	       calchrtrs :=rgs.xxregs.x[$19]*256+rgs.xxregs.x[$18]+1;
	       calchrtre :=rgs.xxregs.x[$1B]*256+rgs.xxregs.x[$1A]+1;
	       pixwid:=8;
	       calclines :=rgs.xxregs.x[$23]*256+rgs.xxregs.x[$22]+1;
	       calcvtot  :=rgs.xxregs.x[$21]*256+rgs.xxregs.x[$20]+1;
	       calcvblks :=rgs.xxregs.x[$25]*256+rgs.xxregs.x[$24]+1;
	       calcvblke :=rgs.xxregs.x[$27]*256+rgs.xxregs.x[$26]+1;
	       calcvrtrs :=rgs.xxregs.x[$29]*256+rgs.xxregs.x[$28]+1;
	       calcvrtre :=rgs.xxregs.x[$2B]*256+rgs.xxregs.x[$2A]+1;  {Hm!!}
	       wid :=rgs.xxregs.x[$44]*256+rgs.xxregs.x[$43];
	       wordadr:=8;
               case rgs.xxregs.x[$51] and 7 of
                 2:calcmmode:=_pk4;
                 3:calcmmode:=_p8;
                 4:calcmmode:=_p16;  {or _p15}
                 5:calcmmode:=_p24;
               end;
               if (rgs.xxregs.x[$50] and 8)>0 then isilace:=true;
	     end;
    end;

    inc(calclines);
    inc(calcpixels);
    if ((cv.flags and FLG_StdVGA)>0) and (not SkipVGA) then
    begin
      calchblke:=(calchblks and (not hblkmask))+calchblke;
      if calchblke<=calchblks then inc(calchblke,hblkmask+1);
      if calchblke>calchtot then calchblke:=calchtot+(hblkmask and calchblke);
      calchrtre:=(calchrtrs and (not hrtrmask))+calchrtre;
      if calchrtre<=calchrtrs then inc(calchrtre,hrtrmask+1);
      if calchrtre>calchtot then calchrtre:=calchtot+(hrtrmask and calchrtre);
      calcvblke:=(calcvblks and (not vblkmask))+calcvblke;
      if calcvblke<=calcvblks then inc(calcvblke,vblkmask+1);
      calcvrtre:=(calcvrtrs and (not vrtrmask))+calcvrtre;
      if calcvrtre<=calcvrtrs then inc(calcvrtre,vrtrmask+1);

      if (rgs.crtcregs.x[$17] and 4)>0 then
      begin
        calclines:=calclines*2;
        calcvtot:=calcvtot*2;
        calcvblks:=calcvblks*2;
        calcvblke:=calcvblke*2;
        calcvrtrs:=calcvrtrs*2;
        calcvrtre:=calcvrtre*2;
      end;
      if ilace then  {Adjust vertical timings}
      begin
        calclines:=calclines*2;
        calcvtot :=calcvtot *2;
        calcvblks:=calcvblks*2;
        calcvblke:=calcvblke*2;
        calcvrtrs:=calcvrtrs*2;
        calcvrtre:=calcvrtre*2;
      end;
      if isilace then ilace:=true;
      if (rgs.attregs[$10] and 1)=0 then  {Text}
      begin
        calclines:=calclines div ((rgs.crtcregs.x[9] and $1F)+1);
        if (rgs.attregs[$10] and 2)=0 then calcmmode:=_TEXT
				      else calcmmode:=_TXT4;
        pixwid:=charwid;
      end
      else begin
        if ((rgs.crtcregs.x[$17] and 1)=0)
          and ((rgs.attregs[$10] and 64)=0) then {CGA}
        begin
	  if (rgs.crtcregs.x[$17] and $40)>0 then calcmmode:=_cga1
					     else calcmmode:=_cga2;
	  extlinfact:=extlinfact shr 1;
        end
        else if ((rgs.attregs[$10] and 64)=0) and ((rgs.grcregs.x[5] and 64)=0)
          and not force256 then  {16 color}
        begin
	  if ((rgs.attregs[$10] and 2)>0) then calcmmode:=_pl1
	  else if (rgs.attregs[$12]=5) then
	  begin
	    calcmmode:=_pl2;
	    pixwid:=pixwid*2;
	  end
	  else if (rgs.seqregs.x[4] and 8)>0 then calcmmode:=_pk4
					     else calcmmode:=_pl4;
        end
        else calcmmode:=_p8;
      end;
    end;


    if (calcmmode>=_PK4) and (cv.dactype>_dac8) and (not skipdac) then
    begin
      x:=rgs.dacregs[6]{getdaccomm};

      case cv.dactype of
   _dac15:if x>127 then calcmmode:=_p15;
   _dac16:case (x and $c0) of
           $80:calcmmode:=_p15;
           $c0:calcmmode:=_p16;
          end;
 _dacALG1101:
          if (cv.chip=__ALG) and ((rgs.crtcregs.x[$19] and 16)>0) then
            calcmmode:=_p16;     {Only used on ALG chips ??}
 _dacMU1880:
          begin
            wrDACreg(dacSTDwrInx,0);
            for m:=1 to 4 do x:=rdDACreg(dacSTDpelMask);
            while x<>$8e do x:=rdDACreg(dacSTDpelMask);
            x:=rdDACreg(dacSTDpelMask);
            rgs.stdregs[$3c1]:=x;
            case x of
              $A6:calcmmode:=_p16;
              $A0:calcmmode:=_p15;
              $9E:calcmmode:=_p24b;
            end;
          end;
 _dacICS5301,_dacMU4910,_dacMU9910,_dacATT490,_dacATT491,_dacATT492,
 _dacATT493,_dacCH8391:
          case (x and $E0) of
         $80,$A0:calcmmode:=_p15;
             $C0:calcmmode:=_p16;
             $E0:calcmmode:=_p24;
          end;
 _dacATT498,_dacATT1498,_dacATT2498:
          case x shr 4 of
            1:begin
                calcmmode:=_p15;
                pixwid:=pixwid*2;
                vclkdiv:=vclkdiv div 2;
              end;
            2:begin
                pixwid:=pixwid*2;
                vclkdiv:=vclkdiv div 2;
              end;
            3:begin
                calcmmode:=_p16;
                pixwid:=pixwid*2;
                vclkdiv:=vclkdiv div 2;
              end;
            5:begin
                calcmmode:=_p32;
                pixwid:=pixwid*2;
                vclkdiv:=vclkdiv div 2;
              end;
            6:calcmmode:=_p16;
           10:calcmmode:=_p15;
          end;
 _dacALG1201,_dacALG1301:
          case (x and $E0) of
            $A0:calcmmode:=_p15;
            $C0:calcmmode:=_p16;
            $E0:calcmmode:=_p24;
          end;
 _dacADAC1:
          case (x and $C7) of
            $C1:calcmmode:=_p16;
            $C5:calcmmode:=_p24;
            $80:calcmmode:=_p15;
          end;
 _dacSC15021,_dacSC15025:
          begin
            case (x and $E1) of
              $41:calcmmode:=_p32b;
              $40:calcmmode:=_p32;
              $61:calcmmode:=_p24b;
              $60:calcmmode:=_p24;
  $80,$81,$A0,$A1:calcmmode:=_p15;
          $C0,$E0:calcmmode:=_p16;
            end;
            if (rgs.dacinxd.x[$10] and 15)>0 then
            begin
              pixwid:=pixwid*2;
              vclkdiv:=vclkdiv div 2;
            end;
          end;
_dacTR8001:case x and $E0 of
             $A0:calcmmode:=_p15;
             $E0:calcmmode:=_p16;
             $C0:calcmmode:=_p24;
           end;
_dacUMC188:case (x and $D0) of
             $80:calcmmode:=_p15;
             $C0:calcmmode:=_p16;
 $10,$50,$90,$D0:calcmmode:=_p24;
           end;
  _dacSTG1732,_dacSTG1764:
           case rgs.dacinxd.x[4] and 3 of
             0:calcmmode:=_PL4;
             1:calcmmode:=_P8;
             2:calcmmode:=_P16;
             3:calcmmode:=_P32;
           end;
  _dacSTG1700,_dacSTG1702,_dacSTG1703:
           if (x and 8)>0 then
             case rgs.dacinxd.x[3] of
               1:begin
                   calcmmode:=_P15;
                   pixwid:=pixwid*2;
                 end;
               2:begin
                   calcmmode:=_p15;
                   pixwid:=pixwid*2;
                   vclkdiv:=vclkdiv div 2;
                 end;
               3:begin
                   calcmmode:=_p16;
                   pixwid:=pixwid*2;
                   vclkdiv:=vclkdiv div 2;
                 end;
               4:begin
                   calcmmode:=_P32;
                   pixwid:=pixwid*2;
                   vclkdiv:=vclkdiv div 2;
                 end;
               5:begin  {P8 - two pixels/clock}
                   calcmmode:=_P8;
                   vclkdiv:=vclkdiv div 2;
                 end;
               6:begin
                   calcmmode:=_P16;
                   pixwid:=pixwid*2;
                 end;
               8:;
               9:begin
                   calcmmode:=_p24;
                   pixwid:=pixwid*2;
                   vclkdiv:=vclkdiv div 2;
                 end;
             end
             else
               case x and $E0 of
                 $A0:calcmmode:=_p15;
                 $C0:calcmmode:=_p16;
                 $E0:calcmmode:=_p24;
               end;
 _dacBt481,_dacBt482:
           case rgs.dacregs[6] and $F0 of
             $A0:calcmmode:=_P15;
             $E0:calcmmode:=_P16;
             $F0:if (rgs.dacregs[6] and 2)=0 then calcmmode:=_P24b
                                             else calcmmode:=_P24;
           end;
 _dacBt484,_dacBt485,_dacATT504,_dacATT505:
           if (rgs.dacregs[9] and $20)>0 then
           begin
             case rgs.dacregs[8] and $78 of
               $10:calcmmode:=_p32;
               $30:calcmmode:=_p15;
               $38:calcmmode:=_p16;
               $60:calcmmode:=_pk4;
             end;
             pixwid:=pixwid*4;
             if (cv.dactype=_dacBt485) or (cv.dactype=_dacATT505) then
               if (rgs.dacregs[16] and 8)>0 then vclkdiv:=vclkdiv div 2; {clk*2}
           end;
_dacCH8398:case rgs.dacregs[dacHIcmd] shr 4 of
             1:begin  {15bit 1VCLK/pixel}
                 calcmmode:=_p15;
                 pixwid:=pixwid*2;
                 vclkdiv:=vclkdiv div 2;
               end;
             3:begin
                 calcmmode:=_p16;
                 pixwid:=pixwid*2;
                 vclkdiv:=vclkdiv div 2;
               end;
             5:begin  {32bpp/2VCLK}
                 calcmmode:=_P32;
                 pixwid:=pixwid*2;
                 vclkdiv:=vclkdiv div 2;
               end;
             6:calcmmode:=_p16;
             7:calcmmode:=_p24;  {24bpp = 2pixels/3VCLKs}
         10,13:begin  {2pixels/VCLK}
                 pixwid:=pixwid*2;
                 vclkdiv:=vclkdiv div 2;
               end;
            $B:begin  {24bpp = 2pixels/3VCLKs}
                 calcmmode:=_p24;
                 pixwid:=pixwid*2;
                 vclkdiv:=vclkdiv div 2;
               end;
            $C:calcmmode:=_p15;
           end;
 _dacIBM514,_dacIBM524,_dacIBM525,_dacIBM526,
 _dacIBM528,_dacIBM530,_dacIBM561,_dacIBM624:
           begin
             case rgs.dacinxd.x[$A] and 7 of
               3:;  {}
               4:if (rgs.dacinxd.x[$C] and 2)>0 then calcmmode:=_P16
                                                else calcmmode:=_P15;
               5:calcmmode:=_P24;
               6:calcmmode:=_P32;
             end;
             if (rgs.dacinxd.x[$71] and $40)>0 then pixwid:=pixwid*2;
             if cv.chip<>__IMAG then SerialDAC:=false;
           end;
 _dacS3_708,_dacS3_716:
           case rgs.dacregs[dacHIcmd] shr 4 of
              1:begin  {2 8bpp pixels/VCLK}
                  vclkdiv:=vclkdiv div 2;
                end;
         2,8,$A:calcmmode:=_p15;
              3:begin
                  calcmmode:=_p15;
                  SerialDAC:=false;
                end;
           4,$E:calcmmode:=_p24;
              5:begin
                  calcmmode:=_p16;
                  SerialDAC:=false;
                end;
           6,$C:calcmmode:=_p16;
              7:begin  {32bpp = 2 VCLKs}
                  calcmmode:=_p32;
                  vclkdiv:=vclkdiv div 2;
                  pixwid:=pixwid*2;
                end;
              9:begin  {24bpp = 1.5 VCLKs}
                  calcmmode:=_p24;
                  vclkdiv:=vclkdiv div 2;
                end;
           end;
 _dacOak88:case rgs.dacregs[dacHIcmd] shr 4 of
              5:begin
                  calcmmode:=_P16;
                  SerialDAC:=false;
                end;
              6:begin
                  calcmmode:=_P32;
                  SerialDAC:=false;
                end;
              7:begin
                  calcmmode:=_P15;
                  SerialDAC:=false;
                end;
             $A:calcmmode:=_P15;
             $C:calcmmode:=_P16;
             $E:calcmmode:=_P24;
           end;
 _dacTVP3010,_dacTVP3020,_dacTVP3025:
           begin
             case rgs.dacinxd.x[$18] and $CF of
               $C:calcmmode:=_P15;
               $D:calcmmode:=_P16;
             6,$E:calcmmode:=_P32;
             end;
             if (rgs.dacinxd.x[$1A] and $10)>0 then
             begin
               vclkdiv:=vclkdiv div 2;
               pixwid:=pixwid*2;
             end;
             SerialDAC:=false;
           end;
 _dacTVP3026,_dacTVP3030:
           begin
             case rgs.dacinxd.x[$18] and $CF of
               $C:calcmmode:=_P15;
               $D:calcmmode:=_P16;
             6,$E:calcmmode:=_P32;
             end;
             SerialDAC:=false;
           end;
 _dacTLC34075,_dacTLC34076:
           begin    {TLC34075}
             if (rgs.dacregs[9]=1) then {On the ATI Mach32 the VCLK is
                                         looped back to CLK1, really should
                                         test explicitly for such loops }
               case (rgs.dacregs[10] shr 3) and 7 of
                 1:vclkdiv:=vclkdiv*2;
                 2:vclkdiv:=vclkdiv*4;
                 3:vclkdiv:=vclkdiv*8;
                 4:vclkdiv:=vclkdiv*16;
                 5:vclkdiv:=vclkdiv*32;
               end;
             SerialDAC:=false;
           end;
   _dacInt:case cv.chip of
              __3Dfx:begin
                       case rgs.xxregs.x[$5E] and $1C of
                         4:calcmmode:=_P16;
                         8:calcmmode:=_P24;
                        12:calcmmode:=_P32;
                       end;
                       SerialDAC:=false;
                     end;
              __Alli:begin
                       case rgs.xxregs.x[$80] and 15 of
                         12:calcmmode:=_P15;
                         13:calcmmode:=_P16;
                         14:calcmmode:=_P24;
                         15:calcmmode:=_P32;
                       end;
                       SerialDAC:=false;
                     end;
             __chips:case rdinx(cv.IOadr,6) and $C of
                       0:if (cv.Version=CT_64300) and
                           ((rgs.xxregs.x[$28] and $10)=0) then calcmmode:=_pk4;
                       4:calcmmode:=_p15;
                       8:calcmmode:=_p24;
                      $C:calcmmode:=_p16;
                     end;
             __cir54:begin
                       case x and $CF of
                     $80,$C0:calcmmode:=_p15;
                         $C1:calcmmode:=_p16;
                         $C5:calcmmode:=_p24;
                         $C8:;  {8bit Grey scale}
                         $C9:;  {3-3-2 RGB}
                       end;
                       if cv.version>=CL_GD5430 then x:=$E else x:=6;
         	       case (rgs.seqregs.x[7] and x) of
		         2:vclkdiv:=vclkdiv*2;
              		 4:if cv.version<CL_GD5446 then vclkdiv:=vclkdiv*3;
                         6:if (cv.version=CL_GD5446) and (calcmmode=_P8) then
                           begin
                             pixwid:=pixwid*2;
                             vclkdiv:=vclkdiv div 2;
                           end;
                         8:if (cv.Version>=CL_GD5430) then calcmmode:=_p32
           	       end;
                       SerialDAC:=false;
                     end;
            __cirLAG:begin           {MMIO C1h}
                       case rgs.xxregs.x[1] and $3E of
                         0:calcmmode:=_P8;
                       $14:calcmmode:=_P16;
                       $16:calcmmode:=_P15;
                       $24:calcmmode:=_P24;
                       $34:calcmmode:=_P32;
                       end;
                       SerialDAC:=false;
                     end;
             __Cyrix:begin
                       SerialDAC:=false;
                       case rgs.crtcregs.x[$46] and 7 of
                         1:calcmmode:=_P16;
                         3:calcmmode:=_P15;
                       end;
                     end;
               __IGS:begin
                       SerialDAC:=false;
                       case rdinx(GRC,$77) and 7 of
                          6:calcmmode:=_P15;
                          2:calcmmode:=_P16;
                        4,5:calcmmode:=_P24;
                        3,7:calcmmode:=_P24;
                       end;
                     end;
             __ctHiQ,
             __Intel:begin
                       SerialDAC:=false;
                       case rgs.xxregs.x[$81] and 15 of
                         0:calcmmode:=_PK4;
                         2:calcmmode:=_P8;
                         4:calcmmode:=_P15;
                         5:calcmmode:=_P16;
                         6:calcmmode:=_P24;
                         7:calcmmode:=_P32;
                       end;
                     end;
               __MGA:begin
                       SerialDAC:=false;
                       case rgs.dacinxd.x[$19] and 7 of
                         0:calcmmode:=_P8;
                         1:calcmmode:=_P15;
                         2:calcmmode:=_P16;
                         3:calcmmode:=_P24;
                       4,7:calcmmode:=_P32;
                       end;
                     end;
               __MX2:begin
                       case rgs.crtcregs.x[$24] and 7 of
                         3:calcmmode:=_P8;
                         4:calcmmode:=_P16;
                         5:calcmmode:=_P24;
                         6:calcmmode:=_P32;
                         7:calcmmode:=_P15;
                       end;
                       SerialDAC:=false;
                     end;
                __NM:begin
                       SerialDAC:=false;
                       case rgs.grcregs.x[$90] and 7 of
                         2:calcmmode:=_P15;
                         3:calcmmode:=_P16;
                         4:calcmmode:=_P24;
                         5:calcmmode:=_P32;
                       end;
                     end;
               __nV2:begin
                       SerialDAC:=false;
                       case rgs.crtcregs.x[$28] and 3 of
                         2:if (rgs.xxregs.x[49] and 16)>0 then {680600.12}
                                calcmmode:=_P16
                           else calcmmode:=_P15;
                         3:calcmmode:=_P32;
                       end;
                     end;
              __OPTi:begin
                       SerialDAC:=false;
                       case rgs.seqregs.x[$11] and $E of
                         2:calcmmode:=_P15;
                         4:calcmmode:=_P24;
                        10:calcmmode:=_P16;
                       end;
                     end;
              __Rend:begin
                       SerialDAC:=false;
                       case rgs.xxregs.x[$B8] and $70 of
                         $40:calcmmode:=_P8;
                         $30:calcmmode:=_P16;
                         $20:calcmmode:=_P15;
                         $10:calcmmode:=_P32;
                       end;
                     end;
                __S3:case rgs.crtcregs.x[$67] shr 4 of
                      { 1:vclkdiv:=vclkdiv div 2;  {2px/VCLK}
                       2:begin
                           calcmmode:=_P15;
                           if cv.version=S3_391 then
                             vclkdiv:=vclkdiv div 2  {1px/VCLK}
                           else SerialDAC:=false;
                         end;
                       3:begin
                           calcmmode:=_P15;
                           if cv.version=S3_391 then
                             SerialDAC:=false
                           else vclkdiv:=vclkdiv div 2;  {1px/VCLK}
                         end;
                       4:begin
                           calcmmode:=_P16;
                           if cv.version=S3_391 then
                             vclkdiv:=vclkdiv div 2  {1px/VCLK}
                           else SerialDAC:=false;
                         end;
                       5:begin
                           calcmmode:=_P16;
                           if cv.version=S3_391 then
                             SerialDAC:=false
                           else vclkdiv:=vclkdiv div 2;  {1px/VCLK}
                         end;
                       7:begin
                           calcmmode:=_P32;
                           vclkdiv:=vclkdiv div 2;  {1px/2VCLK}
                         end;
                       9:begin
                           calcmmode:=_P24;
                           vclkdiv:=vclkdiv div 2;  {2px/3VCLK}
                         end;
                      13:begin
                           if cv.version=S3_988 then calcmmode:=_P24
                                                else calcmmode:=_P32;    {1px/VCLK}
                           SerialDAC:=false;
                         end;
                     end;
                __SC:begin
                       case (x and $E1) of
                         $41:calcmmode:=_p24;
                        { $40:calcmmode:=_p32;
                         $61:calcmmode:=_p24b;
                         $60:calcmmode:=_p24;}
             $80,$81,$A0,$A1:calcmmode:=_p15;
                     $C0,$E0:calcmmode:=_p16;
                       end;
                       if (rgs.dacinxd.x[$10] and 15)>0 then
                       begin
                         pixwid:=pixwid*2;
                         vclkdiv:=vclkdiv div 2;
                       end;
                     end;
               __Sig:begin
                       SerialDAC:=false;
                       case rgs.dacregs[6] shr 4 of
                          1:calcmmode:=_P15;
                          3:calcmmode:=_P16;
                         13:calcmmode:=_P24;
                       end;
                     end;
               __SiS:begin
                       case rgs.seqregs.x[6] and $1C of
                          4:calcmmode:=_P15;
                          8:calcmmode:=_P16;
                         16:if (rgs.seqregs.x[$B] and $80)=0 then calcmmode:=_P24
                                                             else calcmmode:=_P24b;
                       end;
                       SerialDAC:=false;
                     end;
              __Trid:if cv.version<TR_GUI9440 then
                       case rgs.dacregs[6] shr 5 of
                         5:calcmmode:=_p15;
                         7:calcmmode:=_p16;
                         6:calcmmode:=_p24;
                       end
                     else if ((cv.version>=TR_GUI9660) and (cv.version<=TR_GUI9685))
                           or (cv.version>=TR_3D9750) then
                     begin
                       case rgs.dacregs[6] shr 4 of
                         1:calcmmode:=_p15;
                         3:calcmmode:=_p16;
                        13:begin
                             calcmmode:=_p32;
                             vclkdiv:=vclkdiv*2;
                           end;
                       end;
                       SerialDAC:=false;
                     end
                     else {9440,Cyber}
                       case rgs.dacregs[6] shr 4 of
                         1:calcmmode:=_p15;
                         3:calcmmode:=_p16;
                        13:begin
                             calcmmode:=_p24;
                             SerialDAC:=false;
                             vclkdiv:=vclkdiv*3;
                           end;
                       end;
             __Tseng:begin
                       SerialDAC:=false;
                       case rgs.attregs[$16] and $30 of
                         $10:if (rgs.xxregs.x[$58] and 2)>0 then
                                  calcmmode:=_P16
                             else calcmmode:=_P15;
                         $20:calcmmode:=_P24;
                       end;
                     end;
                __WD:if cv.version>=WD_9710 then
                     begin
                       SerialDAC:=false;
                       case rgs.xxregs.x[WDbk11+8]+(rgs.xxregs.x[WDbk11+9] and 15)*256 of
                          $8A:begin
                                calcmmode:=_P24;
                                SerialDAC:=true;
                              end;
                         $130:calcmmode:=_P15;
                         $174:calcmmode:=_P16;
                         $1FC:calcmmode:=_P32;
                       end
                     end
                     else  {WD90c24}
                       case rdinx(SEQ,$26) and $C of
                         4:calcmmode:=_P16;
                       {  8:calcmmode:=_p16b;  }
                        $C:calcmmode:=_P15;
                       end;
           end;
      end;
      if SerialDAC then
	case usebits[calcmmode] of    {Adjust for HiColor}
          16:begin
               pixwid:=pixwid div 2;
               vclkdiv:=vclkdiv*2;
             end;
          24:begin
               calcpixels:=calcpixels div 3;
               calchtot:=calchtot div 3;
               calchblks:=calchblks div 3;
               calchblke:=calchblke div 3;
               calchrtrs:=calchrtrs div 3;
               calchrtre:=calchrtre div 3;
               vclkdiv:=vclkdiv*3;
             end;
          32:begin
               pixwid:=pixwid div 4;
               vclkdiv:=vclkdiv*4;
             end;
	end;
    end;
  end;
  if calcmmode>=_herc then calcpixels:=calcpixels*pixwid;
  calcbytes:=wid*wordadr;

  vclk:=GetClockFreq;
  calchtot :=calchtot*pixwid;
  calchblks:=calchblks*pixwid;
  calchblke:=calchblke*pixwid;
  calchrtrs:=calchrtrs*pixwid;
  calchrtre:=calchrtre*pixwid;
  vclk:=(vclk*12) div vclkdiv;
  if (vclk>0) and (calchtot>0) and (calcvtot>0) then
  begin
    hclk:=(vclk*1000) div (calchtot*hfreqfact);
    fclk:=(hclk*1000) div calcvtot;
  end;
  if extlinfact>0 then calclines:=calclines div extlinfact;
  BWlow :=hclk;
  case memmode of
 _PL4,_PK4,_PK4a:BWlow:=BWlow div 2;
       _P15,_P16:BWlow:=BWlow*2;
      _P24,_P24b:BWlow:=BWlow*3;
     _P32.._P32d:BWlow:=BWlow*4;
  end;

  BWhigh:=(BWlow*calchtot) div 1000;
  BWlow :=(BWlow*calcpixels) div 1000;

  if memmode<=_TXT4 then
  begin
    BWlow :=BWlow*3;
    BWhigh:=(BWhigh*3) div 8;
  end;

  if cheat then cv:=vid[CurrentChip];
  rgs.bytes :=calcbytes;
  rgs.pixels:=calcpixels;
  rgs.lins  :=calclines;
  rgs.mmode :=calcmmode;
  rgs.chip  :=cv.chip;
end;


procedure AnalyseMode;
begin
  DumpRegisters;
  CalcRegisters;
end;



procedure wrregs(base:WORD;nbr:integer;var rg);
type ra=array[0..255] of byte;
var x:word;
  ch:char;
  bp:ra;
begin
  bp:=ra(rg);
  write(hex4(base)+':');
  for x:=0 to nbr-1 do
  begin
    if (x and 3)=0 then ch:='.' else ch:=' ';
    if (x and 15)=0 then ch:=',';
    if (x mod 25)=0 then ch:=' ';
    if (x mod 25=0) and (x>0) then
      write('('+hex2(x)+'):');
    write(ch+hex2(bp[x]));
  end;
  writeln;
end;

procedure wrregblk(var rg:regblk);
var x:word;
begin
  wrregs(rg.base,rg.nbr+1,rg.x);
end;

function dumpVGAregs:word;
var x,y:word;
begin
  settextmode;  {Set 43/50 line text mode}
  writeln('Mode: '+hex2(rgs.mode)+'h Pixels: '+istr(rgs.pixels)+' lines: '+istr(rgs.lins)
       +' bytes: '+istr(rgs.bytes)+' colors: '+istr(modecols[rgs.mmode]));
  writeln;
  if oldreg then writeln('SEQ (OLD): 0Dh: ',hex2(rgs.tridold0d)
				  ,' 0Eh: ',hex2(rgs.tridold0e));

  for x:=$3C0 to $3CF do write(' '+hex2(rgs.stdregs[x]));
  writeln;
  for x:=$3D0 to $3DF do write(' '+hex2(rgs.stdregs[x]));
  writeln;
  wrregs($3C0,32,rgs.attregs);
  wrregblk(rgs.seqregs);
  wrregblk(rgs.grcregs);
  wrregblk(rgs.crtcregs);
  if rgs.xxregs.base<>0 then
  begin
    if (rgs.xxregs.base and $ff8f)=$210A then
    begin
      write(hex4(rgs.xxregs.base and $fff0)+':');
      for x:=0 to 15 do write(' '+hex2(rgs.xgaregs[x]));
      writeln;
    end;
    wrregblk(rgs.xxregs);
  end;
  writeln;
  write('DAC: ');
  for x:=0 to 16 do
    write(' '+hex2(rgs.dacregs[x]));
  writeln;
  if rgs.dacinxd.base<>0 then wrregblk(rgs.dacinxd);
  dumpVGAregs:=getkey;
end;

function FormatRgs(var b:byte):word;   {Format registers for dump}
type
  barr=array[1..2000] of byte;
var
  blk:^barr;
  bts,x:word;

procedure appb(b:byte);
begin
  inc(bts);
  blk^[bts]:=b;
end;

procedure appw(w:word);
begin
  appb(lo(w));
  appb(hi(w));
end;

procedure apprgs(var r:regblk);
var x:word;
begin
  appw(1);
  appw(r.base);
  appb(0);
  appb(r.nbr);
  for x:=0 to r.nbr do appb(r.x[x]);
end;

begin
  blk:=@b;
  bts:=0;
  appw(1);
  appw($3C0);
  appb(0);
  appb(31);
  for x:=0 to 31 do appb(rgs.attregs[x]);
  apprgs(rgs.seqregs);
  apprgs(rgs.grcregs);
  apprgs(rgs.crtcregs);
  if rgs.xxregs.base<>0 then apprgs(rgs.xxregs);
  if oldreg then
  begin
    appw($FF);
    appw(0);
    appb(rgs.tridold0d);
    appw($FF);
    appw(1);
    appb(rgs.tridold0e);
  end;
  for x:=0 to 16 do {DAC registers 0-10h}
  begin
    appw($FF);
    appw($F000+x);
    appb(rgs.dacregs[x]);
  end;
  if rgs.dacinxd.nbr>0 then apprgs(rgs.dacinxd);
  if (rgs.xxregs.base and $FF8F)=$210A then
  begin
    appw(16);
    appw(rgs.xxregs.base-$A);
    for x:=0 to 15 do appb(rgs.xgaregs[x]);
  end;
  appw($3C2);
  appb(rgs.stdregs[$3C2]);
  appw(4);
  appw($3CA);
  for x:=$3CA to $3CD do appb(rgs.stdregs[x]);
  appw(8);
  appw(crtc+4);
  for x:=$3D8 to $3DF do appb(rgs.stdregs[x]);
  appw(0);
  FormatRgs:=bts;
end;


procedure dumpVGAregfile;
var
  f:file of regtype;
begin
  assign(f,'register.vga');
  {$i-}
  reset(f);
  {$i+}
  if ioresult=0 then seek(f,filesize(f)) else rewrite(f);
  write(f,rgs);
  close(f);
end;

End.