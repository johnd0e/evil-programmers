/*
    ListBoxEx.hpp
    Copyright (C) 2004 zg

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#ifndef __LISTBOXEX_HPP__
#define __LISTBOXEX_HPP__

#include "plugin.hpp"
#include "farkeys.hpp"
#include "farcolor.hpp"

#define sizeofa(array) (sizeof(array)/sizeof(array[0]))

//todo
//sort, findstring, userdata.
//updatestr, insertstr.
#define DM_LISTBOXEX_BASE               (DM_USER+0x1000)
#define DM_LISTBOXEX_INIT               (DM_LISTBOXEX_BASE+0)
#define DM_LISTBOXEX_ISLBE              (DM_LISTBOXEX_BASE+1)
#define DM_LISTBOXEX_FREE               (DM_LISTBOXEX_BASE+2)
#define DM_LISTBOXEX_INFO               (DM_LISTBOXEX_BASE+3)
#define DM_LISTBOXEX_GETFLAGS           (DM_LISTBOXEX_BASE+4)
#define DM_LISTBOXEX_SETFLAGS           (DM_LISTBOXEX_BASE+5)
#define DM_LISTBOXEX_ADD                (DM_LISTBOXEX_BASE+6)
#define DM_LISTBOXEX_ADDSTR             (DM_LISTBOXEX_BASE+7)
#define DM_LISTBOXEX_GETCURPOS          (DM_LISTBOXEX_BASE+8)
#define DM_LISTBOXEX_SETCURPOS          (DM_LISTBOXEX_BASE+9)
#define DM_LISTBOXEX_GETITEM            (DM_LISTBOXEX_BASE+10)
#define DM_LISTBOXEX_DELETE             (DM_LISTBOXEX_BASE+11)
#define DM_LISTBOXEX_UPDATE             (DM_LISTBOXEX_BASE+12)
#define DM_LISTBOXEX_INSERT             (DM_LISTBOXEX_BASE+13)
#define DM_LISTBOXEX_SETCOLORS          (DM_LISTBOXEX_BASE+14)
#define DM_LISTBOXEX_GETDATA            (DM_LISTBOXEX_BASE+15)
#define DM_LISTBOXEX_SETDATA            (DM_LISTBOXEX_BASE+16)
#define DM_LISTBOXEX_GETCURCOL          (DM_LISTBOXEX_BASE+17)
#define DM_LISTBOXEX_SETCURCOL          (DM_LISTBOXEX_BASE+18)

#define DM_LISTBOXEX_ITEM_BASE          (DM_USER+0x1100)
#define DM_LISTBOXEX_ITEM_SETCOLOR      (DM_LISTBOXEX_ITEM_BASE+0)
#define DM_LISTBOXEX_ITEM_SETHOTKEY     (DM_LISTBOXEX_ITEM_BASE+1)
#define DM_LISTBOXEX_ITEM_GETFLAGS      (DM_LISTBOXEX_ITEM_BASE+2)
#define DM_LISTBOXEX_ITEM_SETFLAGS      (DM_LISTBOXEX_ITEM_BASE+3)
#define DM_LISTBOXEX_ITEM_TOGGLE        (DM_LISTBOXEX_ITEM_BASE+4)
#define DM_LISTBOXEX_ITEM_MOVE_UP       (DM_LISTBOXEX_ITEM_BASE+5)
#define DM_LISTBOXEX_ITEM_MOVE_DOWN     (DM_LISTBOXEX_ITEM_BASE+6)
#define DM_LISTBOXEX_ITEM_GETDATA       (DM_LISTBOXEX_ITEM_BASE+7)
#define DM_LISTBOXEX_ITEM_SETDATA       (DM_LISTBOXEX_ITEM_BASE+8)


#define DN_LISTBOXEX_BASE         (DM_USER+0x1200)
#define DN_LISTBOXEX_POSCHANGED   (DN_LISTBOXEX_BASE+0)
#define DN_LISTBOXEX_HOTKEY       (DN_LISTBOXEX_BASE+1)
#define DN_LISTBOXEX_OWNERDRAW    (DN_LISTBOXEX_BASE+2)
#define DN_LISTBOXEX_MOUSEMOVE    (DN_LISTBOXEX_BASE+3)

#define LISTBOXEX_COLOR_BACKGROUND      0
#define LISTBOXEX_COLOR_ITEM            1
#define LISTBOXEX_COLOR_HOTKEY          2
#define LISTBOXEX_COLOR_SELECTEDITEM    3
#define LISTBOXEX_COLOR_SELECTEDHOTKEY  4
#define LISTBOXEX_COLOR_DISABLED        5
#define LISTBOXEX_COLOR_COUNT           6

#define LISTBOXEX_COLOR_DEFAULT    0x0100

#define LISTBOXEX_COLORS_ITEM           0
#define LISTBOXEX_COLORS_SELECTED       1
#define LISTBOXEX_COLORS_DISABLED       2
#define LISTBOXEX_COLORS_COUNT          3

#define LBFEX_WRAPMODE                  1
#define LBFEX_HORIZONTAL_SCROLL         2

#define LIFEX_CHECKED                   1
#define LIFEX_DISABLE                   2
#define LIFEX_HIDDEN                    4

extern long WINAPI ListBoxExDialogProc(HANDLE hDlg,int Msg,int Param1,long Param2);

extern PluginStartupInfo Info;
extern FARSTANDARDFUNCTIONS FSF;

struct ListBoxExItem
{
  long Flags;
  long Hotkey;
  char CheckMark;
  unsigned long Length;
  char *Item;
  unsigned short *Attribute[3];
  void *UserData;
};

struct ListBoxExData
{
  long Flags;
  long Top;
  long CurPos;
  long Frozen;
  long CurCol;
  long UserData;
  long ItemCount;
  ListBoxExItem *Items;
  unsigned short Colors[LISTBOXEX_COLOR_COUNT];
};

//structures for messages
struct ListBoxExSetColor
{
  long Index;
  unsigned long TypeIndex;
  unsigned long ColorIndex;
  unsigned short Color;
};

struct ListBoxExSetHotkey
{
  long Index;
  long Hotkey;
};

struct ListBoxExSetFlags
{
  long Index;
  long Flags;
};

struct ListBoxExManageItem
{
  long Index;
  ListBoxExItem Item;
};

struct ListBoxExAddItem
{
  long Count;
  ListBoxExItem *Items;
};

struct ListBoxExColors
{
  long Count;
  unsigned short *Colors;
};
#endif
