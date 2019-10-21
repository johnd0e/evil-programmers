﻿F=far.Flags
K=far.Colors
dialogs={}
id=win.Uuid"02FFA2B9-98F8-4A73-B311-B3431340E272"

ConsoleSize=->
  rr=far.AdvControl"ACTL_GETFARRECT"
  rr.Right-rr.Left+1,rr.Bottom-rr.Top+1

Read=(data)->
  data.file\seek "set",data.offset
  data.data=data.file\read 16*data.height

Write=(data)->
  data.file\seek "set",data.offset
  data.file\write data.data

_title,_view,_edit=1,2,3

HexDraw=(hDlg,data)->
  DrawStr=(pos,str,textel=data.textel)->
    for ii=1,string.len str
      textel.Char=string.byte str,ii
      data.buffer[pos+ii-1]=textel
  GetChar=(pos)->
    char=string.format "%02X",string.byte data.data,pos
    char,data.edit and (string.format "%02X",string.byte data.olddata,pos) or char
  data.textel.Char=0x20
  for ii=1,#data.buffer do
    data.buffer[ii]=data.textel
  len=string.len data.data
  for ii=0,data.height-1
    if ii*16<len
      DrawStr ii*data.width+1,string.format "%010X:",data.offset+ii*16
      data.textel.Char=0x2502
      data.buffer[ii*data.width+24+1+12]=data.textel
    for jj=1,16
      pos=jj+ii*16
      if pos<=len
        char,oldchar=GetChar pos
        txtl=pos==data.cursor and not data.edit and data.textel_sel or (char==oldchar and data.textel or data.textel_changed)
        DrawStr ii*data.width+(jj-1)*3+1+12+(jj>8 and 2 or 0),char,txtl
        DrawStr ii*data.width+16*3+2+1+12+jj,(string.sub data.data,pos,pos),txtl
  if data.edit
    xx,yy=data.editascii and 63+(data.cursor-1)%16 or (data.cursor-1)%16,1+math.floor (data.cursor-1)/16
    xx=12+xx*3+(xx>7 and 2 or 0)+data.editpos if not data.editascii
    hDlg\send F.DM_SETITEMPOSITION,_edit,{Left:xx,Top:yy,Right:xx,Bottom:yy}
    char,oldchar=GetChar data.cursor
    data.editchanged=char~=oldchar
    hDlg\send F.DM_SETTEXT,_edit,data.editascii and (win.Utf16ToUtf8 string.char (string.byte data.data,data.cursor,data.cursor),0) or string.sub char,data.editpos+1,data.editpos+1

UpdateDlg=(hDlg,data)->
  if not data.edit then Read data
  HexDraw hDlg,data
  hDlg\send F.DM_REDRAW

HexDlg=(hDlg,Msg,Param1,Param2)->
  data=dialogs[hDlg\rawhandle!]
  if data
    if Msg==F.DN_CLOSE
      data.file\close!
      dialogs[hDlg\rawhandle!]=nil
    elseif Msg==F.DN_CTLCOLORDLGITEM and Param1==_edit
      color=far.AdvControl F.ACTL_GETCOLOR,data.editchanged and K.COL_VIEWERARROWS or K.COL_VIEWERTEXT
      return {color,color,color,color}
    elseif Msg==F.DN_KILLFOCUS
      if Param1==_edit and data.edit then return _edit
    elseif Msg==F.DN_RESIZECONSOLE
      item=hDlg\send F.DM_GETDLGITEM,_view
      if item
        data.width,data.height=ConsoleSize!
        data.height-=1
        data.buffer=far.CreateUserControl data.width,data.height
        item[4]=data.width-1
        item[5]=data.height
        item[6]=data.buffer
        hDlg\send F.DM_SETDLGITEM,_view,item
        hDlg\send F.DM_RESIZEDIALOG,0,{X:data.width,Y:data.height+1}
        UpdateDlg hDlg,data
    elseif Msg==F.DN_CONTROLINPUT and Param2.EventType==F.KEY_EVENT
      Update=(inc)->
        with data
          if not .edit
            old_offset=.offset
            .offset+=inc
            if .offset>=.filesize
              if (.filesize-old_offset-1)<=.height*16 then .offset=old_offset
              else .offset=.filesize-1
            if .offset<0 then .offset=0
            .offset=.offset-.offset%16
      processed=true
      with data
        DoRight=->
          if not .edit or .editpos==1 or .editascii
            if .cursor+.offset<.filesize then .cursor+=1
            if .cursor>.height*16
              .cursor-=16
              Update 16
            .editpos=0
          else .editpos=1
        DoLeft=->
          if not .edit or .editpos==0 or .editascii
            .cursor-=1
            if .cursor<1
              if .offset>0
                .cursor=16
                Update -16
              else .cursor=1
            .editpos=1
          else .editpos=0
        DoEditMode=->
          .edit=not .edit
          .editpos=0
          .olddata=.edit and .data or nil
          hDlg\send F.DM_SHOWITEM,_edit,data.edit and 1 or 0
          hDlg\send F.DM_SETFOCUS,data.edit and _edit or _view
        uchar=(win.Utf8ToOem Param2.UnicodeChar\sub 1,1)\byte 1
        if data.edit and data.editascii and uchar~=0 and uchar~=9 and uchar~=27
          .data=(string.sub .data,1,.cursor-1)..(string.char uchar)..(string.sub .data,.cursor+1)
          DoRight!
        else
          key=far.InputRecordToName Param2
          switch key
            when '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f'
              old=string.byte .data,.cursor
              new=.editpos==0 and ((tonumber key,16)*16+old%16) or (16*(math.floor old/16)+tonumber key,16)
              .data=(string.sub .data,1,.cursor-1)..(string.char new)..(string.sub .data,.cursor+1)
              DoRight!
            when 'F3' then DoEditMode!
            when 'F9'
              if .edit
                Write data
                DoEditMode!
            when 'Left' then DoLeft!
            when 'Right'
              DoRight!
            when 'Home'
              .cursor-=(.cursor-1)%16
              .editpos=0
            when 'End'
              .cursor+=16
              .cursor=.cursor-(.cursor-1)%16-1
              .editpos=1
            when 'Up'
              .cursor-=16
              if .cursor<1
                .cursor+=16
                if .offset>0 then Update -16
            when 'Down'
              .cursor+=16
              if .cursor+.offset>.filesize
                .cursor-=16
                if .offset+.height*16<.filesize
                  .cursor-=16
                  Update 16
              if .cursor>.height*16
                .cursor-=16
                Update 16
            when 'CtrlPgUp','RCtrlPgUp'
              if .offset==0 and .cursor>16 then .cursor-=16
              else Update -16
            when 'CtrlPgDn','RCtrlPgDn'
              if .offset+.height*16<.filesize
                Update 16
              elseif .offset+.cursor+16<=.filesize
                .cursor+=16
            when 'PgUp'
              if .offset==0 then .cursor=(.cursor-1)%16+1
              else Update -16*.height
            when 'PgDn'
              if .offset+.height*16<.filesize then Update 16*.height
              else
                rest=.filesize-.offset
                .cursor=rest-((15-(.cursor-1)%16)+rest%16)%16
            when 'CtrlHome','RCtrlHome'
              Update -.filesize
              .cursor=1
            when 'CtrlEnd','RCtrlEnd'
              Update .filesize-.offset-1-(.height-1)*16
              if not .edit then .cursor=.filesize-.offset
            when 'BS'
              if .edit
                index=.cursor-(0==.editpos and 1 or 0)
                .data=(string.sub .data,1,index-1)..(string.sub .olddata,index,index)..(string.sub .data,index+1)
                DoLeft!
            when 'Tab' then .editascii=.edit and not .editascii
            else processed=false
      if processed
        UpdateDlg hDlg,data
        return true
  nil

DoHex=->
  filename=viewer.GetFileName!
  file=io.open(filename,"r+b")
  if file
    filesize=file\seek"end"
    if filesize>0
      ww,hh=ConsoleSize!
      buffer=far.CreateUserControl ww,hh-1
      textel=Char:0x20,Attributes:far.AdvControl F.ACTL_GETCOLOR,K.COL_VIEWERTEXT
      textel_sel=Char:0x20,Attributes:far.AdvControl F.ACTL_GETCOLOR,K.COL_VIEWERSELECTEDTEXT
      textel_changed=Char:0x20,Attributes:far.AdvControl F.ACTL_GETCOLOR,K.COL_VIEWERARROWS
      items={
        {F.DI_TEXT,0,0,0,0,0,0,0,0,filename}
        {F.DI_USERCONTROL,0,1,ww-1,hh-1,buffer,0,0,0,""}
        {F.DI_FIXEDIT,0,0,0,0,0,0,0,F.DIF_HIDDEN+F.DIF_READONLY,"9"}
      }
      hDlg=far.DialogInit id,-1,-1,ww,hh,nil,items,F.FDLG_NONMODAL+F.FDLG_NODRAWSHADOW,HexDlg
      if hDlg
        dialogs[hDlg\rawhandle!]=:buffer,width:ww,height:hh-1,:file,offset:0,cursor:1,:filesize,:textel,:textel_sel,:textel_changed,edit:false,editpos:0,editchanged:false,editascii:false
        UpdateDlg hDlg,dialogs[hDlg\rawhandle!]
    else
      file\close!

Macro
  area:"Viewer"
  key:"CtrlF4"
  action:DoHex
